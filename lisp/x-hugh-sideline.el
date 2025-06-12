;;; x-hugh-eglot: configure eglot

;;; Commentary: Not enabled yet; package looks cool, but having
;;; problems getting this to work with Eglot (probably because of
;;; conflicts with box).
;;;
;;; Site: https://github.com/emacs-sideline/sideline

;;; Code:


(use-package sideline-lsp
  :ensure t)
(use-package sideline-eglot
  :ensure t)
(use-package sideline-flycheck
  :ensure t)

(use-package sideline
  :ensure t
  :init
  (setq sideline-backends-left-skip-current-line t   ; don't display on current line (left)
        sideline-backends-right-skip-current-line t  ; don't display on current line (right)
        sideline-order-left 'down                    ; or 'up
        sideline-order-right 'up                     ; or 'down
        sideline-format-left "%s   "                 ; format for left aligment
        sideline-format-right "   %s"                ; format for right aligment
        sideline-priority 100                        ; overlays' priority
        sideline-display-backend-name t ; display the backend name
	sideline-backends-right '((sideline-lsp      . up)
				  (sideline-eglot    . up)
                                  (sideline-flycheck . down)))
  )

(provide 'x-hugh-sideline)
;;; x-hugh-sideline.el ends here
