#!/bin/sh
# VINE contributor main-commit guard (this repo only — NOT part of the user
# plugin payload — it lives in the contributor repo only).
# PreToolUse hook on Bash: blocks `git commit` while the checkout is on
# 'main'. Spawned/parallel sessions sometimes open on the shared checkout
# without a worktree; this gate turns "session committed straight to main"
# into a hard stop with instructions instead of a cleanup job.
#
# Fails open on missing tooling, detached HEAD, or any ambiguity.
# POSIX sh only.

root="${CLAUDE_PROJECT_DIR:-.}"

payload=$(cat 2>/dev/null) || payload=""
if command -v jq >/dev/null 2>&1; then
  cmd=$(printf '%s' "$payload" | jq -r '.tool_input.command // empty' 2>/dev/null) || cmd=$payload
else
  cmd=$payload
fi
case $cmd in
  *git*commit*) ;;
  *) exit 0 ;;
esac

branch=$(git -C "$root" symbolic-ref --short -q HEAD 2>/dev/null) || exit 0
[ "$branch" = "main" ] || exit 0

cat >&2 <<EOF
VINE main guard: this checkout is on 'main' — commits belong on a feature
branch. Run git checkout -b <branch> first (parallel sessions should use a
worktree instead of the shared checkout).
EOF
exit 2
