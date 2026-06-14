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
- **Commit**: 7271476
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
- **Commit**: pending
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
