# CLAUDE.md — VINE Framework

## What This Repo Is

VINE is a pure-markdown AI-assisted development framework. There is no build step, no runtime code, no compilation. The product is 8 command files in `commands/vine/` (init, verify, inquire, navigate, evolve, pair, pause, resume), a state reference at `references/STATE.md`, and a README.

**Editing a command file changes the tool itself.** Test changes by running the modified command on a real repo.

## Repository Structure

- `commands/vine/` — The 8 VINE command files (init, verify, inquire, navigate, evolve, pair, pause, resume). These ARE the product.
- `.claude/commands/` — Contributor tools (trellis, triage, pr). Not part of the distributed product.
- `references/STATE.md` — State artifact contracts between phases
- `.vine/hooks/shared.md` — Contributor context hook (tracked; per-phase hooks gitignored)
- `.vine/projects/<domain>/<feature-slug>/` — Per-feature VINE artifacts (gitignored)
- `.vine/PROFILE.md` — Engineer profile (gitignored)

## Command Authoring Conventions

- YAML frontmatter on every command: `name`, `description`, `argument-hint`, `allowed-tools`
- Valid tool names for `allowed-tools`: Read, Glob, Grep, Write, Edit, Bash, Agent, WebFetch, AskUserQuestion
- Every command starts with a "Load Project Hooks" section (reads `.vine/hooks/shared.md` + `.vine/hooks/<phase>.md`)
- Every command (except init) follows hooks with a "Load Engineer Profile" section (reads `.vine/PROFILE.md`). Init creates hooks/profile rather than loading them.
- Load Project Hooks must appear before Load Engineer Profile — this ordering is enforced by `/trellis`
- Commands are written in second-person instructional markdown ("Scan the project for...", "Present a summary...")
- `AskUserQuestion` is preferred for all decision points: max 4 questions per call, max 4 options per question, recommended option first with "(Recommended)" suffix
- Each command is self-contained — repeated blocks (hook loading, profile loading) are intentional, not DRY violations
- Run `/trellis` to validate command structure and artifact format compliance before submitting changes

## State Artifact Chain

Features flow through: `CONTEXT.md` → `SPEC.md` → `NAVIGATION.md` → `EVOLUTION.md`

All live in `.vine/projects/<domain>/<feature-slug>/`. Formats are defined in `references/STATE.md`. Section headings in STATE.md templates use `<!-- required -->` / `<!-- optional -->` HTML comment markers — new sections must include a marker to prevent validation drift.

`vine:pair` is artifact-free — it produces code changes and a single commit but no CONTEXT/SPEC/NAVIGATION/EVOLUTION files.

`vine:verify` also creates `PROJECT-MAP.md` as a progress tracker. For multi-PR features, `vine:inquire` adds a Milestones table mapping phase groups to PRs.

`vine:pause` writes an ephemeral `PAUSE.md` to the feature directory. `vine:resume` reads it (plus existing artifacts) to reconstruct session state. PAUSE.md is deleted when evolve writes `.resolved`.

## Engineer Profile

`.vine/PROFILE.md` tracks per-domain expertise (confident, familiar, learning, new). Commands use a one-sentence depth hint to adjust explanation depth:

> "The engineer's profile indicates they are [level] with the [domain] domain. Adjust your explanation depth accordingly — be concise where they're confident, explain the why behind decisions where they're learning or new."

If no profile exists or the domain isn't listed, commands behave exactly as they do without the feature.
