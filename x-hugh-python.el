;; x-hugh-python --- Python stuff

;;; Commentary:
;; Required packages and their settings.

;;; Code:

(use-package elpy
  :config (elpy-enable))
;; I like this better than highlight-indentation-mode.
;; highlight-indentation is set as part of elpy-modules; that's in
;; x-hugh-custom.

(use-package highlight-indent-guides
  :custom (highlight-indent-guides-method 'character))

;; I'm not liking how this looks
;; :config (add-hook 'prog-mode-hook 'highlight-indent-guides-mode))

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
  :custom (python-indent-guess-indent-offset t))

(provide 'x-hugh-python)
;;; x-hugh-python ends here
