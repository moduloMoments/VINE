---
description: "Set up VINE for this repo — scan the codebase for tools, agents, and conventions, then create context overlays and engineer profile for your first feature workflow"
argument-hint: ""
disable-model-invocation: true
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
  - Edit
  - Bash
  - Agent
  - AskUserQuestion
---

# vine:init — Project Setup

Initialize VINE for this repository by discovering available tools, agents, conventions, and
team patterns, then scaffolding `.vine/context/` with project-specific templates.

## What This Does

1. Discovers what's available in the repo (tools, agents, skills, commands, CI, test patterns)
2. Asks the engineer about team context that can't be derived from code
3. Generates `.vine/context/shared.md` (and per-phase overlays where warranted) from the
   shipped template — repo-specific content only; the framework's loading and precedence rules
   ship with the plugin (`${CLAUDE_PLUGIN_ROOT}/PROTOCOL.md`), so they never skew against it
4. Scaffolds `.vine/README.md` — a tracked, human/agent-facing orientation doc for using VINE in
   this repo (written for fresh repos; offered, not forced, in upgrade mode)
5. Sets up `.gitignore` for track-by-default — ignores the personal root `.vine.local/` and the
   session sentinel `.vine/ACTIVE`, leaving the rest of `.vine/` tracked
6. Introduces the engineer profile (builds organically through vine:verify)
7. When their triggers fire (Step 8), offers declinable one-time migrations and cleanups:
   legacy directory/gitignore migrations, machinery single-homing into the plugin protocol,
   CLAUDE.md dedup and pointer, legacy npx-install removal, and archiving legacy resolved
   projects

## Step 1: Discover Repo Capabilities

Scan the project for available tooling. Check each of these and catalog what you find:

**Claude configuration:**
- `.claude/commands/` — available slash commands (these can be suggested in overlay files)
- `.claude/skills/` — available skills and agents (these can be wired into specific phases)
- `.claude/settings.json` or `.claude/settings.local.json` — project-level settings
- `CLAUDE.md` — project conventions already documented

**CI/CD and testing:**
- CI config files (`.github/workflows/`, `Jenkinsfile`, `.circleci/`, etc.)
- Test runners and config (`jest.config.*`, `cypress.config.*`, `vitest.config.*`, etc.)
- Lint/format config (`.eslintrc*`, `.prettierrc*`, `biome.json`, etc.)
- Package scripts (`package.json` scripts section, `Makefile`, etc.)

**Project structure:**
- Monorepo indicators (`packages/`, `apps/`, `domains/`, workspace config)
- Key directories and their purposes
- Existing documentation (`docs/`, `*.md` files)

Present a summary of what you found to the engineer before generating anything.

## Step 2: Ask About Team Context

Use `AskUserQuestion` to gather context that can't be derived from code:

- Team/domain ownership patterns (who owns what areas)
- PR review conventions (required reviewers, review tools)
- Any external integrations to wire in (Jira, Linear, Slack, Confluence)
- Testing expectations (coverage thresholds, required test types)

Keep it to 1-2 rounds of questions max. Don't over-interrogate. Derive each question's
recommended option from the Step-1 discovery rather than assuming a team: a repo with no
team signals (single committer, no review config, no CODEOWNERS) recommends solo-appropriate
defaults ("Solo-owned", "No required review", "None") so a first-time user can accept the
recommendations and move on.

## Step 3: Generate Context Overlay Files

Create `.vine/context/`:

### shared.md

Write `.vine/context/shared.md` from the shipped template at
`${CLAUDE_SKILL_DIR}/templates/shared.md.tmpl` (equivalently
`${CLAUDE_PLUGIN_ROOT}/skills/init/templates/shared.md.tmpl`; if neither variable resolved to a
path, the "Base directory for this skill" line at the top of this skill names the same
directory — the `templates/` folder lives under it): copy it verbatim, fill `[Project Name]` and
`[date]`, and replace each bracketed placeholder with repo-specific content per the guidance
inside the bracket (Tooling Notes and Project Conventions from the Step-1 discovery, Team
Context from the Step-2 answers, Validation as a fenced YAML block populated from discovered
package scripts and configs — omit keys the repo doesn't have, or the whole block if nothing
is discoverable).

