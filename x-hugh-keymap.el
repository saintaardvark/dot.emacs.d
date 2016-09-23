;;; x-hugh-keymap -- keymappings

;;; Commentary:

;;; Code:

;; Keymaps

;; Win-switch
;; (global-set-key "\C-xo" 'win-switch-dispatch)
;; (win-switch-setup-keys-ijkl "\C-xo")

;; Indent whole buffer
(global-set-key "\C-\\"          'x-hugh-indent-buffer)
;; open confluence page
(global-set-key "\C-xs"		'replace-region-command-output)
(global-set-key "\C-cb"		'x-hugh-jekyll-new-blog-entry)
(global-set-key "\C-ck"		'compile)
(global-set-key "\C-cm"		'magit-status)
(global-set-key "\C-cn"		'notmuch-search)

(global-set-key "\C-cs"		'x-hugh-email-rt-dwim)
(global-set-key "\C-ct"		'x-hugh-new-rt-email)
(global-set-key "\C-cx"		'x-hugh-set-appearance)
(global-set-key "\C-\M-z"	'x-hugh-delete-to-sig)
(global-set-key "\C-c\C-r"	'x-hugh-show-rt-tickets-2)
(global-set-key "\C-c\C-s"	'sudo-edit-current-file)

;; Try out cbm-cycle
(global-set-key (kbd "C-'") #'cbm-cycle)

;; (global-set-key "\C-cw"		'x-hugh-wordcount)

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

;; C-c e: lisp stuff.

(global-set-key "\C-ced"	'edebug-defun)

;; Personal files

(global-set-key (kbd "C-c i") 'hydra-personal-files/body)

;; Puppet

(global-set-key (kbd "C-c j") 'hydra-puppet/body)


;; I'm gonna declare C-cw the official prefix of Workgroups.  But!
;; This needs to be set before workgroups is loaded -- so it's
;; actually in x-hugh-modes, and I mention it here for reference.
;; (setq wg-prefix-key (kbd "C-c w"))

;; which means I need to find another prefix for wiki stuff...let's go with C-cp

(global-set-key "\C-cpa"	'x-hugh-wiki-attach-file-to-wiki-page)
(global-set-key "\C-cpb"	'x-hugh-blog-entry)
(global-set-key "\C-cpc"	'x-hugh-open-blog-page)
(global-set-key "\C-cpf"	'doom-run-text-autoformat-on-region)
(global-set-key "\C-cpg"	'x-hugh-git-commit-and-push-without-mercy)
(global-set-key "\C-cpr"	'x-hugh-insert-wiki-rt-link)
(global-set-key "\C-cpt"	'x-hugh-insert-wiki-rt-link-as-detailed-in)
(global-set-key "\C-cpq"	'x-hugh-wiki-blockquote-quote)
(global-set-key "\C-cpv"	'x-hugh-wiki-verbatim-quote)

; Markdown mode
(define-key markdown-mode-map (kbd "\C-cwl") 'x-hugh-markdown-footnote)

;; I'm gonna declare C-co the offical prefix of my org stuff.
(global-set-key "\C-cod"		'x-hugh-org-new-day-in-notes)
(global-set-key "\C-cof"		'x-hugh-open-org-file-for-rt-ticket)
(global-set-key "\C-com"		'x-hugh-mail-buffer-to-rt)
(global-set-key "\C-con"		'x-hugh-org-clock-in-starting-now-dammit)
(global-set-key "\C-cop"		'x-hugh-insert-rt-ticket-into-org)
(global-set-key "\C-coR"		'x-hugh-org-autofill-rt-entry)
(global-set-key "\C-cos"		'x-hugh-insert-rt-ticket-commit-comment)
(global-set-key "\C-cot"		'x-hugh-insert-rt-ticket-into-org-from-rt-email)
(global-set-key "\C-coy"		'x-hugh-boxquote-yank-and-indent)

;; C-cv official prefix of vagrant.
(global-set-key "\C-cvd"                'vagrant-destroy)
(global-set-key "\C-cve"                'vagrant-edit)
(global-set-key "\C-cvu"                'vagrant-up)
(global-set-key "\C-cvp"                'vagrant-provision)
(global-set-key "\C-cvs"                'vagrant-ssh)
(global-set-key "\C-cvt"                'vagrant-tramp-term)

;; And I'm gonna declare C-c3 the official prefix of my Cf3 stuff.
(global-set-key "\C-c3f"		'x-hugh-cf3-insert-file-template)
(global-set-key "\C-c3o"	        'x-hugh-open-cfengine-files)


(global-set-key (kbd "C-c y") 'hydra-window/body)

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
(define-key smartparens-mode-map (kbd "M-<delete>") 'sp-unwrap-sexp)
(define-key smartparens-mode-map (kbd "M-<backspace>") 'sp-backward-unwrap-sexp)

(provide 'x-hugh-keymap)
;;; x-hugh-keymap ends here
