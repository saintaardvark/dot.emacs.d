;; x-hugh-appearance.el

;; Emacs appearance
(setq column-number-mode t
      display-time-24hr-format t
      display-time-and-date t)
(display-time)
(menu-bar-mode -1)
(tool-bar-mode -1)
(if window-system
    (progn
      (scroll-bar-mode -1)
      (require 'color-theme nil 'noerror)

      ;; In color-theme.el
      (require 'generic-x))
  ())
;; Only works in X mode, sadly...see .bashrc for a commented-out line
;; that'll turn off blinking in a linux terminal.
(blink-cursor-mode -1)
;; Begone!
(setq inhibit-splash-screen t)

(if window-system
      (set-default-font "Inconsolata-12")
  ())

(defun x-hugh-set-font-smaller ()
  "Set font to 12 point.  FIXME: Make this something like ctrl-shift-+/- in FF."
  (interactive)
  (set-default-font "Inconsolata-12"))


(provide 'x-hugh-appearance)
