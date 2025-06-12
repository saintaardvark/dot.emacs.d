;; x-hugh-python --- Python stuff

;;; Commentary:
;; Required packages and their settings.

;;; Code:

;; Reminder: for Python, run:
;;
;;     pip install --user 'python-lsp-server[all]'
;;
;; Alternatively, on Debian run:
;;
;;     sudo apt-get install -y '^python3-pylsp[a-z-]*$'

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
;;
;; Possibly useful reference:
;; - https://www.naiquev.in/understanding-emacs-packages-for-python.html
;; - https://github.com/naiquevin/emacs-config/blob/f30dba4beae7eee06aa11e0ca3775ebb2f4f6df8/config/python-config.el#L79

;; FIXME: Should move highlight-indent-guides to another file
(use-package highlight-indent-guides
  :ensure t
  ;; :hook (prog-mode . (lambda ()
  ;; 		       (highlight-indents-guide-mode)))
  )

(use-package rainbow-delimiters
  :ensure t)

(use-package python
  :ensure t
  :after (smartparens
	  rainbow-delimiters
	  flycheck-eglot
	  projectile)
  ;; Had been `t`, but this was causing problems for me.
  :custom ((python-indent-guess-indent-offset nil)
	   (python-shell-interpreter "python3"))

  ;; NOTE: I could not get this to work with conda.  I suspect I need to d

  ;; Jedi-language-server installable by "pip install -U jedi-language-server"
  ;; :config
  ;; (add-to-list 'eglot-server-programs
  ;;              `(python-mode . ("jedi-language-server"
  ;;                               ;; Set initial options to configure
  ;;                               ;; the active virtualenv (if any) as
  ;;                               ;; documented here -
  ;;                               ;; https://www.gnu.org/software/emacs/manual/html_mono/eglot.html#User_002dspecific-configuration
  ;;                               :initializationOptions
  ;;                               ,(lambda (s)
  ;;                                  (let ((ve (getenv "VIRTUAL_ENV")))
  ;;                                    (if ve
  ;;                                        `(:workspace (:environmentPath ,(concat ve "bin/python")))
  ;;                                      eglot-{}))))))
  )

;; Ruff server does not yet support going to definitions -- not great.
;; (add-hook 'python-mode-hook 'eglot-ensure)
;; (with-eval-after-load 'eglot
;;   (add-to-list 'eglot-server-programs
;;                '(python-mode . ("ruff" "server")))
;;   (add-hook 'after-save-hook 'eglot-format))

(use-package python-black
  :demand t
  :after python
  :ensure t
  :hook (python-mode . python-black-on-save-mode-enable-dwim)
  )

;; TODO: Break this out to a group var or some such
(setq x-hugh-default-conda-location "~/anaconda3")

(if (file-exists-p x-hugh-default-conda-location)
    (use-package conda
      :after python
      :ensure t
      :config
      (progn
	(setq conda-env-home-directory x-hugh-default-conda-location)
	;; Don't set default environment; I'll leave that for the hydra to take care of
	(setq-default mode-line-format (cons mode-line-format '(:exec conda-env-current-name))))))

(use-package ein
  :ensure t)

(defun x-hugh-python-fixme ()
  "Insert my patented debugging string in Python."
  (interactive)
  (insert "print(f\"[FIXME] \")")
  (backward-char 2))

;; https://fredrikmeyer.net/2020/08/26/emacs-python-venv.html
;;
;; > So my workflow is this: activate the virtual environment with M-x
;; > pyvenv-activate, experiment in a Python shell (started with C-c
;; > C-p), profit.
;;
;; Note: this *also* works for running python-lsp-server!
;;
;; So what I can do is:
;;
;; M-x pyvenv-activate   -> point at .venv in project root
;;  -- **NOTE:** Now taken care of by pyvenv-autoload
;; open python file
;; M-x eglot
;; and now imports are resolved! 🥳

;; TODO: There's a set of dependencies I haven't quite optimized yet:
;;
;; - pyvenv
;;   - the pyvenv-post-activate-hooks
;; - pyenv-autoload
;;
;; The sequence right now is:
;; - open a python file in a project
;; - pyvenv-autoload triggers
;; - which tries to pyvenv-activate a venv in the project root
;; - the pyvenv-post-activate-hook sets the python interpreter correctly
;; - and then we can run eglot
(use-package pyvenv
  :ensure t
  :config
  (pyvenv-mode t)

  ;; Set correct Python interpreter
  (setq pyvenv-post-activate-hooks
        (list (lambda ()
                (setq python-shell-interpreter (concat pyvenv-virtual-env "bin/python3"))
                (setq python-interpreter (concat pyvenv-virtual-env "bin/python3"))
		)))
  (setq pyvenv-post-deactivate-hooks
        (list (lambda ()
                (setq python-shell-interpreter "python3")
                (setq python-interpreter "python3")
		))))

(defun pyvenv-autoload ()
  "Function to automagically load a project venv."
  (interactive)
  (let* ((pdir (projectile-project-root))
	 (venvdir (concat pdir ".venv")))
    (if (file-exists-p venvdir)
        (pyvenv-activate venvdir))))

(add-hook 'python-ts-mode-hook 'pyvenv-autoload)
(add-hook 'python-ts-mode-hook 'eglot-ensure)

(provide 'x-hugh-python)
;;; x-hugh-python.el ends here
