---
description: Audit CLAUDE.md, lessons-learned, and gotchas against current code. Run at task start, mid-task, or weekly to catch stale rules and missing knowledge.
argument-hint: [--quick | --full | <repo-path>]
---

# /self-audit

Verify that your working knowledge matches reality. Every rule must trace to current code — not memory, not history, not assumptions.

## When to use

- **Task start** (`--quick`): entering a repo you haven't touched in 2+ weeks
- **Mid-task** (default): before pushing a PR or when something feels wrong
- **Weekly** (`--full`): comprehensive audit of all knowledge files
- **New repo** (`<repo-path>`): bootstrap audit for a repo with no prior context

## Modes

| Mode | Trigger | Time | Scope |
|------|---------|------|-------|
| Quick | `--quick` or auto from `/principal` | 30s | Current repo only — 5 most relevant gotchas |
| Standard | default | 2min | Current repo + cross-repo gotchas + lessons-learned |
| Full | `--full` | 5min | All repos, full CLAUDE.md audit, PR feedback scan |

## Step 1 — Detect current repo

Identify which repo you're in from the working directory. Map the current path to the upstream repository name.

If `$ARGUMENTS` contains a path, use that instead.

## Step 2 — Verify gotchas are still real

For each gotcha in `~/.claude/CLAUDE.md` that mentions a file path, flag, config key, or command:

1. **grep for it** in the current repo. Does the file/flag/key still exist?
2. If renamed or removed, flag as **STALE**.
3. If still present but behavior changed, flag as **DRIFT**.
4. If still valid, mark as **CONFIRMED**.

Focus on gotchas relevant to the detected repo. Skip unrelated ones in `--quick` mode.

Examples of what to check:
- File paths: does the referenced file exist?
- Config keys: grep for them
- Commands: does the Makefile target exist?
- API signatures: grep for current signature

Do NOT read entire files. Use `grep -rn`, `git grep`, `find` — targeted lookups only.

## Step 3 — Cross-check lessons-learned

Read lessons-learned file(s). For each entry:

1. Is the "Correct approach" still correct? Verify against current code.
2. Has the same mistake been repeated in recent commits? Check: `git log --oneline --since="2 weeks ago" --author="$(git config user.name)" -20`
3. Are there new lessons from recent PR reviews not yet captured?

In `--quick` mode, only check lessons relevant to the current repo.

## Step 4 — Scan recent PR feedback (standard + full only)

For the current repo, check recent review comments on open PRs:

```bash
gh pr list --author="$(gh api user --jq .login)" --state=open --repo <repo> --limit=5 --json number
```

For each PR, scan review comments for repeated patterns — things reviewers keep asking for. If a reviewer made the same type of comment twice, it's a candidate rule.

Do NOT fetch more than 3 PRs. Stay cheap.

## Step 5 — Check memory staleness (full mode only)

Read memory files. For each memory file:

1. Check the file's age (from frontmatter or file modification time)
2. If older than 30 days and references specific code paths, verify those paths still exist
3. Flag memories that reference merged PRs, completed tickets, or resolved decisions as candidates for archival

## Step 6 — Output

Format the output as a patch report. Every finding must cite evidence.

```
## Self-Audit Report — <repo> (<mode>)
Date: YYYY-MM-DD

### STALE (remove or update these)
- [ ] GOTCHA: "<gotcha text>" — <file/flag> no longer exists at <path>. 
      Evidence: `grep -rn "<term>" .` returned 0 results.
- [ ] LESSON: "<lesson title>" — correct approach changed. 
      Evidence: <what changed and where>.
- [ ] MEMORY: "<memory name>" — references completed work / merged PR.

### DRIFT (behavior changed, rule needs updating)
- [ ] GOTCHA: "<gotcha text>" — flag still exists but default changed.
      Evidence: `grep` shows <new value> at <file:line>.

### CONFIRMED (still valid)
- <N> gotchas verified for this repo
- <N> lessons still applicable

### MISSING (should be a rule but isn't)
- [ ] PR #<N> reviewer <name> flagged: "<pattern>". Not in CLAUDE.md.
      Suggested rule: "<one-line rule>"
- [ ] Recent commit <sha> repeated mistake from lesson "<title>".
      Rule exists but was not followed — consider promoting to gotcha.

### PROPOSED PATCH
<for each STALE/DRIFT/MISSING item, show the exact edit>

Edit CLAUDE.md:
  Remove: "<stale gotcha line>"
  Update: "<old text>" → "<new text>"
  Add: "- **<new gotcha>** — <description>"
```

## Rules

- Never modify CLAUDE.md or lessons-learned files automatically. Show the patch, let the user approve.
- Every finding must cite a file path, grep result, or command output as evidence.
- Do not read large files. Use grep, git grep, find, head/tail.
- In quick mode, output max 10 lines. Get in, check, get out.
- In standard mode, output max 30 lines.
- In full mode, no limit but stay concise.
- Do not run tests or builds — this is a knowledge audit, not a CI check.
- If everything checks out, say so in one line: "All <N> rules verified for <repo>. No changes needed."
- Flag uncertainty explicitly: "UNSURE: <gotcha> — could not verify because <reason>."
