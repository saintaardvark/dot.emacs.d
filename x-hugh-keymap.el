;; Keymaps

;; open confluence page
(global-set-key "\C-xwf" 'confluence-get-page)
(global-set-key "\C-xwc" 'confluence-create-page)
(global-set-key "\C-xs"
                'replace-region-command-output)
(global-set-key "\C-cb" 'x-hugh-chronicle-new-blog-entry)
(global-set-key "\C-cc"		'comment-region)
(global-set-key "\C-ce"		'x-hugh-edit-dot-emacs)
(global-set-key "\C-cf"		'x-hugh-figl)
(global-set-key "\C-ck"		'compile)
(global-set-key "\C-cm"		'magit-status)
(global-set-key "\C-cn"		'notmuch-search)
(global-set-key "\C-cp"		'x-hugh-insert-rt-ticket-into-org)
(global-set-key "\C-cr"		'x-hugh-reload-dot-emacs)
(global-set-key "\C-cs"		'x-hugh-email-rt-dwim)

;; FIXME: These are in my home .emacs, but I'm not sure how they'll work w/GUI.
(global-set-key "\C-w" 'clipboard-kill-region)
(global-set-key "\M-w" 'clipboard-kill-ring-save)
(global-set-key "\C-y" 'clipboard-yank)

(global-set-key "\C-\M-z"	'x-hugh-delete-to-sig)
(global-set-key "\C-c\C-r"	'x-hugh-show-rt-tickets)
(global-set-key "\C-c\C-s"	'sudo-edit-current-file)
;; (global-set-key "\C-cw"		'x-hugh-wordcount)
(global-set-key "\C-c\C-s"	'x-hugh-open-cfengine-files)
(global-set-key "\C-c3"	        'x-hugh-open-cf3-files)
(global-set-key "\C-c\C-n"	'x-hugh-open-chibi-account-file)
(global-set-key "\C-c\C-v"	'x-hugh-wiki-verbatim-quote)
(global-set-key "\C-c\C-q"	'x-hugh-wiki-blockquote-quote)
(global-set-key "\C-c\C-w" 'w3m-goto-url)

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
