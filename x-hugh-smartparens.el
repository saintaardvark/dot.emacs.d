;; x-hugh-smartparens --- smartparens settings

;;; Commentary:

;;; Code:

;; smartparens
(add-hook 'emacs-lisp-mode-hook #'smartparens-mode)
(add-hook 'json-mode-hook #'smartparens-mode)
(add-hook 'ruby-mode-hook #'smartparens-mode)
(add-hook 'python-mode-hook #'smartparens-mode)
(add-hook 'shell-mode-hook #'smartparens-mode)
(add-hook 'yaml-mode-hook #'smartparens-mode)
(add-hook 'toml-mode-hook #'smartparens-mode)
(add-hook 'go-mode-hook #'smartparens-mode)

(provide 'x-hugh-smartparens)
;;; x-hugh-smartparens ends here
