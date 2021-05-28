;;; x-hugh-custom --- My custom file.

;;; Commentary:
;; flycheck, get off my back.

;;; Code:

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("2809bcb77ad21312897b541134981282dc455ccd7c14d74cc333b6e549b824f3" "c433c87bd4b64b8ba9890e8ed64597ea0f8eb0396f4c9a9e01bd20a04d15d358" default))
 '(ns-command-modifier nil)
 '(package-selected-packages
   '(wc-mode skewer-mode web-beautify ag gited company-go go-autocomplete go-eldoc golint go-mode go-projectile frame-cmds use-package solarized-theme smex smartparens exec-path-from-shell counsel aggressive-indent))
 '(pdf-view-midnight-colors '("#fdf4c1" . "#1d2021"))
 '(safe-local-variable-values
   '((elpy-rpc-virtualenv-path "/home/aardvark/dev/polaris/.venv")
     (eval add-hook 'before-save-hook
	   (lambda nil
	     (delete-trailing-whitespace)
	     nil))
     (indent-tabs-mode t)
     (indent-tabs-mode nil)
     ((eval add-hook 'write-file-hooks 'delete-trailing-whitespace)
      (eval add-hook 'before-save-hook
	    (lambda nil
	      (delete-trailing-whitespace)
	      nil))
      (mangle-whitespace . t)))))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(fixmee-notice-face ((t (:background "gray88" :foreground "dark red" :underline nil :slant italic :weight bold))))
 '(org-done ((t (:foreground "PaleGreen" :weight normal :strike-through t))))
 '(org-headline-done ((((class color) (min-colors 16) (background dark)) (:foreground "LightSalmon" :strike-through t))))
 '(org-level-1 ((t (:inherit nil :foreground "#cb4b16" :height 1.3))))
 '(org-level-2 ((t (:inherit nil :foreground "#859900" :height 1.2))))
 '(org-level-3 ((t (:inherit nil :foreground "#268bd2" :height 1.15))))
 '(org-level-4 ((t (:inherit nil :foreground "#b58900" :height 1.1))))
 '(org-level-5 ((t (:inherit nil :foreground "#2aa198"))))
 '(org-level-6 ((t (:inherit nil :foreground "#859900"))))
 '(org-level-7 ((t (:inherit nil :foreground "#dc322f"))))
 '(org-level-8 ((t (:inherit nil :foreground "#268bd2")))))

;;; x-hugh-custom ends here.
