;; x-hugh-modes --- Modes/requires.

;;; Commentary:
;; Required packages and their settings.

;;; Code:

;; Shell script stuff
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)


;; NOTE: shell-script-mode is an alias for ‘sh-mode’ in
;; ‘sh-script.el’; the hook is sh-mode-hook.  See
;; x-hugh-smartparens.el for more detail,
(add-to-list 'auto-mode-alist '("\\.sh" . shell-script-mode))

;; Not sure how handy this is going to be...
(autoload 'map-lines "map-lines"
  "Map COMMAND over lines matching REGEX."
  t)

;; Diff mode
(add-hook 'diff-mode 'font-lock-mode)

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
;;; x-hugh-modes.el ends here
