---
name: vine:navigate
description: "Guided implementation — build the feature together one slice at a time"
argument-hint: "[feature path, e.g., 'payments/webhook-support']"
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

# vine:navigate — Guided Implementation

## Load Project Hooks

Before starting this phase, check for project-level VINE hooks:

1. Read `.vine/hooks/shared.md` if it exists — repo-wide context for all VINE phases (available
   tools, agents, conventions, CI/CD patterns, team structure).
2. Read `.vine/hooks/navigate.md` if it exists — navigate-specific extensions for this project
   (agents to invoke after code changes, test commands to run, lint/format requirements,
   review tools to use per domain).
3. Apply the contents of both as additional instructions layered on top of this command. Hook
   instructions take precedence over defaults when they conflict.

If neither file exists, proceed normally. If `.vine/` doesn't exist at all, suggest `/vine:init`.

## Load Engineer Profile

After loading hooks, check for the engineer's profile at `.vine/PROFILE.md`.

If it exists, read it and extract the Domain Expertise table. Once you identify the feature
directory (in "Getting Started" below), check the domain portion of the path against the
profile's domain entries.

- **If the domain is in the profile**: Set the depth hint for this session based on their level.
  Navigate is the biggest consumer of this hint — it directly affects how you narrate your
  implementation choices:
  - **confident/familiar**: Lead with what you're doing, not why. Skip pattern explanations
    the engineer already knows. Focus narration on decisions specific to this feature.
  - **learning/new**: Explain the why behind architectural choices. Name the patterns you're
    using and briefly say why they fit. Flag non-obvious tradeoffs.
- **If the domain is NOT in the profile or no profile exists**: Proceed normally — default
  narration depth as described in the rest of this command. No prompt, no warning.

**Depth hint pattern** (internal, not shown to the engineer):

> "The engineer's profile indicates they are [level] with the [domain] domain. Adjust your
> explanation depth accordingly — be concise where they're confident, explain the why behind
> decisions where they're learning or new."

## Before You Start

**VINE requires approve-edits mode.** This phase especially — the engineer needs to see and approve
every code change as it happens. If running in auto-accept, suggest switching before writing any code.
Navigate without review is just autonomous coding with extra documentation, which defeats the purpose.

You and the engineer are building a feature together. The landscape is mapped (CONTEXT.md), the
design is approved (SPEC.md) — now you're implementing it. This isn't autonomous coding. You're
navigating together: the engineer steers, you execute, and both of you learn along the way.

The key principle: **getting where you're going together, both engaged.** The engineer isn't just
watching you code. They're making decisions, catching issues you'd miss, learning patterns from
your approach, and teaching you things about the domain that make the implementation better.

## Getting Started

### 1. Load Context and Spec

Identify the feature directory under `.vine/projects/` (e.g., `.vine/projects/payments/webhook-support/`). If
there are multiple feature directories, use `AskUserQuestion` to let the engineer pick which
feature to work on. Filter out resolved projects (directories containing a `.resolved` file) and
archived projects (under `.vine/projects/.archive/`). If all projects are resolved or archived,
tell the engineer and suggest starting a new cycle with `vine:verify`.

Read `.vine/projects/<domain>/<feature-slug>/CONTEXT.md` and `.vine/projects/<domain>/<feature-slug>/SPEC.md`. If either is
missing, tell the engineer which prior phase needs to run first.

Also check for `.vine/projects/<domain>/<feature-slug>/NAVIGATION.md` — if it exists, you're resuming a
previous session. Read it to understand what's already been done and pick up where you left off.

Check if SPEC.md organizes slices into phase groups. If it does, you're working on one phase
group per session. Identify which group is next based on NAVIGATION.md progress.

Summarize your starting point:

> "We're implementing [feature]. Based on the spec, I'm picking up at [Phase N: name /
> Slice N: name]. [Brief description of what this involves]. Ready to go?"

### 2. Create a Feature Branch

