---
name: vine:navigate
description: "Implement a feature slice by slice — write code together, run tests, review changes, and commit each validated slice with its acceptance criteria"
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
  - TaskCreate
  - TaskUpdate
  - TaskList
---

# vine:navigate — Guided Implementation

## Load Context Overlays

Before starting this phase, check for project-level VINE context overlays:

1. Read `.vine/context/shared.md` if it exists — repo-wide context for all VINE phases (available
   tools, agents, conventions, CI/CD patterns, team structure).
2. Read `.vine/context/navigate.md` if it exists — navigate-specific extensions for this project
   (agents to invoke after code changes, test commands to run, lint/format requirements,
   review tools to use per domain).
3. Apply the contents of both as additional instructions layered on top of this command. Overlay
   instructions take precedence over defaults when they conflict.

If `.vine/context/` doesn't exist but legacy `.vine/hooks/` does, read the same files from
`.vine/hooks/` instead and nudge once per session, no more: "Heads up: this project uses the
legacy `.vine/hooks/` directory — run `/vine:init` to migrate to `.vine/context/`."

If neither file exists, proceed normally. If `.vine/` doesn't exist at all, suggest `/vine:init`.

## Load Engineer Profile

Follow the Engineer Profile Protocol and Collaboration Stance from `.vine/context/shared.md`. Navigate is
the biggest consumer of the stance — it directly shapes how you work together on every slice.

## Before You Start

**Approve-edits mode recommended.** This phase especially — navigate works best when the engineer
sees and approves every code change as it happens. If running in auto-accept, ask before writing
any code:

> "I'd recommend approve-edits mode for navigate so you review each change as we go. It's not
> required — want to continue in auto-accept?"

Don't block on this. The mode toggle is the engineer's action: you can ask, never switch it
yourself or assume it happened. Navigate without review drifts toward autonomous coding with
extra documentation — fine if the engineer chooses it deliberately, not as a default.

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

**Mark the session active.** Write `.vine/ACTIVE` (repo root, gitignored — format in
`references/STATE.md`) before starting work:

```
feature: .vine/projects/<domain>/<feature-slug>
phase: [phase group or slice being started]
started: [YYYY-MM-DD HH:MM]
```

The sentinel is deliberately minimal — feature path, phase, timestamp, nothing else. It is
not a mini-PAUSE.md; handoff state lives in PAUSE.md. Its only job is to mark "a navigate
session is active on this feature" so installed native hooks can scope their checks to
active work. It never leaves the machine.

**Consume any pause state.** If the feature directory contains a PAUSE.md, picking the work
back up consumes it: surface its notes in your starting-point summary, then delete the file.
A consumed pause must not linger — it would keep suggesting `vine:resume` for work that has
already resumed.

