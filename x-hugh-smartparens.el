;; x-hugh-smartparens --- smartparens settings

;;; Commentary:

;;; Code:

(defmacro x-hugh-sp-add-hook-to-modes (modes)
  "Ensure that smart-parens mode is added to each of (MODES) mode-hook."
  (dolist (mode modes)
    (let ((hooksymbol (intern (concat mode "-mode-hook"))))
      (add-hook hooksymbol #'smartparens-mode))))

(defun x-hugh-create-newline-and-enter-sexp (&rest _ignored)
  "Open a new brace or bracket expression, with relevant newlines and indent."
  (newline)
  (indent-according-to-mode)
  (forward-line -1)
  (indent-according-to-mode))

(use-package smartparens
  :config (progn (x-hugh-sp-add-hook-to-modes ("arduino"
                                               "bats"
                                               "emacs-lisp"
                                               "go"
                                               "groovy"
                                               "javascript"
                                               "jinja2"
                                               "json"
                                               "markdown"
                                               "ruby"
                                               "python"
                                               "shell"
                                               "shell-script"
                                               "terraform"
                                               "toml"
                                               "yaml"))
                 ;; See https://github.com/Fuco1/smartparens/wiki/Permissions
                 (sp-local-pair 'go-mode "{" nil :post-handlers '((x-hugh-create-newline-and-enter-sexp "RET")))
                 (sp-local-pair 'go-mode "(" nil :post-handlers '((x-hugh-create-newline-and-enter-sexp "RET")))))

(provide 'x-hugh-smartparens)
;;; x-hugh-smartparens ends here
