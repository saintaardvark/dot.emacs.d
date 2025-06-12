;;; x-hugh-hydra --- Hydra stuff

;;; Commentary:

;;; Code:

(use-package hydra
  :ensure t)

;; ONE MENU TO RULE THEM ALL
(defhydra hydra-menu (:exit t)
  "menu"
  ("a" hydra-apropos/body "apropos")
  ("d" hydra-dev/body "dev")
  ("e" hydra-elisp/body "elisp")
  ("f" hydra-web/body "web")
  ("g" hydra-golang/body "go")
  ("i" hydra-personal-files/body "personal files")
  ("j" hydra-copy-lines/body "copy lines")
  ("n" hydra-goto/body "navigate")
  ("o" hydra-org/body "org")
  ("r" hydra-emoji/body "emoji")
  ("t" hydra-text/body "text")
  ("w" hydra-window/body "window")
  ("y" hydra-python/body "python")
  ("z" hydra-zoom/body "zoom")
  )

(defhydra hydra-elscreen (:exit t)
  ("s" elscreen-start "start elscreen - do this if you get wrong-type-error")
  ("c" elscreen-create "create") ;; Not sure why, but emacs doesn't like this
  ("i" elscreen-screen-nickname "nickname")
  ("k" elscreen-kill "kill")
  ("n" elscreen-next "next")
  ("p" elscreen-previous "previous")
  ("'" elscreen-goto "goto")
  ("j" elscreen-jump "jump")
  )

(defhydra hydra-apropos (:exit t)
  ("a" apropos "apropos")
  ("d" apropos-documentation "documentation")
  ("v" apropos-variable "variable")
  ("c" apropos-command "command")
  ("l" apropos-library "library")
  ("u" apropos-user-option "option")
  ("e" apropos-value "value"))

(defhydra hydra-dev (:exit t)
  ("a" eglot-code-actions "Eglot code actions")
  ("b" x-hugh-blank-pr "Blank PR")
  ("c" (describe-keymap combobulate-key-map) "Combobulate keymap")
  ("d" (x-hugh-open-preferred-repo-dir) "Dev dir")
  ("e" eglot "eglot")
  ("f" flycheck-mode "Flycheck mode")
  ("g" x-hugh-gpc "Run gh pr create in this repo")
  ("G" x-hugh-grx "grx")
  ("j" json-pretty-print-buffer "pretty-print json")
  ("l" display-line-numbers-mode "linum") ; FIXME: Make this emacs-version dependent
  ("L" global-linum-mode "global-linum")
  ("m" flymake-show-project-diagnostics "flymake-show-project-diagnostics")
  ("o" browse-url-xdg-open "Open in browser") ; FIXME: Wrong place
  ("p" (x-hugh-gh-git-commit-and-push-without-mercy) "Push w/o mercy")
  ("r" eglot-rename "eglot-rename")
  ("s" x-hugh-projectile-switch-to-scratch-project "Projectile: switch to scratch project")
  ("S" x-hugh-open-preferred-repo-dir-scratch-repos "Dired scratch repos")
  ("t" x-hugh-spinoff-branch-named-after-current-one "Spinoff branch named after current")
  ("T" x-hugh-spinoff-branch-named-after-a-ticket "Spinoff branch named after ticket")
  ("U" x-hugh-update-projectile-known-projects-list)
  ("x" xref-find-references "xref-find-references")
  ("[" eldoc-box-hover-mode "eldoc hover mode")
  ("]" eldoc-box-hover-at-point-mode "eldoc hover at point mode")
  ("=" x-hugh-move-to-next-assignment-value "=")
  )

(defhydra hydra-elisp (:exit t)
  "elisp"
  ("d" edebug-defun "edebug-defun")
  ("e" eval-defun "eval-defun")
  ("g" x-hugh-edit-dot-emacs  "Open .emacs.d file")
  ("G" (magit-status "~/.emacs.d")  "Open .emacs.d in magit")
  ("h" x-hugh-jump-to-hydra "Jump to hydra")
  ("l" list-packages "list-packages")
  ("t" (setq debug-on-error t) "turn on debug-on-error")
  ("T" (setq debug-on-error nil) "turn off debug-on-error")
  ("x" macroexpand-point "Expand macro at point")
  ("s" (dired "~/.emacs.d/snippets") "Show snippets directory")
  ("y" yas-describe-tables "Show snippets")
  ("z" yas-reload-all "Reload all snippets")
  ("X" save-buffers-kill-emacs "Exit Emacs")
  )

