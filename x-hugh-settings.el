;; Random settings.

;; So can kill (and thus paste) text from read-only buffer
(setq kill-read-only-ok 1)
(put 'narrow-to-region 'disabled nil)
(fset 'yes-or-no-p 'y-or-n-p)            ; enable one letter y/n answers to yes/no
(add-hook 'write-file-hooks 'delete-trailing-whitespace)


;;; Paste at cursor NOT mouse pointer position
(setq mouse-yank-at-point t)

;; 8 spaces for tab, the way God intended
;;(setq perl-indent-level 8)
(add-hook 'text-mode-hook '(lambda () (auto-fill-mode 1)))
(add-hook 'text-mode-hook '(lambda () (abbrev-mode 1)))
(add-hook 'diff-mode 'font-lock-mode)

;; To set shell-script mode by default
(add-to-list 'auto-mode-alist (cons "\\.muttrc$" 'shell-script-mode))
(add-to-list 'auto-mode-alist '("\\.cfg\\'" . shell-script-mode))
(add-to-list 'auto-mode-alist '("\\.sieve\\'" . shell-script-mode))
(add-to-list 'auto-mode-alist '("\\.mdwn\\'" . markdown-mode))

(add-hook 'comint-output-filter-functions
	  'comint-watch-for-password-prompt)

; From http://www.emacswiki.org/emacs/CopyAndPaste
(setq select-active-regions t) ;  active region sets primary X11 selection
(global-set-key [mouse-2] 'mouse-yank-primary)  ; make mouse middle-click only paste from primary X11 selection, not clipboard and kill ring.

(put 'set-goal-column 'disabled nil)

;; http://emacsblog.org/2008/12/06/quick-tip-detaching-the-custom-file/
(setq custom-file "~/.emacs.d/x-hugh-custom.el")
(load custom-file 'noerror)

(provide 'x-hugh-settings)
