# Feature Context: vine:pair — Lightweight Mode
## Date: 2026-03-27
## Author: Rob + Claude

### Codebase Landscape

**The 5 existing commands** in `commands/vine/` (init, verify, inquire, navigate, evolve) all follow a strict structural pattern:
- YAML frontmatter: `name`, `description`, `argument-hint`, `allowed-tools`
- "Load Project Hooks" section (reads `shared.md` + `<phase>.md`)
- "Load Engineer Profile" section (except init)
- Hooks before profile (enforced by `/trellis`)
- Second-person instructional markdown
- AskUserQuestion for all decision points

**The state artifact chain**: `CONTEXT.md → SPEC.md → NAVIGATION.md → EVOLUTION.md` — all in `.vine/projects/<domain>/<feature-slug>/`. vine:pair breaks from this by producing zero artifacts.

**Symlink structure**: `commands/vine/` is symlinked to `.claude/commands/vine/`. Adding `pair.md` to `commands/vine/` automatically registers the command.

**Trellis validator** (`/.claude/commands/trellis.md`) validates all `commands/vine/*.md` files against 8 structural checks. vine:pair must pass all non-init checks including referencing `.vine/hooks/pair.md` in its hooks section (even though the file is optional and won't exist in most projects).

### Current State

- 5 command files, all passing trellis
- README and CLAUDE.md both say "5 commands" — will need updating
- `references/STATE.md` defines artifact formats but has no section for artifact-free commands
- CONTRIBUTING.md references the 5-command structure

### Decisions Made During Verify

1. **Zero artifacts** — no `.vine/` files written. Mini-retro is conversational only, with CLAUDE.md/skill suggestions if warranted.
2. **Load shared.md only** — reference `pair.md` hook to satisfy trellis, but only shared.md provides real value for a quick mode.
3. **Load engineer profile** — low cost, adjusts narration depth. Follows standard pattern.
4. **Lives in `commands/vine/pair.md`** — part of the distributed product, not a contributor tool.
5. **Targeted context check** — read files the engineer points at + immediate neighbors. No broad scan. 2-3 min max.
6. **Single commit at end** — pair work is small enough for one commit. Suggest message, engineer approves.
7. **Retro = CLAUDE.md + skill suggestions** — same retro block pattern as other phases, but no EVOLUTION.md.

### Edge Cases & Tribal Knowledge

- **"This repo IS the VINE framework"** — editing a command file changes the tool itself. Testing means running the modified command on a real repo.
- The shared hook (`shared.md`) is tracked in git for this repo specifically (contributor onboarding). Per-phase hooks are gitignored.
- Trellis Check 4 requires `.vine/hooks/<phase>.md` reference in the hooks section. Referencing `pair.md` as optional satisfies this without requiring the file to exist.
- The `allowed-tools` union across all commands defines what trellis considers "known" tools. vine:pair's tool list becomes part of this union.

### Tech Debt in Affected Areas

- No tech debt directly in the way. The command files are clean and consistent.
- Minor: README, CLAUDE.md, and CONTRIBUTING.md all hardcode "5 commands" — these need updating when pair ships.

### Documentation Gaps

- README "The Four Phases" section and diagram don't account for non-phase commands like pair
- No guidance in CLAUDE.md or STATE.md for commands that don't produce artifacts
- CONTRIBUTING.md's "Repository Structure" section lists the 5 commands explicitly

### Open Questions

1. **How should README present vine:pair?** It's not a "5th phase" — it's a mode. The "Four Phases" section and ASCII diagram need a narrative decision: separate section? sidebar? mentioned after the phases?
2. **Should vine:pair load the profile and potentially prompt for domain registration?** We said yes to loading, but should a quick pair session add a domain to PROFILE.md? Feels like ceremony for a quick fix. Possible answer: load profile for narration depth but never prompt to add a domain — that's verify's job.
3. **What `allowed-tools` does vine:pair need?** It reads code (Read, Glob, Grep), writes code (Write, Edit), runs validation (Bash), asks questions (AskUserQuestion). Does it need Agent or WebFetch?
4. **Should vine:pair suggest vine:evolve if the work turned out bigger than expected?** An escape hatch from pair to the full cycle could be valuable.
5. **What does "implement with narration" mean concretely?** Navigate has detailed narration guidance calibrated by profile level. Pair should inherit a compressed version of this — but how compressed?
