# Network filtering plan: putting an outbound allowlist on claude-nono

Status: proposed, nothing applied yet.  Written 2026-08-05 against
nono v0.71.0 and Claude Code 2.1.220 (native install,
`~/.local/share/claude/versions/2.1.220`).

Tracked from the network-filtering item in `lisp/TODO-claude.md`.

## Goal

Today the sandbox around Claude Code allows **all** outbound traffic:
the stock `always-further/claude` profile sets `"network": {"block":
false}` and nothing else.  Since 2026-08-04 the CLI runs with
`--dangerously-skip-permissions`, so there is no per-tool prompt in
front of a `curl` either.  Anything the agent can read, it can post
anywhere.

The goal is default-deny outbound, with a small reviewed allowlist,
without breaking the things this branch exists to do (model traffic,
the IDE websocket to Emacs, git).

## Findings

Everything below was checked on this machine, not assumed.

### 1. The domain sketch in the TODO is stale

`bin/claude-nono` suggests `api.anthropic.com`,
`statsig.anthropic.com`, `sentry.io`.  Neither `statsig` nor `sentry`
appears anywhere in the 2.1.220 binary.  Telemetry now rides on
`api.anthropic.com`.  The hosts the CLI actually references:

| host | why it is needed |
| --- | --- |
| `api.anthropic.com` | model traffic, telemetry, server-side WebSearch, `/api/oauth/claude_cli/*` |
| `platform.claude.com` | OAuth: `/v1/oauth/token` refresh, `/oauth/authorize`, `/oauth/code/callback` |
| `downloads.claude.ai` | auto-update and the plugin marketplace CDN |
| `registry.npmjs.org` | plugin / npm fetches |
| `*.mcp.claude.com` | only if the hosted gmail/gcal/slack/microsoft365 MCP servers get enabled |

Corroboration: the `nono` binary itself hardcodes exactly two
Anthropic-side hosts, `api.anthropic.com` and `platform.claude.com`.
That is the true minimum for a session to start and stay
authenticated.

Other hosts in the binary (`code.claude.com`, `docs.anthropic.com`,
`support.claude.com`, `status.anthropic.com`) are documentation and
support URLs meant to be *opened in a browser*, not fetched by the
CLI.  The pack profile already handles those through `open_urls`, which
is a separate mechanism from egress.

### 2. A single `--allow-domain` flips the whole network mode

    $ nono run --dry-run --profile always-further/claude --allow-cwd \
        --allow-domain api.anthropic.com -- claude --version
    ...
     net  proxy

Without it the same command reports open network.  So the allowlist is
not additive-on-top-of-open; adding one domain switches nono into
proxy-only, default-deny mode.  Kernel enforcement is available here:
Landlock V4 with TCP filtering (`degraded: IoctlDev, Scoping` only).

Plain hostname entries get an opaque CONNECT tunnel: no TLS
interception, so no CA-trust problem for the CLI.  Only entries written
as objects with `endpoints` intercept TLS (and nono then injects
`NODE_EXTRA_CA_CERTS` / `REQUESTS_CA_BUNDLE` / `GIT_SSL_CAINFO` /
`CURL_CA_BUNDLE`).  We use plain hostnames, so this does not arise.

### 3. Git is already broken inside the sandbox

Unrelated to networking, found while poking around, worth fixing in the
same pass:

    $ git log
    fatal: unknown error occurred while reading the configuration files
    warning: unable to access '/etc/gitconfig': Permission denied

    $ nono why --path /etc/gitconfig --op read
    DENIED
      Reason: path_not_granted
      Details: Path is not covered by any capability: /etc/gitconfig
      Suggested fix: --read-file /etc/gitconfig

`GIT_CONFIG_NOSYSTEM=1 git log` works, which confirms the diagnosis.

### 4. The allowlist does not belong in `bin/claude-nono`

When the project being worked on *is* this repo, cwd is `~/.emacs.d`,
so `bin/claude-nono` sits inside the agent's read-write set.  An
allowlist stored there can be edited by the thing it is meant to
constrain, taking effect on the next launch.

