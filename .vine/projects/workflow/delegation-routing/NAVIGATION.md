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
- **Commit**: d322135
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

### Slice 3: #46–50 freshness pass — Complete
- **Started**: 2026-06-11 (same session)
- **Commit**: pending
- **Approach taken**: Verified all five bodies against the working tree before drafting. Found #49/#50 landed (live frontmatter matches their proposals) — and #48 landed too (7/8 commands use the one-line shared.md profile reference; status.md's variant is deliberate per the interaction-surface principle). Updated #46 (current section names, the bootstrap-can't-be-externalized constraint, cross-reference to the foundation cycle's precedence work touching the same blocks) and #47 (count corrected 3→4: optimize gained a constraints block). Closed #48/#49/#50 with verification comments. Synced the roadmap's side-track row to #46/#47 only (committed with this slice).
- **Deviations from spec**: #48 closed as landed — the spec's letter said "update paths" for #46–48 and only anticipated #49/#50 as possibly done. Surfaced to the engineer; closing keeps the delegation-test-case set honest (a cold actor on #48 would find nothing to do). SPEC.md annotated.
- **Validation**: pass — re-fetched live bodies: #46/#47 reference `.vine/context/`; their two remaining `.vine/hooks/` strings are intentional (one names the live legacy-fallback feature, one documents the rename in the Source line), not stale paths. States verified: #46/#47 OPEN, #48/#49/#50 CLOSED.
- **Decisions made**:
  - Close #48 as landed rather than spec-literal path fix: (decided by: engineer)
  - Sync roadmap side-track row to surviving issues: (decided by: claude)
  - Treat historical/feature-naming `.vine/hooks/` mentions as compliant with the "no stale paths" AC — the AC's intent is no wrong instructions, not no occurrences of the string: (decided by: claude)
- **Acceptance criteria**:
  - [x] All five bodies reference `.vine/context/`, not `.vine/hooks/` (surviving stale paths: none; two intentional mentions documented above)
  - [x] #49/#50 verified against live skill descriptions and closed with comments
  - [x] Each surviving body (#46, #47) actionable cold — correct paths, current counts and section names
- **Engineer feedback incorporated**: Engineer chose closure over spec-literal path fix for #48.
- **Learnings**:
  - Claude → Engineer: The freshness pass doubled as a drift detector — #48 had silently landed via the shared-pattern convention work, the same way #49/#50 landed via the description rewrites. Verified-against-working-tree before editing is the right default for any issue old enough to predate a rename.
  - Engineer → Claude: The "no stale references" bar is about whether a cold actor would act wrongly, not string presence — confirmed via the #48 closure choice.