(defhydra hydra-personal-files (:exit t)
  "personal files"
  ("a" (dired "~/.local/share/applications") "Desktop shortcuts")
  ("b" x-hugh-edit-dot-bashrc ".bashrc")
  ("B" (find-file "~/.bashrc_local") ".bashrc_local")
  ("c" x-hugh-company-coming "Company coming!")
  ("d" x-hugh-die-outlook-die "die, Outlook, die")
  ("D" (find-file "~/.local/share/applications") "Open desktop shortcuts directory")
  ("e" (dired "~/bin") "~/bin")
  ("g" x-hugh-open-git-repo "Open git repo")
  ("h" x-hugh-hi-bob "hi bob")
  ("l" x-hugh-hugh-va7unx "hugh@va7unx.space")
  ("m" (magit-status "~/.dotfiles") "Open .dotfiles in magit")
  ("o" (dired "/backup/music/ogg") "Music")
  ("p" (image-dired "~/Pictures") "Pictures")
  ("r" (x-hugh-open-password-file) "Open password file")
  ("R" (find-file "~/.config/run-or-raise/shortcuts.conf") "Edit run-or-raise")
  ("s" (find-file "~/.ssh/config") "Open .ssh/config")
  ("u" (calculator) "Calculator")
  ("w" (image-dired "~/Pictures/Wallpaper") "Wallpaper")
  ("x" (dired "~/Downloads" "-l --sort=time") "Downloads") ; newest first
  ("y" (calendar) "Calendar")
  )

(defhydra hydra-copy-lines (:exit t)
  "Shortcuts for copying lines/regions."
  ("c" x-hugh-copy-and-comment-region "Copy and comment region")
  ("l" x-hugh-copy-and-comment-line "Copy and comment line"))

;; http://kitchingroup.cheme.cmu.edu/blog/2015/09/28/A-cursor-goto-hydra-for-emacs/
(defhydra hydra-goto (:color blue :hint nil)
  "
Goto:
^Char^              ^Word^                ^org^                    ^search^
^^^^^^^^---------------------------------------------------------------------------
_c_: char           _w_: word by char     _h_: headline in buffer  _o_: helm-swiper
_2_: 2 chars        _W_: some word        _a_: heading in agenda   _p_: helm-swiper
_L_: char in line                       _q_: swoop org buffers   _f_: search forward
^  ^                                    ^ ^                      _b_: search backward
-----------------------------------------------------------------------------------
_B_: helm-buffers       _g_: avy-goto-line  _C_: avy-copy-line  _y_: show snippets
_m_: helm-mini          _i_: ace-window
_R_: helm-recentf
_x_: helm-M-x

_'_: Delete trailing whitespace               _._: mark position _/_: jump to mark
"
  ("c" avy-goto-char)
  ("2" avy-goto-char-2)
  ("L" avy-goto-char-in-line)
  ("w" avy-goto-word-1)
  ;; jump to beginning of some word
  ("W" avy-goto-word-0)
  ;; jump to subword starting with a char

  ("g" avy-goto-line)
  ("i" ace-window)
  ("C" avy-copy-line)

  ("h" helm-org-headlines)
  ("a" helm-org-agenda-files-headings)
  ("q" helm-multi-swoop-org)
  ("x" helm-M-x)

  ("o" swiper-helm)
  ("p" swiper-helm)

  ("f" isearch-forward)
  ("b" isearch-backward)

  ("." org-mark-ring-push :color red)
  ("/" org-mark-ring-goto :color blue)
  ("B" helm-buffers-list)
  ("m" helm-mini)
  ("R" helm-recentf)
  ("y" yas-describe-tables)
  ("'"  delete-trailing-whitespace "Delete trailing whitespace"))