A user profile under `~/.config/nono/profiles/` is read-only inside the
sandbox: the pack profile grants `read` on `profiles/` and read-write
only on `profile-drafts/`, and turning a draft into a live profile
requires `nono profile promote`, which is an interactive review outside
the sandbox.  That is where the list should live.  It also means
sessions started from a plain shell get the same policy.

(Verified from inside this sandbox: `profile-drafts/` is writable, and
the `~/.config` -> `dotfiles/.config` symlink resolves fine -- the
resolved path `/home/aardvark/dotfiles/.config/nono/profile-drafts`
shows up in the dry-run capability list.)

## Design decisions

- **Default-deny egress via a profile, not wrapper flags.**  Tamper
  resistance (finding 4), survives pack updates, applies outside Emacs.
- **Extend, do not fork, the pack profile.**  `always-further/claude`
  is registry-managed; a local profile that `extends` it keeps
  receiving upstream fixes.
- **Plain hostnames, no endpoint rules.**  Path-level filtering would
  buy little here and costs TLS interception.
- **One human-typed escape hatch** for one-off domains, so a blocked
  `pip install` does not mean editing and promoting a profile
  mid-session.  Recurring needs get promoted into the profile.
- **Close the elisp hole at the same time.**  An egress allowlist on
  the sandboxed process is worth much less while the model can eval
  arbitrary elisp in the Emacs that runs outside the sandbox.  These
  two changes only make sense together.

## Changes

### A. New user profile `claude-local`

Draft at `~/.config/nono/profile-drafts/claude-local.json`:

```json
{
  "meta": { "name": "claude-local",
            "description": "Local overlay: outbound allowlist + system gitconfig" },
  "extends": "always-further/claude",
  "filesystem": { "read_file": ["/etc/gitconfig"] },
  "network": {
    "allow_domain": [
      "api.anthropic.com",
      "platform.claude.com",
      "downloads.claude.ai",
      "registry.npmjs.org",
      "github.com",
      "api.github.com",
      "codeload.github.com",
      "raw.githubusercontent.com",
      "objects.githubusercontent.com",
      "melpa.org",
      "elpa.gnu.org",
      "elpa.nongnu.org"
    ]
  }
}
```

The first four entries are what the CLI needs to run.  The GitHub
entries are for git over https and `gh`; the ELPA entries are for this
repo specifically (package archives, in case anything in-sandbox wants
them).  Drop any of them if unused -- a shorter list is a better list.

### B. `bin/claude-nono`

Point at the new profile, replace the TODO banner with a description of
the policy that is actually in force, and add the escape hatch:

```sh
if [ -n "${CLAUDE_CODE_SSE_PORT:-}" ]; then
    set -- --open-port "$CLAUDE_CODE_SSE_PORT" -- claude "$@"
else
    set -- -- claude "$@"
fi

# One-off widening for a single session, e.g.
#   M-x setenv RET CLAUDE_NONO_ALLOW_DOMAIN RET pypi.org files.pythonhosted.org
# Permanent additions belong in the claude-local profile, which the
# sandbox cannot write to.  Deliberately word-split.
for domain in ${CLAUDE_NONO_ALLOW_DOMAIN:-}; do
    set -- --allow-domain "$domain" "$@"
done

exec nono run --profile claude-local --allow-cwd --allow "$harness_tmp" "$@"
```

The header comment should also lose the "NETWORK IS CURRENTLY WIDE
OPEN" block and gain a note that the allowlist lives in the profile,
with the `nono profile show claude-local` command to read it.

### C. `lisp/x-hugh-claude.el`

Add to the `claude-code-ide` `:custom` block:

```elisp
;; nono's allowlist only binds the sandboxed process.  executeCode
;; evaluates elisp in this Emacs, outside the cage -- an unfiltered
;; network path straight past the allowlist.  openFile, openDiff and
;; getDiagnostics, the tools actually wanted here, are unaffected.
(claude-code-ide-enable-execute-code nil)
```

