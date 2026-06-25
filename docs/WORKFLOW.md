# Workflow Guide

## Daily Workflow

```
Start of day  →  /principal "start my day"  →  picks highest-priority task
                      │
Working on task  →  /principal <task>  →  classifies, researches, gates, codes
                      │
Mid-session     →  /checkpoint save <label>  →  saves approach snapshot
                      │
Stuck on bug    →  /diagnose <symptom>  →  structured diagnosis loop
                      │
Before push     →  /code-review  →  finds bugs in diff
                      │
End of day      →  /handoff  →  writes handoff + suggests CLAUDE.md updates
```

## Command Reference by Scenario

### Starting Work

| Scenario | Command |
|----------|---------|
| "Start my day" | `/principal start my day` |
| Complex task, need full intake | `/principal <task or ticket>` |
| Quick mid-day check | Just ask directly — skip `/principal` for trivial tasks |

### During Work

| Scenario | Command |
|----------|---------|
| Need to understand unfamiliar code | `/zoom-out <file or function>` |
| Need background research before coding | `/research <topic>` |
| Want to stress-test a design | `/grill-me <plan description>` |
| Verify a claim from a PR or issue | `/validate-council <claim>` |
| Save current approach before trying something risky | `/checkpoint save <label>` |
| Approach failed, rewind to decision point | `/checkpoint restore <label>` |
| Context getting long, save tokens | `/caveman` |

### Debugging

| Scenario | Command |
|----------|---------|
| Hard bug or test failure | `/diagnose <symptom>` |
| Need to redirect Claude mid-turn | `steer "check X instead"` (from another terminal) |

### Finishing

| Scenario | Command |
|----------|---------|
| Review diff before push | `/code-review` |
| Draft a Slack message | `/slack <channel> <topic>` |
| Generate smoke test report | `/smoke <topic>` |
| End of session | `/handoff` |

### Learning

| Scenario | Command |
|----------|---------|
| Learn a new concept deeply | `/deep-learn <topic>` |
| Multi-session teaching | `/teach <topic>` |
| Guided mentoring while building | `/mentor <task>` |

### Planning

| Scenario | Command |
|----------|---------|
| Break epic into tasks | `/to-issues <plan or ticket>` |
| Prepare standup | `/standup-prep` |

## The Research Pipeline

`/research` is the core information-gathering skill. It dispatches 3-5 scout agents in parallel:

1. **wiki-scout** — searches wiki, memory, runbooks, lessons-learned
2. **handoff-reader** — scans HANDOFF.md across all repos
3. **git-historian** — searches git history, commits, PRs
4. **upstream-scout** (optional) — web search for external context
5. **code-reader** (optional) — traces call graphs (runs on Sonnet)

Each scout returns a ~1000-word summary. The main context synthesizes these into a Confirmed/Assumptions/Unknowns report.

## The Principal Pipeline

`/principal` is the full task intake workflow. It:

1. Classifies the task (type, risk, blast radius)
2. Runs `/research` for context
3. Runs a pre-implementation gate (3-4 parallel analysis passes)
4. Auto-checkpoints before coding
5. Follows coding rules
6. Runs security scan before push
7. Delegates to specialized skills when they fit
