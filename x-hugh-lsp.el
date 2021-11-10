;;; x-hugh-lsp --- stuff related to lsp

;;; Commentary:

;;; Code:

(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :hook (go-mode . lsp-deferred)
  :config (add-hook 'go-mode-hook #'lsp-deferred)
  :custom ((lsp-gopls-staticcheck t)
	   (lsp-eldoc-render-all t)
	   ;; (lsp-gopls-complete-unimported)
  ))

;; FIXME: lsp is trying to install deps automagically -- which is
;; great, except that streamline-ssh *should* be iimported as
;; "streamline_ssh" (note the underscore); gopls doesn't do that, and
;; so here we are.

;; FIXME: One of the enabled flycheck checkers is having problems with
;; imports, and I think it's lsp -- disabling this (C-c . v, then pick
;; another checker) resolves the problem.

;; Set up before-save hooks to format buffer and add/delete imports.
;; Make sure you don't have other gofmt/goimports hooks enabled.
(defun lsp-go-install-save-hooks ()
  "Install correct hooks for lsp go."
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'go-mode-hook #'lsp-go-install-save-hooks)

(provide 'x-hugh-lsp)
;;; x-hugh-lsp ends here
