;;; -*- lexical-binding: t -*-
;; x-hugh-flycheck --- Flycheck stuff

;;; Commentary:
;; Commentary goes here.

;;; Code:

;; code goes here

(use-package flycheck
  :ensure t
  ;; :config (add-hook 'after-init-hook #'global-flycheck-mode)
  :custom ((flycheck-check-syntax-automatically (quote (save idle-change)))
           (flycheck-flake8-maximum-line-length 9990)
           (flycheck-idle-change-delay 2)
           (flycheck-keymap-prefix ".")))

(use-package flycheck-eglot
  :ensure t)

(provide 'x-hugh-flycheck)
;;; x-hugh-flycheck.el ends here
