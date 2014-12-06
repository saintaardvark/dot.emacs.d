(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(backup-directory-alist (quote (("." . "~/.emacs.d/backups/"))))
 '(battery-mode-line-format "[Battery time: %t]")
 '(c-basic-offset 8)
 '(calendar-offset 0)
 '(case-fold-search t)
 '(clean-buffer-list-delay-general 1)
 '(clean-buffer-list-kill-never-buffer-names (quote ("*scratch*" "*Messages*" "*server*" ".\\*\\.org$")))
 '(color-theme-selection "Arjen" nil (color-theme))
 '(compilation-scroll-output (quote first-error))
 '(cperl-indent-level 8)
 '(current-language-environment "English")
 '(custom-safe-themes (quote ("8aebf25556399b58091e533e455dd50a6a9cba958cc4ebb0aab175863c25b9a4" "e16a771a13a202ee6e276d06098bc77f008b73bbac4d526f160faa2d76c1dd0e" "6a37be365d1d95fad2f4d185e51928c789ef7a4ccf17e7ca13ad63a8bf5b922f" default)))
 '(delete-selection-mode nil nil (delsel))
 '(dired-dwim-target t)
 '(dired-recursive-deletes (quote top))
 '(erc-hide-list (quote ("JOIN" "PART" "QUIT")))
 '(erc-nick "SaintAardvark")
 '(eshell-visual-commands (quote ("vi" "screen" "top" "less" "more" "lynx" "ncftp" "pine" "tin" "trn" "elm" "ssh")))
 '(explicit-shell-file-name "/bin/bash")
 '(find-grep-options "-qi")
 '(global-flycheck-mode t nil (flycheck))
 '(global-font-lock-mode t nil (font-lock))
 '(helm-ff-newfile-prompt-p nil)
 '(ispell-program-name "/usr/bin/ispell")
 '(iswitchb-prompt-newbuffer nil)
 '(magit-git-executable "/usr/bin/git")
 '(magit-use-overlays nil)
 '(midnight-mode t nil (midnight))
 '(ns-command-modifier nil)
 '(org-agenda-columns-add-appointments-to-effort-sum t)
 '(org-agenda-files (quote ("~/orgmode")))
 '(org-agenda-log-mode-items (quote (clock)))
 '(org-agenda-skip-scheduled-if-done t)
 '(org-agenda-span (quote day))
 '(org-agenda-start-with-clockreport-mode t)
 '(org-agenda-start-with-follow-mode t)
 '(org-agenda-start-with-log-mode t)
 '(org-capture-templates (quote (org-bbdb org-bibtex org-docview org-gnus org-info org-jsinfo org-habit org-irc org-mew org-mhe org-rmail org-vm org-wl org-w3m) (("R" "Autofill RT ticket" entry (file "~/org/all.org") "** TODO [#A] %?") ("r" "RT Ticket" entry (file "~/org/all.org") "** TODO RT #%^{Number} -- %^{Subject}") ("t" "TODO" entry (file "~/org/all.org") "** TODO %^{TODO}") ("q" "Question" entry (file "~/org/all.org") "** Q from %^{Who} re: %^{Subject}") ("i" "Random Item" entry (file "~/org/all.org") "** %^{What}")) (quote (org-clock-continuously t)) (quote (org-clock-into-drawer t)) (quote (org-default-notes-file "~/org/TODO.org")) (quote (org-default-priority 65)) (quote (org-log-done (quote time))) (quote (org-stuck-projects (quote ("+PROJECT/-MAYBE-DONE" ("TODO" "NBIJ" "Waiting" "NEXT" "NEXTACTION") nil "")))) (quote (perl-indent-level 8)) (quote (post-fixed-signature-source "~/.signature")) (quote (post-should-prompt-for-attachment (quote Never))) (quote (require-final-newline t)) (quote (safe-local-variable-values (quote ((mangle-whitespace . t) (rm-trailing-spaces . t))))) (quote (scroll-bar-mode -1)) (quote (send-mail-function (quote sendmail-send-it))) (quote (setq c-basic-offset)) (quote (shell-file-name "/bin/bash")) (quote (show-paren-mode 1)) (quote (spell-command "ispell")) (quote (split-window-preferred-function nil)) (quote (standard-indent 8)) (quote (uniquify-buffer-name-style (quote post-forward) nil (uniquify))) (quote (uniquify-min-dir-content 2)) (quote (vc-follow-symlinks nil)) (quote (w3m-use-cookies t)) (quote (wg-morph-on nil)) (quote (win-switch-idle-time 1.25)) (quote (x-select-enable-clipboard t))))
 '(org-default-notes-file "~/orgmode/TODO.org")
 '(org-log-into-drawer t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-done ((t (:foreground "PaleGreen" :weight normal :strike-through t))))
 '(org-headline-done ((((class color) (min-colors 16) (background dark)) (:foreground "LightSalmon" :strike-through t))))
 '(org-level-1 ((t (:inherit nil :foreground "#cb4b16" :height 1.3))))
 '(org-level-2 ((t (:inherit nil :foreground "#859900" :height 1.2))))
 '(org-level-3 ((t (:inherit nil :foreground "#268bd2" :height 1.15))))
 '(org-level-4 ((t (:inherit nil :foreground "#b58900" :height 1.1))))
 '(org-level-5 ((t (:inherit nil :foreground "#2aa198"))))
 '(org-level-6 ((t (:inherit nil :foreground "#859900"))))
 '(org-level-7 ((t (:inherit nil :foreground "#dc322f"))))
 '(org-level-8 ((t (:inherit nil :foreground "#268bd2")))))
