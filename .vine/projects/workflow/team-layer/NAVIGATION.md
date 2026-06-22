# Navigation Log: Personal/Local Layer (#52)
## Date: 2026-06-22

### Slice 1: Formalize the `.vine.local/` contract in STATE.md — Complete
**Started**: 2026-06-22 08:40
**Commit**: 3139119
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

### Slice 2: Overlay composition reads the personal root — Complete
**Started**: 2026-06-22 10:25
**Commit**: e28a5c8
**Gear**: walk-me-through
**Approach taken**: Updated the Overlay Loading Protocol (Personal layer bullet) and Overlay
Precedence (intro, the two conflict bullets, the Personal layer paragraph, the closing
resolution-rule line) in `.vine/context/shared.md`, and mirrored the same change in
`commands/vine/init.md`'s embedded shared.md template. The personal layer now reads from
`.vine.local/context/<name>.md` — the mirrored path under the personal root, `.local` suffix
dropped — generalized so any repo overlay (`shared.md` and the phase overlays) can have a personal
counterpart, not just `shared.local.md`. Policy-class carve-out unchanged; no-op when no personal
file exists.
**Deviations from spec**: None. Scoped to shared.md + init.md's embedded template. The
README-scaffold `shared.local.md` mentions in init.md (lines ~290-350) are deferred to Slice 10's
documentation sweep, per the SPEC's file assignment.
**Validation**: pass — `/trellis` engine green (11/11 commands, 8 cross-ref anchor pairs;
`.vine/.trellis-ok` stamped pass). Two pre-existing allowlisted `.vine/hooks/` legacy warnings
(init.md:104-105) are unrelated. AC2 confirmed by inspection: composition reads the new path, policy
carve-out preserved, absent personal files is a no-op.
**Decisions made during implementation**:
  - Loader reads the NEW path only — no legacy `.vine/context/<name>.local.md` fallback. The
    `shared.local.md` personal-layer convention never shipped: at tag v0.3.0 (latest published
    release) the shipped `init.md` has zero `shared.local`/Overlay-Precedence references, so it
    landed on `main` post-release. No downstream population to stay backward-compatible with; init
    Upgrade Mode (Slice 9) relocates it for `main`-trackers as a courtesy, not a compat requirement
    (decided by: engineer — after confirming the convention is unshipped; confidence: high)
  - Defer init.md's README-scaffold personal-layer mentions to Slice 10 rather than pull them
    forward, keeping the documentation-sweep PR coherent. The transient inconsistency between init's
    embedded template (updated) and its README scaffold (not yet) is `main`-only and
    contributor-visible only (decided by: claude; confidence: medium)
**Acceptance criteria**:
  - [x] AC2 — personal overlay read from `.vine.local/context/<name>.md` composed over the repo
    overlay at `.vine/context/<name>.md`, policy-class carve-out preserved; absent personal files →
    no change in behavior
**Engineer feedback incorporated**: On backward-compat, the engineer asked whether the convention
shipped in the last version (directing: migrate via init upgrade path if it had). It hadn't, so no
loader fallback was added.
**Learnings**:
  - Engineer → Claude: Check whether a convention actually shipped in a released version before
    building backward-compat machinery — an unshipped convention needs no fallback, only a migration
    courtesy for source-trackers.
  - Claude → Engineer: `shared.md` and init.md's embedded template must move in lockstep; the
    personal layer generalizes cleanly from "one file `shared.local.md`" to "any overlay's mirrored
    counterpart under `.vine.local/context/`".

### Slice 3: Profile loader path + team recommendation note — Complete
**Started**: 2026-06-22 10:45
**Commit**: pending
**Gear**: walk-me-through
**Approach taken**: Relocated the engineer-profile path `.vine/PROFILE.md` → `.vine.local/PROFILE.md`
across every functional site: the read protocol (`shared.md` Engineer Profile Protocol, `status.md`
Load Engineer Profile, `init.md`'s embedded protocol), the write/create sites (`verify.md` domain-add,
`evolve.md` Update Engineer Profile × create/update/write, `init.md` Upgrade-Mode existence check), the
routing-tree pointer + completion-summary line in `evolve.md`, and the init completion message. Added a
`### Team conventions (recommendation)` subsection to `shared.md`'s Overlay Precedence (mirrored in
init.md's embedded template): team conventions are repo-owned — put them in the tracked `shared.md` and
mark governance `<!-- class: policy -->`; no `vine:team` command or separate team-overlay file; plugin
distribution is #57.
**Deviations from spec**: None — but a scope clarification worth recording (AC intent over letter):
AC3 names only the profile *reader*, yet no later slice moves the profile *writers*. Moving only the
read path would break the profile (written to `.vine/`, read from `.vine.local/`), so this slice moves
all functional read+write+existence sites together. Deferred to Slice 9/10 (deliberately, not missed):
the bare-`PROFILE.md` mentions in init.md's `.vine/README.md` scaffold (init.md:292, 368) and the repo
gitignore-tracking note (shared.md:70) — those describe the directory/gitignore model the flip changes.
**Validation**: pass — `/trellis` engine green (11/11 commands, 8 cross-ref anchor pairs;
`.vine/.trellis-ok` stamped pass). Same two pre-existing allowlisted `.vine/hooks/` warnings, unrelated.
AC3 confirmed: loader reads `.vine.local/PROFILE.md`, absent → unchanged default-depth behavior; the
team recommendation glosses #57 (reads without dereferencing).
**Decisions made during implementation**:
  - Move profile write paths (verify/evolve) in this slice, not just the reader, for read/write
    coherence — intent over letter, since no other slice covers them (decided by: claude; confidence: high)
  - File-wide swap of the full path `.vine/PROFILE.md` (backticked + the two non-backticked output
    strings), leaving bare `PROFILE.md` scaffold/gitignore mentions for the docs sweep — the bare/full
    split happens to map exactly onto the functional/cosmetic boundary (decided by: claude; confidence: high)
  - Home the team recommendation under Overlay Precedence (not Team Context), so it sits with the
    layering/policy-marker explanation it builds on and Slice 10's README can point to it (decided by:
    claude; confidence: medium)
**Acceptance criteria**:
  - [x] AC3 — profile loader reads `.vine.local/PROFILE.md`; absent → no prompt/warning, default depth
  - [x] Team recommendation present in shared.md + init.md embedded template, reads without
    dereferencing (Reference Legibility — #57 glossed)
**Engineer feedback incorporated**: None beyond the gear choice; approach matched the preview.
**Learnings**:
  - Engineer → Claude: (none new this slice)
  - Claude → Engineer: When a path moves, the read and write sites are one atomic unit — a slice that
    moves only the reader silently breaks the feature; the SPEC's per-slice file lists are a guide, not
    a hard partition when correctness spans them.

### Handoff note for Slice 9 (init Upgrade Mode)
Upgrade Mode should offer to relocate a legacy `.vine/context/*.local.md` → `.vine.local/context/*.md`
(suffix dropped) for repos tracking `main`. This is a courtesy migration, not a shipped-version compat
need — the personal-layer convention never shipped (see Slice 2 decision). Declining must change nothing.
