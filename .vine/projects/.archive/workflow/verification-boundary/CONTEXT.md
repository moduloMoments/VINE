# Feature Context: Verification Boundary (navigate ↔ evolve reconciliation)
## Date: 2026-06-11
## Author: Rob Bruhn + Claude

Source: [#69](https://github.com/moduloMoments/VINE/issues/69) — the last open cycle-1.5 item.
Carried from platform-alignment NAVIGATION.md "Handoff context for evolve" (evolve candidate #2).
Roadmap originally tagged cycle 1.5 for `vine:pair`, but flagged #69 as needing a design call on
the navigate/evolve verification boundary — engineer chose the full cycle for the design
discussion and documentation trail.

### Codebase Landscape

VINE has two verification tiers plus one shared agent, and the checklist they share is
expressed independently in **three** places (the issue says two; exploration found a third):

1. **`commands/vine/navigate.md` step 8 ("Between Phase Groups"), item 1** — phase-group
   verification, run **inline** by the navigate session at each phase-group boundary before
   suggesting a PR. Named checks a–d:
   - a. Validation across the phase group's changes (lint, typecheck, **full test suite**,
     custom commands from `.vine/context/navigate.md`)
   - b. Test coverage per slice (AskUserQuestion per untested slice: add now or defer)
   - c. Per-slice acceptance criteria rollup against committed code
   - d. Cross-slice integration **within the phase group** (imports, data flow, references)

   Explicit exclusions, stated in prose: "no deviation review, no follow-up triage, no
   handoff prep — but thorough enough that a PR opened after this step is shippable."

2. **`commands/vine/evolve.md` Evolution 1 ("Product")** — the full pass at cycle end.
   **Delegates** the integration check to the `vine-verification` agent in feature
   verification mode. Evolve-only additions on top of navigate's tier:
   - Cycle-level **AC traceability** (SPEC top-level criteria → slice/commit evidence,
     "unaccounted" flagging) — distinct from navigate's per-slice AC rollup
   - Cross-cutting concerns (error paths, edge cases spanning slices, performance of the
     combined changes)
   - Multi-PR: prior-PR review + CI status via `gh` (added by #68/#75)
   - Spec deviation review, follow-up triage, handoff prep
   - Trusts per-slice verification from NAVIGATION.md (doesn't re-verify slices)

3. **`agents/vine-verification.md` "Feature Verification (cross-change)" mode** — names
   essentially the same checklist a third time: full test suite, cross-slice integration,
   all spec ACs, test coverage. Also has a "Slice Verification" mode used per-slice during
   navigate. Output format is its own structure (Automated Checks / Acceptance Criteria /
   Issues Found / Test Coverage).

Sync mechanism today: two hand-maintained prose cross-reference blockquotes (navigate.md
~line 455, evolve.md ~line 119) asking the author to check the other file. Nothing
mechanical — `/trellis` (checks 1–9 structural, A–D artifact) has no check covering these
cross-references, and `trellis-check.sh` doesn't either.

### Current State

**The hand-sync has already drifted** — concrete evidence the issue's premise holds:

- navigate's cross-ref says it "mirrors steps a-d of evolve's Cross-Slice Integration
  Check" — but evolve's check has no a–d structure (it's a bullet list in an agent
  delegation prompt). The a–d labels exist only in navigate.
- evolve's cross-ref points at "Navigate step 9" — the section is **step 8** ("Between
  Phase Groups"). Stale after a renumbering.

The coverage asymmetry itself (evolve heavier: deviations, follow-ups, handoff, AC
traceability, prior-PR/CI) is **intentional** and roughly legible from prose, but the
boundary is documented nowhere — a reader can't tell which check is authoritative for what,
and navigate's exclusion list is the only place the split is even hinted at.

Recent related work (all landed, cycle 1.5):
- #66 (PR #75/#76) added the **contract-note pattern** to `references/STATE.md` (lines
  ~141–143): "Deviation-closure contract" and "AC-traceability contract" — short notes
  stating "the rule lives in the command; this note keeps contributors in sync." STATE.md
  is supplementary (doesn't ship via create-vine).
- #68 added evolve's prior-PR CI-status read.
- #70 added `trellis-check.sh` — a scriptable home if any new mechanical check comes out
  of this feature.

### Edge Cases & Tribal Knowledge

- **The inline-vs-delegated split is a historical accident** (engineer confirmed). Navigate
  runs its phase-group checks inline; evolve delegates to the vine-verification agent.
  There is no design rationale behind the difference — so *who runs the checks* is in scope
  for the design discussion, not just where the checklist is written.
- The coverage asymmetry (evolve heavier) is intentional and must survive any
  reconciliation — the goal is a documented/shared boundary, not identical tiers.
- The phase-group verification was designed by the engineer in workflow/multi-pr-tracking
  (2026-04-02), deliberately "lighter than full evolve" as a pre-PR quality gate.
- STATE.md section headings use `<!-- required -->` / `<!-- optional -->` markers; new
  STATE.md sections need a marker or trellis Check A drifts.
- Both commands also consume `.vine/context/<phase>.md` overlay validation commands —
  navigate reads navigate.md, evolve reads evolve.md. The agent's own discovery fallback
  reads `.vine/context/navigate.md` or `pair.md` (NOT evolve.md — a fourth small
  inconsistency worth noting in design).

### Constraint from Adjacent Roadmap Work

**#54 (cycle 4, agent-native): machine-readable validation contract.** It moves the
validation *commands* (lint/typecheck/test invocations) into a structured YAML block in
shared.md that vine-verification, navigate, evolve, and pair all consume. #69 and #54
compose: #69 owns the **coverage boundary** (which tier checks what, why), #54 owns the
**command source** (how each check is invoked). Design constraint: whatever #69 produces
must not pre-empt #54's schema — e.g., don't invent a command-listing format now; keep the
shared contract at the level of *named checks*, leaving invocation discovery as-is for #54.

### Tech Debt in Affected Areas

- Three-way duplication of the verification checklist (navigate inline, evolve's agent
  prompt, the agent's own mode definition). Severity: medium — it has already produced
  drift; directly addressed by this feature.
- Stale "step 9" reference in evolve.md — symptom; fix rides along with whatever the
  design lands.
- Agent's tool-discovery fallback omits `.vine/context/evolve.md` while serving evolve's
  delegation. Small; decide in inquire whether it's in scope or a follow-up.

### Documentation Gaps

- `references/STATE.md` has no note on the verification tiers — the issue's suggested
  direction #1. The #66 contract-note pattern (deviation-closure, AC-traceability) is the
  established shape for exactly this; a "verification-tier contract" note would be the
  third in that family.
- The cross-reference blockquotes in navigate.md and evolve.md are the only boundary
  documentation, and both are partially wrong (see Current State).

### Open Questions

1. **Document vs factor vs both** (the issue's two suggested directions): (a) a STATE.md
   contract note documenting the tier split, keeping each command's prose authoritative
   for its own tier; (b) a named shared checklist (e.g., in STATE.md or shared.md) that
   both commands and the agent reference instead of restating; or (c) a thin combination —
   note the boundary in STATE.md and rewrite the three checklists to reference one named
   list of checks. Direction (b)/(c) must respect the #54 constraint above.
2. **Who runs navigate's tier?** Since inline-vs-delegated is an accident: should
   navigate's phase-group check also delegate to vine-verification (feature mode scoped to
   the phase group)? That would collapse surfaces 1 and 3 — but changes navigate's
   session behavior and token profile, and the agent is sonnet-pinned.
3. **Mechanical teeth?** Should trellis (and/or `trellis-check.sh`) gain a check that the
   cross-references stay valid (e.g., section-anchor existence), per the "modes need
   mechanical teeth" principle? Or is that over-enforcement for supplementary prose?
4. **Scope of the agent-fallback fix** (missing `.vine/context/evolve.md` in the agent's
   discovery list): ride along or follow-up issue?
5. **Where does the shared checklist live if factored?** STATE.md doesn't ship via
   create-vine; commands do. A checklist both shipped commands reference can't live in a
   contributor-only file — this constrains direction (b)/(c) materially.
