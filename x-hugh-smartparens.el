;; x-hugh-smartparens --- smartparens settings

;;; Commentary:

;;; Code:

;; FIXME: This should be made more generic:
;; (x-hugh-add-hook-to-modes "smartparens" ("this" "that" "the other" ...))

(require 'smartparens)

(defmacro x-hugh-sp-add-hook-to-modes (modes)
  "Ensure that smart-parens mode is added to each of (MODES) mode-hook."
  (dolist (mode modes)
    (let ((hooksymbol (intern (concat mode "-mode-hook"))))
      (add-hook hooksymbol #'smartparens-mode))))

(x-hugh-sp-add-hook-to-modes ("bats"
                              "emacs-lisp"
                              "go"
                              "groovy"
                              "jinja2"
                              "json"
                              "markdown"
                              "ruby"
                              "python"
                              "shell"
                              "terraform"
                              "toml"
                              "yaml"))

;; See https://github.com/Fuco1/smartparens/wiki/Permissions
(sp-local-pair 'go-mode "{" nil :post-handlers '((x-hugh-create-newline-and-enter-sexp "RET")))
(sp-local-pair 'go-mode "(" nil :post-handlers '((x-hugh-create-newline-and-enter-sexp "RET")))
(defun x-hugh-create-newline-and-enter-sexp (&rest _ignored)
  "Open a new brace or bracket expression, with relevant newlines and indent."
  (newline)
  (indent-according-to-mode)
  (forward-line -1)
  (indent-according-to-mode))

(provide 'x-hugh-smartparens)
;;; x-hugh-smartparens ends here
