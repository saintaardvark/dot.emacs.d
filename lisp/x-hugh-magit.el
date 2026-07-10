;;; -*- lexical-binding: t -*-
;;; package --- x-hugh-magit

;;; Commentary:
;; Magit ROX.

;;; Code:

;; Note: The git commit template is set in
;; ~/.githooks_global/prepare-commit-msg.
(defun x-hugh-skip-over-issue-number-in-git-commit()
  "Skip over the issue number in a git commit template, if present."
  (interactive)
  (if (or (looking-at "DNS-")
	  (looking-at "DS")
	  (looking-at "MSIMP"))
      (progn
	(search-forward ":")
	(if (not (looking-at " "))
	    (insert " "))
	(move-end-of-line nil))))

(defun x-hugh-spinoff-branch-named-after-current-one (new-branch)
  "Spin off new git branch named after current branch."
  ;; (interactive (format "sNew branch name: "))
  (interactive (list (read-string "New branch name: " (magit-get-current-branch))))
  (message new-branch)
  (magit-branch-spinoff new-branch))

(defun x-hugh-spinoff-branch-named-after-a-ticket (new-branch)
  "Spin off new git branch named after current branch."
  ;; (interactive (format "sNew branch name: "))
  (interactive (list (read-string "New branch name: " (x-hugh-branch-suggestions))))
  (message new-branch)
  (magit-branch-spinoff new-branch))

;; (use-package git-commit
;;   :ensure t
;;   :custom ((git-commit-summary-max-length 50)
;; 	   ;; Hook copied from default in git-commit.el
;; 	   (git-commit-setup-hook '(git-commit-save-message
;; 				    git-commit-setup-changelog-support
;; 				    git-commit-turn-on-auto-fill
;; 				    git-commit-propertize-diff
;; 				    bug-reference-mode
;; 				    magit-diff-while-committing
;; 				    x-hugh-skip-over-issue-number-in-git-commit))))

(add-hook 'find-file-hook
	  (lambda () (if (string-match-p "COMMIT_EDITMSG" buffer-file-name)
			 (progn
			   (x-hugh-skip-over-issue-number-in-git-commit)))))

