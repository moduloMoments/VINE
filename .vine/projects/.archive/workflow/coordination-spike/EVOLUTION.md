# Evolution Report: Coordination Spike (Cycle 0)
## Date: 2026-06-12

### Product Evolution

#### Acceptance Criteria Results

Full-feature verification (vine-verification agent, feature mode): **pass** — run-tests.sh 24/24, trellis-check 11/11, artifact chain cross-consistent, headless-47 worktree spot check confirms all three delegated commits.

| Acceptance criterion (SPEC) | Evidence (slice / commit) | Verdict |
|---|---|---|
| All six questions answered from run observations, consolidated | Slice 4 — 25129c9 (answers + evidence pointers) | pass |
| #47 run → reviewable commits + handoff, or informative failure | Slice 2 — b20a1fe (`bfe5458` + 3 informative failures); Slice 3 — d2c4c88 (re-entry `030836f`+`56856d5`) | pass |
| Every scaffold throwaway-marked + keep/discard tagged | Slice 4 — 25129c9 (all four tagged) | pass¹ |
| No durable mechanism beyond what findings justify | Branch diff vs origin/main: artifacts + review.md + 3-line convention only; review.md promoted at evolve on Q4 evidence | pass |
| Tech debt observed, not fixed | Slices 1–2 — f8600fd, b20a1fe | pass |

¹ One marker-consistency warning: the `### Decisions Taken Autonomously` heading in the actor journal (headless-47 worktree) lacks the inline throwaway comment its sibling scaffolds carry. Keep/discard tag exists at the spike level; AC intent met.

#### The Six Answers (compiled from Slice 4's consolidation)

1. **Q1 — eligibility predicate mechanically checkable?** Checkable in principle, not with today's fields: 0/4 legs fully mechanical. Run-discovered amendments: gate output must be **verdict + constraints**; verdicts **decay** (independence went stale within hours); occurrence-grep blast radius misses **requirement-implied files** (F1's root cause). → posted to #54.
2. **Q2 — headless entry + commit without tripping/bypassing journal-check/ACTIVE?** Yes, three times. Headline: **mechanism portability** — the envelope was rewritten three times across four mechanisms plus a re-entry; the contract core survived every swap unmodified. "VINE is the map, not the mechanism." Platform boundaries: nested Agent tool unavailable to subagents; `CLAUDE_PROJECT_DIR` unset in subagents; headless auth = `claude setup-token`; actor permissions are a provisioning-time human authority. → #53/#54/#79.
3. **Q3 — reviewer orients from artifacts alone?** Yes — load-bearing review with a true major finding (F1), validation independently re-run. The gaps that bite are delegation-route-shaped (gate record + envelope lacking durable homes), not the predicted artifact-format gaps. CONTEXT.md's "ship STATE.md's schema" guess overturned. → #53.
4. **Q4 — role = overlay stack + entry point + handoff contracts?** Holds, with the gate record/envelope promoted into the handoff contracts. A ~50-line review.md was a sufficient entry point first try. Caveat: subagents auto-load CLAUDE.md, which answered one load-bearing question. → #53/#54.
5. **Q5 — one handoff artifact for outbound + inbound?** One per-feature handoff suffices; the "second thing" is the durable role recipe. Confidence-tagged decision logs served both directions — the cold reviewer independently engaged exactly the two medium-confidence entries. Binding inbound requirement: read the originating scope directly. → #53.
6. **Q6 — journaling homes sufficient for evolve?** Yes-except-gear: five small schema fixes, no new calibration artifact — except the durable gate record, the one new artifact the evidence justifies. → #90.

**Convergent finding:** every Q3–Q6 failure mode points at one cycle-1 design move — a durable gate record (verdict + constraints + allowlist + validation baseline) that the envelope embeds, the reviewer reads, and the Route table points at.

#### Spec Deviations

One: SPEC decision 2's headless mechanism (`claude -p`) diverged to the Agent-tool subagent (4th mechanism) after three informative platform failures (auth, remote provisioning, scheduled-task permission deadlock). Annotated as a SPEC addendum; recorded in Slice 2's Deviations field; itself the source of the Q2 mechanism-portability finding. Justified — and the divergence trail is spike evidence, not a quality concern.

