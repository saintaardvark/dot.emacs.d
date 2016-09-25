;;; x-hugh-yasnippet --- Provide yasnippet

;;; Commentary:

;;; Code:
(require 'yasnippet nil 'noerror)
(yas-global-mode 1)

(let ((snippetsdir (file-truename "~/.emacs.d/snippets")))
  (if (file-exists-p snippetsdir)
    (yas-load-directory snippetsdir)))

(provide 'x-hugh-yasnippet)
;;; x-hugh-yasnippet ends here
