#!/bin/sh
# VINE journal-before-commit guard.
# PreToolUse hook on Bash: blocks `git commit` while a navigate session is
# active (.vine/ACTIVE exists) and the active feature's NAVIGATION.md hasn't
# been touched since the last commit. Exit 0 allows the call; exit 2 blocks
# it and shows stderr to Claude.
#
# Every missing-tooling path fails open (exit 0): enforcement degrades, it
# never breaks the session. POSIX sh only — no bashisms, no jq requirement.

root="${CLAUDE_PROJECT_DIR:-.}"
sentinel="$root/.vine/ACTIVE"

# No active navigate session — nothing to guard.
[ -f "$sentinel" ] || exit 0

payload=$(cat 2>/dev/null) || payload=""

# Only commits are guarded. With jq, read tool_input.command precisely;
# without it, substring-match the raw payload. The pattern over-matches by
# design (a non-commit command mentioning "commit" can trip it): a false
# block costs one explained retry, a false allow silently voids the
# journal-before-commit guarantee.
if command -v jq >/dev/null 2>&1; then
  cmd=$(printf '%s' "$payload" | jq -r '.tool_input.command // empty' 2>/dev/null) || cmd=$payload
else
  cmd=$payload
fi
case $cmd in
  *git*commit*) ;;
  *) exit 0 ;;
esac

# The feature path is an opaque repo-relative string. No domain/slug parsing,
# no assumption it lives under .vine/projects/ — future roots work unchanged.
feature=$(sed -n 's/^feature:[[:space:]]*//p' "$sentinel" 2>/dev/null | head -n 1)
[ -n "$feature" ] || exit 0

journal="$root/$feature/NAVIGATION.md"
# No journal yet (first slice of a fresh feature) — nothing to compare.
[ -f "$journal" ] || exit 0

# "Updated since the last commit" = journal mtime newer than HEAD's commit
# time. git status can't answer this: NAVIGATION.md is gitignored in most
# repos. GNU stat first, then BSD (macOS); fail open if neither works.
# Order matters: GNU `stat -f` is `--file-system` and exits 0 printing
# filesystem info (not the mtime), so a BSD-first `stat -f %m` would swallow
# the GNU fallback and yield non-numeric garbage. `stat -c` is GNU-only and
# fails cleanly on BSD, so the fallback fires correctly there.
mtime=$(stat -c %Y "$journal" 2>/dev/null || stat -f %m "$journal" 2>/dev/null)
[ -n "$mtime" ] || exit 0
last=$(git -C "$root" log -1 --format=%ct 2>/dev/null)
# No commits yet — the first commit is always allowed.
[ -n "$last" ] || exit 0

# -ge, not -gt: mtimes have second granularity, and a journal touched in the
# same second as HEAD's commit was plausibly updated alongside it — ties fail
# open like every other ambiguous path here.
#
# This is the only fire-and-pass exit: the guard reached a real commit in an
# active session, found the journal, and confirmed it's current. Emit one
# stderr line so a reviewer can tell "fired and passed" apart from "never
# fired" (both exit 0). Low-noise by construction — it prints once per allowed
# commit, not on the fail-open early exits above.
if [ "$mtime" -ge "$last" ] 2>/dev/null; then
  echo "VINE journal guard: $feature/NAVIGATION.md is current — commit allowed." >&2
  exit 0
fi

cat >&2 <<EOF
VINE journal guard: $feature/NAVIGATION.md has not been updated since the last
commit. Update the slice's journal entry before committing — the journal update
is part of the slice, not an afterthought.
Stale session? Disable this guard with: rm .vine/ACTIVE
EOF
exit 2
