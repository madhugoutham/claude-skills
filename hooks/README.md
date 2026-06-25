# Hooks

These hooks enhance the skills but are NOT installed automatically. Add them to your `~/.claude/settings.json` manually.

## Mid-Flight Steering Hook

Inject corrections while Claude is actively working, without canceling the current turn.

### Setup

Add to `settings.json` under `hooks.PostToolUse`:

```json
{
  "matcher": "*",
  "hooks": [
    {
      "type": "command",
      "command": "test -f /tmp/claude-steer.md && { cat /tmp/claude-steer.md; rm -f /tmp/claude-steer.md; } || true",
      "timeout": 5
    }
  ]
}
```

Add to `~/.zshrc` (or `~/.bashrc`):

```bash
steer() { echo "$*" > /tmp/claude-steer.md; }
```

### Usage

While Claude is working, open another terminal and run:

```bash
steer "wrong direction, check the controller not the router"
```

The hook reads the file after the next tool call and injects your correction into the conversation.

## Handoff Wiki Sync Hook

Auto-syncs wiki content after running `/handoff`. Requires a sync script at `~/wiki/tools/sync.sh`.

### Setup

Add to `settings.json` under `hooks.PostToolUse`:

```json
{
  "matcher": "Skill",
  "hooks": [
    {
      "type": "command",
      "command": "jq -r '.tool_input.skill' | grep -q '^handoff$' && bash ~/wiki/tools/sync.sh 2>/dev/null || true",
      "timeout": 120,
      "statusMessage": "Syncing wiki...",
      "async": true
    }
  ]
}
```
