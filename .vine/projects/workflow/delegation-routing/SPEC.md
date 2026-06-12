# Feature Spec: Delegation-Routing Harness Re-scope (roadmap rewrite)
## Date: 2026-06-11
## Built on: CONTEXT.md (2026-06-11)
## Decisions made by: Rob Bruhn

### Problem Statement

VINE already routes by trust at two granularities (verify's scope check, navigate's per-slice
gearing) but the roadmap doesn't treat routing as the organizing process — it's a cycle list
with agent-native work parked at cycle 4. The re-scope rewrites ROADMAP.md around the core
loop **scope → route (per overlay-defined policy) → execute (platform mechanics) → handoff
(artifact contract) → evolve (criteria calibration)**, extending the gearing axis past the
human-attention boundary: **walk-me-through → free-climb → hybrid-parallel → headless**.

The rewrite also syncs issue-level truth (reshaped #54/#53/#57/#55/#52, new cross-actor
issue, freshened #46–50) and repositions the README comparison against the verified field
state. Carried constraints, not reopened: Path A framing, boundary discipline (VINE owns
decision criteria/contracts/handoff artifacts; platform owns execution mechanics; VINE never
implements an agent runner), composition-not-synchronization, backward compatibility as a
hard gate (language carried verbatim).

### Approach

The deliverable is documents and issue bodies — no command-file changes in this feature.
The foundation *design* work (predicate mechanics, precedence labeling, role primitive) is
deliberately deferred to the spike and foundation cycle this roadmap schedules; this feature
writes the contract those cycles execute against.

#### Decisions (all made 2026-06-11, this session)

1. **Routing decision ownership: Option C — delegation policy as overlay content.**
   Default = recommend-and-ratify (today's pattern everywhere); team/company overlays may
   promote scope classes to auto-route. Why: unifies the two seeds already in the repo
   (#55's Decision Delegation = personal layer, #52's team-mode content = team layer) as one
   policy surface, and resolves the #53→#55 dependency inversion by pulling Decision
   Delegation forward as routing-policy content. Hard dependency honored: C activates only
   after the rule-class precedence split exists — a personal overlay must never loosen a
   team gate.

2. **Overlay precedence: rule-class split.** Preference-type rules (narration, formatting,
   engagement defaults) resolve personal-wins; policy-type rules (gates, eligibility,
   blast radius, permission defaults) resolve company-wins. Requires a labeling mechanism
   inside overlay files (today's shared.md mixes classes freely); defined once and
   referenced per the shared-pattern convention. The spike validates that classification is
   mechanical; the roadmap writes in the fallback (single total ordering with policy-class
   carve-outs) so a fuzzy-classification finding doesn't force a redesign.

3. **verification-boundary SPEC (#69): execute as designed**, before/parallel to this
   rewrite, in its own session. Self-contained, closes the last 1.5 polish item, and hands
   the foundation cycle the consolidated verification agent — #54's future wiring target.

4. **Personal layer: CLAUDE.local-style convention.** Vine-namespaced local files following
   Anthropic's existing `.local` pattern — easily gitignored as a domain, scoped per
   mode/role. Why: rides the platform's established convention instead of inventing a
   user-global home and discovery mechanism (guiding principle), and the per-mode/role
   scoping aligns with the role-primitive hypothesis (role = overlay stack + entry point +
   contracts). Supersedes both options CONTEXT.md mapped (`~/.claude`-adjacent global home,
   user-level `.vine`).

5. **Route journaling: PROJECT-MAP + NAVIGATION, no new artifact.** Scope-level route
   recorded in PROJECT-MAP.md (cleanest E3 status surface, already written by every phase
   command); per-slice route + actor attribution recorded as fields on NAVIGATION.md entries
   (append-only, best E3 reconstruction substrate, needs the actor field for E2 regardless).
   Evolve reads both for calibration. Closes the verify-gearing-note gap.

6. **Team-overlay update propagation: plugin update + init recompose.** Team overlays ship
   as plugin content (#57's expanded scope); updates arrive via plugin version bump;
   `vine:init`'s upgrade pass offers explicit recomposition and declining changes nothing —
   the #58/#56 migration pattern applied to overlay distribution.

7. **Cycle ordering: spike → foundation, freshness rides aside.** Cycle 0 = thin
   coordination spike (one shepherd + one auto-agent + one reviewer, one feature, one full
   routing decision end-to-end; ugly scaffolding allowed; answers its six questions).
   Cycle 1 = foundation (precedence rule-class split + #54 reshape + routing policy per C).
   The #46–50 freshness pass runs as `vine:pair` side-track work at any time so headless
   test cases are ready the moment the gate exists. Spike findings may reshape cycle 1
   before it starts — that's the point of running it first.

8. **Feature scope: all four deliverables** (ROADMAP rewrite, issue reshaping, #46–50
   freshness pass, README reposition) in this one feature, single PR.

### Acceptance Criteria

Feature-level (per-slice criteria below):

- ROADMAP.md presents the routing loop as the organizing thesis; every scheduled cycle
  traces to a stage of the loop or is explicitly labeled supporting subsystem.
- The backward-compatibility hard-gate paragraph appears verbatim from the current
  ROADMAP.md.
- GitHub issue bodies and the milestone description are consistent with the rewritten
  roadmap — no issue still describes its pre-reshape scope, no stale `.vine/hooks/` paths,
  no "plan mode" reference.
- README's "How VINE compares" reflects the verified 2026-06 field state.
- All eight decisions above are findable in the rewritten artifacts (roadmap or issue
  bodies), each with its rationale — an E3 reader can reconstruct why without this SPEC.

### Work Slices

### Slice 1: ROADMAP.md rewrite
**Goal**: Rewrite ROADMAP.md around the routing loop as the organizing structure.
**Depends on**: Nothing (this is the source document; all other slices sync to it).
**Files likely touched**: `ROADMAP.md`
**Acceptance criteria**:
- Core loop named up front; gearing extension axis (walk-me-through → free-climb →
  hybrid-parallel → headless) stated as the thesis.
- Boundary discipline strengthened in the guiding principle: VINE owns decision criteria,
  contracts, handoff artifacts; platform owns execution mechanics; VINE never implements an
  agent runner.
- Backward-compat paragraph carried verbatim.
- New cycle table: cycle 0 = coordination spike (its six questions listed in or linked from
  the roadmap); cycle 1 = foundation (rule-class precedence split, #54 reshaped as
  routing-layer eligibility gate, routing policy as overlay content with Decision
  Delegation pulled forward from #55); #53 paired with the foundation; knowledge lifecycle
  (#51/#56) positioned as routing-calibration substrate; team layer (#52 reframed) and
  plugin (#57 expanded) sequenced after the foundation; #46–50 as pair-mode side-track,
  flagged as first headless test cases never scheduled interactively ahead of the
  foundation.
- Precedence fallback written in: if the spike finds rule classification too fuzzy to be
  mechanical, fall back to single total ordering with policy-class carve-outs.
- Decisions 4, 5, 6 recorded where they bind (personal-layer convention, route journaling
  homes, propagation mechanism).
- E1/E2/E3 named as constraints on every primitive; cross-actor live execution state named
  as new-issue territory (#61 stays closed); reviewer and auto-agent roles in scope,
  org-fleet still deferred; evolve's calibration loop (routing outcomes → criteria updates,
  Stop-hook propose-don't-apply plumbing) named; multi-system ingest stays a consumption
  contract; obsolescence discipline (3–6 month config review) applied to every new
  mechanism.
- No stale references: #62 absent from the foundation story, no "plan mode" language.
**Complexity signal**: Medium-High — the thinking is done in CONTEXT.md; the work is
compressing ~15 verified consequences into a document that stays readable as a roadmap.

### Slice 2: Issue reshaping pass
**Goal**: Make GitHub issue-level truth match the rewritten roadmap.
**Depends on**: Slice 1 (issue bodies quote the new framing).
**Files likely touched**: None in-repo — `gh issue edit` / `gh issue create` against
moduloMoments/VINE; milestone description via `gh api`.
**Acceptance criteria**:
- #54 reshaped: composite eligibility predicate (global contract + slice ACs + slice
  independence + bounded blast radius); gate semantic at the routing layer with the
  interactive fallback preserved for non-headless routes; shipped-home constraint noted
  (not STATE.md, not contributor files).
- #53 updated: Decision Delegation dependency resolved per option C; decision
  classification (human-required vs. default-able) retained; structured-handoff block
  flagged as the spike's question 5 subject.
- #57 expanded: team-overlay distribution scope; propagation = plugin update + init
  recompose under the backward-compat gate.
- #55 split: Decision Delegation / Risk Tolerance content moves to routing policy; domain
  levels / Growth Goals stay profile.
  > **Addendum (2026-06-11, navigate)**: Review Preferences (unnamed in this AC) stayed
  > profile-side — it's preference-class content per the rule-class taxonomy.
- #52 reframed: overlay composition at the team layer; tracked-default flip, `.local`
  projects, and conflict-safe conventions explicitly survive.
- New issue(s) filed for cross-actor live execution state: slice ownership, in-flight
  state, handoff payload, and the PAUSE.md / ACTIVE / PROFILE.md redesign under E2 (the
  three broken-under-E2 artifacts; redesigned by the state model, not patched piecemeal).
- Milestone description's "plan mode" staleness fixed.
**Acceptance check**: each edited body reads correctly cold — an actor with no session
context can execute from it.
**Complexity signal**: Medium — mechanical once slice 1 settles the language, but six
bodies plus a new issue each need care; these edits are live and public immediately.

### Slice 3: #46–50 freshness pass
**Goal**: Make the five maintenance issue bodies usable as delegation test cases.
**Depends on**: Nothing (can run before or after slices 1–2; sequenced here to ride the
same session).
**Files likely touched**: None in-repo — `gh issue edit`; possibly `gh issue close` for
#49/#50.
**Acceptance criteria**:
- All five bodies reference `.vine/context/`, not `.vine/hooks/`.
- #49/#50 verified against the live skill descriptions: closed with a comment if already
  landed, updated if not.
  > **Addendum (2026-06-11, navigate)**: #48 also verified as already landed (7/8 commands
  > carry the one-line shared.md profile reference; status.md's variant is deliberate) and
  > closed with the same treatment — engineer's call during slice 3. Surviving side-track
  > set is #46/#47; roadmap row synced.
- Each surviving body is actionable cold — correct paths, current file names, no
  references to pre-rename structure.
**Complexity signal**: Low — verified-mechanical; the #49/#50 check is the only judgment
call.

### Slice 4: README comparison reposition
**Goal**: Rewrite "How VINE compares" against the verified field state using the new
thesis language.
**Depends on**: Slice 1 (thesis language).
**Files likely touched**: `README.md`
**Acceptance criteria**:
- Spec-Kit (111k★, spec-as-artifact camp, skills-based install), Kiro (GA, EARS specs,
  spec-mode price premium), BMAD v6 (role-persona camp on the same skills/subagents
  substrate), Augment Cosmos (team-level shared context; opposite staleness bet —
  persistent index vs. live-read), agent-context (closest #51/#56 prior art; weak on
  staleness/multi-author — the differentiation seam) each positioned accurately.
- AGENTS.md under Linux Foundation AAIF named as substrate to ride, not a competitor.
- The field gap claimed: nobody has standardized the layering above repo scope — that's
  the overlay matrix's territory.
- No stale star counts or product-state claims.
**Complexity signal**: Low-Medium — bounded section rewrite; the risk is tone (public
document, positioning not disparagement).

### Tech Debt Integration

- **Addressed by parallel work**: three-way verification-checklist duplication — owned by
  the #69 SPEC, executing as designed in its own session (decision 3).
- **Addressed during (slice 3)**: #46–50 body staleness.
- **Deferred to foundation cycle**: mtime-based journal-check (wrong primitive for E2);
  precedence-sentence inconsistency in 5 of 9 command loading blocks (rides with whatever
  next touches the loading blocks — the foundation's precedence work will); STATE.md
  pointers dangling in user installs (becomes acute when E3 reviewers need schema; the
  spike's question 3 sizes it).
- **Deferred to new cross-actor issue (filed in slice 2)**: PAUSE.md's five uncoordinated
  deletion triggers; ACTIVE's any-command-deletes-it semantics; PROFILE.md's
  one-engineer-per-repo shape. Consciously not patched piecemeal — the cross-actor state
  model redesigns them together.
- **Consciously accepted**: issue edits in slices 2–3 are unreviewed live changes (no PR
  gate on GitHub bodies). Acceptable solo; the public-first convention means the history
  is auditable.

### Backlog Updates

- File: cross-actor live execution state issue(s) — slice 2 does this.
- Re-prioritized: #54, #53 move to foundation (cycle 1); #57 moves near-core with expanded
  scope; #55 splits; #52 reframes; #46–50 become side-track delegation test cases.
- Unblocked by this feature: the coordination spike (cycle 0) — it needs the rewritten
  roadmap to exist; the foundation cycle behind it.
- Unchanged: #64 (0.5-gated legacy-fallback removal); #36/#42/#43 stay out of scope.

### Dependencies & Risks

- **#69 executes in a separate session.** The foundation cycle assumes the consolidated
  verification agent exists. If #69 stalls, the #54 reshape language (slice 2) should read
  correctly in either state — write it against the contract, not the file layout.
- **The spike can invalidate the rule-class split.** Mitigated in slice 1: the fallback
  (total ordering + policy carve-outs) is written into the roadmap, so a fuzzy finding
  reorders cycle 1's content rather than forcing a roadmap revision.
- **Live issue edits are immediate and public.** Slices 2–3 have no draft stage; navigate
  should present each body for review before `gh issue edit` fires.
- **`gh` auth and repo access** required for slices 2–3.
- **The roadmap is read by future sessions as ground truth.** Errors here propagate into
  every subsequent cycle's verify phase — slice 1's review bar is the highest of the four.
