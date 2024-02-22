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
	(insert " ")
	(move-end-of-line))))

(use-package git-commit
  :ensure t
  :custom ((git-commit-summary-max-length 50)
	   ;; Hook copied from default in git-commit.el
	   (git-commit-setup-hook '(git-commit-save-message
				    git-commit-setup-changelog-support
				    git-commit-turn-on-auto-fill
				    git-commit-propertize-diff
				    bug-reference-mode
				    magit-diff-while-committing
				    x-hugh-skip-over-issue-number-in-git-commit))))

(use-package magit-delta
  :ensure t
  :hook (magit-mode . magit-delta-mode))

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

(provide 'x-hugh-magit)

;;; x-hugh-magit.el ends here
