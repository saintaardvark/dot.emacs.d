;;; x-hugh-company --- Company-mode and auto-complete-mode

;;; Commentary:

;;; Code:


(use-package company
  :ensure t
  :config (progn
            ;; See https://www.reddit.com/r/emacs/comments/3s3hdf/change_companymode_selectaccept_action_keybinding/
            (eval-after-load 'company
              '(progn
                 (define-key company-active-map (kbd "C-n") #'company-select-next)
                 (define-key company-active-map (kbd "C-p") #'company-select-previous)
                 (define-key company-mode-map (kbd "C-:") 'helm-company)
                 (define-key company-active-map (kbd "C-:") 'helm-company))))
  )

(add-hook 'after-init-hook 'global-company-mode)

(provide 'x-hugh-company)
;;; x-hugh-company.el ends here
