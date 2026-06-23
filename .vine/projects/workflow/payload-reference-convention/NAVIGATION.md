# Navigation: Payload-Relative Reference Convention
## Feature: .vine/projects/workflow/payload-reference-convention
## Started: 2026-06-23
## Built on: SPEC.md (2026-06-23)

Strictly sequential: Slice 0 → 1 → 2 → 3. Single PR (4 tightly-coupled slices).

### Slice 0: Rename STATE.md → CONTRACTS.md (live surfaces) — Complete
**Started**: 2026-06-23 17:05
**Commit**: pending
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
