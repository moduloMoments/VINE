# Evolution Report: Cross-actor state — the role-recipe reframe
## Date: 2026-06-18

> **Shipping status:** The implementation already merged to `main` before evolve ran, across three
> PRs landed in parallel sessions — [#113](https://github.com/moduloMoments/VINE/pull/113) (Phase 1,
> additive agent roles), [#114](https://github.com/moduloMoments/VINE/pull/114) (a vine-reviewer
> validation-discovery ladder), and [#115](https://github.com/moduloMoments/VINE/pull/115) (Phase 2,
> ROUTE.md retirement + navigate interactive-only). This report verifies the merged result and lands
> the evolve closeout (this report, the durable-decision ADRs, the PROJECT-MAP completion) on a fresh
> branch off `origin/main`.

### Product Evolution

#### Acceptance Criteria Results

All ten feature-level criteria from SPEC.md, mapped to evidence. Per-slice ACs were validated and
committed by navigate; this is the cycle-contract rollup.

| Acceptance criterion (SPEC) | Result | Evidence |
|---|---|---|
| 1. Both agent files exist, valid frontmatter, scoped descriptions | ✅ | S1 `45b8a33` + S2 `27f50d4`; frontmatter verified |
| 2. Cold `vine-coder` can orient→implement→commit→PR (dogfood) | ◑ | S1 `45b8a33` — recipe complete; reviewer-side dogfooded live, coder-side validated by structural inspection (no implementation ticket run) |
| 3. Cold `vine-reviewer` produces review without ROUTE (dogfood) | ✅ | S2 `27f50d4`; **empirically dogfooded** against #115 — Approve verdict, short fully-recoverable Missing-context log |
| 4. `vine-reviewer` excludes Edit/Write; `vine-coder` least-privilege | ✅ | S1+S2; `tools` lines verified |
| 5. Neither relies on `AskUserQuestion` | ✅ | S1+S2; `human-required` resolves to stop-and-surface |
| 6. `grep ROUTE` clean except retirement note; chain CONTEXT→SPEC→NAV→EVOL | ✅ | S5 `4cb1921` + S7 `45d873a`; direct grep confirmed |
| 7. `/trellis` passes after every slice | ✅ | every slice logged 11/11 + anchors; re-run green |
| 8. No autonomous `decided by: claude` | ✅ | S4 `cb59d39`; grep clean in product surfaces |
| 9. navigate no headless prose; PROFILE.md + `.vine/ACTIVE` unchanged | ✅ | S6 `308b71d`; navigate `route|headless`-clean |
| 10. Repo-wide sweep; ROADMAP cycle 3 reframe | ✅ | S7 `45d873a` + ROADMAP vision align (squashed into #115) |

No criterion is unaccounted. AC2 is the only partial: the coder-side cold-spawn was not exercised
against a live implementation ticket (out of scope for a closeout), but the recipe is structurally
complete and the reviewer half of the round-trip was validated live.

**Cross-slice integration check** (vine-verification agent, full-feature scope, + direct re-checks):
all green. ROUTE clean (retirement/migration notes only in STATE.md + shared.md's checklist example),
0 `decision-class` tags in live commands, no autonomous `decided by: claude`, `step N` cross-references
resolve, the Decision Delegation policy reads coherently, the kept `**Route**`/`**Actor**` fields are
consistently described across STATE.md / navigate.md / vine-coder.md. trellis green (sole warning: the
known non-blocking legacy `.vine/hooks/` references in init.md).

**Cold-review dogfood** (vine-reviewer against #115): **Approve.** It validated AC3 empirically — the
ported recipe was self-sufficient for a cold review without ROUTE.md; every gap in its Missing-context
log was recoverable from durable state. It independently flagged that the ROUTE-retirement ADR was owed
to evolve (now discharged below) and that the journal slightly *over-claims* one residual `headless`
line that S7 actually removed (reality stricter than the journal — not a defect).

**Prior-PR CI/review status:** #113, #114, #115 all merged. No CI checks configured on the branch
(pure-markdown repo). No unresolved review comments on #113.

#### Spec Deviations

All engineer-directed or in-spirit; none change feature behavior in a way stakeholders need flagged.

- **S6 — repo-wide decision-class sweep (engineer-directed).** Spec scoped the sweep to navigate;
  the engineer took it across all 8 commands (36 tags). Rationale: `vine-coder` implements from the
  SPEC/ticket and never executes command files, so *every* per-site tag is vestigial. Correct call.
- **S7 — KEEP the `**Route**`/`**Actor**` journal fields (engineer's conscious call).** The SPEC
  required this be decided explicitly rather than swept out by the ROUTE grep. Kept, with the
  `**Actor**` template broadened to multi-human attribution. Captured as a durable ADR.
- **S7 — broader ROADMAP v0.4.0 vision narrative left for the engineer's own pass** (medium
  confidence). The SPEC scoped this slice to the cycle-3 row. A post-PR commit (`ff6ab65`) then
  aligned the forward-looking gearing-axis vocabulary; frozen history left untouched.
- **S4 / S5 — minor in-spirit STATE.md line additions** to keep the PAUSE-lifecycle and ROUTE
  retirement contracts from drifting against the commands.

#### Follow-Up Items

- **Journal cross-pointer (minor, from the dogfood).** The reviewer had to open `vine-coder.md` to
  confirm the KEEP'd fields have a live writer; a one-line pointer in the Slice 7 journal would have
  saved the lookup. NAVIGATION.md is already merged — not worth re-touching; recorded as a learning.
- **`vine-coder` dogfood tool (deferred).** A contributor tool mirroring `pr-review` that cold-spawns
  `vine-coder` on a throwaway ticket would close the coder-side AC2 dogfood gap. Conditional/post-cycle
  (engineer declined to file this cycle).
- **Carried from SPEC (unchanged):** PAUSE/`.vine/ACTIVE` deletion-site consolidation (decoupled from
  the now-dissolved cross-actor framing — backlog); journal-check.sh value/rework (fold into
  [#99](https://github.com/moduloMoments/VINE/issues/99)); confirm the PROFILE.md boundary holds when
  [#55](https://github.com/moduloMoments/VINE/issues/55) starts (this cycle left it structurally clean).

### Agent Evolution

#### CLAUDE.md Suggestions

None. CLAUDE.md already carries the agents inventory and the ROUTE leg was cleanly dropped from the
State Artifact Chain line in S5 (grep-confirmed). Manufacturing additions would violate the doc-growth
guardrail.

#### Skill Suggestions

None new. The `pr-review` contributor tool already dogfoods `vine-reviewer`; the symmetric `vine-coder`
dogfood tool is captured as a deferred follow-up rather than a skill this cycle.

#### Context Overlay Updates (applied)

- **`.vine/context/evolve.md` — new `## Multi-PR Features` section.** For features with a Milestones
  table, verify whether phase-group PRs already merged (`gh pr list --state merged` / compare to
  `origin/main`) before assuming evolve must open one. Grounded directly in this cycle's friction:
  PROJECT-MAP listed Phase 2's PR as `—` while #115 had already merged in a parallel session.

#### VINE Process Observations

- **Multi-PR staleness was the meta-friction.** The single most useful signal this cycle: a tracker
  (PROJECT-MAP Milestones) drifts from `main` when PRs land in parallel sessions. Evolve nearly tried
  to open a PR that had already shipped, and the feature branch had gone stale (missing #114's ladder),
  so a naive PR from it would have reverted merged work. The evolve.md overlay note above is the fix.
- **The dogfood paid off.** Running `vine-reviewer` cold against a real merged PR — rather than
  trusting structural inspection alone — both satisfied the SPEC's named sign-off gate and surfaced a
  real journal discrepancy (F1) and the genuine self-sufficiency signal (AC3) that inspection couldn't.
- **`/vine:optimize` not indicated.** This cycle removed content (tags, headless prose) and the
  workflow map was already updated in S3; no skill/description changes warrant a re-score.

### User Evolution

#### Engineer Contributions

- **The reframe itself was load-bearing judgment.** Taking #79's "build one cross-actor live state
  model" apart to find the smaller, sharper feature underneath (a dedicated agent role bounded by a
  ticket, gated by a PR) is the decision the whole cycle pivots on — and it *dissolved* most of the
  originally-scoped machinery rather than building it.
- **The repo-wide decision-class sweep call.** Recognizing that `vine-coder` never executes command
  files — so every per-site tag is vestigial, not just navigate's — turned a navigate-scoped edit into
  a clean repo-wide retirement.
- **The `**Actor**`-field generalization.** Reframing it from "human-vs-bot" to "whoever produced this
  slice" is what makes the kept field earn its place on a shared (E2) repo. That insight is recorded as
  a durable ADR.
- **Model tier by stakes.** Choosing opus for both agent roles against the sonnet house default — the
  reviewer-leash must be at least as strong as what it checks — is a heuristic that now generalizes.

#### Profile Updates

- **workflow — kept `confident`** (already the top tier); refreshed Last Updated → 2026-06-18 and
  broadened the note to cover the role-recipe reframe and the agent-role recipes. No growth-log entry
  (deep work, but squarely in the engineer's confident domain).

#### Claude Memory Suggestions

- **Refined the parallel-PR-check memory** to extend its trigger to evolve/handoff time — the staleness
  here surfaced during evolve, not just before building. No new general-preference memory manufactured.

#### Durable Decisions Recorded (`.vine/knowledge/workflow/`)

- **`2026-06-18-autonomous-work-is-an-agent-role-not-headless-command-impersonation.md`** — the central
  reframe. **Supersedes** `2026-06-16-route-md-headless-eligibility-gate.md` (whose Status was flipped
  to Superseded — the sanctioned bidirectional link). Discharges the supersession owed from S5.
- **`2026-06-18-keep-route-actor-journal-fields.md`** — why the `**Route**`/`**Actor**` fields survive
  a "retire ROUTE / no headless command" cycle.

### Handoff Package

#### PR Description (evolve closeout)

```markdown
## Summary
Closes out the cross-actor-state cycle. The implementation already shipped (#113/#114/#115); this
lands the evolution report, the durable-decision records, and the project-tracker completion.

## Changes
- Adds EVOLUTION.md for the feature (verification rollup, deviations, follow-ups, handoff).
- Records two durable-decision ADRs under .vine/knowledge/workflow/: the role-recipe reframe (which
  supersedes the now-retired ROUTE.md eligibility-gate record) and the Route/Actor field KEEP rationale.
- Flips the superseded ROUTE-gate record's Status line (the one sanctioned edit to an accepted record).
- Adds a Multi-PR section to the evolve context overlay: verify phase-group PRs against main before
  assuming evolve must open one.
- Marks the evolve phase complete in PROJECT-MAP.

## Decisions Made
- Landed on a fresh branch off origin/main rather than the stale feature branch — the feature branch
  predates #114 and a PR from it would have reverted merged work.

## Testing
1. `sh .vine/scripts/trellis-check.sh` → 11/11 commands pass, anchors resolve.
2. Knowledge layer: the route-gate ADR reads `Superseded by …`; the new reframe ADR reads
   `Supersedes: …-route-md-headless-eligibility-gate.md` (bidirectional link intact).

## Follow-up
- vine-coder dogfood contributor tool (deferred); PAUSE/ACTIVE deletion-site consolidation; #99; #55.
```

#### Reviewer Notes

- This PR is **documentation/closeout only** — no command or agent behavior changes. The behavior
  shipped in #113/#114/#115.
- The one substantive thing to check is the **knowledge-layer supersession**: the new reframe ADR must
  carry `Supersedes:` the route-gate slug, and the route-gate record's Status line must read
  `Superseded by …` — body otherwise immutable. Both halves are done; verify the link.
- **Do not merge a PR from the old `feature/cross-actor-state` branch** — it is stale (lacks #114's
  vine-reviewer ladder) and would revert merged work. Recommend deleting it after this closeout merges.
- `Refs #79` — the issue can close once this closeout merges (EVOLUTION + the ADR are the last owed
  pieces the prior PRs deferred).

#### Multi-PR Summary

| Phase | Slices | Status | PR |
|-------|--------|--------|----|
| Phase 1: Autonomous agent path (additive) | 1-4 | ✅ Shipped | [#113](https://github.com/moduloMoments/VINE/pull/113) |
| (mid-cycle) vine-reviewer validation-discovery ladder | — | ✅ Shipped | [#114](https://github.com/moduloMoments/VINE/pull/114) |
| Phase 2: Retire old machinery + repo-wide alignment | 5-7 | ✅ Shipped | [#115](https://github.com/moduloMoments/VINE/pull/115) |
| Evolve closeout (this report + ADRs) | — | 🚧 this PR | — |
