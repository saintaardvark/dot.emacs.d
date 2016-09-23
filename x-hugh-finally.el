;;; x-hugh-finally.el --- last thing before starting

;;; Commentary:
;;; Finally!

;;; Code:

(quietly-read-abbrev-file)
(server-start)
;; Chrome extension
;; (require 'edit-server)
;; (edit-server-start)
(setq default-major-mode 'text-mode)
;; (wg-load "~/.emacs_workgroups")
(if window-system
      (scroll-bar-mode -1)
  ())
(workgroups-mode 1)
;; start in home directory instead of root
(cd "~")

;; As in x-hugh-erc.el: I've moved to Weechat, but I'll keep this here
;; for reference.
;; (erc :server "irc.freenode.net")

; Lastly, like fortune:
(totd)

(provide 'x-hugh-finally)

;;; x-hugh-finally.el ends here
