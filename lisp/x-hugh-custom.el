;;; x-hugh-custom --- My custom file.

;;; Commentary:
;; flycheck, get off my back.

;;; Code:

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ns-command-modifier nil)
 '(package-archives
   '(("org" . "https://orgmode.org/elpa/")
     ("melpa" . "https://melpa.org/packages/")
     ("gnu" . "https://elpa.gnu.org/packages/")))
 '(package-selected-packages
   '(lsp-pyright adoc-mode elscreen elscreen-buffer-group 0blayout avy-flycheck flyspell-correct-avy-menu lsp-ui lsp-mode wsd-mode rg wc-mode skewer-mode web-beautify ag gited company-go go-autocomplete go-eldoc golint go-mode go-projectile frame-cmds use-package solarized-theme smex smartparens exec-path-from-shell counsel aggressive-indent))
 '(safe-local-variable-values
   '((eval add-hook 'before-save-hook
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
      (mangle-whitespace . t))))
 '(warning-suppress-types '((initialization))))

;; TODO Move these settings to orgmode, fixmee mode
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

;;; x-hugh-custom.el ends here.
