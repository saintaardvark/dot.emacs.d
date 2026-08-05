;;; -*- lexical-binding: t -*-
;;; x-hugh-claude --- Claude Code in Emacs, caged by nono

;;; Commentary:

;; Take 2: claude-code-ide.el instead of claude-code.el + monet.
;;
;; The monet route (see branch claude-nono) got a provably healthy
;; websocket between the sandboxed CLI and Emacs, but the model never
;; received its mcp__ide tools (NO_IDE_DIAGNOSIS.md, TODO-claude.md).
;; claude-code-ide.el implements the same IDE protocol with its own
;; MCP websocket server; claude still runs in a ghostel buffer,
;; still confined by nono via bin/claude-nono, which translates
;; CLAUDE_CODE_SSE_PORT into a nono --open-port hole (claude-code-ide
;; uses the same env var).
;;
;; TODO(nono): network is currently WIDE OPEN.  Tighten with
;; --allow-domain in bin/claude-nono -- see the big comment there.
;;
;; Keybindings (here, not x-hugh-keymap, so use-package can autoload):
;;   C-c c -> claude-code-ide-menu
;;   C-c N -> x-hugh-claude-notes

;;; Code:

;; The ghostel terminal backend needs ghostel loaded.
(require 'x-hugh-ghostel)

(defcustom x-hugh-claude-notes-file "NOTES-claude.md"
  "File (relative to the project root) where Claude keeps running notes."
  :type 'string
  :group 'tools)

(defun x-hugh-claude-notes ()
  "Show the project's Claude running-notes file in a right side window.
The buffer auto-reverts, so it live-updates as Claude writes to it."
  (interactive)
  (require 'project)
  (let* ((proj (project-current))
         (root (if proj (project-root proj) default-directory))
         (buf (find-file-noselect
               (expand-file-name x-hugh-claude-notes-file root))))
    (with-current-buffer buf
      (auto-revert-mode 1))
    (display-buffer-in-side-window
     buf '((side . right) (window-width . 0.4)))))

(use-package claude-code-ide
  :vc (:url "https://github.com/manzaltu/claude-code-ide.el" :rev :newest)
  :bind (("C-c c" . claude-code-ide-menu)
         ("C-c N" . x-hugh-claude-notes))
  :custom
  (claude-code-ide-terminal-backend 'ghostel)
  (claude-code-ide-cli-path
   (expand-file-name "bin/claude-nono" user-emacs-directory))
  (claude-code-ide-system-prompt
   "You are running inside Emacs with IDE integration.  To show the \
user a file or location, use the IDE's openFile tool, never \
emacsclient (you cannot see whether emacsclient worked).  While \
working on nontrivial tasks, keep running notes -- current plan, \
discoveries, explanations -- in NOTES-claude.md at the project root, \
updating as you go; the user watches that file live in a side \
window."))

(provide 'x-hugh-claude)

;;; x-hugh-claude.el ends here
