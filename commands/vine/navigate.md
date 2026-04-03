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

- **If the domain is in the profile**: Note their level for this session. Navigate is the
  biggest consumer of the collaboration stance — it directly shapes how you work together.
- **If the domain is NOT in the profile or no profile exists**: Proceed normally — default
  narration depth as described in the rest of this command. No prompt, no warning.

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

Also read `.vine/projects/<domain>/<feature-slug>/PROJECT-MAP.md` if it exists. If present, update the
navigate row to 🚧 with today's date. If it doesn't exist, skip — older projects won't have one.

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

Before writing any code, tell the engineer what you're about to do. Be honest about where
your confidence varies — flag areas where you're less sure about the right pattern, where
you haven't seen how this project handles something, or where the spec leaves room for
interpretation:

> "For this slice, I'm going to [approach]. The main files I'll touch are [files].
> The tricky part will be [challenge from CONTEXT.md]. [If applicable: I'm less sure
> about [specific aspect] — I haven't seen how this project handles [pattern/convention].]
> Sound right, or would you go a different direction?
>
> For this slice — want me to run with it, or walk you through it?"

The self-assessment isn't performative humility — it's an honest signal that helps the
engineer decide where to focus their attention. If you're genuinely confident about
everything, don't manufacture doubt.

**Gearing:** The engineer's answer sets the engagement level for this slice:

- **"Run with it"**: Auto-accept edits for this slice — the engineer trusts the approach
  and wants to move faster. Skip step 3b narration and step 3c review pauses. Still do
  the preview (3a), surface decisions (3d), and all of step 4 (validation, commit,
  NAVIGATION.md). **At the slice boundary (step 4 complete), revert to approve-edits
  mode** so the engineer re-engages for the next slice's preview and gear choice.
- **"Walk me through this"**: Full partnership narration per steps 3b and 3c with
  approve-edits throughout. The engineer wants to stay close to the implementation —
  either because the code is unfamiliar, the approach is novel, or they want to learn
  from the process.

Use the profile's expertise level to inform which option you recommend (confident/familiar
→ default to "run with it"; learning/new → default to "walk me through this") but the
engineer always chooses. Confidence depends on both domain expertise and the specific code
being touched.

Wait for confirmation or redirection. This is the "steering" — the engineer might say
"actually, let's use the existing helper for that" or "be careful, that module has a
circular dependency issue."

**b. Implement with narration** (skip in "run with it" mode)

As you write code, explain your reasoning for non-obvious decisions:

> "I'm using the factory pattern here because the spec calls for supporting multiple
> payment providers. This way adding a new provider is just a new class, no changes to
> the orchestration layer."

When you use a pattern the engineer might not know, name it and briefly say why it fits.
When the engineer corrects your approach, acknowledge what you learned — not just the
change you made — and capture it in NAVIGATION.md's learnings section.

This serves two purposes: the engineer can catch misunderstandings early, and they learn
patterns they might apply elsewhere. This is the "two-way" part — you're not just writing
code, you're transferring knowledge.

**c. Pause for review after each meaningful change** (skip in "run with it" mode)

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

**b. Update NAVIGATION.md**

Before committing, update the slice's entry in `.vine/projects/<domain>/<feature-slug>/NAVIGATION.md`
with the full journal record. This is a prerequisite for committing — you can't commit
without updating the journal. For each slice, capture:

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

**c. Commit the slice**

Stage the changed files (including NAVIGATION.md) and commit with this format:

```
<slice-name>: <1-2 sentence summary>

Acceptance criteria verified:
- [x] <AC from spec that passed>
- [x] <AC from spec that passed>
- [ ] <AC skipped with reason>
```

If the project uses a ticket prefix convention (e.g., `PROJ-1234`), include it. Check
`.vine/hooks/shared.md` or `CLAUDE.md` for commit message conventions.

After committing, update the slice's `**Commit**` field in NAVIGATION.md with the actual
hash.

**Important:** The engineer still reviews every code change via approve-edits before the
commit happens (unless in "run with it" mode). This isn't autonomous committing — it's
structured committing after human-reviewed, validated changes.

### 5. Handle Blockers

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

### 6. Track Deviations Immediately

When the engineer or Claude decides to deviate from the spec during a slice, update **both**
documents immediately:

- **NAVIGATION.md**: Record the deviation with rationale in the slice entry
- **SPEC.md**: Add a strikethrough or addendum to the affected section so the spec reflects
  reality. This prevents evolve from cross-referencing two documents to understand what changed.

### 7. Between Slices

After each slice is validated and committed:

1. Summarize what was built and committed
2. **If the completed slice was in "walk me through this" mode**, include a brief check-in —
   2-3 sentences of shared awareness, not a feedback form:
   > "During that slice, [what shaped the approach — e.g., your suggestion to use the
   > existing helper saved us from a circular dependency]. [What I learned or what you
   > might find useful — e.g., the adapter pattern here could work for the retry logic
   > too]."
   When the completed slice was in "run with it" mode, skip the check-in — the engineer
   already signaled they don't need the reflection.
3. Check if the next slice's assumptions still hold (sometimes building slice 1 reveals that
   slice 2 needs adjustment)
4. If the next slice is marked CONDITIONAL in the spec, evaluate whether the condition is met
5. Ask if the engineer wants to continue or pause

> "Slice 2 committed (abc1234). Before we start Slice 3 (the webhook handler), I want to
> flag that our implementation of the provider interface is slightly different from what the
> spec assumed — we added an async initialization step. This means the webhook handler will
> need to account for that. Want to adjust the plan, or should I adapt as I go?"

**If the engineer chooses to pause**, write a "Remaining Work" section to NAVIGATION.md before
stopping. This ensures the next session (or vine:resume) has structured handoff context:

