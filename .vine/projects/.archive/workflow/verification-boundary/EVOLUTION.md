# Evolution Report: Verification Boundary (navigate ↔ evolve reconciliation)
## Date: 2026-06-11

### Product Evolution

#### Acceptance Criteria Results

| Acceptance criterion (SPEC) | Evidence (slice / commit) |
|---|---|
| Base checklist defined in exactly one shipped surface; neither command restates | Slices 1–3 — 151cdfa, a027582, 7ec6674 |
| Agent feature mode takes caller-specified scope; full-feature adds cross-cutting checks | Slice 1 — 151cdfa |
| Navigate step 8 delegates, preserving fix-in-session + AskUserQuestion coverage triage | Slice 2 — a027582 |
| Evolve references the mode at full-feature scope; evolve-only scope unchanged + enumerated in contract note | Slice 3 — 7ec6674; Slice 4 — 67fd1a6 |
| Both stale cross-ref blockquotes gone; replacements point at the contract note | Slices 2–3 — a027582, 7ec6674 |
| STATE.md note matches the #66 contract-note family shape / marker convention | Slice 4 — 67fd1a6 |
| Agent discovery list includes `.vine/context/evolve.md` | Slice 1 — 151cdfa |
| Anchor check contributor-side only; create-vine shipped set unchanged | Slice 5 — 230ec5c (verified against bin/cli.js SCAFFOLD_SCRIPTS + package.json files) |
| `/trellis` and `trellis-check.sh` green on the full change | Slice 5 + full-feature verification + post-rebase re-run (11/11, 8 anchor pairs, exit 0) |

(Hashes are post-rebase; pre-rebase equivalents are recorded per-slice in NAVIGATION.md.)

All nine criteria accounted — none unaccounted. Full-feature integration verification
(vine-verification agent, full-feature scope — dogfooding the Slice 3 delegation) passed:
cross-references resolve in both directions across all six files, the STATE.md note's claims
match what the agent and commands actually say, and the trellis Check 10 table is
character-identical to the script's PAIRS list.

#### Rebase Onto Post-#82–#85 Main

Main moved during the cycle (delegation-routing feature, roadmap re-scope, and #84's
script-owned trellis stamp). The branch was rebased onto origin/main before handoff:

