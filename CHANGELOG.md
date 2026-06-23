# Changelog

All notable changes to VINE are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

This is the 0.4.0 "platform alignment" cycle — aligning VINE's vocabulary and mechanics with
Claude Code's native platform surface: context overlays vs. native hooks, honest enforcement,
the knowledge boundary, native task tools, gearing↔permission-mode, and — closing the cycle —
repackaging VINE as a native Claude Code plugin (#57). The `#` tags below are the per-phase
tracking issues (#57–#62).

### Added
- **VINE ships as a native Claude Code plugin (#57)** — Install via the self-hosted `moduloMoments` marketplace (`claude plugin marketplace add moduloMoments/VINE` → `claude plugin install vine@moduloMoments`) and update with `/plugin update vine` — replacing `npx create-vine`. All 11 phases now ship as `skills/<name>/SKILL.md` and invoke in colon form (`/vine:<name>`), with the two phase-support agents (`vine-codebase-explorer`, `vine-verification`) and the journal-check hook riding in the same plugin. The two autonomous-role agents (`vine-coder`, `vine-reviewer`) are repo-resident under `.claude/agents/`, not shipped by default. Every skill carries `disable-model-invocation: true`, so a phase never auto-fires from model reasoning. The product lives under `plugins/vine/` so the published payload is product-only (Claude Code has no file-level payload exclusion — a scoped `source` directory is the only control). The journal-check hook is now **default-on** for plugin users (wired via `hooks/hooks.json` + `${CLAUDE_PLUGIN_ROOT}`), where the npx scaffold made it opt-in.
- **Honest enforcement scaffold (#59)** — A `.vine/ACTIVE` session sentinel scopes installed hooks to active navigate sessions, and a POSIX `journal-check.sh` hook blocks `git commit` until the feature's NAVIGATION.md is updated (mtime-based, so it works whether `.vine/` is tracked or gitignored). `/vine:init` offers to wire the scaffold into `.claude/settings.json`; declining changes nothing on disk. README gains an **Enforced vs Advisory** section that's honest about which guarantees are mechanical (one, with the scaffold installed) and which are advisory.
- **Native task tracking (#61)** — When the harness provides task tools, `vine:navigate` builds an ephemeral live view of slice progress, and `vine:resume`/`vine:status` read it for an at-a-glance picture. The live view is a derived mirror of NAVIGATION.md — always rebuilt from the journal, never the reverse. STATE.md adds a **Source of Truth vs Derived Views** contract codifying the split.
- **Inquire sign-off gate + artifact review links (#62)** — `vine:inquire` now gates completion on an explicit `AskUserQuestion` sign-off on the written SPEC, presented as a clickable link with a request-changes/iterate loop; `vine:verify` presents CONTEXT.md as a clickable link on creation. Auto-opening the file is documented as optional repo wiring, never hardcoded.
- **Between-slice `/clear` (#62)** — `vine:navigate` step 7 offers a `/clear`-and-continue-fresh path between slices (selective: recommended only when context is heavy or the next slice is independent), re-entering at the next unfinished slice via the journal rebuild.

### Changed
- **`.vine/hooks/` renamed to `.vine/context/` (#58)** — VINE's per-project customization directory is now "context overlays," freeing "hooks" to mean Claude Code's native hooks. All 11 commands load from `.vine/context/` first and fall back to legacy `.vine/hooks/` (with a once-per-session migration nudge) through 0.4.x. The fallback and nudge are removed in 0.5 — see the tracking issue filed with this release.
- **`/vine:init` legacy migration offer (#58)** — On pre-0.4 installs (`.vine/hooks/` exists, `.vine/context/` doesn't), init offers a one-time directory move, handling the gitignore-negation caveat for repos that track their overlays. Declining changes nothing on disk; commands keep working via the fallback.
- **Trellis legacy detection (#58)** — Trellis now validates the `## Load Context Overlays` heading and `.vine/context/` paths, and warns (without failing) on stray `.vine/hooks/` references — the command fallback lines and init's migration section are allowlisted. Warnings are slated to harden to failures with the 0.5 fallback removal.
- **Honest prose pass (#59)** — Command and README language no longer overclaims what a session is forced to do; advisory guarantees are described as recommendations the command makes and Claude follows, not as mechanical blocks.
- **Knowledge Boundary rule (#60)** — A new rule in `references/STATE.md` draws the line between repo facts (which live in CLAUDE.md / STATE.md) and the harness's native skill inventory (which VINE reads live, never duplicates in files). `vine:optimize` is rewritten around the rule, the "this repo" overlay is deduped, and `/vine:init` offers a dedup pass. The **Skill Workflows** map moved from CLAUDE.md to `.vine/context/shared.md` — superseding the 0.3.0 "Skill Workflows in CLAUDE.md" location — and CLAUDE.md now carries an availability-gated pointer instead of the inline map.
- **Gearing ↔ permission-mode preference (#62)** — `vine:navigate`'s per-slice gearing now recommends the matching permission mode: **free climb → auto-accept-edits**, **walk me through → approve-edits**. The recommendation is explicit; flipping the toggle stays the engineer's action — VINE recommends, never switches modes for you.
- **Artifact-commit guidance for tracked repos (#62)** — `vine:navigate` and `vine:evolve` now state a consistent, self-sufficient staging rule: tracked artifacts → bundle the artifact with its commit (slice → NAVIGATION/SPEC deviations; phase-group boundary → PROJECT-MAP/SPEC header); untracked → code only, the mtime guarantee preserved. STATE.md carries the consolidated per-commit-point contract for contributors.
- **Versioning + branch model (#57)** — `plugins/vine/.claude-plugin/plugin.json` `version` is the single source of truth (`0.4.0`); `package.json` is removed, so no competing version field survives. SemVer for a behavior-only product: **major** = a command/skill removed or renamed or an invocation/artifact-contract break, **minor** = a new command/skill/agent/hook or capability, **patch** = prose/doc/non-behavioral fixes. **`main` holds only released states** (the marketplace `source` tracks it, no `ref`), **`develop` is the integration branch**, and feature branches cut from `develop`. Cutting a release = merge `develop`→`main`, bump the plugin version, tag `vX.Y.Z`, GitHub release.

### Removed
- **npx installer + the `commands/vine/` layout (#57)** — `bin/cli.js`, the `commands/vine/` command tree, the `.claude/commands/vine/` symlink, and `package.json` are deleted; `publish.yml` no longer publishes to npm (it parses the plugin version and cuts a tagged GitHub release). Existing npx users migrate by removing the legacy directory and installing the plugin — `/vine:init` detects a legacy install and offers the cleanup. VINE ships **no overlay-distribution mechanism**: overlay content stays repo-local and consumer-authored, and a company carries conventions across repos by forking the plugin's skills/agents (those distribute natively).

## [0.3.0] - 2026-04-06

### Added
- **vine:optimize** — New command that audits skill descriptions, detects workflow chains, analyzes token efficiency, and optimizes interactivity patterns across all commands and skills.
- **Reusable agents** — `vine-codebase-explorer` (deep codebase research) and `vine-verification` (lint/typecheck/test + acceptance criteria checking) shipped in `agents/`, installed flat to `.claude/agents/` by the CLI.
- **Skill Workflows in CLAUDE.md** — 5 named workflows (Feature Delivery, Quick Fix, Session Management, Maintenance, Contributor PR Flow) with state-based suggestions for command routing.
- **Agent delegation** — verify, inquire, navigate, and evolve now delegate to the reusable agents for codebase exploration and validation.
- **Evolve-to-optimize chain** — Evolve suggests running `/vine:optimize` when a cycle produces new skills or command changes.
- **Trellis-to-PR chain** — Trellis suggests `/pr` when all checks pass and command files have uncommitted changes.

### Changed
- **Description rewrites** — 12 command/skill descriptions rewritten for Claude's ~250 char matching window (+78% matching surface).
- **Token consolidation** — Collaboration stance and engineer profile protocol moved from 7 command files into `.vine/hooks/shared.md` (~150 tokens/session saved). Commands reference shared.md instead of repeating the blocks.
- **Navigate gearing** — Changed from free-text response to structured `AskUserQuestion` with 2 options. Recommended default follows profile expertise level.
- **Navigate blocker handling** — Changed from prose option lists to structured `AskUserQuestion` with concrete resolution paths.
- **Pair commit confirmation** — Changed from free-text approval to structured `AskUserQuestion` with 3 options.
- **Navigate principles trimmed** — Removed principles that restated what the command steps already demonstrate.
- **CLI install output** — Now reports agent count alongside command count.
- Command count updated from 10 to 11 across CLAUDE.md, README, hooks, and trellis.

## [0.2.0] - 2026-04-03

### Added
- **Collaboration stance** — Replaces the passive depth hint across 7 commands with a partnership model: philosophical anchor + three concrete behaviors (flag uncertainty, grow through the work, let expertise shape engagement).
- **Per-slice gearing** — Navigate offers "free climb" (auto-accept, lighter narration) or "walk me through this" (full partnership) per slice. Profile expertise informs the default, engineer always chooses.
- **Navigate completion gate** — Phase Completion now verifies every slice has a commit hash, validation status, acceptance criteria, and learnings before suggesting evolve. Lists gaps and fixes inline.
- **Verify scope check** — After exploring the landscape (step 3b), verify evaluates whether the full cycle is warranted or vine:pair would suffice. Off-ramp for simpler-than-expected work.
- **Verify gearing note** — Completion block includes a navigate gearing recommendation based on observed complexity.
- **Evolve ticket creation** — Follow-up items can become GitHub issues (or tickets via hook-defined workflows for Jira, Linear, etc.).
- **Gear-linked check-ins** — Between Slices includes a brief reflection after partnership-mode slices, skipped after free climb.
- **STATE.md field markers** — NAVIGATION.md template fields marked `<!-- required -->` or `<!-- optional -->` matching the gate check.
- **PROJECT-MAP.md** — Universal progress tracker created by verify, updated by all phases. Shows VINE phase status at a glance. For multi-PR features, inquire adds a Milestones table mapping phase groups to PRs with status markers.
- **vine:status** — Quick read-only progress check. Lighter than resume — no session state, no recommendations.
- **vine:help** — Command reference and usage guide.
- **Multi-PR tracking** — Inquire auto-detects larger features (>4 slices or phase groups) and offers milestone tracking. Navigate runs phase-group verification before suggesting PRs at phase boundaries.
- **Evolve commit + PR flow** — Evolve now commits its artifacts and suggests opening a PR after marking resolved.
- **Resume PR backfill** — Resume prompts to fill in missing PR numbers on shipped milestones.
- **Cross-reference notes** between navigate phase-group verification and evolve product verification to prevent drift.
- **`.vine/` artifacts tracked** — Per-phase hooks and resolved project artifacts committed for contributor context.
- **Artifact preview docs** — Guide for rendering VINE artifacts with glow and Claude Code hooks.
- **"Is VINE for you?"** — README section helping users quickly determine if VINE fits their workflow.

### Changed
- **NAVIGATION.md update merged into step 4** — Journal update is now a commit prerequisite, not a separate step. Old step 5 removed, steps renumbered 1-8.
- **Evolve user evolution reframed** — "Knowledge Captured" → "Engineer Contributions" (what you brought, not what you learned). "Suggested Explorations" removed. Growth log is opt-in with skip as default.
- Navigate output is now committed changes (one commit per validated slice), not staged changes.
- Evolve reads PROJECT-MAP.md for multi-PR context and reviews prior PRs via `gh` CLI when available.
- Pause detects current phase from PROJECT-MAP.md before falling back to artifact detection.
- Resume displays VINE Progress and Milestones from PROJECT-MAP.md in status summary.
- README updated with partnership model, per-slice gearing, and revised Key Principles (leads with "Partnership, not delegation").
- Command count updated from 8 to 10 across CLAUDE.md, README, hooks, and trellis.

## [0.1.2] - 2026-03-30

### Fixed
- Repository URL casing in package.json.

## [0.1.1] - 2026-03-28

### Fixed
- `vine:init` now creates `.vine/projects/` directory and reinforces the convention in shared.md hook template.

## [0.1.0] - 2026-03-27

### Added
- **Core phases**: vine:verify, vine:inquire, vine:navigate, vine:evolve — the four-phase feature development cycle.
- **vine:pair** — Lightweight pair programming for quick fixes without artifact ceremony.
- **vine:pause + vine:resume** — Session management for long-running features.
- **vine:init** — Project setup with repo discovery and hook scaffolding.
- **Engineer profile** (`.vine/PROFILE.md`) — Per-domain expertise tracking with depth-adjusted narration.
- **Project lifecycle** — Resolve and archive completed features.
- **State artifact chain** — CONTEXT.md, SPEC.md, NAVIGATION.md, EVOLUTION.md with format contracts in STATE.md.
- **Project hooks** — `.vine/hooks/` for per-project and per-phase customization.
- **Trellis** — Structural validation for command files and artifact format compliance.
- **npx installer** — `npx create-vine` for project-level, `npx create-vine --global` for user-level install.

[Unreleased]: https://github.com/moduloMoments/VINE/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/moduloMoments/VINE/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/moduloMoments/VINE/compare/v0.1.2...v0.2.0
[0.1.2]: https://github.com/moduloMoments/VINE/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/moduloMoments/VINE/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/moduloMoments/VINE/releases/tag/v0.1.0
