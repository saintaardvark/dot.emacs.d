;;; x-hugh-m-x -- Settings for m-x key

;;; Commentary:

;;; Code:

;; Unbind M-x and use C-x C-m or C-c C-m instead.
;; Thank you, Steve Yegge.
;;
;; Note: These will be overridden in x-hugh-helm.el...but only if that
;; package is successfully loaded.  I've had times where it isn't.
(global-set-key "\C-x\C-m" 'execute-extended-command)
(global-set-key "\C-c\C-m" 'execute-extended-command)
(global-set-key "\C-x\m" 'execute-extended-command) 	; Do I need to compose email within Emacs? No, I do not.
;; (global-unset-key "\M-x")

(provide 'x-hugh-m-x)
;;; x-hugh-m-x.el ends here
