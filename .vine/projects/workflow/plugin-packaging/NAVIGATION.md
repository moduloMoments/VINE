# Navigation Journal: Claude Code Plugin Packaging

## Feature: .vine/projects/workflow/plugin-packaging
## Branch: feature/plugin-packaging
## Started: 2026-06-23

---

## Phase 1: Scaffold + Invocation Proof

### Slice 1: Plugin manifest, marketplace, and invocation spike — Complete
**Started**: 2026-06-23 00:13
**Commit**: 0d53055
**Gear**: walk-me-through
**Approach taken**: Stood up `.claude-plugin/plugin.json` (name `vine`, version `0.4.0`) and
`.claude-plugin/marketplace.json` (marketplace name `moduloMoments`, one plugin entry `vine`,
`source: "./"`). Converted `commands/vine/status.md` → `skills/status/SKILL.md` verbatim body,
revised frontmatter. Validated manifests with `claude plugin validate .` (pass), installed at
**local scope** (`claude plugin marketplace add ./ --scope local` + `claude plugin install
vine@moduloMoments --scope local`), and confirmed the installed snapshot carries the skill + all 4
agents and resolves version 0.4.0 from plugin.json.

Before writing, researched the exact plugin/skill schema two ways: (1) claude-code-guide agent
against current docs, (2) the installed GSD framework as a real-world commands→skills reference.
GSD inspection corrected a guide-agent claim (see Learnings) and shaped the frontmatter decision.

**Deviations from spec**:
  - SPEC Slice 1 said map frontmatter `name/description/argument-hint/allowed-tools`. We **omit
    `name`** instead — for a plugin skill at `skills/status/`, the `/vine:` namespace derives from
    plugin name + dir name, and an explicit `name: vine:status` risks double-namespacing. Kept
    `argument-hint` + `allowed-tools` (GSD evidence shows both are tolerated), added the spec'd
    `disable-model-invocation: true`. SPEC.md annotated.
  - SPEC said marketplace `source = github tracking the default branch, no ref`. For a plugin in
    the **same repo** as the marketplace, the correct schema is the relative `source: "./"` (a
    github-source object is for a plugin in a *different* repo). Same intent achieved: a user who
    runs `claude plugin marketplace add moduloMoments/VINE` clones the default branch (`main`) and
    resolves `"./"` within it — zero ref/sha management, no `version` in the entry (plugin.json
    wins). SPEC.md annotated.
