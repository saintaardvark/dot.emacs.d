;;; -*- lexical-binding: t -*-
;;; x-hugh-finally.el --- last thing before starting

;;; Commentary:
;;; Finally!

;;; Code:

(quietly-read-abbrev-file)
(server-start)
(setq major-mode 'text-mode)

;; On Zombie, emacs was hanging when it exited.  This turned out to be pcache.
;; I'm not sure what's adding it to kill-emacs-hook, but removing it seems
;; to fix this problem.  Someone else w/same problem here:
;; https://emacs.stackexchange.com/questions/51916/help-freeze-up-to-10-seconds-happening-on-windows-when-exiting-kill-emacs-w
;;
;; August 27, 2022
(remove-hook 'kill-emacs-hook 'pcache-kill-emacs-hook)

;; start in home directory instead of root
(cd "~")

;; Lastly, like fortune:
(totd)
(dashboard-open)

(provide 'x-hugh-finally)
;;; x-hugh-finally.el ends here
