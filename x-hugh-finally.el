;; Startup

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
;; Lastly, like fortune:
(totd)


(provide 'x-hugh-finally)

;;; x-hugh-finally.el ends here
