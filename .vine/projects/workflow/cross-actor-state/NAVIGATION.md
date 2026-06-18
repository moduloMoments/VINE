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
- **Commit**: 27f50d4
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

### Slice 3: Auto-agent ticket convention — Complete
- **Commit**: f58a128
- **Route**: interactive — `mechanism: n/a`
- **Actor**: human
- **Gear**: free-climb
- **Approach taken**: Defined the convention in `.vine/context/shared.md` as a new top-level
  `## Autonomous Delegation — the vine-coder ticket` section (cross-phase routing knowledge — per the
  Knowledge Boundary rule, routing lives in shared.md, not as a STATE.md artifact). It states the
  eligibility judgment (bounded + independent + ACs + validation contract), the ticket payload
  (scope, SPEC pointer, constraints, dispatch to vine-coder), and that the PR review is the leash.
  Added a one-line routing hint to State-Based Suggestions, and a `🎫 Auto-agent ticket` emission to
  inquire's completion block that references the shared.md convention. Wrote the section to stand on
  its own after Phase 2 (no ROUTE.md dependency — it says "no separate per-feature route artifact is
  needed," which stays true after retirement).
- **Deviations from spec**: None. Spec listed `references/STATE.md` and `commands/vine/navigate.md`
  as *possibly* touched; consciously left both alone — the AC says keep it a convention not a heavy
  artifact (so no STATE.md format), and navigate's ticket-handoff path folds more naturally into
  Slice 6's navigate rework than touching navigate twice.
- **Validation**: pass — `trellis-check.sh` 11/11, cross-reference anchors resolve (8 pairs), stamp
  refreshed for the inquire.md command edit; new shared.md section confirmed free of ROUTE.md
  coupling.
- **Decisions made during implementation**:
  - Home the convention in shared.md, not STATE.md: the AC says "convention, not a heavy new
    artifact," and the Knowledge Boundary rule routes cross-phase routing to shared.md (decided by:
    claude) [confidence: high]
  - Leave inquire's existing route-preview block in place (Phase 1 is additive; Slice 5 retires it)
    and write the new ticket block to be self-standing so it survives that removal (decided by:
    claude) [confidence: high]
  - Don't touch navigate.md this slice — its ticket-handoff path belongs with Slice 6's
    interactive-only rework, avoiding a double-touch of the most cross-referenced command (decided
    by: claude) [confidence: high]
- **Acceptance criteria**:
  - [x] Documented ticket convention (scope + SPEC pointer + constraints + names vine-coder)
  - [x] inquire's completion block can emit it for autonomous-eligible scope
  - [x] Glossed per Reference Legibility (vine-coder, vine-reviewer, `## Validation` all glossed in
    place — reads without dereferencing)
  - [x] Kept a convention, not a heavy new artifact (no new STATE.md artifact)
- **Learnings**:
  - Claude → Engineer: writing the convention ROUTE-free (eligibility as a delegation-time judgment,
    not a stored gate) is what lets Phase 2 retire ROUTE without rewriting this section — the
    additive slice already lands in its post-retirement shape.

### Slice 4: De-hardcode attribution + fix evolve.md PAUSE delete — Complete
- **Commit**: cb59d39
- **Route**: interactive — `mechanism: n/a`
- **Actor**: human
- **Gear**: free-climb
- **Approach taken**: (a) Replaced the hardcoded `claude` in the **autonomous** attribution at all
  three sites — `commands/vine/navigate.md:387`, `references/STATE.md:195`, `references/STATE.md:224`
  — with `[actor]`, the autonomous actor's role identifier, glossed `e.g. vine-coder` in the STATE
  prose rule with "never a model name." Left the interactive decision-log `(decided by: engineer |
  claude)` lines untouched (navigate.md:385, STATE.md:194/225) — they're a legitimate choice list,
  and `grep "decided by: claude"` doesn't match them, so the feature grep is clean. (b) Changed
  evolve's resolve-time PAUSE delete (evolve.md ~523) from silent to surface-then-delete: a PAUSE.md
  surviving session-start consumption appeared *after* evolve began, so its notes aren't stale —
  surface then delete, matching the rule the other four triggers follow. Aligned STATE.md:292's
  backstop description so the contract doesn't drift from the command.
