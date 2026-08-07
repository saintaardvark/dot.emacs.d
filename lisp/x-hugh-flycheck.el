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
           ;; Dropped flycheck-flake8-maximum-line-length (was 9990, i.e.
           ;; "never warn on line length"): work switched to ruff, whose
           ;; default rule set (E4/E7/E9/F) excludes E501, so the knob is moot.
           (flycheck-idle-change-delay 2)
           (flycheck-keymap-prefix ".")))

(use-package flycheck-eglot
  :ensure t)

(provide 'x-hugh-flycheck)
;;; x-hugh-flycheck.el ends here
