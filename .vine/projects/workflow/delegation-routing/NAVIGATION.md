# Navigation Log: Delegation-Routing Harness Re-scope (roadmap rewrite)
## Date: 2026-06-11

### Slice 1: ROADMAP.md rewrite — Complete
- **Started**: 2026-06-11 10:30
- **Commit**: 64a3021
- **Approach taken**: Kept the existing document skeleton (intro → goal → sections → cycle table → out-of-scope → cleanup → process notes) and rewrote content around the routing loop. New sections: "The core loop" (loop + gearing axis + per-stage notes + roles-not-fleet), "Target environments" (E1/E2/E3), "Overlay layers and precedence" (consolidates decisions 2, 4, 6 + the fallback), "The spike's six questions". Cycle table renumbered: 0 spike → 1 foundation → 2 knowledge → 3 cross-actor state → 4 team layer → 5 plugin, with #46–50 as an unnumbered pair-mode side-track row. Completed cycles compressed to a one-line "Done so far" note (avoids the old #62 "plan mode" language). Obsolescence discipline placed in the guiding principle as a third bolded paragraph.
- **Deviations from spec**: None. One scheduling call the spec left open: cross-actor state slotted as cycle 3 (after knowledge, before team layer) — rationale: it unlocks hybrid-parallel and is shaped by spike question 2; team layer depends on precedence + shared knowledge, not on it. Its issue number is a placeholder ("New issue(s), filed with this re-scope") until slice 2 files it; slice 2 backfills the number.
- **Validation**: pass — vine-verification agent: backward-compat paragraph verbatim (character-identical), no "plan mode", #62 only in the history line, all 20 issue links full-form URLs, all slice ACs verified individually. markdownlint not configured (skipped per overlay's "once configured").
- **Decisions made**:
  - Cross-actor state as cycle 3 with issue-number placeholder: (decided by: claude, free-climb slice — flag at boundary review)
  - Spike question 6 rephrased from "where does the route decision get recorded" to "do the decided journaling homes give evolve enough" — the original question predates SPEC decision 5, which answered it; the spike now validates rather than designs: (decided by: claude)
- **Acceptance criteria**:
  - [x] Core loop named up front; gearing axis stated as thesis — verified
  - [x] Boundary discipline strengthened in guiding principle (criteria/contracts/artifacts vs. execution mechanics; never an agent runner) — verified
  - [x] Backward-compat paragraph carried verbatim — verified character-identical
  - [x] New cycle table with all required elements (spike + six questions, foundation composition, #53 paired, knowledge as calibration substrate, team/plugin after foundation, #46–50 side-track flagged) — verified
  - [x] Precedence fallback written in — verified
  - [x] Decisions 4, 5, 6 recorded where they bind — verified
  - [x] E1/E2/E3, cross-actor new-issue territory (#61 closed), roles-not-fleet, evolve calibration loop, ingest as consumption contract, obsolescence discipline — all verified
  - [x] No stale references: #62 absent from foundation story, no "plan mode" — verified
- **Engineer feedback incorporated**: Free-climb slice — boundary review pending.
- **Learnings**:
  - Claude → Engineer: The old roadmap's "status lives in the milestone, not here" discipline did the heavy lifting for compression — pushing all reshaped-issue detail to slice 2's bodies kept the table rows readable.
  - Engineer → Claude: None yet this slice (free climb).

### Slice 2: Issue reshaping pass — Complete
- **Started**: 2026-06-11 (same session)
- **Commit**: pending
- **Approach taken**: Drafted all seven public changes (five issue edits, one new issue, milestone description) and presented them as one review batch before firing — per the SPEC's live-edit risk note, which holds in every gear. Applied via `gh issue edit --body-file` / `gh issue create` / `gh api PATCH`. Retitled #54, #55, #52, #57 to match their reshaped scopes. New cross-actor issue landed as #79; its number backfilled into ROADMAP.md's cycle 3 row (committed with this slice).
- **Deviations from spec**: None. One refinement: Review Preferences stayed in PROFILE.md during the #55 split (it's preference-class content per the rule-class taxonomy; the spec named only Decision Delegation / Risk Tolerance as moving).
- **Validation**: pass — re-fetched all six live bodies + milestone description: zero `.vine/hooks/` references, zero "plan mode" references. Engineer reviewed and approved the full batch before any edit fired.
- **Decisions made**:
  - Fire all seven as one batch rather than individually: (decided by: engineer)
  - Retitle four issues alongside the body rewrites so list views match the reshaped scopes: (decided by: claude)
  - Review Preferences stays profile-side in the #55 split: (decided by: claude)
- **Acceptance criteria**:
  - [x] #54 reshaped: composite eligibility predicate, routing-layer gate semantic with interactive fallback, shipped-home constraint — verified in live body
  - [x] #53 updated: option C dependency resolution, decision classification retained, structured-handoff flagged as spike question 5 — verified
  - [x] #57 expanded: team-overlay distribution; propagation = plugin update + init recompose under the hard gate — verified
  - [x] #55 split: Decision Delegation / Risk Tolerance → routing policy; domain levels / Growth Goals stay — verified
  - [x] #52 reframed: team-layer overlay composition; tracked-default flip, `.local` projects, conflict-safe conventions survive — verified
  - [x] New cross-actor issue filed (#79): slice ownership, in-flight state, handoff payload, PAUSE/ACTIVE/PROFILE redesign under E2 — in v0.4.0 milestone
  - [x] Milestone description "plan mode" staleness fixed — verified
  - [x] Each body reads cold (no session-context references; rationale carried in "Source" sections with re-scope date)
- **Engineer feedback incorporated**: Batch approved as drafted.
- **Learnings**:
  - Claude → Engineer: Stamping reshaped bodies with "Reshaped/Updated/Split 2026-06-11 by the delegation-routing re-scope (ROADMAP.md)" in their Source sections gives an E3 reader the why without this feature's SPEC — the issue history plus the roadmap reference reconstructs the decision trail.
  - Engineer → Claude: None this slice (free climb).
