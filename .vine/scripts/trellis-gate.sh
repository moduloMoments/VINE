#!/bin/sh
# VINE contributor trellis gate (this repo only — NOT part of the user
# scaffold; create-vine never copies this script).
# PreToolUse hook on Bash: blocks `git commit` when files under
# plugins/vine/skills/ are in the change set and trellis hasn't passed since
# the last skill-file edit. A fully green trellis run writes .vine/.trellis-ok
# with a "status: pass" first line; a red run overwrites it with
# "status: fail".
#
# Unlike the scaffold hooks, this gate fails CLOSED when skill files
# changed without a fresh green stamp — that is its whole job. Missing
# tooling still fails open. POSIX sh only.

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

# Gate only when skill files are in the change set — staged or unstaged,
# since compound "git add ... && git commit" calls stage after this hook runs.
changed=$(git -C "$root" status --porcelain -- plugins/vine/skills 2>/dev/null)
[ -n "$changed" ] || exit 0

stamp="$root/.vine/.trellis-ok"
if [ -f "$stamp" ] && grep -q '^status: pass' "$stamp" 2>/dev/null; then
  # Fresh = no skill file edited after the stamp was written.
  newer=$(find "$root/plugins/vine/skills" -name 'SKILL.md' -newer "$stamp" 2>/dev/null)
  [ -z "$newer" ] && exit 0
fi

cat >&2 <<EOF
VINE trellis gate: files under plugins/vine/skills/ changed but trellis has not
passed since the last skill edit. Run /trellis — a green run writes
.vine/.trellis-ok — then retry the commit.
EOF
exit 2
