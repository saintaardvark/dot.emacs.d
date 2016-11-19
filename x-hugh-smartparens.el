;; x-hugh-smartparens --- smartparens settings

;;; Commentary:

;;; Code:

;; FIXME: This should be a list, not a sngle mode
(defmacro x-hugh-sp-add-hook-to-mode (mode)
  "Ensure that smart-parens mode is added to (MODE)-hook."
  (let ((hooksymbol (intern (concat mode "-mode-hook"))))
    `(add-hook ',hooksymbol #'smartparens-mode)
  ))

(x-hugh-sp-add-hook-to-mode "emacs-lisp")

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
