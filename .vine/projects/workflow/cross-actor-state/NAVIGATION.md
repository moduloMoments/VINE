# Navigation Log: Cross-actor state — the role-recipe reframe
## Date: 2026-06-17

### Slice 1: vine-coder agent definition — Complete
- **Commit**: 45b8a33
- **Route**: interactive — `mechanism: n/a`
- **Actor**: human
- **Gear**: free-climb
- **Approach taken**: Created `agents/vine-coder.md` (auto-mirrored into `.claude/agents/` via the
  existing symlink), modeled on the two shipped agents' frontmatter style. The body absorbs four
  things previously scattered across navigate + ROUTE: (1) orientation order (ticket → SPEC.md →
  feature artifact dir); (2) a self-derived touched-file leash (SPEC's *Files likely touched* +
  requirement-implied files; out-of-leash edits escalate) replacing ROUTE's allowlist/blast-radius;
  (3) the execute loop — per-slice journal sync against the STATE.md schema, run `## Validation`,
  per-slice commit with AC attribution, one PR; (4) decision semantics — `default-able` →
  take-and-log, `human-required` → stop-and-surface, never `AskUserQuestion`. Added an
  Operating-Context block stating the four load-bearing platform facts (no AskUserQuestion, fresh
  isolated context, only final message returns, no nested Agent / resolve repo root via
  `git rev-parse`), the ticket-is-authorization framing, the Headless Handoff shape, and a
  structured final-message contract.
- **Deviations from spec**: None.
- **Validation**: pass — `trellis-check.sh` 11/11 commands pass, cross-reference anchors resolve;
  vine-coder.md frontmatter parses with all required keys. (Pre-existing `.vine/hooks/` legacy
  warnings are unrelated to this slice.)
- **Decisions made during implementation**:
  - Model `opus` (not `sonnet` like the two existing read-only agents): vine-coder does real
    unattended implementation, the highest-stakes role, so the strongest model fits (decided by:
    engineer) [confidence: high]
  - Omit `isolation: worktree` from frontmatter, leaving branch mechanics to the ticket trigger at
    invocation time so the recipe stays about behavior, not vehicle (decided by: engineer)
    [confidence: high]
  - Attribute autonomous decisions to the role (`vine-coder`), not `claude`, anticipating Slice 4's
    de-hardcoding so the recipe ships consistent with where the cycle lands (decided by: claude)
    [confidence: high]
  - vine-coder's handoff references **the ticket** as its authorization, not ROUTE.md — the new
    model doesn't consume ROUTE even while ROUTE still exists this phase (decided by: claude)
    [confidence: high]
- **Acceptance criteria**:
  - [x] Valid frontmatter — `name: vine-coder`, delegation-driving description scoped to explicit
    autonomous-implementation intent (not incidental matching)
  - [x] `tools: Read, Edit, Write, Bash, Grep, Glob` (least-privilege implement-and-commit set)
  - [x] Explicit `model`; no `memory` scope (stateless by design)
  - [x] `isolation: worktree` considered — consciously omitted (left to invocation per engineer)
  - [x] Body: orientation order, implement-within-scope + self-derived touched-file discipline,
    per-slice journal sync, run `## Validation`, per-slice commit with AC, single-PR handoff
  - [x] `default-able` / `human-required` resolved as take-and-log / stop-and-surface; never
    `AskUserQuestion`
  - [x] Structured final-message output (PR link + slices done + escalations)
- **Learnings**:
  - Engineer → Claude: vine-coder warrants opus even though the existing agents default to sonnet —
    model tier should track the stakes of the role (unattended write+commit), not house style.
  - Claude → Engineer: writing the leash as *self-derived* (reasoned blast radius, not a handed
    allowlist) is what lets the ticket stay lightweight — it absorbs ROUTE's discipline as agent
    behavior rather than a pre-committed artifact.

### Slice 2: vine-reviewer agent + retire review.md overlay — Complete
- **Commit**: pending
- **Route**: interactive — `mechanism: n/a`
- **Actor**: human
- **Gear**: free-climb
- **Approach taken**: Ported `.vine/context/review.md` into `agents/vine-reviewer.md` verbatim across
  its four sections (Role + authority boundary, Orientation Order, What to Scrutinize, What to
  Produce), **dropping the ROUTE orientation step** and renumbering the order 1–4. Frontmatter:
  `name: vine-reviewer`, delegation-driving description, `tools: Read, Grep, Glob, Bash` (no
  Edit/Write — the report-only boundary is now platform-enforced). Added a cold-actor/final-message
  note and an explicit statement that the tool set *is* the authority boundary. Deleted the overlay
  (`git rm`). Rewrapped `.claude/commands/pr-review.md`: Step 2 now confirms the agent exists rather
  than loading recipe text; Step 3 spawns the `vine-reviewer` agent type (system prompt = recipe)
  instead of stuffing overlay text into a `general-purpose` subagent; removed the legacy
  `.vine/hooks/review.md` fallback note; retargeted the tool's framing and validation read-out to
  `vine-reviewer`. Fixed README's reviewer paragraph (now links `agents/vine-reviewer.md`, drops the
  ROUTE orientation, notes the tools-enforced boundary) and added `vine-coder`/`vine-reviewer` to the
  agents inventory.
- **Deviations from spec**: None. (Spec named inquire.md/navigate.md as *possibly* touched for the
  ticket convention — that is Slice 3, untouched here.)
- **Validation**: pass — `trellis-check.sh` 11/11, cross-reference anchors resolve; `review.md` grep
  clean across product surfaces (only false positives in `pr-review.md` filename and `preview.md`);
  `route` absent from `agents/vine-reviewer.md`.
- **Decisions made during implementation**:
  - Model `opus` for vine-reviewer (not `sonnet` like the read-only agents): the review is the leash
    on vine-coder's unattended output, so the checker should be at least as strong as what it checks
    (decided by: engineer) [confidence: high]
  - Don't pass `shared.md` to the spawned reviewer: the truest auto-reviewer simulation is the agent
    system prompt + CLAUDE.md + PR pointers only; extra overlay text would contaminate the
    Missing-context-log validation signal (decided by: claude) [confidence: high]
  - Added `vine-coder` to README's agents inventory now (Phase 1 ships it) but left the README ROUTE
    gate-record narrative for Phase 2's retirement sweep — Phase 1 is additive (decided by: claude)
    [confidence: high]
- **Acceptance criteria**:
  - [x] Valid frontmatter — `name: vine-reviewer`, delegation-driving description, `tools: Read,
    Grep, Glob, Bash` (no Edit/Write — boundary mechanically enforced)
  - [x] Body: Role/authority-boundary, Orientation Order (no ROUTE step), What to Scrutinize, What to
    Produce
  - [x] `pr-review` spawns `vine-reviewer` with identical instructions (agent system prompt = recipe)
  - [x] No dangling reference to `.vine/context/review.md` (grep clean)
  - [x] Legacy `.vine/hooks/review.md` fallback note in pr-review reconciled (removed)
- **Engineer feedback incorporated**: Chose opus for the reviewer to match vine-coder's stakes.
- **Learnings**:
  - Engineer → Claude: the reviewer's model should track the coder's — a leash weaker than what it
    restrains is no leash.
  - Claude → Engineer: porting an overlay to an agent makes the authority boundary *mechanical* —
    `tools` without Edit/Write enforces "report only" that prose could only request. This is the
    "mechanical teeth" principle applied to a role.
  - Remaining for Phase 2 (Slice 7): README's ROUTE gate-record paragraph and the STATE.md ROUTE
    pointer near it still describe the route model; they retire with ROUTE.md, not here.
