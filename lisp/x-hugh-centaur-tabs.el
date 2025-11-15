;;; -*- lexical-binding: t -*-
;;; x-hugh-centaur-tabs --- stuff related to centaur-tabs 

;;; Commentary:

;;; Code:

;; Note: after running this for the first time, you'll need to run
;; M-x all-the-icons-install-fonts

(use-package all-the-icons
  :ensure t
  :if (display-graphic-p))

(use-package centaur-tabs
  :ensure t
  :demand
  :config
  (centaur-tabs-mode t)
  (centaur-tabs-style "chamfer")
  (centaur-tabs-set-icons t)
  (centaur-tabs-icon-type 'all-the-icons)
  (centaur-tabs-set-bar 'over)
  (centaur-tabs-group-by-projectile-project) ; 😮
  :bind
  ("C-<prior>" . centaur-tabs-backward)
  ("C-<next>" . centaur-tabs-forward))

;; OMG: centaur-tabs-ace-jump

(provide 'x-hugh-centaur-tabs)
;;; x-hugh-centaur-tabs.el ends here
