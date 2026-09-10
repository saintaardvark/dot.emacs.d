;;; -*- lexical-binding: t -*-
;;; x-hugh-claude --- Claude Code in Emacs, caged by nono

;;; Commentary:

;; Take 2: claude-code-ide.el instead of claude-code.el + monet.
;;
;; The monet route (see branch claude-nono) got a provably healthy
;; websocket between the sandboxed CLI and Emacs, but the model never
;; received its mcp__ide tools (NO_IDE_DIAGNOSIS.md, TODO-claude.md).
;; claude-code-ide.el implements the same IDE protocol with its own
;; MCP websocket server; claude still runs in a ghostel buffer,
;; still confined by nono via bin/claude-nono, which translates
;; CLAUDE_CODE_SSE_PORT into a nono --open-port hole (claude-code-ide
;; uses the same env var).
;;
;; Outbound traffic is default-deny as of 2026-08-31, via the
;; claude-local nono profile.  See bin/claude-nono and
;; NETWORK-FILTERING-PLAN.md.
;;
;; Keybindings (here, not x-hugh-keymap, so use-package can autoload):
;;   C-c c -> claude-code-ide-menu
;;   C-c N -> x-hugh-claude-notes (the pinned notes toggle)
;;
;; Unbound, for a hydra:
;;   x-hugh-claude-notes-toggle         ordinary window, C-x C-f style
;;   x-hugh-claude-notes-toggle-pinned  notes and Claude both side windows

;;; Code:

