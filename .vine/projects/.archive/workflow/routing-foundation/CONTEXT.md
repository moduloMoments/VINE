# Feature Context: Routing Foundation (v0.4.0 Cycle 1)
## Date: 2026-06-14
## Author: Rob + Claude

The *route* stage of the v0.4.0 delegation loop (`scope → route → execute → handoff →
evolve`). Implements the four foundation-cycle threads from ROADMAP.md plus two scope
decisions made at verify:

- **#54** — discoverable validation contract + routing-layer eligibility gate
- **#53** — headless autonomy contract (decision classification + structured handoff)
- **#55 (policy half)** — Decision Delegation as routing-policy overlay content
- **Rule-class precedence split** — preference-type (personal-wins) vs policy-type (company-wins)
- **Personal `.local` overlay layer** — built this cycle (verify decision), so the precedence
  split has a real second layer to resolve against
- **#90 (all of it)** — journal-schema fixes folded in (verify decision), since route
  journaling depends on the same NAVIGATION.md / PROJECT-MAP.md schema

The cycle's center of gravity is one convergent artifact the spike (cycle 0) pointed at: a
**durable gate record** (verdict + constraints + allowlist + validation baseline) that the
headless envelope embeds, the reviewer reads, and the PROJECT-MAP Route table links to.

### Codebase Landscape

**The two routing axes (orthogonal, only one exists today).**
- **Gear** — engagement level *within* a session. Mature: `commands/vine/navigate.md:167–188`
  defines "Free climb" / "Walk me through this" with mechanical consequences (free-climb skips
  narration step 3b and review pauses 3c). Profile level shapes the recommendation
  (`navigate.md:190–193`). Verify previews a gearing default in its completion block
  (`verify.md:339–344`).
- **Route** — actor type + delivery mechanism (interactive / headless / headless-reentry). The
  spike introduced it as NAVIGATION.md `**Route**:`/`**Actor**:` fields and a PROJECT-MAP
  `### Route` table, but **nothing in the commands or STATE.md defines it**. The gearing axis
  extends past the human-attention boundary into `hybrid-parallel → headless` (ROADMAP core loop).