- Slices 1–4 replayed clean. Slice 5 conflicted in trellis.md Step 8 — #84 rewrote it so
  the script, not the session, writes `.vine/.trellis-ok`. Resolved in #84's favor: Step 8
  now says the script's checks include the Check 10 anchor pairs and a failed pair flips
  the script-written stamp. `trellis-check.sh` needed no changes — it already owned the
  stamp and already folded the anchor result into it, so #84 and this feature compose
  cleanly (and #84's motivating incident is the same classifier block recorded in this
  repo's session memory).
- #83's navigate.md template-heading nudge and #82/#85's README/CLAUDE.md/ROADMAP changes
  didn't overlap the feature's edits.
- Main now tracks `.vine/projects/` artifacts (delegation-routing's are committed) and
  CLAUDE.md says "tracked; PAUSE.md gitignored" — so this feature's artifacts are committed
  with the evolve commit, per the artifact-tracking rule.
- Post-rebase re-run: trellis-check.sh green (11/11 commands, 8 anchor pairs).

#### Spec Deviations

None. All five slices recorded "Deviations from spec: None"; no SPEC.md annotations exist or
were needed.

#### Issues Found in Evolve Verification (and resolutions)

- **README.md:56 mechanism drift** — "runs a lightweight verification pass" predated the
  delegation. Fixed in evolve (now "delegates a lightweight verification pass to its
  verification agent"). Engineer-approved.
- **Empty-PAIRS silent pass** — clearing the anchor list would have printed "0 pairs" and
  passed. Hardened in evolve: zero pairs now counts as a failure. Engineer-approved.
- **STATE.md contributor-tooling sentence (post-rebase ride-along)** — #84's new prose
  describes trellis-check.sh as running "trellis's command checks"; updated to mention the
  anchor check so the description matches the script.
- **Terminology note (no action)** — callers say "feature verification mode"; the agent
  heading is "Feature Verification (cross-change)". The mapping is unambiguous and
  anchor-checked; left as-is by design.

#### Follow-Up Items

None requiring tickets. [#69](https://github.com/moduloMoments/VINE/issues/69) closes with
the PR. Composition note for [#54](https://github.com/moduloMoments/VINE/issues/54) (cycle 4,
machine-readable validation contract): it now wires into one checklist surface
(`agents/vine-verification.md`) instead of three — note this when #54 starts; no scope change.

Known accepted debt: the anchor pair list is maintained in two places (trellis.md Check 10
table, trellis-check.sh PAIRS heredoc) with keep-identical comments; a future anchor value
containing `|` would need encoding care (IFS-split in the script).

### Agent Evolution

#### CLAUDE.md Suggestions

- Pointer to the verification-tier contract note — **rejected** (doc-growth guardrail:
  STATE.md's note already keeps contributors in sync; CLAUDE.md already routes artifact rules
  to STATE.md).

#### Skill Suggestions

None — the anchor check (trellis Check 10) is itself the automation this cycle produced.

#### VINE Process Observations

- **Meta-friction (dogfooding)**: evolve's skill expansion loaded the pre-change command text
  while the branch carried the new version — the session followed the landed version, which
  worked, but "command edited mid-cycle runs stale until merged/symlinked" is a real
  dogfooding wrinkle worth knowing about.
- **Parallel-main drift**: a sibling cycle (delegation-routing) merged to main mid-cycle and
  #84 rewrote a section this feature also edited. The rebase-before-handoff step caught it;
  the conflict resolution was semantic (adopt the script-owned model), not mechanical. For
  a solo-maintainer repo running concurrent VINE cycles, "fetch + read what merged" belongs
  in the handoff routine.
- The free-climb × 5 cadence with per-slice agent validation and trellis-before-commit held
  up well; the only stall all cycle was an infrastructure outage, not process.
- Evolve's full-feature verification earned its keep: it caught two real gaps (README drift,
  empty-PAIRS guard) that per-slice verification structurally could not see.
- This cycle changed two command files; running `/vine:optimize` would refresh the workflow
  map and re-score descriptions (suggested, not yet run).

#### Context Overlay Update Suggestions

None — existing overlays (navigate's Pre-Evolve Check, evolve's doc accuracy check) already
cover what this cycle exercised; the doc accuracy check is what surfaced the README drift.

### User Evolution

#### Engineer Contributions

The load-bearing decisions were design-phase calls that held up unchanged through
implementation: choosing the agent file as the single source *because it ships* (the
constraint that killed the STATE.md-as-checklist option), conditioning the mechanical teeth
on staying contributor-side, and spending a full cycle on what could have been patched prose
— which is why the boundary is now documented and enforced rather than re-drifting. The
"rebase and understand what merged" call before handoff caught #84's overlap with Slice 5.
Implementation itself was routine free-climb execution in a confident domain; no corrections
were needed.

#### Profile Updates

- Domain level: **kept at confident** (workflow) — engineer's choice; Notes refreshed to
  record the verification-boundary design.
- Growth log entry: skipped (routine cycle in a confident domain).

#### Claude Memory Suggestions

None proposed — no new general preferences surfaced this cycle; existing memories
(trellis-before-commit, doc-growth guardrail, PR conciseness) were applied, not discovered.
One existing memory is now stale and should be updated rather than added to: the
"trellis stamp classifier block" note — #84 made the stamp script-generated, which is the
exact fix that memory was waiting on.

### Handoff Package

#### PR Description

```markdown
## What

Makes `agents/vine-verification.md` the single source for VINE's cross-change verification
checklist. The agent's feature mode gains a caller-specified scope — phase-group (navigate)
runs the base checks; full-feature (evolve) adds cross-cutting checks. Navigate step 8 and
evolve's integration check now delegate by mode + scope instead of restating the checks, a
new STATE.md contract note documents the tier boundary, and trellis gains a cross-reference
anchor check (Check 10) that fails when any of the wiring drifts.

## Why

The same checklist was maintained by hand in three places and had already drifted (navigate
cited an a–d structure evolve never had; evolve pointed at a renumbered "step 9"). One
shipped surface + a documented boundary + a mechanical check replaces prose cross-references
that asked for sync but couldn't enforce it. The asymmetry between the tiers is intentional
and now stated in `references/STATE.md`.

Composes with #84 (script-owned trellis stamp): the anchor check runs inside
trellis-check.sh, so anchor failures flip the script-written stamp.

Closes #69

## How to test

- `sh .vine/scripts/trellis-check.sh` — expect 11/11 commands green and "Cross-reference
  anchors resolve (8 pairs)"
- Rename any anchored heading (e.g. `**Cross-cutting checks**` in the agent file) and re-run
  — expect exit 1 and a `status: fail` stamp naming the missing anchor
- Read navigate.md step 8 and evolve.md's Cross-Slice Integration Check — neither should
  enumerate the base checks

## Checklist

- [x] I've tested this in an actual VINE cycle (this PR was built with VINE; evolve's
      verification ran the new delegation at full-feature scope)
- [x] Changes are focused on a single concern
- [x] Any new behavior is documented in the README or command file
```

#### Reviewer Notes

- The coverage asymmetry (evolve heavier than navigate) is **intentional** — don't read the
  thinner navigate step 8 as lost coverage; the checks moved to the agent definition and the
  boundary is documented in STATE.md's verification-tier contract note.
- The anchor pair list exists twice on purpose (trellis.md table for humans,
  trellis-check.sh heredoc for the machine) with keep-identical comments. Renaming an
  anchored section is supposed to fail the check — updating the pair list is the sync act.
- Nothing here changes what ships: bin/cli.js's SCAFFOLD_SCRIPTS allowlist is untouched;
  `.claude/commands/` and `.vine/scripts/trellis-check.sh` are contributor-only. The agent
  file does ship — that's why it's the checklist's home.
- Rebased onto post-#84 main; the only conflict was trellis.md Step 8, resolved in favor of
  #84's script-owned stamp (the anchor check already lived in the script, so the models
  compose).
- #54 (cycle 4) will wire its machine-readable validation contract into this single surface;
  this PR deliberately stays at named-check level to avoid pre-empting #54's schema.

#### Commit Suggestions

Already structured — five slice commits (151cdfa, a027582, 7ec6674, 67fd1a6, 230ec5c) plus
one evolve commit (README fix, PAIRS guard, STATE.md tooling sentence, feature artifacts).
Merge as-is or squash; the slice commits tell the story either way.

#### Multi-PR Summary

Not applicable — single-PR feature by design (PROJECT-MAP has no Milestones table).
