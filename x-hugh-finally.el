;;; x-hugh-finally.el --- last thing before starting

;;; Commentary:
;;; Finally!

;;; Code:

(quietly-read-abbrev-file)
(server-start)
;; Chrome extension
;; (require 'edit-server)
;; (edit-server-start)
(setq major-mode 'text-mode)
;; (wg-load "~/.emacs_workgroups")

;; start in home directory instead of root
(cd "~")

;; Lastly, like fortune:
(totd)

(provide 'x-hugh-finally)
;;; x-hugh-finally.el ends here
