;;; -*- lexical-binding: t -*-
;;; x-hugh-m-x -- Settings for m-x key

;;; Commentary:

;;; Code:

;; Unbind M-x and use C-x C-m or C-c C-m instead.
;; Thank you, Steve Yegge.
;;
;; Note: These will be overridden in x-hugh-helm.el...but only if that
;; package is successfully loaded.  I've had times where it isn't.
;; (global-unset-key "\M-x")

(provide 'x-hugh-m-x)
;;; x-hugh-m-x.el ends here