The template is deliberately slim: framework machinery (overlay loading, precedence, the
collaboration stance, interaction constraints) is **not** written into the consuming repo —
it ships with the plugin (`${CLAUDE_PLUGIN_ROOT}/PROTOCOL.md`) and every phase loads it from
there, so a repo's `shared.md` can never version-skew against the plugin.

### Per-phase files (verify.md, inquire.md, navigate.md, evolve.md, pair.md)

Only create per-phase files where there's something phase-specific to add — don't create
empty or boilerplate-only files, and don't restate what the Validation block already carries.
Examples of phase-specific content:

**verify.md** — Areas to always explore, domain-specific questions to ask, key config
files to check

**inquire.md** — Architecture decision templates, preferred patterns, design review
checklists specific to this project

**navigate.md** — Agents to invoke after code changes (e.g., code reviewers, test
generators), test commands to run per domain, lint/format commands

**evolve.md** — PR creation workflow, CI validation commands, issue tracker integration for
follow-up items

**pair.md** — Preferred test commands for quick changes, lint/format requirements,
commit message conventions for small fixes

## Step 4: Scaffold the .vine/README.md Orientation Doc

Write `.vine/README.md` from the shipped template at
`${CLAUDE_SKILL_DIR}/templates/vine-readme.md.tmpl` (same path-resolution fallbacks as the
Step 3 template), filling `[Project Name]`. It's a tracked,
human/agent-facing doc that orients anyone opening this repo on how to *use* VINE inside it —
distinct from the overlays: overlays configure VINE's behavior; this README explains it.

**Fresh repos:** write the file. **Upgrade mode** (existing `.vine/context/`): don't write it
here — Step 8 offers it, declinable. Either way, Step 6 keeps `.vine/README.md` tracked even when
the rest of `.vine/` is gitignored.

## Step 5: Create Projects Directory

Create `.vine/projects/` — the directory where all VINE project artifacts live. This keeps
project state (CONTEXT.md, SPEC.md, NAVIGATION.md, etc.) separate from configuration
(context/, PROFILE.md). All VINE phases read and write project artifacts under this directory.
Write a `.gitkeep` inside so the directory survives commits and clones — git doesn't track
empty directories, and the first `vine:verify` may be days away.

## Step 6: Gitignore

VINE tracks its shared working state by default — context overlays, knowledge records, and
feature projects are repo artifacts meant to travel with the project (work-in-public). Only
*personal* and *ephemeral* state stays out of git: the personal root `.vine.local/` (your
profile, personal overlays, local-only projects, pause state) and the active-session sentinel
`.vine/ACTIVE`.

The target end-state is these two lines:

```
.vine.local/
.vine/ACTIVE
```

That's the whole rule — no per-file negations, no `!.vine/README.md` exception (the README is
tracked because `.vine/` is). Reconcile whatever's already in `.gitignore` toward that
end-state:

- **No `.vine` rules yet:** add the two lines.
- **Legacy ignore-by-default model detected:** don't flip it here — Step 8's Track-by-Default
  Migration owns that offer (personal files must relocate into `.vine.local/` *before* the
  flip, so nothing personal leaks into the tracked tree).

A project you'd rather keep off the shared tree lives under `.vine.local/projects/` (vine:verify
offers this at creation), so the single `.vine.local/` rule covers it with no per-project entries.

## Step 7: Introduce Engineer Profile

After generating overlays, briefly mention the engineer profile to the engineer:

> "VINE can track your familiarity with different areas of this codebase so it adjusts
> explanation depth — more detail in unfamiliar domains, more concise where you're confident.
> This builds organically: the first time you run `/vine:verify` in a new domain, you'll be
> asked to rate your familiarity. No setup needed now."

Do **not** ask any domain rating questions here. The profile seeds itself through vine:verify
as the engineer works in different domains. This step is purely informational.

If `PROFILE.md` already exists at the resolved shared personal root (**Resolving the personal
root** in the plugin protocol — `<personal-root>/.vine.local/PROFILE.md`), e.g. from a previous
init or manual creation, skip this message entirely.

