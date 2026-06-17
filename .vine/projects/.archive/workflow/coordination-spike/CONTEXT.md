# Feature Context: Coordination Spike (Cycle 0)
## Date: 2026-06-11
## Author: Rob + Claude

Ground truth: `ROADMAP.md` — "The core loop", the cycle-0 row, and "The spike's six
questions". The spike runs the whole delegation loop end to end, once: one shepherd + one
auto-agent + one reviewer, one feature, one full routing decision — scope arrives →
eligibility evaluated → route chosen → headless execution → reviewer consumes the handoff.
Throwaway scaffolding is allowed and expected; the deliverable is **answers to the six
questions**, not durable mechanisms. Findings that reshape cycle 1 (foundation) are the
point of running this first.

### Codebase Landscape

**The loop's stages and where their mechanics live today:**

- **Scope** — arrives as a freshened cold-executable issue: [#46](https://github.com/moduloMoments/VINE/issues/46)
  (consolidate overlay-loading boilerplate, 9 command files) or [#47](https://github.com/moduloMoments/VINE/issues/47)
  (consolidate AskUserQuestion constraints block, 4 command files + shared.md). Both were
  freshened 2026-06-11 by the delegation-routing re-scope specifically to be executable by
  a cold actor.
- **Route (eligibility predicate, Q1)** — hand-rolled for the spike; the real gate is #54
  (cycle 1). The four predicate legs and their current homes:
  - *Global validation contract*: **does not exist.** #54 proposes a fenced YAML block
    under `## Validation` in `.vine/context/shared.md`; today validation commands are
    prose in `.vine/context/navigate.md`. For this repo the de facto contract is
    `.vine/scripts/run-tests.sh` (hook-script suite) + trellis-check.sh for command-file
    edits.
  - *Slice ACs*: SPEC.md per-slice `**Acceptance criteria**:` field (STATE.md:81) —
    structured markdown, grep-able, conditions themselves are prose.
  - *Slice independence*: SPEC.md `**Depends on**:` field (STATE.md:79) — free prose, no
    slice-ID graph; "independent of in-flight work" has no representation at all.
  - *Bounded blast radius*: SPEC.md `**Files likely touched**:` field (STATE.md:80) —
    free-text list, "likely" by design, nothing validates existence or overlap.
- **Execute (headless leg, Q2)** — navigate's slice loop (`commands/vine/navigate.md`):
  gearing decision per slice, approach preview, implement, validate via the
  `vine-verification` agent (slice mode), append NAVIGATION.md entry, commit. Entry
  schema: navigate.md:268–285 (writer) / `references/STATE.md`:114–145 (reader contract,
  required/optional markers). The platform owns execution mechanics (guiding principle):
  headless = `claude -p` or Agent-tool subagent; VINE supplies criteria and consumes
  mechanics.
- **Handoff (Q3–Q5)** — evolve's `### Handoff Package` in EVOLUTION.md (PR Description,
  Reviewer Notes, Commit Suggestions, Context for future sessions) is today both the
  outbound and inbound contract. #53 deliberately left the structured-handoff block
  undesigned: "let the spike answer first" whether outbound and inbound are one artifact.
- **Evolve (calibration, Q6)** — evolve reads NAVIGATION.md per-slice ACs/validation/
  commits/deviations and PROJECT-MAP.md tables. The Stop-hook reflection calibration loop
  is **aspirational** — named in ROADMAP.md:68, implemented nowhere.

**Hook scripts a headless run encounters** (all PreToolUse-on-Bash, wired in
`.claude/settings.json`; all read `CLAUDE_PROJECT_DIR`):

| Script | Fires when | Check | Fail mode |
|--------|-----------|-------|-----------|
| `journal-check.sh` (ships to users) | `git commit` | `.vine/ACTIVE` exists AND active feature's NAVIGATION.md mtime < HEAD commit time | open |
| `main-guard.sh` (contributor-only) | `git commit` | current branch is `main` | open |
| `trellis-gate.sh` (contributor-only) | `git commit` touching `commands/vine/*.md` | `.vine/.trellis-ok` stamp missing or stale | **closed** |

**Verification agent (post-PR #86):** `agents/vine-verification.md` is the single shipped
surface for the cross-change checklist. Slice mode (per-change: lint/typecheck/tests +
AC check) and feature mode (phase-group scope from navigate, full-feature scope from
evolve). It reads validation commands from overlays directly. It has **no routing
awareness** — no concept of headless vs. interactive.

**Roles hypothesis (Q4):** role = overlay stack + entry point + handoff contracts
(ROADMAP.md:70–73, "the spike validates it"). Today the reviewer has **no entry point** —
`vine:status` is the closest read-only candidate but outputs progress tracking, not
reviewer orientation; there is no `.vine/context/review.md`; PROFILE.md stays orthogonal
(depth only, never identity or authority).

### Current State

- Main is fresh at `ce84718`; no open PRs; this worktree branches from main HEAD.
  Recently merged and load-bearing for the spike: [#86](https://github.com/moduloMoments/VINE/pull/86)
  (verification-boundary consolidation — the agent the foundation cycle assumes now
  exists), [#84](https://github.com/moduloMoments/VINE/pull/84) (trellis stamp is
  script-owned via trellis-check.sh), [#82](https://github.com/moduloMoments/VINE/pull/82)
  (the roadmap re-scope this spike executes against).
- **Decided but not implemented** (the spike scaffolds these as throwaways):
  - Per-slice route + actor attribution fields on NAVIGATION.md entries — no such field
    in any template; the only attribution is the *informal* `(decided by:
    engineer/claude)` convention inside `**Decisions made**` bullets (used consistently in
    `workflow/delegation-routing/NAVIGATION.md`, documented nowhere).
  - Scope-level route in PROJECT-MAP.md — no Route/Mode column in either table
    (STATE.md:257–272).
  - #53's `Decisions Taken Autonomously` block — named in the issue, exists in no schema.
- **#46/#47 cold-executability**: verified — bodies carry problem, suggestion, constraint
  (graceful fallback when shared.md absent), and coordination notes. #46 ~9 files +
  shared.md; #47 ~4 files + shared.md.
- One E3 data point already exists: delegation-routing's EVOLUTION.md ran an explicit
  E3-reader acceptance check — 7 of 8 decisions findable in public docs, the 8th only in
  shipped artifacts.

### Edge Cases & Tribal Knowledge

- **A headless run on #46 or #47 edits `commands/vine/*.md`, so trellis-gate fires — and
  it fails closed.** The headless actor must run trellis-check.sh green (writes
  `.vine/.trellis-ok`) before its commit, in its own worktree (the stamp and ACTIVE are
  gitignored, so nothing carries over from the shepherd's checkout). This makes the
  trellis check part of the de facto validation contract for this scope — a genuine
  predicate input, not an obstacle.
- **journal-check's mtime primitive is "wrong for E2"** (delegation-routing SPEC.md tech
  debt, deferred to foundation). For the spike's fresh-worktree headless run it should
  pass (checkout mtime > HEAD commit time), but verify empirically — a misfire here is a
  finding, not a failure.
- **ACTIVE lifecycle in a dead headless session**: if the headless actor writes
  `.vine/ACTIVE` and crashes, the stale sentinel blocks later commits in that checkout
  until a human runs `rm .vine/ACTIVE`. Manual escape hatch defeats the headless model —
  feeds Q2 and #79.
- **Hooks-in-headless is unverified**: whether PreToolUse hooks fire identically under
  `claude -p` and Agent-tool subagents, whether `CLAUDE_PROJECT_DIR` resolves to the
  worktree root, and whether a headless session can itself spawn the Agent tool (navigate
  step 4a delegates validation to vine-verification) are empirical platform questions the
  spike answers by running them.
- **Spawned-session isolation** (session memory, hard-learned): spawned sessions may share
  the root checkout on main — every delegated prompt must force branch/worktree isolation
  explicitly. main-guard backstops this in this repo only (contributor-only script).
- **Navigate's interactive decision points** a headless run must pre-decide or surface
  (navigate.md): feature selection (pre-supplied as argument), approve-edits prompt
  (skip — "don't block on this"), branch confirmation (pre-verified), per-slice gearing
  (collapses to free-climb; steps 3b/3c become no-ops), **unspecced implementation
  decisions and blocker resolution (the structural risk — must default-and-record or
  stop-and-surface per #53's human-required/default-able split)**, between-slice
  continuation (always continue), test-coverage gap (pre-decided policy), PR suggestion
  (surface in handoff, never act).
- **Navigate's own framing warns about this exact mode**: "navigate without review drifts
  toward autonomous coding with extra documentation — fine if the engineer chooses it
  deliberately, not as a default" (navigate.md:56–63). The routing decision being recorded
  *upstream* (the eligibility gate) is what makes a headless entry legitimate.
- **#46 and #47 overlap**: both touch the overlay-loading region of the same command
  files. Run **one** as the delegated feature; doing both concurrently would collide.
  #46 also says "coordinate with the foundation cycle's precedence work" — #47 is the
  cleaner cold run (smaller blast radius, no foundation coupling).
- **AC standard** (session memory): resolve acceptance-criteria letter-vs-intent toward
  intent — the bar is whether a cold actor would act wrongly.
- The slice-status heading suffix (`— In Progress / Complete`) is a literal-string
  writer/reader contract (pause matches on it); the `### Slice N:` prefix is what
  trellis Check A matches. A headless writer must keep both exact.

### Tech Debt in Affected Areas

- **mtime-based journal-check** — wrong primitive for E2; deferred to foundation; the
  spike will exercise it and should record observed behavior. (High relevance)
- **Precedence sentence present in only 4 of 9 loading blocks** — #46's coordination
  point with the foundation's rule-class split; whichever lands first fixes it. (Relevant
  if #46 is chosen; an argument for #47)
- **ACTIVE's uncoordinated deletion triggers + PAUSE.md semantics under E2** — owned by
  #79 (cycle 3), shaped by this spike's Q2 finding. Don't fix; observe.
- **No Route/Actor schema anywhere** — decided (delegation-routing SPEC decision 5), not
  implemented. The spike's scaffolded fields become cycle 1's input. (The gap *is* the
  work)
- **Stop-hook reflection calibration loop** — named plumbing, zero implementation; Q6
  only asks whether the journaling homes give evolve enough, not for the loop itself.

### Documentation Gaps

These constitute the Q3 (E3) gap analysis — what a cold reviewer cannot infer from
`.vine/projects/<domain>/<slug>/*.md` alone when STATE.md never shipped:

- Required-vs-optional field contract for NAVIGATION.md (markers live only in STATE.md;
  absent optional fields read as incomplete work).
- The slice-status literal-string contract and what tooling matches on it.
- The deviation-closure contract (SPEC.md strikethroughs ↔ NAVIGATION.md deviations
  pairing).
- The two-AC-layer model (SPEC top-level cycle contract vs. per-slice checklists) that
  makes EVOLUTION.md's traceability table legible.
- PROJECT-MAP.md's status-marker legend and created-by-verify-only lifecycle.
- Whether `#### Context for future sessions` is authoritative or supplementary to
  NAVIGATION.md's `### Remaining Work`.
- The Committing Artifacts table (what each commit point should carry when artifacts are
  tracked).
- The `(decided by:)` attribution convention — live in every real journal, documented
  nowhere, invisible to template-aware tooling.

What a cold reviewer CAN infer: feature/domain/dates, slice list + completion status,
commits + validation per slice, deviations (if strikethroughs are legible), phase
progress, and the prose Handoff Package. Highest-value single chunk to ship if Q3 says
something must: STATE.md's NAVIGATION.md schema section (lines 109–145).

### Open Questions

The six questions (ROADMAP.md:154–168) are the spike's deliverable; exploration already
shades some:

1. **Eligibility predicate mechanically checkable?** Leaning *checkable in principle, not
   with today's fields*: validation contract absent (this repo's de facto contract =
   hook-script suite + trellis check), independence and blast radius are unvalidated
   prose. The hand-rolled gate should record exactly which checks were mechanical vs.
   judgment.
2. **Headless navigate entry + commit without tripping/bypassing journal-check/ACTIVE?**
   Mechanics mapped above; empirical legs: hook firing under `claude -p`/Agent-subagent,
   CLAUDE_PROJECT_DIR in worktrees, nested Agent spawning for vine-verification, ACTIVE
   cleanup on session death. Minimal attribution candidate to test: a `**Route**:`/
   `**Actor**:` field pair on the entry vs. extending the `(decided by:)` convention.
3. **Reviewer orients from artifacts alone (E3)?** Gap list above is the test rubric; the
   spike's reviewer leg should be run against it cold.
4. **Role = overlay stack + entry point + contracts sufficient?** No reviewer entry point
   exists; spike must improvise one (vine:status, or raw artifact reading with a
   scaffolded `.vine/context/review.md`) and note what state, if any, was needed outside
   the artifact chain.
5. **One handoff artifact for outbound + inbound?** Visible tension already: outbound is
   a structured decision log (decision → default → confidence → rationale), inbound is
   prose orientation (what to scrutinize, tribal context). Spike tests whether one block
   serves both readers.
6. **Route-journaling homes sufficient for evolve?** Today evolve can parse nothing
   routing-shaped. The scaffolded fields (Q2/Q6) are the test: can evolve's calibration
   read gear, actor, and outcome per slice plus route per scope without a new artifact?

**Process questions for the spike session (inquire/decide before running):**

- Which feature for the delegated run — recommendation: **#47** (smaller blast radius, no
  coupling to the foundation's precedence work; #46 stays the second contract test once
  cycle 1's real gate exists).
- How much chain ceremony for the spike itself: a minimal SPEC.md (slices = the loop's
  stages: gate scaffold → headless run → reviewer leg → findings write-up) keeps the
  artifact chain honest without over-building a throwaway. The *delegated feature* (#47)
  is pair-shaped per the roadmap's side-track row but runs navigate-shaped headless —
  that mismatch is itself a finding to record.
- Where the six answers land durably: EVOLUTION.md is the natural home (findings +
  follow-ups reshaping cycle 1), with the roadmap updated at the cycle boundary per
  process notes.
