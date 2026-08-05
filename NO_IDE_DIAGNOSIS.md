# No IDE tools reaching Claude — diagnosis

Written 2026-08-04 (round 3), from inside the sandboxed session
(`*claude:~/.emacs.d/:default*`, claude pid 824123, Emacs pid 823441,
monet port 31065).
claude 2.1.220, monet 0.0.3.

## Symptom

Asked to open `x-hugh-magit.el` at line 24, I can't. My tool list
contains no `openFile`, `getDiagnostics`, or any other monet tool —
not even in the deferred-tool index that `ToolSearch` queries.
`ToolSearch` for `openFile` and for `mcp ide` returns nothing.

This session ran `/ide` at the very start (it reported "Connected to
Emacs") and *still* has no tools. That falsifies round 2's working
theory that a fresh `/ide` after startup reliably produces tools.

## What changed since the last round

**The decisive new measurement: MCP resources work.**
`ListMcpResourcesTool` against server `ide` returned the full resource
list — ~70 entries, recent files plus project files, exactly what
monet serves. That single call proves, from inside the model's own
toolset:

- the WebSocket is up and authenticated
- the MCP `initialize` handshake **completed** (resources can't flow
  without it)
- JSON-RPC round-trips work in both directions, right now, mid-session
- monet is alive and answering requests

Round 2 ended unable to distinguish "handshake never happened" from
"handshake happened and tools were dropped". That question is now
answered: the handshake happened. Hypothesis 1 from round 2 is dead.

## What I verified as working

| Check | Result |
|---|---|
| Lockfile count | exactly one: `~/.claude/ide/31065.lock` |
| Lockfile owner | pid 823441 (Emacs), workspace `/home/aardvark/.emacs.d/` — matches |
| `CLAUDE_CODE_SSE_PORT` inside sandbox | `31065` — not stripped by nono |
| `ENABLE_IDE_INTEGRATION` inside sandbox | `t` |
| CLI flags | no `--ide` — auto-connect path only |
| claude's connection | ESTABLISHED: `127.0.0.1:57564 -> 127.0.0.1:31065`, claude pid 824123 fd 21 |
| Socket queues | 0/0 — open, idle |
| `/ide` run this session | yes, reported "Connected to Emacs" |
| **MCP `resources/list` round-trip** | **works — `ListMcpResourcesTool` returns monet's full resource list** |
| **MCP `initialize` completed** | **yes — implied by resources working** |
| monet advertises `openFile` | yes, `monet.el:981` |
| mcp__ide tools in model toolset | **absent**, including from the deferred index |

## What is actually left

The loss is now isolated to the *tools* channel of an otherwise
fully-working MCP session. Resources traverse the whole stack
(monet → CLI → model harness → me); tools do not. Two candidates:

1. **The CLI never sends `tools/list`** (or ignores the answer) on
   this connection, while happily doing `resources/list` on demand.
   monet dispatches `tools/list` at `monet.el:538` and fires
   `notifications/tools/list_changed` after initialize
   (`monet.el:691`) — whether the CLI ever asks is only visible from
   Emacs's side.

2. **`tools/list` completes but the harness never surfaces the tools
   to the model** — neither as live tools nor as deferred ones.
   `ListMcpResourcesTool` is a built-in harness tool, so resources
   don't need per-server tool registration; IDE tools do. The
   registration step is the suspect.

Either way this is now clearly a CLI/harness bug, not an Emacs, monet,
nono, or networking problem. The resources-work-but-tools-don't
evidence is strong material for an upstream report (compare
claude-code-ide.el issue #133).

## Next steps (need to run in Emacs, outside the sandbox)

1. `M-x monet-enable-logging` *before* starting a session, then check
   `*monet-log*` on the next session for the sequence on the active
   port:
   - `initialize` — expected present (proven complete this round)
   - `resources/list` — expected present (they reach the model)
   - `tools/list` — **the one open question.** Absent → candidate 1
     (CLI never asks); present and answered → candidate 2 (harness
     drops registered tools), report upstream with the log.
2. `M-x monet-list-sessions` — confirm the session records a completed
   initialize and note anything odd about capabilities negotiation
   (does the client's `initialize` declare tool support?).
3. File the upstream report once 1 settles which side to blame; this
   document plus the *monet-log* excerpt is the reproduction.

## Workaround until then

Ask Emacs directly rather than via me:

```
C-x 4 f ~/.emacs.d/lisp/x-hugh-magit.el
M-g g 24 RET
```

The `/ide` nudge (`x-hugh-claude--nudge-ide`) can stay — it's harmless
— but this round shows it is not sufficient, so don't rely on it.

## Unrelated noise seen this session

Every Bash call still prints `Permission denied` for
`/etc/bash.bashrc` and `~/.bashrc` (nono policy group
`deny_shell_configs`). Cosmetic, commands run fine, unrelated to the
IDE problem.

## Files referenced

- `lisp/x-hugh-claude.el:53` — `monet-open-file-tool` wrapper binding
- `lisp/x-hugh-claude.el:74-91` — `/ide` nudge (delay + function)
- `lisp/x-hugh-claude.el:104` — nudge hook on `claude-code-start`
- `lisp/x-hugh-claude.el:107` — `claude-code-program` → `bin/claude-nono`
- `lisp/x-hugh-claude.el:108-111` — why `--ide` is omitted
- `lisp/x-hugh-claude.el:120-121` — appended system prompt
- `elpa/monet/monet.el:538` — `tools/list` dispatch
- `elpa/monet/monet.el:691` — `notifications/tools/list_changed`
- `elpa/monet/monet.el:981` — the advertised `openFile` tool

## Notes from Hugh

M-x monet-list-sessions
```
Active Monet Sessions:
======================

*claude:~/.emacs.d/:default* Port: 61266 Connected: Yes Initialized: Yes  Directory: /home/aardvark/.emacs.d/

Total sessions: 1

```

M-x monet-enable-logging

- see monet.log
