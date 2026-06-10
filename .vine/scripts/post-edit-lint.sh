#!/bin/sh
# VINE post-edit validation hook.
# PostToolUse hook on Edit|Write: when a navigate session is active
# (.vine/ACTIVE exists), run the project's validation command after each
# edit so failures surface immediately instead of at the slice boundary.
#
# The command comes from an opt-in marker line in the navigate overlay
# (interim source until the Validation block from #54 lands):
#
#   hook-validation: <command>
#
# in .vine/context/navigate.md (legacy .vine/hooks/navigate.md honored
# through 0.4.x). Prose-mentioned commands are never executed — only the
# marker line is. No sentinel, no overlay, or no marker: exit 0 silently.
# A failing validation exits 2, which shows the output to Claude.
#
# POSIX sh only — no bashisms, no jq requirement. Ambiguity fails open.

root="${CLAUDE_PROJECT_DIR:-.}"
sentinel="$root/.vine/ACTIVE"

# No active navigate session — nothing to validate.
[ -f "$sentinel" ] || exit 0

# Consume the hook payload; the edited file path isn't needed — the
# validation command decides its own scope.
cat >/dev/null 2>&1

overlay="$root/.vine/context/navigate.md"
[ -f "$overlay" ] || overlay="$root/.vine/hooks/navigate.md"
[ -f "$overlay" ] || exit 0

vcmd=$(sed -n 's/^hook-validation:[[:space:]]*//p' "$overlay" 2>/dev/null | head -n 1)
[ -n "$vcmd" ] || exit 0

out=$( (cd "$root" && sh -c "$vcmd") 2>&1 ); rc=$?
[ "$rc" -eq 0 ] && exit 0

{
  printf 'VINE post-edit validation failed (%s):\n' "$vcmd"
  printf '%s\n' "$out"
  printf 'Stale session? Disable VINE hooks with: rm .vine/ACTIVE\n'
} >&2
exit 2
