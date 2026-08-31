# NOTES-claude

## 2026-08-31 — standalone nono wrapper, then step A of the network plan

Branch `nono-network-filtering`, six commits.  Both things asked for
are done as far as they can be done from inside the sandbox; one
command from a real terminal is what is left.

### What landed

1. **Plan: findings re-checked** against nono 0.71.0 on this machine.
2. **Plan: change D**, the standalone wrapper, with its rationale.
3. **`bin/nono-here`** — sandbox the current directory and run
   something in it.  `nono-here` alone gives an interactive sandboxed
   shell; `nono-here make test` runs one command; `-R` makes cwd
   read-only, `-d HOST` adds an outbound host, `-N` kills egress,
   `-n` dry-runs, `-p` picks a profile.
4. **`nono/claude-local.json`** + `nono/README.md` — change A, the
   default-deny egress profile, tracked in the repo and staged in
   `~/.config/nono/profile-drafts/`.
5. **Plan + `lisp/TODO-claude.md`** updated to say exactly where this
   stands.

### Verified

- `nono profile validate --draft claude-local`: valid, 28 group refs ok.
- `nono why` against the draft *by path* (no promote needed):
  api.anthropic.com, platform.claude.com, github.com → ALLOWED
  (`proxy_allowed`); example.com, evil.test → DENIED
  (`proxy_filtered`); `/etc/gitconfig` read → ALLOWED.
- `nono profile show` on the draft: every pack grant still present,
  `Workdir access: ReadWrite` intact, so `extends` behaves.
- A dry run with the draft reports `net proxy`.
- `bin/nono-here -n` in its various flag combinations produces exactly
  the capability lists intended.

### Not verified, and why

- **A real `nono-here` run.**  nono cannot nest: from inside this
  sandbox it dies at `Failed to write config to
  ~/.local/state/nono/sessions/...`.  Only the dry runs are mine to
  check; the first real run has to be yours.
- **`nono profile promote`.**  It opens `/dev/tty` for its y/N review,
  which a sandboxed session does not have.  It printed the review diff
  and then failed.  This is the design working, not a bug.

### Findings worth keeping

- **`--allow-cwd` grants nothing under the `default` profile.**  It
  applies the *profile's* workdir level, and only the claude pack
  profile sets one.  `bin/nono-here` passes `-a "$PWD"` for that reason.
- **`/tmp/claude-$UID` is now in the pack profile**, so
  `--allow "$harness_tmp"` in `bin/claude-nono` is redundant.
- **`nono why` is optimistic about ports.**  It says `github.com:22`
  is ALLOWED under the draft, but proxy mode is HTTP CONNECT and the
  plan expects raw TCP:22 to have no path through it.  Trust `why` for
  443, test port 22 for real.
- **nono reads `NONO_ALLOW_DOMAIN` itself**; a comma-separated value
  does flip proxy mode on, but I could not confirm from `--dry-run`
  that the comma splits into separate entries.
- The `git_config` group covers `~/.gitconfig` and `~/.config/git/*`
  but not `/etc/gitconfig`; the profile fixes that.
- **`git commit` is broken in here**, separately: `~/.githooks_global`
  is unreadable, so `prepare-commit-msg` fails to exec and aborts the
  commit.  `--no-verify` does not skip that hook.  Every commit above
  was made with `git -c core.hooksPath=<empty dir>` plus
  `GIT_CONFIG_NOSYSTEM=1`.

### Follow-up, same day: new-machine steps + a correction

`nono/README.md` now has a "Setting all this up on a new machine"
section: install nono and check the kernel can enforce, install Claude
Code, `nono pull always-further/claude`, promote `claude-local`, then
the `nono why` checks.  It notes that Emacs needs no `PATH` entry
(`claude-code-ide-cli-path` is an absolute path built from
`user-emacs-directory`) but `bin/nono-here` does, and that steps 1-4
have to happen in a real terminal because two of them prompt.

While gathering the facts for it I found the CLI has moved on: 2.1.251
here, against 2.1.220 when the plan was written.  Re-grepping the new
binary turned up one thing the plan gets wrong:

- **`sentry.io` is in there now** -- `o1158394.ingest.us.sentry.io`
  plus `*.sentry.io` and `*.ingest.us.sentry.io`.  Finding 1 says it is
  absent.  Corrected in place.  I did *not* add it to the allowlist:
  crash reporting to a third party is the kind of egress the plan
  exists to stop.
- `statsig` is still a bare word with no domain, so that half of
  finding 1 stands.
- `downloads.claude.ai/claude` is still the update URL, so the
  allowlist entry is right.
- Also present and also deliberately omitted: `mcp-proxy.anthropic.com`
  (hosted MCP only), `claude.googleapis.com` (Vertex),
  `*.claudeusercontent.com` (web app iframes).

### Questions for when you are back

0. NOTES-claude.md is tracked now, as you asked.
1. **Promote it?**  `nono profile promote claude-local` from a plain
   terminal is the whole of what is left in step A.  Changes B and C
   must wait for it — they name a profile that does not exist yet.
2. **All four git remotes are ssh** (github, gitlab, origin=dross,
   rh).  Under proxy mode none of them will work from inside the
   sandbox, and `dross` is a LAN host with no https alternative.  So
   after promoting: the agent commits, you push.  Acceptable, or do
   you want a way around it?  (`--allow-connect-port 22` exists but is
   host-unfiltered — an exfil channel, so I would not.)
3. **`~/.githooks_global`**: grant it read in the profile so git works
   normally in here, or keep the `core.hooksPath` workaround?  Granting
   means the sandboxed agent executes those hooks, which is what you
   presumably want them for — your call, not mine.
4. **Is `~/.emacs.d/bin` on your `PATH`?**  I cannot read `~/.bashrc`
   from in here (the sandbox denies shell configs), so I could not
   check.  If not, `nono-here` wants a symlink into `~/.local/bin`, or
   it belongs in the dotfiles repo instead of this one.
5. **Name.**  `nono-here` versus `nono-run` / `sandbox` / something
   else — trivial to rename now, annoying once it is in muscle memory.
6. **`downloads.claude.ai`** is on the allowlist, so the CLI can
   self-update from inside the cage.  Keep, or make updating something
   that only happens deliberately from outside?

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