## Step 8: Migrations and Cleanups (trigger-gated)

Everything in this step fires only on its trigger. **Evaluate the trigger table first; skip
every subsection whose trigger doesn't match.** On a fresh repo, only the last two rows can
possibly fire (a CLAUDE.md or an old npx install can predate VINE) — check those two triggers
and move straight to Output.

| # | Trigger | Offer | Subsection |
|---|---------|-------|------------|
| 1 | Legacy pre-0.4 overlay directory exists and `.vine/context/` doesn't | One-time directory rename | Legacy Directory Migration |
| 2 | `.gitignore` carries the old ignore-by-default model (`.vine/*` + `!.vine/README.md`, or a deny-then-allowlist block re-admitting subdirs) | Relocate personal files, then flip to track-by-default | Track-by-Default Migration |
| 3 | `.vine/context/` existed **before this run** (a previous init — not the directory Step 3 just created) | Upgrade mode: re-discover, diff, merge | Upgrade Mode |
| 4 | Existing `shared.md` embeds framework-machinery sections (pre-protocol install) | Single-home the machinery into the plugin protocol | Machinery Single-Homing |
| 5 | `CLAUDE.md` and `shared.md` duplicate content | Single-home per the Knowledge Boundary rule | Knowledge Boundary Dedup |
| 6 | Resolved-but-unarchived projects exist in either root | Batch archive | Archive Legacy Resolved Projects |
| 7 | `CLAUDE.md` exists with a missing or incomplete VINE pointer | Add/complete the pointer block | CLAUDE.md VINE Pointer |
| 8 | `.claude/commands/vine/` exists | Remove the legacy npx install | Legacy npx-Install Cleanup |

Row order is execution order — row 1 must run before anything else (it decides which directory
the rest of the step reads), and row 2's relocation must precede any gitignore flip.

**Standard declinable offer.** Every offer in this step is one `AskUserQuestion`
(`multiSelect: false`, 2 options): the action first, labeled "…(Recommended)" with a one-line
description, then **"Not now"** — description: "nothing changes on disk". **Declining any offer
is a strict no-op** — nothing on disk changes, and the offer reappears on the next
`/vine:init`. Variations (extra options, extra decline semantics) are called out inline.

### Legacy Directory Migration

If `.vine/hooks/` exists and `.vine/context/` does **not**, this is a pre-0.4 install. Offer
**"Migrate to .vine/context/ (Recommended)"** — "One-time directory rename; file contents
unchanged".

**If the engineer accepts:**

1. Move the directory: `git mv .vine/hooks .vine/context` if the overlay files are tracked,
   plain `mv .vine/hooks .vine/context` otherwise.
2. **Gitignore caveat**: update any `.gitignore` patterns referencing `.vine/hooks` (most
   commonly a `!.vine/hooks/` negation) to `.vine/context` in the same commit as the move — if
   the negation lags the rename, the tracked overlay files silently fall out of the index.
3. Run the rest of this step against the new `.vine/context/` path.

**If the engineer declines:** commands keep working through the legacy fallback (with a
once-per-session migration nudge). Run the rest of this step against the existing
`.vine/hooks/` files.

If both directories exist, `.vine/context/` is canonical (commands read it first) — point out
the leftover directory to the engineer instead of guessing which one they meant to keep.

### Track-by-Default Migration

Offer **"Migrate to track-by-default (Recommended)"** — "Relocate personal files into
`.vine.local/`, then flip `.gitignore` to the two-line end-state".

**If the engineer accepts**, relocate *before* flipping so nothing personal lands in the tracked
tree:

1. Move personal/ephemeral files to the personal root (all gitignored today, so plain `mv`;
   create `.vine.local/` subdirs as needed):
   - `.vine/context/*.local.md` → `.vine.local/context/<name>.md` (drop the `.local` suffix)
   - `.vine/PROFILE.md` → `.vine.local/PROFILE.md`
   - each `.vine/projects/<d>/<f>/PAUSE.md` → `.vine.local/projects/<d>/<f>/PAUSE.md`
   - `.vine/ACTIVE` does **not** move — it's per-worktree by checkout and stays at `.vine/ACTIVE`
