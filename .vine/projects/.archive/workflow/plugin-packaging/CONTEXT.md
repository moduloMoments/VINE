# Feature Context: Claude Code Plugin Packaging + Team-Overlay Distribution
## Date: 2026-06-22
## Author: Rob + Claude

Cycle 5 of the v0.4.0 roadmap (issue [#57](https://github.com/moduloMoments/VINE/issues/57)).
Package VINE as a native Claude Code plugin distributed via a marketplace, *and* make that plugin
the carrier for team/company overlay content — while keeping the existing `npx create-vine` flow
working (backward compatibility is the roadmap's hard gate).

### Codebase Landscape

The distribution surface today is small and file-copy based:

- **`bin/cli.js`** — the `create-vine` installer. Copies `commands/vine/*.md` → `.claude/commands/vine/`
  and `agents/*.md` → `.claude/agents/` (project or `--global`). Project installs also copy an
  allowlisted scaffold script (`journal-check.sh`) into `.vine/scripts/`; the allowlist deliberately
  excludes contributor-only scripts (`trellis-gate.sh`, `main-guard.sh`). On re-run it detects an
  upgrade and nudges `/vine:init`.
- **`package.json`** — name `create-vine`, version `0.3.0` (not yet bumped to 0.4.0 despite the
  `[Unreleased]` 0.4.0 CHANGELOG block). `files` allowlist controls what npm ships: `bin`,
  `commands/vine`, `agents`, and the single scaffold script.
- **`.github/workflows/publish.yml`** — manual `workflow_dispatch` only. Reads version from
  package.json, extracts the matching CHANGELOG section, smoke-tests `bin/cli.js` in a temp dir,
  `npm publish --provenance`, then tags + creates a GitHub release.
- **The product** — 11 command files (`commands/vine/*.md`, frontmatter `name: vine:navigate` etc.,
  colon-namespaced) and 4 agents (`agents/*.md`: vine-codebase-explorer, vine-verification,
  vine-coder, vine-reviewer; frontmatter `name`/`description`/`tools`/`model`). Note: the npx
  installer only copies *commands and agents*; the contributor agents (coder/reviewer) ship too
  since `files` includes all of `agents/`.
- **Overlay surface** — team/company conventions live in the tracked `.vine/context/shared.md`,
  governed by the `<!-- class: policy -->` marker (immutable from the personal `.vine.local/` layer).
  Per the team-layer ADR, this overlay content is what the plugin must distribute cross-repo.

### Current State — Platform Schema Verified

Claude Code plugin/marketplace schema confirmed against current docs (code.claude.com/docs) via the
claude-code-guide agent:

- **Manifest** `.claude-plugin/plugin.json` + **marketplace** `.claude-plugin/marketplace.json` can
  co-live in one repo → users run `claude plugin marketplace add <repo>` then install. Only `name`
  is required in the manifest; component dirs (`commands/`, `agents/`, `hooks/`, `skills/`) are
  auto-discovered at the plugin **root** (not inside `.claude-plugin/`).
- **Namespace survives.** Frontmatter `name: vine:navigate` is honored as-is — the plugin name does
  **not** auto-prefix — so `/vine:*` invocation is unchanged loaded as a plugin. This is load-bearing
  for the backward-compat gate.
- **Agents behave identically.** Description-based auto-delegation works the same loaded via plugin
  vs. copied into `.claude/agents/`.
- **Hooks shippable.** A plugin can wire hooks via `hooks/hooks.json` using `${CLAUDE_PLUGIN_ROOT}`
  — a possible native home for `journal-check.sh` (today copied by the npx installer).
- **Version sources can pin or float.** Set `version` to pin; omit to use git SHA. Setting it in both
  plugin.json and the marketplace entry is redundant (plugin.json wins silently).

### Edge Cases & Tribal Knowledge

- **Single repo is both the contributor tree and the plugin root.** VINE's files are nested at
  `commands/vine/*.md`, but a plugin auto-discovers `commands/*.md` at its root. Whether the plugin
  lives at repo root, a `plugins/<name>/` subdir, or restructures the tree is an open design fork
  (see Open Questions). This is the central structural tension.
- **Coexistence duplicates, doesn't collide.** A user who installed via npx (`.claude/commands/vine/`)
  *and* installs the plugin gets both on disk — duplicate UI entries, no hard error. Migration is a
  documented `rm -rf` of the old dir. The backward-compat gate is about *not breaking* npx users, not
  about preventing dual-install.
- **Overlays have no native plugin slot.** Plugins ship commands/agents/hooks/skills — not arbitrary
  context files like `shared.md`. The team-layer ADR names #57 as "the explicit seam where plugin
  distribution attaches," but *how* overlay content rides in a plugin is unsolved (skill? SessionStart
  hook that composes? documented copy?). This is the harder half of #57.
- **Obsolescence discipline applies.** Per the roadmap, anything VINE builds near the platform's orbit
  gets a 3–6 month config review. A plugin manifest is close to the platform — keep it thin.

### Tech Debt in Affected Areas

- **Version drift, pre-existing.** package.json is `0.3.0` while CHANGELOG `[Unreleased]` is the 0.4.0
  cycle. The plugin adds a *third* version source (plugin.json + marketplace entry) — version-sync is
  now a release-checklist concern, called out in #57's acceptance criteria.
- **`commands/vine/` nesting vs. flat plugin discovery** — may force a layout decision or a build/copy
  step; flagged as a fork, not yet debt to pay.
- **Unverified platform claim (do not act on yet):** the guide flagged flat `commands/*.md` as
  "deprecated for new plugins, use `skills/`". Treat as **unverified** per shared.md's agent-diagnosis
  rule — re-confirm against docs in inquire before any migration. If true it's a large fork; if false,
  commands ship as-is.

### Documentation Gaps

- **README install section** ([README.md](README.md) ~line 115) documents npx + manual-copy only.
  #57's acceptance criteria require documenting plugin install as the *recommended* path, npx as the
  alternative.
- **Release checklist** (in `.vine/context/shared.md` CI/CD section and any CONTRIBUTING notes) must
  gain the plugin/marketplace version-sync step.
- **CHANGELOG** needs a 0.4.0 plugin entry; the `[Unreleased]` block is the current home.
- **Solo→team graduation path** (README, per team-layer ADR) should point at the plugin as the
  cross-repo overlay-distribution mechanism once it exists.

### Open Questions

1. **Repo layout** — Plugin at repo root (reusing `commands/`, `agents/`), a `plugins/vine/` subdir,
   or a restructure? Does plugin discovery handle the nested `commands/vine/*.md`, or must the layout
   flatten? Resolve before any manifest is written.
2. **Commands vs. skills** — Verify the "flat commands deprecated, use skills/" claim against current
   docs. Decide whether the 11 commands ship as `commands/` (status quo) or migrate to `skills/`.
   Highest-leverage fork — changes the size of the cycle.
3. **Overlay distribution mechanism** — How does team/company `shared.md` overlay content travel
   inside a plugin (no native overlay component exists)? This is the expanded-scope core of #57 and
   the team-layer ADR's named seam. Candidate mechanisms to weigh in inquire: a skill that installs
   overlay content, a SessionStart hook, or documented file placement + init recompose.
4. **Hook home** — Does `journal-check.sh` move to the plugin's `hooks/hooks.json`
   (`${CLAUDE_PLUGIN_ROOT}`), stay an npx scaffold copy, or both? Affects the npx installer's role.
5. **npx coexistence policy** — What does init/README tell dual-install users? Is there an init-time
   detection + cleanup offer (the #58 rename-fallback pattern: offer migration, declining changes
   nothing)?
6. **Version-sync mechanism** — One source of truth across package.json, plugin.json, and the
   marketplace entry, or a sync step in the release checklist? Pin vs. git-SHA float.
7. **Marketplace hosting** — This repo's own `marketplace.json`, and the `source` form for the plugin
   entry (relative path vs. github source vs. git-subdir).
