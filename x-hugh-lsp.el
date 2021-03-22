;;; x-hugh-lsp --- stuff related to lsp mode

;;; Commentary:

;;; Code:

(use-package lsp-mode
  :config
  (add-hook 'go-mode-hook #'lsp)
  (add-hook 'python-mode-hook #'lsp)
  (add-hook 'rust-mode-hook #'lsp))

(provide 'x-hugh-lsp)
;;; x-hugh-lsp ends here
