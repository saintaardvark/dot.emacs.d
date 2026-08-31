# NOTES-claude

## 2026-08-31 — standalone nono wrapper, then step A of the network plan

Branch `nono-network-filtering`.  Working through, in order:

1. plan: record what changed since 2026-08-05 (findings re-checked
   against nono 0.71.0 on this machine, not assumed);
2. plan: add change D, a standalone wrapper so nono gets used outside
   Emacs too;
3. write that wrapper (`bin/nono-here`);
4. step A: draft the `claude-local` profile, validate, and promote it
   if promotion is possible from inside the sandbox.

Findings so far, all verified here today:

- **`--allow-cwd` grants nothing under the `default` profile.**  It
  applies the *profile's* workdir level, and `default` has none.  The
  claude pack profile sets `Workdir access: ReadWrite`, which is why
  `bin/claude-nono` works.  A general-purpose wrapper must pass
  `-a "$PWD"` explicitly.
- **`/tmp/claude-$UID` is now granted by the pack profile itself**, so
  the `--allow "$harness_tmp"` line in `bin/claude-nono` is redundant.
- **`nono` reads `NONO_ALLOW_DOMAIN` natively** and a comma-separated
  value does flip it into proxy mode, but I could not see the resolved
  domain list from `--dry-run`, so I have not confirmed the split
  actually yields two entries.  Keeping the wrapper's own word-split
  variable rather than depending on it.
- **`nono why` ignores env/flag overrides**; it answers from the
  profile alone.  Fine for the rollout checks, which are per-profile.
- The `git_config` group covers `~/.gitconfig` and `~/.config/git/*`
  but *not* `/etc/gitconfig` -- finding 3 of the plan still stands.
  `GIT_CONFIG_NOSYSTEM=1` in front of every git call is the current
  workaround.
- `~/.githooks_global` is unreadable in here too: `git checkout`
  succeeded but its `post-checkout` hook failed to exec.

## 2026-08-04 21:26 PDT — prompt editing now opens in Emacs

`bin/claude-nono` exports `EDITOR=VISUAL=emacsclient`, so claude's
external-editor key stops landing in vi. One line of real change; the
interesting part was finding out how little was needed.

The TODO expected a fight — TCP server plus `--open-port`, or an
`--allow` on the socket directory. None of that was necessary. nono
mediates *directory reads* but not `connect()` on a unix socket:
`ls /run/user/1000/emacs` is denied and `nono why` on the socket path
reports `path_not_granted`, yet `emacsclient --eval '(+ 1 1)'` answers
`2` from inside the sandbox. The stock unix-socket server is reachable
as-is.

Verified the whole round trip rather than just the connection:
emacsclient blocked, the buffer opened in Emacs, `C-x #` released it
with exit 0, and the sandboxed side read back the edited text.

`EDITOR` is a bare word deliberately. Multi-word values like
`emacsclient -a vi` are conventional, but only work if the caller
routes through a shell; if claude `exec`s it directly, the whole thing
fails to resolve. `XDG_RUNTIME_DIR` passes through the sandbox, so
emacsclient finds the default socket without `-s`.

**Security note, worth more than the feature.** The TODO says nono is
"the only boundary" now that claude runs with
`--dangerously-skip-permissions`. That is not true, and was not true
before this change: `mcp__ide__executeCode` evaluates arbitrary elisp
in the Emacs running *outside* the sandbox. I used it repeatedly in
this session. So the model can already run unconfined code, and an
`--allow-domain` allowlist will constrain the sandboxed process but
not elisp evaluated in Emacs. Reaching the server socket via
emacsclient is the same hole by a different door, which is why I was
comfortable doing it — but the mitigation, if wanted, lives on the
Emacs side, not in the nono profile.

Incidental: git is broken in the sandbox — `/etc/gitconfig` is denied
and git treats that as fatal. `GIT_CONFIG_NOSYSTEM=1` works around it.
Worth adding to the profile or the wrapper if it keeps biting.

## 2026-08-04 20:17 PDT — line counts for the x-hugh files

87 files matching `x-hugh*`, **6477 lines total**, mean 74, median 35.
All but two live in `lisp/`: `x-hugh-custom.el` (40) sits at the repo
root alongside the `lisp/` copy of the same name (54), and
`snippets/emacs-lisp-mode/x-hugh` (13) is a snippet, not elisp.

Sorted by size:

