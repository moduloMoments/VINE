#!/bin/sh
# Test matrix for VINE hook scripts (contributor-only — never shipped by
# create-vine). Each case runs against a throwaway temp repo so the live
# repo's sentinel and stamp are untouched.
#
# Usage: sh .vine/scripts/run-tests.sh
# Exit 0 = all pass; exit 1 = failures (each printed with expected/actual).

set -u

SCRIPTS_DIR=$(cd "$(dirname "$0")" && pwd)
PASS=0
FAIL=0

ok() { PASS=$((PASS + 1)); printf 'ok   %s\n' "$1"; }
no() { FAIL=$((FAIL + 1)); printf 'FAIL %s\n' "$1"; }

check() { # check <description> <expected-rc> <actual-rc>
  if [ "$2" -eq "$3" ]; then ok "$1"; else no "$1 (expected rc $2, got $3)"; fi
}

payload_commit='{"tool_input":{"command":"git commit -m x"}}'
payload_ls='{"tool_input":{"command":"ls -la"}}'

# ---------- journal-check.sh ----------
J="$SCRIPTS_DIR/journal-check.sh"
T=$(mktemp -d)
( cd "$T" && git init -q . && git commit -q --allow-empty -m init )
export CLAUDE_PROJECT_DIR="$T"

printf '%s' "$payload_commit" | sh "$J" >/dev/null 2>&1
check "journal-check: no sentinel -> allow" 0 $?

mkdir -p "$T/.vine" "$T/feat"
printf 'feature: feat\nphase: t\nstarted: now\n' > "$T/.vine/ACTIVE"

printf '%s' "$payload_ls" | sh "$J" >/dev/null 2>&1
check "journal-check: non-commit command -> allow" 0 $?

printf '%s' "$payload_commit" | sh "$J" >/dev/null 2>&1
check "journal-check: no journal yet -> allow" 0 $?

touch -t 202001010000 "$T/feat/NAVIGATION.md"
printf '%s' "$payload_commit" | sh "$J" >/dev/null 2>&1
check "journal-check: stale journal -> block (exit 2)" 2 $?

touch "$T/feat/NAVIGATION.md"
printf '%s' "$payload_commit" | sh "$J" >/dev/null 2>&1
check "journal-check: fresh journal (same-second tie fails open) -> allow" 0 $?

rm -rf "$T"

# ---------- post-edit-lint.sh ----------
L="$SCRIPTS_DIR/post-edit-lint.sh"
T=$(mktemp -d)
export CLAUDE_PROJECT_DIR="$T"

printf '{}' | sh "$L" >/dev/null 2>&1
check "post-edit-lint: no sentinel -> allow" 0 $?

mkdir -p "$T/.vine"
printf 'feature: x\nphase: t\nstarted: now\n' > "$T/.vine/ACTIVE"

printf '{}' | sh "$L" >/dev/null 2>&1
check "post-edit-lint: no overlay -> allow" 0 $?

mkdir -p "$T/.vine/context"
printf '## Validation Commands\n\n- `false` (once configured)\n' > "$T/.vine/context/navigate.md"
printf '{}' | sh "$L" >/dev/null 2>&1
check "post-edit-lint: prose backtick without marker -> allow" 0 $?

printf 'hook-validation: true\n' >> "$T/.vine/context/navigate.md"
printf '{}' | sh "$L" >/dev/null 2>&1
check "post-edit-lint: passing marker command -> allow" 0 $?

printf 'hook-validation: false\n' > "$T/.vine/context/navigate.md"
printf '{}' | sh "$L" >/dev/null 2>&1
check "post-edit-lint: failing marker command -> block (exit 2)" 2 $?

rm -rf "$T/.vine/context"
mkdir -p "$T/.vine/hooks"
printf 'hook-validation: false\n' > "$T/.vine/hooks/navigate.md"
printf '{}' | sh "$L" >/dev/null 2>&1
check "post-edit-lint: legacy overlay location honored -> block (exit 2)" 2 $?

rm -rf "$T"

# ---------- trellis-gate.sh ----------
G="$SCRIPTS_DIR/trellis-gate.sh"
T=$(mktemp -d)
( cd "$T" && git init -q . && mkdir -p commands/vine .vine \
  && echo cmd > commands/vine/test.md && git add -A && git commit -qm init )
export CLAUDE_PROJECT_DIR="$T"

printf '%s' "$payload_commit" | sh "$G" >/dev/null 2>&1
check "trellis-gate: no command changes -> allow" 0 $?

echo edit >> "$T/commands/vine/test.md"
printf '%s' "$payload_commit" | sh "$G" >/dev/null 2>&1
check "trellis-gate: changed, no stamp -> block (exit 2)" 2 $?

printf 'status: fail\n' > "$T/.vine/.trellis-ok"
printf '%s' "$payload_commit" | sh "$G" >/dev/null 2>&1
check "trellis-gate: red stamp -> block (exit 2)" 2 $?

sleep 1
printf 'status: pass\n' > "$T/.vine/.trellis-ok"
printf '%s' "$payload_commit" | sh "$G" >/dev/null 2>&1
check "trellis-gate: fresh green stamp -> allow" 0 $?

sleep 1
echo edit2 >> "$T/commands/vine/test.md"
printf '%s' "$payload_commit" | sh "$G" >/dev/null 2>&1
check "trellis-gate: edit newer than stamp -> block (exit 2)" 2 $?

printf '%s' "$payload_ls" | sh "$G" >/dev/null 2>&1
check "trellis-gate: non-commit -> allow" 0 $?

rm -rf "$T"

printf '\n%d passed, %d failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
