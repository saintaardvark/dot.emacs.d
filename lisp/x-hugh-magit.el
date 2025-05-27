;;; package --- x-hugh-magit

;;; Commentary:
;; Magit ROX.

;;; Code:

(defun x-hugh-skip-over-issue-number-in-git-commit()
  "Skip over the issue number in a git commit template, if present."
  (interactive)
  (if (looking-at "DNS-")
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
(defun x-hugh-gpc()
  "Try to run gh pr create in ansi-term."
  (interactive)
  (ansi-term "gh pr create" "*x-hugh-gpc*"))

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
	  (message (format "Here: %s" branch))
	  (setq branch (replace-regexp-in-region (rx (+ whitespace)) "-" branch))
	  (message (format "THere: %s" branch))
	  (setq branch (downcase branch))
	  (message "You selected: %s" branch))
      (message "No suggestion."))))
;;
(defun x-hugh-pick-a-ticket ()
  "Pick a ticket."
  (interactive)
  (let ((options (run-shell-script-and-capture-output-as-list (expand-file-name "~/bin/which_ticket-no_fzf.sh"))))
    (helm :sources (helm-build-sync-source "Select an Option"
                     :candidates options
                     :action (lambda (selected)
                               (setq selected (if (stringp selected) selected nil))
                               (if selected
                                   (progn
                                     (message "You selected: %s" selected)
                                     selected)
                                 (error "No selection made.")))
                     :volatile t))))

(provide 'x-hugh-magit)

;;; x-hugh-magit.el ends here
