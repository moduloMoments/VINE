# Navigation Log: Consolidate AskUserQuestion constraints block (#47)

## Date: 2026-06-12

### Slice 1: Consolidate AskUserQuestion constraints block — In Progress

- **Started**: 2026-06-12
- **Commit**: pending
- **Route**: headless (Agent-tool subagent, local worktree) <!-- throwaway scaffold (spike Q2/Q6) -->
- **Actor**: claude (headless subagent) <!-- throwaway scaffold (spike Q2/Q6) -->
- **Approach taken**: Added an "Interaction Constraints" section to `.vine/context/shared.md` carrying the full generic AskUserQuestion constraint set. In each of the four command files (verify, inquire, navigate, optimize), kept the phase-specific intro sentence ("Use AskUserQuestion for...") and replaced only the bulleted generic constraint list with a one-line reference to the shared section, mirroring the #48 profile-protocol convention.
- **Deviations from spec**: None.
- **Validation**: `trellis-check.sh` exit 0 (11/11 commands pass, fresh `status: pass` stamp in `.vine/.trellis-ok`). `run-tests.sh`: 19 passed / 4 failed — the 4 failures are exactly the known-red trellis-check fixture baseline; no new failures. Acceptance criteria checked directly by this actor (Agent tool unavailable in session — no `vine-verification` delegation possible). Grep sweep confirmed no duplicated generic constraint list remains in `commands/vine/`.
- **Decisions made**: Kept each file's phase-specific "Use AskUserQuestion for..." intro sentence as the graceful-fallback layer; replaced only the bulleted constraint list. Placed the shared section after "Engineer Profile Protocol". Dropped per-file parenthetical multiSelect examples that lived inside the generic lists (they were illustrations of the generic rules, not phase instructions); preserved truly phase-specific blocks untouched (navigate's gearing question spec, optimize's pattern table). Details in "Decisions Taken Autonomously" below.
- **Acceptance criteria**:
  - [x] shared.md has the "Interaction Constraints" section with the full constraint set
  - [x] All four command files reference it in place of their generic block; no generic block remains duplicated
  - [x] Each replacement degrades gracefully without shared.md (the #48 convention)
  - [x] trellis-check.sh exits 0 with a fresh pass stamp before the commit
  - [x] run-tests.sh shows no NEW failures beyond the known baseline
- **Engineer feedback incorporated**: none — headless run
- **Learnings**: The #48 convention's "graceful fallback" is structural, not textual — there is no fallback sentence anywhere; sanity without shared.md comes from the inline behavioral instruction that stays in each command. Mirroring that meant keeping the intro sentences rather than collapsing entire sections to one line. evolve.md carries a one-phrase "Max 4 options" mention (line ~220) woven into phase instructions — out of #47's four-file scope, left alone.
