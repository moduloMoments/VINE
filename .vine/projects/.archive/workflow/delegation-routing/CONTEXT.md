# Feature Context: Delegation-Routing Harness Re-scope (roadmap rewrite)
## Date: 2026-06-11
## Author: Rob Bruhn + Claude

This CONTEXT.md grounds an inquire session that rewrites ROADMAP.md around scope-delegation
routing as the harness's first-class process. It verifies a pre-gathered design brief against
the repo's actual state (issues, commands, packaging, external sources), expands the
single-actor-assumption inventory, and maps the two named open questions to existing
mechanisms. Decisions already made in prior sessions (Path A framing, overlays-as-contract,
composition-not-synchronization) are recorded as constraints, not reopened.

### The Central Thesis (carried, verified compatible)

VINE already routes by trust at two granularities: verify's scope check (full cycle vs.
`vine:pair`) and navigate's per-slice gearing (walk-me-through vs. free-climb). The re-scope
extends that gearing axis past the human-attention boundary:

**walk-me-through → free-climb → hybrid-parallel → headless**

Core loop: **scope → route (per overlay-defined policy) → execute (platform mechanics) →
handoff (artifact contract) → evolve (criteria calibration)**. Everything else in the roadmap
is a supporting subsystem of this loop.

**Boundary discipline (decided, load-bearing):** VINE owns decision criteria, contracts, and
handoff artifacts. The platform owns execution mechanics (subagents, headless invocation,
background tasks, parallelization). VINE never implements an agent runner. Verified against
ROADMAP.md's existing guiding principle — this is a strengthening of language already there
("Loops, gates, enforcement, progress UI, and memory primitives belong to the platform; VINE
consumes them"), not a new rule.

**Path A framing (decided, do not reopen):** routing serves the brownfield human-partnership
moat. The harness optimizes *where human attention is worth spending*. Triple-evolution stays
the differentiator; the human's delegation judgment is one of the three things growing.

### Current State — Repo vs. Brief Drift Findings

The brief was written from a point-in-time read. Verified against live issue bodies and the
working tree on 2026-06-11:

| Brief claim | Verdict | Detail |
|---|---|---|
| #54 is the eligibility-gate foundation | **Partial drift — load-bearing** | #54's body is an *enabler*, not a gate: repo-global YAML validation block in shared.md with **graceful fallback to prose inference when absent** — the opposite of gating. No eligibility predicate exists anywhere, and there is no per-scope contract object to check ("this scope's contract exists" has no referent; the contract is repo-wide). Promoting #54 to foundation requires *reshaping* it: define the predicate, decide global-vs-per-scope, and resolve the gate-vs-fallback contradiction. |
| #53 is the execution half of the pair | Agreement, with a dependency inversion | #53 is genuinely the headless contract (human-required vs. default-able decision classification, per-command Headless Mode, `### Decisions Taken Autonomously` audit block, async ratification via resume/status, code-writing human-gated by default). But its decision machinery leans on **#55's Decision Delegation section** (cycle 5) — promoting #53/#54 to the front inverts that dependency. Either Decision Delegation pulls forward as routing-policy overlay content, or #53 reshapes. |
| #62 specifies something gate-relevant | **Drift — stale** | #62 is CLOSED and was reshaped mid-cycle away from plan-mode integration to gearing↔permission-mode hygiene. Nothing in it relates to eligibility gating. Drop it from the foundation story. |
| #57 is the team-overlay distribution mechanism | Direction supported, **scope expansion required** | The body covers distribution/upgrade hygiene only (plugin.json, own-repo marketplace.json, npx fallback) — it never mentions teams. Anthropic's guidance does support plugins+marketplaces as the anti-tribal-knowledge mechanism (verified quote below), so the promotion is sound, but it rewrites #57's scope, not just its position. |
| #52 team mode → overlay composition reframe | Agreement, much survives | #52 already contains the E2 survival kit: tracked-by-default flip with scaffolded `.vine/.gitignore`, local-only projects under `.vine/projects/.local/`, and **conflict-safe conventions (single-writer per-feature directories, append-only NAVIGATION.md, shared mutable files edited only via evolve's approval flow)**. The reframe relocates team context from a shared.md section to a team layer; the conventions are reusable prior art for hybrid-parallel. |
| #51/#56 distinguish durable knowledge from live state | Agreement | Cleanly. But the live-state half of the distinction is articulated in **#61 (closed)**: "native tasks are the live view (session-scoped), markdown is the durable journal." Cross-actor live execution state is covered by *neither* — it is new issue territory, not a reopen of #61. |
| #46–50 are headless test candidates | Agreement, two caveats | #46–48 are pure mechanical consolidation — ideal first delegations. But all five bodies predate the #58 rename and still say `.vine/hooks/` (a headless agent following them literally touches wrong paths), and #49/#50's proposed descriptions appear to already match the live skills — possibly done without closure. **Freshness pass required before any are assigned as delegation test cases.** |
| Spec-Kit ~90k★ | Stale | 111,358★ as of today. Now skills-based install for Claude Code/Codex; 70+ community extensions. |
| Anthropic blog covers headless/CI patterns | **Drift — do not cite it for that** | The blog has *nothing* on headless mode, CI, background tasks, or permission modes. Verified present: the seven extension points with an explicit adoption ordering, the Stop-hook reflection pattern ("propose CLAUDE.md updates while the context is fresh" — propose, not apply), the plugins/marketplace tribal-knowledge answer, and the obsolescence warning verbatim ("a meaningful configuration review every three to six months"; the Perforce hook example is real). Its config layering is path-hierarchical (root CLAUDE.md → subdirectory files), not org-hierarchical — the org layer exists only implicitly via plugins and committed settings.json. |
| Overlay precedence is "overlay > default, trellis-enforced" | Partial | Trellis (check 6) mechanically enforces **load order** (overlays before profile), not precedence. The precedence sentence ("Overlay instructions take precedence over defaults when they conflict") is prose, and **inconsistently present**: verify/inquire/navigate/pair carry it; evolve/status/pause/resume/optimize don't. That inconsistency is itself a small drift finding worth fixing in whatever cycle touches the loading blocks. |

One process fact the brief didn't have: **this repo already runs E2-shaped** — its own
.gitignore tracks `.vine/context/` and `.vine/projects/` (PAUSE.md and PROFILE.md excluded).
Artifact-tracking compatibility is partially dogfooded; the *concurrent-actors* dimension is
not (solo maintainer).

### Codebase Landscape

- **Product surface:** 11 commands in `commands/vine/`, 2 agents in `agents/`
  (vine-codebase-explorer, vine-verification), `references/STATE.md` artifact contracts.
- **Ships via create-vine** (`package.json` files + `bin/cli.js` allowlist): the 11 commands,
  both agents, and `.vine/scripts/journal-check.sh` (project installs only — global installs
  get no scaffold scripts). **STATE.md does NOT ship.** Contributor-only: trellis tooling,
  trellis-gate.sh, main-guard.sh, run-tests.sh, this repo's settings.json.
- **Consequence (precedent already set):** any contract both shipped commands and external
  actors depend on cannot live in STATE.md or contributor files. The in-flight
  verification-boundary SPEC already hit this wall and chose `agents/vine-verification.md` as
  "the only viable shipped home." The eligibility gate and handoff contracts face the same
  placement constraint. An E3 reviewer in a *user* repo currently has no artifact-schema
  reference at all (STATE.md pointers in shipped commands are dangling there).
- **Existing mechanical gates (model-B precedent):** journal-check.sh (shipped; hard block,
  mtime-based), trellis-gate.sh and main-guard.sh (contributor-only PreToolUse blocks). Gates
  exist as plumbing; nothing user-facing authors them — consistent with the
  overlays-are-contract/hooks-are-plumbing reframe.
- **Roadmap:** ROADMAP.md (repo root) is canonical for cycle structure; the v0.4.0 milestone
  is issue-level truth. Current order: 1 platform-alignment (done) → 1.5 polish (3 of 4 done;
  #69 in flight) → 2 maintenance → 3 knowledge → 4 agent-native (#54→#53) → 5 team → 6 plugin.
  Milestone description still says "plan mode" (stale vs. the #62 reshape).

### Existing Trust-Gearing Mechanisms (what routing extends)

| Mechanism | Where criteria live | How mechanical |
|---|---|---|
| Scope routing (full cycle vs. pair) | verify.md step 3b: 1–3 files→pair / 4+→full, edge cases, clarity, integration concerns | Judgment heuristics + AskUserQuestion; only the file count is quantitative |
| Per-slice gearing | navigate.md step 3a: profile level → recommendation (confident/familiar→free climb; learning/new→walk-through) | Most mechanical routing in the framework; engineer always chooses |
| Gearing↔permission-mode map | navigate.md (free climb→auto-accept, walk-through→approve-edits) | Advisory only — "never flip it or assume it happened" |
| Slice validation gate | navigate step 4a → vine-verification agent; "don't commit broken code" | Prose-instructional; the only hard block is journal-check.sh |
| SPEC sign-off | inquire completion: explicit approval, never inferred | Interactive, single approver |
| Verify's gearing note | completion block prose | Advisory, written to no artifact — a routing recommendation with no durable home (relevant: route decisions currently have nowhere to be recorded) |

### Edge Cases & Tribal Knowledge — Single-Actor Assumption Inventory (expanded — brief had 5, repo has ~14 + structural findings)

Brief's known five, all confirmed: PAUSE.md consumed-once (5 uncoordinated deletion triggers
across commands; overwrite-on-re-pause loses a second actor's notes silently); `.vine/ACTIVE`
single sentinel (last-writer-wins, gitignored, "never leaves the machine" — E3 has zero
visibility; **any** command's cleanup deletes it regardless of which session wrote it, so actor
B's evolve silently disarms actor A's journal guard); NAVIGATION.md single-author journal (no
per-entry actor field, sequential slice ordering, journal-check uses mtime which is
meaningless across actors/machines); #61 tasks per-session by explicit design; knowledge vs.
live-state split (durable covered by #51/#56, live cross-actor state covered by nothing).

New findings beyond the brief:

1. **PROFILE.md is one engineer per repo** — no actor column; under E2 the last evolve wins;
   under E3 a headless agent would apply a human's depth preferences to itself. (It is
   otherwise cleanly orthogonal to roles — depth calibration only, as the role hypothesis
   requires.)
2. **SPEC.md has a single decision-maker** (`## Decisions made by:` header; "The engineer
   decides" principle; single sign-off). No per-decision attribution.
3. **CONTEXT.md author header is single-author free-form** — no structured attribution of
   whose tribal knowledge is whose.
4. **AskUserQuestion is the universal decision surface** — feature pick, gearing, scope
   check, sign-off, coverage triage, PR-number prompts. Every one stalls a headless run; #53's
   classification (human-required vs. default-able) is the right cure and must enumerate all
   sites.
5. **journal-check.sh fails open everywhere multi-actor matters** — no sentinel in CI (E3
   unenforced by design), worktree path mismatch (CLAUDE_PROJECT_DIR vs. main-checkout
   sentinel), mtime races on shared checkouts.
6. **`.resolved` is an empty marker** — no timestamp/author/reason; fine in E1, no audit
   trail for E2/E3.
7. **PROJECT-MAP.md is written by every phase command** with no locking; PR column depends on
   the engineer manually reporting numbers (a headless or remote actor could `gh pr list` but
   is never told to).
8. **Multi-PR deviation scoping is undocumented** — the completion gate can't scope
   deviation-checking to the current phase group (medium confidence; worth a look during the
   foundation cycle, not a blocker).
9. **vine-verification has no trust model** — it runs whatever commands the spawning session
   or overlay supplies, with Bash access. Acceptable in E1; an E3 reviewer spawning it makes
   the overlay a command-injection surface. Policy-rule territory.
10. **`.vine/.trellis-ok` stamp is last-write-wins** (contributor-only, but the same pattern
    class as ACTIVE).

**Per-artifact E2/E3 readiness, condensed:** CONTEXT/SPEC/EVOLUTION — written-once, low E2
risk, E3-readable; missing only actor attribution. NAVIGATION.md — high E2 risk (the one
artifact multiple actors must write), already the best E3 reconstruction substrate.
PROJECT-MAP — medium (every command writes it), cleanest E3 status surface. PAUSE.md, ACTIVE,
PROFILE.md — the three genuinely broken-under-E2 artifacts. `.resolved` — safe but
audit-free. Overlays — standard git merge semantics, no VINE-specific conflict handling;
shared.md is the best E3 bootstrap document but carries person-specific content with no
role/trust differentiation.

### Headless Eligibility as a Mechanical Gate (verified shape of the work)

The brief's construction rule — delegate execution only where a validation contract exists —
converts to harness mechanics only after reshaping #54. What the gate needs that nothing
currently provides:

- **A per-scope object to check.** #54's contract is repo-global. Candidate resolution:
  the global block is necessary-but-not-sufficient; the per-scope half of the predicate comes
  from the SPEC slice itself (slice has ACs + the global contract covers its validation +
  independence from in-flight slices + bounded blast radius). The spike should test whether
  that composite predicate is checkable without inventing per-slice config.
- **A gate semantic, not a fallback semantic.** #54 mandates graceful degradation when the
  block is absent; the gate inverts that for the headless route only: absence = ineligible,
  while interactive routes keep today's fallback. Both semantics can coexist if the gate is
  defined at the routing layer, not inside #54's consumer behavior.
- **A home that ships.** Gate criteria are policy-rule overlay content; the checking logic is
  plumbing. Neither can live in STATE.md (doesn't ship) or contributor scripts.
- **Tension to design around (memory guardrail: repo-owned decisions):** #54's contract is
  repo-supplied config — fine as discovery; "its mere existence flips execution mode" edges
  toward repo-config-as-behavior. The recommend-and-ratify default (human ratifies the route)
  is what keeps the gate on the right side of that line; pure auto-routing (model B) leans on
  it hardest.
- **Composition note:** the in-flight verification-boundary SPEC consolidates the three-way
  verification checklist into the shipped agent — exactly the single surface #54 would wire
  invocations into. Its SPEC explicitly says "#54 gains a cleaner substrate."

VINE's own construction remains the first test bed: roadmap/design sessions stay interactive;
mechanical items graduate to headless once the contract exists, each delegated run doubling as
a contract test (after the #46–50 freshness pass).

### Open Question 1 — Routing Decision Ownership (options mapped, not decided)

- **A. Recommend-and-ratify always.** Maps directly onto every existing decision surface
  (scope check, gearing, sign-off — all recommended-option-first AskUserQuestion). Smallest
  delta; pure principle fit; builds the calibration data evolve needs. Cost: every routed
  scope still consumes human attention; bottlenecks at team scale; headless becomes
  "headless after a human clicks."
- **B. Eligibility-gated auto-routing.** Precedent exists only in plumbing (journal-check's
  hard block) — nothing user-facing auto-decides anything today, and "the engineer decides" is
  stated as a principle in inquire. Requires airtight #54-reshape first, leans hardest on the
  repo-owned-decisions tension, and contradicts #53's written shape (which keys autonomy to
  decision classification + Decision Delegation, not contract presence). Fastest at scale.
- **C. Delegation policy as overlay content (leading candidate, strengthened by findings).**
  Default = A; team/company overlays may promote scope classes to auto-route. The repo
  already contains both seeds: **#55's Decision Delegation section is exactly this policy at
  the personal layer** ("what Claude may take by default vs. must surface" — body explicitly
  wires it into #53's defaults), and **#52's team-mode shared.md content is the team layer**.
  C unifies them as one policy surface across layers and resolves the #53→#55 dependency
  inversion by pulling Decision Delegation forward as routing-policy content. Hard
  dependency: C is only safe **after** the rule-class precedence split exists — a personal
  overlay must not loosen a team's gate.

### Open Question 2 — Overlay Precedence on Conflict (options mapped, not decided)

Current state: one precedence rule total ("overlay > default", prose, present in 4 of 9
loading commands), one mechanical ordering rule (overlays before profile, trellis check 6),
no overlay-vs-overlay story at all (multi-layer conflicts today = git merge conflicts).

- **Rule-class split (leading candidate):** preference-type rules (narration, formatting,
  engagement defaults) resolve personal-wins; policy-type rules (gates, eligibility,
  blast-radius, permission defaults) resolve company-wins. Today's PROFILE.md content is
  almost a pure preference-class preview; today's shared.md mixes both classes freely
  (conventions + CI gates + team context in one file) — so the split likely requires
  *labeling* within overlay files, not just layer ordering. Where it slots: the "apply the
  contents as additional instructions" step in each command's loading block is the only
  place application semantics are stated; the split would be defined once (shared.md protocol
  or shipped equivalent) and referenced, per the existing shared-pattern convention.
- **Single total ordering (company > team > repo > personal or inverse):** simpler to state
  and validate, but provably wrong in one direction or the other — either personal can't set
  its own narration depth or personal can loosen a team gate. Worth keeping as the fallback
  if the spike shows rule classification is too fuzzy to be mechanical.
- **Getting this wrong is a governance hole, not a style bug** — it gates option C above, so
  precedence design must precede or accompany any auto-routing promotion.

### Layer Distribution (options per layer, verified against packaging)

- **Personal:** travels with the person. Open: user-scoped home (`~/.claude`-adjacent vs.
  user-level `.vine`). Fact: create-vine already supports global installs and explicitly
  skips scaffold scripts there ("a global install has nowhere to put them") — personal-layer
  *content* has no per-repo enforcement home today.
- **Team / company:** plugins via marketplaces is Anthropic's explicit answer (verified:
  "A plugin bundles skills, hooks, and MCP configurations into a single installable package,
  so when a new engineer installs that plugin on day one, they will immediately have the same
  context and capabilities"). This is what promotes #57 — with the scope expansion noted
  above. Open: how `vine:init` discovers and composes the stack at init, and how team-overlay
  updates propagate without violating the backward-compat gate.
- **Repo:** `.vine/context/` as today. Composition-of-configuration, not
  synchronization-of-state (decided); federated knowledge sync stays deferred (2027-shaped,
  likely MCP); per-repo primitives must not foreclose it.

### Role Primitive — Leading Hypothesis (spike validates)

**Role = overlay stack + entry point + handoff contracts (inbound and outbound).** Reviewer:
entry point loads the review overlay slice; inbound contract = completed NAVIGATION.md +
validation results. Auto-agent: entry point = headless invocation against a delegated scope;
outbound contract feeds a reviewer. Execution flow is role-to-role handoff along the artifact
chain. PROFILE.md stays orthogonal (verified: it is consumed for depth calibration only,
nowhere as identity/authority).

Supporting repo facts: #55 already proposes the natural split seam (Decision Delegation /
Risk Tolerance → role-adjacent policy; domain levels / Growth Goals → stays profile). #53's
"structured handoff" block and `### Decisions Taken Autonomously` audit block are plausibly
the same artifact as the reviewer's inbound contract — the spike should confirm rather than
design twice. #39/#40 closed as automated *checkers*; reviewer *orientation* (entry point
that works from the artifact chain alone, E3) remains unbuilt and is now the reviewer role's
inbound side.

### Target Environments (constraint on every primitive)

- **E1 local personal** — design center today; backward compat is a hard gate (existing
  ROADMAP language, keep verbatim).
- **E2 committed shared** — where routing, cross-actor state, and slice ownership earn their
  keep. #52's single-writer-per-feature-directory + append-only-journal conventions are the
  starting answer; per-entry actor attribution in NAVIGATION.md is the missing primitive.
- **E3 remote verification** — reviewer works from artifacts alone. Verified blockers: ACTIVE
  invisible by design; PAUSE.md may not exist when the reviewer arrives; STATE.md (the schema
  reference) doesn't ship; no artifact records who did what. EVOLUTION.md + PROJECT-MAP.md are
  the strongest existing E3 surfaces; NAVIGATION.md the strongest reconstruction substrate.
- Gearing↔environment alignment holds: E1 = walk-through/free-climb; E2 unlocks
  hybrid/headless; E3 is the headless route's verification leg.

### The In-Flight verification-boundary SPEC (#69) — disposition options

`.vine/projects/workflow/verification-boundary/` holds a signed-off SPEC (2026-06-11, 5
slices, single PR). Finding: it is **aligned with the new thesis, not opposed** — it
consolidates the verification checklist into the one shipped surface (#54's future wiring
target) and its SPEC already honors the #54 constraint explicitly. Options for inquire/Rob:

1. **Execute as designed before/parallel to the roadmap rewrite.** Self-contained, closes the
   last 1.5 item, hands the foundation cycle a cleaner substrate. Cost: one interactive cycle
   spent before the re-scoped roadmap exists.
2. **Hold and fold into the foundation cycle.** #54's reshaping touches the same surfaces
   (agent file, navigate step 8, evolve delegation) — one combined design avoids touching
   them twice. Cost: a signed-off SPEC goes stale while the roadmap is rewritten; scope creep
   risk in the foundation cycle.
3. **Discard.** Not supported by findings — the design work is done and thesis-aligned.

### Documentation Gaps

- ROADMAP.md: whole-document rewrite is the feature. Milestone description stale ("plan
  mode"). Issue bodies #46–48 carry pre-rename `.vine/hooks/` paths; #49/#50 possibly already
  landed — freshness pass before reuse as delegation test cases.
- README "How VINE compares": reposition against Spec-Kit (111k★, spec-as-artifact camp,
  skills-based install), Kiro (GA, EARS specs, 5× price premium on spec mode), BMAD v6
  (role-persona camp converging on the same skills/subagents substrate), Augment Cosmos
  (strongest team-level shared-context competitor; opposite staleness bet — persistent
  semantic index vs. VINE/Anthropic's live-read), agent-context (closest #51/#56 prior art;
  verified weak on staleness/multi-author — its conflict story is "it's git" — which is the
  differentiation seam). AGENTS.md now under Linux Foundation AAIF (Anthropic/OpenAI/Block
  founding members) — confirmed substrate to ride, not compete with. Field gap worth naming:
  nobody has standardized the layering *above* repo scope; that's the territory the overlay
  matrix claims.
- The precedence sentence missing from 5 of 9 command loading blocks (fix rides with whatever
  touches loading).
- STATE.md pointers dangle in user installs (pre-existing; becomes acute when E3 reviewers
  need schema).

### Tech Debt in Affected Areas

- Three-way verification-checklist duplication — owned by the in-flight #69 SPEC (see
  disposition above).
- #46–48 consolidation backlog — unblocked, mechanical, candidate first delegations after
  freshness pass.
- mtime-based journal-check — adequate E1, wrong primitive for E2; replacement is foundation-
  cycle territory, not a pre-fix.
- Five uncoordinated PAUSE.md deletion triggers; ACTIVE deleted by any command's cleanup —
  both get redesigned by the cross-actor state model, don't patch piecemeal.

### Roadmap Consequences to Carry into Inquire (verified)

- **#54 → foundation**, first goal-relevant cycle after the rewrite — *as reshaped* (gate
  predicate, per-scope composition, route-layer gate semantics). #53 pairs with it; resolve
  the Decision Delegation dependency (pull forward as policy content, per option C, or
  reshape #53).
- **#57 → near-core** with explicit scope expansion to team-overlay distribution.
- **#55 → splits**: role-adjacent policy sections feed the role primitive / routing policy;
  depth-and-growth stays profile.
- **#52 → reframed** as overlay composition at the team layer + delegation-policy content;
  its conflict-safe conventions and tracked-default flip survive nearly intact.
- **#51/#56 → supporting subsystem** (routing calibration substrate). Explicitly distinguish
  durable knowledge from live execution state; the latter is a **new** design object (slice
  ownership, in-flight state, handoff payload) — covered by no existing issue.
- **Cross-actor live-state / ownership** → new issue(s); #61 stays closed.
- **Polish/maintenance (#46–50)** → first headless test cases after freshness pass; never
  scheduled interactively ahead of the foundation.
- **Evolve gains delegation-criteria calibration** — routing outcomes (e.g., a headless scope
  failing validation twice) feed criteria updates as learnings feed CLAUDE.md today. The
  Stop-hook reflection pattern (verified: propose-don't-apply) is the likely plumbing.
- **Multi-system ingest** stays a consumption *contract* (a feature can be seeded from an
  external work item), never VINE-owned connectors; under the thesis, ingest is how scopes
  arrive for routing. Today's only instance: optional `gh` in evolve.
- **Org-fleet concerns stay deferred**; reviewer and auto-agent are in scope as roles
  (partially supersedes ROADMAP's "org-level agents live a layer above" — the *roles* moved
  in scope, the *fleet* didn't).
- **Obsolescence discipline:** every mechanism the rewrite adds needs a review-cadence story
  (3–6 month config review, verified recommendation) — any VINE mechanism duplicating
  platform orchestration starts the Perforce-hook clock.

### Open Questions for Inquire

1. Routing decision ownership — A / B / C above (C leading; requires precedence split first).
2. Overlay precedence — rule-class split vs. single ordering (split leading; needs a
   labeling mechanism inside overlay files).
3. Disposition of the verification-boundary SPEC (execute / fold / discard — discard
   unsupported).
4. Personal-layer physical home (`~/.claude`-adjacent vs. user-level `.vine`), and init's
   stack-discovery/composition flow.
5. Where the route decision itself is journaled — no current home exists (verify's gearing
   note demonstrates the gap); evolve's calibration needs the record. PROJECT-MAP row,
   NAVIGATION entry field, or new artifact?
6. Whether #53's structured-handoff block and the reviewer's inbound contract are one
   artifact (spike answers).
7. How team-overlay updates propagate without violating the backward-compat gate.
8. Cycle ordering of the rewrite itself — what is cycle 1 of the new roadmap given the
   verification-boundary disposition and the #46–50 freshness pass.

### Questions the Coordination Spike Must Answer (before inquire finalizes cycle ordering)

Spike scope (decided): one shepherd + one auto-agent + one reviewer, one feature, one full
routing decision end-to-end — scope arrives → eligibility evaluated → route chosen → headless
execution → reviewer consumes the handoff. Scaffolding allowed to be ugly. It must answer:

1. Is the composite eligibility predicate (global contract + slice independence + bounded
   blast radius) mechanically checkable without per-slice config files?
2. Can a headless navigate-shaped run produce a valid NAVIGATION.md entry and commit without
   tripping or bypassing journal-check/ACTIVE semantics — and what minimal actor-attribution
   does the entry need?
3. Can the reviewer orient from artifacts alone in a repo where STATE.md never shipped
   (E3)? What schema surface, if any, must start shipping?
4. Is role = overlay stack + entry point + contracts sufficient, or does the reviewer need
   state outside the artifact chain?
5. Is one handoff artifact enough for both the auto-agent's outbound and reviewer's inbound
   contract (#53's block), or do they diverge?
6. Where does the route decision get recorded so evolve can calibrate against the outcome?

### Process Notes for Inquire

- Engineer is confident in this domain (authored the framework) — concise narration, options
  with tradeoffs on the two named open questions (2–3, always), no premature recommendations
  beyond the leading-candidate labels already established.
- Planned flow: inquire produces the re-scoped ROADMAP.md as the SPEC deliverable → thin
  coordination spike → cycle design finalized.
- Backward-compat hard gate language from current ROADMAP.md carries verbatim into the
  rewrite.
