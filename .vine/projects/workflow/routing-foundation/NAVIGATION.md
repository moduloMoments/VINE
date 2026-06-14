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
- **Commit**: pending
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
