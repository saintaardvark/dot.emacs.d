;;; -*- lexical-binding: t -*-
;; x-hugh-compile --- Compile stuff

;;; Commentary:
;; Commentary goes here.

;;; Code:

;; code goes her

(use-package ansi-color
  :custom (add-hook 'compilation-filter-hook 'my-colorize-compilation-buffer))

;; FIXME: Pretty sure there's a better way to add hooks here...
(defun my-colorize-compilation-buffer ()
  "Enable ANSI colourization in compilation buffers.

Source: https://stackoverflow.com/questions/13397737/ansi-coloring-in-compilation-mode/20788581#20788581"
  (when (eq major-mode 'compilation-mode)
    (ansi-color-apply-on-region compilation-filter-start (point-max))))

(use-package compile
  :custom (compilation-scroll-output 'first-error))

(provide 'x-hugh-compile-mode)
;;; x-hugh-compile.el ends here
