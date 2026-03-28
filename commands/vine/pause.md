---
name: vine:pause
description: "Pause a VINE session — capture where you stopped and why"
argument-hint: "[feature path, e.g., 'payments/webhook-support']"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
  - AskUserQuestion
---

# vine:pause — Pause a VINE Session

## Load Project Hooks

Before starting, check for project-level VINE hooks:

1. Read `.vine/hooks/shared.md` if it exists — repo-wide context for all VINE phases (available
   tools, agents, conventions, CI/CD patterns, team structure).
2. Read `.vine/hooks/pause.md` if it exists — pause-specific extensions for this project.
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

You're stopping work on a feature and want to pick it up later — possibly in a different
session, possibly days from now. vine:pause captures the context that existing artifacts don't
preserve: where you are right now, what you were thinking, and what to do first when you come
back.

## Identify the Feature

Scan `.vine/projects/` for feature directories. Filter out resolved projects (directories
containing a `.resolved` file) and archived projects (under `.vine/projects/.archive/`). If all
projects are resolved or archived, tell the engineer there's nothing active to pause.

If a feature path was passed as an argument, use it directly. Otherwise:

- If there's exactly one active feature, use it.
- If there are multiple active features, use `AskUserQuestion` to let the engineer pick which
  one to pause.

## Detect Current Phase

Determine the feature's current phase by checking which artifacts exist:

| Artifacts present | Phase |
|---|---|
| None | pre-verify |
| CONTEXT.md only | verify complete → ready for inquire |
| CONTEXT.md + SPEC.md | inquire complete → ready for navigate |
| CONTEXT.md + SPEC.md + NAVIGATION.md | navigate in progress or complete |
| All four (+ EVOLUTION.md) | evolve in progress or complete |

If NAVIGATION.md exists, read it to determine the active slice — look for slices with
`Status: In Progress` or slices that don't have a commit hash yet. If all slices have commits,
navigate is complete.

Present what you found:

> "You're pausing **[feature name]** in the **[phase]** phase. [If navigate: Currently on
> Slice N: Name — status.] I'll capture this in PAUSE.md so vine:resume can pick it up."

## Capture Notes

Use `AskUserQuestion` to gather the engineer's pause context. This is free-form — whatever
will help them (or someone else) pick this up later.

Ask a single question with `freeform: true`:

> "Any notes for when you come back? (What you were thinking, what to pick up first, blockers,
> or anything that won't survive a session break. Leave blank to skip.)"

## Write PAUSE.md

Write PAUSE.md to the feature directory, matching the template defined in `references/STATE.md`:

```markdown
# Paused: [Feature Name]
## Paused at: [YYYY-MM-DD HH:MM]
## Phase: [detected phase]
## Active slice: [Slice N: Name — or "N/A" if not in navigate]

### Notes
[Engineer's notes from above, or "No notes captured." if they skipped]
```

If a PAUSE.md already exists in the feature directory, overwrite it — only the most recent
pause state matters.

## Completion

```
---
✅ vine:pause complete → .vine/projects/<domain>/<feature-slug>/PAUSE.md written
   Feature: [name]
   Phase: [phase]
   Active slice: [slice or N/A]

📋 To pick up where you left off: /clear, then run /vine:resume
   Resume will read your pause state and recommend the next step.
---
```
