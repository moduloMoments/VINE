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
**Commit**: 90d1191
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

### Slice 3: evolve.md — writer wiring — Complete
**Started**: 2026-06-16 22:18
**Commit**: 7f11830
**Route**: interactive — `mechanism: n/a`
**Actor**: human
**Gear**: free-climb
**Approach taken**: Two edits to `commands/vine/evolve.md`:
  - New `### Distill Durable Decisions` subsection at the end of Evolution 3 (after the three existing
    routing flows — CLAUDE.md Suggestions, Context Overlay Update, Update Engineer Profile — and before
    Write EVOLUTION.md). Carries: the compact operative five-step routing rule (each home pointed back
    to the evolve step that handles it, canonical version pointer to STATE.md Knowledge Boundary) →
    mine candidates from NAVIGATION.md + CONTEXT.md → `AskUserQuestion multiSelect` tagged
    `default-able` → write one date-prefixed ADR per accepted record (template + five properties +
    slug) → supersession (new record `Supersedes:` + flip old record's Status line ONLY) → decline-all-
    writes-nothing (backward compat) → records persist beyond project archival.
  - Archive offer in *Mark as Resolved*, immediately after the `.resolved` write (the #56 attach point):
    default-able `AskUserQuestion` to `git mv` the project under `.vine/projects/.archive/`, knowledge
    records explicitly never moved, declining leaves it resolved-but-unarchived. Added a note to
    *Commit Evolve Changes* so it stages artifacts at the post-archive path.
**Deviations from spec**: None. Placed the new step at the end of Evolution 3 (not a restructure to make
all four homes physically adjacent) and stated the routing rule once at the step head, each home tagged
with the existing flow that handles it — satisfies "stated once" + "operative inline" (AC4) without
bloating evolve into a fourth full flow, per the spec's own mitigation.
**Validation**: pass — `sh .vine/scripts/trellis-check.sh` (11/11 commands, 8 cross-reference anchor
pairs; gate stamp `status: pass`). Fixed one Reference-Legibility Check-11 warning: reworded "home #2"
→ "the knowledge home (item 2 above)" so a list-index doesn't read as a bare issue pointer.
**Decisions made during implementation**:
  - Routing rule stated at the *head* of the new step (after the other three flows ran) rather than
    hoisted into a preamble before Evolution 2: avoids restructuring the command and the "four homes
    adjacent" goal is met by the rule naming all four in one place (decided by: claude) [confidence: high]
  - Archive `git mv` performed in *Mark as Resolved* but committed by the existing *Commit Evolve
    Changes* step (added a post-move-path note) rather than a separate archival commit — keeps the
    archival rename in the same evolve commit as the artifacts (decided by: claude) [confidence: medium]
**Acceptance criteria**:
  - [x] AC2 — dedicated Durable Decisions step mines candidates, multiSelect, writes one ADR per record
  - [x] AC3 — supersession bidirectional (new `Supersedes:` + old Status-line flip, body untouched)
  - [x] AC4 (operative half) — compact routing rule inline in evolve with STATE.md pointer
  - [x] AC7 — archive offer after `.resolved`, default-able, knowledge untouched, declinable
  - [x] AC11 — declining all candidates / no archive writes nothing; no migration introduced
**Engineer feedback incorporated**: (pending slice-boundary review — free-climb gear)
**Learnings**:
  - Engineer → Claude: None this slice (Rob's gitignore-convention concern was captured as a
    Discovered Item at the slice-2 boundary; see below).
  - Claude → Engineer: The "four homes adjacent" instruction is satisfiable two ways — physically
    (restructure) or referentially (one rule that names all four). The referential reading is the
    lower-risk one for a long command and matches the spec's anti-bloat mitigation.

### Slice 4: verify.md — reader wiring — Complete
**Started**: 2026-06-16 22:29
**Commit**: pending
**Route**: interactive — `mechanism: n/a`
**Actor**: human
**Gear**: free-climb
**Approach taken**: One edit to `commands/vine/verify.md` — a lead-in block at the start of step 2
(*Read the Landscape*), before code reading: glob `.vine/knowledge/<domain>/` (broadly when the
domain isn't yet pinned from step 1), present a dedicated **Durable Decisions on record** subsection
(title/status/gist per record), and surface — never auto-trust — any record that appears to
contradict the live code (the contradiction call is the engineer's). Explicit no-op when no records
are present.
**Deviations from spec**: None. Placed the block as a bolded lead-in inside step 2 rather than a new
numbered/`###` substep — keeps the existing step numbering intact (per the authoring convention that
prefers not renumbering) while still running "early in Read the Landscape."
**Validation**: pass — `sh .vine/scripts/trellis-check.sh` (11/11 commands, 8 cross-reference anchor
pairs; gate stamp `status: pass`). No new naked-issue warnings.
**Decisions made during implementation**:
  - Reused verify's existing never-auto-trust framing verbatim rather than inventing new
    contradiction-handling language — the records are just one more source verify surfaces for the
    engineer's judgment (decided by: claude) [confidence: high]
**Acceptance criteria**:
  - [x] AC1 — verify globs `.vine/knowledge/<domain>/` early in Read the Landscape, presents a
    dedicated "Durable Decisions on record" subsection, surfaces (not auto-trusts) contradictions
  - [x] AC11 — no records present → silent no-op, verify behaves exactly as today
**Engineer feedback incorporated**: (pending slice-boundary review — free-climb gear)
**Learnings**:
  - Engineer → Claude: None this slice.
  - Claude → Engineer: The reader half is much smaller than the writer half — verify only needs to
    glob-and-present, because "surface, don't trust" is already verify's universal stance. The
    durable-decisions records slot into an existing pattern rather than needing a new one.

### Discovered Items

- **`.vine/` gitignore shape should invert when `.vine.local/` lands** (raised by Rob, slice 2).
  The current `.gitignore` is deny-everything (`.vine/*`) + per-subdir allowlist negations
  (`!.vine/context/`, `!.vine/knowledge/`, …). It's brittle: each new tracked `.vine/` subdir
  needs its own negation, which is why slice 2's records were silently untracked until the commit
  failed. The `.vine.local/` backlog idea (STATE.md "Forward references" — personal work in a
  gitignored sibling root, `.vine/` shared-and-tracked) inverts this: the right shape becomes
  track-`.vine/`-by-default + ignore only `.vine.local/` and a couple of ephemeral sentinels
  (`.vine/ACTIVE`, `.vine/.trellis-ok`), with PROFILE.md/PAUSE.md relocating into `.vine.local/`.
  **Decision (Rob, slice 2):** keep the minimal `!.vine/knowledge/` negation now (consistent,
  in-scope, and correct under either model since knowledge is team-shared); defer the inversion to
  the `.vine.local/` work so the whole pattern flips at once rather than as a half-migration. For
  evolve to triage into the backlog, linked to the existing `.vine.local/` forward reference.
