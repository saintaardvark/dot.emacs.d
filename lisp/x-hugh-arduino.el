;;; x-hugh-arduino --- stuff related to arduino work

;;; Commentary:

;;; Code:

(use-package arduino-mode
  :ensure t
  ;;; Sigh, not sure what's going on here
  ;;; :config (c-toggle-comment-style -1)
  )

(use-package arduino-cli-mode
  :ensure t)

(provide 'x-hugh-arduino)
;;; x-hugh-arduino.el ends here
