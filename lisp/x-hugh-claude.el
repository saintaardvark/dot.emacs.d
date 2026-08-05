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

(use-package monet
  :vc (:url "https://github.com/stevemolitor/monet" :rev :newest))

(use-package claude-code
  :vc (:url "https://github.com/stevemolitor/claude-code.el" :rev :newest)
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
  (claude-code-program-switches '("--ide"))
  :config
  (add-hook 'claude-code-process-environment-functions
            #'monet-start-server-function)
  (monet-mode 1))

(provide 'x-hugh-claude)

;;; x-hugh-claude.el ends here
