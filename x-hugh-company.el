;;; x-hugh-company --- Company-mode and auto-complete-mode

;;; Commentary:

;;; Code:


(require 'company)
(company-quickhelp-mode 1)
;; Needed for the ac-complete stuff up ahead
;; Also needed for go-autocomplet in x-hugh-golang
(require 'auto-complete-config)
(ac-config-default)

;; See https://www.reddit.com/r/emacs/comments/3s3hdf/change_companymode_selectaccept_action_keybinding/
(eval-after-load 'company
  '(progn
     (define-key ac-completing-map "\t" 'ac-complete)
     (define-key ac-completing-map "\r" 'ac-complete)
     (define-key company-active-map (kbd "C-n") #'company-select-next)
     (define-key company-active-map (kbd "C-p") #'company-select-previous)
     (define-key company-mode-map (kbd "C-:") 'helm-company)
     (define-key company-active-map (kbd "C-:") 'helm-company)
     (define-key company-active-map (kbd "C-c h") #'company-quickhelp-manual-begin)))

(provide 'x-hugh-company)
;;; x-hugh-company ends here
