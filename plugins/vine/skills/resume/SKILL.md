---
description: "Resume a paused VINE session — restore full context, see where you left off and what's blocking, and jump back into the right phase"
argument-hint: "[feature path, e.g., 'payments/webhook-support']"
disable-model-invocation: true
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

Read the **VINE Protocol** at `${CLAUDE_PLUGIN_ROOT}/PROTOCOL.md` first — the framework's
loading and precedence rules, personal-root resolution, the Collaboration Stance, the Engineer
Profile Protocol, Interaction Constraints, and Out-of-Scope Routing. Then read the repo
overlays `.vine/context/shared.md` and `.vine/context/resume.md` if they exist and apply them
per the protocol. The resume overlay carries resume-specific extensions for this project.

Degrade gracefully: every overlay file is optional; if `.vine/` doesn't exist at all, suggest
`/vine:init` once and continue on defaults. If the protocol itself is unreadable, the minimums
are: overlay instructions override command defaults, and anything under `.vine.local/` resolves
at the repo's primary worktree — `dirname "$(git rev-parse --git-common-dir)"` — never cwd.

## Load Engineer Profile

Follow the Engineer Profile Protocol and Collaboration Stance from the VINE Protocol.

---

You're picking up work on a feature after a break. vine:resume reads your pause state and
existing artifacts to tell you exactly where you are and what to do next — without you having
to re-read everything yourself.

## Identify the Feature

Scan for feature directories per the Filtering Convention (both roots;
resolved and `.archive/` subtrees filtered out). If all projects are resolved or archived, tell the
engineer there's nothing to resume and suggest starting a new cycle with `/vine:verify` — present
the command in its own fenced code block so it's copy-pastable.

If a feature path was passed as an argument, use it directly. Otherwise:

- If there's exactly one active feature, use it.
- If there are multiple active features, use `AskUserQuestion` to let the engineer pick which
  one to resume.

## Gather State

Read whatever exists in the feature directory. Build your understanding in layers:

### Layer 1: PAUSE.md (if present)

Read `.vine.local/projects/<domain>/<feature-slug>/PAUSE.md` — the feature's mirrored personal
path, resolved per Resolving the personal root (VINE Protocol). Extract:
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
exists. Emit it per the Next-Step Suggestions convention in the VINE Protocol — plain chat
text, with only the runnable `/vine:…` command line in a fenced block.

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

Same block as above minus the Paused/notes lines; add "No pause state found — reconstructing
from artifacts." and, if navigate is in progress, a per-slice status list (✅ complete /
🔲 pending / ▶️ in progress).

## Restore Session State

**Rebuild the live task view (when available).** If native task tools are available, rebuild
the in-session task list to match what `/vine:navigate` would create (see navigate's "Build the
live task view" step): `TaskCreate` one task per remaining slice in the current phase group,
titled by the slice name, `blockedBy`-ordered, skipping slices already `Complete` in
NAVIGATION.md and prefixing conditional slices `(conditional: <condition>)`. If a slice is
`In Progress` per its NAVIGATION.md status suffix, `TaskUpdate` it to `in_progress`. When task
tools aren't available, skip; the status summary is the progress view.

**Consume the pause state.** If you displayed a PAUSE.md, delete it now (consumed-once rule).
Anything worth keeping belongs in NAVIGATION.md's Remaining Work. Skip if none was present.

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

**Do not auto-launch the recommended command.** Resume creates no artifacts — it only touches
ephemeral/derived state (task view, PAUSE.md consumption, PR backfill). Do not suggest
`/clear`: resume exists to rebuild context into the current session; clearing would discard it.

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
