# Architecture

## Three-Layer System

```
Commands (user-triggered)     →  "what to do"
    │
    ├── Agents (auto-dispatched)  →  "how to gather info"
    │
    └── Hooks (auto-fired)        →  "what happens after"
```

### Layer 1: Commands (`/name`)

Slash commands are the entry points. The user types `/handoff`, `/diagnose`, `/principal` and Claude follows the structured workflow in the `.md` file.

Commands orchestrate — they dispatch agents, invoke skills, and gate decisions.

### Layer 2: Agents (subagents)

Cheap, specialized subagents that commands dispatch for parallel information gathering. Each runs on a smaller model (Haiku/Sonnet) to keep costs low.

| Agent | Model | Purpose |
|-------|-------|---------|
| `handoff-reader` | Haiku | Scan HANDOFF.md across repos |
| `wiki-scout` | Haiku | Search wiki + memory |
| `git-historian` | Haiku | Search git history |
| `upstream-scout` | Haiku | Web search for upstream context |
| `code-reader` | Sonnet | Trace call graphs, map dependencies |

The `/research` command spawns scouts 1-3 in parallel. The main Opus context synthesizes their compressed summaries (~1000 words each) instead of reading 20K+ tokens of raw files.

### Layer 3: Hooks (auto-triggered)

Shell commands that fire on lifecycle events:

- **PostToolUse (steer)**: Checks `/tmp/claude-steer.md` after every tool call — enables mid-flight corrections from another terminal
- **PostToolUse (sync)**: Auto-syncs wiki after `/handoff` runs

## How Commands Compose

```
/principal (task intake)
    ├── /research (parallel scouts)
    │   ├── wiki-scout agent
    │   ├── handoff-reader agent
    │   ├── git-historian agent
    │   └── upstream-scout agent (optional)
    ├── Pre-impl gate (3 parallel analysis passes)
    ├── /checkpoint save (auto before coding)
    └── /handoff (end of session)
        └── wiki sync hook (auto)

/diagnose (bug fixing)
    ├── Phase 1-4: feedback loop, reproduce, hypothesize, instrument
    ├── /checkpoint save (auto before fixing)
    └── Phase 5-6: fix, variant scan, cleanup
```

## Cost Model

- **Opus (main context)**: Decision-making, synthesis, code writing
- **Haiku agents**: Information gathering (~5x cheaper per token)
- **Sonnet agents**: Code structure analysis (code-reader)
- **Hooks**: Zero token cost (shell commands)
- **Checkpoints**: ~500 tokens per save (3 tool calls)
