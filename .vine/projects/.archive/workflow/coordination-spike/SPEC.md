# Feature Spec: Coordination Spike (Cycle 0)
## Date: 2026-06-11
## Built on: CONTEXT.md (2026-06-11)
## Decisions made by: Rob

### Problem Statement

Run the delegation loop end to end, once — one shepherd, one headless actor, one
reviewer, one feature, one full routing decision — and answer the six roadmap questions
(ROADMAP.md:154–168). Throwaway scaffolding is expected; the deliverable is evidenced
answers that reshape cycle 1, not durable mechanisms.

### Approach

The spike's slices are the loop's own stages: gate → headless run → reviewer leg →
calibration probe. Decisions made at inquire:

1. **Delegated feature: [#47](https://github.com/moduloMoments/VINE/issues/47)**
   (consolidate AskUserQuestion constraints block, ~4 command files + shared.md).
   Smaller blast radius than #46 and no coupling to the foundation cycle's precedence
   work. #46 stays in reserve as the second contract test once cycle 1's real gate
   exists. (Rob; recommended by verify.)
2. **Headless mechanism: `claude -p` in its own worktree.** Fully cold session — the
   truest test of cold-executability, hook firing outside the interactive harness, and
   the fleet-delegation model. Worktree isolation is forced explicitly in the delegation
   prompt (session-isolation rule: spawned sessions may otherwise share the root
   checkout on main). (Rob.)
   *Noted for cycle 1, out of spike scope:* agent teams (named teammates + a live
   SendMessage channel back to the shepherd) are a third candidate mechanism, mapping
   to a distinct route mode — **supervised delegation**. Stop-and-surface implies an
   escalation channel; `claude -p` has none (the actor can only halt and write). Slice
   2 records whether stop-and-surface fires and how it degrades headless — that
   observation decides whether a supervised-teams route mode belongs in cycle 1's gate.
   *Addendum (slice 2 deviation, 2026-06-11/12):* `claude -p` failed on auth before
   touching anything; delivery happened via the **4th mechanism** (Agent-tool subagent
   into the same worktree) after a remote cloud-agent and a local scheduled-task
   attempt also failed informatively — full trail in NAVIGATION.md Slice 2. A **5th
   mechanism event** followed at the slice 3 boundary: a reviewer-triggered headless
   re-entry run (durable envelope `delegation-prompt-47-reentry.md`) fixed reviewer
   finding F1 on the #47 branch — the event-driven re-entry route shape from the
   reference architecture, exercised live. The contract core survived every envelope
   swap unmodified (mechanism-portability finding, Q2).
3. **Attribution scaffold: per-slice `**Route**:`/`**Actor**:` field pair on
   NAVIGATION.md entries plus a Route column in PROJECT-MAP.md** — the shape
   delegation-routing's SPEC decision 5 decided but never implemented. Structured, so
   the Q6 probe can test whether evolve can parse it. The informal `(decided by:)`
   convention is left as-is for comparison, not extended. (Rob.)
4. **Reviewer content is a three-layer split.** (Rob; surfaced the layering question
   himself.)
   - **PR description** — human-readable, one screen, zero context (hard repo rule,
     CLAUDE.md). Links to artifacts, never carries reviewer orientation.
   - **Per-feature reviewer content** — agent-focused, lives in evolve's Handoff
     Package in EVOLUTION.md. This is the artifact Q5 interrogates.
   - **`.vine/context/review.md`** — the role recipe: durable-shaped (throwaway for the
     spike) instructions for how any cold reviewer orients over the artifact chain.
     This is the Q4 entry-point test.
   - Bonus finding to record: can the human PR description be mechanically derived
     from the agent-focused handoff, or do they need separate authoring?
5. **Autonomy policy for the headless actor (#53's split):** **default-and-record** for
   in-scope implementation choices, captured in a scaffolded `Decisions Taken
   Autonomously` block; **stop-and-surface** for anything that changes scope or blast
   radius. The actor commits but never opens a PR (surface in handoff, never act).
6. **Ceremony:** minimal SPEC.md (this document), single navigate session, single PR
   for the spike's own artifacts. The delegated #47 work lands as the headless actor's
   commits in its own worktree — the reviewer leg consumes them; PR handling for that
   work is the shepherd's call after review. Findings land durably in EVOLUTION.md at
   evolve; ROADMAP.md updates at the cycle boundary.

### Acceptance Criteria

- All six roadmap questions have answers backed by observations from the run (not
  reasoning from the map alone), consolidated for evolve to compile into EVOLUTION.md.
- The delegated #47 run produced either reviewable commits + handoff or an informative
  failure — both are valid spike outcomes; silent/ambiguous failure is not.
- Every scaffold (Route/Actor fields, PROJECT-MAP Route column, review.md, Decisions
  Taken Autonomously block) is marked throwaway and carries a keep/discard
  recommendation for cycle 1.
- No durable mechanism ships beyond what the findings justify.
- Tech debt encountered (journal-check mtime, ACTIVE lifecycle) is observed and
  recorded, not fixed.

### Work Slices

### Slice 1: Eligibility gate run (Q1)
**Goal**: Hand-roll the four-leg eligibility predicate against #47 and record the
routing decision: global validation contract, slice ACs, slice independence, bounded
blast radius. For each leg, record a verdict — *mechanical* (checked by tooling/grep),
*judgment* (human/Claude call), or *input-absent* (the field needed doesn't exist).
**Depends on**: Nothing.
**Files likely touched**: PROJECT-MAP.md (scaffold Route column), NAVIGATION.md (route
decision entry).
**Acceptance criteria**:
- Route decision recorded with all four per-leg verdicts.
- The de facto validation contract for #47's scope named explicitly
  (`.vine/scripts/run-tests.sh` + trellis-check.sh, since the edits touch
  `commands/vine/*.md`).
- Route column scaffolded into PROJECT-MAP.md with the decision.
**Complexity signal**: Low — the predicate is hand-rolled by design; the work is honest
bookkeeping.

### Slice 2: Headless delegation run (Q2)
**Goal**: Compose the delegation prompt and run #47 via `claude -p` in a fresh
worktree; observe everything the platform does.
**Depends on**: Slice 1 (route decision must exist upstream — that's what legitimizes a
headless navigate entry).
**Files likely touched**: Delegation prompt (throwaway file or inline), the delegated
worktree (actor-owned), observation notes in NAVIGATION.md.
**Acceptance criteria**:
- Delegation prompt pre-decides every interactive navigate decision point from
  CONTEXT.md's list: feature pre-supplied, approve-edits skipped, branch pre-verified,
  gearing collapsed to free-climb, always-continue between slices, test-coverage policy
  set, PR suggestion surfaced-never-acted; unspecced decisions follow the
  default-and-record / stop-and-surface split.
- Prompt forces worktree isolation and requires trellis-check.sh green (fresh
  `.vine/.trellis-ok` in the actor's checkout) before any commit.
- Prompt instructs the actor to write `**Route**:`/`**Actor**:` on each NAVIGATION.md
  entry and a `Decisions Taken Autonomously` block in the handoff, keeping the
  `### Slice N:` prefix and `— In Progress / Complete` literal contracts exact.
- Run completes or fails informatively; outcome recorded either way.
- Empirical observations recorded for each Q2 leg: PreToolUse hook firing under
  `claude -p`, `CLAUDE_PROJECT_DIR` resolution in the worktree, whether the headless
  session can spawn the Agent tool (vine-verification slice mode), ACTIVE
  lifecycle/cleanup, journal-check mtime behavior (misfire = finding, not failure).
**Complexity signal**: High — this slice carries every empirical platform unknown the
spike exists to resolve.

### Slice 3: Reviewer leg (Q3–Q5)
**Goal**: Scaffold `.vine/context/review.md` as the role recipe, then run a cold
reviewer session (no spike-session context) against the delegated artifacts and
handoff.
**Depends on**: Slice 2 (needs the actor's commits, journal, and handoff to review).
**Files likely touched**: `.vine/context/review.md` (throwaway scaffold), reviewer
findings in NAVIGATION.md.
**Acceptance criteria**:
- Reviewer session is genuinely cold: a fresh session whose only inputs are review.md
  and the artifact chain.
- Q3: verify's documentation-gap rubric (CONTEXT.md "Documentation Gaps") scored
  item-by-item — which gaps actually blocked or misled the reviewer.
- Q4: verdict on the role hypothesis — what state, if any, the reviewer needed outside
  overlay stack + entry point + handoff contracts.
- Q5: verdict on one-handoff-vs-two, addressing the outbound structured-decision-log
  vs. inbound prose-orientation tension directly.
- Three-layer check: a human PR description drafted from the agent handoff, with a note
  on whether the derivation was mechanical or needed fresh authoring.
**Complexity signal**: Medium — the scaffold is small but cold-session discipline and
rubric scoring need care.

### Slice 4: Calibration probe + findings consolidation (Q6)
**Goal**: Test whether evolve's calibration could read gear, actor, and outcome per
slice plus route per scope from the scaffolded homes alone; consolidate all six answers
with evidence pointers for evolve.
**Depends on**: Slices 1–3 (consumes the scaffolded fields and all observations).
**Files likely touched**: NAVIGATION.md (findings consolidation), PROJECT-MAP.md.
**Acceptance criteria**:
- Q6: verdict on whether the scaffolded journaling homes (Route/Actor fields, Route
  column, Decisions Taken Autonomously block) give evolve enough to calibrate without a
  new artifact — tested by actually parsing them as evolve would, not by inspection.
- All six answers consolidated with pointers to the observations backing them, ready
  for evolve to compile into EVOLUTION.md.
- Each scaffold tagged keep/discard for cycle 1.
**Complexity signal**: Low-Medium — synthesis, but the parse-as-evolve-would test must
be honest.

### Tech Debt Integration

- **Observe, don't fix** (verify's stance, confirmed at inquire): journal-check's mtime
  primitive (record observed behavior in slice 2), ACTIVE's uncoordinated deletion
  triggers (owned by #79, shaped by Q2's finding), Stop-hook calibration loop (Q6 asks
  only whether journaling homes suffice).
- **The gap is the work**: Route/Actor schema absence is what slices 1–2 scaffold;
  observed usefulness becomes cycle 1's input.
- **Dropped out**: precedence-sentence inconsistency (4 of 9 loading blocks) was only
  relevant if #46 were chosen; it stays with #46/foundation.

### Backlog Updates

- #46 remains open as the second contract test, to run once cycle 1's real eligibility
  gate (#54) exists — its coordination note with the foundation's precedence work makes
  it the wrong cold run now and the right one later.
- Expect new finding-shaped issues out of evolve (cycle-1 reshaping); don't pre-create
  them here.
- If the slice-3 derivation check fails (PR description can't be mechanically derived
  from the handoff), that's a candidate backlog item for the handoff design (#53).
- If slice 2 shows stop-and-surface degrading badly without a live channel, agent
  teams as a supervised-delegation route mode becomes a design input for cycle 1's
  gate (#54) and handoff (#53).

### Dependencies & Risks

- **Platform empirics are the point and the risk**: hook firing under `claude -p`,
  `CLAUDE_PROJECT_DIR` in worktrees, nested Agent spawning, and ACTIVE cleanup on
  session death are all unverified. An informative failure on any of these is a
  deliverable, not a blocker — but a `claude -p` environment problem (auth, permissions
  mode) could stall slice 2; record and fall back to an Agent-tool subagent only as a
  recorded divergence, not silently.
- **trellis-gate fails closed**: #47's edits touch `commands/vine/*.md`, so the actor
  must get trellis-check.sh green in its own checkout before committing — part of the
  validation contract, encoded in the delegation prompt.
- **#46/#47 overlap**: both touch the overlay-loading region of the same files; only
  #47 runs. Nothing else is in flight (main fresh at `ce84718`, no open PRs as of
  2026-06-11).
- **Mode mismatch is a finding**: #47 is pair-shaped per the roadmap's side-track row
  but runs navigate-shaped headless — record the mismatch, don't resolve it.
