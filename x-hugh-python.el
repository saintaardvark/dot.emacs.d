;; x-hugh-python --- Python stuff

;;; Commentary:
;; Required packages and their settings.

;;; Code:

;; FIXME: Turn off auto-complete & auto-composition in *at least*
;; Python, possibly all modes.
;; (use-package elpy
;;   ;; The default list, but minus highlight-indentation.
;;   ;; Giving highlight-indentationo-guides a try.
;;   :custom (elpy-modules '(elpy-module-sane-defaults
;; 			  elpy-module-company
;; 			  elpy-module-eldoc
;; 			  elpy-module-pyvenv
;; 			  elpy-module-yasnippet
;; 			  elpy-module-django))
;;   :config (elpy-enable))

(use-package dash
  :ensure t)
(dash-unload-function)

(-map (lambda (num) (* num num)) '(1 2 3 4))
(funcall (-compose #'- #'1+ #'+) 1 2 3)


(use-package lsp-pyright
  :ensure t
  :hook (python-mode . (lambda ()
			 (require 'lsp-pyright)
			 (lsp)))) 	;or lsp-deferred

(defun x-hugh-highlight-indentation-mode-toggle ()
  "Toggle whether highlight-indentation-mode is enabled.

If highlight-indentation-mode is bound (as in, it is a function)
and highlight-indentation-mode (the variable) is true, turn off;
else, turn on."
  (interactive)
  (if (and (boundp 'highlight-indentation-mode)
	   (eq highlight-indentation-mode t))
      (highlight-indentation-mode -1)
    (highlight-indentation-mode)))

(x-hugh-highlight-indentation-mode-toggle)

(use-package python
  :custom ((python-indent-guess-indent-offset t)
	   (python-shell-interpreter "python3"))
  )

(defun x-hugh-python-fixme ()
  "Insert my patented debugging string in Python."
  (interactive)
  (insert "print(\"[FIXME] \")")
  (backward-char 2))

(provide 'x-hugh-python)
;;; x-hugh-python ends here