#### Scaffold Dispositions (executed at evolve)

| Scaffold | Tag | Disposition |
|---|---|---|
| `**Route**:`/`**Actor**:` per-slice fields | KEEP | Schema work → #90 (controlled vocabulary, `mechanism:` token, sibling Gear field) |
| PROJECT-MAP Route table | KEEP | Best-performing scaffold; gate-record cell becomes a path once #54 ships the durable record |
| `.vine/context/review.md` | KEEP | **Promoted from throwaway this evolve** (Q4 evidence); cycle 1 adds "read the gate record" to orientation order |
| `Decisions Taken Autonomously` block | KEEP | Section-scoped attribution + `(slice N)` prefix → #90 |
| Delegation-prompt files | KEEP pattern | v4 (re-entry envelope) is the durable-envelope pattern; v1–v3 archived as evidence |
| Throwaway HTML markers | DISCARD at adoption | Replaced by real STATE.md schema entries in cycle 1 |

#### Follow-Up Items

- **Posted to [#54](https://github.com/moduloMoments/VINE/issues/54)**: gate findings (0/4 mechanical, verdict+constraints, verdict decay, requirement-implied blast radius, durable gate record, actor-permission authority split).
- **Posted to [#53](https://github.com/moduloMoments/VINE/issues/53)**: handoff findings (one artifact + role recipe, confidence-tag triage, read-originating-scope mandate, envelope durability, event-driven re-entry as third route shape).
- **Created [#90](https://github.com/moduloMoments/VINE/issues/90)**: journal schema fixes from the Q6 probe (Gear field, validation token, multi-commit Commit, `(slice N)` attribution, route vocabulary + mechanism token, formalize `(decided by:)` + confidence tags).
- **ROADMAP.md updated** at the cycle boundary (cycle-0 row done; six-questions section points here).
- **Open**: the delegated #47 branch (`feature/askuser-constraints`, headless-47 worktree, commits `bfe5458`+`030836f`+`56856d5`) is reviewed, request-changes resolved, and awaits the shepherd's PR call.
- **Observed, not fixed** (per spec): journal-check mtime (never visibly fired across three headless commits — fired-and-passed vs. didn't-fire indistinguishable, feeds the hook-scoping debt); ACTIVE lifecycle (clean in all completed runs — feeds #79); run-tests fixture baseline (fixed on main by #89 mid-cycle; actor journal's 19/4 records stay checkout-accurate).
- **Minor**: missing throwaway marker on the actor journal's `Decisions Taken Autonomously` heading (headless-47 worktree) — moot if that branch ships, since markers are discarded at adoption.

### Agent Evolution

#### CLAUDE.md / Overlay Suggestions

- **Accepted → shared.md (Tooling Notes)**: "Agent reports are findings-trustworthy, diagnosis-unverified" — re-verify root-cause narratives with a cheap direct check. (Cycle evidence: three accurate subagent reports, one inverted root cause.)
- **Accepted → review.md promotion**: the reviewer role recipe is now a durable overlay (header documents provenance and the cycle-1 follow-up).
- **Landed mid-cycle → shared.md**: branch-naming convention (VINE project slug ↔ feature branch name).
- No CLAUDE.md changes — both notes are VINE-session knowledge; per the Knowledge Boundary rule they belong in shared.md.

#### Skill Suggestions

> **Suggested skill: `post-delegation-sweep`** (deferred to cycle 1 — decided this evolve)
> When triggered: after any delegated/headless run returns DONE.
> What it does: the shepherd's verification sweep that repeated near-identically 3× this cycle — diff-vs-allowlist check, trellis stamp freshness in the actor's checkout, journal literal-string contracts (`### Slice N:` prefix, `— Complete` suffix, required fields), ACTIVE cleanup, claimed-vs-actual commit hashes.
> Estimated value: ~10 min per delegated run; becomes mechanizable once #54's gate record gives it a machine-readable allowlist input.

#### VINE Process Observations

- **Mode mismatch was free**: #47 is pair-shaped per the roadmap but ran navigate-shaped headless with zero friction — route shape and ceremony weight look like independent axes for cycle 1's gate.
- **The upstream gate legitimizes headless navigate**: navigate's own warning about review-free drift is answered by the routing decision being recorded upstream — the spike's structure confirmed the design intent.
- **Dogfooding meta-friction**: none significant; the spike modified no commands, so command self-reference never arose.
- **Verification tiers worked as designed**: per-slice validation (navigate) + full-feature integration check (evolve) divided cleanly; evolve's check added the cross-worktree spot check no slice could.

### User Evolution

#### Engineer Contributions

- The **reference architecture** (Jira → GitHub Action → comment-thread escalation) introduced event-driven re-entry as the third route shape — exercised live in the F1 fix, now cycle-1 design input on #53.
- The **boundary thesis** ("VINE is the map, not the mechanism") preceded the evidence and became the Q2 headline answer after four mechanism swaps confirmed it.
- The **F1 disposition** (re-delegate over shepherd-fix) chose evidence over speed and produced the spike's only live re-entry data point.
- **Mechanism pivots** at each platform failure kept the loop completing while every divergence was recorded — three failures read as findings instead of a stalled spike.
- The **three-layer reviewer-content split** (PR description / agent handoff / role recipe) was the engineer's framing at inquire; it held under test.

#### Profile Updates

- Created `.vine/PROFILE.md` with `workflow: confident` (accepted).
- Growth log entry: skipped (engineer's call).

#### Claude Memory Suggestions

- **Accepted**: "Evidence over speed" — in spike/research work, take the path that produces the data point. Saved to Claude memory.
- **Declined**: "Swap mechanism, keep contract" — not persisted.

### Handoff Package

#### PR Description

```markdown
## Summary

Cycle-0 coordination spike: ran the delegation loop end to end once — eligibility
gate → headless actor → cold reviewer → calibration probe — against a real issue
(#47), and recorded evidenced answers to the roadmap's six delegation questions.
The deliverable is the answers; scaffolding was throwaway by design.

## What this ships

- The spike's VINE artifacts under `.vine/projects/workflow/coordination-spike/`
  (journal, spec, evolution report with the six answers, archived delegation prompts)
- `.vine/context/review.md` — the reviewer role recipe, promoted from scaffold after
  it carried a cold review first try
- shared.md: branch-naming convention + "agent reports are findings-trustworthy,
  diagnosis-unverified" note
- ROADMAP.md: cycle-0 row closed, six-questions section points at the answers

## What it found (short form)

The gate's output needs to be a durable artifact (verdict + constraints + allowlist +
validation baseline) — every reviewer-side gap traced to it. The delegation contract
proved mechanism-portable across four execution mechanisms. Findings posted to #53,
#54; schema fixes filed as #90.

## How to test

1. Read the six answers in `.vine/projects/workflow/coordination-spike/EVOLUTION.md`
2. `bash .vine/scripts/run-tests.sh` (24/24) — no command files changed
```

#### Reviewer Notes

- The delegated #47 work is NOT in this PR — it lives on `feature/askuser-constraints` (headless-47 worktree) and ships separately. This PR is the spike's record.
- NAVIGATION.md is unusually dense for a journal: it doubles as the spike's evidence log (eight numbered platform observations in Slice 2, rubric scoring in Slice 3, parse-extraction verdicts in Slice 4). Skim the Slice 4 consolidation first; drill down only where an answer's evidence matters to you.
- review.md's promotion is the one durable mechanism this spike ships — the justification is the Q4 verdict (cold reviewer produced a true major finding from the recipe + artifacts alone).
- The three delegation-prompt files are archived evidence, not live templates; cycle 1 (#53/#54) designs the real envelope.

#### Commit Suggestions

Single evolve commit on top of the existing five (verify + four slices); message below. The branch is rebased on main `287fd02` and merges clean.

#### Multi-PR Summary

Not applicable — no Milestones table; single-PR feature. The delegated #47 branch is tracked in PROJECT-MAP.md's Route table, not as a milestone.
