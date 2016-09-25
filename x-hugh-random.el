;;; x-hugh-random --- where I keep random things.

;;; Commentary:
;;; I really should sort all this out better.

;; First, set custom file.
;; http://emacsblog.org/2008/12/06/quick-tip-detaching-the-custom-file/

;;; Code:

;; Random settings.

(put 'narrow-to-region 'disabled nil)
(fset 'yes-or-no-p 'y-or-n-p)            ; enable one letter y/n answers to yes/no

;; Sigh...causing too many problems with git repo
;; (add-hook 'write-file-hooks 'delete-trailing-whitespace)

;; Check for ispell stuff.
(setq spell-command "ispell")
;; (ispell-program-name "/usr/local/bin/ispell")

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

(provide 'x-hugh-random)

;;; x-hugh-random ends here