| Lines | File (under `lisp/` unless noted) |
|---:|---|
| 406 | x-hugh-functions.el |
| 369 | x-hugh-org.el |
| 365 | x-hugh-hydra.el |
| 354 | x-hugh-pi.el |
| 330 | x-hugh-magit.el |
| 329 | x-hugh-appearance.el |
| 321 | x-hugh-rt.el |
| 249 | x-hugh-blog.el |
| 220 | x-hugh-text.el |
| 197 | x-hugh-python.el |
| 181 | x-hugh-keymap.el |
| 150 | x-hugh-projectile.el |
| 141 | x-hugh-init.el |
| 133 | x-hugh-email.el |
| 115 | x-hugh-dubcaps.el |
| 112 | x-hugh-random.el |
| 111 | x-hugh-markdown.el |
| 108 | x-hugh-claude.el |
| 99 | x-hugh-shared-keymap.el |
| 86 | x-hugh-elpa.el |
| 83 | x-hugh-jira.el |
| 81 | x-hugh-navi.el |
| 81 | x-hugh-reference.el |
| 80 | x-hugh-typescript.el |
| 69 | x-hugh-combobulate.el |
| 66 | x-hugh-smartparens.el |
| 65 | x-hugh-rebuilder.el |
| 64 | x-hugh-shell.el |
| 60 | x-hugh-eglot.el |
| 55 | x-hugh-gh.el |
| 54 | x-hugh-custom.el |
| 54 | x-hugh-dired.el |
| 50 | x-hugh-yasnippet.el |
| 49 | x-hugh-golang.el |
| 47 | x-hugh-gh-transient.el |
| 45 | x-hugh-treesitter.el |
| 44 | x-hugh-dubldubl.el |
| 44 | x-hugh-ghostel.el |
| 40 | x-hugh-custom.el *(repo root)* |
| 39 | x-hugh-company.el |
| 39 | x-hugh-terraform.el |
| 38 | x-hugh-html.el |
| 38 | x-hugh-mouse.el |
| 37 | x-hugh-helm.el |
| 36 | x-hugh-sideline.el |
| 35 | x-hugh-passwords.el |
| 35 | x-hugh-window-layout.el |
| 32 | x-hugh-modes.el |
| 30 | x-hugh-dashboard.el |
| 29 | x-hugh-finally.el |
| 28 | x-hugh-ruby.el |
| 26 | x-hugh-compile-mode.el |
| 23 | x-hugh-flycheck.el |
| 20 | x-hugh-folding.el |
| 19 | x-hugh-apache.el |
| 19 | x-hugh-arduino.el |
| 19 | x-hugh-fixmee.el |
| 18 | x-hugh-pomm.el |
| 17 | x-hugh-perl.el |
| 17 | x-hugh-swiper.el |
| 16 | x-hugh-abbrev.el |
| 16 | x-hugh-all-the-icons.el |
| 16 | x-hugh-docker.el |
| 16 | x-hugh-m-x.el |
| 16 | x-hugh-midnight-mode.el |
| 16 | x-hugh-packages.el |
| 16 | x-hugh-uniquify.el |
| 16 | x-hugh-vterm.el |
| 15 | x-hugh-annoying-arrows.el |
| 15 | x-hugh-highlight-indent-guide.el |
| 15 | x-hugh-nyan.el |
| 15 | x-hugh-tramp.el |
| 14 | x-hugh-ansible.el |
| 14 | x-hugh-linum.el |
| 14 | x-hugh-ssh.el |
| 14 | x-hugh-xclip.el |
| 13 | x-hugh-ace.el |
| 13 | x-hugh-boxquote.el |
| 13 | x-hugh-browse-kill-ring.el |
| 13 | x-hugh-delsel.el |
| 13 | x-hugh-make.el |
| 13 | x-hugh-multiple-cursors.el |
| 13 | x-hugh-paren.el |
| 13 | x-hugh-winner.el |
| 13 | x-hugh-yaml.el |
| 13 | x-hugh *(snippets/emacs-lisp-mode/)* |
| 2 | x-hugh-TODO.org |

Shape of it: a long tail of ~13-19 line `use-package` stubs (37 files
at 20 lines or under, together under 600 lines), and seven files over
300 that hold most of the actual configuration.

## 2026-08-04 20:15 PDT — monet IDE tools not reaching Claude

I have no `openFile` / `getDiagnostics` / other monet MCP tools in this
session, even though `/ide` reports a successful connection.

Full diagnosis in [NO_IDE_DIAGNOSIS.md](NO_IDE_DIAGNOSIS.md).

Short version: the transport is fine (one live lockfile, port 48615
reachable from inside the nono sandbox, `CLAUDE_CODE_SSE_PORT` not
stripped). The failure is above it — most likely the tool list is
frozen at session start, so a mid-session `/ide` reconnect can't
retrofit tools. Needs checks run from Emacs, outside the sandbox; those
are listed at the end of that file.
