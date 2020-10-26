;;; x-hugh-hydra --- Hydra stuff

;;; Commentary:

;;; Code:

;; ONE MENU TO RULE THEM ALL
(defhydra hydra-menu (:exit t)
  "menu"
  ("a" hydra-apropos/body "apropos")
  ("d" hydra-dev/body "dev")
  ("e" hydra-elisp/body "elisp")
  ("g" hydra-golang/body "go")
  ("i" hydra-personal-files/body "personal files")
  ("j" hydra-copy-lines/body "copy lines")
  ("n" hydra-goto/body "navigate")
  ("t" hydra-text/body "text")
  ("v" hydra-vinz/body "Vinz")
  ("w" hydra-window/body "window")
  ("y" hydra-python/body "python")
  ("z" hydra-zoom/body "zoom"))

(defhydra hydra-apropos (:exit t)
  ("a" apropos "apropos")
  ("d" apropos-documentation "documentation")
  ("v" apropos-variable "variable")
  ("c" apropos-command "command")
  ("l" apropos-library "library")
  ("u" apropos-user-option "option")
  ("e" apropos-value "value"))

(defhydra hydra-dev (:exit t)
  ("a" x-hugh-git-changetype "Cycle changetype")
  ("c" x-hugh-git-connects-to "Connects-to")
  ("g" x-hugh-grx "grx")
  ("j" json-pretty-print-buffer "pretty-print json")
  ("l" linum-mode "linum")
  ("L" global-linum-mode "global-linum")
  )

(defhydra hydra-elisp (:exit t)
  "elisp"
  ("d" edebug-defun "edebug-defun")
  ("e" eval-defun "eval-defun")
  ("t" (setq debug-on-error t) "turn on debug-on-error")
  ("T" (setq debug-on-error nil) "turn off debug-on-error")
  )

(defhydra hydra-personal-files (:exit t)
  "personal files"
  ("a" (lambda ()
	 (interactive)
	 (find-file "/home/aardvark/saintaardvarkthecarpeted.com/astronomy.mdwn"))
   "astronomy page")
  ("b" x-hugh-edit-dot-bashrc ".bashrc")
  ("c" x-hugh-company-coming "Company coming!")
  ("d" x-hugh-die-outlook-die "die, Outlook, die")
  ("E" (magit-status "~/.emacs.d")  "Open .emacs.d in magit")
  ("e" x-hugh-edit-dot-emacs  "Open .emacs.d file")
  ("f" ag  "figl")
  ("g" x-hugh-open-git-repo "Open git repo")
  ("h" x-hugh-hi-bob "hi bob")
  ("l" (find-file "~/orgmode/log_2016.org") "Open logfile")
  ("m" (magit-status "~/.dotfiles") "Open .dotfiles in magit")
  ("o" (dired "/backup/music/ogg") "Music")
  ("p" (x-hugh-gh-git-commit-and-push-without-mercy) "Push w/o mercy")
  ("r" (x-hugh-open-password-file) "Search password file")
  ("s" (find-file "~/.ssh/config") "Open .ssh/config")
  ("t" (find-file "~/orgmode/TODO.org") "TODO"))

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

(defhydra hydra-window (:color amaranth)
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
  ("t" transpose-frame "rotate frame")
  ("o"  ace-maximize-window "ace-one" :color blue)
  ("a" ace-window "ace" :color blue)
  ("s" ace-swap-window "swap")
  ("d" ace-delete-window "del")
  ("b" ido-switch-buffer "buf")
  ("m" headlong-bookmark-jump "bmk")
  ("-" balance-windows "balance")
  (">" end-of-buffer "end-of-buffer")
  ("<" beginning-of-buffer "beg-of-buffer")
  ("/" isearch-forward "search-forward" :color blue)
  ("\\" isearch-backward "search-backward" :color blue)
  ("q" nil "cancel"))

(defhydra hydra-support (:color amaranth)
  "diagnostics"
  ("n" x-hugh-diagnostics-next-section "next diag")
  ("p" x-hugh-diagnostics-prev-section "prev diag")
  ("l" recenter-top-bottom "recenter")
  ("u" scroll-down-command "scroll up") ; weird, backwards
  ("d" scroll-up-command "scroll down")
  ("q" nil "quit")
)

(defhydra hydra-zoom (global-map "<f2>")
  "zoom"
  ("g" (text-scale-adjust 1) "zoom in current window")
  ("l" (text-scale-adjust -1) "zoom out current window")
  ("0" (progn (text-scale-adjust 0) (maximize-frame)) "reset")
  ("j" winner-undo "winner-undo")
  ("k" winner-redo "winner-redo")
  ("s" x-hugh-solarized-toggle "toggle solarized")
  ("t" x-hugh-set-theme-for-terminal "nice terminal theme")
  ;; FIXME: `set-face-attribute` is "mostly intended for internal use only" ☹
  ("z" (x-hugh-increase-default-face-height) "zoom in all")
  ("a" (x-hugh-decrease-default-face-height) "zoom out all")
  ("x" toggle-frame-maximized "toggle max"))

(defhydra hydra-text (:color blue)
  ("'" toggle-quotes "Toggle single/double quotes")
  ("a" align-values "align regions")
  ("b" x-hugh-boxquote-yank-and-indent "boxquote-yank-indent")
  ("c" x-hugh-git-changetype "git-changetype")
  ("d" x-hugh-markdown-footnote "markdown footnote")
  ("f" ag "figl (actually ag, but who cares)")
  ("g" x-hugh-git-changetype "Change patch type")
  ("i" indent-defun "indent-defun")
  ("l" display-line-numbers-mode "line numbers")
  ("p" smartparens-mode "Toggle smartparens mode")
  ("r" replace-region-command-output "Replace region with shell command")
  ("s" delete-trailing-whitespace "Delete trailing whitespace")
  ("t" x-hugh-markdown-code-block "Markdown code block")
  ("v" view-lines-mode "view-lines-mode"))

;; FIXME: Add a hydra for shell.  Or maybe just a keyboard shortcut.

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
  ("h" x-hugh-highlight-indentation-mode-toggle "Toggle indentation highlight")
  ("f" x-hugh-python-fixme "FIXME"))

;; Load x-hugh-hydra-local.el if present
(require 'x-hugh-hydra-local "x-hugh-hydra-local.el" t)

(provide 'x-hugh-hydra)
;;; x-hugh-hydra.el ends here
