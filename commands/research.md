---
description: Deep before-task research on a topic before writing code
argument-hint: <topic, Jira ticket, or task description>
---
Deep-research $ARGUMENTS before writing any code. Follow every step.

## Step 1 — Classify

Determine task type: bug fix | feature | test/CI failure | refactor |
design/research | PR review. Then classify risk: low | medium | high.

## Step 2 — Delegate to scout agents (PARALLEL)

Spawn these scout agents IN PARALLEL using the Agent tool. Each runs on
Haiku (cheap, fast) and returns a compressed summary. This keeps the main
Opus context clean — scouts gather, Opus synthesizes.

**Important:** Pass the topic/keywords from $ARGUMENTS to each scout.
Do NOT do this research inline — delegate it.

### Scout 1: wiki-scout
Prompt: "Research topic: $ARGUMENTS. Search wiki, memory, runbooks,
lessons-learned, and active-work for prior context on this topic."

### Scout 2: handoff-reader
Prompt: "Research topic: $ARGUMENTS. Search HANDOFF.md files across all
repos and recent wiki handoffs for session context on this topic."

### Scout 3: git-historian
Prompt: "Research topic: $ARGUMENTS. Search git history, recent commits,
merged PRs, and branches across relevant repos for prior work on this topic."

### Scout 4: upstream-scout (ONLY if external research needed)
Prompt: "Research topic: $ARGUMENTS. Search upstream projects and web for
related PRs, known pitfalls, best practices, and documentation."

Skip upstream-scout when: task is purely internal (docs fix, test fix,
config change) and repo context is sufficient. Say: "Upstream scout
skipped: repo context sufficient."

### Scout 5: code-reader (ONLY if code understanding needed)
Prompt: "Research topic: $ARGUMENTS. In <repo-path>, trace the call
graph, find convergence points, and map dependencies for <function/area>."

Runs on Sonnet (needs reasoning about code structure). Skip when: task
is docs-only, research-only, or the code area is already well-understood.

**Launch scouts 1-3 always. Launch 4-5 only when relevant.**

## Step 3 — Receive scout reports

Wait for all scouts to return. Each returns a compressed summary
(500-1500 words). Total context added to your session: ~2000-5000 words
instead of the 20,000+ tokens of raw file reads.

## Step 4 — Team PRs (inline, quick)

If scouts didn't already cover this, do a quick PR check:
```bash
gh pr list --repo <org>/<repo> --state all --search "<keyword>" --limit 5
```
Only mark an issue "untouched" after confirming: no assignee + no open PR +
no recently merged PR targeting the same issue.

## Step 5 — Synthesize (Opus does this — the decision layer)

Combine all scout reports into the evidence-based format. This is where
Opus adds value — connecting dots across reports, spotting conflicts,
making judgment calls.

```
## Research Summary: $ARGUMENTS

### Task: <type> | Risk: <low/medium/high>

### Confirmed
- <what scouts verified, with source paths and file:line refs>

### Assumptions
- <what scouts reported but isn't proven>

### Unknowns
- <gaps across all scout reports — what none of them found>

### How the team has handled this before
- <from git-historian and handoff-reader reports>

### How others solve this
- <from upstream-scout, or "skipped — repo context sufficient">

### Code structure (if code-reader was used)
- <convergence point, call graph, affected files>

### Proposed approach
1. <step — ELI5 explanation>
2. <step>

### Blast radius (medium/high risk only)
- Components affected:
- Tests covering this path:
- Configs/CRDs/CI depending on it:
- Downstream/upstream impact:

### Authority order applied
<note any source conflicts and which source won per the authority order
from ~/.claude/CLAUDE.md>
```

## Step 6 — Wait

Do NOT write code, create files, or run mutating commands.
Wait for my "go ahead" or further questions.

For low-risk tasks, say: "Low risk — proceeding unless you say wait."
For medium/high-risk, wait for explicit go-ahead.

## Cost savings note

This research pattern uses Haiku scouts ($1/$5 per MTok) instead of
running all reads on Opus ($5/$25 per MTok). Each scout reads extensively
in its own context but returns only a ~1000-word summary. Net effect:
~5x cheaper research phase with cleaner main context.