(defhydra hydra-window (:color amaranth :timeout 5)
  "window"
  ("h" windmove-left)
  ("j" windmove-down)
  ("k" windmove-up)
  ("l" windmove-right)
  ("v" (lambda ()
         (interactive)
         (split-window-right)
         (windmove-right))
   "vert")
  ("x" (lambda ()
         (interactive)
         (split-window-below)
         (windmove-down))
   "horz")
  ("t" transpose-frame "rotate frame") 	; TODO: Use https://p.bauherren.ovh/blog/tech/new_window_cmds for these
  ("o"  ace-maximize-window "ace-one" :color blue)
  ("a" ace-window "ace-windowe" :color blue)
  ("s" ace-swap-window "swap")
  ("d" ace-delete-window "del")
  ("b" ido-switch-buffer "buf")
  ("m" headlong-bookmark-jump "bmk")
  ("-" balance-windows "balance")
  (">" end-of-buffer "end-of-buffer")
  ("<" beginning-of-buffer "beg-of-buffer")
  ("/" isearch-forward "search-forward" :color blue)
  ("\\" isearch-backward "search-backward" :color blue)
  ("!" comint-previous-input "!" :color blue)
  ("q" nil "cancel"))

(defhydra hydra-zoom (global-map "<f2>")
  "zoom"
  ("g" (text-scale-adjust 1) "zoom in current window")
  ("l" (text-scale-adjust -1) "zoom out current window")
  ("0" (progn (text-scale-adjust 0) (maximize-frame)) "reset")
  ("1" (x-hugh-set-font-larger) "Set to 16 point Inconsolata")
  ("2" (x-hugh-set-font-largest) "Set to 20 point Inconsolata")
  ("3" (x-hugh-set-font-zomg) "Set to 30 point Inconsolata")
  ("7" (x-hugh-set-font-smol) "Set to 8 point Inconsolata")
  ("8" (x-hugh-set-font-semi-smol) "Set to 12 point Inconsolata")
  ("j" winner-undo "winner-undo")
  ("k" winner-redo "winner-redo")
  ("s" x-hugh-solarized-toggle "toggle solarized")
  ("t" x-hugh-set-theme-for-terminal "nice terminal theme")
  ;; FIXME: `set-face-attribute` is "mostly intended for internal use only" ☹
  ("z" (x-hugh-increase-default-face-height) "zoom in all")
  ("a" (x-hugh-decrease-default-face-height) "zoom out all")
  ("x" toggle-frame-maximized "toggle max")
  ("-" x-hugh-appearance-make-things-smaller "Decrease font size")
  ("=" x-hugh-appearance-make-things-bigger "Increase font size")
  )

(defhydra hydra-text (:color blue)
  ("'" toggle-quotes "Toggle single/double quotes") ; FIXME: I don't have this function!
  ("," ispell-word "ispell word")
  ("." delete-horizontal-space "delete horizontal space")
  ("a" align-values "align regions")
  ("b" x-hugh-boxquote-yank-and-indent "boxquote-yank-indent")
  ("c" x-hugh-git-changetype "git-changetype")
  ("d" x-hugh-markdown-footnote "markdown footnote")
  ("e" x-hugh-details-summary "<details>")
  ("E" x-hugh-details-surround "<details>, but surround")
  ("f" auto-fill-mode "Toggle fill mode")
  ("g" x-hugh-git-changetype "Change patch type")
  ("i" x-hugh-italiano "italiano")
  ("j" x-hugh-expand-jira "Expand Jira URL")
  ("J" x-hugh-jira-url)
  ("k" x-hugh-korect-speling "Add abbrev to turn mispeld word-at-point into KORECSHUN")
  ("l" display-line-numbers-mode "line numbers")
  ("m" x-hugh-gh-pr-munge-text "pr munge")
  ("n" x-hugh-fcc-nwcah "Fcc: =nwcah")
  ("o" occur "occur")
  ("p" smartparens-mode "Toggle smartparens mode")
  ("r" query-replace "Query-replace")
  ("R" replace-region-command-output "Replace region with shell command")
  ("s" delete-trailing-whitespace "Delete trailing whitespace")
  ("t" x-hugh-markdown-code-block "Markdown code block")
  ("v" visual-line-mode "visual-lines-mode")
  )

(defhydra hydra-shell ()
  "shell"
  ("n" comint-next-input "Previous input")
  ("p" comint-previous-input "Previous input")
  ("s" x-hugh-launch-shell "Launch shell")
  )

