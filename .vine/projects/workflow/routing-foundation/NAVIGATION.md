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
- **Commit**: pending
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
