;;; x-hugh-eglot: configure eglot

;;; Commentary:

;;; Code:

(use-package eglot
  :ensure t
  :defer t
  :hook (python-mode . eglot-ensure))

(provide 'x-hugh-eglot)
;;; x-hugh-eglot.el ends here
