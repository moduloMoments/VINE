# Changelog

All notable changes to VINE are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

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

[Unreleased]: https://github.com/moduloMoments/VINE/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/moduloMoments/VINE/compare/v0.1.2...v0.2.0
[0.1.2]: https://github.com/moduloMoments/VINE/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/moduloMoments/VINE/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/moduloMoments/VINE/releases/tag/v0.1.0
