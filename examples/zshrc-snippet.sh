# Claude Code mid-flight steering
# Usage: from another terminal, run: steer "wrong direction, check X instead"
steer() { echo "$*" > /tmp/claude-steer.md; }
