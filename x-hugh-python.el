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
  :custom (highlight-indent-guides-method 'character)
  :config (add-hook 'prog-mode-hook 'highlight-indent-guides-mode))

(use-package python
  :custom (python-indent-guess-indent-offset t))

(provide 'x-hugh-python)
;;; x-hugh-python ends here
