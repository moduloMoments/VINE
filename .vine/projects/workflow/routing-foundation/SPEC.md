# Feature Spec: Routing Foundation (v0.4.0 Cycle 1)
## Date: 2026-06-14
## Built on: CONTEXT.md (2026-06-14)
## Decisions made by: Rob

### Problem Statement

The v0.4.0 delegation loop is `scope → route → execute → handoff → evolve`. The **route**
stage does not exist yet: nothing in the commands or `references/STATE.md` defines how VINE
decides whether a scope of work runs interactively (human watches every change) or headless
(an agent runs unattended, a reviewer checks after), records that decision, or enforces the
policy that governs it.

The cycle-0 spike ran the whole loop once by hand and converged on one missing artifact: the
gate's output — verdict + constraints + allowlist + validation baseline — needs a durable,
reviewer-visible home, not a throwaway scaffold. This cycle builds the route stage around that
artifact, plus the four foundation threads it depends on: the routing-layer eligibility gate
(#54), the headless autonomy contract (#53), Decision Delegation as routing policy (#55 policy
half), and the rule-class precedence split that must land *first* — promoting any scope class
to auto-route is unsafe without it (ROADMAP). The personal `.local` overlay layer and the #90
journal-schema fixes fold in because the precedence split needs a real second layer to resolve
against, and route journaling depends on the same NAVIGATION.md / PROJECT-MAP.md schema.

**Backward compatibility is a hard gate** (ROADMAP): every new field, block, and layer is
optional with graceful absence; existing `.vine/` setups work unchanged or get an explicit,
declinable migration through init's upgrade pass.

### Approach

Seven design decisions, made at inquire, shape the build:

1. **Gate record → new per-feature `ROUTE.md`.** A source-of-truth artifact in the feature
   directory, joining the CONTEXT → SPEC → NAVIGATION → EVOLUTION chain. It carries the verdict,
   constraints, allowlist, validation baseline, plus a computed-at stamp and input basis. The
   PROJECT-MAP Route table becomes a *derived pointer* to it — PROJECT-MAP stays a derived view
   (STATE.md "Source of Truth vs Derived Views"), never authoritative state.