2. Replace the old `.vine` ignore rules with the Step 6 end-state (`.vine.local/` + `.vine/ACTIVE`).
3. Verify with `git status` that every previously-tracked `.vine/` artifact is still tracked and
   nothing personal is newly staged; `git check-ignore` should report `.vine.local/` and
   `.vine/ACTIVE` ignored, the rest of `.vine/` tracked.

### Upgrade Mode

When `.vine/context/` already exists (from a previous `/vine:init` or manual setup), never
overwrite — run in upgrade mode:

1. Read all existing overlay files
2. Re-run repo discovery to find new tools, agents, commands, or conventions added since
   the last init
3. If `shared.md` lacks a "Validation" section, offer the structured block populated from
   discovery — declining leaves prose inference in place
4. Present a diff of what's new vs what's already in the overlays using `AskUserQuestion`:
   new tools/agents not yet in overlays, overlay entries referencing tools no longer present,
   convention changes detected
5. Merge accepted changes into existing overlay files — don't overwrite custom content the
   engineer has added
6. If `.vine/README.md` is missing, offer **"Add .vine/README.md (Recommended)"** — "Write the
   orientation doc from the shipped template". If it already exists, skip silently. When
   writing it, also apply the Step 6 gitignore check so the new file is tracked.

This makes upgrading after installing new skills, agents, or commands a one-command operation.

### Machinery Single-Homing

Pre-protocol installs embedded the framework machinery in every generated `shared.md`:
"Overlay Loading Protocol", "Overlay Precedence", "Project Directory Convention",
"Collaboration Stance", "Engineer Profile Protocol", "Interaction Constraints",
"Out-of-Scope Routing", "Next-Step Suggestions". Those sections now ship with the plugin
(`${CLAUDE_PLUGIN_ROOT}/PROTOCOL.md`), so an embedded copy is a stale duplicate that skews as
the plugin evolves.

If the existing `shared.md` carries any of those sections, show a preview first — which
sections would be removed, and call out any whose text the engineer has visibly customized
(customizations are worth keeping: a repo overlay legitimately overrides protocol defaults).
Then offer **"Single-home the machinery into the plugin (Recommended)"** — "Remove the listed
stock sections; the plugin protocol now carries them". Remove only unmodified stock sections;
leave customized ones in place and note that they now *override* the protocol's version rather
than duplicate it.

### Knowledge Boundary Dedup

In upgrade mode, after the overlay diff, compare `CLAUDE.md` and `.vine/context/shared.md` for
content that violates the Knowledge Boundary rule: sections appearing near-verbatim in both
files, or a full workflow map / command inventory still homed in CLAUDE.md (the map belongs in
shared.md, maintained by `/vine:optimize`; CLAUDE.md gets the availability-gated pointer).

If no overlap, skip silently. If overlap exists, show a concrete diff preview **before**
asking — for each duplicate: which file keeps the content, the one-line pointer the other file
gets, and the exact lines removed. Then offer **"Single-home the duplicates (Recommended)"** —
"Apply the previewed moves; each old location keeps a one-line pointer". Apply exactly the
previewed moves, nothing beyond.

### Archive Legacy Resolved Projects

`vine:evolve` offers to archive a project only at the moment it resolves it — so projects
resolved before that offer existed (or where the engineer declined it) sit
resolved-but-unarchived with no command that will ever sweep them. Init closes that gap.

Scan both roots (`.vine/projects/*/*/` and `<personal-root>/.vine.local/projects/*/*/` — the
Filtering Convention) for directories containing a `.resolved` marker that are **not already
under an `.archive/` subtree**. If none, skip silently. Otherwise:

1. **Present the list** of resolved-but-unarchived projects (`<domain>/<feature-slug>`), then
   offer (3-option variant): **"Archive all N (Recommended)"** — "Move every resolved project
   under its root's `.archive/`"; **"Pick which to archive"** — "Choose a subset"; **"Not
   now"**.

2. **If the engineer picks a subset**, present the candidates via `AskUserQuestion`
   (`multiSelect: true`); when there are more than four, split across calls by domain (max 4
   options per call, per the Interaction Constraints).

