---
description: Prepare an impactful standup update with ELI5 context, anticipated questions, and visibility framing
argument-hint: [optional: paste rough notes or "async" for Slack-ready format]
---

# /standup-prep

Prepare a standup update that makes the user's work visible and impactful.

This command extends and follows all global rules in `~/.claude/CLAUDE.md`.

## Goal

Generate **speakable scripts** the user can memorize and deliver — not formatted
reports or bullet lists. Every output section should read like something a
senior engineer would actually say out loud in a standup or 1:1.

**Core style rule:** Business impact first, technical detail second, next
action last. In standup, managers care about: why it matters, what changed,
risk reduced, what is next.

## Workflow

### 1. Gather context (targeted, cheap reads)

Pull from these sources in order — stop when you have enough:

1. User-provided notes (if any passed as $ARGUMENTS)
2. Active work tracking files (e.g., active-work.md) — current tickets and status
3. Recent git activity across active repos:
   ```
   # Check recent commits in active repos
   git -C <repo-path> log --oneline --since="yesterday" --author="$(git config user.name)" -10
   ```
4. Open PR status:
   ```
   gh pr list --author="$(gh api user --jq .login)" --state=open --limit=5 --repo <org>/<repo>
   ```
5. Memory files — scan for recent project memories

Do not read large files fully. Use targeted grep/line ranges.
Do not invent commits, PR numbers, review status, or reviewer names.

### 2. Build speakable scripts

For EACH active work item, generate THREE versions the user can pick from:

#### A. 60-second standup script (primary — always generate)

Write a flowing paragraph (not bullets) that the user can read or memorize.
Structure each paragraph as:

1. **Impact/why** (1-2 sentences) — what changed and why it matters
2. **What I did** (2-3 sentences) — concrete technical delta, accessible language
3. **Status + next action** (1 sentence) — current state and immediate next step

Example tone:
> For the TLS toggle feature, I focused on making the PR smaller,
> cleaner, and aligned with the approved scope. I initially explored a
> per-resource override, but after validating reviewer feedback and the
> requirements, the global config path was enough and actually safer because
> it avoids adding a new API surface.
>
> The main impact is that the existing config flag now works end-to-end.
> I wired it through cert generation, service port naming, routing status
> URL, template-generated runtime args, and optional TLS secret volumes.
>
> Current status is the PR is ready for re-review. Next I'll respond
> to the reviewer's feedback.

#### B. Compact version to memorize (always generate)

4-5 sentences max. The version you use when standup is running long or
you only have 30 seconds.

Example tone:
> I simplified the TLS toggle PR to use the existing global config
> instead of adding a new per-resource API. That keeps the scope aligned
> with the requirements and reduces long-term maintenance risk. I fixed
> the missing wiring so the global flag now controls cert generation,
> service ports, status URL, template args, and optional TLS volumes
> end-to-end. PR is ready for re-review.

#### C. Manager-friendly version (always generate)

The version for your manager's ears — zero implementation detail, pure
impact + risk + next step. 2-3 sentences.

Example tone:
> I made the TLS toggle PR more focused and lower-risk. Instead of
> adding a new per-service API, I aligned it with the existing global
> admin config, which is what the requirements need. PR is ready for
> reviewer re-check. Remaining follow-ups are chart default handling,
> env cleanup, and docs.

### 3. Impact phrases

For each work item, generate a list of **strongest impact phrases** the user
can drop into conversation:

```
## Impact Phrases

- This reduces API surface area.
- This keeps the change aligned with the requirements.
- This reduces risk because we are not introducing a new user-facing API.
- This makes the existing global flag work end-to-end.
```

### 4. What NOT to say (and what to say instead)

For each work item where scope changed, rework happened, or reviewer
pushed back, generate reframing guidance:

```
## Reframing Guide

DON'T say: "I had to rework everything" / "My first approach was wrong"
SAY instead: "I initially explored the per-resource option, but after
validating the scope and reviewer feedback, the cleaner solution
was to use the existing global config path."

WHY: This sounds senior because it shows you adapted based on scope
and reduced complexity — not that you made a mistake.
```

Rules for reframing:
- Never frame scope reduction as failure — frame it as **risk reduction**
- Never frame reviewer pushback as rejection — frame it as **alignment**
- Never say "I misunderstood" — say "I initially explored X, but Y was
  the cleaner path"
- Never say "I removed my code" — say "I simplified the approach"

### 5. Follow-up question scripts

Generate pre-loaded answers for the most likely follow-up questions.
Write them as **speakable scripts**, not bullet points.

Group by who might ask:

```
## If your manager asks...

"What exactly did you fix?"
> The issue was that the config flag existed, but it was not
> consistently respected. Some subsystems could still use the old
> behavior. I fixed those paths so the config produces consistent
> runtime behavior.

"Is this on track?"
> Code-wise, the PR is ready for review. I'm waiting on the
> reviewer's feedback. If no response by end of week, I'll escalate
> through the appropriate channel.
```

```
## If a peer asks...

"Why not the per-resource approach?"
> Per-resource gives more flexibility, but it adds a new user-facing
> API, schema, conversion, deepcopy, and long-term compatibility cost.
> The requirements ask for an admin-level decision, so global config
> is the cleaner and lower-risk solution for this PR.

"What is left?"
> Code-wise, the PR is ready for review. Remaining items are follow-ups:
> chart default handling, env cleanup, and docs.
```

```
## If a skip-level / director asks...

"Which customer is this for?"
> This was flagged by the customer POC team. They need this config
> option for their deployment topology.
```

Question categories to always cover:
1. **Timeline:** "When will this land?" / "Is this on track?"
2. **Scope:** "Why is this taking longer than estimated?"
3. **Priority:** "Should you be working on this vs <other thing>?"
4. **Risk:** "What happens if this doesn't land by <date>?"
5. **Dependencies:** "Who are you waiting on?" / "Is anyone waiting on you?"
6. **Next:** "What's after this?" / "What's the follow-up?"
7. **Help:** "Do you need anything from me?"

### 6. ELI5 cheat sheet

For each work item, generate a plain-English explanation that the user can
use if ANYONE asks "what is that?":

```
## ELI5 Cheat Sheet

**<Work item>**
- What it is: <1 sentence, no jargon>
- Why we care: <business/customer impact>
- Where it fits: <which product/component>
- Analogy: <real-world analogy if helpful>
```

### 7. Visibility moves

Suggest 1-3 concrete visibility actions for today:

```
## Visibility Moves

- [ ] <action> — <why it builds visibility>
```

### 8. Async format (if requested)

If user passes "async" as argument, also generate a Slack-ready version:

```
## Slack-Ready Update (paste to team channel)

<3-5 lines, senior-engineer voice, no exclamation points, cite PRs/tickets>
```

### 9. Output and review

Show the full output with all sections. Then ask:

"Anything to adjust before standup? I can:
- Reframe a bullet for different audience
- Add more question prep for a specific person
- Generate a Slack async version"

Do NOT post anything yourself. This is prep material for the user.

## Anti-patterns to avoid

- No formatted bullet reports — write **speakable paragraphs**
- No "still working on X" without explaining what moved
- No deep technical jargon (no "reconcile loop", "envtest fixture" — say
  "controller test" or "integration test")
- No passive voice ("tests were run" — say "I ran tests")
- No hedging language ("I think maybe" — say "I expect" or "I'm not sure
  yet, investigating")
- No inflated language ("successfully revolutionized" — say "landed" or
  "shipped")
- No self-deprecating framing ("I made a mistake", "I had to rework",
  "reviewer rejected my approach")
- No laundry lists of tasks without impact framing
