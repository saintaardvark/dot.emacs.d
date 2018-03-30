;;; x-hugh-random --- where I keep random things.

;;; Commentary:
;;; I really should sort all this out better.

;;; Code:

;; Random settings.

(put 'narrow-to-region 'disabled nil)
(fset 'yes-or-no-p 'y-or-n-p) ; enable one letter y/n answers to yes/no

;; Sigh...causing too many problems with git repo
;; (add-hook 'write-file-hooks 'delete-trailing-whitespace)

;; Check for ispell stuff.
(setq spell-command "ispell")

(when (executable-find spell-command)
  (add-hook 'text-mode-hook '(lambda () (flyspell-mode 1))))

(add-hook 'comint-output-filter-functions
          'comint-watch-for-password-prompt)

;; From http://www.emacswiki.org/emacs/CopyAndPaste
(setq select-active-regions t) ;  active region sets primary X11 selection
(global-set-key [mouse-2] 'mouse-yank-primary)  ; make mouse middle-click only paste from primary X11 selection, not clipboard and kill ring.

;; Save all tempfiles in $TMPDIR/emacs$UID/
;; See https://www.emacswiki.org/emacs/AutoSave
(defconst emacs-tmp-dir (format "%s/%s%s/" temporary-file-directory "emacs" (user-uid)))
(setq backup-directory-alist
      `((".*" . ,emacs-tmp-dir)))
(setq auto-save-file-name-transforms
      `((".*" ,emacs-tmp-dir t)))
(setq auto-save-list-file-prefix
      emacs-tmp-dir)

(setq epg-gpg-program (executable-find "gpg"))

;; From http://pragmaticemacs.com/emacs/dont-kill-buffer-kill-this-buffer-instead/
(defun jcs-kill-a-buffer (askp)
  "Just kill this damn buffer! If ASKP provided, ask which buffer to kill."
  (interactive "P")
  (if askp
      (kill-buffer (funcall completing-read-function
                            "Kill buffer: "
                            (mapcar #'buffer-name (buffer-list))))
    (kill-this-buffer)))

;; Chrome extension for editing stuff in Emacs
  (when (require 'edit-server nil t)
    (setq edit-server-new-frame nil)
    (edit-server-start))

(defun kill-associated-diff-buf ()
  "Tidy up diffs when closing the file."
  (let ((buf (get-buffer (concat "*Assoc file diff: "
                             (buffer-name)
                             "*"))))
    (when (bufferp buf)
      (kill-buffer buf))))

(add-hook 'kill-buffer-hook 'kill-associated-diff-buf)

;; https://emacs.stackexchange.com/a/22538
(defconst XINPUT-TOUCHPAD-ID "6") ; if using xinput, SET TO VALUE APPROPRIATE FOR YOUR DEVICE!
(defconst XINPUT-DISABLE-TOUCHPAD (concat "xinput --disable " XINPUT-TOUCHPAD-ID))
(defconst XINPUT-ENABLE-TOUCHPAD  (concat "xinput --enable " XINPUT-TOUCHPAD-ID))
(defconst SYNCLIENT-DISABLE-TOUCHPAD "synclient TouchpadOff=1")
(defconst SYNCLIENT-ENABLE-TOUCHPAD  "synclient TouchpadOff=0")

;;; TEST YOUR DEVICE before you choose to use `synclient` (preferred) or `xinput`
(defconst DISABLE-TOUCHPAD XINPUT-DISABLE-TOUCHPAD)
(defconst ENABLE-TOUCHPAD  XINPUT-ENABLE-TOUCHPAD)

(defun touchpad-off (&optional frame)
  (interactive)
  (shell-command DISABLE-TOUCHPAD))

(defun touchpad-on (&optional frame)
  (interactive)
  (shell-command ENABLE-TOUCHPAD))

(add-hook 'focus-in-hook #'touchpad-off)
(add-hook 'focus-out-hook #'touchpad-on)
(add-hook 'delete-frame-functions #'touchpad-on)

;;; and don't forget to enable the touchpad when you exit Emacs:
(add-hook 'kill-emacs-hook #'touchpad-on)

(provide 'x-hugh-random)

;;; x-hugh-random ends here
