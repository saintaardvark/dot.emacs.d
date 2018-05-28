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
  "Adjust font size based on screen resolution.  Takes optional argument FRAME."
  (interactive)
  (let ((target (or frame (window-frame))))
    (set-frame-parameter target 'font (fontify-frame-appropriate-font))))

(defun fontify-frame-appropriate-font ()
  "Return the appropriate font for displays."
  (interactive)
  (cond ((fontify-frame-screen-res-retina-p) "Inconsolata-18")
        ((fontify-frame-screen-res-high-enough-p) "Inconsolata-14")
        ((fontify-frame-screen-tiny-laptop-p) "Inconsolata-12")))

(defun fontify-frame-screen-res-retina-p ()
  "Detect retina display."
  (and
   (>= (display-pixel-height) 1200)
   (>= (display-pixel-width) 1920)))

(defun fontify-frame-screen-res-high-enough-p ()
  "Function to decide if the screen resolution is high enough."
  (or
   (> (display-pixel-height) 800)
   (> (display-pixel-width) 1900)))

(defun fontify-frame-screen-tiny-laptop-p ()
  "Function to decide if the screen resolution is that of a tiny laptop."
  (or
   (< (display-pixel-height) 800)
   (< (display-pixel-width) 1400)))

;; Only if Emacs >= 24.4
(if window-system
    (progn
      (scroll-bar-mode -1)
      ;; Fontify current frame (so that it happens on startup; may be unnecessary if you use focus-in-hook)
      (fontify-frame)
      ;; maximize-frame gone in 26
      ;; (maximize-frame)))
      (toggle-frame-maximized)))


(provide 'x-hugh-appearance)
;;; x-hugh-appearance ends here
