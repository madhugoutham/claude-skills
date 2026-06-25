---
description: Break a plan, spec, Jira epic, or design into independently-grabbable Jira subtasks using vertical slices (tracer bullets). Use when converting a plan into tickets, breaking down work, or decomposing a Jira epic/feature into implementation tasks.
argument-hint: <Jira ticket, plan description, or feature spec>
---

# To Issues

Break $ARGUMENTS into independently-grabbable Jira tickets using vertical slices.

## Process

### 1. Gather context

Work from conversation context. If a Jira ticket is referenced, fetch it:
```
~/bin/acli jira workitem view <TICKET>
```
Read the full description, comments, and linked tickets.

### 2. Explore the codebase

If not already explored, read relevant code to understand current state.
Use `rg`, `git grep`, and targeted file reads — not full file dumps.

### 3. Draft vertical slices

Break the plan into **tracer bullet** issues. Each issue is a thin vertical
slice through ALL layers end-to-end, NOT a horizontal slice of one layer.

Bad (horizontal): "Step 1: Add CRD types" / "Step 2: Add controller logic" / "Step 3: Add tests"
Good (vertical): "Slice 1: TLS disable for router deployment (types + controller + test)" / "Slice 2: TLS disable for model server (types + workload + test)"

Slices are either:
- **AFK** — can be implemented and merged without human interaction
- **HITL** — requires a decision, design review, or manual testing

Prefer AFK. Prefer many thin slices over few thick ones.

### 4. Quiz the user

Present the proposed breakdown as a numbered list:

| # | Title | Type | Blocked by | Covers |
|---|-------|------|-----------|--------|
| 1 | ... | AFK | None | ... |
| 2 | ... | AFK | #1 | ... |
| 3 | ... | HITL | None | ... |

Ask:
- Does the granularity feel right? (too coarse / too fine)
- Are dependency relationships correct?
- Should any slices be merged or split?
- Are HITL/AFK labels correct?

Iterate until approved.

### 5. Create the Jira tickets

For each approved slice, create a ticket via acli. Use the AIPCC project
unless a different project is specified.

Create in dependency order (blockers first) so you can reference real
ticket IDs in the "Blocked by" field.

For each ticket, use this structure in the description:

```
h3. Parent
<parent ticket key if applicable>

h3. What to build
<concise description of the vertical slice — end-to-end behavior, not layer-by-layer>

h3. Acceptance criteria
* [ ] Criterion 1
* [ ] Criterion 2
* [ ] Criterion 3

h3. Blocked by
<blocking ticket key, or "None - can start immediately">

h3. Files likely touched
<list of file paths or patterns, to help with scoping>
```

**Verify before creating:** Show me the draft tickets. Wait for my "yes" before
running any `acli jira workitem create` commands. Never create tickets without
explicit approval.

**After creating:** Remind me to set the Team field in Jira UI (acli can't do this,
and without it the ticket won't appear on the sprint board).

Do NOT close or modify any parent ticket.
