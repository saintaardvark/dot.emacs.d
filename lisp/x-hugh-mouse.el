;;; -*- lexical-binding: t -*-
;;; x-hugh-mouse --- where I keep mouse/trackpad things.

;;; Commentary:
;;; Sometimes I want to hurl trackpads into the ocean, you know?

;;; Code:

(setq mouse-wheel-mode nil)
(setq mouse-yank-at-point t)

;; https://emacs.stackexchange.com/a/22538
(defconst XINPUT-TOUCHPAD-ID "6") ; if using xinput, SET TO VALUE APPROPRIATE FOR YOUR DEVICE!
(defconst XINPUT-DISABLE-TOUCHPAD (concat "xinput --disable " XINPUT-TOUCHPAD-ID))
(defconst XINPUT-ENABLE-TOUCHPAD  (concat "xinput --enable " XINPUT-TOUCHPAD-ID))
(defconst SYNCLIENT-DISABLE-TOUCHPAD "synclient TouchpadOff=1")
(defconst SYNCLIENT-ENABLE-TOUCHPAD  "synclient TouchpadOff=0")

;;; TEST YOUR DEVICE before you choose to use `synclient` (preferred) or `xinput`
(defconst DISABLE-TOUCHPAD XINPUT-DISABLE-TOUCHPAD)
(defconst ENABLE-TOUCHPAD  XINPUT-ENABLE-TOUCHPAD)

;; FIXME: These two take frame as an argument, but I don't think they do anything with them.
(defun touchpad-off (&optional frame)
  "Simple command to disable the touchpad."
  (interactive)
  (shell-command DISABLE-TOUCHPAD))

(defun touchpad-on (&optional frame)
  "Simple command to enable the touchpad."
  (interactive)
  (shell-command ENABLE-TOUCHPAD))

;; make mouse middle-click only paste from primary X11 selection, not clipboard and kill ring.
(global-set-key [mouse-2] 'mouse-yank-primary)

(provide 'x-hugh-mouse)
;;; x-hugh-mouse.el ends here
