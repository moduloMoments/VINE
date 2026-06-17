# Navigation Journal: Durable Decisions Convention (wiring)
## Feature: .vine/projects/workflow/durable-decisions
## Started: 2026-06-16
## Built on: SPEC.md (2026-06-16)

Single navigate session, single PR. Five low-complexity markdown slices (no phase grouping).
Route: interactive throughout — a human (Rob) drives; the eligibility gate is a no-op (graceful
ROUTE.md absence).

### Slice 1: STATE.md consistency + Knowledge Boundary graduation — Complete
**Started**: 2026-06-16 21:54
**Commit**: f5349c0
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

### Slice 2: Bootstrap workflow-domain records — Complete
**Started**: 2026-06-16 22:05
**Commit**: pending
**Route**: interactive — `mechanism: n/a`
**Actor**: human
**Gear**: free-climb
**Approach taken**: Authored three genuine `workflow`-domain records under `.vine/knowledge/workflow/`,
each valid against the ADR template, the five properties, and the slug convention finalized in slice 1:
  - `2026-06-15-cut-the-derived-map-cache.md` — the brain-descope decision (#96); the STATE.md
    example title verbatim.
  - `2026-06-16-decision-delegation-default-able-vs-human-required.md` — the headless decision-class
    split (#98).
  - `2026-06-16-route-md-headless-eligibility-gate.md` — ROUTE.md as the per-scope eligibility gate (#97).
**Deviations from spec**: None in behavior. One **requirement-implied file** beyond the spec's
enumerated `Files likely touched`: `.gitignore` needed `!.vine/knowledge/` added to its allow-list
— the repo's `.vine/*` ignore rule would otherwise have left the new records untracked, contradicting
STATE.md's "tracked by default" and AC9/AC10's commit-by-default stance. The spec mandated the
behavior (tracked records) without naming the file; adding the negation implements the decision the
spec already made, so this is not an approach deviation and needs no SPEC.md annotation.
**Validation**: pass — structural check confirms each record has a declarative-sentence title, the
full Status/Context/Decision/Consequences template, Status+date+source, `Supersedes: none`, and a
date-prefixed slug. (Knowledge records are not trellis-gated this cycle — steered.)
**Decisions made during implementation**:
  - Wrote 3 records rather than 2: the third (Decision Delegation) and the others split cleanly
    across the two source cycles, and three give verify's glob more substantive day-one content
    (decided by: claude) [confidence: high]
**Acceptance criteria**:
  - [x] AC9 — 2–3 real workflow-domain records exist, each valid against the ADR template and the
    five properties, using the date-prefixed slug; ready to be surfaced by verify's glob (slice 4)
**Engineer feedback incorporated**: (pending slice-boundary review — free-climb gear)
**Learnings**:
  - Engineer → Claude: None yet this slice.
  - Claude → Engineer: Authoring the bootstrap records is the first real test of the five
    properties as a *writing* contract (vs. a reading one) — self-contained Context and the
    declarative-sentence title are the two that take deliberate effort; the rest are mechanical.