- **Deviations from spec**: Minor in-spirit addition — also updated `references/STATE.md:292` (not in
  the spec's listed lines) so the PAUSE-lifecycle description matches the corrected evolve behavior;
  leaving it would have drifted the contract from the command.
- **Validation**: pass — `grep "decided by: claude"` clean; interactive log preserved (3 sites);
  three `[actor]` sites confirmed; no `silently delete` left in evolve.md; `trellis-check.sh` 11/11,
  anchors resolve (8 pairs), stamp refreshed for the navigate.md + evolve.md command edits.
- **Decisions made during implementation**:
  - Use `[actor]` (role identifier, glossed `e.g. vine-coder`) rather than the literal `vine-coder`
    in the generic STATE/navigate templates — the schema stays actor-agnostic while the agent recipe
    keeps the concrete name (decided by: claude) [confidence: high]
  - Treat the feature-level "no `decided by: claude`" AC as satisfied by fixing the three autonomous
    sites only: the interactive `engineer | claude` lines aren't matched by that grep and name the
    interactive pair legitimately, so de-hardcoding them is out of scope (decided by: claude)
    [confidence: high] — intent-over-letter resolution
  - Fix evolve's backstop toward surface-then-delete (not "prove redundant + remove"): the rare
    surviving PAUSE.md carries non-stale notes, so consistency with the other triggers is the
    correct behavior, not deletion (decided by: claude) [confidence: high]
- **Acceptance criteria**:
  - [x] Autonomous-attribution wording references the role/route, not `claude`, at all three sites
  - [x] Readers still default a missing `**Actor**` to `human` (STATE.md unchanged on that point)
  - [x] evolve's resolve-time PAUSE delete surfaces notes before deleting, matching surface-then-delete
- **Learnings**:
  - Claude → Engineer: the feature grep `decided by: claude` is sharper than it looks — it only
    matches the autonomous form, so the interactive `engineer | claude` log is safe by construction.
    The two attribution layers were already cleanly separable.

## Phase 2: Retire old machinery + repo-wide alignment (Slices 5-7)

### Slice 5: Retire ROUTE.md across all surfaces — Complete
- **Started**: 2026-06-17 22:30
- **Commit**: 4cb1921
- **Route**: interactive — `mechanism: n/a`
- **Actor**: human
- **Gear**: free-climb
- **Approach taken**: Retired ROUTE.md *the artifact* from the contract/documentation surfaces, leaving
  the headless-*model* prose (navigate's gate, README's "Agents running VINE" narrative) for Slices 6–7
  where they become coherent. (a) `references/STATE.md`: replaced the 67-line `### ROUTE.md` template
  section with a short **retirement + migration note** (chain is now CONTEXT→SPEC→NAVIGATION→EVOLUTION;
  downstream ROUTE.md files are inert and can be deleted); removed the ROUTE row from the
  Source-of-Truth and Committing-Artifacts tables and the `### Route` table + its lifecycle/design-
  constraint/derived-view mentions from the PROJECT-MAP template; scrubbed ROUTE.md cross-refs out of
  the Headless-Handoff template ("authorized by ./ROUTE.md" → "the ticket") and the #90 journal-schema
  rules (dropped "same vocabulary as ROUTE.md and the PROJECT-MAP Route table"). The per-slice `**Route**`
  *field* itself is **kept** — its keep/retire fate is Slice 7's explicit call. (b) `.claude/commands/
  trellis.md`: removed ROUTE from the Step 5a parse list, Step 5b discovery glob, and Check A applies-to;
  **deleted Check E** (ROUTE Verdict shape) and renumbered the old Check F (Validation block) → Check E
  for a clean A–E sequence, fixing all references; removed the Route column + ROUTE.md row from the
  Step 7 table. The NAVIGATION `**Route**` field shape check (Check D) is kept, with its ROUTE/PROJECT-MAP
  cross-refs scrubbed. (c) `CLAUDE.md`: dropped the ROUTE.md sentence from the State Artifact Chain line.
  (d) `commands/vine/inquire.md`: removed the 🧭 Route-preview completion block (the 🎫 Auto-agent ticket
  block stays — the replacement model). (e) `.vine/context/shared.md`: made the State Artifact Addition
  Checklist's worked example bidirectional (ROUTE's addition then one-cycle-later removal); dropped the
  stale "like Check E" shape-check reference. (f) `README.md`: removed the State Artifacts ROUTE row and
  swapped the knowledge-tree example off the route record.
- **Deviations from spec**: Minor in-flight scoping refinement — deferred README's `references/STATE.md`
  closing pointer (the "ROUTE.md format" mention) to Slice 7 alongside the rest of the "Agents running
  VINE" section, rather than scrubbing it here as the preview planned. Keeping that section intact mid-flight
  reads more coherently than a one-line scrub; it's rewritten as one unit once navigate is interactive-only.
- **Validation**: pass — `trellis-check.sh` 11/11 commands, cross-reference anchors resolve (8 pairs),
  stamp `status: pass`; ROUTE-token grep confirms intended end-state (STATE retirement note + kept `**Route**`
  field; CLAUDE/inquire clean; navigate + README "Agents running VINE" deferred to 6/7). Pre-existing
  `.vine/hooks/` legacy warnings in init.md are unrelated.
- **Decisions made during implementation**:
  - Keep the per-slice `**Route**` *field* (and Check D) while retiring the ROUTE.md *artifact* — the field
    is the marker `vine-coder` writes for `vine-reviewer`; its keep/retire fate is Slice 7's explicit call,
    so Slice 5 only scrubs ROUTE.md cross-references from it (decided by: claude) [confidence: high]
  - Renumber trellis Check F→E rather than leave an A,B,C,D,F gap — it's the linter itself, a gap reads as a
    bug; the ripple was 5 internal references, all fixed (decided by: claude) [confidence: high]
  - Defer the README "Agents running VINE" section rewrite (gate-record paragraph + STATE.md pointer) to
    Slice 7 so it's rewritten once, coherently, after navigate is interactive-only — rather than a piecemeal
    scrub that leaves the section dangling (decided by: claude) [confidence: high]
  - Defer the knowledge-layer supersession record (a new ADR superseding `2026-06-16-route-md-headless-
    eligibility-gate.md`, flipping its Status to Superseded) to **evolve**, where the convention homes
    knowledge-record writing — noted in handoff (decided by: claude) [confidence: high]
- **Acceptance criteria**:
  - [x] ROUTE.md retired from the artifact chain with a documented retirement/migration note (STATE.md)
  - [x] `/trellis` passes (11/11, anchors resolve, stamp green) after the slice
  - [x] Artifact chain reads CONTEXT → SPEC → NAVIGATION → EVOLUTION (STATE.md + CLAUDE.md) with no ROUTE leg
  - [~] `grep -rn ROUTE` clean on Slice-5-owned surfaces; navigate.md (Slice 6) and README's "Agents running
    VINE" section (Slice 7) still carry ROUTE by design — the feature-level grep-clean is the evolve-time gate
- **Learnings**:
  - Claude → Engineer: the trellis gate stamp covers only command Checks 1–10 (it never reads STATE.md
    templates or ROUTE artifacts — Steps 5–7 are session-judged), so retiring ROUTE from STATE.md could never
    break the commit gate. That decoupling is what let Slice 5 land green while navigate.md still carries ROUTE.
  - Claude → Engineer: the three slices all touch STATE.md, but the cut lines cleanly — Slice 5 owns the ROUTE
    *artifact* (template, chain, tables), Slice 6 the headless *model*, Slice 7 the `**Route**` *field* fate.
    Scrubbing tokens without ripping out the kept field is the discipline that keeps them separable.

### Slice 6: navigate → interactive-only — Complete
- **Started**: 2026-06-17 22:58
- **Commit**: pending
- **Route**: interactive — `mechanism: n/a`
- **Actor**: human
- **Gear**: free-climb
- **Approach taken**: Made navigate human-only and swept the headless-as-command machinery repo-wide.
  (a) `commands/vine/navigate.md`: deleted the two unnumbered headless sections — `### Route the Work —
  Eligibility Gate` (the navigate-head routing gate that wrote ROUTE.md) and `### Running Headless —
  Decision Protocol & Handoff` (lines 137–252, by range — both unnumbered, so no `step N` ripple). Trimmed
  navigate's slice-entry journal template to its interactive subset — removed the headless-only `**Route**`,
  `**Actor**`, and `**Decisions Taken Autonomously**` fields (kept `**Gear**`), and reframed the surrounding
  prose so navigate writes the human-driven journal shape and points at `references/STATE.md` for the full
  schema (whose `**Route**`-field fate is Slice 7's call — kept the pointer neutral). (b) **Full
  decision-class sweep** (engineer's call: vine-coder doesn't run the commands, so every command reads
  human-triggered-only): removed all 36 `<!-- decision-class: … -->` tags across 8 commands (navigate,
  inquire, evolve, verify, resume, pause, pair, init) via a two-pass perl (delete standalone-tag lines;
  strip inline tags, collapsing surrounding spaces) — verified each inline removal preserved the sentence.
  (c) `.vine/context/shared.md`: rewrote the `class: policy` **Decision Delegation** section — the autonomous
  actor is now `vine-coder` applying the two classes *by judgment* (not a phase running headless reading
  per-site command tags); fixed the dangling "handoff block in navigate.md" pointer → the Headless Handoff
  vine-coder writes to NAVIGATION.md (per STATE.md; the leash is the PR review); preserved policy-class, the
  #55 repo-override path, both class definitions, and the ambiguity→human-required default.
- **Deviations from spec**: Scope expansion (engineer-directed). The spec scoped Slice 6's tag work to
  navigate ("remove or neutralize their headless purpose in navigate"); the engineer asked for the full
  repo-wide sweep here ("ensure the commands are given the full sweep and treat them as only triggered by a
  human"), so all 8 commands' tags were removed in this slice rather than splitting navigate (6) from the
  rest (7). Slice 7 now verifies the grep + does ROADMAP + the `**Route**`-field decision.
- **Validation**: pass — `trellis-check.sh` 11/11 commands, cross-reference anchors resolve (8 pairs), stamp
  `status: pass`; navigate residual `headless` grep is one intentional line ("navigate never runs
  unattended"); shared.md residual is the intentional "Headless Handoff" block reference; no dangling
  pointers to the removed sections; steps 1–8 sequential and STATE.md `step 4c/6/8` cross-refs resolve.
  Pre-existing `.vine/hooks/` warnings in init.md unrelated.
- **Decisions made during implementation**:
  - Full decision-class sweep across all 8 commands, not navigate-only — the engineer's call, grounded in
    "vine-coder doesn't (and shouldn't) execute command files," so every per-site tag is vestigial, not just
    navigate's (decided by: engineer) [confidence: high]
  - Delete the two headless sections by line range (sed 137,252d) rather than reproducing 115 lines of exact
    old_string — lower risk after confirming the exact unnumbered-section boundaries (decided by: claude)
    [confidence: high]
  - Trim navigate's journal template to the interactive subset but keep the STATE.md pointer neutral about the
    `**Route**`/`**Actor**` field fate — navigate (human) legitimately omits them regardless of whether Slice 7
    keeps them in the schema, so this doesn't pre-empt that decision (decided by: claude) [confidence: high]
  - Reframe Decision Delegation as judgment-applied governance (vine-coder classifies decisions) rather than a
    per-site command roster — the roster framing died with the tags; kept the section policy-class and the #55
    repo-override intact so governance isn't weakened (decided by: claude) [confidence: high]
- **Acceptance criteria**:
  - [x] navigate is interactive-only — no ROUTE references, no headless-execution prose (the two sections gone)
  - [x] Decision Delegation policy reads coherently against the new model (vine-coder applies the classes)
  - [x] `/trellis` passes (11/11, anchors resolve, stamp green)
  - [x] STATE.md `step N` cross-references stay intact (removed sections were unnumbered — no renumbering)
  - [x] Every command reads as human-triggered-only (all 36 decision-class tags removed)
- **Engineer feedback incorporated**: Took the decision-class sweep repo-wide (all 8 commands) on the
  engineer's "full sweep / human-triggered-only" directive, rather than the narrower navigate-only spec scope.
- **Learnings**:
  - Engineer → Claude: the reframe's logical end is that *no* command runs headless, so per-site decision-class
    tags are universally dead, not just navigate's — sweep them all and let vine-coder carry the semantics.
  - Claude → Engineer: the two headless sections were unnumbered by design (the CLAUDE.md authoring convention),
    which is exactly what let them be excised by line-range with zero `step N` cross-reference fallout.
  - Deferred to Slice 7 (noted): CLAUDE.md:31 still cites "navigate's head-only routing gate" as an unnumbered-
    section example (now stale); STATE.md:182's Headless Handoff contract still says "vine:navigate's headless
    decision protocol writes it" (→ vine-coder); the `**Route**`/`**Actor**`/Headless-Handoff schema fields and
    README's "Agents running VINE" section remain for the sweep + the explicit `**Route**`-field decision.

### Remaining Work
- **Incomplete slices**: Phase 1 (Slices 1–4) complete and verified. Phase 2 (Slices 5–7) not
  started — Retire ROUTE.md across all surfaces (Slice 5), navigate → interactive-only (Slice 6),
  repo-wide alignment sweep + ROADMAP update (Slice 7). Phase 2 is its own session and PR.
- **Blockers encountered**: None.
- **Handoff context for the Phase 2 session**:
  - The new model is fully stood up and additive: `vine-coder` + `vine-reviewer` agents exist, the
    Autonomous Delegation ticket convention is in shared.md, ROUTE.md still exists but the new agents
    don't consume it. Phase 2 removes the old machinery.
  - **Known ROUTE references already located** (Slice 5/7 targets), beyond the spec's listed files:
    README.md still carries the ROUTE "gate record" paragraph (~387–394) and the closing STATE.md
    ROUTE pointer (~406); these were deliberately left for the retirement PR (Phase 1 is additive).
  - **Slice 4 already de-hardcoded** the autonomous attribution to `[actor]` and added the
    role-not-model gloss in STATE.md — Slice 6's Decision Delegation reframe inherits clean wording.
  - **`**Route**` field fate (Slice 7 explicit call):** the inquire route-preview block (inquire.md
    ~341–347) is still present and ROUTE-coupled; Slice 5 retires it. The new `🎫 Auto-agent ticket`
    block was written self-standing so it survives that removal.
  - **Rebase note:** `origin/main` advanced by #112 (a ROADMAP doc reconciliation) after this branch
    diverged. No Phase 1 file overlapped, but Slice 7 edits ROADMAP.md — rebase onto fresh main
    before that slice to avoid a conflict.
  - Run `/clear` before the Phase 2 session; re-invoke `/vine:navigate workflow/cross-actor-state` —
    it auto-resumes at Slice 5.
