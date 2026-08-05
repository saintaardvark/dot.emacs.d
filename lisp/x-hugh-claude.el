;;; -*- lexical-binding: t -*-
;;; x-hugh-claude --- Claude Code in Emacs, caged by nono

;;; Commentary:

;; Phase 1 of the Claude + Emacs + nono plan (see lisp/TODO-claude.md).
;;
;; claude-code.el runs the claude CLI in a ghostel buffer; monet runs
;; a websocket MCP server *inside* Emacs so Claude can open files,
;; show diffs via ediff, and see the current selection.  The CLI
;; itself is launched through bin/claude-nono, which confines it in
;; the nono sandbox (https://nono.sh) -- Emacs stays outside, same
;; arrangement as x-hugh-pi.
;;
;; monet sets CLAUDE_CODE_SSE_PORT before launch; bin/claude-nono
;; turns that into a nono --open-port hole so the sandboxed claude
;; can reach the websocket server in Emacs.
;;
;; TODO(nono): network is currently WIDE OPEN (stock
;; always-further/claude profile).  Tighten with --allow-domain in
;; bin/claude-nono -- see the big comment there.
;;
;; Keybinding: C-c c -> claude-code-command-map (set in x-hugh-keymap).

;;; Code:

;; The ghostel terminal backend needs ghostel loaded.
(require 'x-hugh-ghostel)

(defun x-hugh-claude-open-file-tool (&rest args)
  "Open a file for Claude without clobbering the claude session window.
`monet-default-open-file-tool' uses `find-file', which reuses the
selected window -- usually the claude terminal, so the file lands on
top of the session.  Hop to (or make) another window first, then hand
off to the default tool."
  (when (string-prefix-p "*claude:" (buffer-name))
    (let ((win (get-window-with-predicate
                (lambda (w)
                  (not (string-prefix-p
                        "*claude:" (buffer-name (window-buffer w))))))))
      (select-window (or win
                         (split-window-sensibly)
                         (split-window-right)))))
  (apply #'monet-default-open-file-tool args))

(use-package monet
  :vc (:url "https://github.com/stevemolitor/monet" :rev :newest)
  :custom
  (monet-open-file-tool #'x-hugh-claude-open-file-tool))

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

(use-package claude-code
  :vc (:url "https://github.com/stevemolitor/claude-code.el" :rev :newest)
  :bind (:map claude-code-command-map
              ("N" . x-hugh-claude-notes))
  :custom
  (claude-code-terminal-backend 'ghostel)
  (claude-code-program (expand-file-name "bin/claude-nono" user-emacs-directory))
  ;; nono strips env vars inside the sandbox, so the usual
  ;; CLAUDE_CODE_SSE_PORT auto-connect never happens.  --ide makes
  ;; claude connect via the ~/.claude/ide lockfile instead (works as
  ;; long as monet's is the only live lockfile for the project).
  ;;
  ;; NOTE: --ide wants *exactly one* matching lockfile.  If a session
  ;; dies uncleanly it can leave a stale lock behind, and auto-connect
  ;; will silently stop working.  Fix: delete the stale
  ;; ~/.claude/ide/<port>.lock (the live one matches the port shown by
  ;; M-x monet-list-sessions), then restart the claude session.
  (claude-code-program-switches
   '("--ide"
     "--append-system-prompt"
     "You are running inside Emacs with the monet IDE integration.  \
To show the user a file or location, use the IDE's openFile tool, \
never emacsclient (you cannot see whether emacsclient worked).  \
While working on nontrivial tasks, keep running notes -- current \
plan, discoveries, explanations -- in NOTES-claude.md at the \
project root, updating as you go; the user watches that file live \
in a side window."))
  :config
  (add-hook 'claude-code-process-environment-functions
            #'monet-start-server-function)
  (monet-mode 1))

(provide 'x-hugh-claude)

;;; x-hugh-claude.el ends here
