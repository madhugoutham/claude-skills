---
description: Draft a Slack message in senior-engineer voice
argument-hint: <channel> <topic>
allowed-tools: Read
---
Draft a Slack message for #$1 about: $ARGUMENTS

Rules:
- Senior-engineer voice. NO "just", "simply", exclamation points.
- 3–6 sentences for top-level posts. Threads can be longer.
- Open with the ask or finding — no preamble.
- Cite specific PRs/Jiras/logs as links, not vague references.
- If reporting a test result, include: cluster name, image tag, verdict, next action.

Output the draft in a code block. Then ask: "Post to #$1? (y/n)"
Do NOT send anything yourself.
