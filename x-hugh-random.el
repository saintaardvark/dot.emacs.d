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

; From http://www.emacswiki.org/emacs/CopyAndPaste
(setq select-active-regions t) ;  active region sets primary X11 selection
(global-set-key [mouse-2] 'mouse-yank-primary)  ; make mouse middle-click only paste from primary X11 selection, not clipboard and kill ring.

;; (exec-path-from-shell-copy-env "GEM_HOME")

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

(defun x-hugh-pull-dotfiles-and-restart ()
  "Do a `git pull` in ~/.emacs.d, then restart."
  (interactive)
  (let ((default-directory "~/.emacs.d/"))
    (shell-command-to-string "git pull"))
  (save-buffers-kill-terminal))

(provide 'x-hugh-random)

;;; x-hugh-random ends here