;; TODO: I like this, but I can't make it visible with my preferred themes.
;; (use-package magit-delta
;;   :ensure t
;;   :hook (magit-mode . magit-delta-mode)
;;   :config (setq magit-delta-delta-args (append magit-delta-delta-args '("--features" "magit-delta"))))

;; NOTE: Also see x-hugh-appearance for split-width-threshold and
;; split-horizontal-threshold.
(use-package magit
  :ensure t
  ;; From https://magit.vc/manual/magit/Performance.html#Performance
  :custom ((magit-refresh-status-buffer nil)
	   (vc-handled-backends nil)
	   (magit-clone-set-remote\.pushDefault t)
	   (magit-commit-arguments (quote ("--signoff")))
	   (magit-commit-show-diff t)
	   (magit-save-repository-buffers (quote dontask))
	   (magit-use-overlays nil)
	   (magit-repository-directories
	    '(;; Directory containing project root directories
	      ("~/dev/"      . 4)
	      ;; Specific project root directory
	      ;; ("~/dotfiles/" . 1)
	      ))
	   )
  :config (remove-hook 'server-switch-hook 'magit-commit-diff))

(defun x-hugh-git-changetype ()
  "Cycle through git changetype.

Meant for use in magit."
  (interactive)
  (save-excursion
    (search-forward-regexp "^Change-type: ")
    (cond ((looking-at "\\[patch\\|minor\\|major\\]")
	   (progn (kill-line)
		  (insert "patch")))
	  ((looking-at "patch")
	   (progn (kill-line)
		  (insert "minor")))
	  ((looking-at "minor")
	   (progn (kill-line)
		  (insert "major")))
	  ((looking-at "major")
	   (progn (kill-line)
		  (insert "patch"))))))

(defun x-hugh-git-connects-to ()
  "Add \"Connects-to\" argument to git commit.

Meant for use in magit."
  (interactive)
  (save-excursion
    (if (search-forward-regexp "^Connects-to:" nil t)
	(progn (beginning-of-line)
	       (kill-line)
	       (join-line))
      (let ((ticket (read-from-minibuffer "Ticket: ")))
	(search-forward-regexp "^Change-type: ")
	(forward-line)
	(insert (format "Connects-to: %s\n" ticket))))))

;; See https://systemcrafters.net/learning-emacs-lisp/creating-minor-modes/
(define-minor-mode x-hugh-github-pr-mode
  "Toggles global x-hugh-github-pr-mode."
  nil   ; Initial value, nil for disabled
  :global t
  :group 'dotfiles
  :lighter " x-hugh-github-pr"
  :keymap
  (list (cons (kbd "C-c C-. t") (lambda ()
				  (interactive)
				  (message "x-hugh-github-pr key binding used!"))))

  (if x-hugh-github-pr-mode
      (message "x-hugh-github-pr-basic-mode activated!")
    (message "x-hugh-github-pr-basic-mode deactivated!")))

(add-hook 'x-hugh-github-pr-mode-hook
	  (lambda ()
	    (progn
	      (auto-fill-mode nil)
	      (visual-line-mode)
	      (message "Hook was executed!"))))

(add-hook 'x-hugh-github-pr-mode-on-hook (lambda () (message "x-hugh-github-pr turned on!")))
(add-hook 'x-hugh-github-pr-mode-off-hook (lambda () (message "x-hugh-github-pr turned off!")))

(use-package consult-gh
  :after consult)

;; OH WOW, this actually works really well 😍
(defvar x-hugh-gpc--origins (make-hash-table :test 'equal)
  "Map a gh PR temp directory to data about the run that created it.
Keys are truename directories (see `x-hugh-gpc'); values are plists
of (:buffer TERM-BUFFER :root PROJECT-ROOT :dir TMPDIR).")

(defvar x-hugh-gpc--counter 0
  "Monotonic counter making each `x-hugh-gpc' temp directory unique.")

(defvar-local x-hugh-gpc--origin-buffer nil
  "The *x-hugh-gpc* term buffer that spawned this PR edit buffer.")

(defun x-hugh-gpc--tmp-base (root)
  "Return a directory under ROOT to hold gh's PR temp file.
Prefer inside .git -- invisible to `git status', but still within
the project so projectile resolves it -- falling back to a
dot-directory in ROOT when .git is not a real directory (e.g. a
worktree, where .git is a file)."
  (let ((dotgit (expand-file-name ".git" root)))
    (if (file-directory-p dotgit)
        (expand-file-name "x-hugh-gpc" dotgit)
      (expand-file-name ".x-hugh-gpc-tmp" root))))

(defun x-hugh-gpc (&optional extra-args)
  "Run `gh pr create' in an ansi-term.
Point gh's TMPDIR at a throwaway directory inside the current
project so the PR body buffer gh opens is seen by projectile, and
remember which term buffer owns it so the edit buffer can jump
back with `x-hugh-gpc-return-to-origin'.

EXTRA-ARGS is a list of additional shell-safe arguments (flags such
as \"--draft\" or \"--base=main\") appended to the gh command.  The
transient menu `x-hugh-gh-pr' in x-hugh-gh-transient.el supplies it;
callers must not pass values that need shell quoting."
  (interactive)
  ;; Use `bash -c' here.  I've had to turn off sourcing .bashrc at
  ;; Gnome login, and that means losing the EDITOR and github variable
  ;; automagic.
  (let* ((root (or (and (fboundp 'projectile-project-root)
                        (projectile-project-root))
                   default-directory))
         (id (setq x-hugh-gpc--counter (1+ x-hugh-gpc--counter)))
         (tmpdir (file-name-as-directory
                  (expand-file-name (number-to-string id)
                                    (x-hugh-gpc--tmp-base root))))
         (process-environment (cons (concat "TMPDIR=" tmpdir)
                                    process-environment))
         (command (mapconcat #'identity
                             (append '("gh" "pr" "create") extra-args)
                             " ")))
    (make-directory tmpdir t)
    (let ((buf (ansi-term (format "bash -c '%s'" command) "*x-hugh-gpc*")))
      (puthash (file-truename tmpdir)
               (list :buffer buf :root root :dir tmpdir)
               x-hugh-gpc--origins)
      buf)))

(defun x-hugh-gpc-return-to-origin ()
  "Switch to the *x-hugh-gpc* buffer that spawned this PR edit buffer."
  (interactive)
  (if (buffer-live-p x-hugh-gpc--origin-buffer)
      (pop-to-buffer x-hugh-gpc--origin-buffer)
    (message "No live x-hugh-gpc buffer for this PR")))

(define-minor-mode x-hugh-gpc-edit-mode
  "Minor mode for a gh PR body buffer opened via `x-hugh-gpc'.
\\{x-hugh-gpc-edit-mode-map}"
  :lighter " gpc"
  :keymap (let ((m (make-sparse-keymap)))
            (define-key m (kbd "C-c g") #'x-hugh-gpc-return-to-origin)
            m))

(defun x-hugh-gpc--adopt ()
  "Wire a freshly visited gh PR body buffer back to its origin.
Runs from `server-visit-hook': if the visited file lives under a
directory registered by `x-hugh-gpc', point `default-directory' at
the project root, record the origin term buffer, enable
`x-hugh-gpc-edit-mode', and arrange to return there and clean up
the temp directory when the buffer is killed (gh finishes the edit
on \\[server-edit], which kills the client buffer)."
  (let ((file (and buffer-file-name (file-truename buffer-file-name))))
    (when file
      (catch 'done
        (maphash
         (lambda (dir data)
           (when (string-prefix-p dir file)
             (let ((origin (plist-get data :buffer))
                   (root (plist-get data :root))
                   (tmpdir (plist-get data :dir)))
               (setq x-hugh-gpc--origin-buffer origin)
               (setq default-directory root)
               (x-hugh-gpc-edit-mode 1)
               (add-hook 'kill-buffer-hook
                         (lambda ()
                           (remhash dir x-hugh-gpc--origins)
                           (when (file-directory-p tmpdir)
                             (delete-directory tmpdir t))
                           (when (buffer-live-p origin)
                             (run-at-time 0 nil #'pop-to-buffer origin)))
                         nil t))
             (throw 'done nil)))
         x-hugh-gpc--origins)))))

(add-hook 'server-visit-hook #'x-hugh-gpc--adopt)

;; In conjunction with above:
(defun x-hugh-save-gh-body-to-kill-ring ()
  "Copy a gh PR body buffer to the kill ring on save."
  (when (or x-hugh-gpc-edit-mode
            (string-match "/tmp/[0-9]+\\.md$" (or buffer-file-name "")))
    (kill-new (buffer-string))))
(add-hook 'after-save-hook #'x-hugh-save-gh-body-to-kill-ring)

;; TODO: Doesn't skip single asterisks, but leaving that for now.
(defun x-hugh-clean-bullet-lines (beg end)
  "Clean selected lines: remove **, strip ticket numbers (e.g. MSIMP-85:), normalize dash spacing."
  (interactive "r")
  (let ((lines (split-string (buffer-substring-no-properties beg end) "\n")))
    (delete-region beg end)
    (insert
     (mapconcat
      (lambda (line)
        (let* ((s line)
               ;; Remove ** (two or more asterisks) but preserve single *
               (s (replace-regexp-in-string "\*\*+" "" s))
               ;; Remove ticket number + colon + optional spaces
               (s (replace-regexp-in-string "[A-Z]+-[0-9]+: *" "" s))
               ;; Normalize dash at line start to exactly one space
               (s (replace-regexp-in-string "^-[ \t]+" "- " s)))
          s))
      lines
      "\n"))))

(defun x-hugh-blank-pr ()
  "Blank a Github PR template. 🤘"
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (beginning-of-line)
    ;; The 't' here means return `nil`, rather than raise an error, if we can't find our regex
    (while (re-search-forward (rx line-start "#") nil t)
      (forward-line 1)
      (let ((beg (point)))
	(if (re-search-forward (rx line-start "#") nil t)
	    (progn
	      (backward-char)
	      (forward-line -1))
	  (goto-char (point-max)))
	(delete-region beg (point))
	(insert "\n\n"))))
  (goto-char (point-min))
  (forward-line 2))

(defun run-shell-script-and-capture-output-as-list (script-path)
  "Run a shell script at SCRIPT-PATH and return its output as a list of lines.
If the script cannot be executed, return an empty list."
  (if (and (file-exists-p script-path) (file-executable-p script-path))
      (with-temp-buffer
        (let ((exit-code (call-process "bash" nil t nil script-path)))
          (if (eq exit-code 0)
              (cl-loop for line in (split-string (buffer-string) "\n" t)
                       collect line)
            (message "Error: Script exited with code %d" exit-code)
            '())))
    (message "Error: Script does not exist or is not executable.")
    '()))

(defun x-hugh-branch-suggestions ()
  "Branch name suggestions"
  (interactive)
  (let ((ticket (x-hugh-pick-a-ticket)))
    (if ticket
	(progn
	  (setq branch (replace-regexp-in-string (rx punctuation) " " ticket))
	  (setq branch (replace-regexp-in-string (rx (+ whitespace)) "-" branch))
	  (setq branch (downcase branch))
	  (setq branch (replace-regexp-in-string (rx line-start "dns") "DNS" branch))
	  (setq branch (replace-regexp-in-string (rx line-start "ds") "DS" branch))
	  (setq branch (replace-regexp-in-string (rx line-start "msimp") "MSIMP" branch))
	  (message "You selected: %s" branch)
	  branch)
      (message "No suggestion."))))
;;
(provide 'x-hugh-magit)

;;; x-hugh-magit.el ends here