**Build the live task view (when available).** If native task tools are available in this
session, create the live view of slice progress (the ephemeral, in-session mirror of the
journal — see "Source of Truth vs Derived Views" in `references/STATE.md`): `TaskCreate` one
task per remaining slice in the current phase group, titled by the slice name. (If SPEC.md
isn't grouped into phases, use every not-yet-complete slice in the feature.) Order them with
`blockedBy` so each task depends on the one before it. Skip slices already marked `Complete`
in NAVIGATION.md — they live in the journal, not the live view. For a slice marked CONDITIONAL
in the spec, prefix the task title `(conditional: <condition>)` and leave it pending; you'll
evaluate the condition on arrival (step 7) and complete or delete it then.

The task list is a derived view, never a source of truth: it mirrors NAVIGATION.md and
SPEC.md and is always rebuilt from them, never the reverse. **When task tools aren't
available, skip this and every other "(when available)" task step below** — navigate then
behaves exactly as it does without task tracking, and NAVIGATION.md remains the durable
journal regardless.

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

For each work slice from SPEC.md (when task tools are available, `TaskUpdate` this slice's
task to `in_progress` as you begin it):

**a. Preview the approach**

Before writing any code, tell the engineer what you're about to do. Be honest about where
your confidence varies — flag areas where you're less sure about the right pattern, where
you haven't seen how this project handles something, or where the spec leaves room for
interpretation:

> "For this slice, I'm going to [approach]. The main files I'll touch are [files].
> The tricky part will be [challenge from CONTEXT.md]. [If applicable: I'm less sure
> about [specific aspect] — I haven't seen how this project handles [pattern/convention].]
> Sound right, or would you go a different direction?"

The self-assessment isn't performative humility — it's an honest signal that helps the
engineer decide where to focus their attention. If you're genuinely confident about
everything, don't manufacture doubt.

After the preview, use `AskUserQuestion` for the gearing decision:

- Use `multiSelect: false` with 2 options
- Put the recommended option first based on the profile's expertise level
  (confident/familiar → "Free climb (Recommended)"; learning/new → "Walk me through this (Recommended)")
- **"Free climb"** description: "I trust the approach — move fast; I'll review the diff at the slice boundary myself (pairs with auto-accept-edits)"
- **"Walk me through this"** description: "Show me each step — I want to stay close to the implementation (pairs with approve-edits)"

**Gearing:** The engineer's choice sets the engagement level for this slice *and* the
permission mode that fits it. Recommend the matching mode — the toggle is always the
engineer's action; you can suggest it, never flip it or assume it happened:

- **"Free climb"**: The engineer trusts the approach and wants to move faster. Recommend
  **auto-accept-edits** (or full auto) for this slice so edits land without a prompt each
  time. Skip step 3b narration and step 3c review pauses. Still do the preview (3a),
  surface decisions (3d), and all of step 4 (validation, commit, NAVIGATION.md). **At the
  slice boundary (step 4 complete), ask the engineer to switch back to approve-edits** so
  they re-engage for the next slice's preview and gear choice.
- **"Walk me through this"**: Recommend **approve-edits** (per-edit permission prompts) so
  the engineer reviews each edit as it lands. Full partnership narration per steps 3b and
  3c. The engineer wants to stay close to the implementation — either because the code is
  unfamiliar, the approach is novel, or they want to learn from the process.

Use the profile's expertise level to inform which option you recommend (confident/familiar
→ default to "free climb"; learning/new → default to "walk me through this") but the
engineer always chooses. Confidence depends on both domain expertise and the specific code
being touched.

Wait for confirmation or redirection. This is the "steering" — the engineer might say
"actually, let's use the existing helper for that" or "be careful, that module has a
circular dependency issue."

**b. Implement with narration** (skip in "free climb" mode)

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

**c. Pause for review after each meaningful change** (skip in "free climb" mode)

Don't write 500 lines and then show the result. Pause after each logical unit:

> "Here's the data access layer for the new endpoint. Before I build the service layer
> on top, want to review this? Anything you'd change?"

The engineer might have feedback, might have questions, might want to understand why you
structured something a certain way. This is learning time — for both of you.

**d. Surface decisions, don't make them silently**

When you encounter something not covered by the spec (and you will), use `AskUserQuestion`
to present the options interactively. Never print markdown option lists for the engineer to
respond to.

Follow the Interaction Constraints from `.vine/context/shared.md` for every `AskUserQuestion` call.

The engineer decides. You document each decision in NAVIGATION.md.

### 4. Validate and Commit Per Slice

Each completed slice gets validated and committed before moving to the next. This captures
iterative progress, makes the PR tell the story of the implementation, and prevents carrying
broken state forward.

**After completing a slice's code changes:**

**a. Run validation**

Delegate to the `vine-verification` agent to run checks on the changed files and verify
acceptance criteria for this slice. The agent runs lint, typecheck, and tests, then checks
each criterion against the code and reports findings.

If `.vine/context/navigate.md` defines custom validation commands, pass those to the agent.
The overlay overrides the defaults entirely — it knows this project's toolchain.

If validation fails, fix the issues within the same slice. Don't commit broken code or carry
failures to the next slice.

**b. Update NAVIGATION.md**

Before committing, update the slice's entry in `.vine/projects/<domain>/<feature-slug>/NAVIGATION.md`
with the full journal record. This is a prerequisite for committing — update the journal
first, every time. It's mechanically enforced when the scaffold hooks are installed:
`journal-check.sh` blocks `git commit` while NAVIGATION.md is older than the last commit
(see `references/STATE.md`). Without the scaffold, honoring the ordering is on you — never
stronger than that. For each slice, capture:

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

The slice-heading shape and field labels above are the NAVIGATION.md template from
`references/STATE.md`. Use them verbatim: keep the `Slice N:` prefix, the literal
`In Progress` / `Complete` status words (pause matches on them), and the field labels as
written. Resume, pause, and artifact-format validation locate entries by these strings, so
a custom heading or relabeled field breaks the chain silently.

**c. Commit the slice**

Stage the changed files and commit with this format. **When the repo tracks `.vine/`
artifacts**, bundle this slice's artifact updates into the same commit so the tracked spec and
journal never lag the code: the slice's NAVIGATION.md journal entry plus any SPEC.md deviation
annotations you made during the slice (step 6). **When artifacts are untracked** — many repos
gitignore them, or keep them in a personal scope, which is fine — commit code only; the
journal-before-commit guarantee compares file modification time, not commit contents, so it holds
either way. Never force-add a gitignored artifact. (The full per-commit-point breakdown —
slice / phase-group boundary / evolve / PR — lives in `references/STATE.md` under *Committing
Artifacts*.)

```
<slice-name>: <1-2 sentence summary>

Acceptance criteria verified:
- [x] <AC from spec that passed>
- [x] <AC from spec that passed>
- [ ] <AC skipped with reason>
```

If the project uses a ticket prefix convention (e.g., `PROJ-1234`), include it. Check
`.vine/context/shared.md` or `CLAUDE.md` for commit message conventions.

After committing, update the slice's `**Commit**` field in NAVIGATION.md with the actual
hash. When task tools are available, `TaskUpdate` this slice's task to `completed` once the
commit lands — the live view follows the journal, so it flips only after the durable record is
written.

**Important:** Review depth is set by the engineer's gear choice: in approve-edits they
review each change before it lands; in free climb they review at the slice boundary. Either
way the commit follows validation and a journal update — structured committing, not
autonomous committing.

### 5. Handle Blockers

When you hit something unexpected:

**If it's a quick question**: Ask the engineer directly. They probably know the answer.

**If it's a significant blocker**: Stop, document it, and use `AskUserQuestion` to present
options. Describe the blocker clearly, then offer concrete resolution paths:

- Use `multiSelect: false` with up to 4 options grounded in the specific situation
- Put the recommended option first with "(Recommended)" suffix
- Common patterns: "Mock and defer", "Block and resolve", "Work around (tech debt)", "Descope"

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
   When the completed slice was in "free climb" mode, skip the check-in — the engineer
   already signaled they don't need the reflection.
3. Check if the next slice's assumptions still hold (sometimes building slice 1 reveals that
   slice 2 needs adjustment)
