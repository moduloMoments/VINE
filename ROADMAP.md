# VINE Roadmap

## Where this is headed

VINE today is a workflow for one engineer and Claude building features together, with the
human reviewing everything. v0.4.0 turns that into a **delegation harness**: for each piece
of work, VINE helps decide how much human attention it deserves — from "walk me through every
change" to "run this unattended and hand the result to a reviewer" — and routes it
accordingly. The human stays the one deciding what's safe to delegate; VINE's job is making
that decision well-informed, recording it, and learning from how it turns out.

In practice, v0.4.0 builds four things:

- **Routing rules** — clear criteria for which work qualifies for unattended runs, and a
  default where VINE recommends and the human approves.
- **Handoff records** — enough written down that a reviewer can check work they didn't
  watch happen.
- **Shared configuration** — team conventions that install with the project instead of
  living in one person's head.
- **Multi-actor safety** — clear ownership when several people (or agents) work in one
  repo at once.

The rest of this file is the working contract for the cycles that deliver this — future
development sessions execute against it, so the detail level below is intentional. Issue-level
status lives in the [v0.4.0 milestone](https://github.com/moduloMoments/VINE/milestone/1);
this file names the cycles, their order, and why the order matters. Each cycle is run as a
VINE feature on this repo (dogfooding is the test suite); small mechanical items go through
`vine:pair` instead of the full chain.

## v0.4.0 — The delegation-routing harness

**Goal:** make VINE the best framework for individuals and teams of humans, local agents, and
auto-agents to build and maintain established codebases while sharing context. The organizing
process is **scope-delegation routing**: deciding, per scope of work, how much human attention
it deserves — and routing it accordingly. The harness optimizes *where human attention is
worth spending*; the human's delegation judgment is one of the three things growing.

### The core loop

Every cycle below builds a stage of one loop, or is explicitly labeled a supporting subsystem
of it:

**scope → route (per overlay-defined policy) → execute (platform mechanics) → handoff
(artifact contract) → evolve (criteria calibration)**

VINE already routes by trust at two granularities — verify's scope check (full cycle vs.
`vine:pair`) and navigate's per-slice gearing (walk-me-through vs. free-climb). v0.4.0 extends
that gearing axis past the human-attention boundary:

**walk-me-through → free-climb → hybrid-parallel → headless**

How each stage works:

- **Scope** — scopes arrive from verify/inquire today. Multi-system ingest (a feature seeded
  from an external work item) stays a consumption *contract*, never VINE-owned connectors;
  today's only instance is the optional `gh` read in evolve.
- **Route** — the default is **recommend-and-ratify**, today's pattern everywhere: VINE
  recommends a route, the human ratifies it. Team or company overlays may promote specific
  scope classes to auto-route, but only after the precedence split below exists — a personal
  overlay must never loosen a team gate.
- **Execute** — belongs to the platform. Subagents, headless invocation, background tasks,
  parallelization: VINE supplies the decision criteria and consumes the mechanics.
- **Handoff** — every route is journaled where evolve can read it (decided): the scope-level
  route in PROJECT-MAP.md, the per-slice route and actor attribution as fields on
  NAVIGATION.md entries. No new artifact.
- **Evolve** — calibrates the criteria. Routing outcomes (e.g., a headless scope failing
  validation twice) feed criteria updates the way learnings feed CLAUDE.md today; the
  Stop-hook reflection pattern (propose updates, never apply them) is the likely plumbing.

