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

(require 'comint)
(require 'compile)
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
    (let ((environment x-hugh-tf-plan--environment))
      (if (string-prefix-p "finished" status)
          (message "Plan for %s finished" environment)
        (message "Plan for %s did not finish cleanly: %s"
                 environment (string-trim status))))))

(provide 'x-hugh-tf-plan)
;;; x-hugh-tf-plan.el ends here
