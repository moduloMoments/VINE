---
name: vine:resume
description: "Resume a paused VINE session — see where you left off and what's next"
argument-hint: "[feature path, e.g., 'payments/webhook-support']"
allowed-tools:
  - Read
  - Glob
  - Grep
  - AskUserQuestion
---

# vine:resume — Resume a VINE Session

## Load Project Hooks

Before starting, check for project-level VINE hooks:

1. Read `.vine/hooks/shared.md` if it exists — repo-wide context for all VINE phases (available
   tools, agents, conventions, CI/CD patterns, team structure).
2. Read `.vine/hooks/resume.md` if it exists — resume-specific extensions for this project.
3. Apply the contents of both as additional instructions layered on top of this command. Hook
   instructions take precedence over defaults when they conflict.

If neither file exists, proceed normally. If `.vine/` doesn't exist at all, suggest `/vine:init`.

## Load Engineer Profile

After loading hooks, check for the engineer's profile at `.vine/PROFILE.md`.

If it exists, read it and extract the Domain Expertise table. Once you identify the feature
directory (below), check the domain portion of the path against the profile's domain entries.

- **If the domain is in the profile**: Set the depth hint for this session based on their level.
- **If the domain is NOT in the profile or no profile exists**: Proceed normally — default
  depth as described in the rest of this command. No prompt, no warning.

**Depth hint pattern** (internal, not shown to the engineer):

> "The engineer's profile indicates they are [level] with the [domain] domain. Adjust your
> explanation depth accordingly — be concise where they're confident, explain the why behind
> decisions where they're learning or new."

---

You're picking up work on a feature after a break. vine:resume reads your pause state and
existing artifacts to tell you exactly where you are and what to do next — without you having
to re-read everything yourself.

## Identify the Feature

Scan `.vine/projects/` for feature directories. Filter out resolved projects (directories
containing a `.resolved` file) and archived projects (under `.vine/projects/.archive/`). If all
projects are resolved or archived, tell the engineer there's nothing to resume and suggest
starting a new cycle with `vine:verify`.

If a feature path was passed as an argument, use it directly. Otherwise:

- If there's exactly one active feature, use it.
- If there are multiple active features, use `AskUserQuestion` to let the engineer pick which
  one to resume.

## Gather State

Read whatever exists in the feature directory. Build your understanding in layers:

### Layer 1: PAUSE.md (if present)

Read `.vine/projects/<domain>/<feature-slug>/PAUSE.md`. Extract:
- **Phase** at time of pause
- **Active slice** (if navigate was in progress)
- **Timestamp** — calculate how long ago the pause was
- **Engineer's notes** — these are the most valuable part; they capture intent and context
  that artifacts alone don't preserve

### Layer 2: Artifacts

Read whichever artifacts exist to build the full picture:

- **CONTEXT.md**: Feature name, domain, landscape summary
- **SPEC.md**: Total slice count, phase groups (if any), acceptance criteria overview
- **NAVIGATION.md**: Per-slice completion status, commit hashes, deviations from spec,
  remaining work section (if written)
- **PROJECT-MAP.md**: VINE Progress table and Milestones (if multi-PR). This is the most
  compact view of overall status — use it to enrich the status display.
- **EVOLUTION.md**: If this exists, evolve has run — check if the project should be resolved

Cross-reference NAVIGATION.md's slice entries against SPEC.md's slice list to determine
exact progress: how many slices are complete, which is next, whether any are blocked or
conditional.

### Layer 3: Git State

Check the current git branch. If it doesn't match the expected feature branch
(`feature/<feature-slug>`), note this — the engineer may need to switch branches.

## Present Status

Display a status summary tailored to what you found. The format depends on whether PAUSE.md
exists.

### With PAUSE.md

