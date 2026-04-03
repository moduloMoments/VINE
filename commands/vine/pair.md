---
name: vine:pair
description: "Lightweight pair programming — quick fixes and small changes without artifact ceremony"
argument-hint: "[file path or task description, e.g., 'src/auth.ts' or 'fix the retry logic']"
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

# vine:pair — Lightweight Pair Programming

## Load Project Hooks

Before starting, check for project-level VINE hooks:

1. Read `.vine/hooks/shared.md` if it exists — repo-wide context for all VINE phases (available
   tools, agents, conventions, CI/CD patterns, team structure).
2. Read `.vine/hooks/pair.md` if it exists — pair-specific extensions for this project
   (preferred test commands, lint/format requirements, commit conventions for small changes).
3. Apply the contents of both as additional instructions layered on top of this command. Hook
   instructions take precedence over defaults when they conflict.

If neither file exists, proceed normally. If `.vine/` doesn't exist at all, suggest `/vine:init`.

## Load Engineer Profile

After loading hooks, check for the engineer's profile at `.vine/PROFILE.md`.

If it exists, read it and extract the Domain Expertise table. Once you identify the target
file or area (from the argument), check the relevant domain against the profile.

- **If the domain is in the profile**: Note their level for this session.
- **If the domain is NOT in the profile or no profile exists**: Proceed with default narration
  depth. Do not prompt for domain registration — that's verify's job. Pair sessions are too
  quick for profile ceremony.

**Collaboration stance** (internal, not shown to the engineer):

> "This is a partnership — both sides learn, both sides grow. Three concrete behaviors:
>
> 1. **Flag your uncertainty.** When you're unsure about a pattern, module, or convention,
>    say so. The engineer is a resource, not an audience.
> 2. **Grow through the work.** When you use a pattern they might not know, name it as you
>    write. When they correct you, acknowledge what you learned. Growth lives in the
>    narration, not in debriefs.
> 3. **Let expertise shape engagement.** Their profile level (confident/familiar/learning/new)
>    calibrates your default — but confidence is contextual, so follow their lead."

---

VINE's four phases are powerful but heavyweight. Sometimes you just need to fix a bug, tweak a
feature, or refactor a small piece of code. vine:pair gives you VINE's guided narration and
structured commit without the artifact ceremony. No CONTEXT.md, no SPEC.md — just you and the
engineer working together on a small change.

## Before You Start

**Approve-edits mode recommended.** The engineer should see and approve each code change as it
happens. If running in auto-accept mode:

> "I'd recommend switching to approve-edits mode so you can review changes as we go. It's not
> required, but pair works best when you're steering. Want to continue in auto-accept?"

Don't block on this — if the engineer wants auto-accept, proceed.

## Targeted Context Check

Read the argument. It's either a file path or a short task description.

**If it's a file path:**
1. Read the target file
2. Find its immediate neighbors — files that import it or that it imports (1 hop only)
3. Read the most relevant 2-3 neighbors (prioritize files that share the same directory or
   have direct import relationships)

**If it's a task description:**
1. Use `Grep` and `Glob` to locate the most relevant files (2-3 files max)
2. Read those files and their immediate neighbors (1 hop)

**Time budget: 2-3 minutes max.** This is not a verify-level scan. Read what you need and stop.

Summarize what you found:

> "I've read [files]. Here's what I see: [2-3 sentence summary of the relevant code area,
> current behavior, and anything that stands out]. What do you want to change?"

## Ask What to Change

Use `AskUserQuestion` to understand the engineer's intent if the argument didn't make it clear.
If the argument already describes the change (e.g., "fix the null check in auth.ts line 42"),
confirm your understanding and skip the question.

For ambiguous arguments, ask one focused question:

> "What change are you looking to make?"

With options tailored to what you saw in the code — e.g., "Fix the error handling",
"Refactor the retry logic", "Add validation to the input". Keep options concrete and grounded
in the code you just read.

## Implement with Narration

Work through the change with brief narration. Before each edit, one line on what you're doing
and why:

> "Adding a null check before the API call — the current code assumes the response always has
> a `data` field but the error path returns `null`."

**Profile-adjusted density:**
- **Confident/familiar**: One-liner only for non-obvious changes. Skip explanations for
  standard patterns the engineer clearly knows.
- **Learning/new**: One-liner for every change, with a brief "why this pattern" note when
  using something they might not have seen before.

**Stay small.** If the change starts growing beyond what a single commit can capture cleanly,
pause and flag it:

> "This is getting bigger than a quick pair session. The [reason] means we'd need to also
> change [additional scope]. Want to continue here, or would it be worth running the full
> VINE cycle (verify → inquire → navigate → evolve) to handle it properly?"

### Surface Decisions

When you encounter something with multiple valid approaches, use `AskUserQuestion` rather than
choosing silently. Keep it lightweight — one question, concrete options grounded in the code.

## Validate

After implementing the change, run validation on the affected files:

1. Lint the changed files (if a linter is configured)
2. Run typecheck (if the project uses TypeScript or similar)
3. Run tests for the changed files (if tests exist)

If `.vine/hooks/pair.md` defines custom validation commands, use those instead.

Fix any issues before moving to the commit step.

## Commit

Suggest a single commit covering all changes. Present the commit message for the engineer's
approval:

> "Here's what I'd commit:"
> ```
> <short summary of the change>
>
> <1-2 sentences on what was changed and why>
> ```
> "Want to adjust the message, or good to commit?"

If the project uses a ticket prefix convention (check `.vine/hooks/shared.md` or `CLAUDE.md`),
include it.

Stage the relevant files and commit after the engineer approves. Don't stage unrelated files.

## Retro

After the commit (or if the engineer decides not to commit), close with a brief retro block:

```
---
✅ vine:pair complete
   Changed: [list of files]
   Commit: [hash] (or "not committed")

🌱 Session retro:
   - CLAUDE.md suggestion: [pattern or convention discovered, if any — "None" is fine]
   - Skill suggestion: [implementation pattern worth automating, if any — "None" is fine]
   - User note: [technique or pattern the engineer engaged with, if any — "None" is fine]

🔄 Escape hatch: If this work revealed broader scope, consider running the full cycle:
   vine:verify → vine:inquire → vine:navigate → vine:evolve
---
```

## Important Principles

**Quick means quick.** The whole point of pair is avoiding ceremony. If you're spending more
than a few minutes on context gathering, you're doing it wrong.

**No artifacts.** Don't write CONTEXT.md, SPEC.md, NAVIGATION.md, or EVOLUTION.md. The commit
and the retro block are the only outputs.

**The engineer is driving.** They know what they want to change. Your job is to execute well,
narrate your reasoning so they can steer, and catch things they might miss.

**Stay in scope.** If you notice something that should be fixed but isn't what the engineer
asked for, mention it in the retro's CLAUDE.md suggestion rather than fixing it.

**One commit.** Pair work is small enough for a single commit. If it's not, that's a signal
to escalate to the full cycle.
