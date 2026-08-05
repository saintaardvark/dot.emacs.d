;;; x-hugh-pi --- Drive the pi coding agent (via nono) from Emacs.  -*- lexical-binding: t; -*-

;;; Commentary:
;;
;; A minimal client for the pi coding agent's RPC mode.  Emacs is the
;; parent process: it spawns `nono run --profile pi -- pi --mode rpc',
;; so pi runs confined inside the nono sandbox while Emacs stays
;; outside.  The JSONL RPC protocol flows over the inherited
;; stdin/stdout pipes (pipes are not subject to nono's Landlock path
;; checks).
;;
;; Protocol reference:
;;   ~/.local/lib/node_modules/@earendil-works/pi-coding-agent/docs/rpc.md
;;
;; Framing: strict JSONL, split on LF (\n) only.  We buffer partial
;; output and parse one object per newline.
;;
;; Quick start:
;;   M-x x-hugh-pi-start
;;   M-x x-hugh-pi-prompt   (or C-c C-p in the pi output buffer)
;;   M-x x-hugh-pi-abort
;;   M-x x-hugh-pi-stop

;;; Code:

(require 'json)
(require 'subr-x)

(defgroup x-hugh-pi nil
  "Drive the pi coding agent from Emacs."
  :group 'tools
  :prefix "x-hugh-pi-")

(defcustom x-hugh-pi-command
  '("nono" "run" "--profile" "pi" "--allow-cwd" "--"
    "pi" "--mode" "rpc" "--no-session")
  "Argv used to launch pi in RPC mode.
By default pi is launched through nono so it runs inside the
sandbox.  `--allow-cwd' grants pi access to the working directory
\(the project you launch it from); without it pi cannot read your
files.  To run pi directly (no sandbox) set this to
\(\"pi\" \"--mode\" \"rpc\"\).

Note: nono prints a human-readable banner to stderr, which this
client keeps separate from the JSON stdout stream (see
`x-hugh-pi--stderr-filter')."
  :type '(repeat string)
  :group 'x-hugh-pi)

(defcustom x-hugh-pi-buffer-name "*pi*"
  "Name of the buffer that displays pi output."
  :type 'string
  :group 'x-hugh-pi)

(defcustom x-hugh-pi-directory nil
  "Working directory in which to launch pi.
When nil, use the current buffer's `default-directory' at start time."
  :type '(choice (const :tag "Current directory" nil) directory)
  :group 'x-hugh-pi)

(defcustom x-hugh-pi-show-thinking nil
  "When non-nil, stream thinking deltas into the output buffer."
  :type 'boolean
  :group 'x-hugh-pi)

;;; Internal state --------------------------------------------------------

(defvar x-hugh-pi--process nil
  "The live pi RPC process, or nil.")

(defvar x-hugh-pi--stderr-process nil
  "Dedicated pipe process carrying pi/nono stderr, or nil.
Kept separate so nono's human-readable banner never reaches the
JSONL parser on stdout.")

(defvar x-hugh-pi--stdout-buffer ""
  "Accumulator for partial stdout lines (JSONL framing).")

(defvar x-hugh-pi--req-counter 0
  "Monotonic counter for RPC request ids.")

(defvar x-hugh-pi--streaming nil
  "Non-nil while pi is producing output for the current prompt.")

;;; Output buffer ---------------------------------------------------------

(defun x-hugh-pi--buffer ()
  "Return the pi output buffer, creating it if needed."
  (let ((buf (get-buffer-create x-hugh-pi-buffer-name)))
    (with-current-buffer buf
      (unless (derived-mode-p 'x-hugh-pi-mode)
        (x-hugh-pi-mode)))
    buf))

(defun x-hugh-pi--insert (face &rest strings)
  "Insert STRINGS propertized with FACE at end of the pi buffer."
  (let ((buf (x-hugh-pi--buffer)))
    (with-current-buffer buf
      (let* ((win (get-buffer-window buf t))
             (at-end (or (null win)
                         (>= (window-point win) (point-max))))
             (inhibit-read-only t)
             (text (apply #'concat strings)))
        (save-excursion
          (goto-char (point-max))
          (insert (if face (propertize text 'face face) text)))
        (when at-end
          (if win
              (set-window-point win (point-max))
            (goto-char (point-max))))))))

;;; JSONL send / receive --------------------------------------------------

(defun x-hugh-pi--send (obj)
  "Encode OBJ as JSON and send it to pi with a trailing newline."
  (unless (process-live-p x-hugh-pi--process)
    (user-error "pi is not running (M-x x-hugh-pi-start)"))
  (let ((json-encoding-pretty-print nil))
    (process-send-string
     x-hugh-pi--process
     (concat (json-encode obj) "\n"))))

(defun x-hugh-pi--next-id ()
  "Return a fresh request id string."
  (format "emacs-%d" (setq x-hugh-pi--req-counter
                            (1+ x-hugh-pi--req-counter))))

(defun x-hugh-pi--filter (_proc chunk)
  "Process filter: buffer CHUNK and dispatch complete JSONL lines."
  (setq x-hugh-pi--stdout-buffer (concat x-hugh-pi--stdout-buffer chunk))
  ;; Split on LF only, per pi's strict JSONL framing.
  (while (let ((nl (string-search "\n" x-hugh-pi--stdout-buffer)))
           (when nl
             (let ((line (substring x-hugh-pi--stdout-buffer 0 nl)))
               (setq x-hugh-pi--stdout-buffer
                     (substring x-hugh-pi--stdout-buffer (1+ nl)))
               ;; Tolerate optional trailing CR.
               (when (string-suffix-p "\r" line)
                 (setq line (substring line 0 -1)))
               (x-hugh-pi--handle-line line))
             t))))

(defun x-hugh-pi--stderr-filter (_proc chunk)
  "Insert stderr CHUNK (nono/pi diagnostics) into the pi buffer as meta."
  (x-hugh-pi--insert 'x-hugh-pi-meta-face chunk))

(defun x-hugh-pi--handle-line (line)
  "Parse one JSONL LINE from pi and dispatch on its type."
  (when (> (length (string-trim line)) 0)
    (let ((event (condition-case err
                     (let ((json-object-type 'alist)
                           (json-array-type 'list)
                           (json-key-type 'symbol))
                       (json-read-from-string line))
                   (error
                    (x-hugh-pi--insert 'error
                                       (format "\n[pi: bad JSON: %s]\n"
                                               (error-message-string err)))
                    nil))))
      (when event
        (x-hugh-pi--dispatch event)))))

(defun x-hugh-pi--alist (event key)
  "Return value of KEY in EVENT alist."
  (alist-get key event))

(defun x-hugh-pi--dispatch (event)
  "Act on a parsed pi EVENT alist."
  (pcase (x-hugh-pi--alist event 'type)
    ("agent_start"
     (setq x-hugh-pi--streaming t)
     (x-hugh-pi--insert 'x-hugh-pi-assistant-face "\n\npi> "))
    ("message_update"
     (x-hugh-pi--handle-delta
      (x-hugh-pi--alist event 'assistantMessageEvent)))
    ("agent_settled"
     (setq x-hugh-pi--streaming nil)
     (x-hugh-pi--insert 'x-hugh-pi-meta-face "\n"))
    ("tool_execution_start"
     (x-hugh-pi--insert 'x-hugh-pi-meta-face
                        (format "\n  [tool: %s]"
                                (x-hugh-pi--alist event 'toolName))))
    ("auto_retry_start"
     (x-hugh-pi--insert 'x-hugh-pi-meta-face
                        (format "\n  [retry %s/%s: %s]"
                                (x-hugh-pi--alist event 'attempt)
                                (x-hugh-pi--alist event 'maxAttempts)
                                (x-hugh-pi--alist event 'errorMessage))))
    ("compaction_start"
     (x-hugh-pi--insert 'x-hugh-pi-meta-face "\n  [compacting context...]"))
    ("extension_error"
     (x-hugh-pi--insert 'error
                        (format "\n  [extension error: %s]"
                                (x-hugh-pi--alist event 'error))))
    ("response"
     ;; Command ack; surface failures only.
     (unless (eq t (x-hugh-pi--alist event 'success))
       (x-hugh-pi--insert 'error
                          (format "\n[pi error: %s]\n"
                                  (x-hugh-pi--alist event 'error)))))
    (_ nil)))

(defun x-hugh-pi--handle-delta (delta)
  "Render a streaming assistantMessageEvent DELTA alist."
  (when delta
    (pcase (x-hugh-pi--alist delta 'type)
      ("text_delta"
       (x-hugh-pi--insert nil (or (x-hugh-pi--alist delta 'delta) "")))
      ("thinking_delta"
       (when x-hugh-pi-show-thinking
         (x-hugh-pi--insert 'x-hugh-pi-thinking-face
                            (or (x-hugh-pi--alist delta 'delta) ""))))
      (_ nil))))

;;; Faces -----------------------------------------------------------------

(defface x-hugh-pi-assistant-face
  '((t :inherit font-lock-keyword-face :weight bold))
  "Face for the pi prompt marker."
  :group 'x-hugh-pi)

(defface x-hugh-pi-user-face
  '((t :inherit font-lock-string-face :weight bold))
  "Face for echoed user prompts."
  :group 'x-hugh-pi)

(defface x-hugh-pi-meta-face
  '((t :inherit shadow))
  "Face for tool/retry/meta annotations."
  :group 'x-hugh-pi)

(defface x-hugh-pi-thinking-face
  '((t :inherit shadow :slant italic))
  "Face for thinking output."
  :group 'x-hugh-pi)

;;; Commands --------------------------------------------------------------

;;;###autoload
(defun x-hugh-pi-start ()
  "Start pi in RPC mode (through nono) and show its output buffer."
  (interactive)
  (when (process-live-p x-hugh-pi--process)
    (user-error "pi is already running"))
  (let* ((default-directory (or x-hugh-pi-directory default-directory))
         (buf (x-hugh-pi--buffer)))
    (setq x-hugh-pi--stdout-buffer ""
          x-hugh-pi--req-counter 0
          x-hugh-pi--streaming nil)
    (setq x-hugh-pi--stderr-process
          (make-pipe-process
           :name "x-hugh-pi-stderr"
           :buffer nil
           :noquery t
           :coding 'utf-8-unix
           :filter #'x-hugh-pi--stderr-filter))
    (x-hugh-pi--insert 'x-hugh-pi-meta-face
                       (format "\n=== pi started in %s ===\n%s\n"
                               default-directory
                               (mapconcat #'identity x-hugh-pi-command " ")))
    (setq x-hugh-pi--process
          (make-process
           :name "x-hugh-pi"
           :buffer nil                  ; we manage output ourselves
           :command x-hugh-pi-command
           :connection-type 'pipe
           :noquery t
           :coding 'utf-8-unix
           :stderr x-hugh-pi--stderr-process
           :filter #'x-hugh-pi--filter
           :sentinel #'x-hugh-pi--sentinel))
    (pop-to-buffer buf)
    x-hugh-pi--process))

(defun x-hugh-pi--sentinel (_proc event)
  "Sentinel: note when pi EVENT indicates the process has exited."
  (unless (process-live-p x-hugh-pi--process)
    (setq x-hugh-pi--streaming nil)
    (x-hugh-pi--insert 'x-hugh-pi-meta-face
                       (format "\n=== pi %s ===\n" (string-trim event)))))

;;;###autoload
(defun x-hugh-pi-prompt (message)
  "Send MESSAGE to pi.  If already streaming, queue it as a steer."
  (interactive
   (list (read-string (if x-hugh-pi--streaming "Steer pi: " "Prompt pi: "))))
  (unless (process-live-p x-hugh-pi--process)
    (x-hugh-pi-start))
  (x-hugh-pi--insert 'x-hugh-pi-user-face (format "\n\nyou> %s" message))
  (if x-hugh-pi--streaming
      (x-hugh-pi--send `((type . "steer") (message . ,message)))
    (x-hugh-pi--send `((id . ,(x-hugh-pi--next-id))
                       (type . "prompt")
                       (message . ,message)))))

;;;###autoload
(defun x-hugh-pi-prompt-region (start end)
  "Send the region between START and END to pi as a prompt."
  (interactive "r")
  (x-hugh-pi-prompt (buffer-substring-no-properties start end)))

;;;###autoload
(defun x-hugh-pi-follow-up (message)
  "Queue MESSAGE to be delivered after pi finishes the current run."
  (interactive (list (read-string "Follow-up: ")))
  (x-hugh-pi--send `((type . "follow_up") (message . ,message))))

;;;###autoload
(defun x-hugh-pi-abort ()
  "Abort pi's current operation."
  (interactive)
  (x-hugh-pi--send '((type . "abort")))
  (x-hugh-pi--insert 'x-hugh-pi-meta-face "\n[abort sent]\n"))

;;;###autoload
(defun x-hugh-pi-stop ()
  "Terminate the pi process."
  (interactive)
  (when (process-live-p x-hugh-pi--process)
    (delete-process x-hugh-pi--process))
  (when (process-live-p x-hugh-pi--stderr-process)
    (delete-process x-hugh-pi--stderr-process))
  (setq x-hugh-pi--process nil
        x-hugh-pi--stderr-process nil
        x-hugh-pi--streaming nil))

;;;###autoload
(defun x-hugh-pi-toggle-thinking ()
  "Toggle whether thinking output is shown."
  (interactive)
  (setq x-hugh-pi-show-thinking (not x-hugh-pi-show-thinking))
  (message "pi thinking output: %s"
           (if x-hugh-pi-show-thinking "on" "off")))

;;; Major mode ------------------------------------------------------------

(defvar x-hugh-pi-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-p") #'x-hugh-pi-prompt)
    (define-key map (kbd "C-c C-f") #'x-hugh-pi-follow-up)
    (define-key map (kbd "C-c C-c") #'x-hugh-pi-abort)
    (define-key map (kbd "C-c C-k") #'x-hugh-pi-stop)
    (define-key map (kbd "C-c C-t") #'x-hugh-pi-toggle-thinking)
    map)
  "Keymap for `x-hugh-pi-mode'.")

(define-derived-mode x-hugh-pi-mode special-mode "pi"
  "Major mode for the pi coding agent output buffer."
  (setq-local truncate-lines nil)
  (visual-line-mode 1)
  (buffer-disable-undo))

(provide 'x-hugh-pi)
;;; x-hugh-pi.el ends here
