;;; x-hugh-keymap -- keymappings

;;; Commentary:

;;; Code:

;; Keymaps

;; WTF, why am I hitting this by accident so much
(global-unset-key "\C-x\C-c")


;; From http://pragmaticemacs.com/emacs/dont-kill-buffer-kill-this-buffer-instead/
(global-set-key (kbd "C-x k")   'jcs-kill-a-buffer)

;; Indent whole buffer
(global-set-key "\C-\\"         'x-hugh-indent-buffer)

;; Use ibuffer mode for this key combo.
;; There is definitely some overlap between this and helm-mini,
;; but I'll leave it for now.
(global-set-key "\C-x\C-b"      'ibuffer)

;; open confluence page
(global-set-key "\C-xs"		'replace-region-command-output)
(global-set-key "\C-ck"		'compile)
(global-set-key "\C-cm"		'magit-status)

(global-set-key "\C-cx"		'x-hugh-set-appearance)
(global-set-key "\C-\M-z"	'x-hugh-delete-to-sig)
(global-set-key "\C-c\C-r"	'x-hugh-show-rt-tickets-2)
(global-set-key "\C-c\C-s"	'sudo-edit-current-file)

;; Using this a lot less than I thought I would.
;; (global-set-key (kbd "C-'") #'sp-rewrap-sexp)

;; OMG, why didn't I do this years ago
(global-set-key "\M-o" 'other-window)

;; Turns out that the hydra-goto is really a good idea.  Going to
;; steal C-; for that, but keep C-' for navi.
;; See also x-hugh-navi.el
(global-set-key (kbd "C-'") 'navi-click-cmd)
(global-set-key (kbd "C-M-'") 'navi-rotate-method)

;; Trying out avy-mode
(use-package avy
  :ensure t)

;; (global-set-key (kbd "C-;") #'avy-goto-char)
(global-set-key (kbd "C-;") #'hydra-goto/body)

;; Official key prefixes:
;; C-c .  flycheck
;; C-c e: lisp stuff
;; C-c f: web stuff
;; C-c g: golang stuff
;; C-c i: random file stuff.
;; C-c k: compile
;; C-c l: org-store link
;; C-c o: org
;; C-c p: RESERVED FOR PROJECTILE
;; C-c u: RESERVED FOR COMBOBOLATE
;; C-c v: fixmee-listview
;; C-c w: workgroups.
;; C-c y: window (hydra)
;; C-c z: zoom (hydra)

;; Global menu
(global-set-key (kbd "C-c h") 'hydra-menu/body)

;; Now all the rest in alphabetical order
(global-set-key (kbd "C-c a") 'hydra-apropos/body)
(global-set-key (kbd "C-c d") 'hydra-dev/body)
(global-set-key (kbd "C-c e") 'hydra-elisp/body)
(global-set-key (kbd "C-c f") 'hydra-web/body)
(global-set-key (kbd "C-c g") 'hydra-golang/body)
(global-set-key (kbd "C-c i") 'hydra-personal-files/body)
(global-set-key (kbd "C-c j") 'hydra-copy-lines/body)
(global-set-key (kbd "C-c n") 'hydra-goto/body)
(global-set-key (kbd "C-c o") 'hydra-org/body)
(global-set-key (kbd "C-c r") 'hydra-emoji/body)
(global-set-key (kbd "C-c s") 'hydra-shell/body)
(global-set-key (kbd "C-c t") 'hydra-text/body)
(global-set-key (kbd "C-c w") 'hydra-window/body)
(global-set-key (kbd "C-c y") 'hydra-python/body)
(global-set-key (kbd "C-c z") 'hydra-zoom/body)

;; Oooh, expand-region!
(use-package expand-region
  :ensure t
  :bind ("C-=" . er/expand-region))

;; For some reason, markdown mode grabs this binding.  I *REALLY* want
;; it back.  I don't know why this isn't working.
(use-package markdown-mode
  :ensure t)
(add-hook 'markdown-mode-hook
          (lambda ()
            (define-key markdown-mode-map "\C-c '"
              'hydra-text/body)))


; God, I hate what this does when using Emacs in X
(global-unset-key "\C-z")

(global-unset-key "\M-j")
(global-set-key "\M-j" 'join-line)

(global-unset-key "\M-z")
(global-set-key "\M-z" 'x-hugh-zap)

;; Goto-line, dammit!
(global-set-key "\M-g" 'avy-goto-line)
(global-set-key "\C-\M-q" 'auto-fill-mode)
(global-set-key "\C-w" 'clipboard-kill-region)
(global-set-key "\M-w" 'clipboard-kill-ring-save)
(global-set-key "\C-y" 'clipboard-yank)

;; C-\ is stolen by tmux.
(global-set-key "\C-\M-]" 'indent-region)
(global-set-key "\M-\\" 'indent-region)

;; Smartparens
;; https://github.com/Fuco1/smartparens/issues/469
;; http://emacs.stackexchange.com/questions/14556/how-do-i-jump-out-of-enclosing-parentheses/14557#14557
(define-key smartparens-mode-map (kbd "C-M-f") 'sp-forward-sexp)
(define-key smartparens-mode-map (kbd "C-M-b") 'sp-backward-sexp)
(define-key smartparens-mode-map (kbd "C-M-d") 'sp-down-sexp)
(define-key smartparens-mode-map (kbd "C-M-a") 'sp-backward-down-sexp)
(define-key smartparens-mode-map (kbd "C-S-d") 'sp-beginning-of-sexp)
(define-key smartparens-mode-map (kbd "C-S-a") 'sp-end-of-sexp)
(define-key smartparens-mode-map (kbd "C-M-e") 'sp-up-sexp)
(define-key smartparens-mode-map (kbd "C-M-u") 'sp-backward-up-sexp)
(define-key smartparens-mode-map (kbd "C-M-t") 'sp-transpose-sexp)
(define-key smartparens-mode-map (kbd "C-M-n") 'sp-next-sexp)
(define-key smartparens-mode-map (kbd "C-M-p") 'sp-previous-sexp)
(define-key smartparens-mode-map (kbd "C-M-k") 'sp-kill-sexp)
(define-key smartparens-mode-map (kbd "C-M-w") 'sp-copy-sexp)

;; Pop-tag-mark, the opposite of M-.
(global-set-key (kbd "C-M-.") 'pop-tag-mark)

(provide 'x-hugh-keymap)
;;; x-hugh-keymap.el ends here
