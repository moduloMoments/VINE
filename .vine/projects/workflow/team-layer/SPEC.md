# Feature Spec: Personal/Local Layer (#52, reshaped)
## Date: 2026-06-18
## Built on: CONTEXT.md (2026-06-18)
## Decisions made by: Rob

### Problem Statement

#52 was scoped as a "team layer" — team conventions that install with the project. Inquire
reshaped it: a *prescribed* team-overlay mechanism (named `context/teams/<name>.md` files, a
`vine:team` command, a cross-team precedence engine) is VINE imposing a shape that orgs should
own. Team structure varies company to company, so it's repo/team-owned, not framework-owned
(the repo-owned-decisions principle).

What *is* genuinely VINE-owned, and what this cycle ships:

1. **The personal/local split.** A gitignored sibling root `.vine.local/` mirroring `.vine/`,
   holding everything that's personal to one machine: personal overlays, the engineer profile,
   the active-session sentinel, pause state, and local-only feature projects. This is your
   machine vs the shared tree — no org redefines it.
2. **The #108 gitignore inversion.** Replace the brittle deny-then-allowlist root `.gitignore`
   with track-by-default: `.vine/` is tracked, `.vine.local/` is ignored, and that's the whole
   rule. The knowledge record gates #108 on `.vine.local/` landing and asks for the flip in one
   coherent move — this cycle is that move.
3. **Per-feature visibility.** New projects default to shared; verify offers a "keep local"
   opt-out; evolve offers local→shared promotion at wrap-up.
4. **A documented recommendation for teams** (not a mechanism): teams configure repo-level
   overlays (`shared.md` and the existing `<!-- class: policy -->` marker) however their org
   maps. Distribution of those overlays is the plugin cycle's job (#57).

**AC reinterpretation (intent over letter):** #52's intent — "team conventions install with the
project" — is satisfied by the mechanism that already exists (tracked `shared.md` + policy-class
marker) plus #57's plugin distribution. The prescribed-layer letter is dropped as
over-engineering. #52's AC4 (conflict-safe conventions) is already realized by the append-only,
one-record-per-file patterns; this cycle extends the tracked/local split to feature directories.

### Approach

**Sibling root, full inversion.** `.vine.local/` mirrors `.vine/`'s structure on demand
(`context/`, `projects/`, optionally `knowledge/`, plus `PROFILE.md` and `ACTIVE`). The entire
root is gitignored, so the root `.gitignore` collapses to a single line — `.vine.local/` — with
zero per-file rules inside `.vine/`. Every personal/ephemeral file relocates out of `.vine/`:

