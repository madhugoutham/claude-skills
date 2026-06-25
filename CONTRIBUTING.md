# Contributing

Contributions are welcome! Here's how to help.

## Adding a New Skill

1. Create a new `.md` file in `commands/` (for slash commands) or `agents/` (for subagents)
2. Follow the frontmatter format from existing skills
3. Ensure NO personal data (paths, names, credentials) — use auto-discover patterns
4. Test the skill in a Claude Code session before submitting

## Improving Existing Skills

- Open an issue describing the improvement
- Submit a PR with the change
- Include a brief description of what changed and why

## Privacy Rules

Before submitting, verify your changes pass the privacy scrub:

```bash
grep -rn -E '(hardcoded-username|~/specific-path|company\.com|PROJ-[0-9])' . --include="*.md" --include="*.json"
```

No personal data, no company-specific paths, no hardcoded credentials.

## Skill Structure

### Commands (`commands/*.md`)

```yaml
---
description: One-line description shown in /help
argument-hint: <required-arg> [optional-arg]
allowed-tools: [Read, Write, Edit, Bash(...)]
---

# Instructions for the AI follow here
```

### Agents (`agents/*.md`)

```yaml
---
name: agent-name
description: When to use this agent
model: haiku|sonnet|opus
tools: [Read, Grep, Glob, Bash]
disallowedTools: [Edit, Write]
maxTurns: 12
---

# Agent instructions follow here
```
