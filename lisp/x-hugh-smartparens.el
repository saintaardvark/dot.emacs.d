;; x-hugh-smartparens --- smartparens settings

;;; Commentary:

;;; Code:

(defun x-hugh-create-newline-and-enter-sexp (&rest _ignored)
  "Open a new brace or bracket expression, with relevant newlines and indent."
  (newline)
  (indent-according-to-mode)
  (forward-line -1)
  (indent-according-to-mode))

;; This is the package that enables showing matching parens.
;; FIXME: it *may* be necessary to enable this package before
;; smartparens.
(use-package mic-paren
  :ensure t
  :config (paren-activate))

;; NOTE: shell *scripting* mode is "sh-mode"; the docstring for
;; shell-script-mode says "shell-script-mode is an alias for ‘sh-mode’
;; in ‘sh-script.el’."  The thing to keep in mind is that the *hook*
;; for this mode is "sh-mode-hook".  See x-hugh-smartparens.el for
;; where that proper name is used to ensure that smartparens is turned
;; on in this mode.
(use-package smartparens
  :ensure t
  :custom (sp-navigate-close-if-unbalanced t)
  :hook (
	 (prog-mode . smartparens-mode)
	 (emacs-lisp-mode . smartparens-mode)
	 (arduino-mode . smartparens-mode)
	 (bats-mode . smartparens-mode)
	 (emacs-lisp-mode . smartparens-mode)
	 (groovy-mode . smartparens-mode)
	 (inferior-python-mode . smartparens-mode)
	 (javascript-mode . smartparens-mode)
	 (jinja2-mode . smartparens-mode)
	 (json-mode . smartparens-mode)
	 (markdown-mode . smartparens-mode)
	 (org-mode . smartparens-mode)
	 (ruby-mode . smartparens-mode)
	 (python-mode . smartparens-mode)
	 (sh-mode . smartparens-mode)
	 (shell-mode . smartparens-mode)
	 (terraform-mode . smartparens-mode)
	 (text-mode . smartparens-mode)
	 (tide-mode . smartparens-mode)
	 (toml-mode . smartparens-mode)
	 (yaml-mode . smartparens-mode)
	 )
  :config (progn
	    ;; See https://github.com/Fuco1/smartparens/wiki/Permissions
	    (sp-local-pair 'prog-mode "{" nil :post-handlers '((x-hugh-create-newline-and-enter-sexp "RET")))
	    (sp-local-pair 'prog-mode "(" nil :post-handlers '((x-hugh-create-newline-and-enter-sexp "RET")))))

(provide 'x-hugh-smartparens)
;;; x-hugh-smartparens.el ends here