;; The ghostel terminal backend needs ghostel loaded.
(require 'x-hugh-ghostel)

(defcustom x-hugh-claude-notes-file "NOTES-claude.md"
  "File (relative to the project root) where Claude keeps running notes."
  :type 'string
  :group 'tools)

(defcustom x-hugh-claude-notes-side 'right
  "Frame side for the pinned notes window.
`right' stacks it above the Claude window in the same column;
`left' gives it a full-height column of its own, opposite Claude."
  :type '(choice (const :tag "Right, stacked above Claude" right)
                 (const :tag "Left, opposite Claude" left))
  :group 'tools)

(defcustom x-hugh-claude-notes-width nil
  "Width in columns of the pinned notes window.
nil means match `claude-code-ide-window-width' when the notes share
Claude's column, and 80 otherwise."
  :type '(choice (const :tag "Automatic" nil) integer)
  :group 'tools)

(defun x-hugh-claude--notes-file ()
  "Absolute path of the current project's Claude notes file."
  (require 'project)
  (let* ((proj (project-current))
         (root (if proj (project-root proj) default-directory)))
    (expand-file-name x-hugh-claude-notes-file root)))

(defun x-hugh-claude--notes-buffer ()
  "Return the buffer visiting the project's notes file, visiting it if needed.
The buffer auto-reverts, so it live-updates as Claude writes to it."
  (let ((buf (find-file-noselect (x-hugh-claude--notes-file))))
    (with-current-buffer buf
      (auto-revert-mode 1))
    buf))

(defun x-hugh-claude--notes-window ()
  "Return the window on this frame showing the notes file, or nil.
Deliberately uses `get-file-buffer': asking whether the notes are
visible must not visit the file."
  (let ((buf (get-file-buffer (x-hugh-claude--notes-file))))
    (and buf (get-buffer-window buf))))

(defun x-hugh-claude--notes-width ()
  "Width in columns for the pinned notes window."
  (or x-hugh-claude-notes-width
      (and (eq x-hugh-claude-notes-side 'right)
           ;; Sharing Claude's column: an equal width means displaying
           ;; the notes does not resize the column under Claude.
           (bound-and-true-p claude-code-ide-window-width))
      80))

(defun x-hugh-claude--hide-window (win)
  "Remove WIN from the frame, or show its previous buffer if it cannot go.
`delete-window' signals on the sole main window, which happens when the
notes are the only thing left outside the side windows."
  (condition-case nil
      (delete-window win)
    (error (switch-to-prev-buffer win))))

(defun x-hugh-claude-notes-toggle ()
  "Toggle an ordinary window showing the project's Claude notes file.
This is the \\[find-file] equivalent: the window is split off the main
area and behaves like any other.  For a window that survives
\\[delete-other-windows], use `x-hugh-claude-notes-toggle-pinned'."
  (interactive)
  (if-let* ((win (x-hugh-claude--notes-window)))
      (x-hugh-claude--hide-window win)
    (display-buffer (x-hugh-claude--notes-buffer)
                    '(display-buffer-pop-up-window
                      (inhibit-same-window . t)))))

(defun x-hugh-claude-notes-toggle-pinned ()
  "Toggle the project's Claude notes file in a side window.
On: the notes join Claude as a side window, so \\[delete-other-windows]
leaves both standing and no stray `display-buffer' reuses either.  Off:
back to Claude alone.  `x-hugh-claude-notes-side' picks the edge.

The notes take slot -1 on the right.  claude-code-ide assigns its
instances non-negative slots only (blocks of 16 at 0, 16, 32 ...), so a
negative slot is never claimed out from under this window -- where slot
0, the default, would land in Claude's own window and displace it."
  (interactive)
  (if-let* ((win (x-hugh-claude--notes-window)))
      (x-hugh-claude--hide-window win)
    (display-buffer
     (x-hugh-claude--notes-buffer)
     `((display-buffer-in-side-window)
       (side . ,x-hugh-claude-notes-side)
       (slot . ,(if (eq x-hugh-claude-notes-side 'right) -1 0))
       (window-width . ,(x-hugh-claude--notes-width))
       (window-parameters . ((no-delete-other-windows . t)))))))

;; C-c N kept its meaning: show the notes in a side window.
(defalias 'x-hugh-claude-notes #'x-hugh-claude-notes-toggle-pinned)

;; The external editor (C-x C-e / ctrl-g in Claude's TUI) opens the
;; prompt in an emacsclient buffer.  With `server-window' nil, server.el
;; switches to it in whatever window is selected -- never the Claude
;; side window, which is dedicated -- so a second window shoulders into
;; the frame.  Put the buffer in the Claude window instead: C-x # kills
;; it (`server-kill-new-buffers' is t by default) and the window falls
;; back to the terminal underneath.

(defcustom x-hugh-claude-editor-in-claude-window t
  "Non-nil to show Claude's external-editor buffer in the Claude window.
Only buffers visiting a file under `temporary-file-directory' are
redirected; every other emacsclient request keeps server.el's default
placement."
  :type 'boolean
  :group 'tools)

(defvar x-hugh-claude--redirected-window nil
  "Window whose dedication `x-hugh-claude-server-window' cleared.")

(defun x-hugh-claude--claude-buffer-p (buffer)
  "Return non-nil if BUFFER is a Claude Code terminal buffer."
  (string-prefix-p "*claude-code" (buffer-name buffer)))

(defun x-hugh-claude--window ()
  "Return a window on the selected frame showing a Claude Code buffer."
  (seq-find (lambda (win) (x-hugh-claude--claude-buffer-p (window-buffer win)))
            (window-list nil 'never)))

(defun x-hugh-claude--rededicate (&rest _)
  "Re-dedicate the borrowed Claude window once the terminal is back in it.
`set-window-buffer' resets soft dedication to nil, so the window stays
undedicated for as long as the editor buffer lives there."
  (let ((win x-hugh-claude--redirected-window))
    (when (or (not (window-live-p win))
              (x-hugh-claude--claude-buffer-p (window-buffer win)))
      (when (window-live-p win)
        (set-window-dedicated-p win t))
      (setq x-hugh-claude--redirected-window nil)
      (remove-hook 'window-buffer-change-functions #'x-hugh-claude--rededicate))))

(defun x-hugh-claude-server-window (buffer)
  "Display BUFFER for emacsclient, preferring the Claude Code window.
Intended as the value of `server-window'.  Falls back to server.el's
own placement when BUFFER is not a temp-file edit, or when no Claude
window is on the frame."
  (let* ((file (buffer-file-name buffer))
         (win (and x-hugh-claude-editor-in-claude-window
                   file
                   (file-in-directory-p file temporary-file-directory)
                   (x-hugh-claude--window))))
    (cond
     (win
      ;; Soft dedication: `set-window-buffer' is allowed and clears the
      ;; flag, where t would signal.  Restored by the hook above.
      (when (window-dedicated-p win)
        (setq x-hugh-claude--redirected-window win)
        (add-hook 'window-buffer-change-functions #'x-hugh-claude--rededicate)
        (set-window-dedicated-p win 'x-hugh-claude))
      (set-window-buffer win buffer)
      (select-window win))
     ((or (window-dedicated-p) (window-minibuffer-p))
      (pop-to-buffer buffer))
     (t (switch-to-buffer buffer)))))

(with-eval-after-load 'server
  (setq server-window #'x-hugh-claude-server-window))

(defun x-hugh-claude--command-via-sh (command-string)
  "Return COMMAND-STRING as a (program . args) cons running via sh -c.
Replacement for `claude-code-ide--parse-command-string', whose
`split-string-shell-command' parse mangles multi-line arguments:
setting any `claude-code-ide-system-prompt' makes the package join it
to its built-in prompt with newlines, after which the ghostel/eat
backends misparse the tail of the prompt as the program name
\(\"Searching for program: ...side window.\").  The command string is
already shell-quoted for sh -c -- the vterm backend uses it that way
-- so just hand it to a real shell.  FIXME: report upstream."
  (cons "/bin/sh" (list "-c" command-string)))

(use-package claude-code-ide
  :vc (:url "https://github.com/manzaltu/claude-code-ide.el" :rev :newest)
  :bind (("C-c c" . claude-code-ide-menu)
         ("C-c N" . x-hugh-claude-notes))
  :config
  (advice-add 'claude-code-ide--parse-command-string :override
              #'x-hugh-claude--command-via-sh)
  :custom
  (claude-code-ide-terminal-backend 'ghostel)
  (claude-code-ide-cli-path
   (expand-file-name "bin/claude-nono" user-emacs-directory))
  ;; nono is the security boundary (same judgement call as
  ;; yolo/podman): kernel-enforced FS limits, so skip the prompt
  ;; nagging.  The egress allowlist that this leans on is now in
  ;; place -- see bin/claude-nono.
  (claude-code-ide-cli-extra-flags "--dangerously-skip-permissions")
  ;; That allowlist only binds the *sandboxed* process.  executeCode
  ;; evaluates elisp in this Emacs, outside the cage, which is an
  ;; unfiltered network path straight past it -- so the two changes
  ;; only make sense together.  openFile, openDiff and getDiagnostics,
  ;; the tools actually wanted here, are unaffected.
  ;;
  ;; This has to be set before claude-code-ide-mcp-handlers.el loads:
  ;; that file builds the tool list once, at load time, with a plain
  ;; setq (claude-code-ide-mcp-handlers.el:663) -- it is not rebuilt
  ;; per tools/list request.  :custom runs at startup and the package
  ;; is deferred, so the ordering holds; check it after a restart with
  ;;   M-: (assoc "executeCode" claude-code-ide-mcp-tools)  => nil
  (claude-code-ide-enable-execute-code nil)
  (claude-code-ide-system-prompt
   "You are running inside Emacs with IDE integration.  To show the \
user a file or location, use the IDE's openFile tool, never \
emacsclient (you cannot see whether emacsclient worked).  While \
working on nontrivial tasks, keep running notes -- current plan, \
discoveries, explanations -- in NOTES-claude.md at the project root, \
updating as you go; the user watches that file live in a side \
window."))

(provide 'x-hugh-claude)

;;; x-hugh-claude.el ends here
