# Evolution Report: Durable Decisions Convention (wiring)
## Date: 2026-06-16

### Product Evolution

#### Acceptance Criteria Results

Every cycle-level criterion maps to a committed slice — none unaccounted.

| Acceptance criterion (SPEC) | Evidence (slice / commit) |
|---|---|
| AC1 — verify globs & surfaces records | Slice 4 — `999288f` |
| AC2 — evolve writes one ADR per accepted record | Slice 3 — `7f11830` |
| AC3 — supersession bidirectional (back-link + Status flip) | Slice 3 — `7f11830` |
| AC4 — single routing rule (canonical + operative) | Slice 1 `f5349c0` (canonical) + Slice 3 `7f11830` (operative) |
| AC5 — STATE.md self-consistent (property 4 vs template) | Slice 1 — `f5349c0` |
| AC6 — slug convention `YYYY-MM-DD-<kebab>` | Slice 1 doc `f5349c0` + Slice 2 records `90d1191` |
| AC7 — archive offer after `.resolved` | Slice 3 — `7f11830` |
| AC8 — knowledge persists across archival | Slice 1 doc `f5349c0` + Slice 5 README `4d029a2` |
| AC9 — 2–3 bootstrap workflow records | Slice 2 — `90d1191` |
| AC10 — README documents the layer | Slice 5 — `4d029a2` |
| AC11 — backward compatible (decline→nothing / no-records→no-op) | Slices 3 & 4 |

