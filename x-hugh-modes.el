;; x-hugh-modes --- Modes/requires.

;;; Commentary:
;; Required packages and their settings.

;;; Code:

;; FIXME: Alphabetize the modes

;; NOTE: Since I come here for examples for use-package...there *is* a
;; custom section.  Example:

;; (use-package highlight-indent-guides
;;   :custom (highlight-indent-guides-method 'character)
;;   :config (add-hook 'prog-mode-hook 'highlight-indent-guides-mode))


;; I'm gonna break this habit if it kills me
(use-package annoying-arrows-mode
  :config (global-annoying-arrows-mode))

;; FIXME: Pretty sure there's a better way to add hooks here...
;; For ANSI colourization in compilation buffers.
;; https://stackoverflow.com/questions/13397737/ansi-coloring-in-compilation-mode/20788581#20788581
(defun my-colorize-compilation-buffer ()
  (when (eq major-mode 'compilation-mode)
    (ansi-color-apply-on-region compilation-filter-start (point-max))))

(use-package ansi-color
  :custom (add-hook 'compilation-filter-hook 'my-colorize-compilation-buffer))

(use-package apache-mode
  :mode (("\\.htaccess\\'" . apache-mode)
         ("httpd\\.conf\\'"  . apache-mode)
         ("srm\\.conf\\'"    . apache-mode)
         ("access\\.conf\\'" . apache-mode)
         ("sites-\\(available\\|enabled\\)/" . apache-mode)))

(use-package browse-kill-ring)

(use-package boxquote)

(use-package compile
  :custom (compilation-scroll-output 'first-error))

(use-package delsel
  :custom (delete-selection-mode nil))

(use-package dired
  :custom ((dired-dwim-target t)
	   (dired-recursive-copies 'always)
	   (dired-recursive-deletes 'top)))

(use-package flycheck
  :config (add-hook 'after-init-hook #'global-flycheck-mode)
  :custom ((flycheck-check-syntax-automatically (quote (save idle-change)))
           (flycheck-flake8-maximum-line-length 9990)
           (flycheck-idle-change-delay 2)
           (flycheck-keymap-prefix ".")))

(use-package linum)

(use-package midnight
  :custom ((midnight-mode t)
           (clean-buffer-list-delay-general 1)
           (clean-buffer-list-kill-never-buffer-names (quote ("*scratch*" "*Messages*" "*server*" ".\\*\\.org$")))))

;; Because it's fun.
;; FIXME: do I need to enable using :config?
(use-package nyan-mode
  :config (nyan-mode))

(use-package paren
  :config (setq show-paren-mode 1))

;; Use post for Mutt.
(use-package post
  :custom ((post-email-address "aardvark@saintaardvarkthecarpeted.com")
           (post-should-prompt-for-attachment 'Never))
  ;; :config
  ;; Tell it manually to just use goddamn server-edit, not
  ;; save-buffers-kill-emacs.

  ;; If you look at where post-finish gets defined, it's looking to see
  ;; if server-edit is fboundp to anything; if not, it falls through to
  ;; save-buffers-kill-emacs.  However, I think what's happening is that
  ;; server-edit is not bound to anything until after post is loaded --
  ;; which is seriously fucking with my use of Mutt and having an Emacs
  ;; daemon hanging around all the time.  This is new behaviour as of
  ;; 24.2; not sure what is different.  This is ugly but it works.
                                        ; (fset 'post-finish 'server-edit)
  :mode ("mutt.*$" . post-mode))
;; FIXME: Not sure what I intended here -- I think to turn on abbrev
;; and smartparens, but not sure.  In any case, uncommenting these
;; gives this error:
;; https://stackoverflow.com/questions/11807128/emacs-nesting-exceeds-max-lisp-eval-depth

;; :hook ((abbrev-mode . post-mode))
;;  (smartparens-mode . post-mode)))

;; Without this particular form for :hook, I get this error:
;; File mode specification error: (error Autoloading file /home/aardvark/.emacs.d/.cask/26.1/elpa/rainbow-delimiters-20170929.1132/rainbow-delimiters.elc failed to define function rainbow-delimiters)
;;
;; Explanation: You've implicitly told use-package to make an autoload
;; declaration that the rainbow-delimiters library defines a function
;; which is also named rainbow-delimiters (and to add that function to
;; prog-mode-hook). Consequently when prog-mode-hook runs and calls
;; the (autoloaded) function rainbow-delimiters, the autoloading
;; mechanism duly loads the rainbow-delimiters library in order to get
;; the real definition of that function -- and then finds that the
;; stated function wasn't defined by that library after all, and
;; complains.
;;
;; Quoted from https://www.reddit.com/r/emacs/comments/87atsm/issue_with_rainbowdelimiters_not_defining_the/
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; Load ssh.
(use-package ssh)

;; Use scp for tramp.
(use-package tramp
  :config
  (setq tramp-default-method "scp"))

;; Shell script stuff
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)


;; NOTE: shell-script-mode is an alias for ‘sh-mode’ in
;; ‘sh-script.el’; the hook is sh-mode-hook.  See
;; x-hugh-smartparens.el for more detail,
(add-to-list 'auto-mode-alist '("\\.sh" . shell-script-mode))

(use-package uniquify
  :custom ((uniquify-buffer-name-style 'post-forward nil (uniquify))
           (uniquify-min-dir-content 2)))

(use-package xclip)

;; Not sure how handy this is going to be...
(autoload 'map-lines "map-lines"
  "Map COMMAND over lines matching REGEX."
  t)

;; Diff mode
(add-hook 'diff-mode 'font-lock-mode)

(use-package yasnippet)

;; Man, I always forget about winner-mode...
(winner-mode 1)

;; jinja
(add-to-list 'auto-mode-alist '("\\.j2\\'" . jinja2-mode))

;; Jenkinsfile
(add-to-list 'auto-mode-alist '("Jenkinsfile\\'" . groovy-mode))

;; Noice!
;; https://emacs.stackexchange.com/questions/202/close-all-dired-buffers
(setq-default ibuffer-saved-filter-groups
              `(("Default"
                 ;; I create a group call Dired, which contains all buffer in dired-mode
                 ("Dired" (mode . dired-mode))
                 ("Temporary" (name . "\*.*\*"))
                 )))

(add-hook 'ibuffer-mode-hook #'(ibuffer-switch-to-saved-filter-groups "Default"))

(provide 'x-hugh-modes)
;;; x-hugh-modes ends here
