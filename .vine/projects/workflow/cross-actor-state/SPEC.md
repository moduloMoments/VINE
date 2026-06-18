# Feature Spec: Cross-actor state — the role-recipe reframe
## Date: 2026-06-17
## Built on: CONTEXT.md (2026-06-16)
## Decisions made by: Rob Bruhn

### Problem Statement

Issue [#79](https://github.com/moduloMoments/VINE/issues/79) framed this cycle as "build one
cross-actor live execution state model," with PAUSE.md / `.vine/ACTIVE` / PROFILE.md redesigned
inside it and journal-check.sh reworked for cross-machine use. The inquire conversation took that
framing apart and found a much smaller, sharper feature underneath it.

The reframe, in one line: **autonomous work doesn't happen by an agent impersonating a human
running `/vine:navigate` — it happens through a dedicated agent role that consumes the artifact
chain, bounded by a ticket and gated by a PR.** Once that's the model, almost everything #79 set
out to build dissolves:

- **Slice ownership / cross-actor live state** — unnecessary. Each autonomous unit is one ticket →
  one sub-agent → one branch → one PR. Git already isolates concurrent work completely; there is no
  two-writers-one-journal race to model. (#52's "single-writer-per-feature-directory" was already
  just the existing one-branch-per-feature convention.)
- **PROFILE.md read-guard** — unnecessary. The agent role simply has no profile-read step; the
  human-calibration (gearing) stays in the interactive commands where a human is present. PROFILE.md
  is untouched and stays human-only. No collision with #55.
- **ROUTE.md** — redundant. Its entire payload (verdict, allowlist, constraints, validation
  baseline, input basis) has a home in {the ticket, git/the PR, the `## Validation` block in
  shared.md}. ROUTE earned its place inside navigate's *in-session* headless route, where there was
  no ticket boundary; the ticket→agent model removes that boundary and absorbs the payload.
- **journal-check.sh cross-machine rework** — out of scope. The agent role owns "sync the journal
  before commit" as a recipe step; the hook stays as-is (fail-open) for the human path. Its
  separate value question is [#99](https://github.com/moduloMoments/VINE/issues/99).

What's actually left to build is small: **two shipped agent roles** (`vine-coder` writes,
`vine-reviewer` reviews), a **lightweight ticket convention** that hands autonomous work to
`vine-coder`, the **retirement of ROUTE.md and navigate's in-session headless route**, and **two
genuine bug fixes** that surfaced along the way.

### Approach

**Two agent roles, each its own recipe.** Because we accept Claude Code coupling for the execution
vehicle, the agent definition *is* the recipe — no separate portable-recipe layer. Two files ship
in `agents/` (mirrored into `.claude/agents/` by the existing symlink):

- **`agents/vine-coder.md`** — the autonomous coding role. Orientation order (ticket → SPEC.md →
  the feature's artifact dir / NAVIGATION.md), then: implement the ticketed slice(s) within SPEC
  scope; derive and respect its own touched-file discipline (the leash ROUTE used to carry); sync
  the NAVIGATION.md journal per slice (approach, validation, decisions, acceptance criteria); run
  the repo's `## Validation` contract; commit per slice with AC attribution; open **one** PR with a
  handoff. It also carries the **decision-handling semantics** that used to live as navigate's
  per-site `decision-class` tags: `default-able` → take the recommended path and log it as an
  autonomous decision; `human-required` → stop and surface it in the PR/handoff for a human, never
  decide it. The agent's separate context window gives the cold-actor property for free.
- **`agents/vine-reviewer.md`** — the reviewer role, ported from the existing `.vine/context/review.md`
  overlay (Role + authority boundary, Orientation Order, What to Scrutinize, What to Produce),
  **minus** the ROUTE orientation step. `.vine/context/review.md` the overlay retires; the
  contributor `pr-review` tool becomes a thin wrapper that spawns `vine-reviewer` with identical
  instructions instead of stuffing the overlay text into a generic subagent.

**Sub-agent conventions (the Claude Code sub-agents contract).** Both roles are standard Claude
Code agent definitions and follow its documented best practices — focused single responsibility, a
delegation-driving `description`, least-privilege `tools`, version-controlled in `agents/`. Three
platform facts (from the [sub-agents docs](https://code.claude.com/docs/en/sub-agents)) are
load-bearing:

- **`AskUserQuestion` is unavailable to sub-agents.** An autonomous actor *cannot* prompt the human
  mid-task. This is precisely why a `human-required` decision must resolve to *stop and surface in
  the PR/handoff*, never a question — the platform enforces what the reframe already chose. (The
  human-present interactive commands keep using `AskUserQuestion` as today.)
- **Tool access is the authority boundary, mechanically.** `vine-reviewer` ships
  `tools: Read, Grep, Glob, Bash` (no Edit/Write) — `review.md`'s "never edit, never commit" stops
  being prose and becomes enforced. `vine-coder` gets the implement-and-commit set
  (Read, Edit, Write, Bash, Grep, Glob). Both authority boundaries get mechanical teeth.
- **Fresh isolated context = the cold-actor property for free.** A non-fork sub-agent sees none of
  the parent's conversation; it loads CLAUDE.md + the memory hierarchy + a git-status snapshot, but
  *not* the session's history and *not* the Engineer Profile step (that step lives inside the
  interactive commands, which the agent doesn't run). So no human-depth calibration leaks in — with
  no guard needed. Only the agent's **final message** returns, so each recipe specifies a structured
  final-message output (PR link + slices done + decisions escalated for vine-coder; the review
  report for vine-reviewer).

**The ticket is the authorization.** At the end of inquire (or the relevant navigate session),
autonomous-eligible scope is ticketed out to `vine-coder`. The ticket carries the relocated ROUTE
payload as plain instructions: which SPEC slice(s), a pointer to SPEC.md, any scope constraints. The
PR that arrives back is the result; the human (or `vine-reviewer`) reviews it before merge. The leash
is the PR review, not a pre-committed repo artifact.

**navigate becomes interactive-only.** It sheds all in-session headless-execution prose and stops
writing ROUTE.md. Its head routing gate and the ROUTE artifact retire together — they were the same
machinery. navigate keeps only the human-in-session implementation flow.

This is the guiding principle taken to its conclusion: VINE owns the **role recipes and the ticket
contract**; the platform owns **how the role is invoked** (the sub-agent, the GitHub trigger). VINE
never implements an agent runner — it ships the recipe and lets the platform run it.

### Acceptance Criteria

Feature-level (verifiable at evolve):

- `agents/vine-coder.md` and `agents/vine-reviewer.md` exist with valid agent frontmatter
  (`name`, `description`, `tools`, `model`) and descriptions scoped so they auto-delegate only on
  explicit intent, not incidentally.
- A cold sub-agent spawned as `vine-coder`, given only a ticket + SPEC.md, can orient, implement,
  sync the journal, run validation, commit, and open a PR without reading session context. (Dogfood
  signal: it produces no "missing context" gaps that the recipe or artifacts should have carried.)
- A cold sub-agent spawned as `vine-reviewer`, given only a PR + ticket + repo artifacts, produces a
  review in the `review.md` "What to Produce" shape with an empty (or fully-explained) Missing
  context log — i.e. the ported recipe is self-sufficient without ROUTE.
- `vine-reviewer`'s `tools` exclude Edit/Write, so its "report only" authority boundary is enforced
  by the platform, not just asserted in prose. `vine-coder`'s tools are the least-privilege
  implement-and-commit set.
- Neither recipe relies on `AskUserQuestion` (unavailable to sub-agents); `human-required` decisions
  resolve to stop-and-surface in the PR/handoff.
- `grep -rn ROUTE` over product surfaces (commands/, references/STATE.md, CLAUDE.md, README.md,
  .vine/context/, .claude/commands/trellis.md) returns nothing except a documented retirement /
  migration note. The artifact chain reads CONTEXT → SPEC → NAVIGATION → EVOLUTION.
- `/trellis` passes after every slice (no dangling cross-references to ROUTE, review.md, or the
  removed navigate sections).
- No `decided by: claude` string remains; autonomous attribution names the role/route, not a model.
- navigate contains no in-session headless-execution prose; PROFILE.md and `.vine/ACTIVE` are
  unchanged from their pre-cycle form.
- A repo-wide sweep leaves no command implying a human-shaped vine command runs headlessly; the only
  autonomous actor is the `vine-coder` agent. ROADMAP.md cycle 3 reflects the reframe (role-recipe
  autonomy + ROUTE retirement), not the original "cross-actor live state model."

### Work Slices

## Phase 1: Autonomous agent path — additive (Slices 1-4) ✅
Summary: Stand up the new model on top of the existing one — both coexist, nothing is removed yet.
Session boundary: After this phase the autonomous path works end-to-end (ticket → vine-coder → PR →
vine-reviewer). ROUTE.md still exists but the new agents don't consume it.

### Slice 1: vine-coder agent definition
**Goal**: Create `agents/vine-coder.md` — the autonomous coding role recipe, absorbing ROUTE's
  leash discipline and the execute flow.
**Depends on**: Nothing (additive).
**Files likely touched**: `agents/vine-coder.md` (new; surfaces in `.claude/agents/` via the symlink).
**Acceptance criteria**: Valid frontmatter — `name: vine-coder`, a delegation-driving `description`
  scoped to explicit autonomous-implementation intent (not incidental matching),
  `tools: Read, Edit, Write, Bash, Grep, Glob` (least-privilege implement-and-commit set), an
  explicit `model`, and consider `isolation: worktree` so each run's edits land on a fresh branch
  fitting one-ticket→one-PR (final mechanics are navigate's call). No `memory` scope — the agent is
  stateless by design. Body (system prompt) carries: orientation order (ticket → SPEC → artifact
  dir), implement-within-scope + self-derived touched-file discipline, per-slice journal sync, run
  `## Validation`, per-slice commit with AC, single-PR handoff, the `default-able` /
  `human-required` decision-handling semantics resolved as *take-and-log* / *stop-and-surface*
  (never `AskUserQuestion`, which sub-agents can't call), and a structured final-message output
  (PR link + slices done + escalations).
**Complexity signal**: Medium — new role recipe; must correctly absorb the ROUTE leash and the
  decision-class semantics without a runtime to test against (run it on a real ticket to validate).

### Slice 2: vine-reviewer agent + retire review.md overlay
**Goal**: Port `.vine/context/review.md` into `agents/vine-reviewer.md` minus the ROUTE step; retire
  the overlay; rewrap `pr-review` to spawn the agent.
**Depends on**: Nothing (additive); pairs naturally with Slice 1.
**Files likely touched**: `agents/vine-reviewer.md` (new), `.vine/context/review.md` (delete),
  `.claude/commands/pr-review.md` (edit — spawn agent instead of reading the overlay).
**Acceptance criteria**: Valid frontmatter — `name: vine-reviewer`, a delegation-driving
  `description`, and `tools: Read, Grep, Glob, Bash` (no Edit/Write — the authority boundary is
  *mechanically* enforced, not just stated). Body carries Role/authority-boundary, Orientation
  Order (no ROUTE step), What to Scrutinize, What to Produce (the structured report = its final
  message). `pr-review` spawns `vine-reviewer` with identical instructions; no dangling reference to
  `.vine/context/review.md` (grep clean); the legacy `.vine/hooks/review.md` fallback note in
  pr-review is reconciled.
**Complexity signal**: Medium — a port plus a consumer rewrap; the ROUTE-step removal is the only
  content change.

### Slice 3: Auto-agent ticket convention
**Goal**: Define the lightweight convention by which inquire (and/or a navigate session) tickets out
  autonomous-eligible scope to `vine-coder`, carrying the relocated ROUTE payload as plain ticket
  instructions.
**Depends on**: Slice 1 (the ticket names vine-coder and references its recipe).
**Files likely touched**: `commands/vine/inquire.md` (completion/handoff), possibly
  `commands/vine/navigate.md` (a handoff path), `.vine/context/shared.md` (workflow map / a ticket
  convention note), `references/STATE.md` if the ticket shape warrants a documented format.
**Acceptance criteria**: A documented ticket convention (scope + SPEC pointer + constraints + names
  vine-coder); inquire's completion block can emit it for headless-eligible scope; the convention is
  glossed per Reference Legibility (reads without dereferencing). Keep it a convention, not a heavy
  new artifact.
**Complexity signal**: Low-Medium — mostly prose; the judgment is keeping it minimal.

### Slice 4: De-hardcode attribution + fix evolve.md:524 (ride-along fixes)
**Goal**: Two independent correctness fixes that surfaced in verify/inquire.
**Depends on**: Nothing.
**Files likely touched**: `references/STATE.md` (lines 195, 224), `commands/vine/navigate.md`
  (line 387), `commands/vine/evolve.md` (lines 524-525).
**Acceptance criteria**: (a) The autonomous-attribution wording references the role/route, not
  `claude`, at all three sites; readers still default a missing `**Actor**` to `human`. (b) evolve's
  resolve-time PAUSE delete surfaces any notes before deleting (or is shown to be genuinely
  redundant given the earlier consumed-once delete), matching the "surface then delete" rule the
  other four triggers follow.
**Complexity signal**: Low — targeted edits at known lines.

## Phase 2: Retire the old machinery + repo-wide alignment (Slices 5-7) ⬜
Summary: Remove ROUTE.md and navigate's in-session headless route now that the new path replaces
them, then sweep the whole repo so every command reads as human-in-the-loop and update the ROADMAP.
Session boundary: After this phase the old autonomous machinery is gone, no stale references remain,
and the cycle is reconciled in ROADMAP.md. This is the State Artifact Addition Checklist run in
reverse, plus a closing alignment pass.

### Slice 5: Retire ROUTE.md across all surfaces
**Goal**: Remove ROUTE.md from the artifact chain everywhere, with a migration note for downstream
  repos that already have ROUTE.md files.
**Depends on**: Phase 1 (the replacement path exists).
**Files likely touched**: `references/STATE.md` (template, chain position, Source-of-Truth +
  Committing tables, the journal-schema Route rules), `CLAUDE.md` (State Artifact Chain line),
  `README.md` (State Artifacts table), `.vine/context/shared.md` (workflow map / route-preview
  references), `.claude/commands/trellis.md` (Step 5a parse list, Step 5b discovery glob, Check A
  applies-to set, any ROUTE shape check), `commands/vine/inquire.md` (the non-binding route-preview
  block in its completion).
**Acceptance criteria**: `grep -rn ROUTE` over product surfaces is clean except a documented
  retirement/migration note; `/trellis` passes; the artifact chain is CONTEXT → SPEC → NAVIGATION →
  EVOLUTION with no ROUTE leg.
**Complexity signal**: High — many coupled surfaces; the reverse-checklist must be complete or
  trellis Check 10 catches the drift.

### Slice 6: navigate → interactive-only
**Goal**: Strip navigate's in-session headless-execution prose and ROUTE-writing head gate; confirm
  the `decision-class` semantics now live in vine-coder (Slice 1), and remove or neutralize their
  headless purpose in navigate.
**Depends on**: Slice 1 (decision semantics relocated), Slice 5 (ROUTE gone).
**Files likely touched**: `commands/vine/navigate.md` (remove headless branches, head routing gate,
  ROUTE writes, headless-only `decision-class` machinery as appropriate), `.vine/context/shared.md`
  (the Decision Delegation policy section — reframe so its headless semantics point at vine-coder,
  not navigate; mind that it is `class: policy`).
**Acceptance criteria**: navigate is interactive-only with no ROUTE references and no headless-
  execution prose; the Decision Delegation policy reads coherently against the new model; `/trellis`
  passes; `references/STATE.md` cross-references (`step N`) stay intact (prefer neutralizing over
  renumbering).
**Complexity signal**: High — navigate is the most cross-referenced command, and the Decision
  Delegation policy is policy-class; touch carefully.

### Slice 7: Repo-wide alignment sweep + ROADMAP update
**Goal**: After Slices 5-6 land, sweep the *entire* repo for any remaining ROUTE references or
  stale headless-as-command conventions, so every vine command reads as human-in-the-loop (the only
  autonomous actor is the `vine-coder` agent), and reconcile the cycle in ROADMAP.md.
**Depends on**: Slices 1-6 (sweep is meaningful only once the new model and retirements are in place).
**Files likely touched**: all eleven `commands/vine/*.md`, `.claude/commands/*.md`,
  `.vine/context/*.md`, `references/STATE.md`, `README.md`, `CLAUDE.md`, `ROADMAP.md`.
**Acceptance criteria**:
  - `grep -rniE "route|headless|head gate|headless-reentry" commands/ .claude/commands/ references/
    .vine/context/ README.md CLAUDE.md` returns only intended hits — the migration note, the
    NAVIGATION.md `**Route**` *field* if it's deliberately kept (see below), and `vine-coder`'s own
    recipe — with no command implying a human-shaped command is run headlessly.
  - **Decide the `**Route**` field's fate explicitly:** ROUTE.md the *artifact* retires, but the
    per-slice `**Route**` field in NAVIGATION.md (and its journal-schema rules in STATE.md) may stay
    as the marker `vine-coder` writes to flag an autonomously-produced entry for `vine-reviewer`.
    Keep-or-retire is a conscious call recorded in the journal — don't let the ROUTE.md sweep rip out
    a still-useful field by accident.
  - ROADMAP.md cycle 3 reflects the reframe: scope is "role-recipe autonomy (vine-coder/vine-reviewer)
    + ROUTE retirement," not "cross-actor live state model." Note what dissolved and why (link this
    SPEC / EVOLUTION).
  - `/trellis` passes; the workflow map in `.vine/context/shared.md` reads coherently for a
    human-only command set.
**Complexity signal**: Medium — mechanical grep-and-reconcile, but wide; the judgment calls are the
  `**Route**` field fate and the ROADMAP narrative.

### Tech Debt Integration

- **Address now (ride-along, Slice 4)**: the hardcoded `claude` attribution (factual-wrongness for
  any non-Claude actor) and evolve.md:524's silent PAUSE note-loss (a real single-actor bug). Both
  were named in CONTEXT.md's debt catalog and are cheap here.
- **Defer (consciously)**:
  - **PAUSE.md / `.vine/ACTIVE` deletion-site sprawl** (5+5 uncoordinated triggers). This was
    cross-actor-motivated; with cross-actor state dissolved, the existing idempotent-delete design
    is tolerable. Not worth the churn this cycle. (Backlog.)
  - **journal-check.sh** — cross-machine rework and the #99 silence question are out of scope; the
    agent path doesn't depend on the hook, and the human path works. (Backlog / #99.)
- **Accept (no new debt taken knowingly)**: retiring ROUTE one cycle after shipping it is a
  deliberate reversal, not debt — the migration note discharges the downstream obligation.

### Backlog Updates

- **Defer**: PAUSE/ACTIVE deletion-site consolidation — re-file as standalone cleanup, decoupled from
  cross-actor framing.
- **Defer**: journal-check.sh value/rework — fold into [#99](https://github.com/moduloMoments/VINE/issues/99).
- **New**: `agents/vine-reviewer.md` symmetric to the `pr-review` dogfood — consider a `vine-coder`
  dogfood contributor tool (a `pr-review` mirror) if the recipe needs the same cold-spawn validation
  loop. Conditional, post-cycle.
- **Flag for #55**: this cycle leaves PROFILE.md structurally untouched, so #55's depth+growth
  reshape inherits a clean file — confirm the boundary holds when #55 starts.

### Dependencies & Risks

- **Reversal of recently-shipped work.** ROUTE.md and navigate's headless route shipped one cycle
  ago (the routing-foundation cycle; ROUTE is the State Artifact Addition Checklist's worked
  example). Retiring them is the intended call here, not an accident — but Slice 5/6 must be
  complete across every surface or `/trellis` Check 10 / Check A will flag drift. Downstream repos
  with existing ROUTE.md files need the migration note.
- **Decision Delegation is policy-class.** Slice 6 touches a `class: policy` section in shared.md;
  the reframe must keep it coherent (its headless semantics relocate to vine-coder) without
  weakening the governance it carries.
- **No runtime to test against.** These are markdown changes; validation is running the new agents
  on a real ticket/PR. Budget a dogfood pass (spawn `vine-coder` on a throwaway ticket, `vine-reviewer`
  on a real PR) before evolve signs off.
- **Platform facts the recipes depend on.** `AskUserQuestion` is unavailable to sub-agents, so the
  recipes must never reach for it; a non-fork sub-agent loads CLAUDE.md but not the session
  conversation, so anything a recipe needs must be in the ticket/SPEC/artifacts (not assumed from
  context). For background/headless invocation, permission prompts are auto-denied — so the ticket
  trigger must grant `vine-coder` a workable `permissionMode` (e.g. `acceptEdits`); that's
  platform-invocation wiring, noted for navigate, not authored in the recipe.
- **Cross-reference fragility.** navigate and STATE.md carry `step N` cross-references; prefer
  neutralizing removed sections over renumbering (CLAUDE.md authoring convention) to avoid rippling
  drift.
- **Multi-PR coordination.** Two phase groups map cleanly to two PRs (additive first, retirement
  second) so each lands a coherent repo state — see PROJECT-MAP.md if multi-PR tracking is enabled.