`claude-code-ide-enable-execute-code` is a real defcustom
(`elpa/claude-code-ide/claude-code-ide.el:194`) and the tool list is
rebuilt on every `tools/list` request
(`claude-code-ide-mcp.el:307`), so setting it through `:custom` is
enough -- no advice, no load-order trap.

Also update the `TODO(nono)` comment in the commentary header to point
at this plan.

## Rollout

1. Write the draft, then:

       nono profile validate --draft claude-local
       nono profile promote claude-local
       nono profile show claude-local | sed -n '/Network/,$p'

   If `extends` rejects the `always-further/claude` spelling, try the
   bare `claude` name that `nono profile list` shows for the pack.

2. Static checks before launching anything:

       nono why --profile claude-local --host api.anthropic.com   # ALLOWED
       nono why --profile claude-local --host platform.claude.com # ALLOWED
       nono why --profile claude-local --host example.com         # DENIED

3. Apply change B, start a session, and check in this order:

   - the model responds at all (proves `api.anthropic.com` and the
     proxy handshake);
   - `/ide` still shows connected and `mcp__ide__openFile` still works
     (proves the localhost websocket survived proxy mode -- see risks);
   - `git fetch` over https works inside the sandbox;
   - `git log` no longer warns about `/etc/gitconfig`.

4. Apply change C last, so that if something in step 3 misbehaves the
   elisp escape hatch is still available for poking at Emacs state.

5. Grow the list from evidence, not guesses: `nono logs` and `nono
   audit` record denied hosts as they are hit.

## Expected breakage

| what | why | mitigation |
| --- | --- | --- |
| WebFetch on arbitrary URLs | fetched client-side, inside the sandbox | add the host via `CLAUDE_NONO_ALLOW_DOMAIN`, or paste the content in |
| WebSearch | **not** broken -- runs server-side behind `api.anthropic.com` | none needed |
| SSH git remotes (`git@github.com:`) | proxy mode is HTTP CONNECT; raw TCP:22 has no path through it | use https remotes in-sandbox; `--allow-connect-port 22` exists but is host-unfiltered, i.e. an exfil channel, so no |
| `pip` / `apt` / `go get` | hosts not listed | `CLAUDE_NONO_ALLOW_DOMAIN`, promote if recurring |
| hosted MCP servers (gmail, gcal, slack) | `*.mcp.claude.com` not listed | add if those get enabled |
| the IDE websocket | should be fine: nono puts loopback in the generated `NO_PROXY`, and `--open-port` still applies | if it does break, `network.no_proxy` in the profile is the knob |

## Rollback

Change B is one line (`--profile claude-local` back to `--profile
always-further/claude`).  The profile can also be neutered in place by
setting `"network": {"network_profile": null, "block": false}` and
re-promoting, but switching the wrapper back is faster and more
obvious.

## Residual risk

Worth stating plainly, because the allowlist can otherwise read as more
protection than it is:

- **The allowlist binds the sandboxed process only.**  That was already
  true of the filesystem rules; it is why change C is part of this plan
  rather than a later nicety.
- **The cage is inside the agent's write set.**  With cwd =
  `~/.emacs.d`, the agent can edit `bin/claude-nono` -- including the
  `--profile` line -- and affect the *next* launch.  Moving the domain
  list into the profile keeps the list itself out of reach, but not the
  choice of profile.  The actual control there is reading the diff
  before committing.
- **Allowlisted hosts are still exfil channels.**  `github.com` is on
  the list and accepts pushes.  Default-deny raises the cost of silent
  exfiltration; it does not eliminate it.

## Open questions

- Does `extends` accept the namespaced `always-further/claude`, or only
  the bare pack profile name?  Resolved by step 1.
- Are ELPA hosts wanted at all in-sandbox, given that Emacs installs
  packages outside the sandbox?  Probably droppable.
- Should `downloads.claude.ai` be included, or should self-update be
  something that only happens outside the sandbox on purpose?
