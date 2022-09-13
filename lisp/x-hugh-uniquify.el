;; x-hugh-uniquify --- Uniquify stuff

;;; Commentary:
;; Commentary goes here.

;;; Code:

;; code goes here
(use-package uniquify
  :custom ((uniquify-buffer-name-style 'post-forward nil (uniquify))
           (uniquify-min-dir-content 2)))

(provide 'x-hugh-uniquify)
;;; x-hugh-uniquify.el ends here

