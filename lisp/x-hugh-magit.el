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

(defun x-hugh-spinoff-branch-named-after-current-one (suffix)
  "Spin off new git branch named after current branch."
  (interactive "sNew branch name: ")
  (message (format "%s-%s" (magit-get-current-branch) suffix))
  (magit-branch-spinoff (format "%s-%s" (magit-get-current-branch) suffix)))

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

(provide 'x-hugh-magit)

;;; x-hugh-magit.el ends here
