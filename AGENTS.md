# AGENTS.md

Guidance for coding agents working in this repository.

## What this repo is

Hugh's personal Emacs configuration (`~/.emacs.d`). It targets a
locally-built Emacs with native compilation, tree-sitter, and pgtk (see
`README.md` and `emacs-compiling.org` for build notes). Licensed GPLv3
for the original code; vendored files keep their own licenses.

## Layout

- `init.el` -- thin bootstrap. Sets `package-archives`, adds `lisp/` to
  `load-path`, then `(require 'x-hugh-init)`. Do not pile config here.

- `lisp/x-hugh-init.el` -- the single entry point. Requires
  `x-hugh-elpa` first (bootstraps `use-package`), sets the custom-file,
  then loads every other module with `(use-package x-hugh-...)`. This
  file defines the load order.

- `lisp/x-hugh-*.el` -- one module per package or topic (for example
  `x-hugh-python.el`, `x-hugh-magit.el`, `x-hugh-org.el`). Each ends
  with `(provide 'x-hugh-NAME)`. This is where nearly all config lives.

- `lisp/x-hugh-elpa.el` -- package.el plus `use-package` bootstrap and
  the `require-package` / `maybe-require-package` helpers.

- `lisp/` also holds a few vendored or standalone libraries that do not
  use the `x-hugh-` prefix (for example `cfg.el`, `edit-server.el`,
  `post.el`, `ssh.el`, `xsteve-functions.el`).

- `x-hugh-custom.el` (repo root) -- the Customize custom-file. It is
  loaded by `x-hugh-init.el` via `custom-file`. Emacs writes
  `custom-set-variables` / `custom-set-faces` here.

- `modes/` -- older vendored major modes. Not on `load-path` from
  `init.el`; treat as legacy unless you confirm a live reference.

- `snippets/` yasnippet snippets, `layouts/` window layouts,
  `bin/claude-nono` a helper script, `tree-sitter/` compiled grammars.

Runtime state and installed packages are gitignored: `elpa*/`,
`eln-cache/`, `transient/`, `recentf`, `session*`, `tramp`, and more
(see `.gitignore`). Do not edit or commit these.

## Conventions

- Package management is package.el plus `use-package`. Not straight,
  not elpaca. Archives: MELPA, GNU ELPA, and org ELPA. Prefer a
  `(use-package ... :ensure t)` stanza over manual installs. One package
  from source uses `package-vc` (see `package-vc-selected-packages` in
  `x-hugh-custom.el`).

- Custom functions and variables use the `x-hugh-` prefix (for example
  `x-hugh-indent-buffer`, `x-hugh-default-conda-location`). Follow it
  for anything new.

- Personal customizations live in `lisp/x-hugh-*.el`. Config variables
  that suit a `use-package` stanza go in that package's module; the rest
  favor plain `setq` over Customize, because Customize is harder to
  debug (see the note in `x-hugh-init.el`).

- Every module sets `;;; -*- lexical-binding: t -*-` on line 1 and ends
  with a matching `(provide ...)`. Keep that shape.

- Keymaps are centralized. Actual `global-set-key` / `define-key` calls
  go in `lisp/x-hugh-keymap.el`, which loads near the end. In other
  modules leave a comment noting the binding, not the binding itself.

- To add a new module: create `lisp/x-hugh-foo.el` with the header,
  config, and `(provide 'x-hugh-foo)`, then add
  `(use-package x-hugh-foo)` to `x-hugh-init.el` at the right spot in
  the load order (languages, modes, then hydra, keymap, dashboard,
  finally last).

## Build, lint, test

- There is no build, lint, or test harness in this repo. No CI, no
  byte-compilation automation, no Makefile.

- To test a change, reload it in a running Emacs (`M-x eval-buffer`, or
  re-`require` the module) or restart Emacs. A clean check is
  `emacs --debug-init`.

- Byte/native compilation happens on demand inside Emacs; there are no
  checked-in `.elc` files to maintain.

## House style (from the user's global rules)

- No smart quotes in code or Markdown files.

- In Markdown for this repo, skip emojis and emphasis unless truly
  needed. (Existing elisp comments do use emoji; leave those as found.)

- Prefer lists over paragraphs; keep prose brief.

- Your commit headlines should end with `(written by Claude 🤖)`.