3. **Move each accepted project within its own root** (`<root>` is `.vine` for a shared project,
   `.vine.local` for a local one) — `git mv` when the repo tracks the artifact so history
   follows, plain `mv` when untracked:

   ```
   mkdir -p <root>/projects/.archive/<domain>
   git mv <root>/projects/<domain>/<feature-slug> <root>/projects/.archive/<domain>/<feature-slug>
   ```

   Before moving, delete any stray `PAUSE.md` at the project's mirrored personal path — a
   resolved project's pause state is definitionally stale (consumed-once rule).
   **`.vine/knowledge/<domain>/` records are never moved** — they live outside
   `.vine/projects/` and keep their own Accepted→Superseded lifecycle.

The `git mv` renames are staged for the engineer to commit with the rest of the init changes;
never force-add a gitignored artifact. Resolved-but-unarchived is a fine terminal state.

### CLAUDE.md VINE Pointer

If `CLAUDE.md` (project root) exists, make sure it carries the **availability-gated VINE
pointer block** — the few lines that tell any session (VINE-using or not) where VINE routing
and the durable-decisions layer live. This is the *ensure-present* half at setup;
`vine:optimize` *verifies and keeps it accurate* thereafter (its CLAUDE.md-pointer check owns
the canonical template). If `CLAUDE.md` doesn't exist, skip silently — init is not a CLAUDE.md
generator.

The block:

```markdown
## VINE

This repo uses VINE. If vine commands are available in this session and `.vine/projects/`
has active features, suggest the matching phase — routing details in
`.vine/context/shared.md`. Durable design decisions are recorded as committed ADR records
under `.vine/knowledge/<domain>/`.
```

- **If the block is missing entirely**, offer **"Add the VINE pointer (Recommended)"** —
  "Write the availability-gated block to CLAUDE.md".
- **If a `## VINE` block exists but lacks the durable-decisions line**, offer to add just that
  line — don't rewrite the rest.
- **If both are present and accurate**, skip silently.

Never expand the block into a workflow map or command inventory — it stays a pointer (the
Knowledge Boundary rule). CLAUDE.md is an ordinary tracked repo file, so an accepted edit is
committed normally with the other init changes.

### Legacy npx-Install Cleanup

Pre-plugin VINE installed via `npx create-vine`, copying command files into
`.claude/commands/vine/`. The plugin now provides every `/vine:` phase, so that directory is a
stale (non-colliding) duplicate. When it exists (a directory of command `*.md` files, or a
symlink to one), offer **"Remove the legacy npx install (Recommended)"** — "Deletes
`.claude/commands/vine/` — the plugin already provides every `/vine:` phase".

**If the engineer accepts:** `git rm -r .claude/commands/vine` when it's tracked (staged for
the engineer to commit with the rest of the init changes), plain `rm -rf` when it isn't. If
it's a symlink, remove the link, never its target.

> The journal-before-commit hook is not scaffolded here — it ships **with the plugin** (the
> bundled journal-check hook, PreToolUse on Bash) and is active automatically for every plugin
> user.

## Output

Print only the lines that apply to what this run actually did:

```
---
✅ vine:init complete
📁 Created:
   - .vine/context/shared.md (repo-specific — framework rules ship with the plugin)
   - .vine/context/<phase>.md (only where phase-specific content existed)
   - .vine/README.md (orientation doc — tracked; offered, not written, in upgrade mode)
   - .vine/projects/ (project artifacts directory)
   - .claude/commands/vine/ removed (if the legacy npx-install cleanup was accepted)

📋 Next step: Run `/vine:verify` to start your first feature.
   Your context overlays will be loaded automatically.

📌 The scaffolding above is created but not committed — commit it when you're ready
   (`git add .vine .gitignore` + a commit), or let your first verify cycle sweep it
   into the artifact commit.

👤 Your engineer profile (.vine.local/PROFILE.md) will build as you work —
   each new domain prompts a quick familiarity check during verify.

💡 Tip: As you complete VINE cycles, `/vine:evolve` will suggest
   updates to your overlay files and profile based on what you learn.

🔧 Run `/vine:optimize` to analyze your skills and commands for
   better matching, workflow chains, and token efficiency.
---
```
