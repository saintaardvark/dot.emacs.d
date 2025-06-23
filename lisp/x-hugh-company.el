;;; -*- lexical-binding: t -*-
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

;; Remove/disable company mode in org, text, shell
(add-hook 'org-mode-hook (lambda() (company-mode 0)))
(add-hook 'text-mode-hook (lambda() (company-mode 0)))
(add-hook 'shell-mode-hook (lambda() (company-mode 0)))

;; But not org mode, text mode pls
;; https://stackoverflow.com/questions/34652692/how-to-turn-off-company-mode-in-org-mode
;; TODO: Make this more like my usual code
(defun jpk/org-mode-hook ()
  (company-mode -1))
(add-hook 'org-mode-hook #'jpk/org-mode-hook)

(use-package company-web
  :ensure t)

(provide 'x-hugh-company)
;;; x-hugh-company.el ends here
