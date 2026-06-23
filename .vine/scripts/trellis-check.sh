#!/bin/sh
# VINE trellis command-check engine (contributor-only — NOT part of the user
# scaffold; create-vine never copies this script).
#
# Runs trellis's command checks (Steps 1-4 of .claude/commands/trellis.md)
# mechanically, so the .vine/.trellis-ok stamp the gate reads becomes
# deterministic and CI-runnable instead of session-interpreted. The harder
# artifact checks (Steps 5-7, STATE.md template parsing) stay in the skill —
# they are out of scope here.
#
# Checks implemented, per skill file in plugins/vine/skills/<name>/SKILL.md:
#   1 Frontmatter present with exactly description/argument-hint/disable-model-invocation/allowed-tools
#   2 disable-model-invocation is true (VINE phases never auto-fire)
#   3 H1 == "# vine:<stem> — <subtitle>" (` — ` em-dash separator; <stem> = skill dir name)
#   4 Load Context Overlays section names .vine/context/<stem>.md (skip init/help)
#   5 Load Engineer Profile section present (skip init/help)
#   6 Overlays heading precedes Profile heading (skip init/help)
#   7 allowed-tools well-formed (single capitalized words) and known (union)
#   8 AskUserQuestion referenced in the body
#   9 Legacy .vine/hooks references outside the two allowlisted spots -> WARNING
#  11 Naked issue pointers in bodies (bare #<n>, not a [link] or glossed) -> WARNING
#
# Plus one repo-level check (not per-command, no table column):
#  10 Cross-reference anchors resolve (verification-tier contract family:
#     STATE.md note, agent mode/scope names, command pointers) -> FAILURE
#  12 Personal-root resolution wired into shared.md — the profile/overlay reads
#     route through the "Resolving the personal root" helper, not a bare
#     cwd-relative .vine.local/ read (#132 regression guard) -> FAILURE
#
# Writes .vine/.trellis-ok in the format the gate expects: a "status: pass"
# (or "status: fail") first line. Warnings never change pass/fail (matches the
# skill: legacy refs are warnings only). Exit 0 = all command checks pass,
# exit 1 = at least one failure. POSIX sh only — no bashisms, no jq.
#
# Usage: sh .vine/scripts/trellis-check.sh

set -u

root="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
SKILL_DIR="$root/plugins/vine/skills"
STAMP="$root/.vine/.trellis-ok"

EXPECTED_FIELDS="allowed-tools argument-hint description disable-model-invocation"

if [ ! -d "$SKILL_DIR" ]; then
  echo "trellis-check: no plugins/vine/skills/ directory at $root — nothing to validate." >&2
  exit 1
fi

# ---------- frontmatter helpers ----------

# Top-level frontmatter keys (between line 1's --- and the closing ---).
fm_fields() {
  awk 'NR==1{next} /^---$/{exit} /^[A-Za-z][A-Za-z-]*:/{sub(/:.*/,""); print}' "$1"
}

# allowed-tools list entries (the only multi-line list in the frontmatter).
fm_tools() {
  awk 'NR==1{next} /^---$/{exit} /^[[:space:]]*-[[:space:]]/{
    sub(/^[[:space:]]*-[[:space:]]*/,""); sub(/[[:space:]]+$/,""); print
  }' "$1"
}

# First H1 line after the frontmatter.
h1_line() {
  awk '/^---$/{c++; next} c>=2 && /^# /{print; exit}' "$1"
}

# Body (everything after the closing ---).
body_has_askuser() {
  awk '/^---$/{c++; next} c>=2' "$1" | grep -q 'AskUserQuestion'
}

# ---------- Step 2: build the union tool set ----------

