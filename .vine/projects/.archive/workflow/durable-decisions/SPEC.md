# Feature Spec: Durable Decisions Convention (wiring)
## Date: 2026-06-16
## Built on: CONTEXT.md (2026-06-16)
## Decisions made by: Rob

### Problem Statement

The durable-decisions record format already exists and shipped in `references/STATE.md`
("Durable Decisions & Gotchas" — `.vine/knowledge/<domain>/<slug>.md`, the Nygard ADR template,
the five properties, tracked-by-default). What's missing is the **command wiring**: nothing reads
or writes the layer yet. This cycle (ROADMAP Cycle 2, Light) makes `vine:evolve` the writer and
`vine:verify` the reader, documents the layer in README, fixes one self-contradiction in STATE.md's
supersede wording, and bootstraps a few real `workflow`-domain records so the format is proven
end-to-end and verify's glob has something to surface on day one.

The central correctness risk (from verify): **knowledge-home overlap**. With `.vine/knowledge/` as a
fourth home alongside CLAUDE.md, shared.md, and the profile, a "decision" could plausibly land in
several places. We need one crisp routing rule, and — because `references/STATE.md` is a contributor
source-of-truth doc that **does not ship** to consumer repos (`create-vine` installs only
`commands/vine/`, `agents/`, and `journal-check.sh`) — the *operative* copy of that rule must live on
a surface the commands actually load at runtime.

### Approach

**Routing rule — canonical + operative split.** `references/STATE.md`'s Knowledge Boundary table
graduates its line-526 forward reference into a first-class `.vine/knowledge/` row plus a short
routing decision tree (canonical, for contributors). Because STATE.md doesn't ship, `evolve.md` —
the *sole* router; verify only reads — carries a compact operative copy of the rule inline with a
`references/STATE.md` pointer. This mirrors the established pattern across the commands (operative
instruction inline, STATE.md pointer for detail; the dangling pointer degrades gracefully in a
consumer repo). No duplication in verify, which never decides a home.

**Routing tree (rough cut, finalized in slice 1):**
- Non-regenerable *judgment* tied to a domain (why-over-alternatives, hard-won gotcha) → `.vine/knowledge/<domain>/`
- Repo fact every session (VINE or not) needs → `CLAUDE.md`
- Cross-phase VINE protocol / inter-phase routing → `.vine/context/shared.md`
- Per-engineer depth/expertise → `.vine/PROFILE.md`

