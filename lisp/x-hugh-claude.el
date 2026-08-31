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
;; Outbound traffic is default-deny as of 2026-08-31, via the
;; claude-local nono profile.  See bin/claude-nono and
;; NETWORK-FILTERING-PLAN.md.
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

(defun x-hugh-claude--command-via-sh (command-string)
  "Return COMMAND-STRING as a (program . args) cons running via sh -c.
Replacement for `claude-code-ide--parse-command-string', whose
`split-string-shell-command' parse mangles multi-line arguments:
setting any `claude-code-ide-system-prompt' makes the package join it
to its built-in prompt with newlines, after which the ghostel/eat
backends misparse the tail of the prompt as the program name
\(\"Searching for program: ...side window.\").  The command string is
already shell-quoted for sh -c -- the vterm backend uses it that way
-- so just hand it to a real shell.  FIXME: report upstream."
  (cons "/bin/sh" (list "-c" command-string)))

(use-package claude-code-ide
  :vc (:url "https://github.com/manzaltu/claude-code-ide.el" :rev :newest)
  :bind (("C-c c" . claude-code-ide-menu)
         ("C-c N" . x-hugh-claude-notes))
  :config
  (advice-add 'claude-code-ide--parse-command-string :override
              #'x-hugh-claude--command-via-sh)
  :custom
  (claude-code-ide-terminal-backend 'ghostel)
  (claude-code-ide-cli-path
   (expand-file-name "bin/claude-nono" user-emacs-directory))
  ;; nono is the security boundary (same judgement call as
  ;; yolo/podman): kernel-enforced FS limits, so skip the prompt
  ;; nagging.  The egress allowlist that this leans on is now in
  ;; place -- see bin/claude-nono.
  (claude-code-ide-cli-extra-flags "--dangerously-skip-permissions")
  ;; That allowlist only binds the *sandboxed* process.  executeCode
  ;; evaluates elisp in this Emacs, outside the cage, which is an
  ;; unfiltered network path straight past it -- so the two changes
  ;; only make sense together.  openFile, openDiff and getDiagnostics,
  ;; the tools actually wanted here, are unaffected.
  ;;
  ;; This has to be set before claude-code-ide-mcp-handlers.el loads:
  ;; that file builds the tool list once, at load time, with a plain
  ;; setq (claude-code-ide-mcp-handlers.el:663) -- it is not rebuilt
  ;; per tools/list request.  :custom runs at startup and the package
  ;; is deferred, so the ordering holds; check it after a restart with
  ;;   M-: (assoc "executeCode" claude-code-ide-mcp-tools)  => nil
  (claude-code-ide-enable-execute-code nil)
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
