;;; x-hugh-helm --- My helm stuff

;;; Commentary:
;;; Break out all helm stuff into one place.

;;; Code:
(if (eq window-system nil)
    (setq x-hugh-helm-enabled nil)
  (setq x-hugh-helm-enabled t))

(if x-hugh-helm-enabled
    (use-package helm
      :ensure t
      :config
      (progn
        (helm-mode 1)
        (global-set-key (kbd "M-x")     'helm-M-x)
        (global-set-key (kbd "M-y")     'helm-show-kill-ring)
        (global-set-key (kbd "C-x b")   'helm-mini)
        (global-set-key (kbd "C-x C-f") 'helm-find-files)
        ;; helm-do-grep is better.
        ;; (global-set-key "\C-cif"	'helm-do-grep)
        (setq helm-ff-newfile-prompt-p nil))
      (use-package helm-config
	:ensure t)
      (use-package helm-xref
	:ensure t)
      ))

;; Also: see x-hugh-swiper.el for swiper-helm

(provide 'x-hugh-helm)
;;; x-hugh-helm.el ends here
