;;; x-hugh-eglot: configure eglot

;;; Commentary:

;;; Code:

(use-package eglot
  :ensure t
  :defer t
  :hook (python-mode . eglot-ensure))

;; Eldoc is used for documentation.  It's shown in the mode line by
;; default, but there are a couple of packages that will do other
;; things:
;;
;; https://repo.or.cz/eldoc-overlay.git

;; Seems okay, but at first glance the font colour makes it pretty
;; much unreadable.
;;
;; Toggle with: eldoc-overlay-mode
;; (use-package eldoc-overlay
;;   :ensure t
;;   :delight eldoc-overlay-mode
;;   :custom ((eldoc-overlay-backend 'inline-docs)
;;            ;; (eldoc-overlay-delay 3)
;;            )
;;   :custom-face (inline-docs-border-face ((t (:family "DejaVu Sans Mono"))))
;;   :hook (eldoc-mode . eldoc-overlay-mode))

;; eldoc-box
;;
;; toggle with: eldoc-box-hover-mode
;; (but also eldoc-box-hover-at-point-mode, eldoc-box-help-at-point)
(use-package eldoc-box
  :ensure t)
(add-hook 'eglot-managed-mode-hook #'eldoc-box-hover-mode t)

;; https://lists.gnu.org/archive/html/emacs-devel/2023-02/msg00841.html
(add-hook 'eglot-managed-mode-hook #'eglot-inlay-hints-mode)

(provide 'x-hugh-eglot)
;;; x-hugh-eglot.el ends here
