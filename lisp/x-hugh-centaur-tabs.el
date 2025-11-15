;;; -*- lexical-binding: t -*-
;;; x-hugh-centaur-tabs --- stuff related to centaur-tabs 

;;; Commentary:

;;; Code:

(use-package centaur-tabs
  :ensure t
  :demand
  :config
  (centaur-tabs-mode t)
  :bind
  ("C-<prior>" . centaur-tabs-backward)
  ("C-<next>" . centaur-tabs-forward))

;; The "demand" setting up above delays loading of some symbols, IIUC.
;; Instead of putting them in the :config secion, I'm breaking out to
;; separate setq calls.
(setq centaur-tabs-style "chamfer")
(setq centaur-tabs-set-icons t)
(setq centaur-tabs-icon-type 'all-the-icons)
(setq centaur-tabs-set-bar 'over)
(setq centaur-tabs-group-by-projectile-project t) ; 😮

;; OMG: centaur-tabs-ace-jump.  Added to hydra.

(provide 'x-hugh-centaur-tabs)
;;; x-hugh-centaur-tabs.el ends here
