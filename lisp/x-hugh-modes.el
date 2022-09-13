;; x-hugh-modes --- Modes/requires.

;;; Commentary:
;; Required packages and their settings.

;;; Code:

;; NOTE: Since I come here for examples for use-package...there *is* a
;; custom section.  Example:

;; (use-package highlight-indent-guides
;;   :custom (highlight-indent-guides-method 'character)
;;   :config (add-hook 'prog-mode-hook 'highlight-indent-guides-mode))



;; FIXME: Pretty sure there's a better way to add hooks here...
(defun my-colorize-compilation-buffer ()
  "Enable ANSI colourization in compilation buffers.

Source: https://stackoverflow.com/questions/13397737/ansi-coloring-in-compilation-mode/20788581#20788581"
  (when (eq major-mode 'compilation-mode)
    (ansi-color-apply-on-region compilation-filter-start (point-max))))

(use-package ansi-color
  :custom (add-hook 'compilation-filter-hook 'my-colorize-compilation-buffer))

(use-package browse-kill-ring
  :ensure t)

(use-package boxquote
  :ensure t)

(use-package compile
  :custom (compilation-scroll-output 'first-error))

(use-package delsel
  :custom (delete-selection-mode nil))

(use-package highlight-indent-guides
  :ensure t
  :custom (highlight-indent-guides-method 'character)
  :config (add-hook 'prog-mode-hook 'highlight-indent-guides-mode))

(use-package linum)

(use-package make-mode
  :mode ("Makefile.*$" . makefile-mode))

(use-package midnight
  :custom ((midnight-mode t)
           (clean-buffer-list-delay-general 1)
           (clean-buffer-list-kill-never-buffer-names (quote ("*scratch*" "*Messages*" "*server*" ".\\*\\.org$")))))

;; Because it's fun.
(use-package nyan-mode
  :ensure t
  :config (nyan-mode))

(use-package paren
  :config (setq show-paren-mode 1))


;; Load ssh.
(use-package ssh
  :ensure t)

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

(use-package xclip
  :ensure t)

;; Not sure how handy this is going to be...
(autoload 'map-lines "map-lines"
  "Map COMMAND over lines matching REGEX."
  t)

;; Diff mode
(add-hook 'diff-mode 'font-lock-mode)

(use-package yaml-mode
  :ensure t)

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

(use-package abbrev
  :custom (save-abbrevs 'silently))

(provide 'x-hugh-modes)
;;; x-hugh-modes.el ends here