2. **Gate evaluated at navigate-head, previewed at inquire.** Inquire's completion block previews
   the likely route (non-binding, like its existing gearing preview). Navigate's head runs the
   *authoritative* gate with fresh repo state and writes ROUTE.md. This is recommend-and-ratify:
   inquire proposes, navigate ratifies. It evaluates the volatile legs (independence, blast
   radius) at the moment of execution, countering verdict decay, and serves standalone delegated
   items (#46/#47) that enter through navigate, never inquire. For interactive runs the gate is a
   no-op — the common path is unchanged.

3. **Precedence → flat personal-wins + policy-only carve-out markers.** Mirrors how Claude's own
   settings resolve (local-wins, with an immutable enterprise-policy ceiling). Only policy-class
   sections (`CI/CD`, `Team Context`) get an HTML-comment class marker; everything unlabeled is
   preference and is personal-overridable. This is the ROADMAP fallback's spirit, chosen over
   per-section or per-rule labeling because it is the lowest-fuzziness path and labeling
   shared.md was named the cycle's fuzziest mechanical risk.

4. **`.local` composition → read-order, class-gated.** Each command's "Load Context Overlays"
   step loads `shared.md` then the `.local` layer; `.local` overrides everything *except*
   policy-marked sections. Follows the platform's `CLAUDE.local.md` convention. Absent `.local`
   changes nothing.

5. **Verdict decay → stamp + navigate re-eval.** ROUTE.md records computed-at and the input basis
   (HEAD SHA, in-flight set). Navigate-head always re-evaluates the volatile legs fresh, so the
   *binding* decision can't decay; the reviewer compares the stamp to the execution state to flag
   authorization-vs-execution drift.

6. **Decision Delegation → policy section + per-site class tags.** A `Decision Delegation`
   section in shared.md (policy-class) sets per-class headless behavior. Each AskUserQuestion site
   is tagged with its class in the command. Headless behavior: default-able → take the recommended
   option and journal it as a Decision Taken Autonomously; human-required → escalate to the
   structured handoff and stop.

7. **Trellis checks → artifact tier.** ROUTE.md format, the #90 journal route fields, and the
   Validation block's presence/shape are session-judged artifact checks (Check A–D family). They
   do not gate the `.vine/.trellis-ok` command-commit stamp, which stays scoped to command-file
   structure. Matches #54's "validate the block when it exists."

The composite eligibility predicate (#54) has four legs: (1) a global validation contract exists,
(2) slice ACs are present in SPEC.md, (3) slices are independent of in-flight work, (4) blast
radius is bounded/enumerable. Absence of any leg makes the scope ineligible for the headless
route; the same absence never degrades interactive routes (gate-time check vs. verification-time
check is the distinction that lets both coexist). Bounded-blast-radius is not pure file
enumeration — it must account for requirement-implied files the spike's occurrence-grep missed
(F1 root cause).

### Acceptance Criteria

Cycle-level contract (each maps to slices/commits at evolve):

1. **Precedence resolves at load time.** Policy-class sections in shared.md carry a class marker;
   a single referenced precedence rule resolves conflicts as flat personal-wins with policy
   carve-outs; the `.local` layer loads in every command's overlay step and overrides only
   non-policy content; an absent `.local` changes nothing.
2. **Validation contract exists and is consumed.** A fenced `## Validation` YAML block schema is
   defined (lint/typecheck/test/test-all/build/extra); init scaffolds it for fresh repos and
   offers it in the upgrade checklist; `vine-verification` reads it with the prose-inference
   fallback preserved for blockless repos; navigate/evolve/pair reference it.
3. **Eligibility gate runs at navigate-head.** Navigate evaluates the four-leg predicate against
   fresh repo state, produces a verdict, and writes ROUTE.md; a missing leg yields headless-
   ineligible without altering the interactive route; volatile legs are re-evaluated rather than
   read from a stale stamp.
4. **ROUTE.md is a complete, reviewer-readable record.** It carries verdict + constraints +
   allowlist + validation baseline + computed-at + input basis; it is embeddable in the headless
   envelope; the PROJECT-MAP Route table links to it.
5. **Headless contract holds (#53).** A headless mode exists; every AskUserQuestion site is
   classified; default-able decisions take the recommended option and are journaled as autonomous
   (section-scoped attribution); human-required decisions escalate to the structured handoff and
   stop; one structured handoff block serves both the outbound (agent) and inbound (reviewer)
   contract.
6. **Decision Delegation policy is overlay content (#55).** A policy-class `Decision Delegation`
   section defines per-class headless behavior, override-able as overlay content, aligned with the
   per-site classification.
7. **Journal schema carries route data (#90).** NAVIGATION.md and PROJECT-MAP.md templates carry
   Route/Actor/Gear fields and the Route table; the five #90 fixes are applied (validation rollup
   token, multi-commit `+`-separated Commit, section-scoped `(slice N)` autonomous-decision
   attribution, controlled Route vocabulary + `mechanism:` token, Gear field); `(decided by:)` +
   confidence tags are formalized.
8. **Reviewer reads the gate record.** review.md's orientation order includes reading ROUTE.md.
9. **Distribution surfaces updated.** README has an "Agents running VINE" section; trellis has
   artifact-tier checks for ROUTE.md, journal route fields, and the Validation block (when
   present); the Command Addition Checklist and all command/section counts are updated.
10. **Backward compatibility verified.** Every new field/block/layer is optional with graceful
    absence; an existing `.vine/` setup with none of them works unchanged; init's upgrade pass
    offers migration and declining changes nothing on disk.

### Work Slices

Sliced into four phase groups; each phase group is one PR (multi-PR tracking enabled — see the
Milestones table in PROJECT-MAP.md). The precedence split lands first within the cycle per the
ROADMAP. File references name areas/sections rather than line numbers (the verify map predates
main's #92, which shifted lines; navigate re-reads the live files).

## Phase 1: Precedence & Validation Foundation (Slices 1-5) ✅
Summary: Build the overlay precedence model, the `.local` layer, and the Validation contract —
the substrate the gate's leg 1 and all auto-routing policy depend on.
Session boundary: After this phase, overlays resolve by class, `.local` composes, and a
structured validation contract exists and is consumed. Nothing routes yet.

### Slice 1: Overlay precedence — policy-class markers + precedence rule
**Goal**: Label policy-class sections in shared.md and define the resolution rule once.
**Depends on**: Nothing (lands first).
**Files likely touched**: `.vine/context/shared.md`.
**Acceptance criteria**: `CI/CD` and `Team Context` (and any policy subsections under Project
Conventions) carry an HTML-comment class marker; a single "Overlay Precedence" rule states flat
personal-wins with policy carve-outs and is defined once for other surfaces to reference;
unlabeled sections are treated as preference.
**Complexity signal**: Medium — labeling mixed content is the cycle's fuzziest call; the
policy-only approach minimizes the surface but section boundaries still need judgment.

### Slice 2: Personal `.local` layer — load + class-gated override
**Goal**: Every command's "Load Context Overlays" step loads `.local` and composes it by the
precedence rule.
**Depends on**: Slice 1 (the rule it resolves against).
**Files likely touched**: `.vine/context/shared.md` (define the load instruction once),
`commands/vine/{verify,inquire,navigate,evolve,pair,pause,resume,status,optimize}.md` (reference
it). init creates overlays rather than loading; help is exempt.
**Acceptance criteria**: load order is shared → `.local`, `.local` overrides only non-policy
content; the instruction is defined once and referenced (shared-pattern convention); absent
`.local` changes behavior nowhere; `.gitignore` handles the `.local` path (it is gitignored as a
domain by design).
**Complexity signal**: Medium — touches every product command; mechanical once the pattern is set.

### Slice 3: Validation YAML block — schema + STATE.md home
**Goal**: Define the fenced `## Validation` block and point STATE.md at it.
**Depends on**: Nothing structural (parallel to 1-2; ordered here for phase coherence).
**Files likely touched**: `.vine/context/shared.md`, `references/STATE.md` (the existing note
naming this block as the validation-contract home).
**Acceptance criteria**: block defines lint/typecheck/test/test-all/build/extra keys with
documented optionality; STATE.md references the real schema; the block is optional (blockless
repos fall back).
**Complexity signal**: Low.

### Slice 4: init scaffolds the Validation block
**Goal**: init writes the structured block for fresh repos and offers it on upgrade.
**Depends on**: Slice 3.
**Files likely touched**: `commands/vine/init.md` (Step-1 discovery already finds the commands;
change the write target from freeform `## CI/CD` prose to the structured block; add to the
upgrade-mode required-sections checklist, mirroring the #48/#92 precedent).
**Acceptance criteria**: fresh repos get the block from the template; upgraded repos get it from
the checklist; declining the upgrade changes nothing on disk.
**Complexity signal**: Low.

### Slice 5: Wire Validation-block consumers
**Goal**: Point the verification agent and the phase commands at the block.
**Depends on**: Slice 3.
**Files likely touched**: `agents/vine-verification.md` (read the block, replacing prose
inference; keep the fallback path for blockless repos), `commands/vine/{navigate,evolve,pair}.md`
(reference the block).
**Acceptance criteria**: the agent prefers the block when present and falls back to prose
inference when absent; navigate/evolve/pair reference the contract; no regression for blockless
repos.
**Complexity signal**: Medium — the agent is the single consolidated verification surface (#69);
the fallback must stay intact.

## Phase 2: Eligibility Gate & Route Record (Slices 6-9) ⬜
Summary: Build the route decision — the four-leg predicate at navigate-head, the ROUTE.md record,
the inquire preview, and the PROJECT-MAP pointer.
Session boundary: After this phase, a scope can be evaluated, routed, and recorded; the headless
behavior that consumes the route comes in Phase 3.

### Slice 6: ROUTE.md artifact format in STATE.md
**Goal**: Define the gate-record contract.
**Depends on**: Slice 3 (validation baseline is part of the record).
**Files likely touched**: `references/STATE.md` (artifact format + add ROUTE.md to the artifact
chain and the Committing Artifacts table).
**Acceptance criteria**: format carries verdict + constraints + allowlist + validation baseline +
computed-at + input basis (HEAD SHA, in-flight set); section headings carry required/optional
markers; the record is documented as travelling tracked with the feature.
**Complexity signal**: Low.

### Slice 7: Navigate-head gate evaluation + ROUTE.md write + re-eval
**Goal**: Run the four-leg predicate at navigate-head, produce a verdict, write ROUTE.md,
re-evaluate volatile legs.
**Depends on**: Slices 3, 6.
**Files likely touched**: `commands/vine/navigate.md`.
**Acceptance criteria**: predicate legs (validation contract, slice ACs, independence, bounded
blast radius) are evaluated against fresh repo state; bounded-blast-radius accounts for
requirement-implied files, not just occurrence-grep; a missing leg yields headless-ineligible
and routes interactively with no change to today's interactive flow; ROUTE.md is written with the
stamp and input basis; the step is a no-op for clearly-interactive runs.
**Complexity signal**: High — the cycle's central mechanism; must keep the interactive fallback
untouched while adding the gate.

### Slice 8: Inquire route preview (non-binding)
**Goal**: Preview the likely route in inquire's completion block.
**Depends on**: Slice 7 (the predicate it previews).
**Files likely touched**: `commands/vine/inquire.md` (completion block, alongside the existing
gearing preview).
**Acceptance criteria**: the preview is explicitly non-binding; it does not write ROUTE.md;
navigate's evaluation remains authoritative.
**Complexity signal**: Low.

### Slice 9: PROJECT-MAP Route table as derived pointer
**Goal**: Add the Route table linking to ROUTE.md.
**Depends on**: Slices 6, 7.
**Files likely touched**: `references/STATE.md` (PROJECT-MAP template), `commands/vine/navigate.md`
(writes the row).
**Acceptance criteria**: the Route table links to ROUTE.md and holds no authoritative state
(derived view); reconstructable from ROUTE.md; the table is optional/graceful when absent.
**Complexity signal**: Low.

## Phase 3: Headless Contract & Journaling (Slices 10-13) ⬜
Summary: Build the headless autonomy contract that consumes the route, the decision-delegation
policy, and the #90 journal schema that records it.
Session boundary: After this phase, a permitted scope can run headless with classified decisions,
escalate when it must, and journal route/actor/gear data.

### Slice 10: Decision Delegation policy section
**Goal**: Add the policy-class `Decision Delegation` section to shared.md.
**Depends on**: Slice 1 (class marking).
**Files likely touched**: `.vine/context/shared.md`.
**Acceptance criteria**: the section is policy-class (immutable from `.local`); it sets per-class
headless behavior (default-able vs human-required); it is override-able as overlay content.
**Complexity signal**: Low.

### Slice 11: AskUserQuestion site classification
**Goal**: Tag each AskUserQuestion site with its decision class.
**Depends on**: Slice 10 (the classes it references).
**Files likely touched**: `commands/vine/{verify,inquire,navigate,evolve,pause,resume,pair}.md`
(~30 sites; the human-required vs default-able map is in CONTEXT.md "Current State").
**Acceptance criteria**: every site carries a class tag matching the CONTEXT map; tags align with
the Decision Delegation policy; interactive behavior is unchanged.
**Complexity signal**: Medium — breadth across commands; mechanical per site.

### Slice 12: Headless mode + structured handoff block (#53)
**Goal**: Define headless entry/behavior and the structured handoff.
**Depends on**: Slices 7, 10, 11.
**Files likely touched**: `commands/vine/navigate.md` (primary), `.vine/context/shared.md` and/or
`references/STATE.md` (the structured handoff contract).
**Acceptance criteria**: in headless mode, default-able decisions take the recommended option and
are journaled as autonomous; human-required decisions escalate to the structured handoff and
stop; one structured handoff block serves both outbound (agent) and inbound (reviewer); platform
boundaries from the spike are respected (no nested Agent tool assumption; actor permissions stay
a provisioning-time human authority, not a VINE artifact field).
**Complexity signal**: High — the autonomy contract; the escalate-and-stop path must be
unambiguous for an unattended actor.

### Slice 13: #90 journal schema fixes
**Goal**: Add route data and the five #90 fixes to the journal templates and writers.
**Depends on**: Slices 7, 9, 12.
**Files likely touched**: `references/STATE.md` (NAVIGATION.md + PROJECT-MAP.md templates),
`commands/vine/navigate.md` (writer).
**Acceptance criteria**: NAVIGATION.md carries Route/Actor/Gear fields; validation rollup uses a
`pass`/`fail` token first; multi-commit slices use a `+`-separated Commit field; autonomous
decisions carry section-scoped `(slice N)` attribution; Route uses a controlled vocabulary with a
labeled `mechanism:` token; `(decided by:)` and confidence tags are formalized; the schema forces
field correction when a mechanism diverges mid-slice (the #90 wrong-extraction gap); all fields
are optional with graceful absence on older journals.
**Complexity signal**: Medium.

## Phase 4: Docs, Reviewer & Trellis (Slices 14-17) ⬜
Summary: Make the new surfaces discoverable, reviewable, and validated.
Session boundary: Cycle complete and ready for evolve.

### Slice 14: review.md gate-record orientation step
**Goal**: Add "read ROUTE.md" to the reviewer's orientation order.
**Depends on**: Slice 6.
**Files likely touched**: `.vine/context/review.md` (orientation order; resolve the cycle-1
follow-up flagged in its header comment).
**Acceptance criteria**: ROUTE.md is read at the right point in the orientation order; the header
follow-up comment is resolved.
**Complexity signal**: Low.

### Slice 15: README "Agents running VINE" section
**Goal**: Document the agent/reviewer roles and `agents/`.
**Depends on**: Phases 1-3 (describes what they built).
**Files likely touched**: `README.md` (seam after `## Context Overlays` or under `## How VINE
compares`).
**Acceptance criteria**: a named section covers running VINE headless and the reviewer role;
`agents/` is treated; one screen, plain language, links for depth (PR-description discipline).
**Complexity signal**: Low.

### Slice 16: Trellis artifact-tier checks
**Goal**: Add session-judged checks for the new surfaces.
**Depends on**: Slices 6, 13, 3.
**Files likely touched**: `.claude/commands/trellis.md` (artifact Checks A–D family).
**Acceptance criteria**: checks cover ROUTE.md format, journal route fields, and the Validation
block presence/shape *when present*; they are session-judged and do not gate the
`.vine/.trellis-ok` command-commit stamp; absence of the surfaces is not a failure.
**Complexity signal**: Medium.

### Slice 17: Command Addition Checklist + count sweeps
**Goal**: Update the cross-reference surfaces for the new sections/artifacts.
**Depends on**: All prior slices.
**Files likely touched**: `.vine/context/shared.md` (Command Addition Checklist), `CLAUDE.md`,
`README.md`, `commands/vine/verify.md` (count reference), `references/STATE.md`.
**Acceptance criteria**: counts and cross-references are consistent across CLAUDE.md, README,
STATE.md, and verify.md; the checklist reflects the new surfaces; `/trellis` passes.
**Complexity signal**: Low.

### Tech Debt Integration

- **Prose validation inference** (`vine-verification.md`) — *addressed now* in Slice 5; the
  Validation block replaces the heuristic, with the fallback retained for blockless repos.
- **shared.md mixes rule classes** — *addressed now* in Slice 1 via policy-class markers; the
  policy-only approach contains the labeling risk.
- **Throwaway-marked route scaffolds** — *addressed now*; the spike's `<!-- throwaway scaffold -->`
  markers are replaced by real STATE.md schema in Slices 6, 9, 13.
- **#90 wrong-extraction gap** — *addressed during* Slice 13; the schema forces field correction
  when a mechanism diverges mid-slice, not just a prose note.
- **journal-check mtime observability** — *deferred* (CONTEXT: "observed, not this cycle's fix").
  The hook's fired-and-passed and didn't-fire states are indistinguishable; the fix is hook
  observability/scoping work, orthogonal to routing. Recorded in Backlog Updates.

### Backlog Updates

- **journal-check observability** (new): make `journal-check.sh` emit a visible signal on
  fire-and-pass so it is distinguishable from didn't-fire. Belongs to the hook-scoping debt, not
  the routing layer. Surfaced by the cycle-0 spike (three headless commits, hook never visibly
  fired).
- **Federated knowledge sync** (forward reference, unchanged): stays deferred (2027-shaped, likely
  MCP); per-repo primitives in this cycle must not foreclose it.
- **`.vine/knowledge/<domain>.md`** (#51, cycle 3): durable per-domain knowledge home; the
  calibration substrate evolve will write routing-criteria updates to. Out of scope here.

### Dependencies & Risks

- **Ordering is load-bearing.** The precedence split (Phase 1) must precede any auto-route policy
  (ROADMAP). Phase 2's gate depends on Phase 1's Validation block (leg 1). Phase 3's headless
  contract consumes Phase 2's route and records it via the #90 schema. Phase 4 documents and
  validates all of it.
- **Fuzziest risk: rule-class labeling** (Slice 1). The policy-only marker approach is the
  mitigation; if section boundaries prove ambiguous, the fallback is the ROADMAP's single total
  ordering with explicit policy carve-outs (already the chosen flavor — low residual risk).
- **Interactive fallback must never degrade** (Slices 5, 7). The gate withholds the headless
  option on a missing leg; it must not change the interactive route. Gate-time vs.
  verification-time check is the distinction to hold.
- **Verdict decay** (Slice 7) — volatile legs are re-evaluated at navigate-head; the stamp makes
  drift visible to the reviewer. Mid-run drift during a long headless run is bounded by the
  handoff re-check, not eliminated.
- **Spike platform boundaries** (Slice 12) — nested Agent tool unavailable to subagents;
  `CLAUDE_PROJECT_DIR` unset in subagents; headless auth via `claude setup-token`; actor
  permissions are provisioning-time human authority, not a VINE field; subagents auto-load
  CLAUDE.md. Design against these, don't assume the artifact chain alone carries reviewer context.
- **Agent reports: findings-trustworthy, diagnosis-unverified** (shared.md) — re-verify
  load-bearing root-cause claims with a cheap direct check during implementation.
- **Backward compatibility is a hard gate** (AC 10) — verify an untouched `.vine/` setup against
  every new surface before each phase PR.
- **`.gitignore` interaction** — the `.local` path is gitignored-as-a-domain (a feature); ROUTE.md
  must travel *tracked* with the feature (handle the `.vine/*` + negation pattern explicitly).
