# Changelog

All notable changes to VINE are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

### Added
- **PROJECT-MAP.md** — Universal progress tracker created by verify, updated by all phases. Shows VINE phase status at a glance. For multi-PR features, inquire adds a Milestones table mapping phase groups to PRs with status markers.
- **vine:status** — Quick read-only progress check. Lighter than resume — no session state, no recommendations.
- **vine:help** — Command reference and usage guide.
- **Multi-PR tracking** — Inquire auto-detects larger features (>4 slices or phase groups) and offers milestone tracking. Navigate runs phase-group verification before suggesting PRs at phase boundaries.
- **Evolve commit + PR flow** — Evolve now commits its artifacts and suggests opening a PR after marking resolved.
- **Resume PR backfill** — Resume prompts to fill in missing PR numbers on shipped milestones.
- **Cross-reference notes** between navigate phase-group verification and evolve product verification to prevent drift.
- **`.vine/` artifacts tracked** — Per-phase hooks and resolved project artifacts committed for contributor context.
- **Artifact preview docs** — Guide for rendering VINE artifacts with glow and Claude Code hooks.

### Changed
- Navigate output is now committed changes (one commit per validated slice), not staged changes.
- Evolve reads PROJECT-MAP.md for multi-PR context and reviews prior PRs via `gh` CLI when available.
- Pause detects current phase from PROJECT-MAP.md before falling back to artifact detection.
- Resume displays VINE Progress and Milestones from PROJECT-MAP.md in status summary.
- README expanded with multi-PR section, gh CLI as optional dependency, and link to `.vine/projects/` examples.
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

[Unreleased]: https://github.com/moduloMoments/VINE/compare/v0.1.2...HEAD
[0.1.2]: https://github.com/moduloMoments/VINE/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/moduloMoments/VINE/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/moduloMoments/VINE/releases/tag/v0.1.0
