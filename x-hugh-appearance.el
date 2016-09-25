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

;; From https://gist.github.com/MatthewDarling/8c232b1780126275c3b4
;; Based on http://arnab-deka.com/posts/2012/09/emacs-change-fonts-dynamically-based-on-screen-resolution/
(defun fontify-frame (&optional frame)
  "Adjust font size based on screen resolution. Takes optional argument FRAME."
  (interactive)
  (let ((target (or frame (window-frame))))
    (if window-system
        (if (fontify-frame-screen-res-high-enough-p)
            (set-frame-parameter target 'font "Inconsolata-16")
          (set-frame-parameter target 'font "Inconsolata-18")))))

(defun fontify-frame-screen-res-high-enough-p ()
  "Function to decide if the screen resolution is high enough."
  (or
   (> (frame-pixel-height) 2000)
   (> (frame-pixel-width) 2000)))

;; Fontify current frame (so that it happens on startup; may be unnecessary if you use focus-in-hook)
(fontify-frame)

;; Only if Emacs >= 24.4
(add-hook 'focus-in-hook 'fontify-frame)

(provide 'x-hugh-appearance)
;;; x-hugh-appearance ends here.
