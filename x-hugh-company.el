;;; x-hugh-company --- stuff related to company-moden

;;; Commentary:

;;; Code:


(require 'company)
(eval-after-load 'company
  '(progn
     (define-key company-mode-map (kbd "C-:") 'helm-company)
     (define-key company-active-map (kbd "C-:") 'helm-company)))

(provide 'x-hugh-company)
;;; x-hugh-company ends here
