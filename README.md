# Engineering Workflow Skills for Claude Code

Battle-tested engineering workflow skills built over 11 weeks of daily Claude Code usage on Kubernetes controllers, Go microservices, and infrastructure automation.

16 slash commands + 5 subagents + 2 hooks that cover the full engineering loop: task intake, research, implementation, debugging, review, and handoff.

## Install

```bash
# Add the marketplace
claude marketplace add madhugoutham/claude-skills

# Install the plugin
claude plugin install goutham-skills
```

All skills are immediately available as `/commands` in your Claude Code session.

## What's Included

### Commands (16)

| Command | What it does |
|---------|-------------|
| `/principal` | Full task intake: classify, research, pre-impl gate, code, review. The orchestrator. |
| `/research` | Parallel scout agents gather context from wiki, git history, handoffs, and upstream. |
| `/diagnose` | Disciplined bug diagnosis: feedback loop, reproduce, hypothesize, instrument, fix. |
| `/validate-council` | 3 independent agents verify a claim, 4th compares and flags disagreements. |
| `/grill-me` | Stress-test a plan or design until every decision branch is resolved. |
| `/handoff` | Structured session handoff with CLAUDE.md update suggestions. |
| `/checkpoint` | Save/restore approach snapshots. Rewind to decision points without losing context. |
| `/deep-learn` | Learn any topic from zero to staff-level. Spaced repetition included. |
| `/teach` | Multi-session teaching with progress tracking and reference docs. |
| `/mentor` | Step-by-step mentoring with checkpoint gates and retention scaffolding. |
| `/zoom-out` | Module map, callers, data flow for unfamiliar code areas. |
| `/standup-prep` | Impact-first standup with anticipated questions and visibility framing. |
| `/self-audit` | Audit CLAUDE.md and lessons-learned against current code for stale rules. |
| `/slack` | Draft Slack messages in senior-engineer voice. |
| `/smoke` | Generate structured smoke test reports for cluster testing. |
| `/to-issues` | Break plans, specs, or epics into independently-grabbable subtasks. |
| `/caveman` | Ultra-compressed communication mode. Cuts token usage ~75%. |

### Agents (5)

| Agent | Model | Purpose |
|-------|-------|---------|
| `code-reader` | Sonnet | Traces call graphs, finds convergence points, maps dependencies. Read-only. |
| `upstream-scout` | Haiku | Searches the web for upstream PRs, pitfalls, best practices. |
| `handoff-reader` | Haiku | Scans HANDOFF.md files across all repos for session context. |
| `git-historian` | Haiku | Searches git history, commits, PRs for prior work on a topic. |
| `wiki-scout` | Haiku | Reads wiki, memory, runbooks, lessons-learned for prior context. |

### Hooks (2, manual setup)

| Hook | Purpose |
|------|---------|
| **Mid-flight steering** | Inject corrections while Claude works — from another terminal, run `steer "message"` |
| **Handoff sync** | Auto-trigger a sync script after `/handoff` completes |

See [hooks/README.md](hooks/README.md) for setup instructions.

## Architecture

```
/principal (orchestrator)
    ├── /research (parallel scouts)
    │   ├── wiki-scout
    │   ├── handoff-reader
    │   ├── git-historian
    │   └── upstream-scout
    ├── Pre-implementation gate (3 parallel passes)
    ├── /checkpoint save (auto before coding)
    └── /handoff (end of session)
```

Full architecture docs: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)

## Customization

Skills auto-discover your repos via `find`. No hardcoded paths.

For Jira integration, wiki paths, or other team-specific config, see [docs/CUSTOMIZATION.md](docs/CUSTOMIZATION.md).

## Workflow Guide

See [docs/WORKFLOW.md](docs/WORKFLOW.md) for the full daily workflow and command reference by scenario.

## Cost Model

- **Opus** runs the main context (decisions, synthesis, coding)
- **Haiku agents** gather information (~5x cheaper per token)
- **Sonnet agents** analyze code structure (code-reader)
- **Hooks** cost zero tokens (shell commands)
- **Checkpoints** cost ~500 tokens per save

A typical `/research` call uses 4 Haiku agents returning ~1000 words each, costing roughly $0.01 instead of the $0.05+ it would cost to do the same reads on Opus.

## License

[MIT](LICENSE)
Updated: 2026-07-08
