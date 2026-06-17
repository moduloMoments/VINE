# Evolution Report: Routing Foundation (v0.4.0 Cycle 1)
## Date: 2026-06-16

### Product Evolution

#### Acceptance Criteria Results

Full-feature verification (evolve tier) delegated to `vine-verification` at full-feature
scope. **All 10 cycle-level acceptance criteria MET.** `sh .vine/scripts/trellis-check.sh`
passes clean (11/11 commands + 8/8 cross-reference anchors). Per-slice and phase-group tiers
all passed during navigate (17 slices + 2 in-phase boundary fixes + 2 phase-group runs, every
one `pass`).

| Cycle AC (SPEC) | Evidence (slice / commit) |
|---|---|
| 1. Precedence resolves at load time | Slice 1 `0c81247` + Slice 2 `bc5d5ca` + Phase-1 boundary `53b0200` (init template) |
| 2. Validation contract exists + consumed | Slice 3 `ea8e30b` + Slice 4 `b47e71c` + Slice 5 `3a26f48` |
| 3. Eligibility gate at navigate-head | Slice 7 `92c13ad` |
| 4. ROUTE.md complete record | Slice 6 `172867b` + Slice 9 `42b576a` (PROJECT-MAP link) |
| 5. Headless contract holds | Slice 11 `99e19fb` + Slice 12 `faa4b4e` |
| 6. Decision Delegation policy | Slice 10 `bc79152` |
| 7. Journal schema carries route data | Slice 13 `a7f8cf3` + Phase-3 boundary `7ad1521` (lockstep) |
| 8. Reviewer reads gate record | Slice 14 `9baacaf` |
| 9. Distribution surfaces updated | Slice 15 `f6df658` + Slice 16 `6983c3f` + Slice 17 `6dd5456` |
| 10. Backward compatibility | Cross-cutting — verified at Phase-1, Phase-3, Phase-4 boundaries |

No unaccounted criteria — every cycle-level AC maps to a slice with a recorded commit.

**Cross-cutting integration (full-feature tier only):** lockstep between `references/STATE.md`
templates and the `navigate.md` writer confirmed (the Phase-3 `Decisions made during
implementation` label mismatch stayed fixed); controlled Route vocabulary
(`interactive | headless | headless-reentry`) consistent across all three authoritative
surfaces; all new internal anchors (`#reference-legibility`, `#source-of-truth-vs-derived-views`,
`#committing-artifacts`) resolve; `.gitignore` `.vine/context/*.local.md` pattern correct; no
dangling ROUTE.md references on swept surfaces (CLAUDE.md chain, README table, shared.md
checklist).

