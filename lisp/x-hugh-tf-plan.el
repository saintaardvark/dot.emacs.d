;;; -*- lexical-binding: t -*-
;;; x-hugh-tf-plan --- Run `make plan' and read the output in Emacs

;;; Commentary:
;; `ENV=stage make plan' in a terraform-wyvern-pipeline-infra checkout
;; emits a couple of thousand lines, ninety per cent of which is
;; `Refreshing state...' noise.  This runs the plan for a chosen
;; environment and hands the output to a viewer.
;;
;; Two things about that repository shape the code here:
;;
;; - The Makefile has a pattern rule, `tf-%', so every Terraform
;;   subcommand is already reachable, and TF_CLI_ARGS_plan reaches
;;   Terraform through util/tf_wrapper.sh.  So we can ask for a saved
;;   plan file and read it back as JSON later.
;;
;; - The wrapper runs Terraform under aws-vault and summon, either of
;;   which may prompt for a passphrase or an MFA token.  The runner is
;;   therefore a comint buffer rather than a plain process: there has to
;;   be somewhere to type the answer.
;;
;; Note that the saved plan file contains resource values in the clear,
;; secrets included.  It is written to a mode-0700 temporary directory,
;; never into the repository -- the repository's .gitignore would not
;; catch it.

;;; Code:

