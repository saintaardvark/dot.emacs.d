# nono profiles

Source of truth for the local [nono](https://nono.sh) profiles this
config depends on.  nono reads profiles from
`~/.config/nono/profiles/`, which is deliberately *not* writable from
inside the sandbox, so nothing here is live until it is promoted by
hand:

    cp nono/claude-local.json ~/.config/nono/profile-drafts/
    nono profile validate --draft claude-local
    nono profile promote claude-local        # shows a diff, asks y/N

`promote` needs a real terminal -- it opens `/dev/tty` -- so it cannot
be run from inside a sandboxed session.  That is the point: the review
happens outside the cage.

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

Check it without promoting:

    nono profile show   ~/.config/nono/profile-drafts/claude-local.json
    nono why --profile ~/.config/nono/profile-drafts/claude-local.json --host github.com
