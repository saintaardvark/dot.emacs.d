# New features wanted

## Claude + Emacs + nono (https://nono.sh)

Phase 1 done on branch `claude-nono`: `bin/claude-nono` wrapper +
`lisp/x-hugh-claude.el` (claude-code.el + monet, ghostel backend).
First run: accept the nono pack install from a regular shell:
`nono run --profile always-further/claude -- claude --version`

- [x] nono for sandboxing
  - goal: prevent rogue agent from deleting files
  - stock `always-further/claude` profile: RW limited to cwd,
    `~/.claude`, `~/.claude.json`, `~/.local/share/claude`
- [ ] **TODO -- BIG ONE -- network filtering**: the stock profile
      allows ALL outbound traffic.  Try the `--allow-domain`
      allowlist sketched in `bin/claude-nono`.  Expect web
      search/fetch and in-sandbox pip/npm to break until their hosts
      are added too.
- [x] live within emacs -- claude-code.el in a ghostel buffer
- [ ] ability to display files claude is thinking about (phase 2)
  - monet openFile works (tested 2026-08-04 via /ide; --ide flag now
    auto-connects since nono strips the handshake env vars)
  - **fix window layout**: Claude-opened files appear on top of the
    claude session window instead of splitting into a separate one.
    Want: claude session stays put, files open in another window
    (e.g. display-buffer-alist rule, or monet's tool-function hooks)
  - also seen: agent tried `emacsclient -n +22 file` from inside the
    sandbox with no way to confirm it landed; steer it toward the
    monet openFile MCP tool instead (CLAUDE.md note?)
- [ ] split view: right-hand side has markdown artifact -- running notes,
  explanations, etc (phase 2)
  - CLAUDE.md instruction to keep running notes in NOTES-claude.md
  - live reload of markdown document using emacs markdown live preview
    mode, auto-revert-file, etc

# Refactoring Opportunities

Generated 2026-02-17 by Claude Code analysis.

---

## High Priority (Bugs / Conflicts)

- [ ] **Duplicate `org-log-done`** (`x-hugh-org.el:53,95`) — set to `t` then overwritten with `'time`. Remove line 53.

- [ ] **`eldoc-box` config conflict** (`x-hugh-eglot.el:42-50`) — `:custom` sets `800x400`, then `setq` overwrites with `900x1000`. Consolidate into one place.

- [ ] **Missing function reference** (`x-hugh-hydra.el:217`) — hydra entry calls `toggle-quotes` which doesn't exist (there's a `FIXME` comment). Remove the entry or implement the function.

---

## Medium Priority (Modernization)

- [ ] **Deprecated `defadvice`** (`x-hugh-functions.el:226-231`) — uses old `defadvice`/`ad-get-arg`/`ad-do-it` API. Replace with `advice-add`.

- [ ] **`insert-string` deprecation** (`x-hugh-org.el:250,259,366` and `x-hugh-rt.el:265`) — `insert-string` is deprecated; replace with `insert`. Similarly `insert-file` → `insert-file-contents`.

- [ ] **`python-mode` vs `python-ts-mode` inconsistency** — eglot hooks to `python-mode`, smartparens hooks to `python-mode`, but treesitter remaps to `python-ts-mode`. Standardize on `python-ts-mode`.

- [ ] **Hook style inconsistency** — some hooks use `use-package :hook`, others use standalone `add-hook` outside the `use-package` block (`x-hugh-org.el:128`, `x-hugh-python.el:172-173`, `x-hugh-keymap.el:129-131`). Consolidate into `:hook`.

- [ ] **Keybinding syntax inconsistency** (`x-hugh-keymap.el`) — mix of `(kbd "C-x ...")` and raw escape sequences like `"\C-x"`. Standardize on `(kbd "...")`.

- [ ] **Acknowledged FIXMEs** — `x-hugh-blog.el:59` notes duplication with `x-hugh-markdown.el`; `x-hugh-rt.el:148` notes a duplicate function.

---

## Low Priority (Dead Code / Cleanup)

- [ ] **Redundant keybindings** (`x-hugh-keymap.el:37-50`) — `execute-extended-command` is bound to 3 keys, then immediately overwritten by `helm-M-x` for the same keys when helm is enabled. Remove the non-helm versions (lines 37-39).

- [ ] **Unused functions** (`x-hugh-elpa.el:44-72`) — `require-package` and `maybe-require-package` are defined but never called; everything uses `use-package :ensure t`. Remove them.

- [ ] **Dead commented code** — exploratory/disabled code without explanation in:
  - `x-hugh-eglot.el` (commented `add-hook` alongside live `remove-hook`)
  - `x-hugh-python.el:22-32` (large elpy block)
  - `x-hugh-magit.el:36-37,54-57`
  - `x-hugh-org.el:174-203`
  Either remove or add a comment explaining *why* it's disabled.

- [ ] **`if` → `when`** (`x-hugh-init.el:42-45`) — single-branch `if` should be `when` idiomatically.

- [ ] **Large files to split** — `x-hugh-hydra.el` (342 lines, 13 hydra menus) and `x-hugh-functions.el` (371 lines) could be split into more focused files.

---

## Quick Wins (Safe, Mechanical Changes)

- [ ] Fix `org-log-done` duplicate (`x-hugh-org.el:53`)
- [ ] Fix `eldoc-box` conflict (`x-hugh-eglot.el:42-50`)
- [ ] Replace `insert-string` → `insert` (`x-hugh-org.el`, `x-hugh-rt.el`)
- [ ] Replace single-branch `if` → `when` (`x-hugh-init.el:42-45`)
- [ ] Remove unused `require-package` functions (`x-hugh-elpa.el:44-72`)