(require 'ansi-color)
(require 'comint)
(require 'compile)
(require 'imenu)
(require 'outline)
(require 'seq)
(require 'subr-x)

(defgroup x-hugh-tf-plan nil
  "Running Terraform plans and reading the output."
  :group 'tools
  :prefix "x-hugh-tf-plan-")

(defcustom x-hugh-tf-plan-default-environment "stage"
  "Environment offered as the default.
Mirrors `ENV ?= stage' in the Makefile."
  :type 'string)

(defcustom x-hugh-tf-plan-environments-directory "terraform/environments"
  "Directory, relative to the repository root, holding one directory per
environment.  The Makefile assumes ENV names such a directory."
  :type 'string)

(defcustom x-hugh-tf-plan-root-markers '("Makefile" "util/tf_wrapper.sh")
  "Files that must all exist for a directory to count as the repository root."
  :type '(repeat string))

(defcustom x-hugh-tf-plan-extra-plan-args
  '("-compact-warnings" "-input=false" "-no-color")
  "Extra arguments passed to `terraform plan' via TF_CLI_ARGS_plan.

`-compact-warnings' collapses the boxed deprecation warnings to one line
each.  `-input=false' makes Terraform fail rather than block on a prompt;
it does not affect aws-vault or summon, which prompt outside Terraform.
`-no-color' is here because comint gives the process a pty, so Terraform
would otherwise emit escape sequences; the viewer does its own colouring.

Only the plan-specific variable is set, never the bare TF_CLI_ARGS: the
`plan' target is `tf-init tf-plan', and plan-only arguments such as
`-out' would break the init step."
  :type '(repeat string))

(defcustom x-hugh-tf-plan-keep-plan-file nil
  "When non-nil, keep the saved plan file after reading it.
The file contains secrets in the clear, so the default is to delete it."
  :type 'boolean)

;;; Locating the repository and its environments

(defun x-hugh-tf-plan-root (&optional directory)
  "Return the wrapper repository root at or above DIRECTORY, or nil.
DIRECTORY defaults to `default-directory'."
  (locate-dominating-file
   (or directory default-directory)
   (lambda (dir)
     (seq-every-p (lambda (marker)
                    (file-exists-p (expand-file-name marker dir)))
                  x-hugh-tf-plan-root-markers))))

(defun x-hugh-tf-plan--root-or-error (&optional directory)
  "Return the repository root at or above DIRECTORY, or signal an error."
  (let ((root (x-hugh-tf-plan-root directory)))
    (unless root
      (user-error "No Terraform wrapper repository at or above %s (want %s)"
                  (abbreviate-file-name (or directory default-directory))
                  (string-join x-hugh-tf-plan-root-markers " and ")))
    (expand-file-name root)))

(defun x-hugh-tf-plan-environments (root)
  "Return the environment names available under ROOT, sorted."
  (let ((dir (expand-file-name x-hugh-tf-plan-environments-directory root)))
    (when (file-directory-p dir)
      (sort (seq-filter (lambda (name)
                          (file-directory-p (expand-file-name name dir)))
                        (directory-files dir nil directory-files-no-dot-files-regexp))
            #'string<))))

(defun x-hugh-tf-plan-read-environment (root)
  "Read an environment name, offering those found under ROOT."
  (let* ((environments (x-hugh-tf-plan-environments root))
         (default (if (member x-hugh-tf-plan-default-environment environments)
                      x-hugh-tf-plan-default-environment
                    (car environments))))
    (completing-read (format-prompt "Environment" default)
                     environments nil nil nil nil default)))

;;; Saved plan files

(defvar x-hugh-tf-plan--directory nil
  "Mode-0700 directory holding this session's saved plan files.")

(defun x-hugh-tf-plan--directory ()
  "Return the directory for saved plan files, creating it if need be."
  (unless (and x-hugh-tf-plan--directory
               (file-directory-p x-hugh-tf-plan--directory))
    (setq x-hugh-tf-plan--directory (make-temp-file "x-hugh-tf-plan-" t)))
  x-hugh-tf-plan--directory)

(defun x-hugh-tf-plan--plan-file (environment)
  "Return the path of the saved plan file for ENVIRONMENT."
  (let ((file (expand-file-name (format "%s.tfplan" environment)
                                (x-hugh-tf-plan--directory))))
    ;; Terraform splits TF_CLI_ARGS_plan on whitespace itself, so a path
    ;; with a space in it cannot be passed through no matter how we quote.
    (when (string-match-p "[[:space:]]" file)
      (error "Refusing to use a plan file path containing whitespace: %s" file))
    file))

(defun x-hugh-tf-plan--discard-plan-file (file)
  "Delete FILE unless `x-hugh-tf-plan-keep-plan-file' says otherwise."
  (when (and file (file-exists-p file))
    (if x-hugh-tf-plan-keep-plan-file
        (message "Keeping plan file %s (contains secrets)" file)
      (delete-file file))))

(defun x-hugh-tf-plan--clean-up ()
  "Remove the saved plan directory.  Runs from `kill-emacs-hook'."
  (when (and x-hugh-tf-plan--directory
             (file-directory-p x-hugh-tf-plan--directory))
    (delete-directory x-hugh-tf-plan--directory t)))

(add-hook 'kill-emacs-hook #'x-hugh-tf-plan--clean-up)

;;; Running the plan

(defvar-local x-hugh-tf-plan--environment nil
  "Environment this buffer's plan was run for.")

(defvar-local x-hugh-tf-plan--root nil
  "Repository root this buffer's plan was run in.")

(defvar-local x-hugh-tf-plan--plan-file nil
  "Saved plan file this buffer's run wrote, if any.")

(defun x-hugh-tf-plan--run-buffer-name (environment)
  "Name of the buffer the plan for ENVIRONMENT runs in."
  (format "*tf-plan run: %s*" environment))

(defun x-hugh-tf-plan--command (environment plan-file &optional skip-init)
  "Return the shell command running a plan for ENVIRONMENT into PLAN-FILE.
With SKIP-INIT, use the `tf-plan' target rather than `plan', skipping the
init step."
  (format "ENV=%s TF_CLI_ARGS_plan=%s make %s"
          (shell-quote-argument environment)
          (shell-quote-argument
           (string-join (cons (concat "-out=" plan-file)
                              x-hugh-tf-plan-extra-plan-args)
                        " "))
          (if skip-init "tf-plan" "plan")))

;;;###autoload
(defun x-hugh-make-tf-plan (environment &optional skip-init)
  "Run `make plan' for ENVIRONMENT and show the result.

Runs in a comint buffer so that aws-vault and summon prompts can be
answered.  The plan is also saved to a file, to be read back as JSON.

With a prefix argument, SKIP-INIT, run the `tf-plan' target instead of
`plan', skipping `terraform init'.  Faster when the environment is
already initialised."
  (interactive
   (list (x-hugh-tf-plan-read-environment (x-hugh-tf-plan--root-or-error))
         current-prefix-arg))
  (let* ((root (x-hugh-tf-plan--root-or-error))
         (plan-file (x-hugh-tf-plan--plan-file environment))
         (default-directory root)
         (command (x-hugh-tf-plan--command environment plan-file skip-init))
         (compilation-buffer-name-function
          (lambda (&rest _)
            (x-hugh-tf-plan--run-buffer-name environment))))
    (with-current-buffer (compilation-start command t)
      (setq x-hugh-tf-plan--environment environment
            x-hugh-tf-plan--root root
            x-hugh-tf-plan--plan-file plan-file)
      (add-hook 'compilation-finish-functions
                #'x-hugh-tf-plan--finished nil t)
      (current-buffer))))

(defun x-hugh-tf-plan--finished (buffer status)
  "Handle the plan in BUFFER having finished with STATUS."
  (with-current-buffer buffer
    (let ((environment x-hugh-tf-plan--environment)
          (text (buffer-substring-no-properties (point-min) (point-max))))
      (unless (string-prefix-p "finished" status)
        (message "Plan for %s did not finish cleanly: %s"
                 environment (string-trim status)))
      (display-buffer (x-hugh-tf-plan--show-text text environment)))))

;;; Reading the saved plan back as JSON
;;
;; `terraform show -json' on a saved plan gives before and after values
;; for every attribute, which the text output only renders.  The wrapper
;; prints its own chatter and the kubeconfig update ahead of Terraform's
;; output, so stdout is not pure JSON and we have to find where the
;; document starts.
;;
;; The fetch is asynchronous.  aws-vault has usually cached its session
;; by this point, but if it has not, a synchronous call would hang Emacs
;; with nowhere to type the answer.

(defcustom x-hugh-tf-plan-show-timeout 180
  "Seconds to wait for `make tf-show' before killing it."
  :type 'integer)

(defcustom x-hugh-tf-plan-value-width 78
  "Column beyond which a JSON value is rendered over several lines."
  :type 'integer)

(defun x-hugh-tf-plan--show-command (environment plan-file)
  "Return the shell command dumping PLAN-FILE for ENVIRONMENT as JSON."
  (format "ENV=%s TF_CLI_ARGS_show=%s make tf-show"
          (shell-quote-argument environment)
          (shell-quote-argument (concat "-json " plan-file))))

(defun x-hugh-tf-plan--buffer-tail (buffer &optional lines)
  "Return the last LINES lines of BUFFER as a string.  LINES defaults to 3."
  (if (not (buffer-live-p buffer))
      ""
    (with-current-buffer buffer
      (let ((end (point-max)))
        (save-excursion
          (goto-char end)
          (forward-line (- (or lines 3)))
          (string-trim (buffer-substring-no-properties (point) end)))))))

(defun x-hugh-tf-plan--parse-buffer (buffer)
  "Parse the Terraform plan JSON in BUFFER and return it as a plist."
  (with-current-buffer buffer
    (goto-char (point-min))
    (unless (re-search-forward "{\"format_version\"" nil t)
      (error "No plan JSON in the output of make tf-show: %s"
             (x-hugh-tf-plan--buffer-tail buffer)))
    (goto-char (match-beginning 0))
    (x-hugh-tf-plan--plan
     (json-parse-buffer :object-type 'alist
                        :array-type 'array
                        :null-object :null
                        :false-object :false))))

;;;; Turning the JSON into something to render

(defun x-hugh-tf-plan--action (actions)
  "Return a symbol for the JSON ACTIONS array."
  (let ((actions (append actions nil)))
    (cond
     ((equal actions '("no-op")) 'no-op)
     ((equal actions '("create")) 'create)
     ((equal actions '("read")) 'read)
     ((equal actions '("update")) 'update)
     ((equal actions '("delete")) 'delete)
     ;; ("delete" "create") and ("create" "delete") are both replacement;
     ;; the order says which happens first.
     ((member "delete" actions) 'replace)
     (t 'unknown))))

(defun x-hugh-tf-plan--flagged-p (flags key)
  "Return non-nil if KEY is flagged in FLAGS.
FLAGS is one of Terraform's parallel structures such as `after_unknown'
or `after_sensitive', in which a leaf is t and a partially flagged
container is a nested object.  A partially flagged container counts as
flagged: for sensitivity that errs towards withholding, and for
unknownness it matches Terraform's own habit of printing the whole
attribute as unknown."
  (cond
   ((eq flags t) t)
   ((consp flags) (let ((cell (assq key flags)))
                    (and cell (not (memq (cdr cell) '(nil :false))))))
   (t nil)))

(defun x-hugh-tf-plan--value (object key sensitive unknown)
  "Return the value of KEY in OBJECT, or a marker.
Markers are `:unknown' if UNKNOWN flags KEY, `:sensitive' if SENSITIVE
does, and `:absent' if OBJECT does not have KEY at all."
  (cond
   ((x-hugh-tf-plan--flagged-p unknown key) :unknown)
   ((x-hugh-tf-plan--flagged-p sensitive key) :sensitive)
   ((not (consp object)) :absent)
   (t (let ((cell (assq key object)))
        (if cell (cdr cell) :absent)))))

(defun x-hugh-tf-plan--normalize (value)
  "Return VALUE with every object's keys sorted, for comparison.
Terraform does not promise a key order, so comparing before and after
with `equal' needs this or it reports spurious changes."
  (cond
   ((vectorp value)
    (apply #'vector (mapcar #'x-hugh-tf-plan--normalize (append value nil))))
   ((consp value)
    (sort (mapcar (lambda (cell)
                    (cons (car cell) (x-hugh-tf-plan--normalize (cdr cell))))
                  value)
          (lambda (a b) (string< (symbol-name (car a)) (symbol-name (car b))))))
   (t value)))

(defun x-hugh-tf-plan--attribute-keys (before after unknown)
  "Return the sorted union of the keys of BEFORE, AFTER and UNKNOWN."
  (let ((keys '()))
    (dolist (cell (append (and (consp before) before)
                          (and (consp after) after)))
      (unless (memq (car cell) keys)
        (push (car cell) keys)))
    (when (consp unknown)
      (dolist (cell unknown)
        (unless (or (memq (cdr cell) '(nil :false))
                    (memq (car cell) keys))
          (push (car cell) keys))))
    (sort keys (lambda (a b) (string< (symbol-name a) (symbol-name b))))))

(defun x-hugh-tf-plan--attributes (action change)
  "Return the attribute changes of CHANGE, given its ACTION.
Each is a plist with `:glyph', `:key', `:before', `:after' and
`:changed'."
  (let* ((before (alist-get 'before change))
         (after (alist-get 'after change))
         (unknown (alist-get 'after_unknown change))
         (before-sensitive (alist-get 'before_sensitive change))
         (after-sensitive (alist-get 'after_sensitive change))
         (attributes '()))
    (dolist (key (x-hugh-tf-plan--attribute-keys before after unknown))
      (let* ((old (x-hugh-tf-plan--value before key before-sensitive nil))
             (new (x-hugh-tf-plan--value after key after-sensitive unknown))
             (same (equal (x-hugh-tf-plan--normalize old)
                          (x-hugh-tf-plan--normalize new))))
        (push (pcase action
                ('create (list :glyph "+" :key key :after new :changed t))
                ('read (list :glyph "+" :key key :after new :changed t))
                ('delete (list :glyph "-" :key key :before old :changed t))
                (_ (list :glyph (if same " " "~") :key key
                         :before old :after new :changed (not same))))
              attributes)))
    (nreverse attributes)))

(defun x-hugh-tf-plan--resource (entry)
  "Return a plist describing the resource change ENTRY."
  (let* ((change (alist-get 'change entry))
         (action (x-hugh-tf-plan--action (alist-get 'actions change))))
    (list :address (alist-get 'address entry)
          :module (or (alist-get 'module_address entry) "")
          :type (alist-get 'type entry)
          :name (alist-get 'name entry)
          :mode (alist-get 'mode entry)
          :action action
          :reason (alist-get 'action_reason entry)
          :replace-paths (alist-get 'replace_paths change)
          :attributes (x-hugh-tf-plan--attributes action change))))

(defun x-hugh-tf-plan--output (name change)
  "Return a plist describing the change to output NAME."
  (let ((action (x-hugh-tf-plan--action (alist-get 'actions change))))
    (list :name (symbol-name name)
          :action action
          :attributes
          (list (list :glyph (pcase action ('create "+") ('delete "-") (_ "~"))
                      :key name
                      :before (if (x-hugh-tf-plan--flagged-p
                                   (alist-get 'before_sensitive change) name)
                                  :sensitive
                                (alist-get 'before change))
                      :after (cond
                              ((eq (alist-get 'after_unknown change) t) :unknown)
                              ((eq (alist-get 'after_sensitive change) t) :sensitive)
                              (t (alist-get 'after change)))
                      :changed t)))))

(defun x-hugh-tf-plan--plan (json)
  "Return a plist describing the parsed JSON plan."
  (let* ((resources (mapcar #'x-hugh-tf-plan--resource
                            (append (alist-get 'resource_changes json) nil)))
         (drift (mapcar #'x-hugh-tf-plan--resource
                        (append (alist-get 'resource_drift json) nil)))
         (outputs (let ((changes (alist-get 'output_changes json))
                        (result '()))
                    (dolist (cell (and (consp changes) changes))
                      (let ((output (x-hugh-tf-plan--output (car cell) (cdr cell))))
                        (unless (eq (plist-get output :action) 'no-op)
                          (push output result))))
                    (nreverse result)))
         (changes (seq-remove (lambda (resource)
                                (memq (plist-get resource :action) '(no-op)))
                              resources)))
    (list :terraform-version (alist-get 'terraform_version json)
          :errored (eq (alist-get 'errored json) t)
          :changes changes
          :unchanged (- (length resources) (length changes))
          :drift (seq-remove (lambda (resource)
                               (eq (plist-get resource :action) 'no-op))
                             drift)
          :outputs outputs)))

(defun x-hugh-tf-plan-summary (plan)
  "Return an alist counting the actions in PLAN."
  (let ((counts '((create . 0) (update . 0) (replace . 0)
                  (delete . 0) (read . 0))))
    (dolist (resource (plist-get plan :changes))
      (let ((cell (assq (plist-get resource :action) counts)))
        (when cell (setcdr cell (1+ (cdr cell))))))
    counts))

;;;; Fetching it

(defun x-hugh-tf-plan--fetch-json (environment root plan-file callback)
  "Dump PLAN-FILE as JSON and call CALLBACK with the parsed plan.
Runs `make tf-show' for ENVIRONMENT in ROOT.  CALLBACK is called with
nil if the plan could not be read."
  (let* ((default-directory root)
         (stdout (generate-new-buffer " *tf-plan show*" t))
         (stderr (generate-new-buffer " *tf-plan show errors*" t))
         (command (x-hugh-tf-plan--show-command environment plan-file))
         (timer nil)
         (process nil))
    (setq process
          (make-process
           :name (format "tf-plan-show-%s" environment)
           :buffer stdout
           :stderr stderr
           :noquery t
           :command (list shell-file-name shell-command-switch command)
           :sentinel
           (lambda (proc _event)
             (when (memq (process-status proc) '(exit signal))
               (when timer (cancel-timer timer))
               (let* ((status (process-exit-status proc))
                      (plan (and (zerop status)
                                 (condition-case err
                                     (x-hugh-tf-plan--parse-buffer stdout)
                                   (error
                                    (message "Could not read the plan JSON: %s"
                                             (error-message-string err))
                                    nil))))
                      (errors (x-hugh-tf-plan--buffer-tail stderr)))
                 (ignore-errors (kill-buffer stdout))
                 (ignore-errors (kill-buffer stderr))
                 (unless (zerop status)
                   (message "make tf-show for %s failed (exit %s): %s"
                            environment status errors))
                 (funcall callback plan))))))
    (setq timer
          (run-at-time
           x-hugh-tf-plan-show-timeout nil
           (lambda ()
             (when (process-live-p process)
               (message "make tf-show for %s timed out after %ss; killing it"
                        environment x-hugh-tf-plan-show-timeout)
               (kill-process process)))))
    process))

;;; Faces

(defface x-hugh-tf-plan-create-face
  '((t :inherit diff-added))
  "Face for resources and attributes being created.")

(defface x-hugh-tf-plan-delete-face
  '((t :inherit diff-removed))
  "Face for resources and attributes being destroyed.")

(defface x-hugh-tf-plan-update-face
  '((t :inherit diff-changed))
  "Face for resources and attributes being changed in place.")

(defface x-hugh-tf-plan-replace-face
  '((t :inherit diff-removed :weight bold))
  "Face for resources being replaced.
Replacement destroys, so it is worth making louder than an update.")

(defface x-hugh-tf-plan-read-face
  '((t :inherit font-lock-constant-face))
  "Face for data sources read during apply.")

(defface x-hugh-tf-plan-address-face
  '((t :inherit font-lock-function-name-face))
  "Face for a resource address.")

(defface x-hugh-tf-plan-heading-face
  '((t :inherit font-lock-keyword-face :weight bold))
  "Face for the headings Terraform prints between sections.")

(defface x-hugh-tf-plan-noise-face
  '((t :inherit shadow))
  "Face for init and refresh output.")

(defface x-hugh-tf-plan-unknown-face
  '((t :inherit shadow :slant italic))
  "Face for values that are unknown or withheld.")

;;; Font lock

(defun x-hugh-tf-plan--header-keyword (verbs face)
  "Return a font-lock keyword matching `# ADDRESS VERB' lines.
VERBS is a list of literal strings; the address is fontified as an
address and the verb and its remainder with FACE."
  (list (rx-to-string
         `(seq bol (* space) "# " (group (+ (not (any " ")))) " "
               (group (or ,@verbs) (* nonl))))
        '(1 'x-hugh-tf-plan-address-face)
        (list 2 (list 'quote face))))

(defconst x-hugh-tf-plan-text-font-lock-keywords
  (list
   ;; Section headings.
   (cons (rx bol (or "Terraform will perform the following actions:"
                     "Note: Objects have changed outside of Terraform"
                     "Changes to Outputs:"
                     "Terraform planned the following actions,"
                     "Plan:"
                     "Saved the plan to:")
             (* nonl))
         ''x-hugh-tf-plan-heading-face)
   (cons (rx bol "No changes." (* nonl)) ''success)

   ;; Resource headers, faced by what is going to happen.
   (x-hugh-tf-plan--header-keyword
    '("will be created") 'x-hugh-tf-plan-create-face)
   (x-hugh-tf-plan--header-keyword
    '("will be destroyed" "has been deleted") 'x-hugh-tf-plan-delete-face)
   (x-hugh-tf-plan--header-keyword
    '("will be updated in-place" "has changed") 'x-hugh-tf-plan-update-face)
   (x-hugh-tf-plan--header-keyword
    '("must be replaced" "will be replaced") 'x-hugh-tf-plan-replace-face)
   (x-hugh-tf-plan--header-keyword
    '("will be read during apply") 'x-hugh-tf-plan-read-face)

   ;; Attribute changes.  Indentation is required, because the init
   ;; output has `- ' lines at column zero that are not diffs, and the
   ;; text after the glyph has to look like an assignment or a block
   ;; opener, because embedded YAML in a heredoc has `- ' list items
   ;; that are not diffs either.
   '("^  +\\(-/\\+\\|\\+/-\\)\
 \\([A-Za-z_\"][A-Za-z0-9_\"./-]* *\\(?:=\\|{\\|\"\\).*\\)$"
     (1 'x-hugh-tf-plan-replace-face) (2 'x-hugh-tf-plan-replace-face))
   '("^  +\\(\\+\\) \\([A-Za-z_\"][A-Za-z0-9_\"./-]* *\\(?:=\\|{\\|\"\\).*\\)$"
     (1 'x-hugh-tf-plan-create-face) (2 'x-hugh-tf-plan-create-face))
   '("^  +\\(-\\) \\([A-Za-z_\"][A-Za-z0-9_\"./-]* *\\(?:=\\|{\\|\"\\).*\\)$"
     (1 'x-hugh-tf-plan-delete-face) (2 'x-hugh-tf-plan-delete-face))
   '("^  +\\(~\\) \\([A-Za-z_\"][A-Za-z0-9_\"./-]* *\\(?:=\\|{\\|\"\\).*\\)$"
     (1 'x-hugh-tf-plan-update-face) (2 'x-hugh-tf-plan-update-face))

   ;; Warnings and errors, and the box they are drawn in.
   '("^│ \\(Warning\\):\\(.*\\)$"
     (1 'warning) (2 'x-hugh-tf-plan-heading-face))
   '("^│ \\(Error\\):\\(.*\\)$"
     (1 'error) (2 'x-hugh-tf-plan-heading-face))
   (cons (rx bol (any "│╷╵─")) ''x-hugh-tf-plan-noise-face)

   ;; Init and refresh output.
   (cons (rx bol (or "util/tf_wrapper.sh" "Setting up kubectl context"
                     "Skipping setup of kubectl context" "Added new context"
                     "Initializing" "Terraform has been successfully initialized"
                     "Terraform used the selected providers"
                     "Acquiring state lock" "Releasing state lock"
                     "- Reusing previous version" "- Using previously-installed"
                     "- Finding " "- Installing " "- Downloading "
                     "- terraform.io/builtin")
             (* nonl))
         ''x-hugh-tf-plan-noise-face)
   (cons (rx (+ nonl) ": "
             (or "Refreshing state..." "Reading..." "Read complete after"
                 "Still reading...")
             (* nonl))
         ''x-hugh-tf-plan-noise-face)

   ;; Details worth picking out of an already-fontified line, so these
   ;; override.
   '("(\\(?:known after apply\\|sensitive value\\|sensitive\\))"
     (0 'x-hugh-tf-plan-unknown-face t))
   '("^ *# (\\(?:[0-9]+\\|.*\\) unchanged [a-z]+ hidden)"
     (0 'x-hugh-tf-plan-unknown-face t))
   '(" \\(->\\) " (1 'x-hugh-tf-plan-heading-face t))
   '("^Plan: \\([0-9]+\\) to add, \\([0-9]+\\) to change, \\([0-9]+\\) to destroy"
     (1 'x-hugh-tf-plan-create-face t)
     (2 'x-hugh-tf-plan-update-face t)
     (3 'x-hugh-tf-plan-delete-face t)))
  "Font lock keywords for `x-hugh-tf-plan-text-mode'.")

;;; Folding the init and refresh output

(defcustom x-hugh-tf-plan-noise-fold-threshold 3
  "Shortest run of init or refresh lines that gets folded away."
  :type 'integer)

(defconst x-hugh-tf-plan-noise-line-regexp
  (concat
   "\\(?:"
   (string-join
    '("^util/tf_wrapper\\.sh "
      "^Setting up kubectl context"
      "^Skipping setup of kubectl context"
      "^Added new context "
      "^Initializing "
      "^Terraform has been successfully initialized"
      "^You may now begin working with Terraform"
      "^any changes that are required"
      "^should now work\\."
      "^If you ever set or change modules"
      "^rerun this command to reinitialize"
      "^commands will detect it and remind"
      "^Acquiring state lock"
      "^Releasing state lock"
      "^- \\(?:Reusing previous version\\|Using previously-installed\\)"
      "^- \\(?:Finding \\|Installing \\|Downloading \\)"
      "^- terraform\\.io/builtin"
      ": Refreshing state\\.\\.\\."
      ": Reading\\.\\.\\.$"
      ": Read complete after "
      ": Still reading\\.\\.\\. ")
    "\\|")
   "\\)")
  "Matches a line of Terraform init or state-refresh output.")

(defun x-hugh-tf-plan--noise-line-p ()
  "Return non-nil if the current line is init or refresh output."
  (save-excursion
    (beginning-of-line)
    (looking-at-p x-hugh-tf-plan-noise-line-regexp)))

(defun x-hugh-tf-plan--blank-line-p ()
  "Return non-nil if the current line is blank."
  (save-excursion
    (beginning-of-line)
    (looking-at-p "[[:space:]]*$")))

(defun x-hugh-tf-plan--noise-overlays ()
  "Return the overlays currently hiding init and refresh output."
  (seq-filter (lambda (overlay) (overlay-get overlay 'x-hugh-tf-plan-noise))
              (overlays-in (point-min) (point-max))))

(defun x-hugh-tf-plan-fold-noise ()
  "Collapse each run of init and refresh output to a single line.
Return the number of runs folded."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (let ((runs 0))
      (while (not (eobp))
        (if (not (x-hugh-tf-plan--noise-line-p))
            (forward-line 1)
          (let ((start (line-beginning-position))
                (end nil)
                (lines 0))
            ;; A run continues over blank lines, so long as more noise
            ;; follows; the overlay itself stops at the last noise line.
            (while (and (not (eobp))
                        (or (x-hugh-tf-plan--noise-line-p)
                            (and end (x-hugh-tf-plan--blank-line-p))))
              (unless (x-hugh-tf-plan--blank-line-p)
                (setq lines (1+ lines)
                      end (line-end-position)))
              (forward-line 1))
            (when (>= lines x-hugh-tf-plan-noise-fold-threshold)
              (let ((overlay (make-overlay start end)))
                (overlay-put overlay 'x-hugh-tf-plan-noise t)
                (overlay-put overlay 'evaporate t)
                (overlay-put overlay 'help-echo
                             "Init and refresh output; N to show")
                (overlay-put
                 overlay 'display
                 (propertize
                  (format "[%d lines of init and refresh output]" lines)
                  'face 'x-hugh-tf-plan-noise-face)))
              (setq runs (1+ runs))))))
      runs)))

(defun x-hugh-tf-plan-toggle-noise ()
  "Show or hide the init and refresh output."
  (interactive)
  (let ((hidden (x-hugh-tf-plan--noise-overlays)))
    (if hidden
        (progn (mapc #'delete-overlay hidden)
               (message "Showing init and refresh output"))
      (message "Folded %d run(s) of init and refresh output"
               (x-hugh-tf-plan-fold-noise)))))

;;; The text viewer

(defun x-hugh-tf-plan--outline-level ()
  "Return the outline level of the heading at point.
Terraform indents by two spaces per level, so the indentation is the
level."
  (max 1 (1+ (/ (current-indentation) 2))))

(defun x-hugh-tf-plan-fold-bodies ()
  "Fold the buffer down to its headings, if it has any."
  (interactive)
  (when (save-excursion
          (goto-char (point-min))
          (re-search-forward (concat "^\\(?:" outline-regexp "\\)") nil t))
    (outline-hide-body)))

(defun x-hugh-tf-plan-revert ()
  "Run the plan again for this buffer's environment."
  (interactive)
  (let ((environment (or x-hugh-tf-plan--environment
                         (user-error "No environment recorded for this buffer"))))
    (x-hugh-make-tf-plan environment)))

(defvar-keymap x-hugh-tf-plan-text-mode-map
  :doc "Keymap for `x-hugh-tf-plan-text-mode'."
  "TAB" #'outline-cycle
  "<backtab>" #'outline-cycle-buffer
  "n" #'outline-next-visible-heading
  "p" #'outline-previous-visible-heading
  "a" #'outline-show-all
  "z" #'x-hugh-tf-plan-fold-bodies
  "N" #'x-hugh-tf-plan-toggle-noise
  "g" #'x-hugh-tf-plan-revert)

(define-derived-mode x-hugh-tf-plan-text-mode special-mode "TF-Plan-Text"
  "Major mode for reading the text output of a Terraform plan."
  (setq-local outline-regexp
              (rx (or (seq (* space) "# " (+ (not (any " "))) " "
                           (or "will be" "must be" "has been" "has changed"))
                      (seq (>= 6 space) (or "-/+" "+/-" "+" "-" "~") " "
                           (+ (not (any " "))) (* nonl) (any "{[("))
                      "Terraform will perform the following actions:"
                      "Terraform planned the following actions,"
                      "Note: Objects have changed outside of Terraform"
                      "Changes to Outputs:"
                      "Plan:"
                      (seq "│ " (or "Warning" "Error") ":"))))
  (setq-local outline-level #'x-hugh-tf-plan--outline-level)
  (setq-local outline-minor-mode-cycle t)
  (setq-local font-lock-defaults
              '(x-hugh-tf-plan-text-font-lock-keywords t))
  (setq-local imenu-generic-expression
              '((nil "^[[:space:]]*# \\([^ ]+\\) \\(?:will be\\|must be\\|has \\)" 1)))
  (setq-local header-line-format
              "TAB fold  n/p heading  a show all  z fold all  \
N init+refresh output  g re-run  q quit")
  (outline-minor-mode 1))

(defun x-hugh-tf-plan-text-buffer-name (environment)
  "Name of the text viewer buffer for ENVIRONMENT."
  (format "*tf-plan text: %s*" environment))

(defun x-hugh-tf-plan--show-text (text environment)
  "Show TEXT as the plan output for ENVIRONMENT.  Return the buffer."
  (let ((buffer (get-buffer-create
                 (x-hugh-tf-plan-text-buffer-name environment))))
    (with-current-buffer buffer
      (let ((inhibit-read-only t))
        (erase-buffer)
        (insert text)
        ;; comint gives the process a pty, so Terraform may colour its
        ;; output despite -no-color; we do our own colouring.
        (ansi-color-filter-region (point-min) (point-max)))
      (x-hugh-tf-plan-text-mode)
      (setq x-hugh-tf-plan--environment environment)
      (goto-char (point-min))
      (font-lock-ensure)
      (x-hugh-tf-plan-fold-noise)
      (x-hugh-tf-plan-fold-bodies))
    buffer))

;;; Reading plan output you already have

(defun x-hugh-tf-plan--environment-in-text (text)
  "Return the environment named by tf_wrapper.sh chatter in TEXT, or nil.
The wrapper is invoked with the environment as its first argument, and
make echoes the command line."
  (when (string-match "util/tf_wrapper\\.sh \\([^ \n]+\\)" text)
    (match-string 1 text)))

;;;###autoload
(defun x-hugh-tf-plan-from-region (start end)
  "Show the plan output between START and END in the text viewer."
  (interactive "r")
  (let ((text (buffer-substring-no-properties start end)))
    (pop-to-buffer
     (x-hugh-tf-plan--show-text
      text (or (x-hugh-tf-plan--environment-in-text text) "region")))))

;;;###autoload
(defun x-hugh-tf-plan-from-last-output ()
  "Show the output of the last command in this shell in the text viewer.
Works in comint buffers -- shell, eshell is not comint -- where the
output of the last command is everything after the last input."
  (interactive)
  (unless (derived-mode-p 'comint-mode)
    (user-error "Not a comint buffer; select the output and use %s instead"
                "x-hugh-tf-plan-from-region"))
  (let ((start (or comint-last-input-end
                   (user-error "No command has been run in this buffer"))))
    (x-hugh-tf-plan-from-region start (point-max))))

;;;###autoload
(defun x-hugh-tf-plan-from-file (file)
  "Show the plan output saved in FILE in the text viewer."
  (interactive "fPlan output file: ")
  (let ((text (with-temp-buffer
                (insert-file-contents file)
                (buffer-string))))
    (pop-to-buffer
     (x-hugh-tf-plan--show-text
      text (or (x-hugh-tf-plan--environment-in-text text)
               (file-name-base file))))))

(provide 'x-hugh-tf-plan)
;;; x-hugh-tf-plan.el ends here
