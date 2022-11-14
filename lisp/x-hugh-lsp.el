;;; x-hugh-lsp --- stuff related to lsp

;;; Commentary:

;;; Code:

;; TODO: Configure doc showing to not suck so much.  See
;; https://www.reddit.com/r/emacs/comments/fxqfs2/trouble_with_lspmode_and_eldoc/
;;
;; Quote:
;; When I leave my point within a function, its entire
;; docstring will show in my minibuffer potentially using up 50+% of
;; my screen. I've eventually figured that this is an eldoc feature,
;; but I can't seem to disable it in any way. I found this issue on
;; Github: https://github.com/emacs-lsp/lsp-mode/issues/443 , but it
;; seems that setting lsp-eldoc-render-all has no effect for me even
;; though it's nil. I also tried just disabling this feature by
;; setting lsp-eldoc-enable-hover to nil, but again no luck. I still
;; get the docstring in the minibuffer.
;;
;; One reply:
;; I have this on my config, hope it works.
;;
;; (setq
;;     lsp-signature-auto-activate t
;;     lsp-signature-doc-lines 1)
;;
;; Another: check lsp-signature-auto-activate and lsp-signature-render-documentation

(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :hook (go-mode . lsp-deferred)
  :config (add-hook 'go-mode-hook #'lsp-deferred)
  :custom ((lsp-gopls-staticcheck t)
	   (lsp-eldoc-render-all t)
	   ;; Adding this to try & get pyright to start in project
	   ;; directory, not in my home directory.  See
	   ;; https://github.com/emacs-lsp/lsp-pyright/issues/6.
	   ;; Note: not sure that this will do what I want; see
	   ;; settings at https://github.com/emacs-lsp/lsp-pyright,
	   ;; but also there are a few issues/unmerged PRs that
	   ;; suggest this package is not getting a lot of love. :-(
	   (lsp-auto-guess-root t)
	   ;; (lsp-gopls-complete-unimported)
  ))

(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode)

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
;;; x-hugh-lsp.el ends here
