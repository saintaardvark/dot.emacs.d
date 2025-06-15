;;; -*- lexical-binding: t -*-
;;; x-hugh-html --- stuff related to html editing

;;; Commentary:

;;; Code:

;; Was trying this...
;; (use-package multi-web-mode
;;   :ensure t
;;   :custom ((mweb-default-major-mode 'html-mode)
;; 	   (mweb-tags  '((php-mode "<\\?php\\|<\\? \\|<\\?=" "\\?>")
;; 			 (js-mode  "<script[^>]*>" "</script>")
;; 			 (css-mode "<style[^>]*>" "</style>")))
;; 	   (mweb-filename-extensions '("php" "htm" "html" "ctp" "phtml" "php4" "php5"))
;; 	   (multi-web-global-mode 1)))

;; ...and going to try this now:
(use-package web-mode
  :ensure t)

(use-package web-narrow-mode
  :ensure t)

;; Not *exactly* webby, but...

(defun x-hugh-open-in-firefox ()
  "Open URL at point in Firefox."
  (interactive)
  (shell-command (format "firefox %s" (thing-at-point 'url))))

(defun x-hugh-open-in-chrome ()
  "Open URL at point in Chrome."
  (interactive)
  (shell-command (format "/opt/google/chrome/chrome %s" (thing-at-point 'url))))

(provide 'x-hugh-html)
;;; x-hugh-html.el ends here
