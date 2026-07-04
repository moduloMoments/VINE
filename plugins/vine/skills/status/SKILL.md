---
description: "Check feature progress — see which phase you're in, what's done, what's next, and artifact status without loading full session context"
argument-hint: "[feature path, e.g., 'payments/webhook-support']"
disable-model-invocation: true
allowed-tools:
  - Read
  - Glob
  - Grep
  - AskUserQuestion
  - TaskList
---

# vine:status — Quick Progress Check

## Load Context Overlays

Read the **VINE Protocol** at `${CLAUDE_PLUGIN_ROOT}/PROTOCOL.md` first — the framework's
loading and precedence rules, personal-root resolution, the Collaboration Stance, the Engineer
Profile Protocol, Interaction Constraints, and Out-of-Scope Routing. Then read the repo
overlays `.vine/context/shared.md` and `.vine/context/status.md` if they exist and apply them
per the protocol. The status overlay carries status-specific extensions for this project.

Degrade gracefully: every overlay file is optional; if `.vine/` doesn't exist at all, suggest
`/vine:init` once and continue on defaults. If the protocol itself is unreadable, the minimums
are: overlay instructions override command defaults, and anything under `.vine.local/` resolves
at the repo's primary worktree — `dirname "$(git rev-parse --git-common-dir)"` — never cwd.

## Load Engineer Profile

Follow the Engineer Profile Protocol from the VINE Protocol. No depth hint needed — status is
a read-only display command.

---

A lightweight alternative to `/vine:resume`. Shows where a feature stands without reconstructing
full session state or recommending next steps. Useful for a quick check between sessions or
when deciding which feature to pick up.

## Identify the Feature

Scan for feature directories per the Filtering Convention (both roots,
`.archive/` subtrees filtered). Unlike the other enumerating commands, status **includes** resolved
projects — mark them as such rather than filtering them out.

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

**Fast.** Complete in seconds; counting `Complete` slice headings in NAVIGATION.md is the
deepest read. A live in-session task list may substitute via `TaskList`; in a fresh session,
derive from NAVIGATION.md instead.

**No recommendations.** Unlike resume, status doesn't suggest next steps or load PAUSE.md.
It answers "where does this stand?" and nothing more. If the engineer wants guidance, they
should run `/vine:resume <domain>/<feature-slug>`.
