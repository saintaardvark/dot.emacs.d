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
(require 'json)
(require 'magit-section)
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
  "Handle the plan in BUFFER having finished with STATUS.
On success the saved plan is read back as JSON and shown as a tree of
changes; the text view is built either way, and is what you get if the
JSON cannot be had."
  (with-current-buffer buffer
    (let* ((environment x-hugh-tf-plan--environment)
           (root x-hugh-tf-plan--root)
           (plan-file x-hugh-tf-plan--plan-file)
           (text (buffer-substring-no-properties (point-min) (point-max)))
           (text-buffer (x-hugh-tf-plan--show-text text environment)))
      (if (and (string-prefix-p "finished" status)
               plan-file
               (file-exists-p plan-file))
          (progn
            (message "Plan for %s finished; reading it back as JSON" environment)
            (x-hugh-tf-plan--fetch-json
             environment root plan-file
             (lambda (plan)
               (x-hugh-tf-plan--discard-plan-file plan-file)
               (if plan
                   (progn
                     (display-buffer
                      (x-hugh-tf-plan-render plan environment root))
                     (funcall x-hugh-tf-plan-summary-function
                              (x-hugh-tf-plan-verdict plan environment)))
                 (message "Could not read the plan as JSON; showing the text")
                 (display-buffer text-buffer)))))
        (unless (string-prefix-p "finished" status)
          (message "Plan for %s did not finish cleanly: %s"
                   environment (string-trim status)))
        (x-hugh-tf-plan--discard-plan-file plan-file)
        (display-buffer text-buffer)))))

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

(defun x-hugh-tf-plan--flag-set-p (flags)
  "Return non-nil if FLAGS contains a true leaf anywhere.

FLAGS is a subtree of one of Terraform's parallel structures such as
`after_unknown' or `after_sensitive'.  Those mirror the shape of the
value they describe, so a list- or block-typed attribute with nothing
flagged inside it appears as an empty array or object rather than as
false.  Only a true leaf means anything is flagged; the presence of a
container means nothing at all.

A partly flagged container does count as flagged, which errs towards
withholding for sensitivity, and matches Terraform's habit of printing
a whole attribute as unknown."
  (cond
   ((eq flags t) t)
   ((vectorp flags) (seq-some #'x-hugh-tf-plan--flag-set-p flags))
   ((consp flags) (seq-some (lambda (cell)
                              (x-hugh-tf-plan--flag-set-p (cdr cell)))
                            flags))
   (t nil)))

(defun x-hugh-tf-plan--flagged-p (flags key)
  "Return non-nil if KEY is flagged in FLAGS."
  (cond
   ((eq flags t) t)
   ((consp flags) (x-hugh-tf-plan--flag-set-p (alist-get key flags)))
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
        (unless (or (not (x-hugh-tf-plan--flag-set-p (cdr cell)))
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

(defface x-hugh-tf-plan-clean-face
  '((t :inherit success :weight bold))
  "Face for the banner of a plan that would change nothing.")

(defface x-hugh-tf-plan-changes-face
  '((t :weight bold))
  "Face for the banner of a plan that would change something.
Weight only, so that the counts inside it keep their own colours.")

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
      "^Terraform used the selected providers"
      "^Terraform has compared your real infrastructure"
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
  "Fold the buffer down to its section and resource headings.
That is the first two levels: Terraform's own section markers sit at
column zero and the `# module... will be created' lines at column two.
Deeper headings are blocks within a resource, which are only worth
seeing once the resource is expanded."
  (interactive)
  (when (save-excursion
          (goto-char (point-min))
          (re-search-forward (concat "^\\(?:" outline-regexp "\\)") nil t))
    (outline-hide-sublevels 2)))

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
  "t" #'x-hugh-tf-plan-toggle-view
  "g" #'x-hugh-tf-plan-revert)

(define-derived-mode x-hugh-tf-plan-text-mode special-mode "TF-Plan-Text"
  "Major mode for reading the text output of a Terraform plan."
  (setq-local outline-regexp
              (rx (or (seq (* space) "# " (+ (not (any " "))) " "
                           (or "will be" "must be" "has been" "has changed"))
                      ;; A nested block or heredoc opener, which has to
                      ;; end the line: an attribute whose value merely
                      ;; contains a bracket, such as `(known after
                      ;; apply)', is a leaf and not a heading.
                      (seq (>= 6 space) (or "-/+" "+/-" "+" "-" "~") " "
                           (+ (not (any " "))) (* nonl)
                           (or (any "{[") (seq "<<" (opt "-") (+ (in "A-Z"))))
                           eol)
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
N init+refresh output  t tree view  g re-run  q quit")
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
        (ansi-color-filter-region (point-min) (point-max))
        (x-hugh-tf-plan-text-mode)
        (setq x-hugh-tf-plan--environment environment)
        (goto-char (point-min))
        (font-lock-ensure)
        (x-hugh-tf-plan-fold-noise)
        (x-hugh-tf-plan-fold-bodies)))
    buffer))

;;; Formatting values

(defun x-hugh-tf-plan--key-name (key)
  "Return KEY, an object key, as a string."
  (if (symbolp key) (symbol-name key) (format "%s" key)))

(defun x-hugh-tf-plan--encode (value)
  "Return VALUE on one line, in Terraform's brace-and-equals style."
  (cond
   ((eq value :unknown) "(known after apply)")
   ((eq value :sensitive) "(sensitive value)")
   ((memq value '(:null :absent)) "null")
   ((eq value :false) "false")
   ((eq value t) "true")
   ((numberp value) (number-to-string value))
   ((stringp value) (json-encode-string value))
   ((vectorp value)
    (concat "[" (mapconcat #'x-hugh-tf-plan--encode value ", ") "]"))
   ((null value) "{}")
   ((consp value)
    (concat "{"
            (mapconcat (lambda (cell)
                         (format "%s = %s"
                                 (x-hugh-tf-plan--key-name (car cell))
                                 (x-hugh-tf-plan--encode (cdr cell))))
                       value ", ")
            "}"))
   (t (format "%S" value))))

(defun x-hugh-tf-plan--format-string (string indent)
  "Format STRING, as a heredoc indented by INDENT if it has newlines."
  (if (string-search "\n" string)
      (let ((pad (make-string (+ indent 4) ?\s)))
        (concat "<<-EOT\n"
                (mapconcat (lambda (line) (concat pad line))
                           (split-string (string-trim-right string "\n+") "\n")
                           "\n")
                "\n" (make-string indent ?\s) "EOT"))
    (json-encode-string string)))

(defun x-hugh-tf-plan--format-multiline (value indent)
  "Format VALUE, an array or object, over several lines from column INDENT."
  (let ((pad (make-string (+ indent 2) ?\s))
        (close (make-string indent ?\s)))
    (cond
     ((vectorp value)
      (concat "[\n"
              (mapconcat (lambda (element)
                           (concat pad (x-hugh-tf-plan--format-value
                                        element (+ indent 2))))
                         value ",\n")
              "\n" close "]"))
     ((consp value)
      (concat "{\n"
              (mapconcat (lambda (cell)
                           (concat pad (x-hugh-tf-plan--key-name (car cell))
                                   " = " (x-hugh-tf-plan--format-value
                                          (cdr cell) (+ indent 2))))
                         value "\n")
              "\n" close "}"))
     (t (x-hugh-tf-plan--encode value)))))

(defun x-hugh-tf-plan--format-value (value indent)
  "Format VALUE for display, with any extra lines indented by INDENT."
  (cond
   ((stringp value) (x-hugh-tf-plan--format-string value indent))
   ((or (vectorp value) (consp value))
    (let ((compact (x-hugh-tf-plan--encode value)))
      (if (<= (+ indent (length compact)) x-hugh-tf-plan-value-width)
          compact
        (x-hugh-tf-plan--format-multiline value indent))))
   (t (x-hugh-tf-plan--encode value))))

;;; The section view

(defvar-local x-hugh-tf-plan--plan nil
  "Parsed plan this buffer is showing.")

(defun x-hugh-tf-plan-buffer-name (environment)
  "Name of the section view buffer for ENVIRONMENT."
  (format "*tf-plan: %s*" environment))

(defun x-hugh-tf-plan--action-face (action)
  "Return the face for ACTION."
  (pcase action
    ('create 'x-hugh-tf-plan-create-face)
    ('delete 'x-hugh-tf-plan-delete-face)
    ('update 'x-hugh-tf-plan-update-face)
    ('replace 'x-hugh-tf-plan-replace-face)
    ('read 'x-hugh-tf-plan-read-face)
    (_ 'default)))

(defun x-hugh-tf-plan--action-glyph (action)
  "Return the diff glyph for ACTION."
  (pcase action
    ('create "+")
    ('delete "-")
    ('update "~")
    ('replace "-/+")
    ('read "<=")
    (_ "?")))

(defun x-hugh-tf-plan--action-label (action)
  "Return a word for ACTION."
  (pcase action
    ('create "create")
    ('delete "destroy")
    ('update "update")
    ('replace "replace")
    ('read "read")
    (_ (symbol-name action))))

;;;; The verdict

(defcustom x-hugh-tf-plan-use-emoji t
  "When non-nil, lead the verdict banner with an emoji."
  :type 'boolean)

(defcustom x-hugh-tf-plan-summary-function #'x-hugh-tf-plan-echo-summary
  "Function called with the verdict, as a string, when a plan finishes.
A plan takes minutes, by which time you are probably looking at
something else, so the answer is announced rather than only written to a
buffer.  Set this to `ignore' for silence, or to something built on
`alert' for a desktop notification."
  :type 'function)

(defconst x-hugh-tf-plan--count-labels
  '((create "to add" x-hugh-tf-plan-create-face)
    (update "to change" x-hugh-tf-plan-update-face)
    (replace "to replace" x-hugh-tf-plan-replace-face)
    (delete "to destroy" x-hugh-tf-plan-delete-face)
    (read "to read" x-hugh-tf-plan-read-face))
  "Action, wording and face for each line of a plan summary.
Replacements are counted as replacements, rather than as an add and a
destroy as Terraform's own summary does, because a replacement destroys
and that is worth seeing.")

(defun x-hugh-tf-plan--counts-text (plan &optional faced)
  "Return the counts in PLAN as a string, empty if nothing would change.
With FACED, fontify each number by its action."
  (let ((counts (x-hugh-tf-plan-summary plan)))
    (string-join
     (delq nil
           (mapcar
            (lambda (entry)
              (let ((count (or (alist-get (car entry) counts) 0)))
                (unless (zerop count)
                  (concat (if faced
                              (propertize (number-to-string count)
                                          'face (nth 2 entry))
                            (number-to-string count))
                          " " (nth 1 entry)))))
            x-hugh-tf-plan--count-labels))
     ", ")))

(defun x-hugh-tf-plan--clean-p (plan)
  "Return non-nil if PLAN would change nothing.
Drift does not count: it has already happened, and no apply is needed to
respond to it unless Terraform also proposes a change."
  (not (or (plist-get plan :changes)
           (plist-get plan :outputs))))

(defun x-hugh-tf-plan-verdict (plan environment &optional faced)
  "Return the one-line verdict on PLAN for ENVIRONMENT.
With FACED, fontify it for display in a buffer."
  (let* ((errored (plist-get plan :errored))
         (clean (x-hugh-tf-plan--clean-p plan))
         (face (cond (errored 'error)
                     (clean 'x-hugh-tf-plan-clean-face)
                     (t 'x-hugh-tf-plan-changes-face)))
         (text (cond
                (errored
                 (format "Terraform errored; the plan for %s is incomplete"
                         environment))
                (clean
                 (format "No changes.  %s matches the configuration."
                         environment))
                (t
                 (format "%s in %s"
                         (x-hugh-tf-plan--counts-text plan faced)
                         environment))))
         (line (concat (if x-hugh-tf-plan-use-emoji
                           (concat (cond (errored "❌") (clean "✅") (t "⚠️"))
                                   "  ")
                         "")
                       text)))
    (when faced
      ;; Appended, so that the counts keep the colours they already have.
      (add-face-text-property 0 (length line) face t line))
    line))

(defun x-hugh-tf-plan-echo-summary (summary)
  "Show SUMMARY in the echo area."
  (message "%s" summary))

(defun x-hugh-tf-plan--insert-banner (plan environment)
  "Insert the verdict on PLAN for ENVIRONMENT, set apart by whitespace."
  (magit-insert-heading (x-hugh-tf-plan-verdict plan environment t))
  (let ((drift (length (plist-get plan :drift))))
    (insert "\n"
            (propertize
             (format "terraform %s, %d resources unchanged%s"
                     (or (plist-get plan :terraform-version) "?")
                     (or (plist-get plan :unchanged) 0)
                     (if (zerop drift)
                         ""
                       (format ", %d changed outside Terraform" drift)))
             'face 'x-hugh-tf-plan-noise-face)
            "\n")))

(defun x-hugh-tf-plan--insert-footer (plan)
  "Insert the summary of PLAN again at the end, where Terraform puts it."
  (insert "\n"
          (propertize "Plan: " 'face 'x-hugh-tf-plan-heading-face)
          (x-hugh-tf-plan--counts-text plan t)
          ".\n"))

(defun x-hugh-tf-plan--attribute-line (attribute width)
  "Return ATTRIBUTE as a line, with its key padded to WIDTH."
  (let* ((glyph (plist-get attribute :glyph))
         (key (x-hugh-tf-plan--key-name (plist-get attribute :key)))
         (prefix (concat "      " glyph " " (string-pad key width) " = "))
         (column (length prefix))
         (face (pcase glyph
                 ("+" 'x-hugh-tf-plan-create-face)
                 ("-" 'x-hugh-tf-plan-delete-face)
                 ("~" 'x-hugh-tf-plan-update-face)
                 (_ 'x-hugh-tf-plan-unknown-face)))
         (body
          (pcase glyph
            ("+" (x-hugh-tf-plan--format-value
                  (plist-get attribute :after) column))
            ("-" (x-hugh-tf-plan--format-value
                  (plist-get attribute :before) column))
            ("~" (let ((old (x-hugh-tf-plan--format-value
                             (plist-get attribute :before) column))
                       (new (x-hugh-tf-plan--format-value
                             (plist-get attribute :after) column)))
                   (if (and (not (string-search "\n" old))
                            (not (string-search "\n" new))
                            (<= (+ column (length old) 4 (length new))
                                x-hugh-tf-plan-value-width))
                       (concat old " -> " new)
                     (concat old "\n"
                             (make-string (max 0 (- column 3)) ?\s)
                             "-> " new))))
            (_ (let ((value (plist-get attribute :after)))
                 (x-hugh-tf-plan--format-value
                  (if (eq value :absent) (plist-get attribute :before) value)
                  column))))))
    (propertize (concat prefix body) 'face face)))

(defun x-hugh-tf-plan--insert-attributes (attributes)
  "Insert ATTRIBUTES, one per line, with their keys aligned."
  (when attributes
    (let ((width (apply #'max
                        (mapcar (lambda (attribute)
                                  (length (x-hugh-tf-plan--key-name
                                           (plist-get attribute :key))))
                                attributes))))
      (dolist (attribute attributes)
        (insert (x-hugh-tf-plan--attribute-line attribute width) "\n")))))

(defun x-hugh-tf-plan--relative-address (resource)
  "Return the address of RESOURCE without its module prefix."
  (let ((address (plist-get resource :address))
        (module (plist-get resource :module)))
    (if (and module
             (not (string-empty-p module))
             (string-prefix-p (concat module ".") address))
        (substring address (1+ (length module)))
      address)))

(defun x-hugh-tf-plan--insert-resource (resource &optional full-address)
  "Insert a collapsed section for RESOURCE.
With FULL-ADDRESS, label it with its whole address rather than with the
part below its module.  Stripping the module only reads well when a
module heading is standing above it."
  (let* ((action (plist-get resource :action))
         (face (x-hugh-tf-plan--action-face action))
         (reason (plist-get resource :reason))
         (attributes (plist-get resource :attributes))
         (changed (seq-filter (lambda (a) (plist-get a :changed)) attributes))
         (unchanged (seq-remove (lambda (a) (plist-get a :changed)) attributes))
         (start (point)))
    (magit-insert-section (tf-plan-resource (plist-get resource :address) t)
      (magit-insert-heading
        (concat
         (propertize (string-pad (x-hugh-tf-plan--action-glyph action) 4)
                     'face face)
         (propertize (string-pad (x-hugh-tf-plan--action-label action) 8)
                     'face face)
         (propertize (if full-address
                         (plist-get resource :address)
                       (x-hugh-tf-plan--relative-address resource))
                     'face 'x-hugh-tf-plan-address-face)
         (if reason
             (propertize (format "  (%s)" (string-replace "_" " " reason))
                         'face 'x-hugh-tf-plan-unknown-face)
           "")))
      (x-hugh-tf-plan--insert-attributes changed)
      (when unchanged
        (magit-insert-section (tf-plan-unchanged
                               (plist-get resource :address) t)
          (magit-insert-heading
            (propertize (format "      %d unchanged attribute%s"
                                (length unchanged)
                                (if (= 1 (length unchanged)) "" "s"))
                        'face 'x-hugh-tf-plan-unknown-face))
          (x-hugh-tf-plan--insert-attributes unchanged))))
    ;; Carry the resource on the text so that visiting and copying can
    ;; find it from any line, without reaching into magit's section
    ;; objects.
    (put-text-property start (point) 'x-hugh-tf-plan-resource resource)))

(defun x-hugh-tf-plan--group-by-module (resources)
  "Return RESOURCES grouped into an alist by module address, sorted."
  (let ((groups '()))
    (dolist (resource resources)
      (let* ((module (plist-get resource :module))
             (cell (assoc module groups)))
        (if cell
            (setcdr cell (cons resource (cdr cell)))
          (push (cons module (list resource)) groups))))
    (mapcar (lambda (cell) (cons (car cell) (nreverse (cdr cell))))
            (sort groups (lambda (a b) (string< (car a) (car b)))))))

(defun x-hugh-tf-plan--insert-module (module resources)
  "Insert a section for MODULE holding RESOURCES."
  (magit-insert-section (tf-plan-module module)
    (magit-insert-heading
      (concat (propertize (if (string-empty-p module) "(root module)" module)
                          'face 'x-hugh-tf-plan-heading-face)
              (propertize (format "  %d" (length resources))
                          'face 'x-hugh-tf-plan-noise-face)))
    (dolist (resource resources)
      (x-hugh-tf-plan--insert-resource resource))
    (insert "\n")))

(defun x-hugh-tf-plan--insert-changes (plan)
  "Insert the resource changes in PLAN."
  (let ((changes (plist-get plan :changes)))
    (when changes
      (insert "\n")
      (dolist (group (x-hugh-tf-plan--group-by-module changes))
        (x-hugh-tf-plan--insert-module (car group) (cdr group))))))

(defun x-hugh-tf-plan--insert-drift (plan)
  "Insert the out-of-band changes in PLAN, if any."
  (let ((drift (plist-get plan :drift)))
    (when drift
      (insert "\n")
      (magit-insert-section (tf-plan-drift nil t)
        (magit-insert-heading
          (concat (propertize "Changed outside Terraform"
                              'face 'x-hugh-tf-plan-heading-face)
                  (propertize (format "  %d" (length drift))
                              'face 'x-hugh-tf-plan-noise-face)))
        (dolist (resource drift)
          (x-hugh-tf-plan--insert-resource resource t))
        (insert "\n")))))

(defun x-hugh-tf-plan--insert-outputs (plan)
  "Insert the output changes in PLAN, if any."
  (let ((outputs (plist-get plan :outputs)))
    (when outputs
      (magit-insert-section (tf-plan-outputs nil t)
        (magit-insert-heading
          (concat (propertize "Changes to Outputs"
                              'face 'x-hugh-tf-plan-heading-face)
                  (propertize (format "  %d" (length outputs))
                              'face 'x-hugh-tf-plan-noise-face)))
        (dolist (output outputs)
          (x-hugh-tf-plan--insert-attributes (plist-get output :attributes)))
        (insert "\n")))))

;;;; Acting on what is under point

(defun x-hugh-tf-plan--resource-at-point ()
  "Return the resource described by the line at point, or nil."
  (get-text-property (line-beginning-position) 'x-hugh-tf-plan-resource))

(defun x-hugh-tf-plan--git-grep (root pattern)
  "Return the hits for PATTERN in the Terraform files under ROOT.
Each hit is a cons of its `file:line:text' description and a cons of file
and line."
  (let ((default-directory root))
    (delq nil
          (mapcar (lambda (line)
                    (when (string-match "\\`\\([^:]+\\):\\([0-9]+\\):" line)
                      (cons line (cons (match-string 1 line)
                                       (string-to-number
                                        (match-string 2 line))))))
                  ;; git grep exits non-zero when nothing matches, which
                  ;; process-lines turns into an error.
                  (ignore-errors
                    (process-lines "git" "grep" "-n" "-E" pattern
                                   "--" "*.tf"))))))

(defun x-hugh-tf-plan--visit-hit (root hit)
  "Visit the file and line of HIT, relative to ROOT."
  (let ((file (expand-file-name (car (cdr hit)) root))
        (line (cdr (cdr hit))))
    (pop-to-buffer (find-file-noselect file))
    (goto-char (point-min))
    (forward-line (1- line))))

(defun x-hugh-tf-plan-visit-resource ()
  "Visit the definition of the resource at point.

The plan gives an address, not a location, so this greps for the block
that declares it.  A resource inside a module is declared once however
many times the module is called, so a single hit is the common case."
  (interactive)
  (let* ((resource (or (x-hugh-tf-plan--resource-at-point)
                       (user-error "No resource on this line")))
         (root (or x-hugh-tf-plan--root default-directory))
         (keyword (if (equal (plist-get resource :mode) "data")
                      "data" "resource"))
         (pattern (format "^[[:space:]]*%s[[:space:]]+\"%s\"[[:space:]]+\"%s\""
                          keyword
                          (plist-get resource :type)
                          (plist-get resource :name)))
         (hits (x-hugh-tf-plan--git-grep root pattern)))
    (pcase (length hits)
      (0 (message "No declaration found for %s" (plist-get resource :address)))
      (1 (x-hugh-tf-plan--visit-hit root (car hits)))
      (_ (x-hugh-tf-plan--visit-hit
          root (assoc (completing-read "Declaration: " hits nil t) hits))))))

(defun x-hugh-tf-plan-copy-address ()
  "Copy the address of the resource at point to the kill ring."
  (interactive)
  (let ((resource (or (x-hugh-tf-plan--resource-at-point)
                      (user-error "No resource on this line"))))
    (kill-new (plist-get resource :address))
    (message "%s" (plist-get resource :address))))

(defun x-hugh-tf-plan-toggle-view ()
  "Switch between the section view and the text view of this plan."
  (interactive)
  (let* ((environment (or x-hugh-tf-plan--environment
                          (user-error "No environment recorded here")))
         (other (get-buffer
                 (if (derived-mode-p 'x-hugh-tf-plan-mode)
                     (x-hugh-tf-plan-text-buffer-name environment)
                   (x-hugh-tf-plan-buffer-name environment)))))
    (if other
        (pop-to-buffer other)
      (message "No other view of the plan for %s" environment))))

;;;; The mode

(defvar-keymap x-hugh-tf-plan-mode-map
  :doc "Keymap for `x-hugh-tf-plan-mode'."
  :parent magit-section-mode-map
  "RET" #'x-hugh-tf-plan-visit-resource
  "w" #'x-hugh-tf-plan-copy-address
  "t" #'x-hugh-tf-plan-toggle-view
  "g" #'x-hugh-tf-plan-revert
  "q" #'quit-window)

(define-derived-mode x-hugh-tf-plan-mode magit-section-mode "TF-Plan"
  "Major mode for reading a Terraform plan as a tree of changes."
  (setq-local header-line-format
              "TAB fold  RET declaration  w copy address  \
t text view  g re-run  q quit"))

(defun x-hugh-tf-plan-render (plan environment root)
  "Render PLAN for ENVIRONMENT in ROOT.  Return the buffer."
  (let ((buffer (get-buffer-create (x-hugh-tf-plan-buffer-name environment))))
    (with-current-buffer buffer
      (let ((inhibit-read-only t))
        (erase-buffer)
        (x-hugh-tf-plan-mode)
        (setq x-hugh-tf-plan--environment environment
              x-hugh-tf-plan--root root
              x-hugh-tf-plan--plan plan
              default-directory (or root default-directory))
        (magit-insert-section (tf-plan)
          (x-hugh-tf-plan--insert-banner plan environment)
          ;; With nothing to apply there is no tree worth drawing, and
          ;; drawing one buries the answer.  Drift comes after the
          ;; changes because it is context rather than something to do.
          (if (x-hugh-tf-plan--clean-p plan)
              (x-hugh-tf-plan--insert-drift plan)
            (x-hugh-tf-plan--insert-changes plan)
            (x-hugh-tf-plan--insert-outputs plan)
            (x-hugh-tf-plan--insert-drift plan)
            (x-hugh-tf-plan--insert-footer plan)))
        ;; Sections record whether they want to be hidden, but nothing
        ;; acts on that until the root is shown; magit does this from
        ;; magit-refresh-buffer.  Without it every section is expanded.
        (magit-section-show magit-root-section)
        (goto-char (point-min))))
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
