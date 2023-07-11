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

(use-package solarized-theme
  :ensure t)

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

;; TODO: This whole thing is whack
(defun x-hugh-set-font-smol ()
  "Set font to 8 point.  fixme: make this something like ctrl-shift-+/- in ff."
  (interactive)
  (set-frame-font "inconsolata-8" t))

(defun x-hugh-set-font-semi-smol ()
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

;; just make it larger...i always do this at startup anyhow.
;; fixme / todo: this is borking the display on wayland.  for now i'm
;; disabling it, but it would be good to understand what's going on
;; here.
;;  (x-hugh-set-font-larger)

(defun x-hugh-set-appearance ()
  "reload x-hugh-appearance.el."
  (interactive)
  (load-file "~/.emacs.d/x-hugh-appearance.el"))

;; fixme: refactor all this
;; fixme: this needs to be broken out into a package

;; from https://gist.github.com/matthewdarling/8c232b1780126275c3b4
;; based on http://arnab-deka.com/posts/2012/09/emacs-change-fonts-dynamically-based-on-screen-resolution/

;; i appear to have lost x-hugh-appearance--font :-(
;; trying to recreate it.

(defun x-hugh-appearance-experiment-get-font-size ()
  "get font size for current frame.

that is, given a font of:

-*-inconsolata-regular-normal-normal-*-16-*-*-*-m-0-iso10646-1

return 16."
  (interactive)
  (let ((current-font (frame-parameter nil 'font)))
    ;; you could imagine splitting that by dash; assuming there's a
    ;; zero-width zero index to the left of that first dash (ie, that
    ;; the first * is the first element), that makes the size the 7th
    ;; element.
    (string-to-number (nth 7 (split-string current-font (rx "-"))))))

(defun fontify-frame (target font)
  "adjust font size based on screen resolution.  takes argument target for frame and font."
  (interactive)
  (setq x-hugh-appearance--font font)
  (set-frame-parameter target 'font font))

(defun fontify-frame-appropriately (&optional frame)
  "adjust font size to appropriate size.  takes optional argument frame."
  (interactive)
  (let ((target (or frame (window-frame))))
    (fontify-frame target (fontify-frame-appropriate-font))))

(defun x-hugh-appearance-get-font-size ()
  "return font size of x-hugh-appearance--font.

assumes font named like `inconsolata-14`."
  (interactive)
  ;; fixme: has to be a better way to do this
  (string-to-number (car (cdr (split-string x-hugh-appearance--font "-")))))

(defun x-hugh-appearance-get-larger-font-size ()
  "return string with current font, but size increased by one."
  (interactive)
  (let ((biggersize (+ 1 (x-hugh-appearance-experiment-get-font-size))))
    (format "inconsolata-%d" biggersize)))

(defun x-hugh-appearance-get-smaller-font-size ()
  "return string with current font, but size increased by one."
  (interactive)
  (let ((smallersize (+ -1 (x-hugh-appearance-experiment-get-font-size))))
    (format "inconsolata-%d" smallersize)))

(defun x-hugh-appearance-make-things-bigger ()
  "increase default font size by one."
  (interactive)
  (fontify-frame (window-frame) (x-hugh-appearance-get-larger-font-size))
  (toggle-frame-maximized))

(defun x-hugh-appearance-make-things-smaller ()
  "decrease default font size by one."
  (interactive)
  (fontify-frame (window-frame) (x-hugh-appearance-get-smaller-font-size))
  (toggle-frame-maximized))

(defun fontify-frame-appropriate-font ()
  "return the appropriate font for displays."
  (interactive)
  (cond ((fontify-frame-screen-res-retina-p) "inconsolata-22")
        ((fontify-frame-screen-res-high-enough-p) "inconsolata-18")
        ((fontify-frame-screen-tiny-laptop-p) "inconsolata-12")))

(defun fontify-frame-screen-res-retina-p ()
  "detect retina display."
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

;; Set "light" as --current.  ATM I'm not loading solarized at start
;; time, but switching to it later when I feel like it...and when that
;; happens, I mainly want it dark.
(setq x-hugh-solarized--current "light")

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
;;
;; See also: (split-window-sensibly)
;; See also: (split-window-below)
;; See also: (split-window-right)
;;
;; Docstrng for split-window-spensibly:
;;
;; "Split WINDOW in a way suitable for `display-buffer'.  WINDOW
;; defaults to the currently selected window.
;;
;; If `split-height-threshold' specifies an integer, WINDOW is at
;; least `split-height-threshold' lines tall and can be split
;; vertically, split WINDOW into two windows one above the other and
;; return the lower window.

;; IE: Use split-window-below

;; Otherwise, if `split-width-threshold' specifies an integer, WINDOW
;; is at least `split-width-threshold' columns wide and can be split
;; horizontally, split WINDOW into two windows side by side and return
;; the window on the right.

;; IE: Use split-window-right

;; If this can't be done either and WINDOW is the only window on its
;; frame, try to split WINDOW vertically disregarding any value
;; specified by `split-height-threshold'.  If that succeeds, return
;; the lower window.  Return nil otherwise.

;; By default `display-buffer' routines call this function to split
;; the largest or least recently used window.  To change the default
;; customize the option `split-window-preferred-function'.

;; You can enforce this function to not split WINDOW horizontally,
;; by setting (or binding) the variable `split-width-threshold' to
;; nil.  If, in addition, you set `split-height-threshold' to zero,
;; chances increase that this function does split WINDOW vertically.

;; In order to not split WINDOW vertically, set (or bind) the
;; variable `split-height-threshold' to nil.  Additionally, you can
;; set `split-width-threshold' to zero to make a horizontal split
;; more likely to occur.

;; Have a look at the function `window-splittable-p' if you want to
;; know how `split-window-sensibly' determines whether WINDOW can be
;; split."

;; Oct 21, 2022: I *think* that I've got this right: set
;; split-width-threshold hight but not too high, and leave
;; split-height-threshold alone (default value is 80).

;; June 5, 2023: God, starting to hate how this works.  Setting threshold super high.
(setq split-width-threshold 15000)

(provide 'x-hugh-appearance)
;;; x-hugh-appearance.el ends here
