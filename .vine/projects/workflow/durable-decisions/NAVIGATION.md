# Navigation Journal: Durable Decisions Convention (wiring)
## Feature: .vine/projects/workflow/durable-decisions
## Started: 2026-06-16
## Built on: SPEC.md (2026-06-16)

Single navigate session, single PR. Five low-complexity markdown slices (no phase grouping).
Route: interactive throughout — a human (Rob) drives; the eligibility gate is a no-op (graceful
ROUTE.md absence).

### Slice 1: STATE.md consistency + Knowledge Boundary graduation — Complete
**Started**: 2026-06-16 21:54
**Commit**: pending
**Route**: interactive — `mechanism: n/a`
**Actor**: human
**Gear**: free-climb
**Approach taken**: Eight prose edits to `references/STATE.md`, concentrated in three existing
sections:
  - *Durable Decisions & Gotchas* — reworded property 4 to "Immutable body — supersede, don't
    rewrite" (Context/Decision/Consequences frozen; the one sanctioned edit is the `Accepted →
    Superseded by <new-slug>` Status flip); added the concurrent-safety nuance to "Why one record
    per file" (guarantee is about never rewriting a *body*; the single Status flip is the rare
    exception); fixed the ADR template's Status block so "Superseded by" rides the Status verdict
    line and `Supersedes:` names the record this one replaces; added a **Slug** paragraph
    documenting `YYYY-MM-DD-<kebab-of-title>`.
  - *Knowledge Boundary* — "four homes" → "five"; added a first-class `.vine/knowledge/<domain>/`
    table row with a who-pays-the-tokens cell; added the five-step "Routing a durable item to its
    home" decision tree (first match wins, narrowest-scope-first); graduated the line-526 forward
    reference out (kept the one-line-pointer rule).
  - *Project Lifecycle* — "Archiving is manual" → engineer-confirmed offer (evolve offers the move
    after `.resolved`); added "Knowledge records persist across archival" (independent
    Accepted→Superseded lifecycle, never moved by archival).
**Deviations from spec**: None.
**Validation**: pass — `sh .vine/scripts/trellis-check.sh` (11/11 commands, 8 cross-reference
anchor pairs resolve; the `.vine/hooks/` warnings are pre-existing in init.md, untouched).
**Decisions made during implementation**:
  - Routing tree finalized as five ordered steps rather than the spec's four-way rough cut: added a
    leading "regenerable from the code? → home it nowhere" gate so the tree opens with the
    discriminator that keeps regenerable facts out of every home (decided by: claude) [confidence: high]
  - Resolved the template Status block by routing "Superseded by" to the Status *verdict* line and
    redefining the `Supersedes:` comment as "the record this one replaces" — makes the bidirectional
    link unambiguous (decided by: claude) [confidence: high]
**Acceptance criteria**:
  - [x] AC4 (canonical half) — first-class `.vine/knowledge/` row + routing decision tree in STATE.md
  - [x] AC5 — supersede carve-out + concurrent-safety nuance; property 4 and template no longer contradict
  - [x] AC6 (doc) — slug convention `YYYY-MM-DD-<kebab-of-title>` documented
  - [x] AC8 (doc) — knowledge persists across archival, stated in Project Lifecycle
**Engineer feedback incorporated**: (pending slice-boundary review — free-climb gear)
**Learnings**:
  - Engineer → Claude: None yet this slice.
  - Claude → Engineer: The five-property list already implied body-immutability ("supersede, don't
    edit"); the defect was only that the template and property 4 used different words for the same
    rule. The fix was lexical precision (body vs. Status line), not a new constraint.
