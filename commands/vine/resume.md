---
name: vine:resume
description: "Resume a paused VINE session — restore full context, see where you left off and what's blocking, and jump back into the right phase"
argument-hint: "[feature path, e.g., 'payments/webhook-support']"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Edit
  - Bash
  - AskUserQuestion
  - TaskCreate
  - TaskUpdate
  - TaskList
---

# vine:resume — Resume a VINE Session

## Load Context Overlays

Before starting, check for project-level VINE context overlays:

1. Read `.vine/context/shared.md` if it exists — repo-wide context for all VINE phases (available
   tools, agents, conventions, CI/CD patterns, team structure).
2. Read `.vine/context/resume.md` if it exists — resume-specific extensions for this project.
3. Apply the contents of both as additional instructions layered on top of this command. Overlay
   instructions take precedence over defaults when they conflict.

If `.vine/context/` doesn't exist but legacy `.vine/hooks/` does, read the same files from
`.vine/hooks/` instead and nudge once per session, no more: "Heads up: this project uses the
legacy `.vine/hooks/` directory — run `/vine:init` to migrate to `.vine/context/`."

If neither file exists, proceed normally. If `.vine/` doesn't exist at all, suggest `/vine:init`.

## Load Engineer Profile

Follow the Engineer Profile Protocol and Collaboration Stance from `.vine/context/shared.md`.

---

You're picking up work on a feature after a break. vine:resume reads your pause state and
existing artifacts to tell you exactly where you are and what to do next — without you having
to re-read everything yourself.

## Identify the Feature

Scan `.vine/projects/` for feature directories. Filter out resolved projects (directories
containing a `.resolved` file) and archived projects (under `.vine/projects/.archive/`). If all
projects are resolved or archived, tell the engineer there's nothing to resume and suggest
starting a new cycle with `/vine:verify` — present the command in its own fenced code block
so it's copy-pastable.

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
exists. Emit it per the Next-Step Suggestions convention in shared.md — plain chat text, with
only the runnable `/vine:…` command line in a fenced block.

### With PAUSE.md

````
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

📋 Recommended next step: [1-2 sentence explanation of why this is the right next step]

```
/vine:[next command] <domain>/<feature-slug>
```
---
````

### PR Number Backfill

If PROJECT-MAP.md has a Milestones table and any shipped phases (✅ status) have `—` in the
PR column, prompt the engineer to fill them in:

> "These shipped phases don't have PR numbers recorded. Want to add them?"

Use `AskUserQuestion` with one question per missing PR (up to 4). For each answer, update the
PR column in PROJECT-MAP.md. This keeps the project map accurate for evolve's cross-PR review.

Skip this if no Milestones table exists or all PR numbers are already filled in.

### Without PAUSE.md (artifact-only fallback)

````
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

📋 Recommended next step: [1-2 sentence explanation of why this is the right next step]

```
/vine:[next command] <domain>/<feature-slug>
```
---
````

## Restore Session State

**Rebuild the live task view (when available).** If native task tools are available, rebuild
the in-session task list to match what `/vine:navigate` would create (see navigate's "Build the
live task view" step): `TaskCreate` one task per remaining slice in the current phase group,
titled by the slice name, `blockedBy`-ordered, skipping slices already `Complete` in
NAVIGATION.md and prefixing conditional slices `(conditional: <condition>)`. If a slice is
`In Progress` per its NAVIGATION.md status suffix, `TaskUpdate` it to `in_progress`. The
rebuilt list is a derived view — it carries no information the journal and spec don't already
hold, so resume reconstructs it identically every time. When task tools aren't available, skip
this; the status summary above is the progress view.

**Consume the pause state.** If you read and displayed a PAUSE.md, delete it now — the
consumed-once rule (see `references/STATE.md`): a lingering pause keeps re-suggesting
`/vine:resume` and re-presents stale notes on the next resume. Its notes have already been
surfaced in the summary above; anything worth keeping past this resume belongs in
NAVIGATION.md's Remaining Work, not PAUSE.md. (If no PAUSE.md was present, skip — nothing to
consume.)

## Recommend Next Step

Based on the detected phase, recommend the appropriate command:

| Phase | Recommendation |
|---|---|
| pre-verify | `/vine:verify` — start the context-building spike |
| verify complete | `/vine:inquire <domain>/<feature-slug>` — build the feature spec |
| inquire complete | `/vine:navigate <domain>/<feature-slug>` — start implementation |
| navigate in progress | `/vine:navigate <domain>/<feature-slug>` — resume implementation (it reads NAVIGATION.md) |
| navigate complete | `/vine:evolve <domain>/<feature-slug>` — verify integration and capture learnings |
| evolve in progress | `/vine:evolve <domain>/<feature-slug>` — finish the evolution report |
| evolve complete | Consider resolving the project or re-running evolve |

**Do not auto-launch the recommended command.** The engineer decides when to proceed. Resume
**creates no artifacts** — it never writes a CONTEXT/SPEC/NAVIGATION/EVOLUTION file; its job
is to *restore* context, not produce the artifact chain. It does touch ephemeral and derived
state: rebuilding the in-session task view (when task tools are available), consuming the
PAUSE.md it displays, and backfilling PR numbers into the derived PROJECT-MAP view.

**Resume is the `/clear` exception.** Unlike the phase commands, resume does *not* suggest
`/clear` before the next step. The phase commands recommend a fresh session so heavy context
flows through `.vine/` files rather than chat; resume is the opposite — it exists to rebuild
that context into the current session, so clearing would immediately discard what it just
restored. Resume is a handoff back into the work that was already running: you continue in the
same session.

## Handle Edge Cases

**Multiple features with PAUSE.md**: If more than one active feature has a PAUSE.md, show a
brief summary of each (feature name, phase, time since pause) and let the engineer pick via
`AskUserQuestion`.

**Stale pause state**: If PAUSE.md says "navigate in progress on Slice 3" but NAVIGATION.md
shows Slice 3 is complete, trust the artifacts over PAUSE.md. Note the discrepancy:

> "Your pause state says you were on Slice 3, but it looks like it was completed since then.
> Picking up at Slice 4 instead."

**No active features**: Tell the engineer and suggest `/vine:verify` to start a new cycle —
present the command in its own fenced code block so it's copy-pastable.

**Wrong branch**: If the current branch doesn't match the feature, suggest switching:

> "You're on branch `[current]` but this feature was built on `feature/[slug]`. You may want
> to switch before continuing: `git checkout feature/[slug]`"
