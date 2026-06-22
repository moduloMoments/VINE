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
- **Version** — with npm gone, `plugin.json` `version` becomes the single version source; bump to
  `0.4.0` (clearing the pre-existing package.json drift). The marketplace entry omits `version`
  (plugin.json wins silently).
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
10. **Decisions recorded.** Knowledge ADR(s) capture the drop-npx decision (revised gate) and the
    overlay-is-consumer-owned decision (amending the team-layer ADR's "seam" expectation).

### Work Slices

## Phase 1: Scaffold + Invocation Proof (Slices 1) ⬜
Summary: Add the plugin manifest + marketplace and prove the skill recipe and colon namespace on a
single low-risk command before converting anything else.
Session boundary: The plugin installs locally and one phase invokes as `/vine:status`; the conversion
recipe is proven and the colon-form risk is retired. Ships as PR 1.

### Slice 1: Plugin manifest, marketplace, and invocation spike
- **Goal**: Stand up `.claude-plugin/plugin.json` (name `vine`, version `0.4.0`) and
  `.claude-plugin/marketplace.json` (one entry, `source` = repo root). Convert one low-risk command
  (`status`) to `skills/status/SKILL.md` with `disable-model-invocation: true`, mapping frontmatter
  (`name`/`description`/`argument-hint`/`allowed-tools`) and confirming `$ARGUMENTS` carries over.
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

## Phase 2: Convert the Product to Skills (Slices 2–3) ⬜
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

### Slice 5: Remove the npx distribution
- **Goal**: Delete `bin/cli.js`, the migrated `commands/vine/` tree, and the `.claude/commands/vine/`
  symlink; update `package.json` (drop `bin`/`create-vine` packaging and the commands entries from
  `files`; keep only what repo metadata needs); replace `publish.yml`'s npm publish with a git-tag +
  GitHub-release flow (the marketplace installs from git).
- **Depends on**: Slices 2–4 (skills + tooling must be live before the old path is removed).
- **Files likely touched**: `bin/cli.js` (delete), `commands/vine/` (delete), `.claude/commands/vine/`
  symlink (delete), `package.json`, `.github/workflows/publish.yml`.
- **Acceptance criteria**: No `create-vine`/npm artifacts remain; the release flow tags + releases for
  the marketplace; contributor dogfooding via local plugin install works (AC 6–8).
- **Complexity signal**: Medium — deletion is easy; reworking `publish.yml` and confirming nothing
  else references the removed paths is the care point.

### Slice 6: init legacy-install migration
- **Goal**: `/vine:init` detects a legacy `.claude/commands/vine/` (old npx install) and offers a
  one-time cleanup; declining changes nothing (#58 offer-migration pattern).
- **Depends on**: Slice 2 (skills are the thing being migrated to).
- **Files likely touched**: `skills/init/SKILL.md`.
- **Acceptance criteria**: With a legacy dir present, init offers cleanup and removes it on accept,
  no-ops on decline; with no legacy dir, init behaves exactly as before (AC 7).
- **Complexity signal**: Low — additive detection + an AskUserQuestion offer.

## Phase 4: Docs + Cycle Knowledge (Slices 7–9) ⬜
Summary: Make every doc surface describe the skills/plugin product and record the load-bearing
decisions.
Session boundary: Docs and knowledge are current; #57 is closeable. Ships as PR 4.

### Slice 7: README + CHANGELOG
- **Goal**: Lead the README with plugin install (`claude plugin marketplace add` → install); remove
  the npx/manual-copy sections; add a migration note for existing npx users; document the solo→team
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
  "Skill Addition Checklist" and update the Skill Workflows install step; update `references/STATE.md`
  product references and add the version-sync note (plugin.json single source).
- **Depends on**: Slices 1–6.
- **Files likely touched**: `CLAUDE.md`, `.vine/context/shared.md`, `.vine/context/verify.md` (command
  count), `references/STATE.md`.
- **Acceptance criteria**: No internal doc describes the product as "11 command files in
  `commands/vine/`" or references the npx-only install; the addition checklist targets skills (AC 9).
- **Complexity signal**: Medium — the old layout is referenced across several contributor docs; the
  Command/State Addition checklists in shared.md exist to catch exactly this kind of multi-file drift.

### Slice 9: Knowledge ADR(s)
- **Goal**: Record (a) the plugin-only / drop-npx decision and its rationale (revised hard gate), and
  (b) overlay distribution = document-only / consumer-owned, amending the team-layer ADR's "seam"
  expectation.
- **Depends on**: Slices 1–8 (decisions are settled by the work).
- **Files likely touched**: `.vine/knowledge/workflow/2026-06-*-*.md` (1–2 ADRs).
- **Acceptance criteria**: ADRs exist in the committed knowledge format; the team-layer "seam"
  expectation is explicitly amended rather than left dangling (AC 10).
- **Complexity signal**: Low — durable-decision capture in the established ADR format.

### Tech Debt Integration

- **Version drift (package.json 0.3.0 vs 0.4.0 CHANGELOG)** — *Addressed now.* `plugin.json` becomes
  the single version source at `0.4.0`; package.json's npm version stops mattering once npm publish is
  removed (Slice 5).
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

### Backlog Updates

- **Consider a contributor skill-dev helper** (hot-reload or a `make dev` that reinstalls the local
  plugin) *if* the dev-loop friction proves real after Slice 1 — backlog, low priority.
- No other additions; the overlay-distribution "feature" is consciously *not* built (documented as
  consumer-owned), so nothing is parked for it beyond the ADR.
