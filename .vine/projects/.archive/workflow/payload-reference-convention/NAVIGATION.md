# Navigation: Payload-Relative Reference Convention
## Feature: .vine/projects/workflow/payload-reference-convention
## Started: 2026-06-23
## Built on: SPEC.md (2026-06-23)

Strictly sequential: Slice 0 → 1 → 2 → 3. Single PR (4 tightly-coupled slices).

### Slice 0: Rename STATE.md → CONTRACTS.md (live surfaces) — Complete
**Started**: 2026-06-23 17:05
**Commit**: e75b744
**Gear**: free-climb
**Approach taken**: `git mv references/STATE.md references/CONTRACTS.md`, then a scoped
per-file `sed 's/STATE.md/CONTRACTS.md/g'` over the live/operative set only — the renamed file's
self-refs, `CLAUDE.md`, `README.md`, `.vine/README.md`, `.vine/context/{shared,verify,navigate,evolve,pair}.md`,
`.claude/agents/vine-coder.md`, `.claude/commands/{trellis,pr-review}.md`, `ROADMAP.md`, and the two
`.vine/scripts/*.sh`. No blanket repo-wide sed, honoring the historical carve-out.
**Deviations from spec**: Added `.vine/scripts/trellis-check.sh` and `.vine/scripts/run-tests.sh`
to the touched set (not in SPEC's "Files likely touched"). Both hardcode the Check 10 anchor pair
and the test fixture stubbing it; the rename breaks `/trellis` without them. Annotated in SPEC.md
Slice 0 as a navigate addendum.
**Validation**: `pass` — `sh .vine/scripts/trellis-check.sh` exits 0 (8 anchor pairs resolve,
including the renamed `references/CONTRACTS.md` pair); `sh .vine/scripts/run-tests.sh` 27/27 pass.
Pre-existing legacy `.vine/hooks/` warnings in init unchanged (warnings, not failures).
**Decisions made during implementation**:
  - Scope bare `STATE.md` mentions (not just `references/STATE.md`) into the rename: all live
    mentions name the same file, so renaming the file renames them too (decided by: claude) [confidence: high]
  - Leave the feature's own CONTEXT.md/SPEC.md naming `STATE.md` untouched — they are
    period-accurate verify/inquire records of the rename plan, not operative references
    (decided by: claude) [confidence: high]
**Acceptance criteria**:
  - [x] `references/STATE.md` gone; `references/CONTRACTS.md` present
  - [x] Zero live files reference `STATE.md`
  - [x] CHANGELOG (5 refs) + dated `.vine/knowledge/` ADRs (6 files) unchanged — period-accurate
  - [x] `/trellis` passes; cross-reference anchors intact
**Engineer feedback incorporated**: None yet (free climb; review at slice boundary).
**Learnings**:
  - Claude → Engineer: the Check 10 anchor pair lives in three coupled places (the
    `trellis.md` table, `trellis-check.sh`'s PAIRS heredoc, and `run-tests.sh`'s fixture) — a file
    rename has to update all three in lockstep or the anchor check fails / the test fixture drifts.
  - Engineer → Claude: None.

### Slice 1: Document the convention — Complete
**Started**: 2026-06-23 17:25
**Commit**: bc04aef
**Gear**: free-climb
**Approach taken**: Wrote the three-bucket reference convention into its two homes. CLAUDE.md
"Skill Authoring Conventions" gets one bullet + three sub-bullets (the authoring rule: payload-internal
→ invocable name / `${CLAUDE_PLUGIN_ROOT}`; consumer working tree → as-is; VINE-source-internal →
forbidden, inline via operative-copy; init writes no VINE-internal pointer). CONTRACTS.md gets a
"Path resolution by audience" subsection under Reference Legibility, framed as the *why* (the #138
two-audience split — plugin user cwd vs contributor repo root) and cross-linking CLAUDE.md as the
authoring home. Minimal duplication: CLAUDE.md = rule, CONTRACTS.md = rationale.
**Deviations from spec**: None.
**Validation**: `pass` — trellis-check exit 0; run-tests 27/27; both homes state the three buckets.
**Decisions made during implementation**:
  - Split the content by purpose rather than duplicating verbatim (AC requires both homes state the
    buckets, but CLAUDE.md carries the rule and CONTRACTS.md the audience-resolution why) — keeps the
    doc-growth surface tight (decided by: claude) [confidence: high]
**Acceptance criteria**:
  - [x] Both homes state the three buckets
  - [x] Self-contained rule for shipped skills stated
  - [x] Name / `${CLAUDE_PLUGIN_ROOT}` rule for payload cross-refs stated
  - [x] Init writes no VINE-internal pointer stated
**Engineer feedback incorporated**: None (free climb; review at slice boundary).
**Learnings**:
  - Claude → Engineer: the AC "both homes state the buckets" risks pure duplication; splitting by
    purpose (rule vs rationale) satisfies it without two copies drifting apart.
  - Engineer → Claude: None.

### Slice 2: Make shipped skills self-contained — Complete
**Started**: 2026-06-23 17:40
**Commit**: e72f448
**Gear**: free-climb
**Approach taken**: Applied the three-bucket convention across all 9 affected skills, batched by
size (small six → init → navigate → evolve). Triaged each `references/STATE.md` citation as binary:
runtime-critical → inline an operative copy; provenance-only → drop the path. Net: 60 `references/`
citations removed from skill bodies (58 STATE.md + the agent pair), 0 remain. Runtime-critical
inlines were few — PROFILE.md format (`## Domain Expertise` table) inlined in verify + evolve; the
PAUSE.md template (pause), ACTIVE format (navigate), and journal-entry schema (navigate) were
already inline below their pointers, so the pointers just dropped. For "two roots" pointers, cited
`shared.md`'s Overlay Loading Protocol (bucket-2) instead — matching verify's existing in-skill
pattern. Converted the two agent citations (`agents/vine-verification.md` → "the `vine-verification`
agent") to invocable-name form. Removed the dead consumer-template pointers from init (README step
4, CLAUDE.md step 8) and — discovered — optimize's CLAUDE.md-pointer template (3e). Reworded three
descriptive bare-payload-path mentions to satisfy the #138 no-bare-path AC.
**Deviations from spec**: Three, all annotated in SPEC.md Slice 2 addendum. (1) optimize also wrote
a dead `references/STATE.md` pointer into a consumer's CLAUDE.md (spec named only init); fixed.
(2) Removing the bucket-3 "verification-tier contract note" pointer from navigate/evolve broke
`/trellis` Check 10 — removed the two stale anchor pairs from all three coupled homes
(`trellis-check.sh`, `trellis.md`, `run-tests.sh`). (3) Reworded three descriptive bare-payload-path
mentions (init `skills/<name>/SKILL.md`, init `hooks/hooks.json`, evolve "skills/commands").
**Validation**: `pass` — `sh .vine/scripts/trellis-check.sh` exit 0 (11/11 skills pass; 6 anchor
pairs resolve; legacy `.vine/hooks/` lines remain warning-only, unchanged); `sh .vine/scripts/run-tests.sh`
27/27. Greps confirm zero `references/` and zero bare `agents/|skills/|hooks/` file paths in
`plugins/vine/skills/`; shipped agents/hooks carry only bucket-2 `.vine/` + `${CLAUDE_PLUGIN_ROOT}`
refs (unchanged — confirmed clean, not edited).
**Decisions made during implementation**:
  - Binary triage (inline vs drop), never leave a `references/` path even as provenance — the
    self-contained rule (CONTRACTS.md:572) forbids any VINE-source-internal path on a shipped
    surface (decided by: claude) [confidence: high]
  - Drop dangling enumerated references ("property 4", "the five properties") rather than cite a
    number the runtime can't resolve — the operative ADR-writing template is inline; the five
    properties never were (decided by: claude) [confidence: high]
  - Cite `shared.md`'s Overlay Loading Protocol (bucket-2) for personal-root resolution instead of
    the bucket-3 *The two roots* — matches verify's pre-existing in-skill pattern (decided by: claude) [confidence: high]
**Acceptance criteria**:
  - [x] Zero `references/STATE.md` (or any `references/…`) in `plugins/vine/skills/` (#142)
  - [x] No bare `agents/|skills/|hooks/` path in a skill body; payload cross-refs by invocable name (#138)
  - [x] init's README + CLAUDE.md templates write no `references/…` pointer; same for optimize (#141)
  - [x] Runtime-critical content inlined (PROFILE.md format); a spot-run produces a correct artifact
        — the live navigate session itself, plus trellis structural pass on all 11 skills
  - [x] Shipped agents/hooks confirmed clean (bucket-2 only)
**Engineer feedback incorporated**: Free climb + batch-by-size checkpointing (engineer's gear choice);
review at slice boundary.
**Learnings**:
  - Claude → Engineer: most of the 58 STATE.md refs were provenance ("see X for detail"), safe to
    drop — the runtime-critical content was already inlined, confirming verify's read. Only PROFILE.md
    format needed a fresh inline (in two skills).
  - Claude → Engineer: a removed cross-reference can break `/trellis` from the *other* side — Check 10
    couples the skill's pointer phrase to an anchor pair, so deleting the pointer requires deleting
    its pair (the Slice 0 lockstep, run in reverse).
  - Engineer → Claude: None.

### Slice 3: Add the /trellis regression guard — Complete
**Started**: 2026-06-23 18:05
**Commit**: 01db36c
**Gear**: free-climb
**Approach taken**: Added **Check 13** to `.vine/scripts/trellis-check.sh` (repo-level, modeled on
Check 12): scans `plugins/vine/{skills,agents,hooks}/` and fails on (1) any `references/…` path or
(2) a bare `agents|skills|hooks/` plugin-root path. Key design move: every *legitimate* occurrence
of those tokens is `/`-preceded (`${CLAUDE_PLUGIN_ROOT}/`, `**/`, `.claude/`, `.vine/`), so the
bare-path regex `(^|[^/[:alnum:]])(agents|skills|hooks)/[A-Za-z<]` anchors on a non-slash boundary —
no allowlist of legitimate prefixes needed. Wired into the summary line, the STATUS pass/fail gate,
and the `.trellis-ok` stamp. Documented as Check 13 in `.claude/commands/trellis.md` (the check + the
Step 4 result line). Added 3 CI-parity tests to `run-tests.sh` (references/ fails, bare hooks/ fails,
bucket-2 + name-based agent refs pass).
**Deviations from spec**: One, annotated in SPEC.md Slice 3 addendum — the guard flagged a *prose*
"skills/agents" at `init/SKILL.md:45` (two-word slash, not a path); despaced to "skills and agents",
the same fix evolve "skills/commands" got in Slice 2. Known limitation of the non-slash-boundary
heuristic, documented in the Check 13 prose.
**Validation**: `pass` — `sh .vine/scripts/trellis-check.sh` exit 0 (all four repo-level guards green,
including the new "Shipped surfaces carry no VINE-source-internal reference" line); `sh .vine/scripts/run-tests.sh`
30/30 (was 27; +3 Check 13 tests). Manual battery confirmed: clean→pass, `references/` injection→fail,
bare `hooks/` injection→fail, agent's 2 `.vine/context` refs→do not trip.
**Decisions made during implementation**:
  - Non-slash-boundary regex over an explicit prefix allowlist — simpler and self-maintaining, since
    new legitimate prefixes (any `…/agents/`) are `/`-preceded by construction (decided by: claude) [confidence: high]
  - Despace prose `X/Y` rather than complicate the regex to distinguish prose from paths — only two
    such cases exist, and a slash-free "X and Y" reads fine (decided by: claude) [confidence: high]
**Acceptance criteria**:
  - [x] A deliberately-added `references/CONTRACTS.md` line in a skill fails `/trellis` (tested, both
        scripted and manual)
  - [x] The corrected tree passes
  - [x] The shipped agent's `.vine/context/…` references do not trip it (tested)
  - [x] Bare `agents|skills|hooks/` path also caught (beyond the SPEC's references/ example)
**Engineer feedback incorporated**: Free climb; continue in session (engineer's gear + proceed choices).
**Learnings**:
  - Claude → Engineer: a guard's regex is only as good as its false-positive profile — writing the
    guard immediately surfaced a prose `X/Y` the human eye skips over. Running it against the live tree
    *before* trusting it caught the one case the design hadn't anticipated.
  - Engineer → Claude: None.

### Remaining Work
- **Incomplete slices**: All slices complete (0–3).
- **Blockers encountered**: None.
- **Handoff context for evolve**: Single PR, 4 tightly-coupled slices (commits e75b744, bc04aef,
  e72f448, + Slice 3 pending). Closes #142/#141/#138 — use `Refs #N` on the impl PR (evolve + a
  knowledge ADR still owe their part per the issue-close-timing convention). Deviations to review:
  (a) optimize's consumer-CLAUDE.md template carried the same #141 dead pointer as init (fixed,
  beyond spec's named scope); (b) the navigate/evolve Check 10 anchor pair was removed across all
  three coupled homes (consequence of Slice 2's pointer removal); (c) two prose `X/Y` despaced
  (init, evolve) for the guard. New durable knowledge candidate: the three-bucket reference
  convention itself + the non-slash-boundary guard heuristic. Verify the v0.4.x CHANGELOG/version
  bump and whether this ships as a patch or minor (it's prose/tooling + a new guard — likely patch,
  but the guard is arguably a new capability).
