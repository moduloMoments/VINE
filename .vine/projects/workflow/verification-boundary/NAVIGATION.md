# Navigation Journal: Verification Boundary (navigate ↔ evolve reconciliation)
## Feature: .vine/projects/workflow/verification-boundary
## Started: 2026-06-11
## Branch: verification-boundary (worktree: VINE-verification-boundary)

### Slice 1: Agent as authoritative checklist — Complete
**Started**: 2026-06-11 10:30
**Commit**: 151cdfa (dd2247b before rebase onto post-#84 main)
**Approach taken**: Restructured the "Feature Verification (cross-change)" mode in
`agents/vine-verification.md` into a named, scoped checklist. Four **base checks** (both
scopes): full test suite, cross-slice integration, acceptance criteria, test coverage —
numbered 1–4. Three **cross-cutting checks** (full-feature scope only): error paths,
cross-slice edge cases, combined performance — numbered 5–7, absorbed from evolve's
delegation prompt. Scope parameter documented up front with caller attribution (phase-group
= navigate at phase-group boundaries; full-feature = evolve at cycle end) plus a
single-source statement so readers know navigate/evolve delegate rather than restate.
Output format gained a "Cross-Cutting Concerns" section with an inline HTML comment marking
it full-feature-only. Added `.vine/context/evolve.md` to the Finding Project Tools
discovery list (ride-along fix from CONTEXT.md tech debt).
**Deviations from spec**: None.
**Validation**: Pass — vine-verification agent verified all 5 slice ACs (frontmatter valid,
cross-references resolve, markdownlint not configured in repo). `trellis-check.sh` green
(11/11 commands) after a transient Bash-classifier outage delayed it.
**Decisions made during implementation**:
  - Default scope when caller doesn't specify: full-feature (safer/complete). One-line
    fallback in the mode definition. (decided by: claude, free-climb minor call)
  - Scope vocabulary fixed as "phase-group scope" / "full-feature scope"; check groups as
    "Base checks" / "Cross-cutting checks" — these are the anchor names slices 2–5 and the
    trellis anchor check will reference. (decided by: claude, per spec's naming latitude)
  - Agent file does NOT point at the STATE.md contract note (STATE.md doesn't ship via
    create-vine; the agent self-describes as single source instead). navigate.md/evolve.md
    will carry the contract-note pointers per spec AC. (decided by: claude, consistent with
    spec's shipped-surface reasoning)
**Acceptance criteria**:
  - [x] Mode names each base check — verified (lines 52–60)
  - [x] Scope parameter described with what each scope includes — verified (lines 43–50)
  - [x] Cross-cutting concerns listed under full-feature scope — verified (lines 62–67)
  - [x] `.vine/context/evolve.md` in discovery list — verified (line 98)
  - [x] Output format accommodates both scopes — verified (lines 89–90)
**Engineer feedback incorporated**: None yet — free-climb slice; diff review at boundary.
**Learnings**:
  - Engineer → Claude: Profile/context confirmed the inline-vs-delegated split was a
    historical accident, which licensed making the agent the single source rather than
    preserving parallel checklists.
  - Claude → Engineer: Numbering base checks 1–4 and cross-cutting 5–7 in one continuous
    list keeps the "full-feature = superset" relationship visible at a glance.

### Slice 2: Navigate delegates phase-group verification — Complete
**Started**: 2026-06-11 13:30
**Commit**: a027582 (c0a13ef before rebase)
**Approach taken**: Replaced navigate.md step 8 item 1's inline a–d checks with a delegation
to the `vine-verification` agent in feature verification mode at phase-group scope. The
delegation passes the phase group's changed files, each slice's ACs, and overlay validation
commands — mirroring step 4a's per-slice delegation phrasing. Report handling is structured
by the agent's report sections: Acceptance Criteria (rollup to engineer, resolve unmet),
Test Coverage (per-slice AskUserQuestion triage: add now or defer), anything else
(fix-in-session). Kept the "lighter than evolve's full pass" exclusion sentence and the
PR-shippable bar verbatim. The stale "mirrors steps a-d" cross-ref blockquote is replaced
by a "Verification tiers" blockquote pointing at the STATE.md verification-tier contract
note (written in Slice 4) and at the agent file as the checklist home. Step 8 items 2–5
untouched. Checked README: line 56's "runs a lightweight verification pass" stays accurate
under delegation — no README change needed.
**Deviations from spec**: None.
**Validation**: Pass — vine-verification agent verified all 6 slice ACs; /trellis green
(11/11 commands, artifact checks pass, fresh .vine/.trellis-ok stamp).
**Decisions made during implementation**:
  - Report-section names ("Acceptance Criteria section", "Test Coverage section") are the
    only check vocabulary step 8 retains — section names of the agent's report, not a
    restated checklist. (decided by: claude, free-climb minor call)
  - README left unchanged — its phrasing doesn't assert inline execution. (decided by:
    claude, per spec's "adjust if present" instruction)
**Acceptance criteria**:
  - [x] No restated checklist in step 8 — verified ("don't restate it here" + no check
    enumeration)
  - [x] Delegation names agent, mode, and scope — verified (navigate.md:417–419)
  - [x] Triage and fix-in-session flows intact — verified (navigate.md:428–438)
  - [x] Tracker-update items 2–5 of step 8 untouched — verified (navigate.md:448–463)
  - [x] Contract-note pointer in place — verified (navigate.md:443–446)
**Engineer feedback incorporated**: None — free-climb slice; diff review at boundary.
**Learnings**:
  - Engineer → Claude: The engineer designed the original phase-group verification as a
    deliberately lighter pre-PR gate — preserving that exclusion sentence verbatim was the
    fixed point the rewrite pivoted around.
  - Claude → Engineer: Driving the triage flows off the agent's report-section names (not
    restated checks) keeps step 8 readable while leaving exactly one checklist surface.

### Slice 3: Evolve slims its delegation — Complete
**Started**: 2026-06-11 13:40
**Commit**: 7ec6674 (6f814ab before rebase)
**Approach taken**: Rewrote evolve.md's Cross-Slice Integration Check to delegate to the
`vine-verification` agent in feature verification mode at full-feature scope by name. The
four-bullet restated checklist is gone; cross-cutting concerns are referenced only as "the
cross-cutting checks that full-feature scope adds" (they live in the agent since Slice 1).
What evolve passes stays explicit: the feature's changed files + SPEC ACs, and
`.vine/context/evolve.md` integration validation commands. The stale "Navigate step 9"
cross-ref blockquote is replaced by the same "Verification tiers" blockquote shape used in
navigate.md, pointing at the STATE.md contract note and the agent file. Evolve-only content
untouched: Trust Per-Slice Verification, AC Traceability, the multi-PR gh block, Review
Spec Deviations, Identify Follow-Up Work, Prep the Handoff.
**Deviations from spec**: None.
**Validation**: Pass — vine-verification agent verified all 4 slice ACs; trellis-check.sh
green (11/11, fresh stamp).
**Decisions made during implementation**:
  - The two tier-pointer blockquotes (navigate.md, evolve.md) use deliberately parallel
    wording, differing only in which tier is "this" — gives Slice 5's anchor check a stable
    shape to verify. (decided by: claude, free-climb minor call)
**Acceptance criteria**:
  - [x] Delegation references named mode + scope, no restated base checks — verified
    (evolve.md:110–113)
  - [x] Cross-cutting concerns no longer listed in the prompt — verified (referenced by
    label only)
  - [x] Evolve-only sections unchanged — verified (all six present with documented behavior)
  - [x] Stale "step 9" reference gone — verified (zero grep hits; pointer at
    evolve.md:118–121)
**Engineer feedback incorporated**: None — free-climb slice; diff review at boundary.
**Learnings**:
  - Engineer → Claude: None this slice — the deletion followed directly from Slice 1's
    single-source structure.
  - Claude → Engineer: Keeping "what to pass the agent" explicit while deleting "what the
    agent checks" is the line that makes a delegation slim without making it vague.

### Slice 4: STATE.md verification-tier contract note — Complete
**Started**: 2026-06-11 13:50
**Commit**: 67fd1a6 (9042b2b before rebase)
**Approach taken**: Added the "Verification-tier contract." note to `references/STATE.md`
immediately after the AC-traceability contract — third in the #66 family, same shape (bold
lead-in paragraph, prose body, no heading, so no `<!-- required -->`/`<!-- optional -->`
marker needed). It documents: both tiers delegate to the agent's feature-verification mode;
the checklist lives only in `agents/vine-verification.md`; navigate = phase-group scope
(base checks, deliberately lighter pre-PR gate); evolve = full-feature scope (base +
cross-cutting checks); the asymmetry is intentional; evolve-only scope enumerated (AC
traceability, deviation review, follow-up triage, handoff prep, multi-PR gh review/CI)
with the rationale that it isn't agent-runnable; closing "rules live in the agent and the
commands; this note keeps contributors in sync" sentence matching the family idiom.
**Deviations from spec**: None. (Spec said "new STATE.md section" with marker convention
"or matches the #66 contract-note shape if those notes carry no marker — match whichever
the existing family uses"; the family uses unmarked bold paragraphs, so that's the shape
used — the spec's own either/or, not a deviation.)
**Validation**: Pass — vine-verification agent verified all 4 slice ACs and cross-checked
terminology against the agent file and both command pointers (exact matches).
**Decisions made during implementation**:
  - Placed the note with the existing family under the NAVIGATION.md section rather than
    creating a new top-level section — precedent: AC-traceability also spans evolve/SPEC
    and lives there; keeping the family physically together beats taxonomic purity.
    (decided by: claude, free-climb minor call)
  - The note enumerates the base and cross-cutting check names — STATE.md is
    contributor-side and the spec says the note "states which tier checks what"; the
    single-source AC constrains the two shipped commands, not this supplementary note.
    (decided by: claude)
**Acceptance criteria**:
  - [x] Note matches #66 family shape — verified (STATE.md:145, fifth bold-lead-in note)
  - [x] Heading-marker convention respected — verified (no new heading, fences untouched)
  - [x] Enumerates evolve-only scope — verified (all five items)
  - [x] Names the agent mode and both scopes — verified (exact terminology matches)
**Engineer feedback incorporated**: None — free-climb slice; diff review at boundary.
**Learnings**:
  - Engineer → Claude: The #66 contract-note pattern ("the rule lives in the command; the
    note keeps contributors in sync") scaled cleanly to a three-surface rule.
  - Claude → Engineer: A contract note that names exact anchor strings (scope names, check
    names) doubles as the data source for Slice 5's mechanical anchor check.

### Slice 5: Trellis cross-reference anchor check — Complete
**Started**: 2026-06-11 16:00
**Commit**: 230ec5c (727729d before rebase; trellis.md Step 8 conflict resolved against
#84's script-owned stamp — anchor failures now described as flipping the script-written
stamp, matching what trellis-check.sh already did)
**Approach taken**: Added "Check 10: Cross-Reference Anchors (repo-level)" to both
contributor surfaces. In `.claude/commands/trellis.md`: a new Check 10 section under Step 3
with the 8-pair file→anchor table, a Step 4 addition printing the anchor result line, and
Step 8 updates so anchor failures flip the stamp to fail (scope note now reads "command
structure and cross-reference anchors only"). In `.vine/scripts/trellis-check.sh`: a
data-driven block after the per-command loop — pairs in a quoted PAIRS heredoc, loop logic
separate, `grep -qF --` literal matching (POSIX sh, no bashisms), its own summary line, and
the stamp's summary now semicolon-joins the anchor result. The 8 pairs: STATE.md's
`**Verification-tier contract.**`; the agent's mode heading and four vocabulary anchors
(Phase-group scope, Full-feature scope, Base checks, Cross-cutting checks); and
"verification-tier contract note" pointer presence in navigate.md and evolve.md. Both
lists carry "keep the two lists identical" comments pointing at each other.
**Deviations from spec**: None.
**Validation**: Pass — green run on the landed change (8 pairs, exit 0, stamp
"status: pass"); red test with a renamed anchor failed loudly (exit 1, stamp
"status: fail", detail naming file + missing anchor) and restored cleanly. The
vine-verification agent confirmed list identity character-for-character, POSIX
compliance, doc/script agreement, and all 8 anchors resolving. bin/cli.js's explicit
SCAFFOLD_SCRIPTS allowlist (journal-check.sh only) confirms nothing new ships.
**Decisions made during implementation**:
  - Anchor failures count toward the stamp's pass/fail (unlike Check 9 warnings) — the
    drift class this feature exists to fix should block, not warn. (decided by: claude,
    free-climb call consistent with "fail loudly" spec language)
  - Pointer-presence pairs for navigate.md/evolve.md (last two) guard the reverse
    direction: the note can't silently lose its inbound pointers. (decided by: claude)
  - Pairs match stable tokens (bold lead-ins, headings, the literal phrase
    "verification-tier contract note"), not full sentences — reword-tolerant, rename-strict.
    (decided by: claude)
**Acceptance criteria**:
  - [x] Check fails when an anchor is renamed/removed and passes on the landed change —
    verified by red/green runs
  - [x] Lives only in contributor-side files — verified (.claude/commands/ +
    .vine/scripts/; SCAFFOLD_SCRIPTS allowlist unchanged)
  - [x] Trellis doc lists the new check alongside 1–9/A–D — verified (Check 10 section,
    Step 4 + Step 8 updates)
**Engineer feedback incorporated**: None — free-climb slice; diff review at boundary.
**Learnings**:
  - Engineer → Claude: The #70 "scriptable style" (data list separated from loop logic,
    POSIX sh, stamp contract) made the new check a pattern-follow rather than a design.
  - Claude → Engineer: Testing the red path (rename an anchor, watch it fail, restore) is
    the only real proof a guard works — a check that's only ever seen green is untested.

### Remaining Work
- **Incomplete slices**: All slices complete (5 of 5).
- **Blockers encountered**: None. (A transient Bash-classifier outage during Slice 1
  delayed its trellis run and commit by a few minutes; no impact on the work.)
- **Handoff context**: Single-PR feature per spec — evolve should prep one PR for the
  branch `verification-boundary` (worktree VINE-verification-boundary), closing #69.
  Spec's Backlog Updates note for #54: one checklist surface now exists to wire its YAML
  validation contract into — note the composition when #54 starts. No spec deviations
  anywhere in the cycle, so evolve's deviation review should be a clean no-op. Discovered
  items: none. The anchor pair list (trellis.md Check 10 + trellis-check.sh PAIRS) is new
  conscious debt — when anchored sections are renamed, both lists need the matching update;
  the check fails loudly to force exactly that.