(defhydra hydra-org (:exit t) 		; Inconsistent with metaleft/right; may have to adjust this in the future
  "org"
  ("a" (org-agenda nil "a") "Agenda for today")
  ("b" (find-file "~/orgmode/books.org.txt") "Books.org")
  ("c" (org-capture) "Capture")
  ("d" (find-file "~/orgmode/dad.org") "Dad")
  ("f" (find-file "~/orgmode/fun_projects/fun_projects.org") "Fun projects")
  ("h" x-hugh-org-toggle-heading-save-excursion "Toggle heading")
  ("H" org-html-export-to-html "Export to HTML file")
  ("j" (progn
	 (find-file "~/orgmode/journal.org")
	 (goto-char (point-max))) "Journal")
  ("l" (org-capture nil "l") "org-capture log")
  ("r" (org-refile) "refile")
  ("t" (org-agenda nil "t") "Show TODOs")
  ("w" (org-agenda-list 7) "Agenda for week")
  ("y" (progn
	 (find-file "~/orgmode/climate/climate_letters.org")
	 (goto-char (point-max))) "Climate Letters")
  ("," (call-interactively 'org-insert-structure-template) "Insert template (quote, src, etc)")
  ("u" (org-metaleft) "Org metaleft")
  ("i" (org-metaright) "Org metaright")
  )

(defhydra hydra-golang ()
  "golang"
  ("d" x-hugh-golang-insert-log-debug "debug")
  ("o" (dired "~/go/src") "Browse ~/go/src")
  ("s" (dired "/usr/local/go/src") "Browse GOROOT/src"))

;; TODO: You could imagine this being something that is
;; mode-appropriate.  Like, x-hugh-insert-fixme, figure out mode,
;; figure out what that looks like.
(defhydra hydra-python (:exit t)
  "python"
  ("b" python-black-buffer "Black buffer")
  ("c" conda-env-activate "Activate conda env")
  ("d" conda-env-deactivate "Deactivate conda env")
  ("e" ein:run "Start jupyter server with ein")
  ("l" ein:login "Log into already-running jupyter server with ein")
  ("h" x-hugh-highlight-indentation-mode-toggle "Toggle indentation highlight")
  ("f" x-hugh-python-fixme "FIXME")
  ("r" run-python "Python shell")
  ("v" pyvenv-activate "pyvenv-activate")
  ("V" (dired ".venv/lib/python3.11/site-packages") "Venv site-packages dir")
  )

(defhydra hydra-web ()
  "web"
  ("s" web-mode-surround "Surround with tag")
  )

(defhydra hydra-emoji ()
  ("b" (insert "💪") "💪")
  ("c" (insert "🤞") "🤞")
  ("C" (insert "✅") "✅")
  ("d" (insert "ಠ_ಠ") "ಠ_ಠ")
  ("f" (insert "🤦") "🤦")
  ("g" (insert "😬") "😬")
  ("h" (insert "❤️" ) "❤️")
  ("H" (insert "😍" ) "😍")
  ("l" (insert "🤣") "🤣")
  ("r" (insert "ヽ( ಠ益ಠ )ﾉ") "ヽ( ಠ益ಠ )ﾉ")
  ("m" (insert "ヽ(。_°)ノ") "ヽ(。_°)ノ")
  ("o" (insert "😮") "😮")
  ("p" (insert "🥳") "🥳")
  ("P" (insert "👉") "👉")
  ("s" (insert "¯\\_(ツ)_/¯") "¯\\_(ツ)_/¯")
  ("t" (insert "(╯°□°)╯︵ ┻━┻") "(╯°□°)╯︵ ┻━┻")
  ("T" (insert "👍") "👍")
  ("x" (insert "❌") "❌")
  ("w" (insert "⚠️") "⚠️")
  ("-" (insert "😑") "😑")
  ("3" (insert "⚠️ DRAG03 ⚠️") "⚠️ DRAG03 ⚠️")
  )

(defun x-hugh-jump-to-hydra ()
  "Jump to a particular hydra definition so I can edit it."
  (interactive)
  (find-file "~/.emacs.d/lisp/x-hugh-hydra.el")
  (swiper-helm "(defhydra "))

;; Load x-hugh-hydra-local.el if present
(require 'x-hugh-hydra-local "x-hugh-hydra-local.el" t)

(provide 'x-hugh-hydra)
;;; x-hugh-hydra.el ends here