4. If the next slice is marked CONDITIONAL in the spec, evaluate whether the condition is met.
   When task tools are available, dispose its task accordingly: if the condition holds, drop
   the `(conditional: …)` prefix and proceed (it becomes a normal slice); if not, `TaskUpdate`
   it to `deleted` and note the skip in NAVIGATION.md.
5. Decide how to proceed. Offer three paths via `AskUserQuestion` — **continue in this
   session**, **`/clear` and continue fresh**, or **pause**. The `/clear` path means run
   `/clear` then re-invoke `/vine:navigate <domain>/<feature-slug>`, which auto-resumes at the
   next not-Complete slice — navigate rebuilds state from NAVIGATION.md + SPEC.md (Slices 15–16),
   so a mid-phase clear loses nothing. **Surface it selectively**: mark "`/clear` and continue
   fresh" as Recommended only when the session context has grown heavy (several slices deep, or a
   lot of exploration this session) or the next slice is substantially independent of what you
   just built. When the next slice is tightly coupled to the just-finished one, or only a slice or
   two is done, keep **continue in this session** the default and present `/clear` as the lighter
   option. The journal carries everything forward either way.

> "Slice 2 committed (abc1234). Before we start Slice 3 (the webhook handler), I want to
> flag that our implementation of the provider interface is slightly different from what the
> spec assumed — we added an async initialization step. This means the webhook handler will
> need to account for that. Want to adjust the plan, or should I adapt as I go?"

**If the engineer chooses `/clear` and continue fresh**, this is a continuation, not an ending.
NAVIGATION.md is already current (you updated it at the slice commit), so nothing extra to write —
the re-invoked `/vine:navigate` rebuilds context from it. Leave `.vine/ACTIVE` in place; the next
invocation refreshes its `phase` line. Then tell the engineer the exact command to run:

> "Slice N committed. Run `/clear`, then `/vine:navigate <domain>/<feature-slug>` — it'll pick up
> at Slice N+1 with a fresh context. NAVIGATION.md carries everything forward."

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
> for when you come back, run `vine:pause <domain>/<feature-slug>` before closing the session."

Then delete `.vine/ACTIVE` — the navigate session is ending. (`vine:pause` also clears the
sentinel; deleting it here covers the engineer who pauses without running the command.)

### 8. Between Phase Groups

If SPEC.md defines phase groups, suggest a context clear when you reach the end of a group.
This is a natural stopping point — the group's work is a coherent unit that can be reviewed
and committed independently.

**If PROJECT-MAP.md has a Milestones table** (multi-PR feature), do the following at each
phase group boundary before showing the completion block:

