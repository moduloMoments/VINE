#!/bin/sh
# VINE contributor main-commit guard (this repo only — NOT part of the user
# plugin payload — it lives in the contributor repo only).
# PreToolUse hook on Bash: blocks `git commit` while the checkout is on
# 'main'. Spawned/parallel sessions sometimes open on the shared checkout
# without a worktree; this gate turns "session committed straight to main"
# into a hard stop with instructions instead of a cleanup job.
#
# The guard only governs commits made in THIS repo. A session rooted here can
# run git against other repos (git -C, cd, spawned scratch repos); those
# commits are none of the guard's business and pass untouched. The target
# repo is resolved from the command — an explicit `git -C <path>` beats a
# `cd <path>` in the command, which beats the payload cwd, which beats
# CLAUDE_PROJECT_DIR — and compared by absolute git common dir. Same-repo
# targets are judged by the branch of the worktree the commit lands in, so
# linked worktrees aren't misread through the root checkout's HEAD.
#
# Fails open on missing tooling, detached HEAD, or any ambiguity.
# POSIX sh only.

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
# Provably a different repo -> not ours to guard.
if [ -n "$tgt_repo" ] && [ -n "$this_repo" ] && [ "$tgt_repo" != "$this_repo" ]; then
  exit 0
fi

# Judge the worktree the commit lands in — linked worktrees of this repo have
# their own HEAD, independent of the root checkout's.
branch=$(git -C "$tgt" symbolic-ref --short -q HEAD 2>/dev/null) || exit 0
[ "$branch" = "main" ] || exit 0

cat >&2 <<EOF
VINE main guard: this checkout is on 'main' — commits belong on a feature
branch. Run git checkout -b <branch> first (parallel sessions should use a
worktree instead of the shared checkout).
EOF
exit 2
