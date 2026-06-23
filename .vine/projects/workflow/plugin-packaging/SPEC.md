# Feature Spec: Claude Code Plugin Packaging (skills-only, drop npx)
## Date: 2026-06-22
## Built on: CONTEXT.md (2026-06-22)
## Decisions made by: Rob

### Problem Statement

VINE ships today as 11 `commands/vine/*.md` files installed by the `create-vine` npx tool (file-copy
into `.claude/commands/vine/`). Cycle 5 of v0.4.0 ([#57](https://github.com/moduloMoments/VINE/issues/57))
repackages VINE as a **native Claude Code plugin** distributed via a self-hosted marketplace.

The verify phase confirmed the platform schema and surfaced one load-bearing fork (commands vs.
skills). Resolving it reshaped the cycle from "package the existing commands" into a clean migration:

- **Skills become the sole product.** Docs steer new plugins to `skills/`, and a plugin named `vine`
  with `skills/<name>/SKILL.md` resolves to the exact colon form `/vine:<name>` — so invocation is
  unchanged. (Flat `commands/` in a plugin can't be made to namespace from a non-plugin install, and
  nested `commands/vine/*.md` is undocumented.)
- **npx is retired.** Rather than carry two distribution surfaces forever, the npx path is dropped
  this cycle. This **revises #57's stated hard gate** from "keep npx working" to "migrate npx users to
  the plugin" — a deliberate roadmap call given the early, small installed base.
- **Overlay distribution is documentation, not a mechanism.** Overlay *content* is 100%
  consumer-owned. Plugins have no native slot for delivering an arbitrary context file, and a company
  wanting cross-repo conventions can fork the plugin's skills/agents (which distribute natively),
  leaving `.vine/context/shared.md` repo-local and consumer-authored. VINE ships no overlay-delivery
  feature — only docs and a decision record. This is the "harder half" of #57, resolved by scoping it
  out.

### Approach

**End state:** one product representation (`skills/<name>/SKILL.md` at repo root) distributed as a
native plugin (`.claude-plugin/plugin.json` + self-hosted `.claude-plugin/marketplace.json`), with
agents and the journal-check hook riding in the same plugin. The npx installer, its symlink-based
dogfooding, and the npm publish flow are removed.

**Key decisions and rationale:**

- **Skills, not commands** — the only layout that guarantees `/vine:<name>` from the docs (plugin name
  `vine` + skill dir name → `/vine:<name>`, colon form confirmed in the plugins reference). Slice 1
  validates this empirically before any mass conversion; a hyphen form is a stop-and-flag.
- **`disable-model-invocation: true` on every skill** — VINE phases are deliberate, user-driven gates.
  The model must never auto-fire `/vine:navigate`. Every converted SKILL.md carries the flag.
- **Drop npx now, no transition window** — single distribution path, no sync surface, no two-tree
  drift. Existing npx users migrate via documented cleanup (init offers to remove a legacy
  `.claude/commands/vine/` install; declining is a no-op — the #58 offer-migration pattern).
- **Hook home = plugin** — journal-check wires natively via `hooks/hooks.json` using
  `${CLAUDE_PLUGIN_ROOT}`. Contributor-only hooks (`trellis-gate.sh`, `main-guard.sh`) stay unshipped,
  wired by the repo's own `.claude/settings.json` as today.
- **Versioning & release** — with npm gone, the version strategy follows from one platform fact:
  Claude Code resolves a plugin's version as `plugin.json version` → marketplace `version` → git SHA,
  and **a set `version` gates updates** (users move only when the *string* changes; an omitted version
  floats on every commit). Because our plugin source repo *is* the contributor tree, floating would
  ship WIP to users — so we **pin**:
  - `plugin.json` `version` (SemVer) is the **single source of truth**; bump to `0.4.0`. The
    marketplace entry omits `version` (plugin.json wins silently). `package.json` is removed entirely
    (Slice 5) so no competing version field survives.
  - **SemVer policy** (no API — only command behavior): **major** = a command/skill removed/renamed or
    an invocation/artifact-contract break; **minor** = new command/skill/agent/hook or capability;
    **patch** = prose/doc/non-behavioral fixes.
  - **Users update** via `/plugin update vine` (or auto-update) — replaces `npx create-vine@latest`.
  - **Branch model: `main` = release, `develop` = integration.** `main` holds only released states, so
    the marketplace `source` tracks `main` (the default branch) with **zero ref/sha management** and
    every released version is reproducible. All development (including this cycle's remaining PRs)
    targets `develop`; cutting a release = merge `develop`→`main`, bump `plugin.json` version, tag
    `vX.Y.Z`, GitHub release. The existing main-guard hook ("don't commit directly to main") already
    fits this model.
- **Contributor dogfooding moves to local plugin install** — the old `.claude/commands/vine/` symlink
  is removed; contributors load the repo as a plugin (`claude plugin marketplace add .`). The dev loop
  (how a skill edit is picked up) is established and documented in Slice 1.

**Sequencing principle:** de-risk first (prove the namespace + recipe on one skill), convert in bulk,
*then* remove the old path — so the repo stays functional at every phase boundary.

### Acceptance Criteria

1. **Invocation unchanged.** All 11 phases invoke as `/vine:<name>` (colon form) under a plugin
   install, with behavior identical to today — empirically verified by installing the plugin locally,
   not inferred. A hyphen form (`/vine-navigate`) halts the cycle for redesign.
2. **No auto-fire.** Every `skills/<name>/SKILL.md` contains `disable-model-invocation: true`; no VINE
   phase triggers from model reasoning.
3. **Arguments preserved.** `argument-hint` and `$ARGUMENTS` (and positional forms) behave in skills
   as they did in commands (e.g. `/vine:inquire workflow/foo` passes the slug through).
4. **Agents intact.** The 4 agents (`agents/*.md`) load and auto-delegate via the plugin, unchanged.
5. **Hook native.** journal-check fires on a real navigate session loaded via the plugin, wired
   through `hooks/hooks.json` + `${CLAUDE_PLUGIN_ROOT}`; `trellis-gate.sh` / `main-guard.sh` remain
   unshipped.
6. **Marketplace install works.** `claude plugin marketplace add <repo>` then install brings the full
   product (11 skills + 4 agents + hook), documented as the install path.
7. **npx removed cleanly.** `bin/cli.js`, `commands/vine/`, and the `.claude/commands/vine/` symlink
   are gone; `package.json` no longer declares the `create-vine` bin/npm packaging; `publish.yml` no
   longer publishes to npm. Existing-user migration is documented and init offers legacy-install
   cleanup (declining changes nothing).
8. **Tooling rewired.** `/trellis` and `trellis-gate.sh` validate/watch the `skills/<name>/SKILL.md`
   layout; contributor dogfooding via local plugin install is documented and works.
9. **Docs current.** README leads with plugin install; CLAUDE.md, `shared.md`, `references/STATE.md`,
   and CHANGELOG describe the skills/plugin product; the solo→team graduation path documents overlays
   as consumer-owned with no VINE distribution mechanism.
10. **Decisions recorded.** Knowledge ADR(s) capture the drop-npx decision (revised gate), the
    overlay-is-consumer-owned decision (amending the team-layer ADR's "seam" expectation), and the
    versioning + `main`-release/`develop`-integration branch model.
11. **Versioning coherent.** `plugin.json` `version` is the sole version source (`0.4.0`); no
    `package.json` version competes; marketplace `source` tracks `main` with no `ref`; `main` holds
    only released states; the documented user-update path is `/plugin update vine`.

### Work Slices

## Phase 1: Scaffold + Invocation Proof (Slices 1) ✅
Summary: Add the plugin manifest + marketplace and prove the skill recipe and colon namespace on a
single low-risk command before converting anything else.
Session boundary: The plugin installs locally and one phase invokes as `/vine:status`; the conversion
recipe is proven and the colon-form risk is retired. Ships as PR 1.

### Slice 1: Plugin manifest, marketplace, and invocation spike
- **Goal**: Stand up `.claude-plugin/plugin.json` (name `vine`, version `0.4.0`) and
  `.claude-plugin/marketplace.json` (one entry; `source` = github tracking the default branch, **no
  `ref`** — per the branch model, `main` holds only releases; omit `version` so plugin.json wins).
  Convert one low-risk command
  (`status`) to `skills/status/SKILL.md` with `disable-model-invocation: true`, mapping frontmatter
  (`name`/`description`/`argument-hint`/`allowed-tools`) and confirming `$ARGUMENTS` carries over.

  > **Addendum (navigate, 2026-06-23):** Two schema realities differed from the above and were
  > applied during implementation:
  > - **Marketplace `source` = relative `"./"`, not a github-source object.** For a plugin living in
  >   the *same repo* as the marketplace, the documented form is the relative path `"./"`; a
  >   github-source object is for a plugin in a *different* repo. The intent is unchanged — adding
  >   the github repo tracks its default branch (`main`) with no `ref`, and the entry omits
  >   `version` so plugin.json wins. (`marketplace.json` also requires `owner` and a
  >   `metadata.description` to validate cleanly.)
  > - **Frontmatter: `name` is omitted, not mapped.** The `/vine:status` colon form derives from
  >   plugin name (`vine`) + skill dir (`status`); an explicit `name: vine:status` risks
  >   double-namespacing. `argument-hint` + `allowed-tools` are kept (empirically tolerated — 66/68
  >   installed GSD skills carry `allowed-tools`), and `disable-model-invocation: true` is added.
  Install the plugin locally (`claude plugin marketplace add .` + install) and verify end-to-end.
- **Depends on**: Nothing.
- **Files likely touched**: `.claude-plugin/plugin.json` (new), `.claude-plugin/marketplace.json`
  (new), `skills/status/SKILL.md` (new), `commands/vine/status.md` (left in place this phase).
- **Acceptance criteria**: `/vine:status` resolves in **colon** form, runs, accepts its argument, and
  does **not** auto-fire (AC 1–3). The 4 agents still load via the plugin (AC 4). **Stop-and-flag** if
  the invocation is hyphenated or any frontmatter field is incompatible. Document the contributor dev
  loop (how a skill edit is picked up: reinstall/reload).
- **Complexity signal**: Medium — mechanically small, but this is the de-risking spike the whole
  cycle rests on; the validation, not the code, is the work.

## Phase 2: Convert the Product to Skills (Slices 2–3) ✅
Summary: Apply the proven recipe to the remaining 10 commands and move the journal hook into the
plugin.
Session boundary: The full product (11 skills + 4 agents + hook) runs via the plugin. Ships as PR 2.

### Slice 2: Convert the remaining 10 commands to skills
- **Goal**: Convert init, verify, inquire, navigate, evolve, pair, pause, resume, help, optimize to
  `skills/<name>/SKILL.md`, each with `disable-model-invocation: true`, using the Slice 1 recipe.
- **Depends on**: Slice 1.
- **Files likely touched**: `skills/<name>/SKILL.md` ×10 (new); corresponding `commands/vine/*.md`
  left in place until Phase 3.
- **Acceptance criteria**: All 11 phases (the 10 here + `status`) invoke as `/vine:<name>` via the
  plugin with unchanged behavior and arguments; every SKILL.md carries the flag (AC 1–3).
- **Complexity signal**: Medium — repetitive but voluminous; each file needs frontmatter mapping and a
  spot-check that the colon namespace + args hold.

### Slice 3: Ship journal-check as a plugin hook
- **Goal**: Wire `journal-check.sh` via `hooks/hooks.json` using `${CLAUDE_PLUGIN_ROOT}` so plugin
  users get it natively. Keep contributor-only hooks unshipped.
- **Depends on**: Slice 1 (manifest exists).
- **Files likely touched**: `hooks/hooks.json` (new), `hooks/journal-check.sh` (moved/copied from
  `.vine/scripts/`), `.claude-plugin/plugin.json` if hook discovery needs a pointer.
- **Acceptance criteria**: journal-check fires on a real navigate session loaded via the plugin;
  `trellis-gate.sh` / `main-guard.sh` remain unshipped (AC 5). Note the behavior change: auto-wired is
  default-on for plugin users (today it's opt-in scaffold) — surface in docs (Slice 7).
- **Complexity signal**: Low — small JSON wiring; the risk is path resolution under
  `${CLAUDE_PLUGIN_ROOT}`.

  > **Addendum (navigate, 2026-06-23):** Two things landed beyond the original goal:
  > - **journal-check single home + settings drop.** `journal-check.sh` was *moved* (not copied) to
  >   `hooks/journal-check.sh` and its entry removed from the contributor `.claude/settings.json` (the
  >   plugin provides it now). `trellis-gate.sh` + `main-guard.sh` stay wired in `.claude/settings.json`.
  > - **Payload-slimming restructure (pulled in by engineer).** Research confirmed Claude Code has **no
  >   file-level payload exclusion** (no `.claudeignore`, no `files`/`exclude` field — verified against
  >   the official plugins/marketplaces docs); the *only* control is which directory `source` points at.
  >   So the whole product moved into **`plugins/vine/`** (`.claude-plugin/plugin.json`, `skills/`,
  >   `agents/`, `hooks/`) and marketplace `source` became **`./plugins/vine`**. This both (a) adopts the
  >   documented `plugins/<name>/` convention and (b) scopes the published payload to product-only —
  >   verified: the installed snapshot contains only `.claude-plugin/ + skills + agents + hooks`, with
  >   `.vine/`, `commands/`, `bin/`, `references/`, `package.json`, and the contributor hooks all absent.
  >   AC5 is therefore met in **letter** (those scripts are not shipped at all), not just intent. The
  >   `.claude/agents` symlink was repointed to `../plugins/vine/agents` (final disposition → Slice 5).
  >   This supersedes the Slice-1 discovered item proposing a `.claudeignore`.

## Phase 3: Remove npx + Rewire Tooling (Slices 4–6) ⬜
Summary: Retire the npx distribution and point the contributor tooling at the skills layout.
Session boundary: The old path is gone, contributor dogfooding runs on the plugin, and existing users
have a migration path. Ships as PR 3.

### Slice 4: Rewire `/trellis` and the trellis-gate to the skills layout
- **Goal**: Update `/trellis` (`.claude/commands/trellis.md`) to validate `skills/<name>/SKILL.md`
  (frontmatter, section ordering, the renamed Skill Addition Checklist) instead of `commands/vine/*.md`;
  update `.vine/scripts/trellis-gate.sh` to watch `skills/`.
- **Depends on**: Slice 2 (skills exist to validate).
- **Files likely touched**: `.claude/commands/trellis.md`, `.vine/scripts/trellis-gate.sh`.
- **Acceptance criteria**: `/trellis` passes against the converted skills and flags a deliberately
  malformed SKILL.md; the gate blocks a commit touching `skills/` without a green trellis run (AC 8).
- **Complexity signal**: Medium — trellis encodes the old layout in multiple checks; each must move.

  > **Addendum (navigate, 2026-06-23):** Retarget path changed. After Slice 3's restructure the skills
  > live at **`plugins/vine/skills/<name>/SKILL.md`** (not root `skills/`). `/trellis` and
  > `trellis-gate.sh` must validate/watch that path. **Done** — both, plus `trellis-check.sh`, rewired
  > (commit `e5252db`).

### Slice 5: Remove the npx distribution + rework the release flow
- **Goal**: Delete `bin/cli.js`, the migrated `commands/vine/` tree, the `.claude/commands/vine/`
  symlink, and **`package.json` entirely** (nothing functional needs it post-npm — the only
  references are the deleted `bin/cli.js` and prose examples). Rework `.github/workflows/publish.yml`:
  read the version from `plugin.json`, drop the `npm publish` + node smoke-test steps (replace the
  smoke test with a plugin-load / `trellis-check` validation), keep the tag-exists-check +
  CHANGELOG-extract + GitHub-release steps. Adopt the branch model: create `develop`, set it as the
  PR base for ongoing work, leave `main` as the release branch the marketplace tracks.
- **Depends on**: Slices 2–4 (skills + tooling must be live before the old path is removed).
- **Files likely touched**: `bin/cli.js` (delete), `commands/vine/` (delete), `.claude/commands/vine/`
  symlink (delete), `package.json` (delete), `.github/workflows/publish.yml`.
- **Acceptance criteria**: No `create-vine`/npm artifacts or competing version source remain; the
  release workflow tags + creates a GitHub release sourced from `plugin.json` version with no npm step;
  contributor dogfooding via local plugin install works (AC 6–8, 11).
- **Complexity signal**: Medium — deletion is easy; reworking `publish.yml` and confirming nothing
  else references the removed paths (grep for `package.json` / `create-vine` / `commands/vine`) is the
  care point.

  > **Addendum (navigate, 2026-06-23):** Symlink cleanup grew. Slice 3 repointed the `.claude/agents`
  > symlink to `../plugins/vine/agents`; it now joins `.claude/commands/vine` in the removal list (agents
  > arrive via the plugin install). Also note `agents/` and `hooks/` have already moved under
  > `plugins/vine/` — grep should cover any remaining root-`agents/`/`skills/`/`hooks/` references.
  >
  > **Added scope (engineer decision, 2026-06-23):** add a **PR-time trellis GitHub Action** —
  > `.github/workflows/trellis.yml` running `sh .vine/scripts/trellis-check.sh` on PRs into `develop`/
  > `main`. Rationale: the local `trellis-gate.sh` only protects contributors who have the hook
  > installed; a CI check is the unbypassable enforcement for community PRs (Team Context anticipates
  > them), and `trellis-check.sh` is already CI-ready (POSIX sh, deterministic stamp) and survives the
  > Slice-5 deletions (it's `.vine/scripts/` contributor tooling, not removed). Distinct from the
  > release-time `trellis-check` validation folded into `publish.yml` above: this gates *merges*, that
  > gates *publishes*. New AC: a PR carrying a malformed SKILL.md fails the action.
  >
  > **Done + deviations (navigate, 2026-06-23, commit `<pending>`):**
  > - Deletions complete: `bin/cli.js`, `commands/vine/` (11 files), the `.claude/commands/vine/` +
  >   `.claude/agents` symlinks, and `package.json` — all `git rm`'d. `develop` already existed
  >   (tracks `origin/develop`); the GitHub-side default-base / branch-protection is repo-admin.
  > - `publish.yml` reworked: node-free version parse from `plugins/vine/.claude-plugin/plugin.json`,
  >   `npm publish` + `setup-node` + node smoke-test dropped, smoke-test replaced with
  >   `sh .vine/scripts/trellis-check.sh`, tag-check + CHANGELOG-extract + GitHub-release kept;
  >   `id-token` permission removed.
  > - **CI-fix folded in (this slice owns "PR 3 CI green").** `ci.yml` runs `run-tests.sh`, which was
  >   red (16 failures): Slice 3 *moved* `journal-check.sh` to `plugins/vine/hooks/` and Slice 4
  >   rewired the trellis scripts to `plugins/vine/skills/`, but the test matrix still pointed at the
  >   old paths/fixtures. Rewrote `run-tests.sh` to the new layout (journal-check path + skills
  >   fixtures + the repurposed Check 2 → no-auto-fire case). Now 27/27 pass. Stale `create-vine`
  >   header comments in the four surviving `.vine/scripts/*.sh` also cleaned.
  > - **Deviation — `trellis.yml` NOT created.** `ci.yml` already runs `sh .vine/scripts/trellis-check.sh`
  >   on every PR (alongside `run-tests.sh`), so the dedicated-gate intent and the "malformed SKILL.md
  >   fails the PR" AC are already satisfied; a separate workflow would run trellis-check twice.
  >   (Engineer decision, 2026-06-23.)

### Slice 6: init legacy-install migration
- **Goal**: `/vine:init` detects a legacy `.claude/commands/vine/` (old npx install) and offers a
  one-time cleanup; declining changes nothing (#58 offer-migration pattern).
- **Depends on**: Slice 2 (skills are the thing being migrated to).
- **Files likely touched**: `skills/init/SKILL.md`.
- **Acceptance criteria**: With a legacy dir present, init offers cleanup and removes it on accept,
  no-ops on decline; with no legacy dir, init behaves exactly as before (AC 7).
- **Complexity signal**: Low — additive detection + an AskUserQuestion offer.

  > **Addendum (navigate, 2026-06-23):** Scope grew by one item (engineer decision). init's **"Native Hook
  > Scaffold"** section (scaffolds `journal-check.sh` into a user's `.vine/scripts/` + wires their
  > `settings.json`) is now obsolete for plugin users — the plugin ships the hook default-on (Slice 3).
  > Revise/remove that section here, in the same init pass as the legacy-install cleanup. Edit
  > `plugins/vine/skills/init/SKILL.md` (the live product); the legacy `commands/vine/init.md` is deleted
  > in Slice 5.

## Phase 4: Docs + Cycle Knowledge (Slices 7–9) ⬜
Summary: Make every doc surface describe the skills/plugin product and record the load-bearing
decisions.
Session boundary: Docs and knowledge are current; #57 is closeable. Ships as PR 4.

### Slice 7: README + CHANGELOG
- **Goal**: Lead the README with plugin install (`claude plugin marketplace add` → install) and the
  update path (`/plugin update vine`, replacing `npx create-vine@latest`); remove the npx/manual-copy
  sections; add a migration note for existing npx users; document the solo→team
  graduation path (fork the plugin's skills/agents; overlays stay repo-local and consumer-authored —
  no VINE distribution mechanism). Add the 0.4.0 CHANGELOG entry. Note journal-check's default-on
  change for plugin users.
- **Depends on**: Slices 1–6 (docs describe the shipped reality).
- **Files likely touched**: `README.md`, `CHANGELOG.md`.
- **Acceptance criteria**: README's install path is the plugin; overlay distribution is documented as
  consumer-owned; no stale npx-as-primary instructions remain (AC 9).
- **Complexity signal**: Medium — README is the user-facing source of truth; the install/migration
  narrative must read cleanly for a zero-context reader.

### Slice 8: Internal docs (CLAUDE.md, shared.md, STATE.md)
- **Goal**: Rewrite CLAUDE.md "What This Repo Is" / Repository Structure / Command Authoring
  Conventions for the skills/plugin product; rename shared.md's "Command Addition Checklist" →
  "Skill Addition Checklist" and update the Skill Workflows install step; rewrite shared.md's CI/CD
  **Release checklist** for the new flow (bump `plugin.json` version per SemVer → CHANGELOG → merge
  `develop`→`main` → tag `vX.Y.Z` → GitHub release; no npm) and record the SemVer policy + the
  `main`-release/`develop`-integration branch model + the Branch Naming convention (feature branches
  now off `develop`); update `references/STATE.md` product references and the version note
  (`plugin.json` single source).
- **Depends on**: Slices 1–6.
- **Files likely touched**: `CLAUDE.md`, `.vine/context/shared.md` (CI/CD Release checklist, Branch
  Naming, Skill Addition Checklist, Skill Workflows), `.vine/context/verify.md` (command count),
  `references/STATE.md`.
- **Acceptance criteria**: No internal doc describes the product as "11 command files in
  `commands/vine/`" or references the npx-only install; the addition checklist targets skills; the
  release checklist and branch model are documented (AC 9, 11).
- **Complexity signal**: Medium — the old layout is referenced across several contributor docs; the
  Command/State Addition checklists in shared.md exist to catch exactly this kind of multi-file drift.

### Slice 9: Knowledge ADR(s)
- **Goal**: Record (a) the plugin-only / drop-npx decision and its rationale (revised hard gate),
  (b) overlay distribution = document-only / consumer-owned, amending the team-layer ADR's "seam"
  expectation, and (c) the versioning strategy + `main`-release/`develop`-integration branch model
  (plugin.json as version gate; pin-not-float because the repo is the dev tree).

  > **Addendum (navigate, 2026-06-23):** Add a **(d)** ADR — the **plugin-layout / payload-control
  > decision**: the product lives in a `plugins/vine/` subdirectory on the documented `plugins/<name>/`
  > convention, and the marketplace `source` points there. Rationale worth capturing because it's
  > non-obvious: Claude Code has **no file-level payload exclusion** (no `.claudeignore`, no `files`/
  > `exclude` field — verified against the official docs), so a scoped `source` subdir is the *only*
  > mechanism to keep contributor/personal/ephemeral files out of the published plugin payload. This
  > emerged in Slice 3 and isn't a restatement of (a)/(c) — it's its own load-bearing structural call.
- **Depends on**: Slices 1–8 (decisions are settled by the work).
- **Files likely touched**: `.vine/knowledge/workflow/2026-06-*-*.md` (2–3 ADRs).
- **Acceptance criteria**: ADRs exist in the committed knowledge format; the team-layer "seam"
  expectation is explicitly amended rather than left dangling; the versioning/branch-model decision is
  captured (AC 10).
- **Complexity signal**: Low — durable-decision capture in the established ADR format.

### Tech Debt Integration

- **Version drift (package.json 0.3.0 vs 0.4.0 CHANGELOG)** — *Addressed now.* `plugin.json` becomes
  the single version source at `0.4.0`; `package.json` is removed entirely (Slice 5), eliminating the
  competing version field rather than just neutralizing it.
- **`commands/vine/` nesting vs. flat plugin discovery** — *Resolved by design.* The skills layout
  sidesteps it entirely; no nested-command discovery is relied on.
- **Unverified "flat commands deprecated, use skills/" claim** — *Resolved.* Verified against current
  docs in inquire: commands are supported but skills are the forward path; we migrate.
- **New debt, consciously taken on:**
  - *Dev-loop friction.* Editing a skill requires a plugin reinstall/reload vs. the old instant
    symlink edit. Accepted; the loop is documented (Slice 1).
  - *No npx transition window.* Existing npx users must migrate immediately; mitigated by README
    migration docs + init's cleanup offer (Slices 6–7).

### Dependencies & Risks

- **Risk — colon vs. hyphen invocation form.** The whole skills choice depends on `/vine:<name>`
  resolving in colon form. Docs confirm it; Slice 1 verifies empirically and **stops the cycle** if it
  fails. *Highest-leverage risk, retired first.*
- **Risk — hook path resolution.** `${CLAUDE_PLUGIN_ROOT}` must resolve journal-check correctly under
  a plugin load (Slice 3); fail-open behavior in the script limits blast radius.
- **Risk — stranded npx users.** Mitigated by migration docs + init cleanup offer; acceptable given
  the small early installed base.
- **Risk — dangling references after npx removal.** package.json, publish.yml, trellis, and docs all
  encode the old layout; Slices 4–8 are the systematic sweep, guarded by the Command/State Addition
  checklists in shared.md.
- **Dependency — Claude Code plugin/marketplace feature.** GA per current docs; no preview flag
  needed.
- **Process change — branch model adoption.** `develop` must exist and become the PR base before
  Phase 1's PR merges; `main` is reserved for releases the marketplace tracks. This is repo-admin
  (branch creation + default-PR-base/branch-protection settings) plus doc updates — light, but it
  retargets this cycle's remaining PRs to `develop`, so the navigator should branch from and PR into
  `develop`, not `main`.

### Backlog Updates

- **Consider a contributor skill-dev helper** (hot-reload or a `make dev` that reinstalls the local
  plugin) *if* the dev-loop friction proves real after Slice 1 — backlog, low priority.
- No other additions; the overlay-distribution "feature" is consciously *not* built (documented as
  consumer-owned), so nothing is parked for it beyond the ADR.