**Eligibility gate (#54).** No command home today — the spike ran the composite predicate by
hand (`coordination-spike/NAVIGATION.md` Slice 1). Predicate legs: (1) global validation
contract exists, (2) slice ACs present in SPEC.md, (3) slices independent of in-flight work,
(4) blast radius bounded/enumerable. Absence of any leg ⇒ ineligible for headless; the scope
routes interactively. Gate semantics live at routing time, never degrade interactive fallback.

**Validation contract (#54).** Today `agents/vine-verification.md:95–99` infers commands by
prose: scans `package.json` scripts, config files, then three phase overlays
(`navigate.md`/`evolve.md`/`pair.md`), falling back to "no automated checks configured." This
agent is the consolidated single verification surface (#69, `vine-verification.md:38–49`).
Target: a fenced YAML `## Validation` block in `shared.md` (lint/typecheck/test/test-all/
build/extra) that init scaffolds and the agent + navigate + evolve + pair consume. STATE.md
already names this block as the home for any future validation contract (`STATE.md:244`).

**Overlay layers + precedence.** `shared.md` (130 lines) mixes rule classes with **no labeling
mechanism**: `## Collaboration Stance` and `## Engineer Profile Protocol` are preference-type;
`## CI/CD` (trellis-gate, main-guard, publish) is hard policy-type; `## Project Conventions`
and `## Skill Workflows` are mixed. The starkest collision: Collaboration Stance (personal-wins)
sits four sections above CI/CD (company-wins) with zero class signal. The personal `.local`
layer is **entirely unimplemented** — referenced only as "decided" in ROADMAP.md:119 and as a
`.vine.local/` backlog idea in `STATE.md:374,401`. No `.local` load instruction exists in any
command's "Load Context Overlays" step.

**Headless / autonomy (#53).** **Zero** mentions of "headless / --headless / autonomous /
Decisions Taken Autonomously" across all 11 commands. The autonomy split exists only as spike
artifacts (delegation-prompt files, SPEC decision). Navigate has a proto-version at
`navigate.md:229–238` ("surface decisions, don't make them silently") but framed as interactive
collaboration, not a headless contract. ~30 AskUserQuestion sites across 8 commands need
human-required vs default-able classification (mapped in full — see Current State).

**Journaling homes (#90).** STATE.md NAVIGATION.md template (`STATE.md:115–135`) and
PROJECT-MAP.md template (`STATE.md:248–272`) carry **no** Route/Actor/Gear fields and no Route
table — those exist only as throwaway-tagged scaffolds in the spike's artifacts (validated, all
KEEP-tagged in `coordination-spike/EVOLUTION.md:37–43`). #90's five fixes: Gear field, Validation
rollup token (`pass`/`fail` first), multi-commit `+`-separated Commit, section-scoped `(slice N)`
attribution for `Decisions Taken Autonomously`, controlled Route vocabulary + labeled
`mechanism:` token. Plus formalizing `(decided by:)` + confidence tags.

**Distribution surfaces.** `commands/vine/init.md:37–53` discovers tooling but writes it to a
freeform `## CI/CD` prose placeholder (`init.md:75–128` template) — needs to scaffold the
structured Validation block. `.claude/commands/trellis.md` has Checks 1–10 (command) + A–D
(artifact); none validate a Validation block, journal route fields, or a gate record. README
(~399 lines) has no Agents section; the seam is after `## Context Overlays` or under `## How
VINE compares` (line 364 already says "hybrid-parallel and headless on the roadmap"). `.gitignore`
uses `.vine/*` + selective negation (`!.vine/context/`, `!.vine/projects/`, `!.vine/scripts/`;
ignores PAUSE.md, PROFILE.md) — any new `.vine.local/` or gate-record dir is ignored by default
unless explicitly handled.

### Current State

**Works / available to build on:**
- Gear axis (navigate) — the one mature routing primitive; route axis layers beside it.
- `vine-verification` consolidated surface (#69) — single consumer to point at the Validation block.
- init tooling discovery (Step 1) already finds the commands; only the write target changes.
- `journal-check.sh` hook + mtime guarantee — works regardless of artifact tracking.
- Spike-validated scaffolds — Route table was the "best-performing scaffold"; route/actor fields
  parsed mechanically except gear (0/5). The schema is de-risked; this cycle promotes it.
- `review.md` — the reviewer role recipe, already a durable overlay; cycle 1 adds "read the gate
  record" to its orientation order (noted in its header provenance comment).

**Absent / to build:**
- Headless mode + autonomy classification (every AskUserQuestion site). Classification map:
  - *Human-required:* domain familiarity (`verify.md:43–59`), domain/slug confirm
    (`verify.md:251–255`), every inquire design decision (`inquire.md:98–113`), spec sign-off
    (`inquire.md:316–320`), follow-up/CLAUDE.md/overlay acceptance (`evolve.md:157,222,280`),
    blocker resolution (`navigate.md:337–341`), pause notes (`pause.md:84`), PR-number backfill
    (`resume.md:137`), ambiguous pair intent (`pair.md:80`).
  - *Default-able:* scope check (`verify.md:163`), multi-PR tracking (`inquire.md:209`), per-slice
    gearing (`navigate.md:167`), between-slice continuation (`navigate.md:373`), test-coverage
    defer (`navigate.md:447`), profile/growth updates (`evolve.md:323,344,370`), resolved/PR
    prompts (`evolve.md:459,507`), commit confirm (`pair.md:129`), all feature-selection prompts.
- Eligibility-gate command home + durable gate record (home undecided — top open question).
- Validation YAML block (schema, init scaffold, agent/navigate/evolve/pair consumers, fallback).
- Personal `.local` layer (load + precedence resolution in every command's overlay step) — **in
  scope this cycle** per verify decision.
- Rule-class labeling in `shared.md` + precedence rule (approach deferred to inquire).
- Decision Delegation routing-policy overlay content (#55 policy half).
- #90 journal-schema fields in STATE.md templates + the commands that write them.
- README "Agents running VINE" section; trellis checks for the new surfaces.

### Edge Cases & Tribal Knowledge

- **Backward compatibility is a hard gate** (ROADMAP.md:101–105). Existing `.vine/` setups must
  work unchanged, or init's upgrade pass offers explicit migration and declining changes nothing.
  Patterns to copy: the #58 rename fallback, the #56 backfill mode. Every new field/block/layer
  must be optional with graceful absence.
- **Interactive fallback ≠ gate.** #54's gate makes a scope *ineligible for headless* when a leg
  is missing; the same absence must never degrade interactive routes (today's prose inference
  continues). Gate-time check vs verification-time check is the distinction that lets both coexist.
- **Spike platform boundaries** (from `coordination-spike/EVOLUTION.md`, Q2): nested Agent tool
  unavailable to subagents; `CLAUDE_PROJECT_DIR` unset in subagents; headless auth =
  `claude setup-token`; **actor permissions are a provisioning-time human authority** (not a
  VINE artifact field). Subagents auto-load CLAUDE.md — answered one load-bearing reviewer
  question "for free," so don't assume the artifact chain alone carried it.
- **Verdict decay** — the gate's independence leg went stale within hours during the spike. The
  gate record needs a freshness/decay semantic, not a static stamp.
- **Requirement-implied blast radius** — occurrence-grep missed files implied by a requirement
  but not named (the spike's F1 root cause). Bounded-blast-radius can't be pure file enumeration.
- **Agent reports: findings-trustworthy, diagnosis-unverified** (shared.md Tooling Notes) — three
  accurate spike subagent reports, one inverted root cause. Re-verify load-bearing root-cause
  claims with a cheap direct check.
- **`.gitignore` interaction** — `.vine/*` + negation means a new `.vine.local/` root or any
  gate-record directory is ignored unless explicitly negated/handled. The personal layer is
  *meant* to be gitignored-as-a-domain, so this is a feature for `.local` but a trap for a
  gate record that should travel with a tracked feature.
- **Trellis stamp tiers** — command Checks 1–10 + Check 10 anchors gate the `.vine/.trellis-ok`
  stamp; artifact Checks A–D are session-judged and don't affect it. A new gate-record or
  Validation-block check must consciously pick a tier.
- **Mode mismatch was free** (spike) — #47 is pair-shaped per the roadmap but ran navigate-shaped
  headless with zero friction. Route shape and ceremony weight are independent axes — keep gear
  and route orthogonal in the schema.

### Tech Debt in Affected Areas

- **Prose validation inference** (`vine-verification.md:95–99`) — fragile multi-file heuristic;
  the Validation block is its replacement, but the fallback path stays for blockless repos.
- **shared.md mixes rule classes** — pre-existing; the precedence split is the fix, but labeling
  130 lines of mixed content is the cycle's fuzziest mechanical risk (ROADMAP.md:127–133).
- **Throwaway-marked route scaffolds** — the spike's `<!-- throwaway scaffold -->` HTML markers
  get replaced by real STATE.md schema entries at adoption (EVOLUTION.md Scaffold Dispositions).
- **#90 wrong-extraction gap** — one mechanically-extracted journal value was *wrong* (a stale
  field a prose correction didn't fix). Schema must force field correction, not just prose, when
  a mechanism diverges mid-slice.
- **journal-check mtime never visibly fired** across three headless commits (fired-and-passed vs
  didn't-fire indistinguishable) — feeds the hook-scoping debt; observed, not this cycle's fix.

### Documentation Gaps

- **README** — no "Agents running VINE" section (#53 AC); no named treatment of `agents/`.
- **STATE.md templates** — NAVIGATION.md and PROJECT-MAP.md lack Route/Actor/Gear + Route table +
  gate-record pointer; PROFILE.md format may need the #55 split note (Decision Delegation absent).
- **review.md** — orientation order needs "read the durable gate record" once it exists (its
  header already flags this as the cycle-1 follow-up).
- **Command Addition Checklist** (shared.md:19–24) — any new surface must update CLAUDE.md count,
  README, STATE.md, verify.md count. Applies to the Validation block + headless sections.

### Open Questions

1. **Gate-record durable home** (top priority). The convergent design move. Can't live in
   STATE.md (doesn't ship via create-vine) or contributor scripts (#54 shipped-home constraint;
   #69 precedent = `agents/vine-verification.md`). Candidates: a new per-feature artifact (e.g.
   `ROUTE.md`/`GATE.md` in the feature dir), a section embedded in PROJECT-MAP.md (extends the
   validated Route table), or a shipped-overlay home. Must carry verdict + constraints + allowlist
   + validation baseline, embed in the envelope, be reviewer-readable, and link from PROJECT-MAP.
2. **Rule-class precedence approach** (deferred to inquire). Per-rule preference/policy labeling
   vs the ROADMAP fallback (single total ordering + policy carve-outs). The spike tested the
   delegation loop, *not* this — cycle 1 is where it's exercised for the first time. The personal
   layer being in scope means this must actually resolve at load time, not stay theoretical.
3. **Personal `.local` composition** — how does `.local` load and compose in every command's "Load
   Context Overlays" step? Read-order (shared → personal, personal-wins on preference) vs a formal
   labeled resolver. Backward-compat: absent `.local` changes nothing.
4. **Decision Delegation content shape** — which decision *classes* are default-able by policy, and
   how is the override expressed as overlay content (#55 policy half)? Must align with the
   per-command human-required/default-able classification.
5. **Gate-record check tier in trellis** — stamp-gating (command tier) or session-judged
   (artifact tier)? Ties to #54's "trellis validates the block's presence/shape when it exists."
6. **Multi-PR slicing** — the precedence split must land *first within the cycle* (ROADMAP.md:147:
   "promoting any scope class to auto-route is unsafe without it"). Inquire sets the phase-group
   order; likely: precedence + Validation block → gate + record → headless contract + journaling →
   docs/trellis. #90 schema folds into the journaling phase group.
7. **Verdict decay mechanism** — does the gate record carry a freshness/expiry field, or is
   re-validation a reviewer/route-time obligation? (From the spike's independence-staleness finding.)
