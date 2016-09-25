;; x-hugh-appearance.el --- appearances are everything

;;; Commentary:

;;; Code:

;; Emacs appearance
(setq column-number-mode t
      display-time-24hr-format t
      display-time-and-date t)
(display-time)
(menu-bar-mode -1)
(tool-bar-mode -1)
;; Only works in X mode, sadly...see .bashrc for a commented-out line
;; that'll turn off blinking in a linux terminal.
(blink-cursor-mode -1)
;; Begone!
(setq inhibit-splash-screen t)

(defun x-hugh-am-i-at-work-p ()
  "Simple function meant to return 'yes' or 'no'."
  (interactive)
  "yes")

(defun x-hugh-default-font ()
  "Set default font depending on where I am."
  (if (x-hugh-am-i-at-work-p)
      "Inconsolata-14"
    "Inconsolata-12"))

(if window-system
    (progn
      (set-frame-font (x-hugh-default-font))
      (scroll-bar-mode -1))
  ())

(defun x-hugh-set-font-smaller ()
  "Set font to 12 point.  FIXME: Make this something like ctrl-shift-+/- in FF."
  (interactive)
  (set-default-font "Inconsolata-12"))
(defun x-hugh-set-font-larger ()
  "Set font to 16 point.  FIXME: Make this something like ctrl-shift-+/- in FF."
  (interactive)
  (set-default-font "Inconsolata-18"))
;; (require 'color-theme nil 'noerror)
;; (load-theme "solarized-dark" t)

;; Just make it larger...I always do this at startup anyhow.

(x-hugh-set-font-larger)

(defun x-hugh-set-appearance ()
  "Reload x-hugh-appearance.el."
  (interactive)
  (load-file "~/.emacs.d/x-hugh-appearance.el"))

(provide 'x-hugh-appearance)
;;; x-hugh-appearance ends here.
