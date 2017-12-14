;;; x-hugh-yasnippet --- Provide yasnippet

;;; Commentary:

;;; Code:
(require 'yasnippet nil 'noerror)
(yas-global-mode 1)

(let ((snippetsdir (file-truename "~/.emacs.d/snippets")))
  (if (file-exists-p snippetsdir)
    (yas-load-directory snippetsdir)))

;; https://emacs.stackexchange.com/questions/10431/get-company-to-show-suggestions-for-yasnippet-names
;; Add yasnippet support for all company backends
;; https://github.com/syl20bnr/spacemacs/pull/179
(defvar company-mode/enable-yas t
  "Enable yasnippet for all backends.")

(defun company-mode/backend-with-yas (backend)
  "Define a company BACKEND for yasnippets."
  (if (or (not company-mode/enable-yas) (and (listp backend) (member 'company-yasnippet backend)))
      backend
    (append (if (consp backend) backend (list backend))
            '(:with company-yasnippet))))

(setq company-backends (mapcar #'company-mode/backend-with-yas company-backends))

(provide 'x-hugh-yasnippet)
;;; x-hugh-yasnippet ends here
