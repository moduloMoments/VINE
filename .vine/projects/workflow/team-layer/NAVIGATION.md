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
**Commit**: df64d3b
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

### Slice 4: Two-root project discovery — Complete
**Started**: 2026-06-22 12:15
**Commit**: pending
**Gear**: free-climb
**Approach taken**: Taught all 8 discovery sites to scan both `.vine/projects/` and
`.vine.local/projects/` by referencing the single Filtering Convention in `references/STATE.md`
rather than restating the filter rules per site (referential-homes stance). Sites updated:
`status.md` (preserved its "include resolved, marked" exception), `pause.md`, `resume.md`,
`navigate.md`, `inquire.md`, `evolve.md`, `init.md`'s archive sweep, and `.claude/commands/trellis.md`'s
Glob (Step 5b). Amended STATE.md's Filtering Convention with a **Resolving the personal root**
paragraph: the gitignored `.vine.local/` is resolved at the repository's *primary* worktree via
`git rev-parse --git-common-dir` (cwd fallback for non-git dirs) so worktree sessions enumerate the
same local-only projects instead of silently finding none — the discovery half of the worktree ADR.
Made `init.md`'s archive sweep root-aware (each project archives within its own root's `.archive/`;
the existing `git mv`/plain-`mv` branch maps cleanly to shared/local). Folded in the Slice-3
profile-path leftover in trellis (`.vine/PROFILE.md` → `.vine.local/PROFILE.md`, 3 refs).
**Deviations from spec**: Two bounded additions beyond the literal "discovery" scope, both for
correctness in the same code paths I was already editing: (1) `init.md` archive-sweep *destination*
made root-aware (not just the *scan*), else a local project would archive into the shared
`.vine/projects/.archive/`; (2) the trellis profile-path fix, a Slice-3 leftover (AC3's profile move)
surfaced because trellis's discovery section was in scope here. Recorded, not silent.
**Validation**: pass — `sh .vine/scripts/trellis-check.sh` exit 0 (11/11 commands, 8 cross-ref anchor
pairs; `.vine/.trellis-ok` stamped pass at 12:33, fresh after all edits). Artifact validation
unaffected — Slice 4 touched no artifact files and no STATE.md template fences, so the parsed
templates and the feature's artifacts (validated in prior slices) are unchanged. The two pre-existing
allowlisted `.vine/hooks/` legacy warnings (init.md:104-105) are unrelated.
**Decisions made during implementation**:
  - Scope Slice 4's STATE.md amendment to the **Filtering Convention** (discovery's git-anchored
    resolution of the personal root) and leave the general two-roots contract + the `ACTIVE` per-tree
    git-dir split entirely to Slice 5 — keeps STATE.md internally non-contradictory at every step (no
    half-changed `ACTIVE` contract), unlike the broad Slice-1 consolidation (decided by: claude, after
    flagging the alternative to the engineer; confidence: high)
  - Make each site a thin reference to the Filtering Convention while preserving its distinct tail
    (status includes-resolved, pause "nothing active to pause", resume/inquire/evolve `/vine:verify`
    suggestion) rather than a uniform boilerplate swap (decided by: claude; confidence: high)
  - Fold the trellis `.vine/PROFILE.md` → `.vine.local/PROFILE.md` fix into this slice since trellis's
    discovery section was already open, rather than leave a known Slice-3 gap (decided by: claude —
    flagged in preview; confidence: high)