1. **Phase group verification** — Before suggesting a PR, delegate a product check to the
   `vine-verification` agent in **feature verification mode at phase-group scope**. The
   checklist lives in the agent definition — don't restate it here. Pass the agent:

   - The files changed across this phase group (not just the last slice)
   - Each slice in the group with its acceptance criteria from SPEC.md
   - Custom validation commands from `.vine/context/navigate.md`, if defined

   The agent runs the base checks for that scope and reports without fixing. When the
   report comes back:

   - **Acceptance Criteria section**: present the agent's rollup to the engineer. If any
     criteria are unmet, resolve them before proceeding.
   - **Test Coverage section**: if the report flags slices that introduced behavior
     without tests, use `AskUserQuestion` — let the engineer decide per-slice whether to
     add tests now or defer to a follow-up:

     > "Slice [N] added [behavior] but the verification report shows no tests covering
     > it. Want to add tests before we PR this phase, or defer to a follow-up?"

   - **Anything else the report surfaces**: fix it within the current session before
     moving on — don't carry a failing phase group into a PR.

   This is lighter than evolve's full pass — no deviation review, no follow-up triage, no
   handoff prep — but thorough enough that a PR opened after this step is shippable.

   > **Verification tiers:** This is the phase-group tier; evolve runs the full-feature
   > tier. The boundary between them — and the intentional asymmetry — is documented in
   > the verification-tier contract note in `references/STATE.md`. The checklist itself
   > lives in `agents/vine-verification.md`.

2. Update the completed phase's row in PROJECT-MAP.md — change status from `🚧 Active` to
   `✅ Shipped` (or `✅ Complete` if no PR yet).
3. Update the SPEC.md phase group header — replace the `⬜` or `🚧` marker with `✅`.
4. If there's a next phase, update its Milestones row to `🚧 Active`.

   **When the repo tracks artifacts**, commit these tracker updates at the boundary — the
   PROJECT-MAP.md row changes and the SPEC.md phase-group ✅ marker are the phase group's
   closing artifact state, so the PR you open next carries them alongside the code. (Untracked
   repos: they update on disk only, never in a commit.)
5. Suggest opening a PR for the completed phase group:

   > "Phase [N: name] is complete. This is a good point to open a PR for this work.
   > Want to open a PR now, or continue to the next phase first?"

   If the engineer opens a PR, record the PR number in PROJECT-MAP.md's Milestones table
   (the PR column for this phase row). Don't create the PR automatically — just suggest it.

**Whether or not it's a multi-PR feature**, handle the sentinel before showing the completion
block: if the session ends here (the recommended path — the next group gets a fresh session),
delete `.vine/ACTIVE`; if the engineer continues into the next phase group immediately, update
the sentinel's `phase` line instead. Then show the phase group completion block:

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

**Respect the engineer's expertise — and flag your own gaps.** They know this codebase better
than you. When they suggest a different approach, explore it seriously. When you're unsure,
say so — the engineer is a resource, not an audience.

**Stay in scope.** If you notice something that should be fixed but isn't in the spec, note it
in NAVIGATION.md under "discovered items" rather than fixing it.

## Phase Completion

When all slices are implemented (or the engineer decides to stop), run the gate check before
suggesting evolve.

### Completion Gate Check

Read NAVIGATION.md and verify each slice entry has:

- **Commit hash**: Not "pending" — every completed slice must have an actual hash
- **Validation status**: Filled in (pass or fail with resolution)
- **Acceptance criteria**: At least one criterion checked (either `[x]` or `[ ]` with reason)
- **Learnings**: Not empty — at minimum "None" is acceptable, but blank is not
- **Deviation closure**: For every slice whose "Deviations from spec" is not "None" (or
  blank), confirm SPEC.md carries the matching annotation step 6 requires — a strikethrough
  or addendum in the affected section. This is a lookup, not a judgment call: like a missing
  commit hash, a recorded deviation with no SPEC.md annotation is a gap. Grep SPEC.md for the
  deviation's subject if you're unsure it's there. The point is to never leave evolve
  cross-referencing two documents to reconstruct what changed.

If any slice has gaps, list them:

> "Before we wrap up, NAVIGATION.md has some gaps:
> - Slice 2: missing learnings
> - Slice 3: deviation recorded ('switched to async init') but SPEC.md has no annotation for it
> - Slice 4: commit hash still says 'pending'
> Want me to fill these in now?"

Fix the gaps inline — update NAVIGATION.md with the engineer's input (or fill in what you
can from the commit history and conversation context). For an unclosed deviation, the fix is
to add the missing SPEC.md annotation (step 6), not to edit NAVIGATION.md. Don't proceed to
the completion block until the gate passes.

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

Delete `.vine/ACTIVE` — the navigate session is over, and a stale sentinel keeps installed
hooks firing against work that's no longer active.

Persist actionable retro items before presenting the completion block. The retro is
conversation output and doesn't survive `/clear` — anything evolve should act on belongs
in NAVIGATION.md (a slice's Learnings or the Remaining Work handoff context), not just
the retro.

Then present the completion block:

```
---
✅ vine:navigate complete → .vine/projects/<domain>/<feature-slug>/NAVIGATION.md updated
   Slices completed: [N of M]
   Commits: [list of commit hashes]

📋 Suggested next step: Run `vine:evolve <domain>/<feature-slug>` to verify integration and capture learnings.
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
