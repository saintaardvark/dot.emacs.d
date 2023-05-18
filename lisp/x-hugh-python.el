;; x-hugh-python --- Python stuff

;;; Commentary:
;; Required packages and their settings.

;;; Code:

;; FIXME: Turn off auto-complete & auto-composition in *at least*
;; Python, possibly all modes.
;;
;; FIXME: elpy is giving lots of errors on my laptop when I start it
;; up; will dig into it later, but disabling it for now.
;; (use-package elpy
;;   :ensure t
;;   ;; The default list, but minus highlight-indentation.
;;   ;; Giving highlight-indentationo-guides a try.
;;   :custom (elpy-modules '(elpy-module-sane-defaults
;; 			  elpy-module-company
;; 			  elpy-module-eldoc
;; 			  elpy-module-pyvenv
;; 			  elpy-module-yasnippet
;; 			  elpy-module-django))
;;   :config (elpy-enable))

;; FIXME: Why is this here?
(use-package dash
  :ensure t)
(dash-unload-function)

;; And what's this?
(-map (lambda (num) (* num num)) '(1 2 3 4))
(funcall (-compose #'- #'1+ #'+) 1 2 3)

(use-package lsp-pyright
  :ensure t
  :hook (python-mode . (lambda ()
			 (require 'lsp-pyright)
			 (lsp)))) 	;or lsp-deferred

;; FIXME: Should move highlight-indent-guides to another file
(use-package highlight-indent-guides
  :ensure t
  ;; :hook (prog-mode . (lambda ()
  ;; 		       (highlight-indents-guide-mode)))
  )

(use-package python
  :custom ((python-indent-guess-indent-offset nil) ; Had been t, but
						   ; this was causing
						   ; problems for me.
	   (python-shell-interpreter "python3"))
  )

(use-package python-black
  :demand t
  :after python
  :ensure t
  :hook (python-mode . python-black-on-save-mode-enable-dwim)
  )

(setq x-hugh-default-conda-location "~/anaconda3")
(if (file-exists-p x-hugh-default-conda-location)
    (use-package conda
      :after python
      :ensure t
      :config
      (progn
	(setq conda-env-home-directory x-hugh-default-conda-location)
	;;get current environment--from environment variable CONDA_DEFAULT_ENV
	(conda-env-activate 'getenv "CONDA_DEFAULT_ENV")
	;;(conda-env-autoactivate-mode t)
	(setq-default mode-line-format (cons mode-line-format '(:exec conda-env-current-name))))))

(defun x-hugh-python-fixme ()
  "Insert my patented debugging string in Python."
  (interactive)
  (insert "print(\"[FIXME] \")")
  (backward-char 2))

(provide 'x-hugh-python)
;;; x-hugh-python.el ends here
