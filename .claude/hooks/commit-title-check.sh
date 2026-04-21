#!/bin/sh
# Extracts the commit title from a git commit command and checks length.
# Expects Claude Code PreToolUse JSON on stdin.
CMD=$(jq -r '.tool_input.command')

# Extract title: look for the first content line after <<'EOF' or <<EOF
TITLE=$(echo "$CMD" | sed -n "/<<['\"]\\{0,1\\}EOF/,/^EOF/ { /<<.*EOF/d; /^EOF/d; /^[[:space:]]*$/d; p; q; }")

# Fallback: simple -m "title" format
if [ -z "$TITLE" ]; then
  TITLE=$(echo "$CMD" | sed -n 's/.*-m ["'\'']\([^"'\'']*\).*/\1/p' | head -1)
fi

# Get first line and trim whitespace
TITLE=$(echo "$TITLE" | head -1 | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')

if [ -z "$TITLE" ]; then
  exit 0
fi

LEN=${#TITLE}
if [ "$LEN" -gt 72 ]; then
  echo "{\"decision\":\"block\",\"reason\":\"Commit title too long: $LEN chars (max 72, prefer under 50)\"}"
fi
