# Evolution Report: Multi-PR Tracking for Large Features
## Date: 2026-04-02

### Product Evolution
#### Acceptance Criteria Results

| # | Criterion | Status |
|---|-----------|--------|
| 1 | Verify creates PROJECT-MAP.md | ✅ Pass |
| 2 | Inquire updates PROJECT-MAP.md | ✅ Pass |
| 3 | Navigate updates PROJECT-MAP.md | ✅ Pass |
| 4 | Evolve updates PROJECT-MAP.md | ✅ Pass |
| 5 | Resume reads PROJECT-MAP.md | ✅ Pass |
| 6 | Pause reads PROJECT-MAP.md | ✅ Pass |
| 7 | Inquire auto-flags multi-PR | ✅ Pass |
| 8 | STATE.md documents PROJECT-MAP.md | ✅ Pass |
| 9 | Backward compatible | ✅ Pass |
| 10 | Navigate phase completion flow | ✅ Pass |

#### Spec Deviations

1. **Phase-group verification in navigate step 9** (Slice 4) — Added mini-verification pass (lint, typecheck, tests, coverage, AC rollup, cross-slice integration) before suggesting PR at phase boundaries. Not in original spec. Justified: ensures PRs are shippable without requiring full evolve.
2. **gh CLI PR review in evolve** (Slice 5) — Added `gh pr view` and `gh api` for reviewing prior phase PRs during multi-PR features. Not in original spec. Justified: surfaces reviewer feedback for cross-phase integration.

Both deviations are additive and don't change existing behavior.

#### Follow-Up Items

1. **Shared verification instructions** — Navigate step 9's phase-group verification and evolve's product check overlap. Potential extraction to prevent drift. Low priority now.
2. **`vine:status` command** — Lightweight command to read PROJECT-MAP.md and show progress without resume's full artifact scan.
3. **PR number backfill in resume** — Resume could prompt for missing PR numbers on shipped phases.
4. **`glow` rendering hook** — Shared hook could suggest `glow -w 100` for PROJECT-MAP terminal rendering.

### Agent Evolution
#### CLAUDE.md Suggestions

- **Add PROJECT-MAP.md mention to State Artifact Chain** — Accepted. One-line addition describing verify creating PROJECT-MAP.md and inquire adding Milestones.

#### Skill Suggestions

No strong candidates this cycle. Multi-PR tracking is baked into commands, not a repeatable scaffold pattern.

#### Hook Update Suggestions

- **Trellis reminder in navigate hook** — Accepted. Run `/trellis` after completing all slices.
- **PROJECT-MAP in evolve hook doc guardrail** — Accepted. Added to doc growth checklist.

#### VINE Process Observations

- Verify → inquire handoff was smooth. CONTEXT.md captured the right landscape detail.
- Navigate's per-slice commit approach made git history tell the implementation story well.
- No meta-friction from modifying VINE commands while VINE guided the work.

### User Evolution
#### Knowledge Highlights

- Identified the conceptual gap between session boundaries and PR boundaries — this design insight shaped the entire feature direction.
- Made strong judgment calls on quality gates (phase-group verification) and cross-PR integration (gh CLI review).
- Third multi-command cycle; comfort zone confirmed.

#### Suggested Explorations

- Multi-repo feature tracking — PROJECT-MAP could evolve into a cross-repo coordination point.

#### Profile Updates

- vine-commands: kept at `confident`, updated date to 2026-04-02 — Accepted
- Growth log entry added — Accepted

#### Claude Memory Suggestions

No general preferences discovered this cycle.

### Handoff Package
#### PR Description

```markdown
## Summary
Add PROJECT-MAP.md as a universal progress tracker for VINE features. Every project gets an
at-a-glance VINE Progress table; multi-PR features additionally get a Milestones table mapping
phase groups to PRs with status markers (✅/🚧/⬜).

## Changes
- 56d39ef STATE.md: define PROJECT-MAP.md artifact
- 59845e5 verify.md: create PROJECT-MAP.md at phase completion
- 1de1476 inquire.md: multi-PR detection and PROJECT-MAP updates
- 6cf2274 navigate.md: phase completion flow and PROJECT-MAP updates
- 668447b navigate.md: add phase-group verification before PR suggestion
- 325834b evolve.md: multi-PR awareness with PROJECT-MAP and PR review
- cbb7be8 pause.md + resume.md: PROJECT-MAP awareness

## Decisions Made
- PROJECT-MAP.md as new file vs SPEC.md extension — chose new file for scannability
- Phase-group verification in navigate step 9 — ensures PRs are shippable without full evolve
- gh CLI PR review in evolve — surfaces reviewer feedback across phase boundaries
- Inline verification vs shared skill — chose inline, noting duplication risk as follow-up

## Testing
- All 6 slices validated per-commit (frontmatter, document flow, tool availability)
- Trellis passes clean: 8/8 commands, 5/5 artifacts
- Cross-slice integration verified: consistent lifecycle, status markers, file paths, backward compat

## Follow-up
- Shared verification instructions between navigate step 9 and evolve (prevent drift)
- `vine:status` command for lightweight progress checks
- PR number backfill in resume
- `glow` rendering hook for PROJECT-MAP
```

#### Reviewer Notes

This is a meta-feature — it modifies VINE's command files, which ARE the product. Key areas for review:
- `references/STATE.md` PROJECT-MAP section sets the contract for all other changes
- `commands/vine/navigate.md` step 9 (lines ~305-370) is the heaviest change — phase-group verification + milestone updates
- Every command guards PROJECT-MAP reads with "if it exists" — verify no path assumes it's present
- The feature is fully backward compatible — projects without PROJECT-MAP.md work identically
