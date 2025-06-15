;;; -*- lexical-binding: t -*-
;; x-hugh-tramp --- Tramp stuff

;;; Commentary:
;; Commentary goes here.

;;; Code:

;; Use scp for tramp.
(use-package tramp
  :config
  (setq tramp-default-method "scp"))

(provide 'x-hugh-tramp)
;;; x-hugh-tramp.el ends here
