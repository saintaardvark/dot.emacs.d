;;; x-hugh-terraform --- stuff related to terraform

;;; Commentary:

;;; Code:

(use-package terraform-mode
  :ensure t
  :config (add-hook 'terraform-mode-hook  #'terraform-format-on-save-mode)
)

(provide 'x-hugh-terraform)
;;; x-hugh-terraform ends here