Before writing any code, check the current git branch. If the engineer is on `main` (or the
repo's default branch), create a feature branch:

```
git checkout -b feature/<feature-slug>
```

Use the feature slug from the `.vine/projects/` directory path. If the engineer is already on a feature
branch, confirm it's the right one for this work:

> "You're on branch `<branch-name>`. Is this the right branch for this work, or should I
> create a new one?"

If resuming (NAVIGATION.md exists), the engineer is likely already on the right branch — verify
by checking that the commits recorded in NAVIGATION.md are in the current branch's history.

### 3. Implement One Slice at a Time

For each work slice from SPEC.md:

**a. Preview the approach**

Before writing any code, tell the engineer what you're about to do:

> "For this slice, I'm going to [approach]. The main files I'll touch are [files].
> The tricky part will be [challenge from CONTEXT.md]. Sound right, or would you go a
> different direction?"

Wait for confirmation or redirection. This is the "steering" — the engineer might say
"actually, let's use the existing helper for that" or "be careful, that module has a
circular dependency issue."

**b. Implement with narration**

As you write code, explain your reasoning for non-obvious decisions:

> "I'm using the factory pattern here because the spec calls for supporting multiple
> payment providers. This way adding a new provider is just a new class, no changes to
> the orchestration layer."

This serves two purposes: the engineer can catch misunderstandings early, and they learn
patterns they might apply elsewhere. This is the "two-way" part — you're not just writing
code, you're transferring knowledge.

**c. Pause for review after each meaningful change**

Don't write 500 lines and then show the result. Pause after each logical unit:

> "Here's the data access layer for the new endpoint. Before I build the service layer
> on top, want to review this? Anything you'd change?"

The engineer might have feedback, might have questions, might want to understand why you
structured something a certain way. This is learning time — for both of you.

**d. Surface decisions, don't make them silently**

When you encounter something not covered by the spec (and you will), use `AskUserQuestion`
to present the options interactively. Never print markdown option lists for the engineer to
respond to.

Key constraints for `AskUserQuestion`:
- Max 4 questions per call, max 4 options per question (auto-adds "Other")
- Use `multiSelect: false` for mutually exclusive choices (which pattern, which approach)
- Use `multiSelect: true` when batching yes/no tactical decisions together
- Put the recommended option first with "(Recommended)" appended to its label
- Use short labels (1-5 words) with descriptions for tradeoff context
- Batch related decisions into one call when possible

The engineer decides. You document each decision in NAVIGATION.md.

### 4. Validate and Commit Per Slice

Each completed slice gets validated and committed before moving to the next. This captures
iterative progress, makes the PR tell the story of the implementation, and prevents carrying
broken state forward.

**After completing a slice's code changes:**

**a. Run validation**

Run relevant checks on the changed files. The default validation sequence is:

1. Lint the changed files (if a linter is configured)
2. Run typecheck (if the project uses TypeScript or similar)
3. Run tests for the changed files (if tests exist)

If `.vine/hooks/navigate.md` defines custom validation commands, use those instead. The hook
overrides the defaults entirely — it knows this project's toolchain.

If validation fails, fix the issues within the same slice. Don't commit broken code or carry
failures to the next slice.

**b. Commit the slice**

Stage the changed files and commit with this format:

```
<slice-name>: <1-2 sentence summary>

Acceptance criteria verified:
- [x] <AC from spec that passed>
- [x] <AC from spec that passed>
- [ ] <AC skipped with reason>
```

If the project uses a ticket prefix convention (e.g., `PROJ-1234`), include it. Check
`.vine/hooks/shared.md` or `CLAUDE.md` for commit message conventions.

**c. Record in NAVIGATION.md**

Add the commit hash to the slice's entry in NAVIGATION.md so evolve can reference it.

**Important:** The engineer still reviews every code change via approve-edits before the
commit happens. This isn't autonomous committing — it's structured committing after
human-reviewed, validated changes.

### 5. Document as You Go

Update `.vine/projects/<domain>/<feature-slug>/NAVIGATION.md` incrementally throughout implementation. Don't save it for the end.

For each slice, capture:

```markdown
### Slice N: [Name] — [Status: In Progress / Complete]
**Started**: [timestamp]
**Commit**: [hash] (or "pending" if in progress)
**Approach taken**: [what you actually did]
**Deviations from spec**: [anything that changed and why — also annotated in SPEC.md]
**Validation**: [pass/fail — lint, typecheck, tests]
**Decisions made during implementation**:
  - [decision]: [rationale] (decided by: [engineer/claude])
**Acceptance criteria**:
  - [x] [AC from spec — verified]
  - [ ] [AC skipped — reason]
**Engineer feedback incorporated**: [adjustments made based on review]
**Learnings**:
  - Engineer → Claude: [context the engineer provided that shaped the code]
  - Claude → Engineer: [patterns or approaches the engineer found useful]
```

### 6. Handle Blockers

When you hit something unexpected:

**If it's a quick question**: Ask the engineer directly. They probably know the answer.

**If it's a significant blocker**: Stop, document it, and discuss:

> "I've hit a problem. The spec assumes we can call the notification service directly, but
> it's behind an internal API gateway that requires a service token we don't have in this
> environment. Three options:
> 1. Mock it for now, create a follow-up ticket
> 2. Request the token (blocks this slice)
> 3. Use the legacy direct connection (tech debt but works)
> What's your call?"

**If it reveals a spec gap**: Note it. Sometimes verify and inquire missed something. That's
normal. Make the tactical decision together and note it for vine:evolve to capture.

### 7. Track Deviations Immediately

When the engineer or Claude decides to deviate from the spec during a slice, update **both**
documents immediately:

- **NAVIGATION.md**: Record the deviation with rationale in the slice entry
- **SPEC.md**: Add a strikethrough or addendum to the affected section so the spec reflects
  reality. This prevents evolve from cross-referencing two documents to understand what changed.

### 8. Between Slices

After each slice is validated and committed:

1. Update NAVIGATION.md with the completed slice (including commit hash)
2. Summarize what was built and committed
3. Check if the next slice's assumptions still hold (sometimes building slice 1 reveals that
   slice 2 needs adjustment)
