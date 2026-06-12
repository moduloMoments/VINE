# Feature Spec: Verification Boundary (navigate ↔ evolve reconciliation)
## Date: 2026-06-11
## Built on: CONTEXT.md (2026-06-11)
## Decisions made by: Rob Bruhn

### Problem Statement

The verification checklist VINE runs at phase-group boundaries (navigate) and at cycle end
(evolve) is expressed independently in three places: navigate.md step 8's inline a–d checks,
evolve.md's delegation prompt to the `vine-verification` agent, and the agent's own
feature-verification mode. The only sync mechanism is two hand-maintained prose
cross-references — and both have already drifted (navigate cites an a–d structure evolve
doesn't have; evolve points at "step 9," now step 8). The coverage boundary between the two
tiers is documented nowhere. Source: [#69](https://github.com/moduloMoments/VINE/issues/69).

### Approach

**Agent as single source.** `agents/vine-verification.md` becomes the authoritative
checklist — it ships via create-vine, which STATE.md does not, so it's the only viable
shipped home for a checklist both commands depend on. Navigate and evolve reference the
agent's named checks with their tier scoping instead of restating them.

**Navigate delegates.** The inline-vs-delegated split was a confirmed historical accident,
and navigate already delegates per-slice verification to this same agent. Navigate's
phase-group check becomes a delegation to the agent's feature mode scoped to the phase
group. Accepted costs: one agent invocation per phase-group boundary (token/latency), and
the agent is sonnet-pinned.

**Scope parameter completes the single source.** The agent's feature-verification mode
gains a caller-specified scope:

- **Phase-group scope** (navigate): base checks — full test suite, cross-slice integration
  within the scope, acceptance criteria for the scoped slices, test coverage.
- **Full-feature scope** (evolve): base checks across the whole feature, **plus**
  cross-cutting concerns (error handling paths, edge cases spanning slices, performance of
  the combined changes) — these move out of evolve's delegation prompt into the mode
  definition so the single source is complete.

**The boundary is documented in STATE.md** as a verification-tier contract note — third in
the #66 contract-note family (deviation-closure, AC-traceability). It states which tier
checks what, that the asymmetry is intentional, and that the rule lives in the agent/commands
while the note keeps contributors in sync. Evolve-only scope (not agent-runnable, stays in
evolve.md): AC traceability, spec deviation review, follow-up triage, handoff prep, and
multi-PR prior-PR review + CI status via `gh`.

**Mechanical teeth, contributor-side only.** `/trellis` and `trellis-check.sh` gain a
cross-reference anchor check: the contract-note pointers and referenced section anchors must
resolve. Both files are contributor tooling (`.claude/commands/`, `.vine/scripts/`) — nothing
new ships via create-vine. This was an explicit condition of the decision.

**#54 constraint honored.** Everything stays at the level of *named checks*. Invocation
discovery (which commands to run) is untouched — that's #54's machine-readable validation
contract (cycle 4). The agent's existing "Finding Project Tools" discovery stands, with one
ride-along fix: `.vine/context/evolve.md` joins its discovery list (it serves evolve's
delegation but currently only reads navigate.md/pair.md).

**Key decisions and rationale:**

| Decision | Choice | Why |
|---|---|---|
| Reconciliation shape | Agent file as single source + STATE.md contract note | Agent ships; STATE.md doesn't — only shipped surface both commands can depend on. Collapses 3 checklists to 1. |
| Who runs navigate's tier | Delegate to vine-verification (phase-group scope) | Inline was an accident; per-slice checks already delegate; consistency + collapses the inline restatement. |
| Trellis check | Add anchor check, contributor-side only | Catches the exact drift class already observed (stale "step 9"); acceptable because nothing ships. |
| Agent fallback gap | Ride along | One-line edit to a file the feature already touches. |
| Cross-cutting concerns | Move into agent mode as full-feature-scope checks | Single source must be complete; the agent already runs them today via evolve's prompt. |
| PR strategy | Single PR, no phase grouping | Five tightly coupled prose slices; intermediate PRs would ship half-migrated states. |

### Acceptance Criteria

- The base verification checklist (full suite, cross-slice integration, acceptance criteria,
  test coverage) is defined in exactly one shipped surface: the agent's feature-verification
  mode. Neither navigate.md nor evolve.md restates the checks.
- The agent's feature mode takes a caller-specified scope (phase group / full feature);
  full-feature scope adds the cross-cutting concerns checks.
- Navigate step 8 delegates phase-group verification to the agent, preserving the
  fix-in-session rule and the per-slice AskUserQuestion test-coverage triage (now driven by
  the agent's Test Coverage report section).
- Evolve's Cross-Slice Integration Check references the agent's feature mode at full-feature
  scope; evolve-only scope (AC traceability, deviations, follow-ups, handoff, prior-PR/CI)
  is unchanged and enumerated in the contract note.
- Both stale cross-reference blockquotes are gone; their replacements point at the STATE.md
  verification-tier contract note.
- The new STATE.md section carries the `<!-- required -->` / `<!-- optional -->` marker
  convention (or matches the #66 contract-note shape if those notes carry no marker — match
  whichever the existing family uses).
- The agent's "Finding Project Tools" discovery list includes `.vine/context/evolve.md`.
- The anchor check exists only in `.claude/commands/trellis.md` and
  `.vine/scripts/trellis-check.sh`; `create-vine`'s shipped file set is unchanged.
- `/trellis` (and `trellis-check.sh`) pass green on the full change.

### Work Slices

### Slice 1: Agent as authoritative checklist
**Goal**: Restructure `agents/vine-verification.md` feature-verification mode into the named,
scoped checklist: base checks named, scope parameter (phase group / full feature)
documented, cross-cutting concerns absorbed as full-feature-scope checks. Add
`.vine/context/evolve.md` to the Finding Project Tools list.
**Depends on**: Nothing.
**Files likely touched**: `agents/vine-verification.md`
**Acceptance criteria**: Mode names each base check; scope parameter described with what
each scope includes; cross-cutting concerns listed under full-feature scope; evolve.md in
discovery list; output format still accommodates both scopes.
**Complexity signal**: Medium — the names chosen here are what every other slice references.

### Slice 2: Navigate delegates phase-group verification
**Goal**: Replace navigate.md step 8 item 1's inline a–d checks with a delegation to
vine-verification (feature mode, phase-group scope), passing the phase group's changed
files, slice ACs, and a pointer to overlay validation commands. Keep: fix-in-session rule,
AskUserQuestion coverage triage fed by the agent's report, the "lighter than evolve"
exclusion statement. Replace the cross-ref blockquote with a pointer to the STATE.md
contract note.
**Depends on**: Slice 1 (check names, scope vocabulary).
**Files likely touched**: `commands/vine/navigate.md`
**Acceptance criteria**: No restated checklist in step 8; delegation names the agent, mode,
and scope; triage and fix-in-session flows intact; tracker-update items 2–5 of step 8
untouched; contract-note pointer in place.
**Complexity signal**: Medium — behavioral change to a core command; wording must keep the
PR-shippable bar explicit.

### Slice 3: Evolve slims its delegation
**Goal**: Rewrite evolve.md's Cross-Slice Integration Check to invoke the agent's feature
mode at full-feature scope by name instead of restating checks. Evolve-only content stays
(multi-PR `gh` review/CI block, trust-per-slice framing, AC traceability section). Replace
the stale "step 9" cross-ref with a contract-note pointer.
**Depends on**: Slice 1.
**Files likely touched**: `commands/vine/evolve.md`
**Acceptance criteria**: Delegation references named mode + scope, no restated base checks;
cross-cutting concerns no longer listed in the prompt (they live in the agent); evolve-only
sections unchanged; stale reference gone.
**Complexity signal**: Low-Medium — mostly deletion and a pointer.

### Slice 4: STATE.md verification-tier contract note
**Goal**: Add the verification-tier contract note to `references/STATE.md` alongside the
deviation-closure and AC-traceability notes: the two tiers, what each covers, the
intentional asymmetry, where the rule lives (agent + commands), and that the note exists to
keep contributors in sync.
**Depends on**: Slices 1–3 (documents the landed shape).
**Files likely touched**: `references/STATE.md`
**Acceptance criteria**: Note matches the #66 family shape; heading-marker convention
respected; enumerates evolve-only scope; names the agent mode and both scopes.
**Complexity signal**: Low.

### Slice 5: Trellis cross-reference anchor check
**Goal**: Add a check to `/trellis` and `trellis-check.sh` verifying that the
cross-reference pointers introduced by this feature resolve: the contract-note section
exists in STATE.md, the agent mode/scope names referenced by navigate.md and evolve.md exist
in the agent file. Data-driven (small list of file → expected-anchor pairs), in the #70
scriptable style.
**Depends on**: Slices 1–4 (anchors must exist to be checked).
**Files likely touched**: `.claude/commands/trellis.md`, `.vine/scripts/trellis-check.sh`
**Acceptance criteria**: Check fails when an anchor is renamed/removed and passes on the
landed change; lives only in contributor-side files; trellis doc lists the new check
alongside 1–9/A–D.
**Complexity signal**: Medium — script + command doc must agree, and the check should fail
loudly but not be brittle to harmless rewording.

### Tech Debt Integration

- **Three-way checklist duplication** — addressed now; it is the feature.
- **Stale "step 9" cross-ref in evolve.md** — addressed now; dies in Slice 3.
- **Agent discovery fallback missing evolve.md** — addressed now; rides along in Slice 1.
- **Conscious new debt**: the anchor check carries a small maintained list of expected
  anchors in `trellis-check.sh`. Accepted — it is the mechanical tooth that catches the
  drift class this feature exists to fix, and it fails loudly when stale.

### Backlog Updates

- [#69](https://github.com/moduloMoments/VINE/issues/69) closes with this cycle.
- [#54](https://github.com/moduloMoments/VINE/issues/54) (cycle 4) gains a cleaner
  substrate: one checklist surface to wire its YAML validation contract into instead of
  three. No scope change to #54; note the composition when it starts.
- No new backlog items.

### Dependencies & Risks

- **#54 composition**: this feature must not invent a command-listing format. Mitigation:
  everything stays at named-check level; honored in the approach and ACs.
- **Navigate token/latency profile changes**: each phase-group boundary now spawns a
  sonnet-pinned agent run. Accepted in design; if it proves heavy in dogfooding, the scope
  parameter makes it easy to revisit who calls the agent without touching the checklist.
- **Anchor-check brittleness**: renaming a section legitimately (good rewording) trips the
  check. That is the intended behavior — the fix is updating the pair list, which is the
  sync act the old prose cross-refs asked for but couldn't enforce.
- **README drift**: README may describe navigate's phase-group verification as inline.
  Slice 2 implementer should grep README for the old description and adjust if present
  (small, in-slice).
