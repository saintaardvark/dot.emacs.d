;; First, set custom file.
;; http://emacsblog.org/2008/12/06/quick-tip-detaching-the-custom-file/
(setq custom-file "~/.emacs.d/x-hugh-custom.el")
(load custom-file 'noerror)

;; Random settings.

;; Packages -- should be broken out into separate file, I think.
(package-initialize)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)

;; So can kill (and thus paste) text from read-only buffer
(setq kill-read-only-ok 1)
(put 'narrow-to-region 'disabled nil)
(fset 'yes-or-no-p 'y-or-n-p)            ; enable one letter y/n answers to yes/no
(add-hook 'write-file-hooks 'delete-trailing-whitespace)

;; See http://www.emacswiki.org/emacs/NoTabs
(setq-default indent-tabs-mode nil)

;;; Paste at cursor NOT mouse pointer position
(setq mouse-yank-at-point t)

;; 8 spaces for tab, the way God intended
;;(setq perl-indent-level 8)
(add-hook 'text-mode-hook '(lambda () (auto-fill-mode 1)))
(add-hook 'text-mode-hook '(lambda () (abbrev-mode 1)))
(add-hook 'text-mode-hook '(lambda () (flyspell-mode 1)))
(add-hook 'diff-mode 'font-lock-mode)

;; Turn on abbrevs for post mode
(add-hook 'post-mode '(lambda () (abbrev-mode 1)))

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

;; Ibuffer

(global-set-key (kbd "C-x C-b") 'ibuffer)
(autoload 'ibuffer "ibuffer" "List buffers." t)

;; win-switch
;; (require 'win-switch)

;; Needed to get Vagrant provision to work; ditto for rbenv/puppet-lint.
;; See http://www.emacswiki.org/emacs/ExecPath
;; See http://marc-bowes.com/2012/03/10/rbenv-with-emacs.html
;; (setenv "PATH" (concat (concat (getenv "HOME") "/.rbenv/shims:")
;;                        (concat (getenv "HOME") "/.rbenv/bin:")
;;                        (concat (getenv "HOME") "/rubygems/bin:")
;;                        "/usr/local/bin:"
;;                        (getenv "PATH")))
;; (setenv "GEM_HOME" (concat (getenv "HOME") "/rubygems"))
;;                    ;; (setq exec-path (append (concat (getenv "HOME") "/.rbenv/shims")

(provide 'x-hugh-settings)
