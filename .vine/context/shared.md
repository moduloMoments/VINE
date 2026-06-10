# VINE Shared Context Overlay — VINE Framework
# Edit this file to customize VINE behavior for this repo.

## Available Tools & Agents

The command and agent inventory lives in the harness's native skill list, not in files — see the Knowledge Boundary rule in `references/STATE.md`. Repo-specific note:

- This repo IS the VINE framework — commands in `commands/vine/` are symlinked into `.claude/commands/vine/`, so running a command runs your working-tree edits.

## Project Conventions

### Repository Structure
See `CLAUDE.md` — repo facts live there (Knowledge Boundary rule, `references/STATE.md`). This file (`.vine/context/shared.md`) is tracked in git for contributor onboarding; the other overlays are gitignored.

### Writing Style
Command authoring conventions live in `CLAUDE.md` (Knowledge Boundary rule: repo facts every contributor session needs).

### Command Addition Checklist
When adding or removing a VINE command, update all of these:
- `CLAUDE.md` — command count and list
- `README.md` — command references, install text, hooks table
- `references/STATE.md` — if the command affects the artifact chain
- `.vine/context/verify.md` — command count reference

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

After loading overlays, check for `.vine/PROFILE.md`. If it exists, read the Domain Expertise
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

- **Trellis gate hook**: this repo's `.claude/settings.json` wires `.vine/scripts/trellis-gate.sh`
  (PreToolUse on Bash) — commits touching `commands/vine/` are blocked unless `/trellis` has
  passed since the last command edit (a green run writes `.vine/.trellis-ok`). Contributor-only:
  `create-vine` never ships this script. The journal-check scaffold hook is wired here too
  (dogfooding).
- **Publish workflow**: `.github/workflows/publish.yml` — manual dispatch, publishes `create-vine` to npm with provenance
  - Reads version from `package.json`, extracts release notes from `CHANGELOG.md`
  - Runs smoke test (`bin/cli.js` in temp dir, verifies command files are installed)
  - Creates git tag + GitHub release with changelog notes
- **Testing**: Run VINE phases on real repos to test command changes
- **Validation**: Run `/trellis` before submitting PRs to check command structure and artifact format compliance
- **Build**: None — pure markdown, no compilation step
- **Release checklist**: Bump version in `package.json`, add entry to `CHANGELOG.md`, then trigger the publish workflow
