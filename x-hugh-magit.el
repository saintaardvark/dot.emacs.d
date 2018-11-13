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

(use-package magit
  :config
  ;; From https://magit.vc/manual/magit/Performance.html#Performance
  (progn (setq magit-refresh-status-buffer nil)
         (setq vc-handled-backends nil)
         (setq magit-clone-set-remote\.pushDefault t)
         (setq magit-commit-arguments (quote ("--signoff")))
         (setq magit-commit-show-diff t)
         (setq magit-save-repository-buffers (quote dontask))
         (setq magit-use-overlays nil)
         (remove-hook 'server-switch-hook 'magit-commit-diff)))

;; Turning this off -- refreshing CI status every time is very, very slow.
;; (require 'magithub)
;; (require 'magit-gh-pulls)
;; (add-hook 'magit-mode-hook 'turn-on-magit-gh-pulls)

(provide 'x-hugh-magit)

;;; x-hugh-magit ends here