UNION=$(for f in "$SKILL_DIR"/*/SKILL.md; do fm_tools "$f"; done | sort -u)

is_known_tool() {
  printf '%s\n' "$UNION" | grep -qx "$1"
}

# ---------- per-command validation ----------

PASS_CMDS=0
ISSUE_COUNT=0
FAIL_CMDS=0
FAILDETAIL=""
WARNINGS=""
GLOSSWARN=""

cell() { # cell <ok 0|1> ; echos a fixed-width status glyph
  if [ "$1" -eq 0 ]; then printf '%-5s' '✅'; else printf '%-5s' '❌'; fi
}
skipcell() { printf '%-5s' 'skip'; }

note_fail() { # note_fail <stem> <check> <detail>
  ISSUE_COUNT=$((ISSUE_COUNT + 1))
  FAILDETAIL="$FAILDETAIL
  - $1 — $2: $3"
}

printf '| %-9s | %-5s | %-5s | %-5s | %-5s | %-5s | %-5s | %-5s | %-5s |\n' \
  Skill Front NoFire H1 Overlay Profile Order Tools AskUsr
printf '|%s|%s|%s|%s|%s|%s|%s|%s|%s|\n' \
  '-----------' '-------' '-------' '-------' '-------' '-------' '-------' '-------' '-------'

for f in "$SKILL_DIR"/*/SKILL.md; do
  stem=$(basename "$(dirname "$f")")
  cmd_failed=0

  case "$stem" in
    init|help) skip_overlay=1 ;;
    *) skip_overlay=0 ;;
  esac

  # --- Check 1: frontmatter, exactly the 4 fields ---
  first=$(awk 'NR==1{print; exit}' "$f")
  fm_end=$(awk 'NR>1 && /^---$/{print NR; exit}' "$f")
  c1=1
  if [ "$first" = "---" ] && [ -n "$fm_end" ]; then
    got=$(fm_fields "$f" | sort -u | tr '\n' ' ' | sed 's/ *$//')
    want=$(printf '%s' "$EXPECTED_FIELDS" | tr ' ' '\n' | sort -u | tr '\n' ' ' | sed 's/ *$//')
    [ "$got" = "$want" ] && c1=0
  fi
  if [ "$c1" -ne 0 ]; then
    note_fail "$stem" Frontmatter "expected exactly [$EXPECTED_FIELDS]"
    cmd_failed=1
  fi

  # --- Check 2: disable-model-invocation is true (no auto-fire) ---
  dmi=$(awk 'NR==1{next} /^---$/{exit} /^disable-model-invocation:/{sub(/^disable-model-invocation:[[:space:]]*/,""); gsub(/["'\'']/,""); sub(/[[:space:]]+$/,""); print; exit}' "$f")
  c2=1
  [ "$dmi" = "true" ] && c2=0
  if [ "$c2" -ne 0 ]; then
    note_fail "$stem" NoFire "disable-model-invocation is '$dmi', expected 'true'"
    cmd_failed=1
  fi

  # --- Check 3: H1 format "# vine:<stem> — <subtitle>" ---
  h1=$(h1_line "$f")
  c3=1
  case "$h1" in
    "# vine:$stem — "*) c3=0 ;;
  esac
  if [ "$c3" -ne 0 ]; then
    note_fail "$stem" H1 "H1 is '$h1', expected '# vine:$stem — <subtitle>'"
    cmd_failed=1
  fi

  # --- Checks 4/5/6: overlays + profile (skip init/help) ---
  if [ "$skip_overlay" -eq 1 ]; then
    c4=skip; c5=skip; c6=skip
  else
    ov=$(grep -n '^## Load Context Overlays' "$f" | head -1 | cut -d: -f1)
    pr=$(grep -n '^## Load Engineer Profile' "$f" | head -1 | cut -d: -f1)

    # Check 4: phase path present in the overlays section.
    c4=1
    if [ -n "$ov" ]; then
      sect=$(awk -v s="$ov" 'NR>s && /^## /{exit} NR>=s{print}' "$f")
      printf '%s\n' "$sect" | grep -q "\.vine/context/$stem\.md" && c4=0
    fi
    if [ "$c4" -ne 0 ]; then
      note_fail "$stem" Overlays "overlays section missing .vine/context/$stem.md"
      cmd_failed=1
    fi

    # Check 5: profile section present.
    c5=1
    [ -n "$pr" ] && c5=0
    if [ "$c5" -ne 0 ]; then
      note_fail "$stem" Profile "missing '## Load Engineer Profile' heading"
      cmd_failed=1
    fi

    # Check 6: overlays before profile.
    c6=1
    if [ -n "$ov" ] && [ -n "$pr" ] && [ "$ov" -lt "$pr" ]; then c6=0; fi
    if [ "$c6" -ne 0 ]; then
      note_fail "$stem" Order "Load Context Overlays must precede Load Engineer Profile"
      cmd_failed=1
    fi
  fi

  # --- Check 7: allowed-tools well-formed + known ---
  c7=0
  tools=$(fm_tools "$f")
  if [ -z "$tools" ]; then
    c7=1
    note_fail "$stem" Tools "allowed-tools is empty"
  else
    for t in $tools; do
      case "$t" in
        *[!A-Za-z]*|"")
          c7=1; note_fail "$stem" Tools "malformed tool entry '$t'"; continue ;;
      esac
      case "$t" in
        [A-Z]*) ;;
        *) c7=1; note_fail "$stem" Tools "tool '$t' not capitalized"; continue ;;
      esac
      if ! is_known_tool "$t"; then
        c7=1; note_fail "$stem" Tools "unknown tool '$t' (not in union)"
      fi
    done
  fi
  [ "$c7" -ne 0 ] && cmd_failed=1

  # --- Check 8: AskUserQuestion referenced in body ---
  c8=1
  body_has_askuser "$f" && c8=0
  if [ "$c8" -ne 0 ]; then
    note_fail "$stem" AskUser "AskUserQuestion not referenced in body"
    cmd_failed=1
  fi

  # --- Check 9: legacy .vine/hooks references (warning-only) ---
  # Allowlist: the fallback paragraph (loading commands) and init.md's
  # "### Legacy Directory Migration" section. Anything else warns.
  warn=$(awk '
    {
      line=$0
      if (line ~ /^### Legacy Directory Migration/) mig=1
      else if (mig && line ~ /^#{1,3} /) mig=0
      if (line ~ /^If `\.vine\/context\/` doesn.t exist but legacy `\.vine\/hooks\/` does/) para=1
      else if (para && line ~ /^$/) para=0
      if (line ~ /\.vine\/hooks/ && !(mig || para)) printf "%d\t%s\n", NR, line
    }' "$f")
  if [ -n "$warn" ]; then
    while IFS=$(printf '\t') read -r ln txt; do
      [ -n "$ln" ] || continue
      WARNINGS="$WARNINGS
- $stem/SKILL.md:$ln — $txt"
    done <<EOF
$warn
EOF
  fi

  # --- Check 11: naked issue pointers in the body (warning-only) ---
  # A bare #<n> that isn't a [#n](link) and isn't immediately glossed by a
  # parenthetical reads as an opaque pointer (references/STATE.md
  # "Reference Legibility"). Warning-only; never affects pass/fail.
  naked=$(awk '/^---$/{c++; next} c>=2{
    t=$0
    gsub(/\[[^][]*\]/, " ", t)   # drop [link text]/[placeholders] — legibility there is prose-judged
    s=t
    while (match(s, /#[0-9]+/)) {
      pre = (RSTART>1) ? substr(s, RSTART-1, 1) : ""
      post = substr(s, RSTART+RLENGTH, 1)
      if (pre != "(" && post != "(" && post !~ /[A-Za-z0-9]/) {
        printf "%d\t%s\n", FNR, $0
        break
      }
      s = substr(s, RSTART+RLENGTH)
    }
  }' "$f")
  if [ -n "$naked" ]; then
    while IFS=$(printf '\t') read -r ln txt; do
      [ -n "$ln" ] || continue
      GLOSSWARN="$GLOSSWARN
- $stem/SKILL.md:$ln — $txt"
    done <<EOF
$naked
EOF
  fi

  # --- render row ---
  if [ "$c4" = skip ]; then ov_c=$(skipcell); pr_c=$(skipcell); or_c=$(skipcell)
  else ov_c=$(cell "$c4"); pr_c=$(cell "$c5"); or_c=$(cell "$c6"); fi
  printf '| %-9s | %s| %s| %s| %s| %s| %s| %s| %s|\n' \
    "$stem" "$(cell "$c1")" "$(cell "$c2")" "$(cell "$c3")" \
    "$ov_c" "$pr_c" "$or_c" "$(cell "$c7")" "$(cell "$c8")"

  if [ "$cmd_failed" -eq 0 ]; then
    PASS_CMDS=$((PASS_CMDS + 1))
  else
    FAIL_CMDS=$((FAIL_CMDS + 1))
  fi
done

TOTAL=$((PASS_CMDS + FAIL_CMDS))

# ---------- Check 10: cross-reference anchors (repo-level) ----------
# Literal file|anchor pairs. The same list lives in .claude/commands/trellis.md
# (Check 10) — keep the two identical. Renaming an anchored section means
# updating both lists; that is the sync act this check enforces.

ANCHOR_TOTAL=0
ANCHOR_ISSUES=0
ANCHORDETAIL=""
while IFS='|' read -r af anchor; do
  [ -n "$af" ] || continue
  ANCHOR_TOTAL=$((ANCHOR_TOTAL + 1))
  if [ ! -f "$root/$af" ] || ! grep -qF -- "$anchor" "$root/$af"; then
    ANCHOR_ISSUES=$((ANCHOR_ISSUES + 1))
    ANCHORDETAIL="$ANCHORDETAIL
  - $af — missing anchor: $anchor"
  fi
done <<'PAIRS'
references/STATE.md|**Verification-tier contract.**
plugins/vine/agents/vine-verification.md|### Feature Verification (cross-change)
plugins/vine/agents/vine-verification.md|**Phase-group scope**
plugins/vine/agents/vine-verification.md|**Full-feature scope**
plugins/vine/agents/vine-verification.md|**Base checks**
plugins/vine/agents/vine-verification.md|**Cross-cutting checks**
plugins/vine/skills/navigate/SKILL.md|verification-tier contract note
plugins/vine/skills/evolve/SKILL.md|verification-tier contract note
PAIRS

# An emptied pair list must not read as green — zero pairs is a failure.
if [ "$ANCHOR_TOTAL" -eq 0 ]; then
  ANCHOR_ISSUES=1
  ANCHORDETAIL="
  - PAIRS list is empty — the anchor check verified nothing"
fi

# ---------- Check 12: personal-root resolution wired into shared.md ----------
# Guards #132: the high-frequency profile/overlay reads in shared.md's protocols
# must route through the "Resolving the personal root" helper, never a bare
# cwd-relative `.vine.local/` read — which a linked git worktree does not check
# out, so the read silently returns nothing. FAILURE. Skipped when shared.md is
# absent (it is optional). Only inspects shared.md: command files inherit the
# fix by deferring to these protocols.

SHARED="$root/.vine/context/shared.md"
RESOLVE_ISSUES=0
RESOLVEDETAIL=""
if [ -f "$SHARED" ]; then
  # (a) the helper must be defined (lives in the Overlay Loading Protocol).
  if ! grep -qF '**Resolving the personal root.**' "$SHARED"; then
    RESOLVE_ISSUES=$((RESOLVE_ISSUES + 1))
    RESOLVEDETAIL="$RESOLVEDETAIL
  - shared.md — missing the \`**Resolving the personal root.**\` helper definition"
  fi
  # (b) the Engineer Profile Protocol must reference it — reverting to a bare
  #     cwd-relative PROFILE.md read drops this phrase and trips the check.
  epp=$(awk '/^## Engineer Profile Protocol/{f=1; next} f && /^## /{exit} f{print}' "$SHARED")
  if ! printf '%s\n' "$epp" | grep -qF 'Resolving the personal root'; then
    RESOLVE_ISSUES=$((RESOLVE_ISSUES + 1))
    RESOLVEDETAIL="$RESOLVEDETAIL
  - shared.md — Engineer Profile Protocol must route the PROFILE.md read through 'Resolving the personal root' (bare cwd-relative read regresses #132)"
  fi
fi

echo
if [ "$ISSUE_COUNT" -eq 0 ]; then
  SUMMARY="✅ $TOTAL/$TOTAL skills pass all checks"
else
  SUMMARY="❌ $ISSUE_COUNT issues found across $FAIL_CMDS skills"
fi
echo "$SUMMARY"
[ -n "$FAILDETAIL" ] && printf '%s\n' "$FAILDETAIL"

if [ "$ANCHOR_ISSUES" -eq 0 ]; then
  ANCHOR_SUMMARY="✅ Cross-reference anchors resolve ($ANCHOR_TOTAL pairs)"
else
  ANCHOR_SUMMARY="❌ $ANCHOR_ISSUES cross-reference anchor(s) missing"
fi
echo "$ANCHOR_SUMMARY"
[ -n "$ANCHORDETAIL" ] && printf '%s\n' "$ANCHORDETAIL"

if [ "$RESOLVE_ISSUES" -eq 0 ]; then
  RESOLVE_SUMMARY="✅ Personal-root resolution wired into shared.md (#132 guard)"
else
  RESOLVE_SUMMARY="❌ $RESOLVE_ISSUES personal-root resolution gap(s) in shared.md"
fi
echo "$RESOLVE_SUMMARY"
[ -n "$RESOLVEDETAIL" ] && printf '%s\n' "$RESOLVEDETAIL"

if [ "$ISSUE_COUNT" -eq 0 ] && [ "$ANCHOR_ISSUES" -eq 0 ] && [ "$RESOLVE_ISSUES" -eq 0 ]; then
  STATUS="pass"
else
  STATUS="fail"
fi

if [ -n "$WARNINGS" ]; then
  echo
  echo "⚠️ Legacy \`.vine/hooks/\` references (warnings — slated to harden to failures"
  echo "   with the 0.5 fallback removal):"
  printf '%s\n' "$WARNINGS"
fi

if [ -n "$GLOSSWARN" ]; then
  echo
  echo "⚠️ Naked issue pointers (bare #<n> with no gloss — see STATE.md Reference Legibility):"
  printf '%s\n' "$GLOSSWARN"
fi

# ---------- Step 8: write the pass stamp ----------
when=$(date '+%Y-%m-%d %H:%M' 2>/dev/null || echo unknown)
mkdir -p "$root/.vine"
{
  echo "status: $STATUS"
  echo "checked: $when"
  echo "summary: $SUMMARY; $ANCHOR_SUMMARY; $RESOLVE_SUMMARY"
} > "$STAMP"

[ "$STATUS" = pass ]
