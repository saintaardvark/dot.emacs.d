;;; -*- lexical-binding: t -*-
;; x-hugh-fixmee --- Fixmee stuff

;;; Commentary:
;; Commentary goes here.

;;; Code:

;; code goes here

;; button-lock is required for `fixmee` mode.
(use-package fixmee
  :ensure t
  :preface (use-package button-lock)
  :config (global-fixmee-mode))


(provide 'x-hugh-fixmee)
;;; x-hugh-fixmee.el ends here
