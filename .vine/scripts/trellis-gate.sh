#!/bin/sh
# VINE contributor trellis gate (this repo only — NOT part of the user
# plugin payload — it lives in the contributor repo only).
# PreToolUse hook on Bash: blocks `git commit` when files under
# plugins/vine/skills/ are in the change set and trellis hasn't passed since
# the last skill-file edit. A fully green trellis run writes .vine/.trellis-ok
# with a "status: pass" first line; a red run overwrites it with
# "status: fail".
#
# The gate only governs commits made in THIS repo. A session rooted here can
# run git against other repos (git -C, cd, spawned scratch repos); those
# commits are none of the gate's business and pass untouched. The target
# repo is resolved from the command — an explicit `git -C <path>` beats a
# `cd <path>` in the command, which beats the payload cwd, which beats
# CLAUDE_PROJECT_DIR — and compared by absolute git common dir, so linked
# worktrees of this repo still gate.
#
# Unlike the scaffold hooks, this gate fails CLOSED when skill files
# changed without a fresh green stamp — that is its whole job. Missing
# tooling still fails open, and only a target that provably resolves to a
# DIFFERENT repo skips the gate. POSIX sh only.

root="${CLAUDE_PROJECT_DIR:-.}"

payload=$(cat 2>/dev/null) || payload=""
cwd=""
if command -v jq >/dev/null 2>&1; then
  cmd=$(printf '%s' "$payload" | jq -r '.tool_input.command // empty' 2>/dev/null) || cmd=$payload
  cwd=$(printf '%s' "$payload" | jq -r '.cwd // empty' 2>/dev/null) || cwd=""
else
  cmd=$payload
fi
case $cmd in
  *git*commit*) ;;
  *) exit 0 ;;
esac

# ---- resolve the directory the git command runs against ----
base=${cwd:-$root}

# First token of $1, honoring simple single/double quoting.
first_token() {
  case $1 in
    \"*) t=${1#\"}; printf '%s' "${t%%\"*}" ;;
    \'*) t=${1#\'}; printf '%s' "${t%%\'*}" ;;
    *)   printf '%s' "${1%%[[:space:]]*}" ;;
  esac
}

tgt=""
rest=$(printf '%s' "$cmd" | sed -n 's/.*git[[:space:]]\{1,\}-C[[:space:]]\{1,\}//p')
[ -n "$rest" ] && tgt=$(first_token "$rest")
if [ -z "$tgt" ]; then
  rest=$(printf '%s' "$cmd" | tr ';&|' '\n' | sed -n 's/^[[:space:]]*cd[[:space:]]\{1,\}//p' | tail -n 1)
  [ -n "$rest" ] && tgt=$(first_token "$rest")
fi
case $tgt in
  "") tgt=$base ;;
  /*) ;;
  *)  tgt="$base/$tgt" ;;
esac

# Absolute git common dir of the repo containing $1; empty when unresolvable.
repo_of() {
  d=$(git -C "$1" rev-parse --git-common-dir 2>/dev/null) || return 1
  case $d in
    /*) ;;
    *) d="$1/$d" ;;
  esac
  (CDPATH='' cd "$d" 2>/dev/null && pwd -P)
}

tgt_repo=$(repo_of "$tgt")
this_repo=$(repo_of "$root")
# Provably a different repo -> not ours to gate. Anything unresolvable falls
# through and gates as before (fail closed).
if [ -n "$tgt_repo" ] && [ -n "$this_repo" ] && [ "$tgt_repo" != "$this_repo" ]; then
  exit 0
fi

# Gate against the worktree the commit lands in — the same repo can have
# linked worktrees with independent change sets and stamps.
top=$(git -C "$tgt" rev-parse --show-toplevel 2>/dev/null) || top=""
[ -n "$top" ] || top=$root

# Gate only when skill files are in the change set — staged or unstaged,
# since compound "git add ... && git commit" calls stage after this hook runs.
changed=$(git -C "$top" status --porcelain -- plugins/vine/skills 2>/dev/null)
[ -n "$changed" ] || exit 0

stamp="$top/.vine/.trellis-ok"
if [ -f "$stamp" ] && grep -q '^status: pass' "$stamp" 2>/dev/null; then
  # Fresh = no skill file edited after the stamp was written.
  newer=$(find "$top/plugins/vine/skills" -name 'SKILL.md' -newer "$stamp" 2>/dev/null)
  [ -z "$newer" ] && exit 0
fi

cat >&2 <<EOF
VINE trellis gate: files under plugins/vine/skills/ changed but trellis has not
passed since the last skill edit. Run /trellis — a green run writes
.vine/.trellis-ok — then retry the commit.
EOF
exit 2
