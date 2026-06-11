# Navigation Log: Delegation-Routing Harness Re-scope (roadmap rewrite)
## Date: 2026-06-11

### Slice 1: ROADMAP.md rewrite — Complete
- **Started**: 2026-06-11 10:30
- **Commit**: pending
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
