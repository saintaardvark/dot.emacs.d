# nono profiles

Source of truth for the local [nono](https://nono.sh) profiles this
config depends on.  nono reads live profiles from
`~/.config/nono/profiles/`, which is deliberately *not* writable from
inside the sandbox, so nothing here takes effect until it is promoted
by hand.

## claude-local.json

Overlay on the registry-managed `always-further/claude` pack profile,
adding two things:

- a default-deny outbound allowlist (naming even one domain switches
  nono from "all outbound allowed" to proxy-only), and
- read access to `/etc/gitconfig`, without which git inside the
  sandbox dies with "unknown error occurred while reading the
  configuration files".

`extends` means pack updates still flow through.  Rationale, the host
list, expected breakage and rollback are in
[`../NETWORK-FILTERING-PLAN.md`](../NETWORK-FILTERING-PLAN.md).

## Promoting a change to it

    cp nono/claude-local.json ~/.config/nono/profile-drafts/
    nono profile validate --draft claude-local
    nono profile promote claude-local        # shows a diff, asks y/N

`promote` opens `/dev/tty`, so it cannot be run from inside a
sandboxed session -- it fails with `Failed to open /dev/tty`.  That is
the point: the review happens outside the cage.

**Updating a profile that is already live needs a `.base` file too.**
The three commands above are the *first* install only.  Once
`~/.config/nono/profiles/claude-local.json` exists, `promote` demands a
sibling `claude-local.base` holding the SHA-256 of the live profile's
bytes -- its way of noticing that the live profile changed while you
were drafting.  Without it:

    nono: Profile read error at ~/.config/nono/profile-drafts/claude-local.base: No such file or directory

So the update sequence is four commands, not three:

    cp nono/claude-local.json ~/.config/nono/profile-drafts/
    printf '%s' "$(sha256sum ~/.config/nono/profiles/claude-local.json | cut -d' ' -f1)" \
        > ~/.config/nono/profile-drafts/claude-local.base
    nono profile validate --draft claude-local
    nono profile promote claude-local

The `.base` file must be exactly 64 lowercase hex characters, which is
why the `printf` avoids a trailing newline.  If it no longer matches
the live profile when you promote, nono says `draft base hash does not
match current profile` -- someone changed the profile underneath you;
re-read it and redo the draft.  On success the draft file is deleted.

Before any of that, check whether there is anything to do at all:

    diff -u ~/.config/nono/profiles/claude-local.json nono/claude-local.json

Inspect a draft without promoting it, by passing the path where a
profile name would go:

    nono profile show   ~/.config/nono/profile-drafts/claude-local.json
    nono why --profile ~/.config/nono/profile-drafts/claude-local.json --host github.com

## What it is built on

The chain is three deep, and all of it has to be present:

    claude-local            ~/.config/nono/profiles/claude-local.json
      -> always-further/claude   pack 0.0.16, ~/.config/nono/packages/
           -> default            built into the nono binary

The pack profile is also registered under the bare names `claude` and
`claude-code`; `nono profile list` shows all three sources at once.

Three errors turn up around this, and only one of them means the
inheritance chain is broken:

- `Profile inheritance error: base profile 'X' not found` -- the base
  really is missing, usually because the pack was never pulled (step 3
  below).  `validate` catches this and `promote` refuses to write.

- `Profile not found: claude-local` -- nothing is broken; that name
  just is not live *yet*.  Every command that takes `--profile NAME`
  says this until the draft has been promoted.  Before then, refer to
  the draft by path instead, as in the section above.

- `Profile read error at .../claude-local.base: No such file or
  directory` -- also not an inheritance problem, despite reading like
  one.  It means the opposite of the previous error: `claude-local`
  *is* already live, so `promote` wants the hash file described above.

## Setting all this up on a new machine

Verified against nono 0.71.0, pack `always-further/claude` 0.0.16, and
Claude Code 2.1.251.  Steps 1-4 need a real terminal, not an Emacs
Claude session: two of them prompt.

1. **Install nono** from <https://nono.sh> -- a single static binary
   (~30 MB; here it lives at `~/.local/bin/nono`).  Then:

        nono setup
        nono setup --check-only     # confirms the kernel can enforce

   Linux wants Landlock V4 for TCP filtering.  This machine reports
   `Landlock V4, degraded: IoctlDev, Scoping`, which is enough.

2. **Install Claude Code** (<https://docs.claude.com/en/docs/claude-code>).
   The native install puts a versioned binary under
   `~/.local/share/claude/versions/` and symlinks `~/.local/bin/claude`
   at it.  Make sure `~/.local/bin` is on `PATH`.

3. **Pull the pack**, which is what `bin/claude-nono` names:

        nono pull always-further/claude
        nono list --installed

   The first sandboxed run will otherwise stop to ask for this, which
   is awkward inside an Emacs terminal buffer.  Same for the login: run
   `nono run --profile always-further/claude -- claude --version` once
   and complete any OAuth flow before wiring Emacs up.

4. **Promote the local profile** with the three commands under
   "Promoting a change to it" above, then confirm the policy is what
   you think it is:

        nono why --profile claude-local --host api.anthropic.com   # ALLOWED
        nono why --profile claude-local --host example.com         # DENIED
        nono why --profile claude-local --path /etc/gitconfig --op read  # ALLOWED

   `nono why` answers from the profile alone -- it ignores flags and
   environment overrides, which is what makes it a useful check.  It is
   also optimistic about ports: it will call `github.com:22` allowed,
   but proxy mode is HTTP CONNECT and ssh does not survive it.

5. **The Emacs side needs no `PATH` entry.**  `lisp/x-hugh-claude.el`
   points `claude-code-ide-cli-path` at
   `(expand-file-name "bin/claude-nono" user-emacs-directory)`, so the
   wrapper is found by absolute path.

6. **`bin/nono-here` does want to be on `PATH`**, since the whole point
   of it is typing it from a shell:

        ln -s ~/.emacs.d/bin/nono-here ~/.local/bin/nono-here

   Check it with `nono-here -n`, which prints the capabilities and runs
   nothing.

Note that nono cannot nest: inside a sandboxed session every one of
these commands that needs to write session state fails with
`Permission denied` under `~/.local/state/nono/`.  Read-only ones
(`why`, `show`, `validate`, `--dry-run`) work fine.