**Roles, not fleet.** Reviewer and auto-agent are in scope as *roles*; the working hypothesis
(the spike validates it) is role = overlay stack + entry point + handoff contracts, with
PROFILE.md staying orthogonal (depth calibration only, never identity or authority). Org-fleet
concerns — risk auditors, fleet dashboards — stay a layer above a per-repo framework.
Cross-actor *live execution state* (slice ownership, in-flight state, handoff payloads) is new
issue territory: [#61](https://github.com/moduloMoments/VINE/issues/61) stays closed — native
tasks are the live view and markdown the durable journal, but neither covers state between
concurrent actors.

### Target environments

Every primitive is checked against three environments:

- **E1 — local personal.** Today's design center. Backward compatibility here is the hard
  gate below.
- **E2 — committed shared.** `.vine/` tracked in git, multiple actors on one repo. Where
  routing, cross-actor state, and slice ownership earn their keep.
- **E3 — remote verification.** A reviewer works from the artifact chain alone. The headless
  route's verification leg.

The gearing axis aligns: E1 covers walk-through and free-climb; E2 unlocks hybrid-parallel
and headless; E3 verifies headless output.

### Guiding principle

Before adding a VINE mechanism, check whether the harness already provides it. **VINE owns
the decision criteria, the contracts, and the handoff artifacts; the platform owns execution
mechanics — subagents, headless invocation, background tasks, parallelization. VINE never
implements an agent runner.** Loops, gates, enforcement, progress UI, and memory primitives
belong to the platform; VINE consumes them.

**Backward compatibility is a hard gate for every cycle.** Existing `.vine/` setups must keep
working unchanged, or `vine:init`'s upgrade pass must offer an explicit migration — and
declining the migration must change nothing. The rename fallback in
[#58](https://github.com/moduloMoments/VINE/issues/58) and the backfill mode in
[#56](https://github.com/moduloMoments/VINE/issues/56) are the patterns to copy.

**Obsolescence discipline applies to every mechanism this roadmap adds.** Platform
capabilities move fast; anything VINE builds near the platform's orbit gets a meaningful
configuration review every three to six months and is removed when the platform catches up.

### Overlay layers and precedence

Routing policy lives in overlays, so the overlay matrix is foundation-cycle territory:

- **Repo layer** — `.vine/context/` as today. Composition of configuration, not
  synchronization of state; federated knowledge sync stays deferred (2027-shaped, likely MCP),
  and per-repo primitives must not foreclose it.
- **Personal layer** (decided) — vine-namespaced local files following the platform's
  existing `.local` convention (the `CLAUDE.local.md` pattern): easily gitignored as a domain,
  scoped per mode/role. No invented user-global home or discovery mechanism.
- **Team / company layer** — overlays ship as plugin content
  ([#57](https://github.com/moduloMoments/VINE/issues/57)). Updates propagate by plugin
  version bump plus an explicit recomposition offer in `vine:init`'s upgrade pass — and
  declining changes nothing (decided: the #58/#56 migration pattern applied to overlay
  distribution).
- **Precedence on conflict** — rule-class split: preference-type rules (narration,
  formatting, engagement defaults) resolve personal-wins; policy-type rules (gates,
  eligibility, blast radius, permission defaults) resolve company-wins. This requires a
  labeling mechanism inside overlay files — today's shared.md mixes both classes freely — and
  is defined once and referenced, per the shared-pattern convention. **Fallback, written in
  now:** if the spike finds rule classification too fuzzy to be mechanical, fall back to a
  single total ordering with policy-class carve-outs. That finding reorders the foundation
  cycle's content; it does not force a roadmap revision.

### Cycle order

Done so far: cycle 1 in the pre-rewrite numbering (platform alignment,
[#58](https://github.com/moduloMoments/VINE/issues/58)–[#62](https://github.com/moduloMoments/VINE/issues/62))
shipped, and cycle 1.5 polish is three of four done — the fourth,
[#69](https://github.com/moduloMoments/VINE/issues/69) (navigate↔evolve verification
reconciliation), executes as designed in its own session. The foundation cycle assumes the
consolidated verification agent #69 produces.

| # | Cycle | Issues | Mode | Loop stage / why this order |
|---|-------|--------|------|------------------------------|
| 0 | **Coordination spike** — ✅ done 2026-06-12 | none — throwaway scaffolding | Spike (ugly allowed) | The whole loop, end to end, once: one shepherd + one auto-agent + one reviewer, one feature, one full routing decision — scope arrives → eligibility evaluated → route chosen → headless execution → reviewer consumes the handoff. Ran before the foundation; all six questions answered with run evidence — see `.vine/projects/workflow/coordination-spike/EVOLUTION.md`. Convergent finding for cycle 1: the gate's output (verdict + constraints + allowlist + validation baseline) needs a durable, reviewer-visible artifact. |
| 1 | **Foundation** | [#54](https://github.com/moduloMoments/VINE/issues/54) reshaped: routing-layer eligibility gate; [#53](https://github.com/moduloMoments/VINE/issues/53) headless contract; routing policy as overlay content (Decision Delegation pulled forward from [#55](https://github.com/moduloMoments/VINE/issues/55)); rule-class precedence split | Full cycle | The *route* stage. The precedence split lands first within the cycle — promoting any scope class to auto-route is unsafe without it. #54's gate semantic lives at the routing layer: a missing validation contract makes a scope ineligible for the headless route, while interactive routes keep today's graceful fallback. #53 pairs with it — decision classification (human-required vs. default-able) plus the structured handoff block. |
| 2 | **Knowledge lifecycle** | [#51](https://github.com/moduloMoments/VINE/issues/51) durable knowledge layer, [#56](https://github.com/moduloMoments/VINE/issues/56) archival + backfill | Full cycle (multi-PR) | Supporting subsystem: the calibration substrate. Evolve's routing-criteria updates need a durable home to write to and read from. Durable knowledge only — live cross-actor state is the next cycle's design object, not this one's. |
| 3 | **Cross-actor state** | [#79](https://github.com/moduloMoments/VINE/issues/79) | Full cycle | The *execute* and *handoff* stages under E2: slice ownership, in-flight state, handoff payload. Redesigns the three broken-under-E2 artifacts (PAUSE.md, `.vine/ACTIVE`, PROFILE.md) as one state model rather than patching them piecemeal. Shaped by the spike's question 2. Unlocks hybrid-parallel. |
| 4 | **Team layer** | [#52](https://github.com/moduloMoments/VINE/issues/52) reframed: overlay composition at the team layer | Full cycle | The *route* stage's policy layering. #52's conflict-safe conventions (single-writer feature directories, append-only journal, shared files edited only via evolve's approval flow) and its tracked-by-default flip survive intact; team context relocates from a shared.md section to a composable layer. Needs the precedence split (cycle 1) and shared knowledge (cycle 2) first. |
| 5 | **Plugin** | [#57](https://github.com/moduloMoments/VINE/issues/57) expanded: packaging *plus* team-overlay distribution | Light cycle | Supporting subsystem: distribution. Ships after the team layer exists so the plugin's first release carries it. Propagation is plugin version bump + init recompose, under the backward-compat hard gate. |
| — | **Maintenance side-track** | [#46](https://github.com/moduloMoments/VINE/issues/46), [#47](https://github.com/moduloMoments/VINE/issues/47) (#48–#50 closed as already landed) | `vine:pair`, anytime | The first headless test cases. Bodies freshened with this re-scope so a delegated actor can execute them cold; they are never scheduled interactively ahead of the foundation — each one waits for cycle 1's gate, and each delegated run doubles as a contract test. |

### The spike's six questions

> **Answered 2026-06-12** — evidenced answers and scaffold dispositions live in
> `.vine/projects/workflow/coordination-spike/EVOLUTION.md`. Short form: Q1 checkable in
> principle, not with today's fields (0/4 legs mechanical); Q2 yes ×3, and the contract
> core proved mechanism-portable across four envelope swaps; Q3 yes — the gaps that bite
> are the gate record and envelope lacking durable homes, not artifact-format schema;
> Q4 holds, with the gate record promoted into the handoff contracts; Q5 one handoff
> artifact suffices (the second thing is the durable role recipe); Q6 yes-except-gear,
> four small schema fixes.

1. Is the composite eligibility predicate (global validation contract + slice ACs + slice
   independence + bounded blast radius) mechanically checkable without per-slice config files?
2. Can a headless navigate-shaped run produce a valid NAVIGATION.md entry and commit without
   tripping or bypassing journal-check/ACTIVE semantics — and what minimal actor attribution
   does the entry need?
3. Can the reviewer orient from artifacts alone in a repo where STATE.md never shipped (E3)?
   What schema surface, if any, must start shipping?
4. Is role = overlay stack + entry point + contracts sufficient, or does the reviewer need
   state outside the artifact chain?
5. Is one handoff artifact enough for both the auto-agent's outbound and the reviewer's
   inbound contract (#53's structured-handoff block), or do they diverge?
6. Do the decided route-journaling homes (PROJECT-MAP.md scope-level, NAVIGATION.md
   per-slice) give evolve enough to calibrate against, or is a field missing?

### Out of scope for v0.4.0

Open issues not in the milestone ([#36](https://github.com/moduloMoments/VINE/issues/36) vine:grow,
[#42](https://github.com/moduloMoments/VINE/issues/42) debugger agent,
[#43](https://github.com/moduloMoments/VINE/issues/43) UI audit) are deferred — they add agents and
phases, and the guiding principle says to revisit them after v0.4.0 to see how much the native
tooling already covers.

Closed during cycle-1 triage as already-covered: #39 integration-checker (the existing
`vine-verification` agent's feature mode does cross-slice integration — proven in cycle 1's evolve)
and #40 design-checker (the inquire sign-off gate is VINE's chosen design-validation mechanism; an
automated checker is the performative-findings pattern #66 rejects).

Also deliberately deferred: org-fleet tooling (the reviewer and auto-agent *roles* moved into
scope above; the fleet did not), HTML output, and VINE-owned ingest connectors (ingest stays a
consumption contract — see the core loop).

### Post-0.4.0 cleanup

[#64](https://github.com/moduloMoments/VINE/issues/64) removes the `.vine/hooks/` legacy fallback.
It is **gated on the 0.5 release**, not schedulable within v0.4.0 — the fallback must ship through
all of 0.4.x (the one-minor-version compatibility window from #58), then the removal + trellis
Check 9 hardening land together at 0.5.

### Process notes

- Each full cycle gets its own `.vine/projects/` feature with PROJECT-MAP.md; multi-PR cycles use
  the Milestones table.
- VINE's own construction is the first test bed for routing: roadmap and design sessions stay
  interactive; mechanical items graduate to headless once the contract exists.
- Run `/trellis` before committing command changes; `/vine:optimize` after each cycle that touches
  descriptions or workflows.
- This file is updated at each cycle boundary (evolve's handoff step) — status lives in the GitHub
  milestone, not here.
