;;; x-hugh-helm --- My helm stuff

;;; Commentary:
;;; Break out all helm stuff into one place.

;;; Code:
(if (eq window-system nil)
    (setq x-hugh-helm-enabled nil)
  (setq x-hugh-helm-enabled t))

(if x-hugh-helm-enabled
    (progn
      (require 'helm-config   nil 'noerror)
      (helm-mode 1)
      (global-set-key (kbd "M-x")     'helm-M-x)
      (global-set-key (kbd "M-y")     'helm-show-kill-ring)
      (global-set-key (kbd "C-x b")   'helm-mini)
      (global-set-key (kbd "C-x C-f") 'helm-find-files)
      (setq helm-ff-newfile-prompt-p nil)))

(provide 'x-hugh-helm)
;;; x-hugh-helm.el ends here
