;;; x-hugh-keymap -- keymappings

;;; Commentary:

;;; Code:

;; Keymaps

;; Win-switch
;; (global-set-key "\C-xo" 'win-switch-dispatch)
;; (win-switch-setup-keys-ijkl "\C-xo")

;; From http://pragmaticemacs.com/emacs/dont-kill-buffer-kill-this-buffer-instead/
(global-set-key (kbd "C-x k")   'jcs-kill-a-buffer)

;; Indent whole buffer
(global-set-key "\C-\\"         'x-hugh-indent-buffer)

;; Use ibuffer mode by default
(global-set-key "\C-x\C-b"      'ibuffer)

;; open confluence page
(global-set-key "\C-xs"		'replace-region-command-output)
(global-set-key "\C-cb"		'x-hugh-jekyll-new-blog-entry)
(global-set-key "\C-ck"		'compile)
(global-set-key "\C-cm"		'magit-status)
;; (global-set-key "\C-cn"		'notmuch-search)

(global-set-key "\C-cx"		'x-hugh-set-appearance)
(global-set-key "\C-\M-z"	'x-hugh-delete-to-sig)
(global-set-key "\C-c\C-r"	'x-hugh-show-rt-tickets-2)
(global-set-key "\C-c\C-s"	'sudo-edit-current-file)

(global-set-key (kbd "C-'") #'sp-rewrap-sexp)
;; Trying out avy-mode
(global-set-key (kbd "C-;") #'avy-goto-char)

;; Official key prefixes:
;; C-c e: lisp stuff
;; C-c i: random file stuff.
;; C-c j: Puppet
;; C-c o: org
;; C-c p: wiki/blog
;; C-c u: random
;; C-c v: vagrant
;; C-c w: workgroups.
;; C-c y: window (hydra)
;; C-c 3: CFEngine

;; Global menu
(global-set-key (kbd "C-c h") 'hydra-menu/body)

;; Now all the rest in alphabetical order
(global-set-key (kbd "C-c a") 'hydra-apropos/body)
(global-set-key (kbd "C-c e") 'hydra-elisp/body)
(global-set-key (kbd "C-c i") 'hydra-personal-files/body)
(global-set-key (kbd "C-c j") 'hydra-copy-lines/body)
(global-set-key (kbd "C-c n") 'hydra-goto/body)
(global-set-key (kbd "C-c p") 'hydra-puppet/body)
(global-set-key (kbd "C-c t") 'hydra-text/body)
(global-set-key (kbd "C-c y") 'hydra-window/body)
(global-set-key (kbd "C-c z") 'hydra-zoom/body)


;; For some reason, markdown mode grabs this binding.  I *REALLY* want
;; it back.  I don't know why this isn't working.
(require 'markdown-mode)
(add-hook 'markdown-mode-hook
          (lambda ()
            (define-key markdown-mode-map "\C-c '"
              'hydra-text/body)))

;; These can be turned into Hydra if needed.

;; (global-set-key "\C-cpa"	'x-hugh-wiki-attach-file-to-wiki-page)
;; (global-set-key "\C-cpb"	'x-hugh-blog-entry)
;; (global-set-key "\C-cpc"	'x-hugh-open-blog-page)
;; (global-set-key "\C-cpg"	'x-hugh-gh-git-commit-and-push-without-mercy)
;; (global-set-key "\C-cpr"	'x-hugh-insert-wiki-rt-link)
;; (global-set-key "\C-cpt"	'x-hugh-insert-wiki-rt-link-as-detailed-in)
;; (global-set-key "\C-cpq"	'x-hugh-wiki-blockquote-quote)
;; (global-set-key "\C-cpv"	'x-hugh-wiki-verbatim-quote)

; Markdown mode
(define-key markdown-mode-map (kbd "\C-cwl") 'x-hugh-markdown-footnote)

;; I'm gonna declare C-co the offical prefix of my org stuff.
;; (global-set-key "\C-cod"		'x-hugh-org-new-day-in-notes)
;; (global-set-key "\C-cof"		'x-hugh-open-org-file-for-rt-ticket)
;; (global-set-key "\C-com"		'x-hugh-mail-buffer-to-rt)
;; (global-set-key "\C-con"		'x-hugh-org-clock-in-starting-now-dammit)
;; (global-set-key "\C-cop"		'x-hugh-insert-rt-ticket-into-org)
;; (global-set-key "\C-coR"		'x-hugh-org-autofill-rt-entry)
;; (global-set-key "\C-cos"		'x-hugh-insert-rt-ticket-commit-comment)
;; (global-set-key "\C-cot"		'x-hugh-insert-rt-ticket-into-org-from-rt-email)
;; (global-set-key "\C-coy"		'x-hugh-boxquote-yank-and-indent)

;; Vagrant
;; (global-set-key "\C-cvd"                'vagrant-destroy)
;; (global-set-key "\C-cve"                'vagrant-edit)
;; (global-set-key "\C-cvu"                'vagrant-up)
;; (global-set-key "\C-cvp"                'vagrant-provision)
;; (global-set-key "\C-cvs"                'vagrant-ssh)
;; (global-set-key "\C-cvt"                'vagrant-tramp-term)



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
;; Garr, I hate what these do.
;; (define-key smartparens-mode-map (kbd "M-<delete>") 'sp-unwrap-sexp)
;; (define-key smartparens-mode-map (kbd "M-<backspace>") 'sp-backward-unwrap-sexp)

;; Going to try Steve Yegge's suggestion.
;; https://www.reddit.com/r/emacs/comments/2z3yxe/invoke_mx_without_the_alt_key/
(global-set-key "\C-x\C-m" 'execute-extended-command)
(global-set-key "\C-c\C-m" 'execute-extended-command)

(provide 'x-hugh-keymap)
;;; x-hugh-keymap ends here