4. If the next slice is marked CONDITIONAL in the spec, evaluate whether the condition is met
5. Ask if the engineer wants to continue or pause

> "Slice 2 committed (abc1234). Before we start Slice 3 (the webhook handler), I want to
> flag that our implementation of the provider interface is slightly different from what the
> spec assumed — we added an async initialization step. This means the webhook handler will
> need to account for that. Want to adjust the plan, or should I adapt as I go?"

### 9. Between Phase Groups

If SPEC.md defines phase groups, suggest a context clear when you reach the end of a group.
This is a natural stopping point — the group's work is a coherent unit that can be reviewed
and committed independently.

```
---
✅ Phase group [N: name] complete
   Slices completed: [list]
   Commits: [hashes from this group]

🔄 Recommended: Run `/clear` before starting Phase group [N+1: name].
   This group focused on [what was built]. The next group shifts to
   [what's next]. NAVIGATION.md carries the full context forward.

📝 All slices in this group are committed and validated.
---
```

Between groups is a great time for the engineer to review the commit history and take a break.
The work so far should stand on its own.

## Important Principles

**Narrate, don't lecture.** Share your reasoning naturally as you work. The engineer doesn't
need a tutorial — they need to understand your choices so they can steer effectively.

**Respect the engineer's expertise.** They know this codebase and this team better than you.
When they suggest a different approach, explore it seriously. They're usually right about the
organizational and historical context.

**Small batches.** Show work frequently. A 20-line change that's reviewed and understood is
better than a 200-line change that gets rubber-stamped.

**The engineer is learning too.** Part of the value is that the engineer sees patterns,
approaches, and techniques through your implementation. Don't rush past the educational moments.
If you use a pattern they might not know, briefly explain why it fits here.

**Stay in scope.** If you notice something that should be fixed but isn't in the spec, note it
in NAVIGATION.md under "discovered items" rather than fixing it. Scope discipline is what makes
the whole system work.

## Phase Completion

When all slices are implemented (or the engineer decides to stop):

```
---
✅ vine:navigate complete → .vine/projects/<domain>/<feature-slug>/NAVIGATION.md updated
   Slices completed: [N of M]
   Commits: [list of commit hashes]

📋 Suggested next step: Run `vine:evolve` to verify integration and capture learnings.
   Key items for evolve:
   - [spec deviations to review]
   - [cross-slice integration to verify]
   - [discovered items to triage]

🔄 Recommended: Run `/clear` before starting vine:evolve.
   Navigate is tactical — evolve needs a reflective, evaluative headspace.
   NAVIGATION.md carries everything forward; conversation context doesn't need to.

🌱 Phase retro:
   - CLAUDE.md suggestion: [coding patterns or conventions discovered]
   - Skill suggestion: [any implementation pattern worth automating]
   - User note: [techniques or patterns the engineer engaged with most]
---
```
