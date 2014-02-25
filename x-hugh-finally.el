;; Startup

(quietly-read-abbrev-file)
(server-start)
(setq default-major-mode 'text-mode)
(wg-load "~/.emacs.d/workgroups_save.el")
;; Lastly, like fortune:
(totd)


(provide 'x-hugh-finally)
