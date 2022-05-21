;;; package --- x-hugh-magit

;;; Commentary:
;; Magit ROX.

;;; Code:

;; We need cl-lib if less than 24.  This check taken from post.el.
;; (if (< (string-to-number (substring (emacs-version)
;; 				    (string-match "[0-9]+\.[0-9]"
;; 						  (emacs-version) 5))) 24)
;;     (load-file "~/.emacs.d/cl-lib-0.3.el"))
;; (setq load-path  (cons (expand-file-name "~/.emacs.d/git-modes/") load-path))
;; ;; (require 'git-commit-mode nil 'noerror)
;; ;; (setq load-path  (cons (expand-file-name "~/.emacs.d/magit/") load-path))
;; (setq magit-last-seen-setup-instructions "1.4.0")
;; ;; (require 'magit nil 'noerror)

(use-package git-commit
  :ensure t
  :custom (git-commit-summary-max-length 90))

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
	      ("~/dev/"      . 3)
	      ;; Specific project root directory
	      ;; ("~/dotfiles/" . 1)
	      ))
	   )
  :config (remove-hook 'server-switch-hook 'magit-commit-diff))

;; Turning this off -- refreshing CI status every time is very, very slow.
;; (require 'magithub)
;; (require 'magit-gh-pulls)
;; (add-hook 'magit-mode-hook 'turn-on-magit-gh-pulls)

(provide 'x-hugh-magit)

;;; x-hugh-magit ends here
