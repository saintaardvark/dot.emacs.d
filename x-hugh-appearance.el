;; x-hugh-appearance.el --- appearances are everything

;;; Commentary:

;;; Code:

;; Emacs appearance

;; Custom themes package
(use-package custom
  :custom (
	   ;; Note: `custom-safe-themes` needs to come before
	   ;; `custom-enabled-themes`; otherwise, you'll get
	   ;; interrupted with a prompt to trust the custom theme.
	   (custom-safe-themes
	    '("a22f40b63f9bc0a69ebc8ba4fbc6b452a4e3f84b80590ba0a92b4ff599e53ad0"
	      "a8245b7cc985a0610d71f9852e9f2767ad1b852c2bdea6f4aadc12cce9c4d6d0"
	      "d677ef584c6dfc0697901a44b885cc18e206f05114c8a3b7fde674fce6180879"
	      "a27c00821ccfd5a78b01e4f35dc056706dd9ede09a8b90c6955ae6a390eb1c1e"
	      "c74e83f8aa4c78a121b52146eadb792c9facc5b1f02c917e3dbb454fca931223"
	      "3c83b3676d796422704082049fc38b6966bcad960f896669dfc21a7a37a748fa"
	      "8aebf25556399b58091e533e455dd50a6a9cba958cc4ebb0aab175863c25b9a4"
	      "e16a771a13a202ee6e276d06098bc77f008b73bbac4d526f160faa2d76c1dd0e"
	      "6a37be365d1d95fad2f4d185e51928c789ef7a4ccf17e7ca13ad63a8bf5b922f"
	      default))
	   (custom-enabled-themes '(gruvbox-dark-hard))))

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
  (set-frame-font "Inconsolata-12"))

(defun x-hugh-set-font-larger ()
  "Set font to 16 point.  FIXME: Make this something like ctrl-shift-+/- in FF."
  (interactive)
  (set-frame-font "Inconsolata-18"))
;; (require 'color-theme nil 'noerror)
;; (load-theme "solarized-dark" t)

;; Just make it larger...I always do this at startup anyhow.

(x-hugh-set-font-larger)

(defun x-hugh-set-appearance ()
  "Reload x-hugh-appearance.el."
  (interactive)
  (load-file "~/.emacs.d/x-hugh-appearance.el"))


;; FIXME: Refactor all this
;; FIXME: This needs to be broken out into a package

;; From https://gist.github.com/MatthewDarling/8c232b1780126275c3b4
;; Based on http://arnab-deka.com/posts/2012/09/emacs-change-fonts-dynamically-based-on-screen-resolution/

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
  (let ((biggersize (+ 1 (x-hugh-appearance-get-font-size))))
    (format "Inconsolata-%d" biggersize)))

(defun x-hugh-appearance-get-smaller-font-size ()
  "Return string with current font, but size increased by one."
  (interactive)
  (let ((biggersize (+ -1 (x-hugh-appearance-get-font-size))))
    (format "Inconsolata-%d" biggersize)))

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
      (fontify-frame-appropriately)
      ;; maximize-frame gone in 26
      ;; (maximize-frame)))
      (toggle-frame-maximized)))

(defun x-hugh-load-solarized (which)
  "Load solarized-WHICH theme, where WHICH is light or dark."
  (interactive)
  ;;; FIXME: Not sure I understand what's going on with the intern here
  ;;; Need to dig a bit more into load-theme
  (load-theme (intern (format "solarized-%s" which))))

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

(provide 'x-hugh-appearance)
;;; x-hugh-appearance ends here