**One benign warning (verified directly, no defect):** `navigate.md:233` uses
`<!-- decision-class: ... -->` as *explanatory prose* (instructing the actor to read each
site's tag), not a real site tag. 31 real site tags confirmed across 7 commands. Recorded as a
forward-note for an eventual mechanical tag-parser (Follow-Up).

#### Spec Deviations

No behavioral deviations. Three descriptive **file-hint** corrections, each reasoned to the
right target and explicitly flagged in NAVIGATION.md as descriptive-only (no SPEC annotation
needed):

| Slice | SPEC hint | Reality / action |
|---|---|---|
| 8 | "alongside the existing gearing preview in inquire" | The gearing preview lives in `verify.md`, not inquire. Modeled the route preview on verify's pattern, placed in inquire's completion block per the AC. |
| 15 | seam "after `## Context Overlays`" or "under `## How VINE compares`" | Placed after `## State Artifacts` instead — strictly better legibility (no forward references; the section leans on ROUTE.md / journal / reviewer role introduced by that point). |
| 17 | `commands/vine/verify.md (count reference)` | The count reference lives in `.vine/context/verify.md`; `commands/vine/verify.md` carries none. Command count is 11, unchanged this cycle, so no count edit was needed anywhere. |

Root cause is benign: the verify map predated main's #92 (line shifts), so a long multi-PR
cycle accumulates minor hint drift. Navigate correctly treats file-hints as descriptive
candidates, not mandates.

#### Follow-Up Items

- **Close implemented issues (actioned):** `#54` (validation + eligibility gate), `#53`
  (headless autonomy), `#90` (journal schema) are fully delivered — set to close via the Phase 4
  PR (`Closes #53, #54, #90`).
- **#55 commented (actioned):** the routing-policy half (Decision Delegation) landed this cycle;
  the profile-rework half (strip delegation/risk from PROFILE.md, keep depth + growth) remains
  open — this cycle delivered the precondition, not the rework.
- **New issue filed (actioned): [#99](https://github.com/moduloMoments/VINE/issues/99)** —
  `journal-check.sh` observability: emit a visible signal on fire-and-pass so it is
  distinguishable from didn't-fire. Hook-scoping debt from the cycle-0 spike, orthogonal to
  routing. Distinct from #90 (schema, implemented).
- **Deferred / already tracked:** `#51` (`.vine/knowledge/<domain>.md`, cycle 3); federated
  knowledge sync (2027-shaped); the decision-class prose-occurrence note (very low priority —
  only matters if a mechanical tag-parser is ever built).

#### Multi-PR Status

| Phase | Slices | PR | Status |
|-------|--------|----|--------|
| Phase 1: Precedence & Validation Foundation | 1-5 | [#94](https://github.com/moduloMoments/VINE/pull/94) | Merged (clean, no review comments, no CI) |
| Phase 2: Eligibility Gate & Route Record | 6-9 | [#97](https://github.com/moduloMoments/VINE/pull/97) | Merged (clean) |
| Phase 3: Headless Contract & Journaling | 10-13 | [#98](https://github.com/moduloMoments/VINE/pull/98) | Merged (clean) |
| Phase 4: Docs, Reviewer & Trellis | 14-17 | — | Ready to open (6 commits ahead of origin/main) |

This repo has no CI (pure markdown); the validation contract is `trellis-check.sh`, which
passed green at every slice and at the full-feature tier.

### Agent Evolution

#### CLAUDE.md Suggestions

- **Unnumbered-section command-authoring convention** — **accepted**. Added under Command
  Authoring Conventions: prefer an unnumbered `###` section over renumbering existing steps,
  because renumbering ripples through every `step N` cross-reference (the drift `/trellis`
  Check 10 catches), and an unnumbered section signals "runs once / out of the numbered flow."
  Reinforced twice this cycle (Slices 7 and 12, both navigate-head additions).

#### Skill Suggestions

None. The one repeatable workflow this cycle produced — the multi-surface sweep when adding a
state artifact — was already codified as the **State Artifact Addition Checklist** in
`.vine/context/shared.md` (Slice 17). For a pure-markdown framework, in-repo checklists are the
right unit, not skills.

#### VINE Process Observations

- **Phase-group boundary verification earned its keep twice.** It caught the init-template
  precedence gap (Phase 1) and a years-old `Decisions made` field-label drift (Phase 3) that
  was invisible until the #90 schema contract referenced the field by name. Strong validation
  of the verification-tier design (per-slice → phase-group → full-feature).
- **Multi-PR tracking held the thread cleanly.** 4 phases → 4 PRs, clean rebases (`--onto
  origin/main` to drop merged-phase noise), PROJECT-MAP Milestones table tracked across
  sessions.
- **SPEC file-hints drift over a long cycle.** Three descriptive-hint imprecisions (Slices 8,
  15, 17) because main moved under the cycle. No fix — navigate correctly treats hints as
  candidates — but a signal that file-hints in a multi-PR SPEC age faster than the ACs do.
- **Meta-friction (dogfooding):** editing `navigate.md` while `navigate.md` guided the work was
  handled by the unnumbered-section choice (keeps navigate's own trellis green while extending
  it). Worked cleanly; no confusion.

#### Context Overlay Updates

None proposed. Slice 17 already swept the overlay surfaces it touched (State Artifact Addition
Checklist in shared.md); no genuine new overlay content surfaced this cycle.

### User Evolution

#### Engineer Contributions

- **Ran the full 17-slice / 4-PR cycle in free-climb gearing**, set up front each phase — heavy,
  sustained delegation that is itself a confident-domain signal.
- **The load-bearing steering call was the Phase-1 boundary "fix in-phase" decision:** rather
  than carry a known-graceful-but-incoherent init-template precedence gap across the cycle's
  other PRs, close the coherence gap the phase group itself created. That set the precedent the
  Phase-3 boundary lockstep fix then followed — a reusable judgment about *when* a discovered
  gap is in-scope (the phase created it) versus spin-out work.

This was routine work in Rob's comfort zone; no manufactured growth narrative.

#### Profile Updates

- **`workflow` domain — kept `confident` (the ceiling), Notes + Last Updated refreshed** to
  2026-06-16, recording the routing-foundation cycle and the in-phase-fix precedent. No level
  change warranted.
- **Growth log — skipped** (engineer's call; routine confident-domain work).

#### Claude Memory Suggestions

None persisted. The in-phase-fix pattern was offered and declined for memory — it's
situational and complements the existing spawn-scoped-tasks preference (out-of-scope → spawn;
in-scope-but-discovered → fix now) without needing its own durable entry.

### Handoff Package

#### PR Description

```markdown
## Summary
Final phase of the routing-foundation cycle (v0.4.0 Cycle 1): make the new routing surfaces
discoverable, reviewable, and validated. Phases 1–3 built the precedence model, the validation
contract, the navigate-head eligibility gate + ROUTE.md record, the headless autonomy contract,
and the journal schema. This phase wires those into the docs, the reviewer's orientation, and
trellis.

## Changes
- review.md: a "gate record" step in the reviewer's orientation order — read ROUTE.md (verdict,
  allowlist, constraints, validation baseline, stamp) before the journal/commits, so execution
  is checked against its authorization basis. Graceful when ROUTE.md is absent.
- README: an "Agents running VINE" section — the routing gate, the gate record, the reviewer
  role, and the agents/ directory, one screen, links for depth.
- trellis: artifact-tier checks (session-judged, never gate the command-commit stamp) for
  ROUTE.md format (Checks A + E), optional journal route fields (Check D), and the Validation
  block shape (Check F). All skip gracefully when their surface is absent.
- Cross-reference sweep: ROUTE.md added to CLAUDE.md's artifact chain and README's State
  Artifacts table; a new State Artifact Addition Checklist in shared.md.

## Decisions Made
- New checks land in trellis's already-unstamped artifact tier, so "don't gate the stamp" needs
  no new mechanism — it falls out of placement.
- ROUTE.md goes in *enumerating* surfaces (artifact chain, tables) but not *narrative*
  "four phases" prose — it's navigate-internal, not a fifth phase.

## Testing
- sh .vine/scripts/trellis-check.sh → 11/11 commands + 8/8 anchors, clean.
- Full-feature verification (evolve tier): all 10 cycle-level ACs MET; backward compatibility
  holds (ROUTE.md / journal route fields / Validation block all degrade to interactive defaults
  when absent).

## Follow-up
Closes #53, #54, #90. The routing-policy half of #55 landed (profile-rework half remains).
New: #99 (journal-check observability).
```

#### Reviewer Notes

- **This is the cycle's documentation/validation tail, not new mechanism** — Phases 1–3 (already
  merged as #94/#97/#98) built the routing machinery; Phase 4 only surfaces it. The diff is docs,
  reviewer orientation, and trellis checks.
- **Backward compatibility is the load-bearing invariant** (AC 10). Every new surface is optional
  with graceful absence — confirm a `.vine/` setup with no ROUTE.md, no journal route fields, and
  no `## Validation` block still works unchanged. The interactive path is never gated; the gate
  only ever *adds* the headless option.
- **The new trellis checks are session-judged and must not gate `.vine/.trellis-ok`** — they live
  in Steps 5–7 (the artifact tier), which `trellis-check.sh` never runs. The script is unchanged,
  by design.
- **Tribal-knowledge context** (from CONTEXT.md): the spike's "map, not mechanism" finding means
  the headless contract is a decision protocol + handoff format, both mechanism-agnostic — it
  survives whatever launches the actor. Don't expect VINE to store actor permissions; those are
  provisioning-time human authority, outside the artifact chain.

#### Commit Suggestions

Phase 4 is 6 commits on `feature/routing-foundation` ahead of `origin/main` (919aa56 Phase-3
tracker + 9baacaf, f6df658, 6983c3f, 6dd5456 slice commits + ac472aa tracker/boundary). They tell
the slice story cleanly; open the PR against `origin/main` as-is (no squash needed pre-PR — GitHub
squash-merge on merge, matching the prior three phases).
