;; Startup

(quietly-read-abbrev-file)
(server-start)
(setq default-major-mode 'text-mode)

;; Lastly, like fortune:
(totd)


(provide 'x-hugh-startup)