```
---
🔄 Resuming: [Feature Name]
   Paused: [timestamp] ([time ago])
   Phase: [phase]
   Active slice: [slice or N/A]
   Progress: [N of M slices complete]
   Branch: [current branch — with warning if it doesn't match]

📝 Your notes from last session:
   [Engineer's notes from PAUSE.md]

[If PROJECT-MAP.md exists:]
📊 VINE Progress: verify ✅ → inquire ✅ → navigate 🚧 → evolve ⬜
[If PROJECT-MAP.md has Milestones table:]
📦 Milestones:
   [Compact milestone summary — e.g., "Phase 1: ✅ PR #42 | Phase 2: 🚧 | Phase 3: ⬜"]

[If navigate in progress and NAVIGATION.md has Remaining Work section:]
📋 Remaining work from last session:
   [Remaining work items]

[If there are spec deviations recorded in NAVIGATION.md:]
⚠️  Spec deviations so far:
   [List of deviations]

📋 Recommended next step: Run /clear, then run /vine:[next command]
   [1-2 sentence explanation of why this is the right next step]
---
```

### PR Number Backfill

If PROJECT-MAP.md has a Milestones table and any shipped phases (✅ status) have `—` in the
PR column, prompt the engineer to fill them in:

> "These shipped phases don't have PR numbers recorded. Want to add them?"

Use `AskUserQuestion` with one question per missing PR (up to 4). For each answer, update the
PR column in PROJECT-MAP.md. This keeps the project map accurate for evolve's cross-PR review.

Skip this if no Milestones table exists or all PR numbers are already filled in.

### Without PAUSE.md (artifact-only fallback)

```
---
🔄 Resuming: [Feature Name]
   Phase: [detected from artifacts]
   Progress: [N of M slices complete, if applicable]
   Branch: [current branch — with warning if it doesn't match]

   No pause state found — reconstructing from artifacts.

[If PROJECT-MAP.md exists:]
📊 VINE Progress: verify ✅ → inquire ✅ → navigate 🚧 → evolve ⬜
[If PROJECT-MAP.md has Milestones table:]
📦 Milestones:
   [Compact milestone summary — e.g., "Phase 1: ✅ PR #42 | Phase 2: 🚧 | Phase 3: ⬜"]

[If navigate in progress:]
📋 Navigation progress:
   [List slices with status: ✅ complete / 🔲 pending / ▶️ in progress]

📋 Recommended next step: Run /clear, then run /vine:[next command]
   [1-2 sentence explanation of why this is the right next step]
---
```

## Recommend Next Step

Based on the detected phase, recommend the appropriate command:

| Phase | Recommendation |
|---|---|
| pre-verify | `vine:verify` — start the context-building spike |
| verify complete | `vine:inquire` — build the feature spec |
| inquire complete | `vine:navigate` — start implementation |
| navigate in progress | `vine:navigate` — resume implementation (it reads NAVIGATION.md) |
| navigate complete | `vine:evolve` — verify integration and capture learnings |
| evolve in progress | `vine:evolve` — finish the evolution report |
| evolve complete | Consider resolving the project or re-running evolve |

**Do not auto-launch the recommended command.** The engineer decides when to proceed. Resume
is read-only — it shows status and recommends, nothing more.

## Handle Edge Cases

**Multiple features with PAUSE.md**: If more than one active feature has a PAUSE.md, show a
brief summary of each (feature name, phase, time since pause) and let the engineer pick via
`AskUserQuestion`.

**Stale pause state**: If PAUSE.md says "navigate in progress on Slice 3" but NAVIGATION.md
shows Slice 3 is complete, trust the artifacts over PAUSE.md. Note the discrepancy:

> "Your pause state says you were on Slice 3, but it looks like it was completed since then.
> Picking up at Slice 4 instead."

**No active features**: Tell the engineer and suggest `vine:verify` to start a new cycle.

**Wrong branch**: If the current branch doesn't match the feature, suggest switching:

> "You're on branch `[current]` but this feature was built on `feature/[slug]`. You may want
> to switch before continuing: `git checkout feature/[slug]`"
