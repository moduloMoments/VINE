# VINE Project Hooks — VINE Framework
# Edit this file to customize VINE behavior for this repo.

## Available Tools & Agents

### VINE Commands (in `commands/vine/`)
- `/vine:init` — Scaffold .vine/hooks/ for a project
- `/vine:verify` — Context-building spike for a feature
- `/vine:inquire` — Feature specification and design
- `/vine:navigate` — Guided implementation with per-slice commits
- `/vine:evolve` — Triple evolution: product, agent, user
- `/vine:pair` — Lightweight pair programming for quick fixes
- `/vine:pause` — Capture session state when stopping work
- `/vine:resume` — See where you left off and what's next
- `/vine:status` — Quick read-only progress check
- `/vine:optimize` — Analyze and optimize skill matching, workflows, token efficiency, and interactivity
- `/vine:help` — Command reference and usage guide

### Contributor Tools (in `.claude/commands/`)
- `/trellis` — Validate structural conventions across VINE command files
- `/triage` — Check GitHub issues, surface priorities, and discuss next steps
- `/pr` — Create a PR using the repo's template and contributing guidelines

### Notes
- This repo IS the VINE framework — commands in `commands/vine/` are symlinked to `.claude/commands/vine/`
- Editing a command file changes the tool itself. Test changes by running the modified command on this repo or another project.

## Project Conventions

### Repository Structure
- `commands/vine/` — The 11 VINE command files (init, verify, inquire, navigate, evolve, pair, pause, resume, status, help, optimize). These ARE the product.
- `.claude/commands/` — Contributor tools (trellis, triage, pr). Not part of the distributed product.
- `references/STATE.md` — State artifact contracts between phases
- `.github/` — PR template, issue templates (bug, friction, idea)
- `README.md` — Primary documentation, installation, philosophy
- `CONTRIBUTING.md` — Contribution guidelines
- `.vine/hooks/shared.md` — This file (tracked in git for contributor onboarding)

### Writing Style
- Commands are written in second-person instructional markdown ("Scan the project for...", "Present a summary...")
- Each command has YAML frontmatter: name, description, argument-hint, allowed-tools
- Sections use `##` headers for major steps, `###` for substeps
- Anti-patterns and constraints are called out explicitly
- AskUserQuestion is preferred over markdown lists for decision points

### Command Addition Checklist
When adding or removing a VINE command, update all of these:
- `CLAUDE.md` — command count and list
- `README.md` — command references, install text, hooks table
- `references/STATE.md` — if the command affects the artifact chain
- `.vine/hooks/shared.md` — command list and count
- `.vine/hooks/verify.md` — command count reference

### Content Standards
- Keep command files focused — one phase, one responsibility
- State artifact formats are defined in `references/STATE.md` — commands must produce artifacts that match
- README is the source of truth for user-facing documentation
- Markdown should be clean, readable without rendering

## Collaboration Stance

Internal, not shown to the engineer. Apply this stance in all VINE phases:

> "This is a partnership — both sides learn, both sides grow. Three concrete behaviors:
>
> 1. **Flag your uncertainty.** When you're unsure about a pattern, module, or convention,
>    say so. The engineer is a resource, not an audience.
> 2. **Grow through the work.** When you use a pattern they might not know, name it as you
>    write. When they correct you, acknowledge what you learned. Growth lives in the
>    narration, not in debriefs.
> 3. **Let expertise shape engagement.** Their profile level (confident/familiar/learning/new)
>    calibrates your default — but confidence is contextual, so follow their lead."

## Engineer Profile Protocol

After loading hooks, check for `.vine/PROFILE.md`. If it exists, read the Domain Expertise
table. Match the feature's domain against the profile's entries.

- **If the domain is in the profile**: Note their level for this session. Use it to calibrate
  default engagement depth (confident/familiar = concise; learning/new = explain the why).
- **If the domain is NOT in the profile or no profile exists**: Proceed with default depth.
  No prompt, no warning.

## Team Context

- **Maintainer**: Solo maintainer, expecting community contributors in the future
- **PR review**: Self-review and merge for now; will evolve to community review
- **Tracking**: GitHub Issues for bugs/friction/ideas, GitHub Discussions for community conversation
- **Public-first**: Work in public, track tasks in GitHub rather than private tools

## CI/CD

- **Publish workflow**: `.github/workflows/publish.yml` — manual dispatch, publishes `create-vine` to npm with provenance
  - Reads version from `package.json`, extracts release notes from `CHANGELOG.md`
  - Runs smoke test (`bin/cli.js` in temp dir, verifies command files are installed)
  - Creates git tag + GitHub release with changelog notes
- **Testing**: Run VINE phases on real repos to test command changes
- **Validation**: Run `/trellis` before submitting PRs to check command structure and artifact format compliance
- **Build**: None — pure markdown, no compilation step
- **Release checklist**: Bump version in `package.json`, add entry to `CHANGELOG.md`, then trigger the publish workflow
