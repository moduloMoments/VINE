---
description: "Lightweight pair programming — quick fixes and small changes without artifact ceremony"
argument-hint: "[file path or task description, e.g., 'src/auth.ts' or 'fix the retry logic']"
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

# vine:pair — Lightweight Pair Programming

## Load Context Overlays

Read the **VINE Protocol** at `${CLAUDE_PLUGIN_ROOT}/PROTOCOL.md` first — the framework's
loading and precedence rules, personal-root resolution, the Collaboration Stance, the Engineer
Profile Protocol, Interaction Constraints, and Out-of-Scope Routing. Then read the repo
overlays `.vine/context/shared.md` and `.vine/context/pair.md` if they exist and apply them
per the protocol. The pair overlay carries pair-specific extensions for this project
(preferred test commands, lint/format requirements, commit conventions for small changes).

Degrade gracefully: every overlay file is optional; if `.vine/` doesn't exist at all, suggest
`/vine:init` once and continue on defaults. If the protocol itself is unreadable, the minimums
are: overlay instructions override command defaults, and anything under `.vine.local/` resolves
at the repo's primary worktree — `dirname "$(git rev-parse --git-common-dir)"` — never cwd.

## Load Engineer Profile

Follow the Engineer Profile Protocol and Collaboration Stance from the VINE Protocol. Do not prompt
for domain registration — that's verify's job. Pair sessions are too quick for profile ceremony.

---

Quick fixes and small changes without artifact ceremony — no CONTEXT.md, no SPEC.md; the
commit and retro block are the only outputs.

## Before You Start

**Ask permissions mode recommended.** The engineer should see and approve each code change as it
happens. If running in Accept edits mode:

> "I'd recommend switching to Ask permissions mode so you can review changes as we go. It's not
> required, but pair works best when you're steering. Want to continue in Accept edits?"

Don't block on this — if the engineer wants Accept edits, proceed.

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

Calibrate narration density per the Engineer Profile Protocol — one-liner per change with
"why this pattern" notes for learning/new; one-liner only for non-obvious changes for
confident/familiar.

**Stay small.** If the change starts growing beyond what a single commit can capture cleanly,
pause and flag it:

> "This is getting bigger than a quick pair session. The [reason] means we'd need to also
> change [additional scope]. Want to continue here, or would it be worth running the full
> VINE cycle (verify → inquire → navigate → evolve) to handle it properly?"

### Surface Decisions

When you encounter something with multiple valid approaches, use `AskUserQuestion` rather than
choosing silently. Keep it lightweight — one question, concrete options grounded in the code.

## Validate

After implementing the change, delegate to the `vine-verification` agent to run checks on the
affected files (lint, typecheck, tests) — the agent reads the `## Validation` block in
`.vine/context/shared.md` (prose-inference fallback when absent). If `.vine/context/pair.md`
defines custom validation commands, pass those to the agent instead.

**Wait for the report.** Verification is a gate, so the next step needs its result. If the
agent is still running in the background, end your turn and continue here when its report
arrives. A report that doesn't list the commands it ran with their exit codes counts as
not verified.

Fix any issues before moving to the commit step.

## Commit

Suggest a single commit covering all changes. Show the proposed commit message, then use
`AskUserQuestion` to confirm:

- Use `multiSelect: false` with 3 options:
  - "Commit as drafted (Recommended)" — with the commit message as the description
  - "Edit message" — "I'll help adjust the wording"
  - "Skip commit" — "Don't commit yet, I'll handle it"

If the project uses a ticket prefix convention (check `.vine/context/shared.md` or `CLAUDE.md`),
include it in the drafted message.

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

**The engineer is driving.** They know what they want to change. Your job is to execute well,
narrate your reasoning so they can steer, and catch things they might miss.

**Stay in scope.** If you notice something that should be fixed but isn't what the engineer
asked for, mention it in the retro's CLAUDE.md suggestion rather than fixing it.