```markdown
### Remaining Work
- **Incomplete slices**: [list slices not yet started or in progress, with brief status]
- **Blockers encountered**: [anything that's blocking progress, or "None"]
- **Handoff context**: [what the next session should pick up first, key decisions pending,
  anything that won't be obvious from the slice entries alone]
```

After writing Remaining Work, suggest running `vine:pause` to capture the engineer's notes:

> "NAVIGATION.md updated with remaining work. If you want to capture any personal notes
> for when you come back, run `vine:pause` before closing the session."

### 8. Between Phase Groups

If SPEC.md defines phase groups, suggest a context clear when you reach the end of a group.
This is a natural stopping point — the group's work is a coherent unit that can be reviewed
and committed independently.

**If PROJECT-MAP.md has a Milestones table** (multi-PR feature), do the following at each
phase group boundary before showing the completion block:

1. **Phase group verification** — Before suggesting a PR, run a lightweight product check
   modeled on evolve's verification. This catches gaps before code leaves the branch.

   **a. Run validation across the phase group's changes:**
   - Lint all files changed in this phase group (not just the last slice)
   - Run typecheck if the project uses one
   - Run the full test suite (not just per-file tests from slice validation)
   - If `.vine/hooks/navigate.md` defines custom validation commands, use those

   **b. Check test coverage:**
   - Review whether the phase group's slices have corresponding tests. If any slice
     introduced behavior without tests, flag it:

     > "Slice [N] added [behavior] but I don't see tests covering it. Want to add
     > tests before we PR this phase, or defer to a follow-up?"

   - Use `AskUserQuestion` if there are untested slices — let the engineer decide
     per-slice whether to add tests now or defer.

   **c. Verify acceptance criteria:**
   - Review the acceptance criteria for each slice in this phase group against the
     committed code. Present a rollup:

     > "Phase [N] acceptance criteria:
     > - [x] [criterion] — verified in [commit/file]
     > - [ ] [criterion] — not met: [reason]"

   - If any criteria are unmet, resolve them before proceeding.

   **d. Check cross-slice integration within this phase group:**
   - Do the slices work together? (imports resolve, data flows between modules, no
     broken references across slice boundaries)
   - Flag anything that looks fragile or inconsistent.

   If verification surfaces issues, fix them within the current session before moving on.
   This is lighter than evolve's full pass — no deviation review, no follow-up triage, no
   handoff prep — but thorough enough that a PR opened after this step is shippable.

   > **Cross-reference:** This verification mirrors steps a-d of evolve's Cross-Slice
   > Integration Check. If you change the verification approach here, check evolve.md's
   > product verification for consistency.

2. Update the completed phase's row in PROJECT-MAP.md — change status from `🚧 Active` to
   `✅ Shipped` (or `✅ Complete` if no PR yet).
3. Update the SPEC.md phase group header — replace the `⬜` or `🚧` marker with `✅`.
4. If there's a next phase, update its Milestones row to `🚧 Active`.
5. Suggest opening a PR for the completed phase group:

   > "Phase [N: name] is complete. This is a good point to open a PR for this work.
   > Want to open a PR now, or continue to the next phase first?"

   If the engineer opens a PR, record the PR number in PROJECT-MAP.md's Milestones table
   (the PR column for this phase row). Don't create the PR automatically — just suggest it.

**Whether or not it's a multi-PR feature**, show the phase group completion block:

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

**Respect the engineer's expertise — and flag your own gaps.** They know this codebase and
this team better than you. When they suggest a different approach, explore it seriously.
They're usually right about the organizational and historical context. When you're unsure
about a pattern or convention, say so — the engineer is a resource, not an audience.
Presenting uncertain approaches with false confidence wastes both your time.

**Small batches.** Show work frequently. A 20-line change that's reviewed and understood is
better than a 200-line change that gets rubber-stamped.

**Grow through the work.** The engineer sees patterns, approaches, and techniques through
your implementation. When you use a pattern they might not know, name it and briefly say
why it fits. When they correct you, acknowledge what you learned — not just the change you
made. Growth lives in the narration as you work, not in retrospective check-ins.

**Stay in scope.** If you notice something that should be fixed but isn't in the spec, note it
in NAVIGATION.md under "discovered items" rather than fixing it. Scope discipline is what makes
the whole system work.

## Phase Completion

When all slices are implemented (or the engineer decides to stop), run the gate check before
suggesting evolve.

### Completion Gate Check

Read NAVIGATION.md and verify each slice entry has:

- **Commit hash**: Not "pending" — every completed slice must have an actual hash
- **Validation status**: Filled in (pass or fail with resolution)
- **Acceptance criteria**: At least one criterion checked (either `[x]` or `[ ]` with reason)
- **Learnings**: Not empty — at minimum "None" is acceptable, but blank is not

If any slice has gaps, list them:

> "Before we wrap up, NAVIGATION.md has some gaps:
> - Slice 2: missing learnings
> - Slice 4: commit hash still says 'pending'
> Want me to fill these in now?"

Fix the gaps inline — update NAVIGATION.md with the engineer's input (or fill in what you
can from the commit history and conversation context). Don't proceed to the completion block
until the gate passes.

### Remaining Work

Write a "Remaining Work" section to NAVIGATION.md. Even when all slices are complete, this
section captures loose ends:

```markdown
### Remaining Work
- **Incomplete slices**: [list any unfinished slices, or "All slices complete"]
- **Blockers encountered**: [unresolved blockers, or "None"]
- **Handoff context**: [discovered items, deferred decisions, things evolve should review]
```

Update PROJECT-MAP.md (if it exists) — set the navigate row to ✅ with today's date.

Then present the completion block:

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
