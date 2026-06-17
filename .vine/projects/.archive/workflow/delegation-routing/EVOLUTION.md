# Evolution Report: Delegation-Routing Harness Re-scope (roadmap rewrite)
## Date: 2026-06-11

### Product Evolution

#### Acceptance Criteria Results

Per-slice ACs (23 total) all verified during navigate — trusted, not re-run. Feature-level rollup:

| Acceptance criterion (SPEC) | Evidence (slice / commit) | Result |
|---|---|---|
| Routing loop as organizing thesis; every cycle traces to a loop stage or labeled supporting subsystem | Slice 1 — 64a3021 | Pass |
| Backward-compat hard-gate paragraph verbatim | Slice 1 — 64a3021 (character-identical) | Pass |
| Issues + milestone consistent with the roadmap; no stale `.vine/hooks/` paths, no "plan mode" | Slices 2–3 — d322135, 10ec509; re-confirmed against live GitHub at evolve (#79 open in v0.4.0, #46/#47 open, #48–50 closed, milestone clean) | Pass |
| README "How VINE compares" reflects verified 2026-06 field state | Slice 4 — dda866c | Pass |
| All eight SPEC decisions findable with rationale by an E3 reader | Evolve cross-artifact pass — decisions 1–7 findable in ROADMAP.md (full rationale in SPEC.md, which ships in this repo); decision 8 (single-PR packaging) findable only in SPEC/NAVIGATION | Pass with accepted gap |

**Accepted gap (engineer decision at evolve):** decision 8 stays out of ROADMAP/README — it is packaging metadata, and SPEC.md ships in this repo's tracked artifacts. The "Done so far: cycle 1" old-numbering ambiguity found by the same pass was fixed inline (qualifier added: "in the pre-rewrite numbering").

**Integration verification:** vine-verification agent ran the E3-reader pass, README↔ROADMAP link check (no anchors used; all references resolve), and staleness sweep (clean — the two `.vine/hooks/` mentions in ROADMAP/README are intentional historical/feature-naming references). Hook-script test suite: 23 passed, 0 failed. No command files changed in this feature (`git diff main..HEAD -- commands/` empty), so `/trellis` was not required.

#### Spec Deviations

All annotated in SPEC.md during navigate; none change stakeholder-visible behavior adversely:

1. **Cross-actor state slotted as cycle 3** (spec left ordering open) — it unlocks hybrid-parallel and is shaped by spike question 2; team layer doesn't depend on it. Justified.
2. **Review Preferences stayed profile-side in the #55 split** — preference-class content per the rule-class taxonomy; consistent application of decision 2. Justified.
3. **#48 closed as landed** rather than spec-literal path fix (engineer decision) — keeps the delegation test-case set honest; a cold actor on #48 would find nothing to do. Justified; surviving side-track set is #46/#47.

#### Follow-Up Items

- **Filed [#80](https://github.com/moduloMoments/VINE/issues/80)** (friction): vine:verify emitted non-template CONTEXT.md headings; needs a STATE.md template nudge. Only trellis-running repos catch this today.
- **Filed [#81](https://github.com/moduloMoments/VINE/issues/81)** (idea): extend the trellis-check pattern to scriptable artifact-format checks; doubles as a future headless validation contract surface.
- **Deferred to foundation cycle** (recorded in SPEC's tech-debt section, unchanged): mtime-based journal-check, precedence-sentence inconsistency in 5 of 9 loading blocks, dangling STATE.md pointers in user installs.
- **Owned by #79**: PAUSE.md/ACTIVE/PROFILE.md redesign under E2.

### Agent Evolution

#### CLAUDE.md Suggestions

- **Accepted:** ROADMAP.md line in Repository Structure ("canonical cycle structure; the GitHub milestone is issue-level truth") — future sessions previously had no pointer to the roadmap's authority.
- **Applied as doc-accuracy fix (evolve overlay mandate):** CLAUDE.md claimed `.vine/context/` per-phase overlays and `.vine/projects/` were gitignored; both are tracked (this repo runs E2-shaped). Corrected in CLAUDE.md and shared.md.

#### Skill Suggestions

None proposed. The batch-review-then-fire and verify-before-edit patterns for live issue edits were codified as overlay guidance (below) rather than a skill — they're judgment protocols, not scaffolds.

#### VINE Process Observations

- The freshness pass doubled as a drift detector: three of five "maintenance" issues had silently landed via unrelated work. Verify-against-working-tree before editing is now evolve overlay guidance.
- Free-climb worked cleanly for all four slices of a docs-only feature; the per-slice vine-verification validation carried the quality load, and evolve's single cross-artifact pass (E3-reader check) caught exactly the class of gap per-slice checks can't.
- Meta-friction (dogfooding overlay): verify's template drift (#80) is the cycle's one genuine framework friction point.

#### Context Overlay Updates

- **Accepted:** `.vine/context/evolve.md` gained a "GitHub Issue Edits" section — verify against working tree before drafting, batch-draft public edits for review, "no stale references" = cold-actor bar.

### User Evolution

#### Engineer Contributions

- The eight SPEC decisions were all made in one session and held through implementation — zero spec churn across four slices. Decision 7 (spike before foundation, freshness as side-track) is what made slice 3's #48 discovery cheap instead of disruptive.
- The #48 closure call clarified the acceptance-criteria interpretation standard (cold-actor intent over string letter) — load-bearing for every future freshness or reshaping pass.
- The batch-fire decision on slice 2's seven public edits set the protocol now codified in the evolve overlay.

#### Profile Updates

- Domain `workflow`: stays **confident** — no level change proposed (routine work at the top of an established domain).
- Growth log: skipped (engineer choice).

#### Claude Memory Suggestions

- **Accepted:** "AC intent over letter" — Rob resolves acceptance-criteria letter-vs-intent divergence toward intent; the bar is whether a cold actor would act wrongly. Saved to Claude memory.

### Handoff Package

#### PR Description

```markdown
## Summary

Rewrites ROADMAP.md around scope-delegation routing as the harness's organizing process —
the core loop **scope → route (per overlay-defined policy) → execute (platform mechanics) →
handoff (artifact contract) → evolve (criteria calibration)**, extending the existing
trust-gearing axis past the human-attention boundary (walk-me-through → free-climb →
hybrid-parallel → headless). Syncs issue-level truth to the new roadmap and repositions the
README comparison against the verified June 2026 field.

Carried constraints, not reopened: Path A framing, boundary discipline (VINE owns decision
criteria/contracts/handoff artifacts; the platform owns execution mechanics; VINE never
implements an agent runner), composition-not-synchronization, backward compatibility as a
hard gate (paragraph carried character-identical).

## Changes

- `64a3021` roadmap-rewrite — ROADMAP.md restructured around the routing loop: cycle 0
  coordination spike (six questions) → cycle 1 foundation (rule-class precedence split, #54
  reshaped as routing-layer eligibility gate, routing policy as overlay content) → knowledge →
  cross-actor state → team layer → plugin; #46–50 as pair-mode side-track.
- `d322135` issue-reshaping — #54/#53/#57/#55/#52 reshaped and retitled to match; new #79
  filed (cross-actor live execution state); milestone description de-staled; #79 backfilled
  into the cycle-3 row.
- `10ec509` issue-freshness — #46/#47 freshened to cold-executable; #48/#49/#50 verified as
  already landed and closed; roadmap side-track row synced.
- `dda866c` readme-comparison — "How VINE compares" rewritten against the verified field
  (Spec-Kit, Kiro, BMAD v6, Augment Cosmos, agent-context; AGENTS.md/AAIF as substrate;
  above-repo layering claimed as the gap).
- `654f734` navigate-close — completion gate, remaining work, artifact-format compliance.
- evolve commit — evolution report, follow-up issues #80/#81 filed, CLAUDE.md/overlay
  accuracy fixes, roadmap numbering qualifier.

## Decisions Made

Eight decisions, all findable with rationale in the rewritten artifacts (the E3-reader test
was an explicit acceptance criterion). Highlights: routing ownership = delegation policy as
overlay content with recommend-and-ratify default (activates only after the precedence
split); overlay precedence = rule-class split (preference→personal-wins, policy→company-wins)
with a written-in fallback; route journaling in PROJECT-MAP + NAVIGATION fields, no new
artifact; personal layer rides the CLAUDE.local convention; team-overlay propagation =
plugin update + init recompose.

## Testing

Docs-and-issues feature — no command files changed. Per-slice validation via
vine-verification (backward-compat paragraph character-identical; live issue bodies
re-fetched post-edit; README tone/accuracy pass). Evolve integration pass: E3-reader
decision traceability (7/8 in public docs, decision 8 = packaging metadata in shipped
SPEC), live GitHub state re-confirmed, hook-script suite 23/23 green.

## Follow-up

- #80 (friction): vine:verify template-heading drift.
- #81 (idea): scriptable artifact-format checks.
- Cycle 0 spike and cycle 1 foundation are unblocked by this rewrite; #46/#47 are
  cold-executable delegation test cases gated on the foundation's #54 work.
```

#### Reviewer Notes

- **ROADMAP.md is the load-bearing document** — future sessions read it as ground truth, and errors propagate into every subsequent cycle's verify phase. Review it hardest.
- The issue edits (slices 2–3) are already live — the PR reviews the in-repo record of them, not the edits themselves. Each reshaped body carries a "Reshaped/Updated 2026-06-11 by the delegation-routing re-scope" Source stamp for the audit trail.
- The verification-boundary feature (#69) executes in its own session; #54's new body was deliberately written against the contract, not the file layout, so it reads correctly whether or not #69 has landed.
- "As of June 2026" date-qualifies the entire README product list — one line to bump on the next freshness pass, no per-claim qualifiers.
- The spike (cycle 0) may invalidate the rule-class split; the fallback (single total ordering + policy-class carve-outs) is written into the roadmap so that finding reorders cycle 1's content rather than forcing a roadmap revision.

#### Commit Suggestions

Already structured — one commit per slice plus navigate-close and the evolve commit; no restructuring needed.

#### Multi-PR Summary

Not applicable — single-PR feature (decision 8), no Milestones table.
