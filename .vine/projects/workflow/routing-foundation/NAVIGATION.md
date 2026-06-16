# Navigation Log: Routing Foundation (v0.4.0 Cycle 1)
## Date: 2026-06-14

Implementing Phase 1: Precedence & Validation Foundation (Slices 1-5). Session run in
free-climb gearing with an agent-team read fan-out for live-state refresh (verify's line refs
predated main's #92). Authoring stays interactive under engineer review.

### Slice 1: Overlay precedence — policy-class markers + rule — Complete
- **Started**: 2026-06-14 16:12
- **Commit**: 0c81247
- **Approach taken**: Added a single `## Overlay Precedence` section at the top of
  `.vine/context/shared.md` defining the resolution rule once — flat personal-wins with policy
  carve-outs, mirroring Claude's own settings (local overrides project except an immutable
  policy ceiling). Marked `## CI/CD` and `## Team Context` with `<!-- class: policy -->`
  directly under each heading. Unmarked sections are preference by definition.
- **Deviations from spec**: None. (The Slice-1 AC permits marking "any policy subsections under
  Project Conventions"; see Decisions for why none were marked.)
- **Validation**: pass — structural check: both policy markers placed under their headings
  (shared.md:137, :145), the Overlay Precedence section resolves to one referenceable home
  (shared.md:4). No lint/test suite is configured for overlay files; markdown renders clean.
- **Decisions made during implementation**:
  - Marked only CI/CD + Team Context as policy, not any Project Conventions subsection —
    honors design decision #3 ("policy-only approach minimizes the immutable surface / lowest
    fuzziness"). Command Addition Checklist is the one borderline case; left as preference and
    flagged to the engineer rather than marked. (decided by: claude — pending engineer ratify)
  - Named the personal layer `shared.local.md` (the platform's `CLAUDE.local.md` convention,
    design decision #4). Slice 2 implements its load + gitignore. (decided by: claude)
  - Placed Overlay Precedence as the first `##` section for prominence — other surfaces (the
    `.local` load step, init upgrade, reviewer orientation) reference it. (decided by: claude)
- **Acceptance criteria**:
  - [x] `CI/CD` and `Team Context` carry an HTML-comment class marker
  - [x] A single "Overlay Precedence" rule states flat personal-wins with policy carve-outs,
        defined once for other surfaces to reference
  - [x] Unlabeled sections are treated as preference (stated explicitly in the rule)
  - [ ] "Any policy subsections under Project Conventions" carry a marker — none marked by
        design (see Decisions); permissive clause, not a mandate
- **Engineer feedback incorporated**: Session approach set by engineer up front — agent-team
  read fan-out + free climb.
- **Learnings**:
  - Engineer → Claude: None specific to this slice.
  - Claude → Engineer: The policy-only marking keeps the immutable surface as small as
    possible; everything defaults to personal-overridable, matching the Claude-settings
    local-wins-with-policy-ceiling model the design points at.

### Slice 2: Personal `.local` layer — load + class-gated override — Complete
- **Started**: 2026-06-14 16:40
- **Commit**: bc5d5ca
- **Approach taken**: Defined the personal-layer load+compose rule once in `shared.md`'s
  Overlay Precedence section (file `shared.local.md`, read after `shared.md` + the phase
  overlay, composed by the precedence rule). Added a two-line step 4 referencing that rule to
  the Load Context Overlays section of all 9 product commands (verify, inquire, navigate,
  evolve, pair, pause, resume, status, optimize). Added `.vine/context/*.local.md` to
  `.gitignore` so the personal layer is gitignored by design.
- **Deviations from spec**: None.
- **Validation**: pass — `/trellis` 11/11 commands + 8/8 cross-reference anchors (stamp
  written); grep confirms step 4 in all 9 commands and the rule defined once at shared.md:18;
  `.gitignore:21` ignores the local path.
- **Decisions made during implementation**:
  - File named `shared.local.md` (the platform's `CLAUDE.local.md` convention). (decided by: claude)
  - Referenced the rule from each command rather than inlining the full instruction —
    honors the shared-pattern convention noted in CLAUDE.md (~150 tokens/command saved).
    (decided by: claude)
  - gitignore pattern is `*.local.md` (not just `shared.local.md`) so future per-phase
    personal overlays are covered by the same rule. (decided by: claude)
- **Acceptance criteria**:
  - [x] Load order is shared → `.local`; `.local` overrides only non-policy content (per the
        Overlay Precedence rule it composes by)
  - [x] The instruction is defined once and referenced (shared-pattern convention)
  - [x] Absent `.local` changes behavior nowhere (each step 4 is "if it exists … absent it,
        nothing changes")
  - [x] `.gitignore` handles the `.local` path (gitignored as a domain by design)
- **Engineer feedback incorporated**: None this slice.
- **Learnings**:
  - Engineer → Claude: None specific to this slice.
  - Claude → Engineer: The 9 overlay sections vary in their step 1–3 wording but share a
    verbatim-identical legacy-fallback paragraph — anchoring the insertion on that shared
    paragraph made the 9 edits a single mechanical pattern instead of 9 bespoke ones.

### Slice 3: Validation YAML block — schema + STATE.md home — Complete
- **Started**: 2026-06-14 16:55
- **Commit**: ea8e30b
- **Approach taken**: Added a `## Validation` section to `shared.md` documenting six optional
  keys (`lint`/`typecheck`/`test`/`test-all`/`build`/`extra`) with a fenced YAML instance for
  this repo. Since VINE is pure markdown with no compile/test toolchain, the instance declares
  only `extra: [sh .vine/scripts/trellis-check.sh]` — which also demonstrates graceful partial
  population. Updated STATE.md's line-244 note from a forward reference ("the Validation block
  proposed in #54 is its home") to a pointer at the now-real block, naming the keys and the
  prose-inference fallback.
- **Deviations from spec**: None.
- **Validation**: pass — structural check: `## Validation` section present in shared.md with
  all six keys documented and a well-formed YAML block; STATE.md:244 points at the real schema.
  No `commands/vine/` files touched, so the trellis command gate is not involved.
- **Decisions made during implementation**:
  - Placed `## Validation` immediately before `## CI/CD` (operationally adjacent) and left it
    unmarked = preference: validation commands are personally overridable, unlike the
    policy-class CI/CD enforcement. (decided by: claude)
  - This repo's instance populates only `extra` — honest (no lint/test/build exists) and
    doubles as the canonical partial-population example. (decided by: claude)
- **Acceptance criteria**:
  - [x] Block defines lint/typecheck/test/test-all/build/extra keys with documented optionality
  - [x] STATE.md references the real schema (line 244)
  - [x] The block is optional (blockless repos fall back — stated in the section + STATE.md note)
- **Engineer feedback incorporated**: None this slice.
- **Learnings**:
  - Engineer → Claude: None specific to this slice.
  - Claude → Engineer: Defining the schema and shipping this repo's (near-empty) instance in
    the same block makes the optionality contract self-documenting — the example *is* the
    blockless-fallback demonstration.

### Slice 4: init scaffolds the Validation block — Complete
- **Started**: 2026-06-14 16:56
- **Commit**: b47e71c
- **Approach taken**: Added a `## Validation` section to init's shared.md template and a
  Validation bullet to the upgrade-mode required-sections checklist (declinable — declining
  leaves prose inference and changes nothing on disk). Narrowed the now-overlapping `## CI/CD`
  placeholder to enforcement/pipeline context so runnable check commands have one home.
- **Deviations from spec**: None.
- **Validation**: pass — `/trellis` 11/11 commands + 8/8 anchors (stamp written 16:56).
- **Decisions made during implementation**:
  - Template uses a bracketed *instruction* to write the YAML block rather than a literal
    nested fence — the template is itself inside a ```markdown fence, so a nested ```yaml would
    terminate it. The instruction points at the canonical schema (STATE.md + framework
    shared.md). (decided by: claude)
  - Narrowed the CI/CD placeholder to enforcement context to avoid telling engineers to put
    check commands in two sections. (decided by: claude)
- **Discovered item (out of Slice 4 scope)**: init's template does NOT scaffold the
  `## Overlay Precedence` / Personal-layer sections (Slices 1–2 added those only to this repo's
  shared.md). A fresh repo's commands (post-Slice-2) therefore reference a "Personal layer rule
  in shared.md" that a freshly-init'd shared.md won't contain. Common case is graceful (absent
  `shared.local.md` ⇒ the load step is a no-op), but the reference dangles if a fresh-repo
  engineer creates a `.local`. Flagged for the Phase-1 boundary — decide whether to fold
  precedence-template scaffolding into this cycle or defer.
- **Acceptance criteria**:
  - [x] Fresh repos get the block from the template
  - [x] Upgraded repos get it from the checklist
  - [x] Declining the upgrade changes nothing on disk
- **Engineer feedback incorporated**: None this slice.
- **Learnings**:
  - Engineer → Claude: None specific to this slice.
  - Claude → Engineer: A template that lives inside a fenced code block can't carry nested
    fences — instruct-to-generate is the clean pattern there, and it keeps the schema
    single-homed instead of duplicating the YAML into the template.

### Slice 5: Wire Validation-block consumers — Complete
- **Started**: 2026-06-14 16:57
- **Commit**: 3a26f48
- **Approach taken**: Rewrote `vine-verification`'s tool-discovery section into an explicit
  priority order — (1) the `## Validation` block in shared.md, preferred and authoritative when
  present; (2) prose inference (package.json / config files / phase overlays) as the fallback;
  (3) "no automated checks configured". The original prose-inference bullets are preserved
  verbatim as step 2, so blockless repos are unchanged. Added a one-line reference to the
  `## Validation` block (with the fallback noted) at each consumer site: navigate step 4a,
  evolve's cross-slice integration check, and pair's Validate step.
- **Deviations from spec**: None.
- **Validation**: pass — `/trellis` 11/11 commands + 8/8 anchors; the fallback path in
  `vine-verification.md` is intact (prose inference is step 2, "no checks" is step 3), so the
  blockless-repo behavior is byte-for-byte the prior heuristic.
- **Decisions made during implementation**:
  - Kept the existing prose-inference bullets verbatim as the fallback step rather than
    rewording — the AC requires "no regression for blockless repos", so preserving the exact
    heuristic is the safest expression of that. (decided by: claude)
- **Acceptance criteria**:
  - [x] The agent prefers the block when present and falls back to prose inference when absent
  - [x] navigate / evolve / pair reference the contract
  - [x] No regression for blockless repos (fallback preserved unchanged)
- **Engineer feedback incorporated**: None this slice.
- **Learnings**:
  - Engineer → Claude: None specific to this slice.
  - Claude → Engineer: Expressing "no regression" as *literally preserving* the old path (as a
    numbered fallback step) is more defensible than rewording it — the diff shows the old
    behavior is still exactly reachable.

### Phase-1 boundary fix: init template precedence (closes the Slice 4 discovered item) — Complete
- **Started**: 2026-06-14 17:05
- **Commit**: 53b0200
- **Approach taken**: The phase-group + backward-compat verification (both via agent fan-out)
  confirmed all Phase-1 ACs pass and AC-10 is PASS, surfacing one coherence gap: init's
  shared.md template (fresh repos) lacked the `## Overlay Precedence` section, the Personal-layer
  rule, and the `<!-- class: policy -->` markers that Slices 1–2 added only to this repo's
  shared.md. Engineer chose to fix in-phase. Added all three to init's template so fresh repos
  resolve precedence and their commands' step-4 reference points at a rule their shared.md
  actually contains.
- **Deviations from spec**: None — this completes Slices 1–2's intent ("commands reference it",
  works on fresh installs) for the create-vine distribution path, which the original slices
  scoped only to this repo.
- **Validation**: pass — `/trellis` 11/11 commands + 8/8 anchors (stamp 17:06); init template now
  carries Overlay Precedence + 2 policy markers (grep: 4 hits).
- **Decisions made during implementation**:
  - Trimmed the template's Overlay Precedence to the self-contained rule (dropped the
    "other surfaces reference it" tail that only applies in this repo's fuller context).
    (decided by: claude)
- **Acceptance criteria** (re-confirmed at boundary):
  - [x] Fresh repos now get Overlay Precedence + Personal-layer rule + policy markers from init
  - [x] A fresh repo's command step-4 reference resolves to a rule its shared.md contains
- **Engineer feedback incorporated**: Engineer chose "fix now in Phase 1" at the boundary
  decision over deferring or spinning out a separate task.
- **Learnings**:
  - Engineer → Claude: Prefer closing a coherence gap the phase group itself created in-phase,
    rather than carrying a known-graceful-but-incoherent wart across the cycle's other PRs.
  - Claude → Engineer: A slice that edits both a repo's live overlay AND the init template needs
    to touch *both* in the same breath — editing shared.md without the template is the exact
    drift class the boundary verification caught.

## Phase 2: Eligibility Gate & Route Record (Slices 6-9)

Resumed 2026-06-14 17:20 in free-climb gearing (engineer choice; profile confident/workflow).
Branch synced to origin/main (the #94 squash-merge) before starting. Building the route
decision: the gate record (ROUTE.md), the navigate-head gate, the inquire preview, and the
PROJECT-MAP pointer.

### Slice 6: ROUTE.md artifact format in STATE.md — Complete
- **Started**: 2026-06-14 17:25
- **Commit**: 172867b
- **Approach taken**: Added a `### ROUTE.md` State File section to `references/STATE.md`, placed
  in chain order between SPEC.md and NAVIGATION.md (the route is decided before slices execute).
  The template carries the six required pieces — Verdict (controlled `interactive |
  headless | headless-reentry` route + `mechanism:` token), Eligibility Legs (the four-leg #54
  predicate as a checklist), Constraints, Allowlist, Validation Baseline, Input Basis (HEAD SHA +
  in-flight set) — plus an optional Decay note and a `## Computed at:` stamp. Reused the spike's
  validated vocabulary (Route table was its best-performing scaffold; verdict + constraints +
  allowlist + validation baseline is the convergent finding from EVOLUTION.md:29). Added ROUTE.md
  to the Source of Truth table (authoritative for the route decision; PROJECT-MAP Route table is
  its derived view — wired in Slice 9), to the Committing Artifacts artifact list, and as a new
  "Navigate head" commit-point row. Documented graceful absence and tracked-travel (lives under
  the already-negated `!.vine/projects/`, so no `.gitignore` change needed).
- **Deviations from spec**: None.
- **Validation**: pass — `sh .vine/scripts/trellis-check.sh` 11/11 commands + 8/8 cross-reference
  anchor pairs (the two new internal links — `#source-of-truth-vs-derived-views`,
  `#committing-artifacts` — resolve to existing headers). Structural check: all six required
  fields present with `<!-- required -->` markers; Decay carries `<!-- optional -->`. No
  `commands/vine/` files touched, so the trellis command-commit gate is not involved.
- **Decisions made during implementation**:
  - Placed ROUTE.md in chain order between SPEC.md and NAVIGATION.md but labeled it "produced by
    vine:navigate at head, previewed by vine:inquire" — the artifact's logical position (route
    decided before implementation) differs from its writer (navigate). (decided by: claude)
  - Verdict uses the spike's controlled route vocabulary + `mechanism:` token rather than a free
    field, aligning ahead of the #90 schema work in Slice 13. (decided by: claude)
  - Kept Slice 6 scoped to `references/STATE.md` per the SPEC's file mapping. CLAUDE.md's
    "State Artifact Chain" line still reads CONTEXT → SPEC → NAVIGATION → EVOLUTION (no ROUTE);
    that cross-reference is Slice 17's sweep ("cross-references consistent across CLAUDE.md …").
    Flagged here so Slice 17 doesn't miss it. (decided by: claude)
- **Discovered item (for Slice 17)**: CLAUDE.md `## State Artifact Chain` line omits ROUTE.md;
  fold into the Slice 17 cross-reference sweep alongside the count updates.
- **Acceptance criteria**:
  - [x] Format carries verdict + constraints + allowlist + validation baseline + computed-at +
        input basis (HEAD SHA, in-flight set)
  - [x] Section headings carry required/optional markers
  - [x] The record is documented as travelling tracked with the feature
- **Engineer feedback incorporated**: Gearing set to free climb up front.
- **Learnings**:
  - Engineer → Claude: None specific to this slice.
  - Claude → Engineer: Reusing the spike's already-validated scaffold vocabulary (route verdict,
    `mechanism:` token, the verdict+constraints+allowlist+baseline quartet) made the format a
    promotion of proven shapes rather than a fresh design — the de-risking the spike paid for.

### Slice 7: Navigate-head gate evaluation + ROUTE.md write + re-eval — Complete
- **Started**: 2026-06-14 17:30
- **Commit**: 92c13ad
- **Approach taken**: Added a `### Route the Work — Eligibility Gate (runs once, at head)`
  section to `commands/vine/navigate.md`, placed between step 2 (Create a Feature Branch) and
  step 3 (Implement One Slice at a Time) — navigate-head, after setup, before the slice loop.
  The section: (1) frames interactive as the default, never-gated path and the gate as a no-op
  for ordinary human-driven sessions; (2) runs the real four-leg predicate only when a headless
  route is on the table (entered headless — Phase 3 — or the engineer asks to delegate);
  (3) evaluates all four legs against fresh repo state, with blast radius as the reasoned set
  (Files-likely-touched + requirement-implied files, not raw grep — the spike's F1 root cause);
  (4) marks independence + blast radius as volatile and mandates recompute (never trust a prior
  ROUTE.md); (5) writes ROUTE.md with verdict, legs, constraints, allowlist, validation baseline,
  input basis (`git rev-parse --short HEAD` + in-flight set), and the computed-at stamp;
  (6) handles resume (recompute volatile legs, rewrite stamp) and graceful absence.
- **Deviations from spec**: None.
- **Validation**: pass — `/trellis` (via `sh .vine/scripts/trellis-check.sh`) 11/11 commands +
  8/8 cross-reference anchors; `.vine/.trellis-ok` stamp written `status: pass` 17:33 (the commit
  ticket for this command-file change). Frontmatter intact (4 fields). The new section is
  unnumbered, so no step renumbering and no broken `step N` cross-references.
- **Decisions made during implementation**:
  - Inserted the gate as an **unnumbered** `###` section rather than a new numbered step 3.
    Renumbering would have rippled through navigate.md (`step 3b/3c/3d`, `step 4`, `step 6`,
    `step 8`) and `references/STATE.md` (`step 4c`, `step 6`, `step 8` pointers) — the exact
    rename-without-updating-references drift class trellis Check 10 exists to catch. Unnumbered
    keeps every cross-reference valid and signals "runs once at head," distinct from the
    per-slice loop. (decided by: claude)
  - Made the interactive path the explicit default and the gate a no-op for it — the AC's
    "no change to today's interactive flow" is satisfied by *not touching* the per-slice loop
    at all; the gate only ever adds the headless option, never gates interactive. (decided by:
    claude)
  - Kept the headless *entry signal* deliberately vague ("a later phase") — entry + the
    headless contract are Slice 12 (Phase 3); Slice 7 only produces the verdict and record.
    (decided by: claude)
- **Acceptance criteria**:
  - [x] Predicate legs (validation contract, slice ACs, independence, bounded blast radius)
        evaluated against fresh repo state
  - [x] Bounded blast radius accounts for requirement-implied files, not just occurrence-grep
  - [x] A missing leg yields headless-ineligible and routes interactively with no change to
        today's interactive flow
  - [x] ROUTE.md is written with the stamp and input basis
  - [x] The step is a no-op for clearly-interactive runs
- **Engineer feedback incorporated**: None this slice (free climb).
- **Learnings**:
  - Engineer → Claude: None specific to this slice.
  - Claude → Engineer: For the cycle's highest-risk slice, the safest expression of "don't
    degrade the interactive path" was structural — add a head-only section and leave the entire
    per-slice loop untouched, so the diff *shows* the interactive flow is unchanged rather than
    asserting it. The unnumbered-section choice was the same instinct: change nothing that's
    referenced by position.

### Slice 8: Inquire route preview (non-binding) — Complete
- **Started**: 2026-06-14 17:36
- **Commit**: 766af0c
- **Approach taken**: Added a `🧭 Route preview (non-binding):` line to inquire.md's completion
  block, placed after the `🔄 /clear` recommendation and before the `🌱 retro` — modeled on
  verify.md's `🧭 Navigate gearing note:` line. It previews the likely route by reading the
  four-leg predicate against the spec as written, and states explicitly that it does not write
  ROUTE.md and that navigate's head gate makes the binding call by re-evaluating volatile legs.
- **Deviations from spec**: None against the ACs. Note: the spec's file hint says "alongside the
  existing gearing preview" in inquire, but the gearing preview actually lives in verify.md's
  completion block (`🧭 Navigate gearing note:`), not inquire's. I modeled the route preview on
  that verify pattern and placed it in inquire's completion block as the ACs require — the
  intent (a non-binding preview mirroring the gearing-note style) is met. Not a spec deviation
  to annotate: the phrase is descriptive context, not an acceptance criterion.
- **Validation**: pass — `sh .vine/scripts/trellis-check.sh` 11/11 + 8/8 anchors; grep confirms
  the non-binding language ("does not write ROUTE.md", "makes the binding call").
- **Decisions made during implementation**:
  - Placed the preview before the retro (end of block), matching verify's placement of its
    `🧭` note at the block tail. (decided by: claude)
  - Phrased it as a bracketed instruction (like the gearing note) so inquire fills it from the
    actual spec at runtime, rather than hardcoding a verdict. (decided by: claude)
- **Acceptance criteria**:
  - [x] The preview is explicitly non-binding
  - [x] It does not write ROUTE.md
  - [x] Navigate's evaluation remains authoritative
- **Engineer feedback incorporated**: None this slice (free climb).
- **Learnings**:
  - Engineer → Claude: None specific to this slice.
  - Claude → Engineer: The spec's cross-reference to "inquire's gearing preview" was off by one
    command (it's verify's) — caught by grepping for `gear` in inquire.md before assuming. Cheap
    direct check beats trusting a spec's incidental file note (shared.md: diagnosis-unverified).

### Slice 9: PROJECT-MAP Route table as derived pointer — Complete
- **Started**: 2026-06-14 17:40
- **Commit**: 42b576a
- **Approach taken**: Added a `### Route <!-- optional -->` table to the PROJECT-MAP.md template
  in `references/STATE.md` (after Milestones): columns `Scope | Route | Gate record`, with the
  Gate-record cell linking to `./ROUTE.md` and Route using the controlled vocabulary
  (interactive | headless | headless-reentry). Added a "Route table is a derived pointer" design
  constraint and folded the Route row into the existing PROJECT-MAP derived-view bullet in the
  Source of Truth section (when it disagrees with ROUTE.md, ROUTE.md wins) and into the
  navigate-updates lifecycle note. Added a "Point PROJECT-MAP.md at it" instruction to navigate's
  gate section — when navigate writes ROUTE.md and PROJECT-MAP.md exists, it adds/updates the
  Route row; skips silently when PROJECT-MAP.md is absent.
- **Deviations from spec**: None. Kept columns to `Scope | Route | Gate record` (the derived
  pointer Slice 9 needs); the spike's fuller `Actor`/`Outcome` columns are headless-execution
  concepts that Slice 13 (#90 journal schema) owns — not added prematurely here.
- **Validation**: pass — `sh .vine/scripts/trellis-check.sh` 11/11 + 8/8 anchors; the new
  template heading carries an `<!-- optional -->` marker (no unmarked-heading warning); the real
  routing-foundation PROJECT-MAP.md has no Route table (this feature ran interactively — gate is
  a no-op, no ROUTE.md), exercising the graceful-absence path.
- **Decisions made during implementation**:
  - Three columns now, not the spike's five — Actor/Outcome are Phase-3/Slice-13 territory.
    (decided by: claude)
  - Wired the row-write into navigate's gate section (where ROUTE.md is written) rather than a
    separate step, so the pointer and its target are written together. (decided by: claude)
- **Acceptance criteria**:
  - [x] The Route table links to ROUTE.md and holds no authoritative state (derived view)
  - [x] Reconstructable from ROUTE.md
  - [x] The table is optional/graceful when absent
- **Engineer feedback incorporated**: None this slice (free climb).
- **Learnings**:
  - Engineer → Claude: None specific to this slice.
  - Claude → Engineer: A derived view earns its keep only if it adds no new state — keeping the
    Route table to three columns (and deferring Actor/Outcome to the slice that owns the
    underlying journal schema) keeps it a pure pointer, not a second writer.

### Remaining Work
- **Incomplete slices**: All Phase 2 slices (6-9) complete. Phase 3 (Slices 10-13: Headless
  Contract & Journaling) and Phase 4 (Slices 14-17: Docs, Reviewer & Trellis) remain.
- **Blockers encountered**: None.
- **Handoff context**:
  - **Slice 17 discovered item**: CLAUDE.md `## State Artifact Chain` line still reads
    `CONTEXT → SPEC → NAVIGATION → EVOLUTION` (omits ROUTE.md). Fold the ROUTE.md insertion into
    Slice 17's cross-reference sweep alongside the count updates. (Slice 6 stayed scoped to
    STATE.md per the spec's file mapping.)
  - **Spec note for Phase 3**: the spec's Slice 8 file hint ("alongside the existing gearing
    preview" in inquire) is off — the gearing preview lives in verify.md. No action needed;
    recorded so it isn't re-investigated.
  - **Phase 3 builds on this**: ROUTE.md format (Slice 6), the navigate-head gate + verdict
    (Slice 7), and the Route table (Slice 9) are the substrate the headless contract (Slice 12)
    and #90 journal schema (Slice 13) consume. The headless *entry signal* was deliberately left
    vague in navigate's gate section — Slice 12 defines it.

### Pre-PR Reconciliation (2026-06-16)
Before opening the Phase 2 PR, rebased the branch `--onto origin/main` to drop the already-
squash-merged Phase 1 noise (PR #94) and the merge commits, leaving 6 clean Phase 2 commits.
Reconciled with two PRs that merged to main while Phase 2 was building:
- **#95 (init scaffolds `.vine/README.md`)** — touched `references/STATE.md` (PROFILE lifecycle
  step renumber + new `### README.md` section) in regions after my edits; auto-merged cleanly,
  no overlap with the ROUTE.md / Route-table additions.
- **#96 (descope bespoke brain → durable-decisions convention)** — added `## Durable Decisions
  & Gotchas` and `## Reference Legibility` to STATE.md plus a warning-only trellis Check 11
  (bare `#<n>` in command files). Verified: my command-file issue refs use the `(#54)` form the
  check accepts and name what each issue is in surrounding prose, so trellis stays green (11/11
  + 8 anchors) with no Check 11 warnings. No content conflict — #96's sections sit after mine.
- The slice **Commit** fields above were rebased: Slice 6 `7271476`→`172867b`, Slice 7
  `dc60e70`→`92c13ad`, Slice 8 `949145f`→`766af0c`, Slice 9 `9f0f8df`→`42b576a`.

## Phase 3: Headless Contract & Journaling (Slices 10-13)

Resumed 2026-06-16 09:20 in free-climb gearing (engineer choice; profile confident/workflow).
Branch even with `origin/main` (#97 merged), clean tree, no open PRs in flight. Routing gate at
navigate-head is a no-op this session — human-driven, route is `interactive`, no ROUTE.md
written. Building the autonomy layer that consumes Phase 2's route: the Decision Delegation
policy (Slice 10), per-site decision-class tags (Slice 11), the headless mode + structured
handoff (Slice 12), and the #90 journal schema (Slice 13).

### Slice 10: Decision Delegation policy section — Complete
- **Started**: 2026-06-16 09:20
- **Commit**: bc79152
- **Approach taken**: Added a `## Decision Delegation` section to `.vine/context/shared.md`,
  marked `<!-- class: policy -->`, placed directly after `## Interaction Constraints` (it
  governs how those `AskUserQuestion` sites behave headless — the natural adjacency for a
  reader) and before `## Team Context`. The section defines the two decision classes and their
  headless semantics: `default-able` → take the recommended option and journal it as a Decision
  Taken Autonomously with `(slice N)` attribution; `human-required` → escalate to the structured
  handoff and stop. It states the section is policy-class (immutable from `.local`, but a *repo*
  overlay can reclassify — the #55 override path), that it is inert in interactive sessions, and
  that ambiguous sites default to `human-required` (escalation is always safe).
- **Deviations from spec**: None.
- **Validation**: pass — `sh .vine/scripts/trellis-check.sh` 11/11 commands + 8/8 cross-reference
  anchors. No `commands/vine/` files touched, so the trellis command-commit gate is not involved.
  The new heading is a `##` section in an overlay file (not a STATE.md template), so no
  required/optional marker applies.
- **Decisions made during implementation**:
  - Placed Decision Delegation after Interaction Constraints (thematic adjacency to the
    `AskUserQuestion` sites it governs) rather than grouped with the bottom policy sections
    (Team Context, CI/CD) — the class marker declares its policy status regardless of position
    (Overlay Precedence: "Only policy-class sections carry the marker"). (decided by: claude)
  - Kept the per-site roster *out* of this section — it defines the two classes; the commands
    carry the assignments (Slice 11). A single roster home avoids two places to keep in sync.
    (decided by: claude)
  - Forward-references the structured handoff (Slice 12) and the autonomous-decision journal
    field (Slice 13); both land in this same phase/PR, so the references resolve by phase end.
    (decided by: claude)
- **Acceptance criteria**:
  - [x] The section is policy-class (immutable from `.local`) — `<!-- class: policy -->` marker
  - [x] It sets per-class headless behavior (default-able vs human-required)
  - [x] It is override-able as overlay content (repo overlay can reclassify; stated explicitly)
- **Engineer feedback incorporated**: Gearing set to free climb up front.
- **Learnings**:
  - Engineer → Claude: None specific to this slice.
  - Claude → Engineer: Defining the classes in one policy section and the per-site assignments
    at the sites (Slice 11) keeps the routing policy single-homed — the same derived-view
    discipline Slice 9 applied to the Route table, applied to decision classification.

### Slice 11: AskUserQuestion site classification — Complete
- **Started**: 2026-06-16 09:35
- **Commit**: 99e19fb
- **Approach taken**: Tagged every `AskUserQuestion` decision site across the 7 commands in the
  SPEC's file list with an inline `<!-- decision-class: human-required | default-able -->` HTML
  comment, placed adjacent to the `AskUserQuestion` instruction so a headless actor reading the
  command sees the class in place. 31 sites total: verify 4, inquire 4, navigate 6, evolve 9,
  pause 2, resume 3, pair 3 (14 human-required, 17 default-able). Distinguished real decision
  sites from the frontmatter `allowed-tools` entry and the "Follow the Interaction Constraints"
  / "Use AskUserQuestion for all decision points" reference lines, which are not sites.
- **Deviations from spec**: None against the ACs. The CONTEXT "Current State" map enumerated ~22
  named sites; 3 live sites it did not name were classed by the Decision Delegation
  ambiguous-defaults-to-`human-required` rule rather than left untagged (see Decisions).
- **Validation**: pass — `sh .vine/scripts/trellis-check.sh` 11/11 commands + 8/8 anchors;
  `.vine/.trellis-ok` stamp written (command-file changes, so the command-commit gate applies).
  Tag counts verified by grep (31 total, all 7 commands). HTML comments are invisible to
  rendering and don't alter the prompts — interactive behavior is byte-unchanged.
- **Decisions made during implementation**:
  - Used an inline HTML comment at each site rather than a per-command roster table — keeps the
    class with the decision (one source, no table to drift from the sites), matching Slice 10's
    "the commands carry the roster" split. (decided by: claude)
  - Three sites the CONTEXT map didn't enumerate were classed `human-required`: verify's
    sign-off gate (`verify.md` "Gate on explicit sign-off" — added by #93 *after* the verify map
    was written; sign-offs gate phase handoff, so human-required like inquire's spec sign-off);
    navigate's step-3d spec-gap decision-surfacing ("something not covered by the spec"); pair's
    multiple-valid-approaches prompt. All three are unplanned approach/scope decisions an actor
    shouldn't make silently → the policy's "ambiguous ⇒ human-required, escalation is always
    safe" default. (decided by: claude)
  - Treated "all feature-selection prompts" (CONTEXT, default-able) as covering the
    pick-which-feature prompts in inquire/navigate/evolve/pause/resume — tagged each
    default-able. status and optimize have feature/selection prompts too but are out of the
    SPEC's Slice 11 file list, so left untagged this slice. (decided by: claude)
- **Acceptance criteria**:
  - [x] Every site carries a class tag matching the CONTEXT map (22 named sites aligned; 3
        unnamed sites classed by the policy default)
  - [x] Tags align with the Decision Delegation policy (Slice 10 vocabulary, exact tokens)
  - [x] Interactive behavior is unchanged (HTML comments, no prompt text touched)
- **Engineer feedback incorporated**: None this slice (free climb).
- **Learnings**:
  - Engineer → Claude: None specific to this slice.
  - Claude → Engineer: The CONTEXT map was a snapshot — #93's verify sign-off gate landed after
    it, so trusting the map verbatim would have left a real site untagged. Grepping the live
    files for every `AskUserQuestion` site and reconciling against the map (rather than tagging
    only the map's list) caught the drift; the policy's ambiguous→human-required default made the
    unenumerated sites a mechanical call, not a judgment one.

### Slice 12: Headless mode + structured handoff block (#53) — Complete
- **Started**: 2026-06-16 09:45
- **Commit**: faa4b4e
- **Approach taken**: Added a `### Running Headless — Decision Protocol & Handoff` section to
  `commands/vine/navigate.md` (unnumbered, placed right after the gate section and before step 3
  — same no-renumber rationale as Slice 7's gate). It defines: (1) **entry** — headless is a
  property of how the run was invoked, never a flag VINE stores; an actor never self-asserts
  authority; provisioning/permissions are a launch-time human authority outside the artifact
  chain; no `headless` ROUTE.md ⇒ don't run headless; (2) **execute under ROUTE.md** — modify only
  the Allowlist, run the Validation Baseline green before each commit, an out-of-allowlist touch
  is itself an escalation; (3) **decision protocol** — read each site's `<!-- decision-class -->`
  tag (Slice 11) and apply the Decision Delegation policy (Slice 10): default-able → take
  recommended + journal autonomous `(slice N)`; human-required → write handoff and stop;
  ambiguous → human-required; (4) **platform boundaries** (verified, see Decisions): no nested
  Agent tool (run checks directly), `CLAUDE_PROJECT_DIR` may be unset (use `git rev-parse
  --show-toplevel`), subagents auto-load CLAUDE.md but the route lives in ROUTE.md + journal;
  (5) **Headless Handoff** — written on escalation or clean completion, one block both directions.
  Added the `### Headless Handoff <!-- optional -->` block to the NAVIGATION.md template in
  `references/STATE.md` plus a "Headless Handoff contract" note (single block serves outbound +
  inbound, points at ROUTE.md per Reference Legibility, mechanism-agnostic, optional/graceful).
- **Deviations from spec**: None.
- **Validation**: pass — `sh .vine/scripts/trellis-check.sh` 11/11 commands + 8/8 anchors;
  `.vine/.trellis-ok` stamp written (navigate.md is a command file → command-commit gate applies).
  The new navigate section is unnumbered, so no step renumber and no broken `step N`
  cross-references. The STATE.md contract note's `#reference-legibility` link resolves (heading at
  STATE.md:563).
- **Decisions made during implementation**:
  - **Verified the spike's platform-boundary claims before encoding them** (shared.md Tooling
    Notes: agent diagnoses are unverified). Read `coordination-spike/EVOLUTION.md` directly: Q2
    (line 23) confirms nested-Agent-unavailable, `CLAUDE_PROJECT_DIR`-unset, `claude setup-token`
    auth, and actor-permissions-as-provisioning-authority; Q4 (line 25) confirms subagents
    auto-load CLAUDE.md and the "map, not mechanism" / mechanism-portability finding. All four
    claims accurate — design encodes them verbatim. (decided by: claude)
  - Defined the structured handoff as an **optional section of NAVIGATION.md**, not a new file
    type — the journal already travels tracked and is in the reviewer's orientation order (and
    Slice 14 adds ROUTE.md to it). One durable home, one block, both directions. (decided by:
    claude)
  - Kept **headless as a property of invocation**, not a self-asserted artifact field — directly
    honors the spike's "actor permissions are a provisioning-time human authority, not a VINE
    field" boundary. ROUTE.md authorizes *what* is touched; *who* runs is granted at launch.
    (decided by: claude)
  - Inserted the section **unnumbered** after the gate (not a numbered step 3) — renumbering
    would ripple through navigate's `step 3b/c/d`, `step 4/6/8` and STATE.md's pointers (the exact
    drift trellis Check 10 catches). Same structural choice as Slice 7. (decided by: claude)
  - The autonomous-decision **journal field** itself (section-scoped `(slice N)` token) is
    formalized in Slice 13 — Slice 12 introduces the *behavior* and references the field; Slice 13
    adds it to the slice template. Complementary, dependency-ordered (13 depends on 12). (decided
    by: claude)
- **Acceptance criteria**:
  - [x] In headless mode, default-able decisions take the recommended option and are journaled as
        autonomous (section-scoped attribution)
  - [x] Human-required decisions escalate to the structured handoff and stop
  - [x] One structured handoff block serves both outbound (agent) and inbound (reviewer)
  - [x] Platform boundaries respected (no nested Agent assumption; actor permissions stay
        provisioning-time human authority, not a VINE field)
- **Engineer feedback incorporated**: None this slice (free climb).
- **Learnings**:
  - Engineer → Claude: None specific to this slice.
  - Claude → Engineer: The cycle's highest-risk autonomy slice was safest expressed by *not*
    inventing mechanism — the spike's "map, not the mechanism" finding meant the contract is a
    decision protocol + a handoff format, both mechanism-agnostic, so it survives whatever launches
    the actor. The one place I slowed down (re-reading the spike's EVOLUTION.md to confirm the four
    platform claims rather than trusting the SPEC's summary of them) is exactly where the
    diagnosis-unverified rule pays off — encoding an inverted boundary into an autonomy contract
    would be expensive to catch later.

### Slice 13: #90 journal schema fixes — Complete
- **Started**: 2026-06-16 10:00
- **Commit**: a7f8cf3
- **Route**: interactive — `mechanism: n/a`
- **Actor**: human (Rob + Claude)
- **Gear**: free-climb
- **Approach taken**: Applied all five #90 fixes plus Route/Actor/Gear to the journal schema
  across `references/STATE.md` (NAVIGATION.md template + PROJECT-MAP Route table) and the
  `commands/vine/navigate.md` writer template, keeping the two templates in lockstep.
  NAVIGATION.md slice template gained: optional `**Route**` (controlled `interactive | headless
  | headless-reentry` vocab + labeled `mechanism:` token), `**Actor**`, `**Gear**` fields;
  `**Commit**` now documents the `+`-separated multi-commit form; `**Validation**` leads with a
  bare `pass`/`fail` token; `**Decisions made**` formalizes `(decided by: …)` + optional
  `[confidence: …]`; new `**Decisions Taken Autonomously**` field with section-scoped `(slice N)`
  attribution. Added a six-rule "journal-schema contract (#90)" note covering token-first
  validation, multi-commit, controlled Route vocab, autonomous attribution, decided-by/confidence,
  and the **mechanism-divergence correction rule** (correct the field, not just prose — the #90
  wrong-extraction gap). PROJECT-MAP Route table gained the `Actor` and `Outcome` columns Slice 9
  deferred here; updated the derived-pointer note so the execution columns are documented as
  mirrors of the journal (table stays a pure derived view). All new fields `<!-- optional -->`
  with graceful absence. This entry itself carries the new Route/Actor/Gear fields as a
  dogfooding instance.
- **Deviations from spec**: None.
- **Validation**: pass — `sh .vine/scripts/trellis-check.sh` 11/11 commands + 8/8 anchors;
  `.vine/.trellis-ok` stamp written (navigate.md command-file change → command-commit gate).
  PROJECT-MAP Route table renders with 5 columns; NAVIGATION template headings unchanged (trellis
  Check A matches on the `Slice N:` prefix, unaffected).
- **Decisions made during implementation**:
  - Added `Actor`/`Outcome` to the PROJECT-MAP Route table (the columns Slice 9 explicitly
    deferred to this slice) and documented them as derived from NAVIGATION.md's per-slice fields +
    the Headless Handoff — preserving Slice 9's "the Route table holds no authoritative state"
    invariant. (decided by: claude) [confidence: high]
  - Kept Route/Actor/Gear optional and made interactive defaults explicit (missing Route ⇒
    interactive, missing Actor ⇒ human) so older and interactive journals stay valid without
    backfill — AC-10 backward-compat. (decided by: claude) [confidence: high]
  - Recorded `Gear` as fillable on *any* run (not just headless): the gearing choice is currently
    lost to prose, and journaling it is cheap dogfooding value. Route/Actor stay headless-relevant
    with interactive defaults. (decided by: claude) [confidence: medium]
  - Expressed the mechanism-divergence fix as "make the field true, not just a prose note" —
    directly targets the #90 wrong-extraction root cause (mechanical extraction reads the field,
    not surrounding prose). (decided by: claude) [confidence: high]
- **Acceptance criteria**:
  - [x] NAVIGATION.md carries Route/Actor/Gear fields
  - [x] Validation rollup uses a `pass`/`fail` token first
  - [x] Multi-commit slices use a `+`-separated Commit field
  - [x] Autonomous decisions carry section-scoped `(slice N)` attribution
  - [x] Route uses a controlled vocabulary with a labeled `mechanism:` token
  - [x] `(decided by:)` and confidence tags are formalized
  - [x] The schema forces field correction when a mechanism diverges mid-slice
  - [x] All fields are optional with graceful absence on older journals
- **Engineer feedback incorporated**: None this slice (free climb).
- **Learnings**:
  - Engineer → Claude: None specific to this slice.
  - Claude → Engineer: The #90 wrong-extraction gap is really a "single source of mechanical
    truth" rule — a prose correction and a stale field disagree, and the extractor trusts the
    field. The fix isn't a richer schema; it's a contract that the *field* is the truth and must
    be corrected when reality diverges. Same discipline as the derived-view rule, applied to a
    single field instead of a whole table.

### Phase-3 boundary verification + lockstep fix — Complete
- **Started**: 2026-06-16 10:20
- **Commit**: 7ad1521
- **Route**: interactive — `mechanism: n/a`
- **Actor**: human (Rob + Claude)
- **Gear**: free-climb
- **Approach taken**: Ran the `vine-verification` agent at phase-group scope over Phase 3
  (Slices 10-13). Result: trellis pass (11/11 + 8 anchors); all four slices' ACs met with
  file:line evidence; backward-compat (AC-10) fully met (every new field/block degrades to its
  interactive default). The agent surfaced one **error** and one **warning**:
  - **Error (fixed):** lockstep field-label mismatch — `references/STATE.md`'s NAVIGATION.md
    template (and my new #90 contract note) named the field `**Decisions made**`, but
    `navigate.md`'s writer template and *every existing journal entry* use `**Decisions made
    during implementation**`. Verified directly: the verbose label is pre-existing (since the
    skills→commands refactor `da773a7`) and is the form in actual use; my Slice 13 contract note
    sharpened the pre-existing drift into a named-field mismatch. Reconciled toward reality —
    aligned STATE.md's template line and the contract note to `**Decisions made during
    implementation**` (changing the writer instead would have orphaned every journal). All four
    references now agree; trellis re-run green.
  - **Warning (intentional, no change):** `inquire.md`'s design-decision tag sits on the
    class-level "Use AskUserQuestion for all design decisions" instruction rather than a discrete
    call — because inquire's design decisions are an open-ended set made dynamically, with no
    enumerable single call to tag. A class-level tag is the correct shape there; `human-required`
    is also the safe default for any untagged call. Reasoning already recorded in Slice 11.
- **Deviations from spec**: None — the lockstep fix closes a coherence gap this phase's contract
  note created, in-phase (the Phase-1-boundary precedent).
- **Validation**: pass — `sh .vine/scripts/trellis-check.sh` 11/11 + 8/8 anchors after the fix.
- **Decisions made during implementation**:
  - Reconciled the label toward the writer/journals (`during implementation`), not toward
    STATE.md's terse form — the terse form was never actually used, so aligning to it would have
    broken every existing journal against the template. (decided by: claude) [confidence: high]
  - Verified the agent's mismatch finding with a direct grep before fixing (findings-trustworthy,
    diagnosis-unverified) — confirmed origin and direction-of-truth rather than trusting the
    report's framing. (decided by: claude) [confidence: high]
- **Acceptance criteria**:
  - [x] Phase-group verification run; all Slice 10-13 ACs confirmed met
  - [x] Backward compatibility (AC-10) confirmed for every new surface
  - [x] Lockstep between STATE.md template and navigate.md writer restored
- **Engineer feedback incorporated**: None (free climb).
- **Learnings**:
  - Engineer → Claude: None specific.
  - Claude → Engineer: A contract note that names a field is only as good as the field's real
    name — writing the #90 schema contract is what *revealed* a years-old terse/verbose drift,
    because a contract forces you to name the field precisely and then someone checks it against
    practice. The phase-group verification earned its keep here: the mismatch was invisible until
    a contract referenced the field by name.

## Phase 4: Docs, Reviewer & Trellis (Slices 14-17)

Resumed 2026-06-16 10:01 in free-climb gearing (engineer choice; profile confident/workflow).
Branch even with `origin/main` + 1 local tracker commit (919aa56, Phase-3-shipped), clean tree,
no open PRs in flight. Routing gate at navigate-head is a no-op this session — human-driven,
route is `interactive`, no ROUTE.md written. Making the routing surfaces discoverable (README),
reviewable (review.md orientation), and validated (trellis artifact checks), then sweeping
cross-references and counts.

### Slice 14: review.md gate-record orientation step — Complete
- **Started**: 2026-06-16 10:01
- **Commit**: 9baacaf
- **Route**: interactive — `mechanism: n/a`
- **Actor**: human (Rob + Claude)
- **Gear**: free-climb
- **Approach taken**: Added a new step 2, **The gate record**, to `.vine/context/review.md`'s
  Orientation Order — placed after the originating scope (intent) and before the artifact
  directory / journal / commits (execution), since ROUTE.md is the *authorization* basis the
  reviewer checks execution against. The step names what to read it for (verdict, allowlist,
  constraints, validation baseline, input basis + stamp) and the three checks it frames (diff
  stayed inside the allowlist; validation baseline ran; stamp's input basis still matches
  execution state — authorization-vs-execution drift is a finding), with explicit graceful
  absence ("absent ROUTE.md, the run was interactive and ungated — move to the next step").
  Renumbered the following steps (artifact directory → 3, commits → 4, touched files → 5) and
  added a parenthetical to step 3 so ROUTE.md isn't re-read redundantly. Resolved the header
  follow-up comment: rewrote its forward-looking "Cycle 1 adds … once that artifact exists"
  sentence into a resolved note pointing at step 2 (kept the promotion provenance trail).
- **Deviations from spec**: None.
- **Validation**: pass — `sh .vine/scripts/trellis-check.sh` 11/11 commands + 8/8 cross-reference
  anchors. review.md is an overlay file (not a command file), so the `.vine/.trellis-ok`
  command-commit gate is not involved; no required/optional marker applies (not a STATE.md
  template).
- **Decisions made during implementation**:
  - Placed the gate record as step 2 (between scope and the artifact directory) rather than
    folding it into the existing "read every .md" step — the reviewer needs the authorization
    boundaries *before* reading the journal/commits so they have something to check execution
    against, and a discrete numbered step is what the AC ("read at the right point in the
    orientation order") asks for. Added a parenthetical to step 3 to avoid double-reading.
    (decided by: claude) [confidence: high]
  - Resolved the header comment by rewriting (not deleting) its last sentence — kept the cycle-0
    promotion provenance, changed only the forward-looking clause to a resolved pointer.
    (decided by: claude) [confidence: high]
- **Acceptance criteria**:
  - [x] ROUTE.md is read at the right point in the orientation order (new step 2, before
        journal/commits)
  - [x] The header follow-up comment is resolved (forward-looking sentence → resolved note)
- **Engineer feedback incorporated**: Gearing set to free climb up front.
- **Learnings**:
  - Engineer → Claude: None specific to this slice.
  - Claude → Engineer: The orientation order is a dependency chain ("later items make sense
    because of earlier ones") — the gate record's *value* is positional: it only frames the
    journal/commit reads if it's read before them, so where it lands in the list is the design
    decision, not just that it's present.

### Slice 15: README "Agents running VINE" section — Complete
- **Started**: 2026-06-16 10:08
- **Commit**: pending
- **Route**: interactive — `mechanism: n/a`
- **Actor**: human (Rob + Claude)
- **Gear**: free-climb
- **Approach taken**: Added a `## Agents running VINE` section to `README.md`, placed after
  `## State Artifacts` and before `## Engineer Profile` — the seam where the artifacts (ROUTE.md,
  the journal handoff) and the reviewer role it references have just been introduced, so the
  section reads without forward-pointing. Four plain-language subsections, one screen: **the
  routing gate** (four-leg eligibility, frames headless as opt-in and the gate as withholding-only
  so the interactive path is untouched); **the gate record** (ROUTE.md's allowlist / constraints /
  validation baseline / stamp, and the bound headless run + escalate-don't-guess behavior with the
  human-required/default-able tagging); **the reviewer** (links `.vine/context/review.md`, orient
  + produce); **the agents** (`agents/` dir, names both shipped agents and their roles). Closes
  with a single STATE.md link for ROUTE.md format + delegation/handoff contracts (link-don't-inline
  per the PR-description discipline).
- **Deviations from spec**: None. The spec's file hint named two candidate seams ("after
  `## Context Overlays`" or "under `## How VINE compares`"); chose after `## State Artifacts`
  instead — strictly better for legibility because the section leans on ROUTE.md / journal / the
  review role, all introduced by that point, so nothing reads forward. Descriptive hint, not an
  AC; no SPEC annotation needed.
- **Validation**: pass — `sh .vine/scripts/trellis-check.sh` 11/11 commands + 8/8 anchors; all
  three new relative links resolve (`.vine/context/review.md`, `agents/`, `references/STATE.md`
  all exist). README is not a command file, so the command-commit gate is not involved.
- **Decisions made during implementation**:
  - Placed the section after State Artifacts rather than either spec-suggested seam — legibility
    (no forward references) over the literal hint. (decided by: claude) [confidence: high]
  - Named both shipped agents (`vine-verification`, `vine-codebase-explorer`) and noted they're
    identical interactive-or-headless — the AC says "`agents/` is treated"; naming the concrete
    contents beats a vague pointer. (decided by: claude) [confidence: high]
  - Kept it to one screen with a single STATE.md link for depth rather than inlining the ROUTE.md
    format / delegation policy — the PR-description / Reference Legibility discipline applied to a
    README section. (decided by: claude) [confidence: high]
- **Acceptance criteria**:
  - [x] A named section covers running VINE headless and the reviewer role
  - [x] `agents/` is treated (both shipped agents named with their roles)
  - [x] One screen, plain language, links for depth (PR-description discipline)
- **Engineer feedback incorporated**: None this slice (free climb).
- **Learnings**:
  - Engineer → Claude: None specific to this slice.
  - Claude → Engineer: A spec file-hint names *candidate* locations, not a mandate — the real
    constraint is "no forward references," and the seam that satisfies it (after the artifacts the
    section depends on) won out over the literally-suggested ones. Same instinct as Slice 8's
    "the gearing preview is in verify, not inquire": treat file hints as descriptive.
