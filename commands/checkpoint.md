---
description: Save/restore approach snapshots for session branching. Save before risky changes, restore to rewind to a decision point without losing context.
argument-hint: [save <label> | list | restore <label|number> | diff]
allowed-tools: Read, Write, Edit, Bash(git status:*), Bash(git log:*), Bash(git branch:*), Bash(git diff:*), Bash(ls:*), Bash(mkdir:*), Bash(head:*), Bash(wc:*)
---

# /checkpoint — Session Branching for Claude Code

Parse $ARGUMENTS to determine subcommand: `save`, `list`, `restore`, `diff`.
Default (no args or just a label): `save`.

---

## save [label]

Save a lightweight snapshot of the current approach and state.

### Step 1 — Gather git state
```bash
git rev-parse --show-toplevel 2>/dev/null || echo "NOT_A_REPO"
```
If not a repo, use `$PWD` as the project root.

```bash
git branch --show-current 2>/dev/null
git log --oneline -5 2>/dev/null
git status --short 2>/dev/null
git diff --stat 2>/dev/null
```

### Step 2 — Build the checkpoint from conversation context

Extract from THIS conversation (not from files — from what we've discussed):

- **Current approach**: what we're doing and why (2-3 sentences)
- **Decisions made**: choices and their reasons (so restore doesn't re-litigate)
- **Rejected approaches**: what we tried that failed (so restore doesn't retry)
- **Files touched and why**: each file with a one-line reason
- **Open questions**: unresolved items at this point
- **Ticket/PR context**: any Jira ticket or PR numbers mentioned

### Step 3 — Write the checkpoint file

```bash
mkdir -p <repo-root>/.claude/checkpoints
```

Write to `<repo-root>/.claude/checkpoints/<YYYY-MM-DD-HHMMSS>-<label>.md`:

```markdown
# Checkpoint: <label>
**Date**: <timestamp> · **Branch**: <branch>
**Approach**: <one-sentence summary>

## State snapshot
- Branch: <name>
- Last commit: <hash> <message>
- Modified files: <list from git status>
- Uncommitted changes: <yes/no, diff stat summary>

## Current approach
<2-3 sentences: what we're doing and why>

## Decisions made (keep these on restore)
- Chose X over Y because Z
- ...

## Rejected approaches (do NOT retry these)
- ❌ Tried X → failed because Y
- ...

## Files touched and why
- `path/to/file.go:42` — <why>
- ...

## Open questions
- <unresolved items>

## Ticket / PR context
- Jira: <ticket> · PR: <number> · Issue: <number>
```

### Step 4 — Confirm

Output ONE line:
> Checkpoint saved: `<label>` at `<path>` (approach: <one-sentence>)

Do NOT explain the checkpoint format or offer next steps.

---

## list

Show recent checkpoints for the current repo.

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")
ls -1t "$REPO_ROOT/.claude/checkpoints/"*.md 2>/dev/null | head -10
```

For each file, read ONLY the first 3 lines (the header) and show:

```
## Recent Checkpoints

| # | Date | Label | Approach |
|---|------|-------|----------|
| 1 | 2026-06-25 14:30 | pre-impl-tls | Wire TLS flag through reconciler |
| 2 | 2026-06-25 11:00 | before-rebase | Clean state before midstream rebase |
```

If no checkpoints exist, say: "No checkpoints saved in this repo. Use `/checkpoint save <label>` to create one."

---

## restore [label|number]

Load a checkpoint's context into the current conversation.

### Step 1 — Find the checkpoint

If argument is a number, map to the Nth most recent checkpoint (from `list`).
If argument is a label, find the file matching `*-<label>.md`.
If no argument, use the most recent checkpoint.

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")
ls -1t "$REPO_ROOT/.claude/checkpoints/"*.md 2>/dev/null | head -1
```

### Step 2 — Read and present

Read the full checkpoint file. Present it as:

```
## Restoring Checkpoint: <label> (from <date>)

<full checkpoint contents>

---

**Current git state vs checkpoint:**
- Branch then: <checkpoint branch> → now: <current branch>
- Files changed since checkpoint: <git diff --stat from checkpoint commit>

**Ready to continue from this point.** The decisions and rejected approaches above are carried forward. What direction do you want to take?
```

### Step 3 — Hard wait

Do NOT start coding or making changes. Wait for the user to give direction.

---

## diff

Compare current conversation state against the most recent checkpoint.

### Step 1 — Find latest checkpoint

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")
LATEST=$(ls -1t "$REPO_ROOT/.claude/checkpoints/"*.md 2>/dev/null | head -1)
```

If no checkpoint exists, say: "No checkpoints to diff against."

### Step 2 — Read checkpoint and compare

Read the checkpoint. Compare against current git state and conversation context:

```
## Diff: Current State vs Checkpoint "<label>" (<date>)

### Approach
- Then: <checkpoint approach>
- Now: <current approach from conversation>
- Changed: <yes/no, what shifted>

### New decisions since checkpoint
- <decisions made after the checkpoint>

### New files touched
- <files modified since checkpoint that weren't in it>

### New rejected approaches
- <things tried and failed since checkpoint>

### Git changes since checkpoint
<git diff --stat from checkpoint's last commit to HEAD>
```
