;;; x-hugh-hydra --- Hydra stuff

;;; Commentary:

;;; Code:

;; ONE MENU TO RULE THEM ALL
(defhydra hydra-menu (:exit t)
  "menu"
  ("a" hydra-apropos/body "apropos")
  ("e" hydra-elisp/body "elisp")
  ("g" hydra-golang/body "go")
  ("i" hydra-personal-files/body "personal files")
  ("j" hydra-copy-lines/body "copy lines")
  ("n" hydra-goto/body "navigate")
  ("p" hydra-puppet/body "puppet")
  ("t" hydra-text/body "text")
  ("v" hydra-vinz/body "Vinz")
  ("y" hydra-window/body "window")
  ("z" hydra-zoom/body "zoom")
  )

(defhydra hydra-apropos (:exit t )
  ("a" apropos "apropos")
  ("d" apropos-documentation "documentation")
  ("v" apropos-variable "variable")
  ("c" apropos-command "command")
  ("l" apropos-library "library")
  ("u" apropos-user-option "option")
  ("e" apropos-value "value"))

(defhydra hydra-org (:exit t )
  ("a" org-agenda "agenda")
  ("c" org-capture "capture"))

(defhydra hydra-elisp (:exit t)
  "elisp"
  ("d" edebug-defun "edebug-defun")
  ("e" eval-defun "eval-defun")
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
_c_: char           _w_: word by char     _h_: headline in buffer  _o_: helm-occur
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

  ("o" helm-occur)
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
  ("a" ace-window "ace")
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

(defhydra hydra-zoom (global-map "<f2>")
  "zoom"
  ("g" (text-scale-adjust 1) "in")
  ("l" (text-scale-adjust -1) "out")
  ("0" (progn (text-scale-adjust 0) (maximize-frame)) "reset")
  ("j" winner-undo "winner-undo")
  ("k" winner-redo "winner-redo")
  ("s" x-hugh-solarized-toggle "toggle solarized")
  ("z" x-hugh-appearance-make-things-bigger "zoom in all")
  ("a" x-hugh-appearance-make-things-smaller "zoom out all")
  ("x" toggle-frame-maximized "toggle max"))

(defhydra hydra-text (:color blue)
  ("'" ruby-toggle-string-quotes "Toggle single/double quotes")
  ("a" align-values "align regions")
  ("b" x-hugh-boxquote-yank-and-indent "boxquote-yank-indent")
  ("f" ag "figl (actually ag, but who cares)")
  ("i" indent-defun "indent-defun")
  ("l" display-line-numbers-mode ("line numbers"))
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

;; Load x-hugh-hydra-local.el if present
(require 'x-hugh-hydra-local "x-hugh-hydra-local.el" t)

(provide 'x-hugh-hydra)
;;; x-hugh-hydra.el ends here
