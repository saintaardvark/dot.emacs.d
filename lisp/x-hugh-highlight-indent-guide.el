;; x-hugh-highlight-indent-guide --- Highlight-Indent-Guide stuff

;;; Commentary:
;; Commentary goes here.

;;; Code:

(use-package highlight-indent-guides
  :ensure t
  :custom (highlight-indent-guides-method 'character)
  :config (add-hook 'prog-mode-hook 'highlight-indent-guides-mode))

(provide 'x-hugh-highlight-indent-guide)
;;; x-hugh-highlight-indent-guide.el ends here
