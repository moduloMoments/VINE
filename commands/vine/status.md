---
name: vine:status
description: "Check feature progress — see which phase you're in, what's done, what's next, and artifact status without loading full session context"
argument-hint: "[feature path, e.g., 'payments/webhook-support']"
allowed-tools:
  - Read
  - Glob
  - Grep
  - AskUserQuestion
  - TaskList
---

# vine:status — Quick Progress Check

## Load Context Overlays

Before starting, check for project-level VINE context overlays:

1. Read `.vine/context/shared.md` if it exists — repo-wide context for all VINE phases.
2. Read `.vine/context/status.md` if it exists — status-specific extensions for this project.
3. Apply the contents of both as additional instructions layered on top of this command.

If `.vine/context/` doesn't exist but legacy `.vine/hooks/` does, read the same files from
`.vine/hooks/` instead and nudge once per session, no more: "Heads up: this project uses the
legacy `.vine/hooks/` directory — run `/vine:init` to migrate to `.vine/context/`."

If neither file exists, proceed normally. If `.vine/` doesn't exist at all, suggest `/vine:init`.

## Load Engineer Profile

After loading overlays, check for the engineer's profile at `.vine/PROFILE.md`.

If it exists, note it for the status display. No depth hint needed — status is a read-only
display command.

---

A lightweight alternative to `vine:resume`. Shows where a feature stands without reconstructing
full session state or recommending next steps. Useful for a quick check between sessions or
when deciding which feature to pick up.

## Identify the Feature

Scan `.vine/projects/` for feature directories. Filter out archived projects (under
`.vine/projects/.archive/`). Include resolved projects but mark them as such.

If a feature path was passed as an argument, use it directly. Otherwise:

- If there's exactly one active feature, use it.
- If there are multiple features (active or resolved), use `AskUserQuestion` to let the
  engineer pick. Show resolved projects with a "(resolved)" suffix.

## Display Progress

### With PROJECT-MAP.md

If `.vine/projects/<domain>/<feature-slug>/PROJECT-MAP.md` exists, display it directly —
it's already designed for at-a-glance scanning:

```
---
📊 [Feature Name]
   Path: .vine/projects/<domain>/<feature-slug>

   VINE Progress: verify ✅ → inquire ✅ → navigate 🚧 → evolve ⬜

[If Milestones table exists:]
   Milestones:
   | Phase | Slices | Status | PR |
   | ... | ... | ... | ... |

[If resolved:]
   ✅ Resolved
---
```

### Without PROJECT-MAP.md (artifact fallback)

If no PROJECT-MAP.md exists, detect progress from which artifacts are present:

```
---
📊 [Feature Name]
   Path: .vine/projects/<domain>/<feature-slug>

   Artifacts found:
   - CONTEXT.md ✅
   - SPEC.md ✅ ([N] slices, [M] phase groups)
   - NAVIGATION.md ✅ ([X of Y] slices complete)
   - EVOLUTION.md ⬜

[If resolved:]
   ✅ Resolved
---
```

### Multiple Features

If the engineer didn't specify a feature path and there are multiple projects, show a
compact summary of all active projects before asking which to drill into:

```
---
📊 VINE Projects

   payments/webhook-support — navigate 🚧 (4/6 slices)
   auth/sso-migration — verify ✅ → ready for inquire
   payments/retry-logic — ✅ Resolved

---
```

## Important Principles

**Read-only.** Status never writes or modifies anything. No artifact updates, no state changes.

**Fast.** This should complete in seconds. Read PROJECT-MAP.md (or detect artifacts and count
slice headings) and display — no deep content analysis, no git log archaeology. Counting
`Complete` slice headings in NAVIGATION.md is the deepest it reads. When a live task list
exists in the session (e.g., status run alongside an active navigate), status may read it via
`TaskList` for the slice count instead; in a fresh session there is no list, so it derives
`[X of Y]` from NAVIGATION.md as usual.

**No recommendations.** Unlike resume, status doesn't suggest next steps or load PAUSE.md.
It answers "where does this stand?" and nothing more. If the engineer wants guidance, they
should run `vine:resume <domain>/<feature-slug>`.
