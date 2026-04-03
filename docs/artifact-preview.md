# Auto-Preview Artifacts with Glow

VINE phase artifacts (CONTEXT.md, SPEC.md, NAVIGATION.md, EVOLUTION.md) are easier to review with terminal rendering. This guide sets up a Claude Code hook that automatically opens a formatted preview window whenever an artifact is written.

Scroll with arrow keys or `j`/`k`, press `q` to close.

## Prerequisites

Install [glow](https://github.com/charmbracelet/glow) (terminal markdown renderer) and [jq](https://jqlang.github.io/jq/) (JSON parser):

```bash
brew install glow jq
```

## 1. Create the Hook Script

Save one of the scripts below to `.vine/hooks/artifact-preview.sh` (project-level) or `~/.claude/hooks/vine-artifact-preview.sh` (global).

### iTerm2

```bash
#!/bin/bash
INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

BASENAME=$(basename "$FILE" 2>/dev/null)
case "$BASENAME" in
  CONTEXT.md|SPEC.md|NAVIGATION.md|EVOLUTION.md|PAUSE.md) ;;
  *) exit 0 ;;
esac

osascript <<EOF
tell application "iTerm2"
  create window with default profile
  tell current session of current window
    write text "glow -p \"$FILE\"; exit"
  end tell
end tell
EOF

exit 0
```

### Terminal.app

```bash
#!/bin/bash
INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

BASENAME=$(basename "$FILE" 2>/dev/null)
case "$BASENAME" in
  CONTEXT.md|SPEC.md|NAVIGATION.md|EVOLUTION.md|PAUSE.md) ;;
  *) exit 0 ;;
esac

osascript <<EOF
tell application "Terminal"
  do script "glow -p \"$FILE\"; exit"
  activate
end tell
EOF

exit 0
```

### Make it executable

```bash
chmod +x .vine/hooks/artifact-preview.sh
```

## 2. Register the Hook

Add a `PostToolUse` entry to your Claude Code settings.

- **Project-level:** `.claude/settings.local.json` (gitignored, this project only)
- **Global:** `~/.claude/settings.json` (all projects)

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "/absolute/path/to/artifact-preview.sh",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

Replace the command path with the absolute path to your script. If you already have `PostToolUse` entries in your settings, add the new entry to the existing array — don't replace it.

## How It Works

When Claude writes a CONTEXT.md, SPEC.md, NAVIGATION.md, or EVOLUTION.md file, the hook fires and opens a new terminal window with a glow-rendered preview. Other `.md` files are ignored.
