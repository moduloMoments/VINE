---
name: vine:pause
description: "Pause a VINE session — save progress, capture current state and blockers so you can pick up exactly where you left off later"
argument-hint: "[feature path, e.g., 'payments/webhook-support']"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
  - Bash
  - AskUserQuestion
---

# vine:pause — Pause a VINE Session

## Load Context Overlays

Read `.vine/context/shared.md` and `.vine/context/pause.md` if they exist, then follow the
**Overlay Loading Protocol** from `shared.md` for the rest (apply-as-overlay precedence, the
personal `.local` layer, the legacy-directory fallback, and missing-file behavior). The pause
overlay carries pause-specific extensions for this project. If `shared.md` is absent, degrade
gracefully: read the phase overlay if present, otherwise proceed on command defaults.

## Load Engineer Profile

Follow the Engineer Profile Protocol and Collaboration Stance from `.vine/context/shared.md`.

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
  one to pause. <!-- decision-class: default-able -->

## Detect Current Phase

First check `.vine/projects/<domain>/<feature-slug>/PROJECT-MAP.md` — if it exists, read the VINE
Progress table for the current phase (the row with 🚧 status). This is the most reliable source.

If no PROJECT-MAP.md exists, fall back to determining the phase from which artifacts exist:

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

<!-- decision-class: human-required -->
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

## Clear the Active-Session Sentinel

If `.vine/ACTIVE` exists at the repo root, delete it. The sentinel marks an active navigate
session (format and lifecycle in `references/STATE.md`); pausing ends the session, and a
lingering sentinel keeps installed hooks firing against work that's no longer active. If the
file doesn't exist, skip silently — pausing from a non-navigate phase is normal.

## Completion

```
---
✅ vine:pause complete → .vine/projects/<domain>/<feature-slug>/PAUSE.md written
   Feature: [name]
   Phase: [phase]
   Active slice: [slice or N/A]

📋 To pick up where you left off: /clear, then run /vine:resume <domain>/<feature-slug>
   Resume will read your pause state and recommend the next step.
---
```
