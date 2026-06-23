# plugin.json is VINE's single version source; main is the release branch, develop is integration

## Status

Accepted — 2026-06-23
Source: workflow/plugin-packaging · Actor: Rob + Claude
Supersedes: none

## Context

Dropping npm (`2026-06-23-vine-ships-as-a-plugin-and-drops-npx`) removed `package.json` and with
it VINE's version field, forcing a new versioning and release model. One platform fact drives it:
Claude Code resolves a plugin's version as `plugin.json` `version` → marketplace `version` → git
SHA, and **a set `version` gates updates** — users move to a new version only when the version
*string* changes; an omitted version floats on every commit to the tracked branch. Because VINE's
plugin source repo *is* the contributor tree (the plugin lives in `plugins/vine/`), a floating
version would ship work-in-progress to users on every commit.

A prior tech-debt item also lived here: `package.json` (0.3.0) and the `CHANGELOG` (0.4.0) had
drifted out of sync — two version fields that could disagree.

## Decision

**Pin, single-source, and split the branches.**

- `plugins/vine/.claude-plugin/plugin.json` `version` (SemVer) is the **single source of truth**
  (bumped to `0.4.0`). The marketplace entry **omits** `version` so plugin.json wins silently.
  `package.json` is removed entirely — no competing version field survives (closing the drift).
- **SemVer for a behavior-only product** (no API, only command behavior): **major** = a skill
  removed/renamed or an invocation/artifact-contract break; **minor** = a new skill/agent/hook or
  capability; **patch** = prose/doc/non-behavioral fixes.
- **Branch model: `main` = release, `develop` = integration.** `main` holds only released states,
  so the marketplace `source` tracks `main` (the default branch) with **no `ref`** — zero ref/sha
  management, every released version reproducible from `main`. All development targets `develop`;
  feature branches cut from it. Cutting a release = merge `develop`→`main`, bump the plugin
  version, tag `vX.Y.Z`, GitHub release.
- **Users update** via `/plugin update vine` (replacing `npx create-vine@latest`).

## Consequences

- The marketplace needs no per-release ref bookkeeping: pointing at the repo's default branch
  (`main`) and letting plugin.json carry the version is the whole mechanism.
- The existing `main-guard` hook ("don't commit directly to `main`") already fits — `main` being
  release-only is exactly what it enforces.
- Every in-flight branch (including this cycle's remaining PRs) retargets to `develop`; the
  contributor PR flow (`/pr`, `CONTRIBUTING.md`) was retargeted `main`→`develop` to match.
- One repo-admin action sits outside the code: setting `develop` as the default PR base + branch
  protection on the forge.
- The release workflow (`publish.yml`) parses the version from plugin.json (node-free) and cuts a
  tagged GitHub release with no npm step.
