---
description: Commit and/or create PR — GPG-signed, no AI co-author, minimal PR template
argument-hint: [commit | pr | both] [message or PR title]
allowed-tools: Bash(git *), Bash(gh *), Read, Edit
---

# /ship — Madhu's Git Workflow

Personal git workflow skill. Handles commits and PRs with:
- GPG-signed commits (`-s -S`), conventional format
- Zero AI attribution — no `Co-Authored-By` lines
- Minimal PR descriptions in simple English

---

## Determine mode

Parse `$ARGUMENTS`:
- `/ship commit fix: wire TLS flag` → commit mode
- `/ship pr` → PR mode (auto-generates title from commits)
- `/ship both feat: add NetworkPolicy` → commit then PR
- `/ship` (no args) → ask what to do

---

## COMMIT MODE

### Step 1: Check working tree

```bash
git status
git diff --stat
```

If nothing staged and nothing modified → stop, say "Nothing to commit."
If unstaged changes exist → show them, ask what to stage. Never `git add -A`.

### Step 2: Build commit message

Format: `type(scope): description`

**Types** (conventional commits v1.0.0):
| Type | When |
|------|------|
| `fix` | Bug fix |
| `feat` | New feature |
| `docs` | Documentation only |
| `test` | Adding/fixing tests |
| `chore` | Maintenance, deps, CI |
| `refactor` | Code change that neither fixes nor adds |

**Rules:**
- Subject line ≤ 72 chars, imperative mood ("add" not "added")
- No period at end of subject
- Body only when the WHY is non-obvious (blank line after subject)
- If `$ARGUMENTS` includes a message after the mode word, use it
- If no message given, read the diff and draft one

### Step 3: Show draft and confirm

Show the exact commit command:
```
git commit -s -S -m "$(cat <<'EOF'
fix(llmisvc): wire enableLLMInferenceServiceTLS through reconcile

Gate cert reconciliation and DestinationRules on the ConfigMap flag
to allow HTTP-only deployments.
EOF
)"
```

**HARD RULES:**
- Always `-s` (DCO sign-off)
- Always `-S` (GPG signature, key `82E732F0E0A2730693ACDFE84F2DFD425FBC608C`)
- **NEVER** add `Co-Authored-By`, `Signed-off-by: Claude`, or any AI attribution
- **NEVER** use `--no-verify` or `--no-gpg-sign`
- **NEVER** amend unless user explicitly says "amend"

Ask: **"Commit this? (y/n)"** — wait for approval before running.

### Step 4: Commit

Run the approved command. Show result. If hook fails → fix the issue, stage, NEW commit (never amend).

---

## PR MODE

### Step 1: Gather context

Run in parallel:
```bash
git status
git log --oneline main..HEAD  # or master..HEAD
git diff main..HEAD --stat
```

If no commits ahead of base → stop, say "No commits to PR."

### Step 2: Detect repo PR template

Check in order:
1. `.github/pull_request_template.md`
2. `.github/PULL_REQUEST_TEMPLATE.md`
3. `docs/pull_request_template.md`

If a template exists → use it as the structure, fill it in from the commits.
If no template → use the default template below.

### Step 3: Build PR description

**Default template** (when no repo template exists):

```markdown
## What

[1-3 bullet points. What changed and why. Simple English.]

## How

[1-3 bullet points. Key implementation details only if non-obvious.]

## Testing

[How this was verified. Be specific:]
- [ ] `make precommit` passes
- [ ] Unit tests: `go test ./pkg/... -count=1`
- [ ] Manual: [describe what you tested]

## Notes

[Optional. Anything reviewers should know. Delete if empty.]
```

**Template rules:**
- Simple English. No jargon unless the reviewer needs it.
- Short sentences. Fragments OK.
- No filler ("This PR implements...", "In this change we...").
- Lead with WHAT, not WHY-first paragraphs.
- Max 15 lines total (excluding checklist items).
- No internal cluster names (Waldorf, PokProd002) in upstream PRs.
- No AI attribution anywhere in the PR description.
- Link Jira ticket if one exists: `Resolves: INFERENG-XXXX` or `Relates: RHOAIENG-XXXX`

**Title rules:**
- ≤ 70 chars
- Format matches commit type: `fix(llmisvc): wire TLS flag in reconcile`
- No PR number references, no emoji

### Step 4: Show draft and confirm

Show the exact `gh pr create` command with the full body in a HEREDOC:

```bash
gh pr create --title "fix(llmisvc): wire TLS flag in reconcile" --body "$(cat <<'EOF'
## What

- Gate cert reconciliation on `enableLLMInferenceServiceTLS` ConfigMap flag
- Allow HTTP-only deployments without TLS overhead

## Testing

- [x] `make precommit` passes (197/197 envtest)
- [x] Manual: TLS on 7/7, TLS off 5/5 on HyperShift EA2
EOF
)"
```

Ask: **"Create this PR? (y/n)"** — wait for approval before running.

### Step 5: Create PR

Run the approved command. Print the PR URL.

---

## BOTH MODE

Run COMMIT MODE first. If commit succeeds, check if branch needs pushing:
```bash
git log --oneline @{u}..HEAD 2>/dev/null
```
If ahead → push with `git push origin HEAD`. Then run PR MODE.

---

## Edge cases

- **Detached HEAD**: warn, ask user to create a branch first
- **Dirty working tree in PR mode**: warn, offer to commit first (enters BOTH mode)
- **No remote tracking**: `git push -u origin $(git branch --show-current)` before PR
- **Fork workflow**: detect with `git remote -v`, use correct remote for push
- **Rebase needed**: warn if base branch is ahead, suggest `git rebase` first

---

## What this skill NEVER does

1. Adds AI co-author or attribution of any kind
2. Uses `--no-verify` or `--no-gpg-sign`
3. Amends without explicit request
4. Runs `git add -A` or `git add .`
5. Force-pushes without explicit request
6. Creates a PR without showing the full draft first
7. Writes PR descriptions longer than 15 lines
8. Uses corporate jargon or complex English
