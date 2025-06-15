;;; -*- lexical-binding: t -*-
;;; x-hugh-docker --- Docker stuff

;;; Commentary:

;;; Code:

(use-package dockerfile-mode
  ;; Use spaces when indenting in dockerfile-mode
  ;; TODO: This may be better as a directory variable.
  :config (add-hook 'dockerfile-mode-hook (lambda () (setq indent-tabs-mode nil)))
  :ensure t)

(provide 'x-hugh-docker)

;;; x-hugh-docker.el ends here
