# Navigation Log: Cross-actor state — the role-recipe reframe
## Date: 2026-06-17

### Slice 1: vine-coder agent definition — Complete
- **Commit**: pending
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