**Acceptance criteria**:
  - [x] AC6 — all feature-enumerating commands (status, resume, pause, navigate, inquire, evolve,
    init's archive sweep) and trellis discover projects in **both** roots with `.resolved`/`.archive/`
    filtering applied to each; the two-root rule is stated once (Filtering Convention) and referenced,
    not restated per site
**Engineer feedback incorporated**: Gear choice (free climb) and the two flagged judgment calls were
presented before coding; engineer chose free climb, trusting the approach. No mid-slice redirection.
**Learnings**:
  - Engineer → Claude: (none new this slice)
  - Claude → Engineer: A "discovery" slice can't cleanly stop at the *scan* — the archive *destination*
    and the personal-root *resolution* live in the same code paths, so getting discovery right pulls in
    root-awareness and the git-anchoring the worktree ADR specified. The referential-homes home (one
    Filtering Convention statement) is what kept that from rippling into 8 separate restatements.

### Handoff note for Slice 9 (init Upgrade Mode)
Upgrade Mode should offer to relocate a legacy `.vine/context/*.local.md` → `.vine.local/context/*.md`
(suffix dropped) for repos tracking `main`. This is a courtesy migration, not a shipped-version compat
need — the personal-layer convention never shipped (see Slice 2 decision). Declining must change nothing.

### Remaining Work
- **Incomplete slices**: Phase 1 (Slices 1-3) complete and committed (3139119, e28a5c8, df64d3b).
  Phases 2-3 (Slices 4-10) remain — a fresh session each, per the multi-PR plan.
- **Blockers encountered**: None.
- **Handoff context**:
  - **Phase-group verification (Phase 1)**: trellis green; AC1/AC2/AC3/AC6/AC7 all met. The
    `vine-verification` agent flagged `evolve.md:64` (`delete .vine/ACTIVE`) as mismatching STATE.md's
    `.vine.local/ACTIVE`. **Not a Phase 1 gap** — deferred to Slice 5. Direct check confirmed the ACTIVE
    *machinery* is uniformly `.vine/ACTIVE` across all commands + hook scripts (navigate writes it,
    pause/navigate/evolve delete the same path, journal-check.sh/run-tests.sh read it), so the runtime
    is self-consistent; only STATE.md's contract documents the end-state. Fixing `evolve.md:64` in
    isolation now would BREAK it (delete the wrong path while navigate still writes the old one).
  - **Slice 5 (Phase 2) ACTIVE-relocation checklist** — move all of these from `.vine/ACTIVE` →
    `.vine.local/ACTIVE` together: `navigate.md:79` (writer) + `:384/:416/:478/:557` (leave/delete),
    `pause.md:100` (delete), `evolve.md:64` (delete), `journal-check.sh:12` (+ line 4 comment, line 63
    escape-hatch message), `run-tests.sh:35`. Same slice relocates PAUSE.md to `.vine.local/projects/...`.
  - **PR 1 reviewer note**: STATE.md documents the `.vine.local/` end-state (ACTIVE/PAUSE/PROFILE/
    gitignore) ahead of the command + hook machinery, which relocates in Phases 2-3. This is the
    intended "contract leads implementation" phasing (maintainer-directed in Slice 1), not drift.
  - **Shipped-command ref hygiene (done post-Phase-1, in PR #122)**: per a maintainer directive,
    removed all VINE-internal references that shouldn't ship to downstream users — the `vine:team`
    command (never built), the issue links #57/#52/#56, and the README scaffold's "on the roadmap /
    not yet shipped" forward-looking block (collapsed to shipped-only "Team distribution" guidance).
    Also corrected the never-shipped `shared.local.md` convention references in init's customize
    bullet + the team distribution block to `.vine.local/context/`. Mirrored the team-recommendation
    fix into `.vine/context/shared.md`.
  - **Slice 10 docs-sweep deferrals** (remaining): the WHOLE `.vine/README.md` scaffold in init.md
    is currently split-brained on the personal layer and must be reworked as one unit — both the
    overlay-precedence **prose** (the `shared.local.md` lines ~302/307/315/318, left as-is this phase)
    AND the directory **table** (`PROFILE.md` / `ACTIVE`,`PAUSE.md` rows ~304/306). The post-Phase-1
    ref-hygiene pass updated only the customize bullet + team-distribution block to `.vine.local/`,
    so the scaffold now names both conventions — Slice 10 must close the entire block, not just the
    table. Gated on Phase 2's final locations (per the worktree ADR, `ACTIVE` lands in the
    per-worktree git dir, NOT `.vine.local/` — don't bake `.vine.local/ACTIVE` into the table).
    Plus shared.md's gitignore-tracking note (~line 70/82), CLAUDE.md, README.md, and STATE.md's
    surfaces per the State Artifact Addition Checklist. (Surfaced by the cold vine-reviewer pass on
    PR #122.)
  - **Worktree resolution (Phase 2 — design added 2026-06-22)**: gitignored personal state is invisible
    to git worktrees/clones (confirmed live — the main checkout's `.vine/PROFILE.md` was unseen by this
    worktree session). Phase 2 must resolve the personal root from git, not cwd: shared root (profile,
    overlays, local projects, pause) via `git rev-parse --git-common-dir`; `ACTIVE` to the per-worktree
    git dir via `git rev-parse --git-dir` (so hooks don't cross-fire); non-git fallback = cwd. Full
    rationale in knowledge ADR `2026-06-22-anchor-the-personal-root-at-the-repo-shared-across-worktrees`;
    SPEC Phase 2 summary annotated. Extends Slices 4-5; amend STATE.md's contract there. Stopgap applied
    this session: symlinked this worktree's `.vine/PROFILE.md` → main checkout.
