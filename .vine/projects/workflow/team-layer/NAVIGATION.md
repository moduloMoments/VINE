# Navigation Log: Personal/Local Layer (#52)
## Date: 2026-06-22

### Slice 1: Formalize the `.vine.local/` contract in STATE.md — Complete
**Started**: 2026-06-22 08:40
**Commit**: pending
**Gear**: walk-me-through
**Approach taken**: Promoted `.vine.local/` from the `**Forward references**` backlog placeholder
to a real contract in `references/STATE.md`. Added a "The two roots" subsection under Directory
Structure (the canonical contract home, top of file) defining the shared `.vine/` vs personal
`.vine.local/` split: sibling root mirroring `.vine/`'s structure, what it holds (personal overlays,
`.vine.local/PROFILE.md`, `.vine.local/ACTIVE`, PAUSE under `.vine.local/projects/...`, local-only
projects), the gitignored-entirely guarantee, and the location-based (not suffix-based) distinguisher.
Relocated every `.vine/ACTIVE` (6 refs), `.vine/PROFILE.md` (2 refs), and the PAUSE.md path to their
`.vine.local/` end-state. Rewrote `## Committing Artifacts` to describe the per-path `git check-ignore`
commit test, and `### Filtering Convention` to state the two-root scan rule once (for Slice 4's scan
sites to reference). Removed the graduated Forward-references placeholder.
**Deviations from spec**: None. All Slice 1 ACs (AC1, AC6, AC7) met with only `references/STATE.md`
touched, matching the slice's stated file list.
**Validation**: pass — `sh .vine/scripts/trellis-check.sh` exit 0 (11/11 commands pass, 8 cross-ref
anchor pairs resolve). No markdownlint config or test suite exists in this repo (pure markdown), so
trellis-check is the only mechanical gate. Pre-existing `init.md` legacy-`.vine/hooks/` warning is
unrelated to this slice.
**Decisions made during implementation**:
  - Document STATE.md at its finished end-state with no transitional hedging (e.g. `rm .vine.local/ACTIVE`
    escape hatch written to the target even though navigate's writer relocates in Slice 5): STATE.md is
    the contributor-only contract reference and already documents conventions ahead of implementation
    (decided by: engineer — surfaced via AskUserQuestion; confidence: high)
  - Consolidate ALL STATE.md path-relocations (including the PROFILE.md and PAUSE.md section mentions
    that Slices 3/5 otherwise touch in command files) into this slice, so STATE.md is internally
    consistent in one move. Slices 3 and 5 therefore touch only shared.md / command files / hook scripts,
    not STATE.md — consistent with their stated file lists, which never claimed STATE.md (decided by:
    claude; confidence: high)
  - Home the contract in Directory Structure (a "The two roots" subsection) rather than a new top-level
    section, keeping doc growth modest on an already-600+-line file (decided by: claude; confidence: medium)
**Acceptance criteria**:
  - [x] AC1 — `.vine.local/` documented as a real contract (structure mirrors `.vine/`, what it holds,
    gitignored-entirely guarantee); Forward-references placeholder removed
  - [x] AC6 — Filtering Convention states the two-root scan once, framed as the single referenced home
  - [x] AC7 — per-path `git check-ignore` commit test described (specific feature dir, not the root)
  - [x] Artifact-template `<!-- required -->` / `<!-- optional -->` markers unchanged
**Engineer feedback incorporated**: On the ACTIVE-wording decision, the engineer directed documenting
the finished end-state ("if we are only updating state, just update it to what it will be when this
project is done") rather than a transitional note — simplifying the section to its target form.
**Learnings**:
  - Engineer → Claude: STATE.md is a contract/reference doc — describe the finished design, not the
    in-flight transitional state; the per-PR implementation lag is expected and the doc leads it.
  - Claude → Engineer: The "state the rule once, reference it" (referential-homes) stance applies
    cleanly here — the two-root scan and per-path commit test each get a single authoritative home in
    STATE.md that later slices (4, 6) point at instead of restating.