**Validation**: pass — manifests pass `claude plugin validate .`; local install succeeds and
version 0.4.0 resolves; skill + 4 agents present in snapshot. **Colon-form gate confirmed by the
engineer** in an authenticated session: `/vine:status` resolves in COLON form (the worktree showed
two identical `vine:status` entries — the legacy command symlink + the new plugin skill — proving
the plugin's skill is colon, not hyphen; a hyphen failure would have read `vine-status`). The
duplicate is the documented "coexistence duplicates, doesn't collide" and clears in Slice 5 when the
command tree + symlink are removed. No-auto-fire holds (skill only appeared on explicit invocation;
`disable-model-invocation: true` set).
**Decisions made during implementation**:
  - Keep `argument-hint` + `allowed-tools` in SKILL.md; omit `name`: rationale above (decided by: engineer) [confidence: high]
  - Marketplace name `moduloMoments`, plugin name `vine` → install `vine@moduloMoments`: publisher-as-marketplace convention; plugin name locked to `vine` for the namespace (decided by: claude) [confidence: medium]
  - Verify via local-scope install (not global): isolates to this worktree's gitignored settings.local.json, reversible (decided by: claude) [confidence: high]
  - **Conversion recipe = verbatim body, frontmatter-only changes** (sets Slice 2 pattern): grounded in the canonical skill-creator guide — for `disable-model-invocation` skills the description-triggering pillar is moot, and VINE already does the progressive-disclosure pillar (commands point to STATE.md / shared.md). `<objective>` is GSD house style (all 64 of its `<objective>` skills auto-invoke; 0 disable it), not a canonical requirement. Restructuring would be cosmetic and would violate AC-1 "behavior identical" (decided by: engineer) [confidence: high]
**Acceptance criteria**:
  - [x] AC1 invocation colon form `/vine:status` — confirmed by engineer (two identical `vine:status` entries, not `vine-status`)
  - [x] AC2 no auto-fire — `disable-model-invocation: true` set; skill only ran on explicit invocation
  - [x] AC3 argument preserved — `$ARGUMENTS` carried over (frontmatter `argument-hint` retained)
  - [x] AC4 4 agents load via plugin — present in installed snapshot
**Engineer feedback incorporated**: Chose to keep both frontmatter fields after I surfaced GSD
evidence that disproved the "skills ignore allowed-tools" premise.
**Learnings**:
  - Engineer → Claude: Asked me to check how GSD handled the same commands→skills migration —
    GSD is the on-disk reference that corrected the docs-agent claim.
  - Claude → Engineer: (1) The claude-code-guide agent's "skills don't honor `allowed-tools`" was
    empirically false — 66/68 installed GSD skills carry it. Agent-diagnosis-unverified discipline
    paid off. (2) GSD installs as flat prefixed skills (`/gsd-help`, hyphen) — the colon form is a
    *plugin-namespace* property, not a `name`-field property; copying GSD's `name:` habit is the one
    thing that could break VINE's colon form. (3) A `directory`-source install is a snapshot copy
    into `~/.claude/plugins/cache/.../0.4.0/`; the dev loop is edit → `claude plugin marketplace
    update moduloMoments` (or `/reload-plugins`) to pick up changes.

### Discovered Items (not in scope — for evolve/triage)
  - **Whole-repo plugin payload**: `source: "./"` ships the *entire repo* in the plugin cache
    (commands/, .vine/, README, package.json, ROADMAP, …). Slice 5 removes commands//package.json/bin,
    but `.vine/`, `references/`, agents/, docs still ship. Consider a plugin file-allowlist /
    `.claudeignore` to slim the user-facing payload. Candidate backlog item.
  - **Automated invocation testing is blocked by auth**: nested `claude -p --plugin-dir … "/vine:…"`
    returns 401 (no inherited session credentials), so the colon-form gate can't be CI-automated this
    way. Relevant if a future cycle wants automated plugin smoke tests.
  - **Oversized skill bodies** (`init` ~38KB, `evolve` ~32KB, `navigate` ~30KB) exceed the skill-creator
    <500-line "ideal." Not a conversion blocker (kept verbatim per recipe decision), but a candidate
    trim — overlaps the existing optimize-scope per-phase context-trim backlog item. Route there, not
    into this packaging cycle.

---

## Phase 2: Convert the Product to Skills

### Slice 2: Convert the remaining 10 commands to skills — Complete
**Started**: 2026-06-23 06:05
**Commit**: 508ae18
**Gear**: free-climb
**Approach taken**: Applied the Slice 1 recipe to all 10 remaining commands (init, verify, inquire,
navigate, evolve, pair, pause, resume, help, optimize) → `skills/<name>/SKILL.md`. Per-file frontmatter
transform: drop `name:`, insert `disable-model-invocation: true` after `argument-hint` (matching
`status`'s field order), keep `description`/`argument-hint`/`allowed-tools` verbatim; body copied
byte-for-byte. Done with a deterministic awk frontmatter-rewrite rather than hand-copy — precisely
because AC-1 demands behavior-identical bodies and several are 30KB+, so transcription drift was the
only real risk and a script removes it.
**Deviations from spec**: None — recipe applied as designed; the schema deviations (drop `name`, add
the flag) were already recorded in Slice 1's SPEC addendum.
**Validation**: pass — (1) all 10 bodies diff byte-identical to their source commands
(697/373/342/574/640/151/104/212/65/475 lines); (2) frontmatter check across all 10 — `name:` absent,
exactly one `disable-model-invocation: true`, `argument-hint` preserved; (3) `claude plugin validate .`
passes; (4) local-scope reinstall refreshes the `0.4.0` snapshot, which now carries all 11 skills + 4
agents with the converted frontmatter intact.
**Decisions made during implementation**:
  - Deterministic awk conversion + body-diff proof instead of file-by-file hand edit: byte-identical bodies are an AC-1 correctness requirement, not a stylistic preference (decided by: engineer) [confidence: high]
  - Insert `disable-model-invocation` after `argument-hint` (status's field order) for consistency across all 11 skills (decided by: claude) [confidence: high]
**Acceptance criteria**:
  - [x] AC1 colon form `/vine:<name>` — structurally identical to `status` (plugin `vine` + skill dir name); the recipe was empirically proven colon in Slice 1; all 11 skills present in the installed snapshot. Final cross-skill colon re-confirm is the human-only gate (nested `claude -p` 401s — Slice 1 discovered item).
  - [x] AC2 no auto-fire — `disable-model-invocation: true` on all 10 (verified count)
  - [x] AC3 arguments preserved — `argument-hint` retained; `$ARGUMENTS` carried in the verbatim bodies
**Engineer feedback incorporated**: Chose free-climb for the mechanical 10x repeat, with the body-diff
proof standing in as the review surface.
**Learnings**:
  - Engineer → Claude: None new — Slice 1's recipe carried over directly.
  - Claude → Engineer: A local-scope marketplace (Slice 1's `--scope local`) is invisible to user-scope
    `claude plugin marketplace update <name>` ("marketplace not found"); the dev-loop refresh from a
    worktree is re-`marketplace add ./ --scope local` + reinstall, which re-syncs the directory-source
    snapshot. Refines the Slice 1 dev-loop note. **Update**: a *same-version* reinstall is a no-op
    ("already installed") and does NOT re-copy the snapshot — a forced refresh needs `uninstall` +
    `install`.

### Slice 3: Ship journal-check as a plugin hook (+ payload-slimming restructure) — Complete
**Started**: 2026-06-23 06:10
**Commit**: c679792 + 8d87cb3 (8d87cb3 records the marketplace `source` repoint + settings.json +
symlink, which a failing-pathspec `git add` silently dropped from c679792; working tree was always correct)
**Gear**: free-climb
**Approach taken**: Two parts. (1) **Journal-check as a plugin hook** — moved `journal-check.sh` out of
`.vine/scripts/` into the plugin's `hooks/`, wired via `hooks/hooks.json` (PreToolUse/Bash →
`sh "${CLAUDE_PLUGIN_ROOT}/hooks/journal-check.sh"`). Script logic unchanged (it keys off
`CLAUDE_PROJECT_DIR`, the user's project). Dropped journal-check from the contributor `.claude/settings.json`
(the plugin provides it now); `trellis-gate.sh` + `main-guard.sh` stay there, unshipped. (2) **Payload-slimming
restructure** (engineer pulled this into the slice) — research confirmed Claude Code has NO file-level payload
exclusion (no `.claudeignore`, no `files`/`exclude` field; verified against official docs); the only control is
which directory `source` points at. So moved the entire product into `plugins/vine/`
(`.claude-plugin/plugin.json`, `skills/`, `agents/`, `hooks/`) and set marketplace `source: "./plugins/vine"`.
This both adopts the documented `plugins/<name>/` convention and scopes the payload to product-only.
**Deviations from spec**:
  - **Plugin moved from repo root to `plugins/vine/`** (SPEC Slice 1 / AC11 assumed product at root, `source: "./"`).
    Forced by the payload-slimming decision + the no-file-exclusion finding; also lands us on the documented
    convention. SPEC annotated (Slice 3 addendum + AC11).
  - **`hooks/journal-check.sh` is the single home** (SPEC said "moved/copied from .vine/scripts/") — chose move,
    no drift, and dropped its `.claude/settings.json` entry. SPEC Slice 3 annotated.
  - **`.claude/agents` symlink repointed** to `../plugins/vine/agents` so contributor agent-loading survives
    the move; final symlink disposition belongs to Slice 5 (annotated there).
**Validation**: pass — `claude plugin validate .` passes; a forced reinstall yields a snapshot containing ONLY
`.claude-plugin/ + skills(11) + agents(4) + hooks(2)` — `.vine/`, `.claude/`, `commands/`, `bin/`, `docs/`,
`references/`, `package.json`, and `trellis-gate.sh`/`main-guard.sh` are all absent. journal-check resolves at
`${CLAUDE_PLUGIN_ROOT}/hooks/journal-check.sh` and fires correctly (stale → exit 2 BLOCK, current → exit 0
ALLOW, non-commit → 0).
**Decisions made during implementation**:
  - Move plugin into `plugins/vine/` for payload control (decided by: engineer, after research showed no file-level exclusion exists) [confidence: high]
  - Adopt the documented `plugins/<name>/` layout rather than a generic `plugin/` (decided by: claude, ratified by engineer's convention question) [confidence: high]
  - Repoint `.claude/agents` rather than delete it now — non-breaking; Slice 5 finalizes (decided by: claude) [confidence: medium]
**Acceptance criteria**:
  - [x] AC5 hook native — journal-check fires via `hooks/hooks.json` + `${CLAUDE_PLUGIN_ROOT}`; tested stale/current/non-commit against the installed snapshot. `trellis-gate.sh`/`main-guard.sh` now absent from the payload entirely (met in letter, not merely intent).
**Engineer feedback incorporated**: Engineer pulled payload-slimming into this slice, then chose the subdir
restructure once research showed it was the only viable mechanism, and asked whether we follow the GitHub
convention — confirmed the restructure adopts the documented `plugins/<name>/` layout.
**Learnings**:
  - Engineer → Claude: Pushed for *true* payload slimming (not accept-by-intent) and for convention alignment — both converged on the same subdir restructure.
  - Claude → Engineer: (1) Claude Code copies the `source` directory wholesale (minus `.git`) — NO `.claudeignore`/`files`/`exclude` exists; payload control is purely "scope the source dir." (2) A local *directory* source copies gitignored working files (`.vine/ACTIVE`, `settings.local.json`) into the cache, but a *github* source (production) clones — so only committed files ship; the personal-state leak is local-dev-only. (3) The `plugins/<name>/` layout is both the documented convention and the slimming mechanism — one move.

### Discovered Items — Slice 3 (for later slices / evolve)
  - **Slice 4 retarget**: `/trellis` + `trellis-gate.sh` must validate/watch `plugins/vine/skills/<name>/SKILL.md`
    (not root `skills/`). SPEC Slice 4 annotated.
  - **Slice 5 addition**: the `.claude/agents` symlink (repointed this slice) joins `.claude/commands/vine` in
    the symlink-cleanup list — agents now arrive via the plugin. SPEC Slice 5 annotated.
  - **Slice 8 (docs)**: skills reference `references/STATE.md` + `.vine/context/shared.md`, which are now outside
    the plugin payload (`plugins/vine/` only). For plugin users these were already cwd-relative pointers (a
    pre-existing Reference Legibility concern); the restructure just makes "not shipped" explicit. Docs should
    address how skills cite repo-internal contracts for plugin users. Routed to Slice 8.
  - **Supersedes the Slice-1 `.claudeignore` backlog note**: payload slimming is NOT achievable via an ignore
    file (none supported); the subdir restructure done here is the mechanism, and it resolves the Slice-1
    "whole-repo payload" item for the product payload.
  - **init Native Hook Scaffold is now obsolete for plugin users** (plugin ships the hook default-on) → folded
    into Slice 6 per engineer decision; SPEC Slice 6 annotated.

---

## Phase 3: Remove npx + Rewire Tooling

### Slice 4: Rewire /trellis + trellis-gate to the skills layout — Complete
**Started**: 2026-06-23 06:40
**Commit**: e5252db
**Gear**: free-climb
**Approach taken**: Rewired the three trellis surfaces in lockstep to validate
`plugins/vine/skills/<name>/SKILL.md` instead of `commands/vine/*.md`: (1) `.vine/scripts/trellis-check.sh`
(the mechanical engine that writes the gate stamp), (2) `.claude/commands/trellis.md` (the doc), (3)
`.vine/scripts/trellis-gate.sh` (the commit gate). Key changes: discovery glob → `plugins/vine/skills/*/SKILL.md`;
"stem" now = skill **directory** name; Check 1's required-field set drops `name`, adds `disable-model-invocation`;
**Check 2 repurposed** from "Name Matches Filename" (meaningless without a `name` field) to "No Auto-Fire —
`disable-model-invocation: true`" (keeps the 12-check numbering stable AND adds real AC2 enforcement the linter
lacked); Check 10 anchor paths → `plugins/vine/agents/…` + `plugins/vine/skills/{navigate,evolve}/SKILL.md`;
gate now watches `plugins/vine/skills/`.
**Deviations from spec**: Check 2's repurpose (vs delete-and-renumber) is the one design call beyond the literal
goal — chosen to avoid the renumbering ripple trellis itself guards against, and to convert AC2 from
convention to enforced check. (Engineer ratified.) No SPEC annotation needed — it's within Slice 4's stated
"validate skills frontmatter" scope.
**Validation**: pass — rewired `trellis-check.sh` passes **11/11 skills**, all **8 cross-reference anchors
resolve** (now at `plugins/vine/` paths), personal-root guard intact, exit 0, green stamp written (AC8 first
half). A deliberately-malformed skill (extra `name`, missing `disable-model-invocation`) is **flagged** —
Frontmatter ❌ + NoFire ❌, exit 1 (AC8 second half). Zero residual `commands/vine` references across the three
files. Pre-existing non-blocking legacy-`.vine/hooks` warnings on init (its body wraps the allowlisted sentence
across two lines — byte-identical in the source command, not introduced here).
**Decisions made during implementation**:
  - Repurpose Check 2 → `disable-model-invocation: true` rather than delete + renumber (decided by: engineer) [confidence: high]
  - Rewire engine first, then match the doc to it (the engine is the gate's source of truth; the doc must mirror it) (decided by: claude) [confidence: high]
**Acceptance criteria**:
  - [x] AC8 — `/trellis` validates the converted skills (11/11 pass) and flags a malformed SKILL.md; the gate now watches `plugins/vine/skills/` and blocks a touch without a green stamp (gate logic verified by code inspection; the live gate reloads next session).
**Engineer feedback incorporated**: Chose free-climb with the trellis-run proof (pass-on-11 + fail-on-malformed) as the review surface; ratified the Check 2 repurpose.
**Learnings**:
  - Engineer → Claude: Preferred repurposing Check 2 over renumbering — keeping cross-reference numbering stable is itself the kind of drift trellis exists to catch.
  - Claude → Claude: The engine (`trellis-check.sh`) and the doc (`trellis.md`) carry duplicate contracts (the anchor list, the check set) and MUST stay byte-consistent — each lists the other as the sync partner. Rewiring one without the other is the exact divergence Step 8 warns about.

### Slice 5: Remove the npx distribution + rework the release flow (+ CI-fix) — Complete
**Started**: 2026-06-23 07:10
**Commit**: 04bbb2f
**Gear**: free-climb
**Approach taken**: Three parts. (1) **Delete the npx path** — `git rm` of `bin/cli.js`,
`commands/vine/` (11 files), the `.claude/commands/vine/` + `.claude/agents` symlinks, and
`package.json` entirely. `develop` already existed locally (tracks `origin/develop`), so the branch
model is in place; the GitHub default-base / branch-protection toggle is repo-admin (flagged to
engineer). (2) **Rework `publish.yml`** — renamed to "Release plugin", node-free version parse from
`plugins/vine/.claude-plugin/plugin.json` (grep+sed), dropped `npm publish` + `setup-node` + the node
smoke-test, replaced the smoke-test with `sh .vine/scripts/trellis-check.sh`, kept tag-exists-check +
CHANGELOG-extract + GitHub-release, removed the `id-token` permission. (3) **CI-fix folded into this
slice** — `ci.yml` runs `run-tests.sh`, which was red (16/27 failing) because Slice 3 *moved*
`journal-check.sh` into `plugins/vine/hooks/` and Slice 4 rewired the trellis scripts to
`plugins/vine/skills/`, but the test matrix still used the old paths/fixtures. Rewrote `run-tests.sh`:
journal-check `J` path → `plugins/vine/hooks/`; trellis-gate fixtures → `plugins/vine/skills/test/SKILL.md`;
trellis-check `mkcmd`/`mkanchors` → skills layout + new frontmatter (drop `name`, add
`disable-model-invocation`); the old "name mismatch" case repurposed to the **no-auto-fire** case
(matching Slice 4's Check 2 repurpose); warning greps → `<stem>/SKILL.md` paths. Also cleaned the stale
`create-vine` header comments in the four surviving `.vine/scripts/*.sh`.
**Deviations from spec**:
  - **`trellis.yml` NOT created** (SPEC added-scope asked for it). `ci.yml` already runs
    `trellis-check.sh` on every PR alongside `run-tests.sh`, so the dedicated-gate intent and the
    "malformed SKILL.md fails the PR" AC are already met; a separate workflow would double-run
    trellis-check. Engineer decision. SPEC Slice 5 annotated.
  - **CI-fix (run-tests.sh rewrite) pulled into Slice 5** — not in the original goal, but `ci.yml`
    must be green for PR 3 and the failures are fallout from Slices 3–4. Engineer chose to fold it in.
    SPEC Slice 5 annotated.
**Validation**: pass — `run-tests.sh` 27/27 (was 11/27); live `trellis-check.sh` 11/11 skills + 8
anchors + #132 guard; `publish.yml` version parse verified (`0.4.0`); zero dangling
`bin/cli`/`commands/vine`/`package.json`/`npm publish`/`create-vine` refs across `.github/` +
`.vine/scripts/`; root `bin/`, `commands/`, `package.json` gone; contributor `.claude/commands/` tools
(pr/pr-review/trellis/triage) intact.
**Decisions made during implementation**:
  - Skip `trellis.yml`; `ci.yml` already gates trellis-check on PRs (decided by: engineer) [confidence: high]
  - Fold the `run-tests.sh` CI-fix into Slice 5 rather than a separate pair/PR (decided by: engineer) [confidence: high]
  - Node-free version parse (grep+sed) in `publish.yml` since `setup-node` is removed (decided by: claude) [confidence: high]
  - Clean stale `create-vine` comments in surviving scripts to satisfy AC7's grep-clean intent (decided by: claude) [confidence: medium]
**Acceptance criteria**:
  - [x] AC7 npx removed cleanly — `bin/cli.js`, `commands/vine/`, the `.claude/commands/vine/` symlink, and `package.json` gone; `publish.yml` no longer publishes to npm; no `create-vine` artifacts remain
  - [x] AC11 versioning coherent — `plugin.json` is the sole version source (`0.4.0`); `package.json` removed (no competing field); marketplace `source` tracks `./plugins/vine` with no `ref`; `develop`/`main` branch model in place
  - [x] AC6/AC8 (partial) — contributor tooling (trellis scripts) survives the deletions and validates the live skills; `ci.yml` (run-tests + trellis-check) is green for PR 3. Full marketplace-install / dogfooding re-confirm is the human-only gate (nested `claude -p` 401s).
**Engineer feedback incorporated**: Chose free-climb; folded the CI-fix into the slice; chose to skip
the redundant `trellis.yml` once I surfaced that `ci.yml` already covers it.
**Learnings**:
  - Engineer → Claude: When a specced new artifact duplicates existing coverage, drop it — the
    enforcement matters, not the file count.
  - Claude → Engineer: The hook test matrix (`run-tests.sh`, run by `ci.yml`) is a hidden coupling to
    the layout — moving `journal-check.sh` (Slice 3) and rewiring the trellis scripts (Slice 4) both
    silently broke it because no PR had exercised CI yet. A layout move isn't done until its tests move
    with it; checking CI status at each restructure would have caught this two slices earlier.

### Slice 6: init legacy-install migration (+ obsolete hook-scaffold revision) — Complete
**Started**: 2026-06-23 07:40
**Commit**: <pending>
**Gear**: free-climb
**Approach taken**: Edited the live `plugins/vine/skills/init/SKILL.md`. Two coupled changes: (1)
**Replaced the obsolete "Native Hook Scaffold" section** — the journal-before-commit hook now ships
*with the plugin* (`hooks/hooks.json`, default-on, Slice 3), so init's offer to scaffold it into a
repo's `.claude/settings.json` (and its `npx create-vine` / `.vine/scripts/journal-check.sh`
references) is dead. The section is now "### Legacy npx-Install Cleanup" plus a blockquote noting the
hook is plugin-provided (no scaffold step) and that validation/lint stays out of scope. (2) **Added the
legacy npx-install cleanup** — init detects a legacy `.claude/commands/vine/` (old file-copy install,
or a symlink to one), offers a one-time removal (`git rm -r` tracked / `rm -rf` untracked; remove the
link not the target if symlinked), no-ops on decline, and is gated on the directory existing (#58
offer-migration pattern, shaped to mirror the existing "Legacy Directory Migration" offer). Three
contradiction-fixes the revision forced: item 7 in "What This Does" (hook-scaffold → legacy cleanup),
the Output block's `.claude/settings.json hooks` line, and the `.vine/scripts/ | …journal-check.sh`
structure-table row (removed — journal-check no longer lives in a user's `.vine/scripts/`).
**Deviations from spec**: None beyond the addendum's own added scope (the hook-scaffold revision),
which is recorded in SPEC Slice 6. The broader internal-docs sweep (STATE.md's init-hook description,
the rest of init's structure prose) is left to Slice 8 as specced.
**Validation**: pass — `trellis-check.sh` 11/11 skills (init row ✅ Front/NoFire/H1/Tools/AskUsr,
overlays/profile/order `skip` as init is exempt), 8 anchors resolve, #132 guard; green stamp written
(satisfies the trellis-gate for this skill-touching commit). The only residual `npx create-vine`
string is intentional historical context in the new section; the two init `.vine/hooks` warnings are
pre-existing (noted in Slice 4), not introduced here.
**Decisions made during implementation**:
  - Replace the hook-scaffold section in place with the legacy-cleanup section (rather than delete it and add the cleanup elsewhere) — keeps the obsolete content and its replacement in one edit, no orphaned references (decided by: claude) [confidence: high]
  - Remove the `.vine/scripts/` structure-table row — init no longer scaffolds journal-check into a user's `.vine/scripts/`; leaving it would contradict the new plugin-provided note (decided by: claude) [confidence: high]
**Acceptance criteria**:
  - [x] AC7 (init half) — with a legacy `.claude/commands/vine/` present, init offers cleanup and removes it on accept; no-ops on decline; with no legacy dir the offer is suppressed so init behaves exactly as before
  - [x] Obsolete hook-scaffold revised — the Native Hook Scaffold offer is gone; the hook is documented as plugin-provided (addendum scope)
**Engineer feedback incorporated**: Chose free-climb with the trellis-run proof as the review surface.
**Learnings**:
  - Engineer → Claude: None new this slice.
  - Claude → Engineer: Removing a capability from a skill (the hook scaffold) is a multi-site edit even
    in a single file — the feature list, the section, the Output block, and a structure table all
    referenced it. Grepping the file for the removed concept before committing is what keeps the skill
    internally consistent.

### Remaining Work
- **Incomplete slices**: Phase 3 (Slices 4–6) complete. Phase 4 (Slices 7–9: docs + cycle knowledge) not started.
- **Blockers encountered**: None.
- **Handoff context**: Phase-group boundary reached — Phase 3 ships as PR 3. GitHub repo-admin still
  owed: set `develop` as the default PR base + branch protection (branch exists, tracks origin/develop).
  Routed-to-Slice-8 items: STATE.md's description of init's hook scaffold (now plugin-provided);
  init's broader `.vine/` structure prose; how skills cite repo-internal contracts (`references/STATE.md`,
  `.vine/context/shared.md`) for plugin users now that those files are outside the plugin payload
  (Slice 3 discovered item). Phase 4 also carries the ADRs (Slice 9), including the (d) plugin-layout /
  payload-control ADR from the Slice 3 addendum.