**Cross-slice integration:** Green. `trellis-check.sh` passes 11/11 commands with all 8
cross-reference anchor pairs resolving. All three bootstrap records are tracked in git and
glob-able by verify's new block. Evolve's Distill step, bidirectional supersession, and archive
offer are internally consistent with the STATE.md contract finalized in slice 1 — the dogfood loop
closes (the cycle's own wiring verifies against its own bootstrap records). The pre-existing
`.vine/hooks/` warnings in `init.md` are untouched and out of scope.

#### Spec Deviations

| Deviation | Slice | Justified? |
|---|---|---|
| Added `!.vine/knowledge/` to `.gitignore` (file not in slice's enumerated touch-list) | 2 | Yes — requirement-implied. STATE.md's "tracked by default" mandated the behavior without naming the file; adding the negation implements a decision the spec already made. No behavior change. Annotated in SPEC.md slice 2. |

No behavioral deviations. Every slice reports "Deviations from spec: None."

#### Follow-Up Items

Filed as GitHub issues this cycle:
- [#108](https://github.com/moduloMoments/VINE/issues/108) — Invert `.vine/` gitignore to track-by-default when `.vine.local/` lands (deferred from slice 2; coupled to the `.vine.local/` work). **Open.**
- [#109](https://github.com/moduloMoments/VINE/issues/109) — Add a format validator (trellis check / evolve-time lint) for durable-decision records. **Open.**
- [#110](https://github.com/moduloMoments/VINE/issues/110) — Availability-gated CLAUDE.md pointer to `.vine/knowledge/` for mixed-adoption teams. **Resolved in this PR** by the post-evolve init/optimize pointer work (see Post-Evolve Additions below).

#### Post-Evolve Additions

Three changes were made *after* the evolve commit (`e4580d9`), in response to engineer requests, and ride in the same PR. They are outside the slice 1–5 plan above and are recorded here so the durable state matches the diff:

- **CLAUDE.md durable-decisions pointer** (`8df52e1`) — extended the availability-gated `## VINE` pointer block (canonical template in `optimize` 3e) with a line naming `.vine/knowledge/<domain>/`, and added an `init` step that ensures the block is present at setup. This delivers [#110](https://github.com/moduloMoments/VINE/issues/110), which is therefore resolved rather than deferred.
- **init legacy-archive sweep** (`2405f42`) — new `init` upgrade-mode step that detects resolved-but-unarchived projects and offers to `git mv` them into `.vine/projects/.archive/`. Closes the gap where `evolve` only archives the project it just resolved. Documented in STATE.md's Project Lifecycle as the catch-up path.
- **Sweep executed on this repo** (`49ccf40`) — the new step's first real run archived 11 legacy resolved projects (≈50 file renames, history preserved). Knowledge records under `.vine/knowledge/` were not moved. This is a repo-state migration bundled into the PR, not feature wiring.

### Agent Evolution

#### CLAUDE.md Suggestions

- **Accepted** — Added `.vine/knowledge/<domain>/` to the Repository Structure list (committed
  durable-decision ADR records, tracked, independent of the project lifecycle, never moved by
  archival). The layer is now live; a contributor session needs to know where it lives.

#### Skill Suggestions

None. This cycle was framework wiring, not a repeatable per-feature workflow — no scaffold or
checklist pattern emerged that a skill would capture.

#### VINE Process Observations

- **Dogfood loop closed cleanly.** This cycle *built* evolve's Distill step and then evolve ran it
  on this same cycle — strong signal the writer/reader wiring is internally coherent. Minimal
  meta-friction.
- **One real friction:** the `.gitignore` deny+allowlist shape silently left slice-2's records
  untracked until a commit failed. Captured as a knowledge record and follow-up [#108](https://github.com/moduloMoments/VINE/issues/108).
- **Evolve length watch held.** The referential-adjacency approach (one routing rule naming all
  four homes, rather than restructuring evolve into a fourth full flow) kept the long command from
  bloating — recorded as durable judgment.
- **Suggested next:** this cycle changed `evolve.md` and `verify.md` and added the `.vine/knowledge/`
  layer. Running `/vine:optimize` would refresh the workflow map in `shared.md` and re-score
  descriptions against the new behavior.

#### Durable Decisions Recorded

Two workflow-domain records written via evolve's own Distill step (both `Supersedes: none`):
- `2026-06-16-evolve-states-the-four-knowledge-homes-referentially.md` — why the four homes are
  stated referentially, not by physical restructure (slice 3).
- `2026-06-16-defer-the-vine-gitignore-inversion-to-the-vine-local-work.md` — why the minimal
  gitignore negation was kept and the full inversion deferred (slice 2, Rob's call).

### User Evolution

#### Engineer Contributions

- **The keep-negation-defer-inversion call (slice 2).** Rob steered away from inverting the
  `.gitignore` now — recognizing that an early inversion would be a half-migration carrying two
  competing models until `.vine.local/` exists. That judgment is now a durable record and a gated
  follow-up, keeping the cleanup coupled to the change that completes it.
- **Pre-set steers that kept inquire focused.** The CONTEXT steers (bootstrap = seed real records;
  no new trellis check; routing-criteria Option A; STATE.md supersede fix in scope) front-loaded
  the contested calls so navigate ran free-climb without re-litigation.
- **Authorship continuity.** Rob authored the routing foundation and this spec; the cycle executed
  cleanly inside that frame.

This was routine framework wiring in Rob's confident domain — no new ground broken, no manufactured
growth.

#### Profile Updates

- **workflow:** kept at `confident` (no change). Routine wiring in the comfort zone; level already
  reflects authorship of the routing foundation and this spec.
- **Growth log:** none — not every cycle needs an entry; this one didn't.

#### Claude Memory Suggestions

None this cycle. The cycle's non-obvious judgment was project-specific (gitignore shape, referential
adjacency) and routed to `.vine/knowledge/` records, not to cross-domain memory. No general
interaction preference surfaced.

### Handoff Package

#### PR Description

```markdown
## Summary
Wires up the durable-decisions layer that the format spec already defined. `vine:evolve` becomes
the writer (a Distill step that records team judgment as committed ADR files), `vine:verify`
becomes the reader (surfaces prior decisions before exploring), and the convention is documented
end-to-end. Closes the gap where the `.vine/knowledge/` format existed in the spec but no command
read or wrote it.

## Changes
- **STATE.md consistency + Knowledge Boundary** (`f5349c0`) — fixed the property-4-vs-template
  contradiction, graduated `.vine/knowledge/` to a first-class home with a routing decision tree,
  documented the slug convention and archival-persistence semantics.
- **Bootstrap records** (`90d1191`) — three genuine `workflow`-domain ADR records so the format is
  proven and verify has day-one content; tracked via a `!.vine/knowledge/` gitignore negation.
- **evolve.md writer wiring** (`7f11830`) — a Distill Durable Decisions step (mine → multiSelect →
  write one ADR per record), bidirectional supersession, and a post-resolve archive offer.
- **verify.md reader wiring** (`999288f`) — globs `.vine/knowledge/<domain>/` early in Read the
  Landscape and surfaces records (never auto-trusts contradictions).
- **README** (`4d029a2`) — documents the layer, the active→resolved→archived lifecycle, and that
  knowledge persists across archival.

## Decisions Made
- The four knowledge homes are stated by one referential routing rule, not a physical restructure
  of evolve — keeps a long command from bloating.
- Kept the minimal gitignore negation and deferred the full `.vine/`-track-by-default inversion to
  the `.vine.local/` work (#108) rather than half-migrating now.

## Testing
- `trellis-check.sh` — 11/11 commands pass, 8 cross-reference anchor pairs resolve.
- Dogfood: verify's glob surfaces the three bootstrap records; evolve's Distill step ran on this
  cycle and produced two new records.

## Follow-up
- #108 gitignore inversion · #109 record-format validator. (#110 gated CLAUDE.md pointer was delivered in this PR — see Post-Evolve Additions.)
```

#### Reviewer Notes

- **Backward compatibility is the hard gate.** With no `.vine/knowledge/` files present, verify and
  evolve behave exactly as before — verify's glob no-ops, evolve's Distill step writes nothing.
  Confirm the no-record paths in both commands.
- **Supersession is the one sanctioned edit to an immutable record.** The flip touches the Status
  line only (`Accepted → Superseded by <new-slug>`); the body stays frozen. This is the lone
  exception to the append-only guarantee — check evolve scopes it to the Status line.
- **STATE.md / README don't ship to consumer repos** (`create-vine` installs only `commands/vine/`,
  `agents/`, `journal-check.sh`). That's why the routing rule has an operative copy inline in
  evolve and STATE.md carries the canonical version — the dangling pointer degrades gracefully.
- **Records are not trellis-gated this cycle** (steered; see #109). Format compliance rides the
  writing command.

#### Commit Suggestions

Slices are already committed atomically (`f5349c0`, `90d1191`, `7f11830`, `999288f`, `4d029a2`).
The evolve phase adds one commit: EVOLUTION.md, the two new knowledge records, the CLAUDE.md line,
PROJECT-MAP update, and the `.resolved` marker.
