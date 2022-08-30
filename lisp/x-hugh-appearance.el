;; x-hugh-appearance.el --- appearances are everything

;;; Commentary:

;;; Code:

;; Emacs appearance

;; Custom themes package

;; (require 'gruvbox-theme)

;; (use-package custom
;;   ;; Note: previously, I customzed the value of custom-safe-themes.
;;   ;; This holds sha256sums of themes that have been designated as
;;   ;; safe.  This is a PITA to update.  For now, I'm going to use the
;;   ;; no-confirm variant of load-theme, as shown above.
;;   :config (load-theme 'gruvbox-dark-hard "no-confirm"))

(use-package gruvbox-theme
  :ensure t
  :config
  (load-theme 'gruvbox-dark-hard "no-confirm")
  )

(use-package transpose-frame
  :ensure t)

;; (use-package emojify
;;   :config (global-emojify-mode))

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
  (set-frame-font "Inconsolata-12" t))

(defun x-hugh-set-font-larger ()
  "Set font to 16 point.  FIXME: Make this something like ctrl-shift-+/- in FF."
  (interactive)
  (set-frame-font "Inconsolata-16" t))

(defun x-hugh-set-font-largest ()
  "Set font to 20 point.  FIXME: Make this something like ctrl-shift-+/- in FF."
  (interactive)
  (set-frame-font "Inconsolata-20" t))

(defun x-hugh-set-font-zomg ()
  "Set font to 30 point.  FIXME: Make this something like ctrl-shift-+/- in FF."
  (interactive)
  (set-frame-font "Inconsolata-30" t))

;; Just make it larger...I always do this at startup anyhow.
;; FIXME / TODO: This is borking the display on Wayland.  For now I'm
;; disabling it, but it would be good to understand what's going on
;; here.
;;  (x-hugh-set-font-larger)

(defun x-hugh-set-appearance ()
  "Reload x-hugh-appearance.el."
  (interactive)
  (load-file "~/.emacs.d/x-hugh-appearance.el"))

;; FIXME: Refactor all this
;; FIXME: This needs to be broken out into a package

;; From https://gist.github.com/MatthewDarling/8c232b1780126275c3b4
;; Based on http://arnab-deka.com/posts/2012/09/emacs-change-fonts-dynamically-based-on-screen-resolution/

;; I appear to have lost x-hugh-appearance--font :-(
;; Trying to recreate it.

(defun x-hugh-appearance-experiment-get-font-size ()
  "Get font size for current frame.

That is, given a font of:

-*-Inconsolata-regular-normal-normal-*-16-*-*-*-m-0-iso10646-1

return 16."
  (interactive)
  (let ((current-font (frame-parameter nil 'font)))
    ;; You could imagine splitting that by dash; assuming there's a
    ;; zero-width zero index to the left of that first dash (ie, that
    ;; the first * is the first element), that makes the size the 7th
    ;; element.
    (string-to-number (nth 7 (split-string current-font (rx "-"))))))

(defun fontify-frame (target font)
  "Adjust font size based on screen resolution.  Takes argument target for frame and font."
  (interactive)
  (setq x-hugh-appearance--font font)
  (set-frame-parameter target 'font font))

(defun fontify-frame-appropriately (&optional frame)
  "Adjust font size to appropriate size.  Takes optional argument FRAME."
  (interactive)
  (let ((target (or frame (window-frame))))
    (fontify-frame target (fontify-frame-appropriate-font))))

(defun x-hugh-appearance-get-font-size ()
  "Return font size of x-hugh-appearance--font.

Assumes font named like `Inconsolata-14`."
  (interactive)
  ;; FIXME: Has to be a better way to do this
  (string-to-number (car (cdr (split-string x-hugh-appearance--font "-")))))

(defun x-hugh-appearance-get-larger-font-size ()
  "Return string with current font, but size increased by one."
  (interactive)
  (let ((biggersize (+ 1 (x-hugh-appearance-experiment-get-font-size))))
    (format "Inconsolata-%d" biggersize)))

(defun x-hugh-appearance-get-smaller-font-size ()
  "Return string with current font, but size increased by one."
  (interactive)
  (let ((smallersize (+ -1 (x-hugh-appearance-experiment-get-font-size))))
    (format "Inconsolata-%d" smallersize)))

(defun x-hugh-appearance-make-things-bigger ()
  "Increase default font size by one."
  (interactive)
  (fontify-frame (window-frame) (x-hugh-appearance-get-larger-font-size))
  (toggle-frame-maximized))

(defun x-hugh-appearance-make-things-smaller ()
  "Decrease default font size by one."
  (interactive)
  (fontify-frame (window-frame) (x-hugh-appearance-get-smaller-font-size))
  (toggle-frame-maximized))

(defun fontify-frame-appropriate-font ()
  "Return the appropriate font for displays."
  (interactive)
  (cond ((fontify-frame-screen-res-retina-p) "Inconsolata-22")
        ((fontify-frame-screen-res-high-enough-p) "Inconsolata-18")
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

;; FIXME: Causing problems with, I think, inconsolata 3
;; Only if Emacs >= 24.4
;; (if window-system
;;     (progn
;;       (scroll-bar-mode -1)
;;       ;; Fontify current frame (so that it happens on startup; may be unnecessary if you use focus-in-hook)
;;       (fontify-frame-appropriately)
;;       ;; maximize-frame gone in 26
;;       ;; (maximize-frame)))
;;       (toggle-frame-maximized)))

(defun x-hugh-load-solarized (which)
  "Load solarized-WHICH theme, where WHICH is light or dark."
  (interactive)
  ;;; FIXME: Not sure I understand what's going on with the intern here
  ;;; Need to dig a bit more into load-theme
  (load-theme (intern (format "solarized-%s" which))) "no-confirm")

;; Assumption: this code will be run at startup, when I have the dark
;; theme loaded.
(setq x-hugh-solarized--current "dark")

(defun x-hugh-solarized-toggle ()
  "Toggle whether solarized dark or light is loaded."
  (interactive)
  (if (string= x-hugh-solarized--current "dark")
      (setq x-hugh-solarized--current "light")
    (setq x-hugh-solarized--current "dark"))
  (x-hugh-load-solarized x-hugh-solarized--current))

(defun x-hugh-decrease-default-face-height ()
  "Shrink face height for current frame.  Default shrinkage is 5."
  (interactive)
  (let* ((current-height (x-hugh-get-face-height))
	 (new-height (- current-height 5)))
    (x-hugh-set-face-height new-height)))

(defun x-hugh-increase-default-face-height ()
  "Increase face height for current frame.  Default shrinkage is 5."
  (interactive)
  (let* ((current-height (x-hugh-get-face-height))
	 (new-height (+ current-height 5)))
    (x-hugh-set-face-height new-height)))

(defun x-hugh-get-face-height ()
  "Get height for default face in current frame."
  (interactive)
  (face-attribute 'default :height))

(defun x-hugh-set-face-height (arg)
  "Set height for default face in current frame to ARG."
  (interactive)
  (message (format "Calling set-face-attribute with %d" arg))
  ;; (set-face-attribute 'default (selected-frame) :height arg)
  (set-face-attribute 'default nil :height arg)
  (face-attribute 'default :height))

(defun x-hugh-set-theme-for-terminal ()
  "I always forget that tsdh-dark looks good in a terminal."
  (interactive)
  (load-theme (intern "tsdh-dark") "no-confirm"))

;; My attempt to get Magit to prefer splitting windows vertically
;; rather than horizontally.  See
;; https://emacs.stackexchange.com/questions/28496/magit-status-always-split-vertically
(setq split-width-threshold 90)
(setq split-height-threshold 40)

(provide 'x-hugh-appearance)
;;; x-hugh-appearance.el ends here
