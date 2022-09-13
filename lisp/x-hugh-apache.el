;; x-hugh-apache ---  Apache fundtions

;;; Commentary:
;; Apache stuff

;;; Code:

;; code goes here

(use-package apache-mode
  :mode (("\\.htaccess\\'" . apache-mode)
         ("httpd\\.conf\\'"  . apache-mode)
         ("srm\\.conf\\'"    . apache-mode)
         ("access\\.conf\\'" . apache-mode)
         ("sites-\\(available\\|enabled\\)/" . apache-mode)))

(provide 'x-hugh-apache)
;;; x-hugh-apache.el ends here
