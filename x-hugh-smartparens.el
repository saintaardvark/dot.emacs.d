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

;; NOTE: shell *scripting* mode is "sh-mode"; the docstring for
;; shell-script-mode says "shell-script-mode is an alias for ‘sh-mode’
;; in ‘sh-script.el’."  The thing to keep in mind is that the *hook*
;; for this mode is "sh-mode-hook".  See x-hugh-smartparens.el for
;; where that proper name is used to ensure that smartparens is turned
;; on in this mode.
(use-package smartparens
  :custom (sp-navigate-close-if-unbalanced t)
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
					       "sh"
                                               "shell"
                                               "terraform"
                                               "toml"
                                               "yaml"))
                 ;; See https://github.com/Fuco1/smartparens/wiki/Permissions
                 (sp-local-pair 'go-mode "{" nil :post-handlers '((x-hugh-create-newline-and-enter-sexp "RET")))
                 (sp-local-pair 'go-mode "(" nil :post-handlers '((x-hugh-create-newline-and-enter-sexp "RET")))))

(provide 'x-hugh-smartparens)
;;; x-hugh-smartparens ends here
