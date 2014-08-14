;; Keymaps

;; From http://endlessparentheses.com/the-toggle-map-and-wizardry.html
;; Other suggestons: http://irreal.org/blog/?p=2830

(define-prefix-command 'endless/toggle-map)
;; The manual recommends C-c for user keys, but C-x t is
;; always free, whereas C-c t is used by some modes.
(define-key ctl-x-map "t" 'endless/toggle-map)
(define-key endless/toggle-map "c" 'column-number-mode)
(define-key endless/toggle-map "d" 'toggle-debug-on-error)
(define-key endless/toggle-map "e" 'toggle-debug-on-error)
(define-key endless/toggle-map "f" 'auto-fill-mode)
(define-key endless/toggle-map "l" 'toggle-truncate-lines)
(define-key endless/toggle-map "q" 'toggle-debug-on-quit)
(define-key endless/toggle-map "t" 'endless/toggle-theme)
;;; Generalized version of `read-only-mode'.
(define-key endless/toggle-map "r" 'dired-toggle-read-only)
(autoload 'dired-toggle-read-only "dired" nil t)


;; open confluence page
(global-set-key "\C-xwf"	'confluence-get-page)
(global-set-key "\C-xwc"	'confluence-create-page)
(global-set-key "\C-xs"		'replace-region-command-output)
(global-set-key "\C-cb"		'x-hugh-chronicle-new-blog-entry)
(global-set-key "\C-cc"		'comment-region)
(global-set-key "\C-ce"		'x-hugh-edit-dot-emacs)
(global-set-key "\C-cf"		'x-hugh-figl)
(global-set-key "\C-ck"		'compile)
(global-set-key "\C-cm"		'magit-status)
(global-set-key "\C-cn"		'notmuch-search)
(global-set-key "\C-cr"		'x-hugh-reload-dot-emacs)
(global-set-key "\C-cs"		'x-hugh-email-rt-dwim)
(global-set-key "\C-ct"		'x-hugh-new-rt-email)
(global-set-key "\C-cx"		'x-hugh-set-appearance)
(global-set-key "\C-\M-z"	'x-hugh-delete-to-sig)
(global-set-key "\C-c\C-r"	'x-hugh-show-rt-tickets-2)
(global-set-key "\C-c\C-s"	'sudo-edit-current-file)
;; (global-set-key "\C-cw"		'x-hugh-wordcount)
(global-set-key "\C-cir"	'x-hugh-open-chibi-account-file)

;; I'm gonna declare C-cw the official prefix of my wiki stuff.
(global-set-key "\C-cwa"	'x-hugh-insert-wiki-rt-link-as-detailed-in)
(global-set-key "\C-cwb"	'x-hugh-blog-entry)
(global-set-key "\C-cwc"	'x-hugh-open-blog-page)
(global-set-key "\C-cwf"	'doom-run-text-autoformat-on-region)
(global-set-key "\C-cwg"	'x-hugh-git-commit-and-push-without-mercy)
(global-set-key "\C-cwp"	'x-hugh-insert-wiki-rt-link)
(global-set-key "\C-cwq"	'x-hugh-wiki-blockquote-quote)
(global-set-key "\C-cwv"	'x-hugh-wiki-verbatim-quote)

; Markdown mode
; (define-key markdown-mode-map (kbd "\C-cwl") 'x-hugh-markdown-footnote)

;; I'm gonna declare C-co the offical prefix of my org stuff.
(global-set-key "\C-cof"		'x-hugh-open-org-file-for-rt-ticket)
(global-set-key "\C-com"		'x-hugh-mail-buffer-to-rt)
(global-set-key "\C-con"		'x-hugh-org-clock-in-starting-now-dammit)
(global-set-key "\C-cop"		'x-hugh-insert-rt-ticket-into-org)
(global-set-key "\C-cos"		'x-hugh-insert-rt-ticket-commit-comment)
(global-set-key "\C-cot"		'x-hugh-insert-rt-ticket-into-org-from-rt-email)
(global-set-key "\C-coy"		'x-hugh-boxquote-yank-and-indent)

;; And I'm gonna declare C-c3 the official prefix of my Cf3 stuff.
(global-set-key "\C-c3f"		'x-hugh-cf3-insert-file-template)
(global-set-key "\C-c3o"	        'x-hugh-open-cfengine-files)

; God, I hate what this does when using Emacs in X
(global-unset-key "\C-z")

(global-unset-key "\M-j")
(global-set-key "\M-j" 'join-line)

;; Goto-line, dammit!
(global-set-key "\M-g" 'goto-line)
(global-set-key "\C-\M-q" 'auto-fill-mode)
(global-set-key "\C-w" 'clipboard-kill-region)
(global-set-key "\M-w" 'clipboard-kill-ring-save)
(global-set-key "\C-y" 'clipboard-yank)

(global-set-key (kbd "<f9> y")	'x-hugh-boxquote-yank-and-indent)

; Markdown mode
(define-key markdown-mode-map (kbd "C-c l") 'x-hugh-markdown-footnote)

(provide 'x-hugh-keymap)
