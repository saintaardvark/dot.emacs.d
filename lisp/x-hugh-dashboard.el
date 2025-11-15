;;; -*- lexical-binding: t -*-
;;; x-hugh-dashboard --- stuff related to dashboard 

;;; Commentary:

;;; Code:



;; use-package with package.el:
(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook))

;; Another case where setq seems necessary insted of :config 
(setq dashboard-show-shortcuts nil)
(setq dashboard-center-content t)
(setq dashboard-vertically-center-content t)
(setq dashboard-items '((recents   . 5)
                        (bookmarks . 5)
                        (projects  . 5)
                        (registers . 5)))

(setq dashboard-icon-type 'all-the-icons)
(setq dashboard-set-heading-icons t)
(setq dashboard-set-file-icons t)

(provide 'x-hugh-dashboard)
;;; x-hugh-dashboard.el ends here
