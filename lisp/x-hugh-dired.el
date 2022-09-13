;; x-hugh-dired --- Dired stuff

;;; Commentary:
;; Commentary goes here.

;;; Code:

;; code goes here

(use-package dired
  :custom ((dired-dwim-target t)
	   (dired-recursive-copies 'always)
	   (dired-recursive-deletes 'top)))

;; TODO: Use dired-git-info
(use-package dired-git-info
  :ensure t
  :config (define-key dired-mode-map ")" 'dired-git-info-mode))

(provide 'x-hugh-dired)
;;; x-hugh-template.el ends here
