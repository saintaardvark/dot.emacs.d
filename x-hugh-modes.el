;; x-hugh-modes --- Modes/requires.

;;; Commentary:
;; Required packages and their settings.

;;; Code:

;; Use post for Mutt.
(use-package post
  :config
  ;; Tell it manually to just use goddamn server-edit, not
  ;; save-buffers-kill-emacs.

  ;; If you look at where post-finish gets defined, it's looking to see
  ;; if server-edit is fboundp to anything; if not, it falls through to
  ;; save-buffers-kill-emacs.  However, I think what's happening is that
  ;; server-edit is not bound to anything until after post is loaded --
  ;; which is seriously fucking with my use of Mutt and having an Emacs
  ;; daemon hanging around all the time.  This is new behaviour as of
  ;; 24.2; not sure what is different.  This is ugly but it works.
  (fset 'post-finish 'server-edit)
  :mode ("mutt.*$" . post-mode))

;; Use scp for tramp.
(use-package tramp
  :config
  (setq tramp-default-method "scp"))

;; Load ssh.
(use-package ssh)

;; Shell script stuff
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

;; Random
(use-package boxquote)
(use-package linum)
(use-package midnight
  :custom ((midnight-mode t)
           (clean-buffer-list-delay-general 1)
           (clean-buffer-list-kill-never-buffer-names (quote ("*scratch*" "*Messages*" "*server*" ".\\*\\.org$")))))

(use-package uniquify)
(use-package xclip)

;; Not sure how handy this is going to be...
(autoload 'map-lines "map-lines"
  "Map COMMAND over lines matching REGEX."
  t)

;; Perl
(use-package perldoc)
(defalias 'perl-mode 'cperl-mode)
(use-package perltidy)
;; 8 spaces for tab, the way God intended
;;(setq perl-indent-level 8)

;; Diff mode
(add-hook 'diff-mode 'font-lock-mode)

(use-package browse-kill-ring)

;; Apache mode.

(use-package apache-mode
  :mode (("\\.htaccess\\'" . apache-mode)
         ("httpd\\.conf\\'"  . apache-mode)
         ("srm\\.conf\\'"    . apache-mode)
         ("access\\.conf\\'" . apache-mode)
         ("sites-\\(available\\|enabled\\)/" . apache-mode)))

;; Longlines mode
(use-package visual-line-mode)

;; Because it's fun.
;; FIXME: do I need to enable using :config?
(use-package nyan-mode
  :config (nyan-mode))

;; I'm gonna break this habit if it kills me
(use-package annoying-arrows-mode
  :config (global-annoying-arrows-mode))

;; Flycheck
(use-package flycheck
  :config (add-hook 'after-init-hook #'global-flycheck-mode)
  :custom ((flycheck-check-syntax-automatically (quote (save idle-change)))
           (flycheck-flake8-maximum-line-length 9990)
           (flycheck-idle-change-delay 2)
           (flycheck-keymap-prefix ".")))

(use-package yasnippet)

;; For ANSI colourization in compilation buffers.
;; https://stackoverflow.com/questions/13397737/ansi-coloring-in-compilation-mode/20788581#20788581
(defun my-colorize-compilation-buffer ()
  (when (eq major-mode 'compilation-mode)
    (ansi-color-apply-on-region compilation-filter-start (point-max))))
;; FIXME: Pretty sure there's a better way to add hooks here...
(use-package ansi-color
  :custom (add-hook 'compilation-filter-hook 'my-colorize-compilation-buffer))

;; Man, I always forget about winner-mode...
(winner-mode 1)

;; jinja
(add-to-list 'auto-mode-alist '("\\.j2\\'" . jinja2-mode))

;; Jenkinsfile
(add-to-list 'auto-mode-alist '("Jenkinsfile\\'" . groovy-mode))

;; Dired
(use-package dired
  :config
  (setq dired-dwim-target t)
  (setq dired-recursive-copies 'always)
  (setq ddired-recursive-deletes 'top))

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
