# Customization Guide

After installing, some skills use auto-discover patterns that work out of the box. Others have conventions you may want to customize.

## Directory Conventions

These skills expect the following directory structure. Create the directories that apply to your workflow:

```
~/projects/          # Your git repos (agents auto-discover repos here)
~/wiki/              # Personal knowledge wiki (optional)
  ├── index.md       # Wiki index (used by wiki-scout)
  ├── runbooks/      # Runbooks (used by wiki-scout)
  └── raw/           # Raw handoff archives (used by handoff-reader)
~/learning/          # Study notes and learning materials (optional)
  └── lessons-learned.md  # (used by wiki-scout, self-audit)
```

If your repos are elsewhere (e.g., `~/code/`, `~/src/`), the agents use `find` to auto-discover — just update the search root in the agent `.md` files.

## Skill-Specific Customization

### `/principal`

The principal skill uses `git config user.name` to check your recent commits. No customization needed.

If you use Jira, the skill auto-detects ticket keys in your prompt (e.g., `PROJ-123`). If your Jira integration uses a specific CLI tool, update the Jira ticket detection line in `commands/principal.md`.

### `/research`

The research skill dispatches scout agents in parallel. The agents auto-discover:
- **Repos with HANDOFF.md** — `find ~/projects -maxdepth 3 -name HANDOFF.md`
- **All git repos** — `find ~/projects -maxdepth 2 -name .git`
- **Wiki pages** — reads from `~/wiki/index.md`

To change the search root, edit the `find` commands in `agents/handoff-reader.md`, `agents/git-historian.md`, and `agents/wiki-scout.md`.

### `/handoff`

Works in any git repo — no customization needed. Checkpoints are stored at `<repo>/.claude/checkpoints/` (gitignored automatically).

### `/checkpoint`

Works in any git repo. Checkpoints stored at `<repo>/.claude/checkpoints/`. Add `.claude/checkpoints/` to your `.gitignore` if it's not already there.

### Hooks

Hooks are NOT installed automatically. See `hooks/README.md` for setup instructions. Copy the JSON snippets into your `~/.claude/settings.json`.

## Adding Your Own Skills

Create a `.md` file in `~/.claude/commands/` with the frontmatter format:

```yaml
---
description: One-line description
argument-hint: <arg>
allowed-tools: [Read, Write, Edit, Bash(...)]
---

# Your instructions here
```

The file name becomes the slash command name (e.g., `my-skill.md` → `/my-skill`).