**Evolve as writer.** A new dedicated "Durable Decisions" step runs *after* the existing three
routing flows (CLAUDE.md Suggestions → Context Overlay Update → Profile growth), keeping the four
homes adjacent so the routing rule can be stated once right before them. It mines candidate
decisions/gotchas from NAVIGATION.md + CONTEXT.md, presents them via `AskUserQuestion` `multiSelect`,
and writes one date-prefixed ADR-format file per accepted record. Supersession is handled both ways:
the new record gets `Supersedes: <slug>` and the old record's Status flips `Accepted → Superseded by
<new-slug>` — the one sanctioned edit to an existing record (body stays immutable).

**Verify as reader.** Early in "Read the Landscape," verify globs `.vine/knowledge/<domain>/` and
presents records in a dedicated "Durable Decisions on record" subsection. Records that appear to
contradict the live code are *surfaced for the engineer's judgment, never auto-trusted* (consistent
with the existing never-auto-trust rule; the contradiction call is the engineer's).

**Slug.** `YYYY-MM-DD-<kebab-of-title>` — chronological ordering and near-zero collision risk.

**Archive (#56).** After evolve writes `.resolved`, it offers (via `AskUserQuestion`, default-able)
to move the project to `.vine/projects/.archive/<domain>/<slug>/`. **Knowledge records are physically
separate and never move** — `.vine/knowledge/<domain>/` is untouched by archival, with its own
Accepted→Superseded lifecycle. Durable judgment outlives the project that produced it.

**Backward compatibility (the roadmap's hard gate).** With no `.vine/knowledge/` files present, every
command behaves exactly as before. No migration. The bootstrap records exist only because we write
them this cycle, not because anything requires them.

### Acceptance Criteria

- **AC1 — verify reads.** `vine:verify` globs `.vine/knowledge/<domain>/` early in Read the
  Landscape and presents records in a dedicated "Durable Decisions on record" subsection. Records
  that appear to contradict live code are surfaced, not auto-trusted. With no records present,
  verify behaves exactly as today.
- **AC2 — evolve writes.** `vine:evolve` has a dedicated Durable Decisions step (after profile
  growth) that mines candidates from NAVIGATION.md + CONTEXT.md, presents them via `AskUserQuestion`
  `multiSelect`, and writes one date-prefixed ADR-format file per accepted record under
  `.vine/knowledge/<domain>/`. Declining all writes nothing — current behavior.
- **AC3 — supersession is bidirectional.** When a record supersedes an existing one, evolve writes
  the new record with `Supersedes: <old-slug>` AND flips the old record's Status to `Superseded by
  <new-slug>`. The flip touches the Status line only; the body stays immutable.
- **AC4 — single routing rule.** A knowledge-home routing rule (knowledge record vs CLAUDE.md vs
  shared.md vs profile) is canonical in STATE.md's Knowledge Boundary (first-class `.vine/knowledge/`
  row + decision tree) and operative inline in evolve with a STATE.md pointer. A cold actor can pick
  the right home without ambiguity.
- **AC5 — STATE.md self-consistent.** STATE.md states the supersede carve-out (body-immutable; the
  Status line is a one-time forward-pointer that flips on supersession only) and the concurrent-safety
  nuance (the guarantee is about never rewriting a record's *body* concurrently; the single-line
  Status flip is the rare sanctioned exception). Property 4 and the template's Status comment no
  longer contradict.
- **AC6 — slug convention.** Records use `YYYY-MM-DD-<kebab-of-title>`; documented in STATE.md;
  bootstrap records follow it.
- **AC7 — archive offer.** After evolve writes `.resolved`, it offers (default-able) to move the
  project to `.vine/projects/.archive/<domain>/<slug>/`. Declining leaves it resolved-but-unarchived.
  The offer respects the consumed-once PAUSE.md rule (already deleted by this point) and the existing
  `.archive/` filtering convention.
- **AC8 — knowledge persists across archival.** Durable-decision records in `.vine/knowledge/` are
  NOT moved by archival and keep their own Accepted→Superseded lifecycle. Stated explicitly in
  STATE.md and README.
- **AC9 — bootstrap.** 2–3 real `workflow`-domain records exist under `.vine/knowledge/workflow/`
  (the brain-descope decision = the STATE.md example, plus routing-foundation decision(s)), each
  valid against the ADR template and the five properties, and immediately surfaced by verify's glob.
- **AC10 — README documents the layer.** README documents `.vine/knowledge/` (commit-by-default),
  the active→resolved→archived project lifecycle, and that knowledge persists independent of
  archival. It points back to STATE.md for the format rather than duplicating it.
- **AC11 — backward compatible.** With no `.vine/knowledge/` files, every command behaves exactly as
  before. No migration step exists.

### Work Slices

Single navigate session, single PR. Five low-complexity markdown slices — no phase grouping (the
multi-PR/milestone path was already declined; see Backlog Updates). Slice 1 is the foundation every
other slice references; 2–5 build on it. Slices 3 and 4 are independent of each other, but verify
(slice 4) is best validated against the records written in slice 2.

### Slice 1: STATE.md consistency + Knowledge Boundary graduation
**Goal**: Make STATE.md self-consistent and the canonical home for the routing rule, slug
convention, and archival-persistence semantics — the contract slices 2–5 implement against.
**Depends on**: nothing
**Files likely touched**: `references/STATE.md`
**Acceptance criteria**: AC4 (canonical half), AC5, AC6 (doc), AC8 (doc). Specifically:
  - Resolve the property-4-vs-template contradiction: add the carve-out (body-immutable; Status line
    is a one-time forward-pointer that flips on supersession only) and the concurrent-safety nuance
    (the guarantee is about not rewriting a record's *body*; the single Status flip is the exception).
  - Graduate the line-526 `.vine/knowledge/` forward reference into a first-class row in the
    Knowledge Boundary table, and add the four-way routing decision tree.
  - Document the slug convention `YYYY-MM-DD-<kebab-of-title>`.
  - State that knowledge records persist across project archival (independent lifecycle), and update
    the Project Lifecycle "Archiving is manual" line to reflect that evolve now *offers* the move
    (still engineer-confirmed, still not auto-archive).
**Complexity signal**: Low — prose edits to one reference file, no behavior.

### Slice 2: Bootstrap workflow-domain records
**Goal**: Write 2–3 genuine `workflow`-domain records so the format is proven end-to-end and verify's
glob has real content to surface.
**Depends on**: Slice 1 (template, slug, five properties finalized)
**Files likely touched**: `.vine/knowledge/workflow/*.md` (new). **Addendum (navigate, slice 2):**
also touched `.gitignore`, adding the `!.vine/knowledge/` negation so records are tracked by default
per STATE.md ("tracked by default"). A requirement-implied file the slice enumeration missed, not an
approach change; recorded here so the spec reflects what was touched.
**Acceptance criteria**: AC9. Records: the brain-descope decision (the STATE.md example — cut the
derived-map cache, keep decisions as committed markdown) and routing-foundation decision(s) (e.g.
the Decision Delegation default-able/human-required split; ROUTE.md as the per-scope eligibility gate
record). Each valid against the ADR template and the five properties, using the date-prefixed slug.
**Complexity signal**: Low — authoring markdown records from already-decided history.

### Slice 3: evolve.md — writer wiring
**Goal**: Make evolve distill durable-decision records and offer the archive move.
**Depends on**: Slice 1
**Files likely touched**: `commands/vine/evolve.md`
**Acceptance criteria**: AC2, AC3, AC4 (operative half), AC7, AC11. Specifically:
  - New dedicated "Durable Decisions" step after the Profile growth step: mine candidates from
    NAVIGATION.md + CONTEXT.md, `AskUserQuestion` `multiSelect`, write one date-prefixed ADR file per
    accepted record. Tag the decision site `default-able` (record proposal is reviewer-ratifiable).
  - Supersession handling: new record `Supersedes:` back-link + flip the old record's Status line
    (Status line only — never the body).
  - Compact operative routing rule inline (the four-way tree) with a `references/STATE.md` pointer;
    reuse the existing "where does this learning go" framing rather than duplicating disambiguation
    prose (keeps evolve from bloating with a fourth full flow).
  - Archive-move offer after the `.resolved` write (the #56 attach point at evolve.md:464): default-
    able `AskUserQuestion`, respects consumed-once PAUSE.md and `.archive/` filtering; declining
    leaves the project resolved-but-unarchived; knowledge records untouched.
**Complexity signal**: Medium — evolve is already long with three routing flows; the new step plus
supersession logic plus archive offer are the most intricate edits this cycle. Mitigated by stating
the routing rule compactly and referencing STATE.md.

### Slice 4: verify.md — reader wiring
**Goal**: Make verify glob and present durable-decision records as prior judgment.
**Depends on**: Slice 1; validated against Slice 2's records
**Files likely touched**: `commands/vine/verify.md`
**Acceptance criteria**: AC1, AC11. Specifically: glob `.vine/knowledge/<domain>/` early in Read the
Landscape; present a dedicated "Durable Decisions on record" subsection; surface (never auto-trust)
records that appear to contradict the live code — the contradiction call is the engineer's. With no
records present, verify behaves exactly as today.
**Complexity signal**: Low — one read-and-present step added to an existing flow.

### Slice 5: README.md — document the layer
**Goal**: Document `.vine/knowledge/` for users on the public surface.
**Depends on**: Slice 1
**Files likely touched**: `README.md`
**Acceptance criteria**: AC10. Document the `.vine/knowledge/` layer (commit-by-default), the
active→resolved→archived project lifecycle, and that knowledge persists independent of archival.
Point back to STATE.md for the format; keep it to roughly one screen.
**Complexity signal**: Low — user-facing documentation, no behavior.

### Tech Debt Integration

- **STATE.md property-4-vs-template contradiction** — *Address now* (Slice 1). The one pre-existing
  defect; fixing it is in scope and unblocks unambiguous supersession wiring.
- **Knowledge-home overlap (correctness risk)** — *Address now* (AC4). The routing rule is the
  disambiguation lever; without it the fourth home is a coin-flip.
- **Evolve length / reader confusion** — *Address during* (Slice 3). Evolve already carries three
  knowledge-routing flows; state the routing rule once and reference it (shared-pattern convention)
  rather than duplicating disambiguation prose, so the fourth flow doesn't bloat the command.
- **Trellis check for knowledge-record format** — *Defer* (steered). Records aren't chain artifacts,
  so the State Artifact Addition Checklist doesn't apply; enforcement rides the writing commands
  (Reference Legibility's stated stance). Re-evaluate if records start drifting in practice.

### Backlog Updates

- **Deferred this cycle**: a validator (trellis check or evolve-time lint) for knowledge-record
  format compliance. Steered out now; surface again if records drift.
- **Possible follow-up**: an availability-gated CLAUDE.md pointer to `.vine/knowledge/` for
  mixed-adoption teams (non-VINE teammates), using the existing availability-gated-pointer pattern.
  Not required by any AC; only if a real team needs it.
- **Unchanged**: the `.vine.local/` sharing-boundary forward reference (existing backlog idea) and
  the per-phase context-trim review (existing note) are unaffected by this cycle.
- **Multi-PR tracking declined**: 5 slices exceeds the multi-PR heuristic, but single-PR was chosen
  deliberately (Light cycle, cohesive wiring). No PROJECT-MAP Milestones table is added.

### Dependencies & Risks

- **Slice ordering**: Slice 1 is the foundation; 2–5 depend on it. 3 and 4 are mutually independent;
  run 2 before 4 so verify's glob is validated against real records.
- **STATE.md / README don't ship** to consumer repos. Operative behavior must live in the command
  files (evolve, verify); STATE.md/README carry canonical docs and pointers that degrade gracefully
  when absent. This is why the routing rule has an inline operative copy in evolve.
- **Supersession is the one sanctioned edit to an immutable record.** Evolve must scope the flip to
  the Status line and never rewrite the body — the immutability/concurrent-safety guarantee depends
  on it.
- **`/trellis` (existing checks) must pass** before committing the evolve/verify edits. No new check
  is added this cycle, but the frontmatter/section-ordering/cross-reference checks still gate the
  command-file changes.
- **No external dependencies**; pure markdown, no build or test toolchain. Validation is `/trellis`
  plus running the modified commands on this repo (dogfooding) — the bootstrap records and the
  evolve/verify wiring can be exercised end-to-end here.