| Today (gitignored in-place)            | After                                         |
|----------------------------------------|-----------------------------------------------|
| `.vine/context/*.local.md`             | `.vine.local/context/<name>.md` (drop suffix) |
| `.vine/PROFILE.md`                     | `.vine.local/PROFILE.md`                      |
| `.vine/ACTIVE`                         | `.vine.local/ACTIVE`                          |
| `.vine/projects/<d>/<f>/PAUSE.md`      | `.vine.local/projects/<d>/<f>/PAUSE.md`       |
| (local-only projects: didn't exist)    | `.vine.local/projects/<d>/<f>/`               |

**Personal layer = same filename, different root.** Today the repo overlay (`shared.md`) and the
personal overlay (`shared.local.md`) are distinguished by *suffix* in one directory. After the
move, the distinguisher is *location*: `.vine/context/shared.md` (repo) vs
`.vine.local/context/shared.md` (personal). The loader reads both and composes personal-over-repo
with the policy-class carve-out unchanged. The `.local` suffix is dropped because the root already
signals personal scope. Any repo overlay (`shared.md`, phase overlays) can have a personal
counterpart at the mirrored path.

**Discovery scans two roots.** Commands that enumerate features scan both `.vine/projects/*/*/`
and `.vine.local/projects/*/*/`, applying the same `.resolved` / `.archive/` filtering to each.
To avoid restating the two-root rule at 7+ sites (the duplication the referential-homes record
warns against), the rule is stated once (Filtering Convention in `references/STATE.md`) and the
scan sites reference it.

**Per-path commit test.** The commit-or-skip test stops checking the `projects/` root and instead
runs `git check-ignore` on the *specific* feature directory. A project under `.vine/projects/`
reads as committable; one under `.vine.local/projects/` reads as ignored — so the same test
routes shared and local projects correctly with no special-casing.

**Visibility.** verify (the only command that creates projects) defaults new projects to
`.vine/projects/` (shared, fits work-in-public) and surfaces a one-tap "keep this local" option
that routes to `.vine.local/projects/` instead. evolve offers local→shared promotion (move the
directory) at wrap-up.

**Team recommendation (docs only).** README's "Piloting" section becomes a solo→team graduation
path that points at the existing primitives: edit the tracked `shared.md`, mark team governance
`<!-- class: policy -->`, and (future) install team overlays as plugins (#57). No new files, no
new command.

### Acceptance Criteria

1. Root `.gitignore` is track-by-default: `.vine/` and all current subdirs are tracked with no
   per-file negation lines; `.vine.local/` is the only ignore rule. `git check-ignore` reports
   every file under `.vine/` as tracked and every file under `.vine.local/` as ignored.
2. The overlay loader composes a personal overlay read from `.vine.local/context/<name>.md` over
   the repo overlay at `.vine/context/<name>.md`, preserving the policy-class carve-out
   (personal cannot weaken a `<!-- class: policy -->` section). Absent personal files → no change
   in behavior.
3. The profile loader reads `.vine.local/PROFILE.md`; absent it, commands behave as they do with
   no profile (no prompt, no warning).
4. `vine:navigate` writes the active sentinel to `.vine.local/ACTIVE`; `journal-check.sh` and
   `run-tests.sh` read that location; the active-session hook fires correctly against it.
5. `vine:pause` writes `PAUSE.md` under the feature's path within `.vine.local/projects/...`, and
   resume/inquire/navigate/evolve consume it from there (consumed-once rule intact).
6. All feature-enumerating commands (status, resume, pause, navigate, inquire, evolve, init's
   archive sweep) and trellis discover projects in **both** `.vine/projects/` and
   `.vine.local/projects/`, with `.resolved` and `.archive/` filtering applied to each; the
   two-root rule is stated once and referenced, not restated per site.
7. The commit-or-skip test in verify/inquire/navigate/evolve runs against the specific feature
   directory, committing shared projects and skipping local ones.
8. `vine:verify` defaults new projects to shared and offers a "keep local" option that creates the
   project under `.vine.local/projects/`; `vine:evolve` offers local→shared promotion.
9. `vine:init` scaffolds the new single-line `.gitignore` for fresh repos, and its Upgrade Mode
   offers existing repos an opt-in migration (relocate personal files + flip `.gitignore`) where
   **declining changes nothing** (#58 rename-fallback).
10. This repo is migrated as the worked example: `.gitignore` flipped, `ACTIVE` relocation wired,
    `git status` shows no unintended tracking changes for existing committed artifacts.
11. README "Piloting", CLAUDE.md tracked/gitignored bullets, init's `.vine/README.md` scaffold,
    and `references/STATE.md` (Forward references, Committing Artifacts, ACTIVE guarantee,
    Filtering Convention) reflect the now-real `.vine.local/` contract and the team recommendation.
12. `/trellis` passes; no command file references a personal path that has moved.

### Work Slices

## Phase 1: Composition Model (Slices 1-3) ✅
Summary: Formalize the `.vine.local/` contract and teach overlay + profile loading to compose the
personal root. No `.gitignore` flip yet — loaders learn the new location while the old one still
works, so nothing breaks mid-cycle.
Session boundary: After this phase, the composition model is defined and documented; a personal
overlay placed in `.vine.local/context/` composes correctly. Ships as PR 1.

### Slice 1: Formalize the `.vine.local/` contract in STATE.md
**Goal**: Turn the `**Forward references**` backlog idea (`STATE.md:484-486`) into the real
contract: `.vine.local/` structure (mirrors `.vine/`), what it holds, gitignored-entirely
guarantee. Update Committing Artifacts (per-path test), the ACTIVE "never leaves the machine"
guarantee (new location), the Filtering Convention (two-root scan, stated once), and the
Source-of-Truth table.
**Depends on**: Nothing.
**Files likely touched**: `references/STATE.md`.
**Acceptance criteria**: AC1 (contract text), AC6 (Filtering Convention single statement), AC7
(per-path test described). Section headings keep their `<!-- required -->`/`<!-- optional -->`
markers.
**Complexity signal**: Medium — load-bearing contract that later slices implement against.

### Slice 2: Overlay composition reads the personal root
**Goal**: Update the Overlay Loading Protocol and Overlay Precedence in `shared.md` so the
personal layer is read from `.vine.local/context/<name>.md` (location-based, suffix dropped) and
composed personal-over-repo with the policy carve-out intact. Update the legacy/missing-file
behavior accordingly. Because `init.md` embeds the `shared.md` template, update both in lockstep.
**Depends on**: Slice 1.
**Files likely touched**: `.vine/context/shared.md`, `commands/vine/init.md` (embedded template),
every command's "Load Context Overlays" step if it hardcodes `.vine/context/*.local.md`.
**Acceptance criteria**: AC2. Composition with no personal files present is a no-op.
**Complexity signal**: Medium — touches the shared protocol referenced by all phases.

### Slice 3: Profile loader path + team recommendation note
**Goal**: Point the Engineer Profile Protocol (and any command "Load Engineer Profile" step that
hardcodes the path) at `.vine.local/PROFILE.md`. Add the team-overlay recommendation to `shared.md`
(repo-level overlays + policy-class marker; distribution → #57) — replacing what would have been a
prescribed team layer with a one-paragraph pointer.
**Depends on**: Slice 2.
**Files likely touched**: `.vine/context/shared.md`, `commands/vine/init.md` (embedded template),
command "Load Engineer Profile" references.
**Acceptance criteria**: AC3, plus the team recommendation reads without dereferencing
(Reference Legibility).
**Complexity signal**: Low.

## Phase 2: Discovery & Session Plumbing (Slices 4-6) ✅
Summary: Make every command find projects in both roots, relocate the session-state files
(PAUSE/ACTIVE) and update the hook scripts that read them, and switch the commit test to per-path.
Session boundary: After this phase, all commands operate correctly across both roots while the
`.gitignore` is still in its old state. Ships as PR 2.

**Added 2026-06-22 (worktree resolution — see knowledge ADR
`2026-06-22-anchor-the-personal-root-at-the-repo-shared-across-worktrees`):** gitignored personal
state is invisible to git worktrees/clones (a worktree session can't see the main checkout's
`.vine.local/`). Phase 2 must resolve the **shared** personal root (profile, overlays, local projects,
pause) from git, not cwd: it anchors at the primary worktree via `git rev-parse --git-common-dir`
(non-git dirs fall back to cwd-relative). This extends Slice 4 (discovery resolves the shared root) and
Slice 5 (PAUSE relocation uses the git-anchored shared root); STATE.md's `.vine.local/` contract is
amended across both to match.

> **Amended 2026-06-22 (Slice 5):** the ADR originally moved the **`ACTIVE`** sentinel to the
> per-worktree git dir (`git rev-parse --git-dir`). During implementation we kept it at `.vine/ACTIVE`
> (gitignored) instead — `.vine/` is tracked, so each worktree checks out its own copy and a gitignored
> `.vine/ACTIVE` is per-tree for free, with **no** `git rev-parse` and **no** hook-script changes. Cost:
> the Slice-9 gitignore flip carries an explicit `.vine/ACTIVE` rule alongside `.vine.local/`. The ADR's
> Status + Decision + an Amendment section record this; the shared-root anchoring is unchanged.

### Slice 4: Two-root project discovery
**Goal**: Extend the 7 prose scan sites (status, resume, pause, navigate, inquire, evolve, init's
archive sweep) and trellis's glob to scan `.vine/projects/*/*/` **and** `.vine.local/projects/*/*/`,
filtering each by `.resolved` / `.archive/`. Per the referential-homes record, reference the
single Filtering Convention statement (Slice 1) rather than restating the two-root rule at each
site.
**Depends on**: Slice 1.
**Files likely touched**: `commands/vine/{status,resume,pause,navigate,inquire,evolve,init}.md`,
`.claude/commands/trellis.md`.
**Acceptance criteria**: AC6.
**Complexity signal**: Medium — many sites, but mechanical once the convention is referenced.

> **Addendum (implemented 2026-06-22):** Slice 4 also made two bounded corrections in code paths it
> was already editing, beyond the literal "scan" scope: (1) `init.md`'s archive-sweep *destination* is
> now root-aware — a project archives within its own root's `.archive/` (the `git mv`/plain-`mv` branch
> maps to shared/local), not always `.vine/projects/.archive/`; (2) trellis's profile path was corrected
> to `.vine.local/PROFILE.md` (a leftover from Slice 3's AC3 profile move, surfaced because trellis's
> discovery section was in scope). STATE.md's Slice-4 amendment is scoped to the **Filtering Convention**
> (personal-root resolution via `git rev-parse --git-common-dir`); the general two-roots contract and the
> `ACTIVE` per-tree split remain Slice 5's, so STATE.md stays internally consistent at each step.

### Slice 5: Relocate PAUSE + ACTIVE and update hook scripts
**Goal**: pause writes `PAUSE.md` under `.vine.local/projects/<d>/<f>/`; resume and the consume
sites (inquire/navigate/evolve) read it there. navigate writes `.vine.local/ACTIVE`
(`navigate.md:83` template). Update `journal-check.sh:12` and `run-tests.sh:35` to the new ACTIVE
location.
**Depends on**: Slice 4.
**Files likely touched**: `commands/vine/{pause,resume,navigate,inquire,evolve}.md`,
`.vine/scripts/journal-check.sh`, `.vine/scripts/run-tests.sh`.
**Acceptance criteria**: AC4, AC5.
**Complexity signal**: Medium — hook scripts must move in lockstep with navigate's writer.

> **Addendum (implemented 2026-06-22): ACTIVE does not relocate.** The Goal above assumed
> `ACTIVE` moves to `.vine.local/ACTIVE` (per the original worktree ADR, then the git dir). During
> implementation we kept it at `.vine/ACTIVE` (gitignored) — see the Phase 2 amendment note above and
> the ADR's Amendment section. Consequences for this slice: **the hook scripts are NOT touched**
> (`journal-check.sh`/`run-tests.sh` already read `.vine/ACTIVE`), and navigate/pause/evolve's `ACTIVE`
> read/write/delete lines are unchanged. The slice's *real* work was (a) relocating `PAUSE.md` to the
> feature's mirrored personal path `.vine.local/projects/<d>/<f>/PAUSE.md` across pause/resume/inquire/
> navigate/evolve (+ init's archive-sweep stray-PAUSE delete), and (b) amending STATE.md's two-roots
> contract for the shared-root git-anchored resolution while clarifying `ACTIVE` stays at `.vine/ACTIVE`.
> AC4 is met by the unchanged-but-now-documented `.vine/ACTIVE` machinery + the contract; AC5 by the
> PAUSE relocation. **Slice 9 must add a `.vine/ACTIVE` line to the flipped `.gitignore`.**

### Slice 6: Per-path commit test
**Goal**: Replace the `git check-ignore -q .vine/projects` root test (`verify.md:331`,
`inquire.md:314`, and the navigate/evolve commit logic) with a check against the specific feature
directory, so shared projects commit and local ones skip.
**Depends on**: Slice 1.
**Files likely touched**: `commands/vine/{verify,inquire,navigate,evolve}.md`.
**Acceptance criteria**: AC7.
**Complexity signal**: Low.

## Phase 3: Visibility, the Flip & Docs (Slices 7-10) ⬜
Summary: Add the user-facing shared/local choice, perform the `.gitignore` inversion and migrate
this repo, and update all documentation. The flip lands last, after everything reads the new
locations.
Session boundary: Feature complete and ready for evolve. Ships as PR 3.

### Slice 7: verify shared-vs-local prompt
**Goal**: At project creation, verify defaults to shared (`.vine/projects/`) and offers a one-tap
"keep local" option routing to `.vine.local/projects/`. Use AskUserQuestion per the Interaction
Constraints.
**Depends on**: Slices 1, 6.
**Files likely touched**: `commands/vine/verify.md`.
**Acceptance criteria**: AC8 (verify half).
**Complexity signal**: Low.

### Slice 8: evolve local→shared promotion
**Goal**: At wrap-up, evolve detects a local project and offers to promote it to shared (move the
directory tree from `.vine.local/projects/` to `.vine/projects/`), then commits as usual.
**Depends on**: Slices 4, 6.
**Files likely touched**: `commands/vine/evolve.md`.
**Acceptance criteria**: AC8 (evolve half).
**Complexity signal**: Low-Medium — directory move + commit interaction.

### Slice 9: The `.gitignore` flip + init scaffold + Upgrade Mode + repo migration
**Goal**: Replace the root `.gitignore` deny-allowlist with `.vine.local/` (single rule). Update
init Step 6 (gitignore template) and Step 8 Upgrade Mode to offer existing repos an opt-in
migration (relocate personal files, flip `.gitignore`) where declining is a no-op. Migrate THIS
repo as the worked example (relocate ACTIVE wiring; flip `.gitignore`); verify with
`git check-ignore` + `git status` that no committed artifact changes tracking unexpectedly.
**Depends on**: Slices 2, 3, 4, 5, 6 (everything must read the new locations before the flip).
**Files likely touched**: `.gitignore`, `commands/vine/init.md` (Steps 6, 8).
**Acceptance criteria**: AC1, AC9, AC10.
**Complexity signal**: High — the riskiest change; isolated to its own PR by design.

### Slice 10: Documentation sweep
**Goal**: README "Piloting" → solo→team graduation path + repo-level team-overlay recommendation;
CLAUDE.md tracked/gitignored bullets; init's `.vine/README.md` scaffold table + the forward-looking
#52 block (`init.md:349-358`) → reflect the now-real `.vine.local/`. Run the State Artifact
Addition Checklist for the new directory convention. `/trellis` green.
**Depends on**: Slice 9.
**Files likely touched**: `README.md`, `CLAUDE.md`, `commands/vine/init.md`, `references/STATE.md`.
**Acceptance criteria**: AC11, AC12.
**Complexity signal**: Low-Medium.

### Tech Debt Integration

- **Brittle root `.gitignore` (deny-then-allowlist)** — **Address now** (Slice 9). The inversion
  is the fix; resolves #108. This is the central reason #108 was gated on `.vine.local/`.
- **README "Piloting" thin/stale** — **Address now** (Slice 10), as #52 explicitly calls for the
  solo→team graduation path.
- **Prose-only project discovery restated at 7+ sites** — **Address during** (Slices 1 + 4).
  Rather than worsen the duplication by adding a second root to every site, state the two-root
  Filtering Convention once and reference it (referential-homes record). Conscious, bounded
  refactor folded into work already touching those sites.
- **New debt accepted: none.** The inversion removes per-file gitignore rules rather than adding
  any.

### Backlog Updates

- **#108 (track-by-default gitignore inversion)** — closed by Slice 9; the flip the record gated
  on `.vine.local/` is performed here.
- **#57 (plugin distribution)** — unblocked: this cycle finalizes the overlay-composition model
  #57 builds on. The team-overlay *recommendation* (Slice 3 / Slice 10) is the explicit seam where
  #57's plugin distribution attaches. No distribution mechanism ships here.
- **Dropped from #52 (over-engineering):** prescribed `context/teams/<name>.md` format, a
  `vine:team` command, and a cross-team precedence engine. Recorded as deliberately out-of-scope —
  team structure is repo/team-owned. If a future need for VINE-level multi-team composition
  emerges, it earns its own cycle.

### Dependencies & Risks

- **The `.gitignore` flip is the highest-risk change.** It alters what the live repo tracks.
  Mitigation: it lands last (Slice 9), after every loader/discovery/session-state path reads the
  new locations; verify with `git check-ignore` over both roots and `git status` before/after.
- **Hook-script lockstep.** `journal-check.sh` and `run-tests.sh` hardcode `.vine/ACTIVE`. If
  navigate's writer moves to `.vine.local/ACTIVE` without updating them, the active-session hook
  breaks mid-session. Slice 5 moves writer and readers together.
- **Backward-compat (#58 pattern).** Existing solo repos may hold `.vine/context/shared.local.md`
  and `.vine/PROFILE.md`. Upgrade Mode must relocate them on opt-in; declining must change nothing.
  (This repo currently has neither file, lowering migration risk for the worked example.)
- **create-vine packaging.** The npm package ships init + commands but not the contributor scripts.
  The `.gitignore` template change ships; confirm `create-vine` scaffolds the new single-line
  ignore for fresh installs.
- **#57 boundary.** This cycle must finalize the composition model without pre-empting #57's
  distribution design — ship the mechanism and the recommendation, not propagation.
