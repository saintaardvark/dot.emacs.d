;;; -*- lexical-binding: t -*-
;; x-hugh-midnight-mode --- Midnight-Mode stuff

;;; Commentary:
;; Commentary goes here.

;;; Code:

(use-package midnight
  :custom ((midnight-mode t)
           (clean-buffer-list-delay-general 1)
           (clean-buffer-list-kill-never-buffer-names
	    (quote ("*scratch*" "*Messages*" "*server*" ".\\*\\.org$")))))

(provide 'x-hugh-midnight-mode)
;;; x-hugh-midnight-mode.el ends here
