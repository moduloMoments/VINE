# Evolution Report: Platform Alignment (v0.4.0 cycle 1) — Phases 4+5

## Date: 2026-06-10

This report covers the final phase group (Phase 4 — Native Tasks #61, Phase 5 —
Mode/Gate/Workflow #62), which ship together as **PR 4**. Phases 1–3 already shipped via
PR #63 (#58 rename), PR #65 (#59 honest enforcement), and PR #67 (#60 knowledge boundary).

### Product Evolution

#### Acceptance Criteria Results

Per-slice ACs are committed and trusted from NAVIGATION.md; evolve verified cross-slice integration.

| Slice | Title | ACs |
|-------|-------|-----|
| 14 | STATE.md contracts + SPEC h3 fix | 3/3 ✅ |
| 15 | Navigate task tracking | 3/3 ✅ |
| 16 | Resume/status/inquire task awareness | 4/4 ✅ |
| 17 | Gearing ↔ permission-mode | 4/4 ✅ |
| 18 | Inquire sign-off gate + review links | 6/6 ✅ |
| 19 | Artifact-commit guidance | 5/5 ✅ |
| 20 | Between-slice `/clear` | 5/5 ✅ |
| 21 | README + CHANGELOG docs | 8/8 ✅ |

**38/38 ACs met across the phase group.**

#### Cross-Slice Integration (vine-verification agent — 8/8 contracts PASS)

1. **Backward-compat gate** ✅ — every native-task instruction in navigate/resume guarded
   "when available"; navigate has the master skip clause (line 117–119). Task tools absent →
   navigate/resume/status behave byte-identically to before.
2. **Task rebuild consistency** ✅ — resume's rebuild rules match navigate's create rules
   (remaining slices in current group, `blockedBy`-ordered, skip Complete, conditional prefix).
   resume adds one resume-specific `In Progress → in_progress` update (correct for mid-session pickup).
3. **Source-of-truth principle** ✅ — task flips `completed` only after journal write + commit;
   no path writes the journal FROM a task (STATE.md "rebuilt FROM the journal, never the reverse").
4. **Artifact-commit alignment** ✅ — navigate step 4c/8, evolve's commit section, and STATE.md
   `## Committing Artifacts` agree; evolve no longer stages EVOLUTION.md unconditionally.
5. **No plan-mode leakage** ✅ — grep of commands/vine, README, CHANGELOG, STATE.md → zero matches.
6. **Gearing↔mode symmetry** ✅ — both gears name their mode in navigate prose and README Key
   Principles; every mode reference frames the toggle as the engineer's action.
7. **trellis** ✅ — 11/11; new frontmatter tools self-ratify via consensus union; zero new
   legacy `.vine/hooks` refs in shipped files.
8. **Doc accuracy** ✅ — README/CLAUDE.md claims match command behavior.

**Other validation**: hook test suite 11/11 (`run-tests.sh`), `node --check bin/cli.js` OK,
`.claude/settings.json` valid JSON.

**Prior-PR review**: PR #63, #65, #67 all MERGED, no unresolved review concerns carried forward.

#### Spec Deviations

| Deviation | Slice | Justification |
|-----------|-------|---------------|
| **Plan mode dropped from the cycle entirely** | Phase 5 reshape | `ExitPlanMode` is harness-owned (Claude calls it itself); a VINE command teaching it that narrates behavior VINE doesn't own. Same repo-owned-decision line as the Phase 2 lint-hook removal. Slice 17 became gearing↔permission-mode instead. |
| trellis.md touched beyond "STATE.md only" | 14 | Check A/C are mechanically coupled to the SPEC template; the point was making trellis pass on this feature's own grouped SPEC. |
| Source-of-truth section generalized to cover PROJECT-MAP | 14 | Engineer chose "document the principle" over scoping to just tasks. |
| CLAUDE.md valid-tools rider | 15 | Contributor doc accuracy; done once so Slice 16 needn't re-touch it. |
| resume granted `Edit` + `/clear` exception | 16 | Engineer's call — made the latent PR-backfill claim honest; resume's "creates no artifacts" reword licenses it. |
| Write-then-review over "no write before approval" | 18 | A clickable review link needs the file written first; the gate moved to *completion*. |
| Self-sufficient commands over STATE-as-single-source | 19 | `references/STATE.md` doesn't ship via create-vine, so load-bearing rules can't live only there. |

#### Follow-Up Items → GitHub Issues

- [#68](https://github.com/moduloMoments/VINE/issues/68) — evolve: read CI status (`gh pr checks`) before suggesting a PR (idea, integration)
- [#69](https://github.com/moduloMoments/VINE/issues/69) — Reconcile navigate phase-group verification with evolve's cross-slice check (feedback)
- [#70](https://github.com/moduloMoments/VINE/issues/70) — Make trellis checks runnable as a script for a reproducible stamp (idea, tooling)
- [#71](https://github.com/moduloMoments/VINE/issues/71) — Optional init-upgrade offer to re-level legacy `#### Slice` (h4) specs to h3 (idea)

Captured but not ticketed: Knowledge Boundary rule "same subject, different reader scope" may
deserve a worked example if it confuses contributors (retro item #2).

### Agent Evolution

#### CLAUDE.md / Overlay Updates (applied this commit)

- **CLAUDE.md line 45** — added `inquire` to the PAUSE.md consumer list (it consumes PAUSE.md
  as of Slice 16; STATE.md's authoritative list already includes it). Fixes the one doc-accuracy
  warning from cross-slice verification.
- **shared.md + init.md template** — renamed `## Available Tools & Agents` → `## Tooling Notes`.
  Post-Knowledge-Boundary that heading holds repo-specific *notes*, not an inventory (the body
  already says so); the title was the last misleading remnant. Renamed in both the repo overlay
  and init's generated template to avoid drift.

#### Skill Suggestions

None this cycle. The recurring "run the structural checks mechanically" pattern is better served
as a contributor *script* than a skill — filed as [#70](https://github.com/moduloMoments/VINE/issues/70).

#### VINE Process Observations

- **Dogfooding paid out**: Slice 15 created its own tasks #14–16 at session start before the
  instruction was written, so the slice codified a proven flow (spec, live run, written instruction
  all matched — validation was confirmation, not discovery).
- **Mid-cycle replans worked cleanly**: Slices 19 and 20 were added mid-Phase-5 (artifact-commit
  guidance, between-slice `/clear`) with explicit replan commits — the Milestones/slice machinery
  absorbed renumbering without friction.
- **Empirical finding on native tasks**: `TaskCreate` todos render as a transient line, not a
  watchable panel. #61's real value is the resume-rebuild source + agent-side structure, not a
  dashboard — Slice 21's README states this plainly rather than overselling.
- This cycle added native task tools to navigate/resume/status/inquire and changed several
  command behaviors — **`/vine:optimize` is worth running** to refresh the workflow map in
  shared.md and re-score descriptions against the new capabilities.

### User Evolution

#### Engineer Contributions

The load-bearing calls this cycle were the engineer's, and several steered away from worse paths:

- **Dropping harness plan mode entirely.** The original #62 was "plan mode integration." The
  engineer re-confirmed against the live tool (`ExitPlanMode` takes no content param, is documented
  for code-writing not research) and made the larger call: plan mode is harness-owned, so VINE
  consumes it, never narrates it. This reshaped all of Phase 5 and avoided shipping a command that
  describes behavior it doesn't control.
- **Write-then-review for the inquire gate.** Choosing to review SPEC.md via the rendered file
  meant the gate belongs at *completion*, not before the draft write — matching how design review
  actually works, and shedding a holdover assumption from the dropped plan-mode model.
- **resume's "creates no artifacts" identity + Edit grant.** Reworded resume from "read-only" and
  granted Edit, which surfaced and fixed a latent inconsistency (resume always claimed to backfill
  PROJECT-MAP without the tool to do it). Also the `/clear`-exception insight: resume is a handoff
  into running work, so it shouldn't discard the context it just rebuilt.
- **The ships-vs-contributor file boundary.** The question "does that mean we need to ship STATE?"
  reshaped Slice 19 — load-bearing user rules must live in `commands/vine/*`; STATE.md is the
  contributor map. "Single home" is always scoped by which reader loads the file.

This was confident command of the native-tooling surface, not exploration — hence the profile bump.

#### Profile Updates

- **platform: familiar → confident** (accepted). Note updated to reflect the cycle's decisions and
  to drop "plan mode" (the thing this cycle removed), replaced with "permission modes."
- **Growth log**: skipped (engineer's call — strong cycle, but in-wheelhouse).

#### Claude Memory Suggestions

None new. The cycle strongly *reinforced* the existing "repo-owned decisions" memory (dropping
plan mode because it's harness-owned is a textbook instance) but revealed no new cross-domain
preference. Not manufacturing one.

### Handoff Package

#### PR Description

```markdown
## Summary
Closes the v0.4.0 cycle-1 platform-alignment work: native task tracking (#61) and
mode/gate/workflow hygiene (#62). Builds on PR #63 (#58 rename), #65 (#59 honest
enforcement), #67 (#60 knowledge boundary). VINE now consumes Claude Code's native
task tools and permission modes instead of shadowing them — and explicitly defers
harness plan mode to the harness.

## Changes
**Phase 4 — Native Tasks (#61)**
- STATE.md contracts: slice-status + Remaining-Work contracts, new `Source of Truth vs
  Derived Views` section, SPEC h3 slice-heading fix (trellis Check A/C) (9368236)
- navigate: native live task view of slice progress, every step guarded "when available" (4b55f33)
- resume/status/inquire: task awareness + PAUSE.md consumption; resume reworded
  "creates no artifacts" (9e4b7de)
- Drop contributor-only `/trellis` reminder from shipped optimize output (b48416d)

**Phase 5 — Mode/Gate/Workflow (#62)**
- Gearing↔permission-mode: free climb → auto-accept-edits, walk-through → approve-edits (2921233)
- Track platform-alignment VINE artifacts for consistency with other projects (ff44b4d)
- inquire sign-off gate + clickable artifact review links; verify review link (17b8c5e)
- Artifact-commit guidance for tracked repos (STATE.md `Committing Artifacts` + navigate/evolve) (abb8f4d)
- Between-slice `/clear` suggestion in navigate step 7 (3158608)
- README + CHANGELOG 0.4.0 docs (2119dc9)
- ROADMAP: relabel #62 (plan-mode dropped), milestone state in evolve handoff (8c5d36b, 0cd76b4)

## Decisions Made
- **Harness plan mode dropped from the cycle** — it's harness-owned; VINE consumes it, never
  narrates it. #62 reshaped to gearing↔mode + sign-off gate + artifact-commit guidance + `/clear`.
- **Native task view is a derived view** — rebuilt FROM the journal, never the reverse; flips
  `completed` only after the commit lands.
- **Write-then-review** for inquire's sign-off — the gate is on completion/handoff, not the draft write.
- **Self-sufficient commands** — STATE.md doesn't ship, so load-bearing rules live in the commands;
  STATE.md is the contributor contract.

## Testing
- 38/38 per-slice ACs (committed); cross-slice integration 8/8 contracts (vine-verification agent)
- Backward-compat gate confirmed: task tools absent → navigate/resume/status unchanged
- Hook test suite 11/11; trellis 11/11; cli.js + settings.json valid
- No plan-mode leakage (grep-clean across shipped files)

## Follow-up
#68 (evolve CI-status read), #69 (navigate↔evolve verification reconciliation),
#70 (mechanical trellis script), #71 (h4→h3 init normalization offer).
Post-merge: run `/vine:optimize` to refresh the workflow map.
```

#### Reviewer Notes

- **Backward compatibility is the gate.** Every native-task instruction carries a "when available"
  guard, and navigate has a master skip clause. The single test that matters: with task tools
  absent, navigate/resume/status behave exactly as before. The verification confirmed byte-identical
  behavior — that's the property to spot-check, not the task UX.
- **Why plan mode is gone.** The cycle started as "plan mode integration" and deliberately dropped
  it. This is intentional and load-bearing, not an oversight — `ExitPlanMode` is harness-owned.
  The only surviving "plan mode" mentions are reshape-history notes inside `.vine/projects/`
  artifacts; shipped files are grep-clean.
- **Native tasks are not a dashboard.** Empirically they render as a transient line, not a watchable
  panel. The value is resume-rebuild + agent-side structure; the README says so. Don't expect a
  visible todo panel when reviewing.
- **Tracked-artifact dogfooding.** platform-alignment artifacts became tracked mid-cycle (ff44b4d),
  so from Slice 19 on, slice commits bundle their NAVIGATION/SPEC updates — this PR's own commits
  demonstrate the artifact-commit guidance it adds.

#### Commit Suggestions

16 atomic commits already on `feature/platform-alignment` (one per slice + replans + boundary +
ROADMAP). No squash needed — the slice-per-commit history is the Changes section. evolve adds one
trailing commit for the report + doc fixes (this commit).

#### Multi-PR Summary

| Phase | Slices | Status | PR |
|-------|--------|--------|----|
| Phase 1: The Rename (#58) | 1–5 | ✅ Shipped | [#63](https://github.com/moduloMoments/VINE/pull/63) |
| Phase 2: Honest Enforcement (#59) | 6–10 | ✅ Shipped | [#65](https://github.com/moduloMoments/VINE/pull/65) |
| Phase 3: Knowledge Boundary (#60) | 11–13 | ✅ Shipped | [#67](https://github.com/moduloMoments/VINE/pull/67) |
| Phase 4: Native Tasks (#61) | 14–16 | ✅ Complete | PR 4 (this PR) |
| Phase 5: Mode/Gate/Workflow (#62) | 17–21 | ✅ Complete | PR 4 (this PR) |
