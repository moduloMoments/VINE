---
name: vine:inquire
description: "Design and spec a feature — define requirements, make architecture decisions, and break work into implementation slices after verifying codebase context"
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

# vine:inquire — Feature Specification & Design

## Load Context Overlays

Read `.vine/context/shared.md` and `.vine/context/inquire.md` if they exist, then follow the
**Overlay Loading Protocol** from `shared.md` for the rest (apply-as-overlay precedence, the
personal `.local` layer, the legacy-directory fallback, and missing-file behavior). The inquire
overlay carries inquire-specific extensions for this project (design review checklists, architecture
decision templates, preferred patterns to recommend). If `shared.md` is absent, degrade gracefully:
read the phase overlay if present, otherwise proceed on command defaults.

## Load Engineer Profile

Follow the Engineer Profile Protocol and Collaboration Stance from `.vine/context/shared.md`.

---

You and the engineer are designing a feature. The landscape has already been mapped in vine:verify
— there should be a CONTEXT.md with codebase knowledge, edge cases, tech debt, and open questions.
Your job now is to build the feature specification on top of that foundation.

This is a design conversation, not a monologue. Present options with tradeoffs, let the engineer
decide, and document everything. The output is a SPEC.md that vine:navigate can execute against.

## Getting Started

### 1. Load the Context

Identify the feature directory under `.vine/projects/`. Look for the domain/feature-slug path
(e.g., `.vine/projects/payments/webhook-support/`). Filter out resolved projects (directories
containing a `.resolved` file) and archived projects (under `.vine/projects/.archive/`). If
there's only one active feature directory, use that. If there are multiple, use
`AskUserQuestion` to let the engineer pick which feature to work on. <!-- decision-class: default-able --> If all projects are
resolved or archived, tell the engineer and suggest starting a new cycle with `/vine:verify` —
present the command in its own fenced code block so it's copy-pastable.

Also read `.vine/projects/<domain>/<feature-slug>/PROJECT-MAP.md` if it exists. If present, update the
inquire row to 🚧 with today's date. If it doesn't exist, skip — older projects won't have one.

Read `.vine/projects/<domain>/<feature-slug>/CONTEXT.md` from the project. If it doesn't exist, tell the engineer:

> "I don't see a CONTEXT.md from a verify phase. We can either run /vine:verify first to map the
> landscape, or if you're confident we have enough context, I can work from what you tell me.
> What do you prefer?"

If CONTEXT.md exists, read it and summarize the key points back to the engineer:

> "Based on our verify phase, here's what I'm working with: [brief summary]. The open questions
> were: [list]. Let's start by resolving those."

**Consume any pause state.** If the feature directory contains a PAUSE.md (e.g., the engineer
paused after verify), surface its notes alongside the summary above, then delete it — the
consumed-once rule (see `references/STATE.md`). A consumed pause must not linger: it would keep
suggesting `/vine:resume` for work that has already resumed. Anything worth keeping past this
session belongs in the artifacts, not PAUSE.md. (If no PAUSE.md is present, skip.)

### 2. Resolve Open Questions

CONTEXT.md will have open questions from the verify phase. Address each one:

- Present 2-3 options with tradeoffs where there's genuine ambiguity
- Ask the engineer for their call
- Document the decision and rationale

Don't manufacture false choices. If there's an obvious right answer, say so and ask if they agree.
The goal is informed decisions, not decision theater.

### 3. Design the Approach

Now propose the architecture. When a design decision requires deeper understanding of how
existing code handles a similar problem, delegate to the `vine-codebase-explorer` agent to
research the specific area rather than reading broadly yourself.

For each significant design decision:

<!-- decision-class: human-required -->
**Use AskUserQuestion for all design decisions.** Never print markdown option lists — use the
interactive `AskUserQuestion` tool instead. This gives the engineer a clean UI with selectable
options.

Follow the Interaction Constraints from `.vine/context/shared.md` for every `AskUserQuestion` call.

**Wait for the decision.** Don't assume. Don't proceed. The engineer decides.

**Document the decision.** Capture not just what was chosen but why. Future you (or another
engineer) will want to know.

### 4. Define Acceptance Criteria

For each piece of the feature, define what "done" looks like. Good acceptance criteria are:

- Verifiable (you can write a test or check for it)
- Specific (not "works well" but "returns 200 with valid payload within 500ms")
- Edge-case aware (incorporate what you learned in verify)

Run these by the engineer. They'll catch criteria you missed and remove ones that don't matter.

### 5. Integrate Tech Debt

Review the tech debt catalog from CONTEXT.md. For each item, decide together:

- **Address now**: This debt is in the critical path and fixing it makes the feature better
- **Address during**: Can be cleaned up while implementing without significant extra effort
- **Defer**: Not relevant enough to this work; add to backlog with context
- **Accept new debt**: Sometimes the right call is to take on debt consciously. Document why.

This is where the engineer's judgment matters most. They know the team's capacity, upcoming
priorities, and how much debt the codebase can absorb.

### 6. Slice the Work

Break the feature into ordered work slices. Each slice should be:

- **Independent enough** to be implemented, reviewed, and understood on its own
- **Ordered by dependency** — later slices build on earlier ones
- **Sized for one session** — if a slice feels like it'll take multiple vine:navigate sessions,
  it's too big
- **Clear on inputs/outputs** — what does this slice need, what does it produce

For each slice:
```markdown
### Slice N: [Name]
**Goal**: What this accomplishes
**Depends on**: Previous slices or external factors
**Files likely touched**: [from CONTEXT.md knowledge]
**Acceptance criteria**: Specific to this slice
**Complexity signal**: Low / Medium / High + brief rationale
```

**Conditional slices:** When a slice depends on a finding from verify that could go either way,
mark it as conditional so navigate can skip it cleanly instead of discovering it's unnecessary
mid-implementation:

```markdown
### Slice N: [Name] (CONDITIONAL)
**Condition**: Only if [verify finding] — e.g., "only if role-based selectors
  are insufficient for reliable test targeting"
**Goal**: ...
```

Navigate will evaluate the condition before starting the slice and skip it if unmet.

### 6b. Group Slices Into Phases (for larger features)

If the feature has more than 4-5 slices, group them into named phases with natural boundaries.
Each phase becomes one vine:navigate session. This keeps sessions focused and gives the engineer
clean stopping points.

```markdown
## Phase 1: Data Layer (Slices 1-3)
Summary: Set up the database schema, repository, and data validation.
Session boundary: After this phase, the data layer is complete and testable independently.

## Phase 2: API Layer (Slices 4-6)
Summary: Build the endpoints and service logic on top of the data layer.
Session boundary: After this phase, the API is functional end-to-end.

## Phase 3: Integration (Slices 7-8)
Summary: Wire up event handlers, webhooks, and monitoring.
Session boundary: Feature is complete and ready for evolve.
```

Each phase should be a coherent unit — something that makes sense to implement, review, and
potentially ship on its own. Navigate will work one phase at a time and suggest a context
clear between phases.

For smaller features (4 or fewer slices), skip grouping. Everything fits in one navigate session.

### 6c. Multi-PR Detection (if PROJECT-MAP.md exists)

After slicing (and grouping, if applicable), check whether this feature is a multi-PR candidate.
The heuristic: **more than 4 slices or phase groups exist.** If either condition is met, use
`AskUserQuestion` to ask the engineer: <!-- decision-class: default-able -->

> "This feature has [N slices / N phase groups] — large enough that it might benefit from
> shipping in multiple PRs. Should we set up multi-PR tracking?"

Options (mutually exclusive):
1. "Yes, track milestones (Recommended)" — "Each phase group becomes a milestone with its own PR"
2. "No, single PR" — "We'll ship everything in one PR"

If the engineer confirms multi-PR tracking:

1. Add a Milestones table to PROJECT-MAP.md mapping each phase group to a milestone row:

   ```markdown
   ### Milestones

   | Phase | Slices | Status | PR |
   |-------|--------|--------|----|
   | Phase 1: [Name] | [slice range] | ⬜ Pending | — |
   | Phase 2: [Name] | [slice range] | ⬜ Pending | — |
   ```

2. Add status markers to SPEC.md phase group headers — append `⬜` to each phase heading:

   ```markdown
   ## Phase 1: Data Layer (Slices 1-3) ⬜
   ```

   Navigate will update these markers as phases complete.

If no PROJECT-MAP.md exists, skip this step entirely — backward compatible.

### 7. Suggest Backlog Updates

Based on everything you've discussed, suggest updates to the project backlog:

- New items discovered during design
- Existing items that should be re-prioritized
- Items that are now unblocked by this feature
- Tech debt items deferred from this work

Present these as suggestions. The engineer manages the backlog.

### 8. Write SPEC.md

Compile everything into the spec document:

```markdown
# Feature Spec: [Feature Name]
## Date: [YYYY-MM-DD]
## Built on: CONTEXT.md ([date])
## Decisions made by: [engineer name]

### Problem Statement
[What we're solving and why]

### Approach
[Chosen architecture with rationale]
[Key decisions and why they were made]

### Acceptance Criteria
[Verifiable conditions for done]

### Work Slices
[Ordered list with details per slice]

### Tech Debt Integration
[What's being addressed, deferred, or consciously taken on]

### Backlog Updates
[Suggested additions/changes]

### Dependencies & Risks
[External dependencies, team coordination needed, unknowns]
```

The section headings above are the SPEC.md template headings from `references/STATE.md`.
Use them verbatim. Extending a heading with subtitle text after a colon or dash is fine;
replacing or rewording the heading itself is not. Navigate and artifact-format validation
locate sections by these headings, so a custom heading breaks the chain silently.

Save to `.vine/projects/<domain>/<feature-slug>/SPEC.md`.

## Important Principles

**Build on verify, don't redo it.** CONTEXT.md is your foundation. Reference it, don't repeat it.
If you find gaps in the context, note them — but don't turn inquire into another exploration phase.

**The engineer decides.** Every design choice, every tradeoff, every priority call. You present,
they decide, you document. This isn't a rubber stamp — push back if you see problems, but
ultimately it's their call.

**Spec for the navigator.** The person running vine:navigate (possibly a different engineer, possibly
the same one in a different session) should be able to pick up SPEC.md and know exactly what to
build, why, and in what order. If they'd need to ask clarifying questions, the spec isn't done.

**Don't over-spec.** Leave room for implementation judgment. Specify the what and why, not the
exact how-many-spaces-of-indentation. Navigate needs latitude to make tactical decisions.

## Phase Completion

### Sign-Off Gate

SPEC.md is written (step 8) — now get explicit sign-off before handing to navigate. Don't infer
approval from the absence of objections; ask for it. This is the gate that closes inquire, not a
formality.

1. **Present the spec for review.** Give the engineer a clickable link to the file (e.g.,
   `[SPEC.md](.vine/projects/<domain>/<feature-slug>/SPEC.md)`) so it opens rendered in their
   editor, plus a short summary of the key decisions and the slice/phase breakdown. (To open the
   file automatically, a repo can wire its editor's open command in `.vine/context/inquire.md`;
   the clickable link is the portable default — don't shell out to an OS-specific opener yourself.)

2. **Gate on explicit sign-off.** <!-- decision-class: human-required --> Use `AskUserQuestion`:
   - **"Approve — hand to navigate (Recommended)"**: the spec is ready to implement.
   - **"Request changes"**: something needs revision first.

   If the engineer requests changes, revise SPEC.md, re-present the link, and ask again. Loop
   until approved. The spec isn't done until the engineer signs off.

Once approved:

1. Update PROJECT-MAP.md (if it exists) — set the inquire row to ✅ with today's date.

2. If the repo tracks artifacts (`git check-ignore -q .vine/projects` exits non-zero), commit
   SPEC.md and the PROJECT-MAP.md update (see "Committing Artifacts" in `references/STATE.md`).
   If the path is gitignored, skip this step silently — personal-scope artifacts never enter
   a commit.

3. Persist actionable retro items before printing the completion block. The retro is
   conversation output and doesn't survive `/clear` — if a retro item should change what
   navigate builds (a slice criterion, a convention to record, a framing a rule needs),
   fold it into the relevant slice in SPEC.md now. Only items with no downstream action
   belong in the retro alone.

Then present the completion block per the Next-Step Suggestions convention in shared.md —
plain chat text, with only the `/vine:navigate` command line in a fenced block:

````
---
✅ vine:inquire complete → SPEC.md written to .vine/projects/<domain>/<feature-slug>/SPEC.md
📋 Suggested next step: Run /vine:navigate to begin implementation.
   Starting with [Phase 1: name / Slice 1: name]
   [1-2 sentence summary of what's first]

```
/vine:navigate <domain>/<feature-slug>
```

🔄 Recommended: Run `/clear` before starting /vine:navigate.
   Inquire is analytical — navigate needs a tactical, implementation-focused headspace.
   SPEC.md carries everything forward; conversation context doesn't need to.

🧭 Route preview (non-binding): [Based on the four-leg headless predicate read against the
   spec as written — is there a validation contract, do the slices carry acceptance criteria,
   do they look independent of in-flight work, is the blast radius bounded — name the likely
   route, e.g. "Looks headless-eligible — bounded, independent slices with ACs and a validation
   block" or "Likely interactive — slice 3 overlaps in-flight work / no validation contract yet".
   This is a preview only, like the gearing note: it does not write ROUTE.md, and navigate's
   head gate re-evaluates the volatile legs against fresh repo state and makes the binding call.]

🎫 Auto-agent ticket (when scope is autonomous-eligible): If a phase group is bounded, independent
   of in-flight work, carries acceptance criteria, and the repo has a validation contract, it can be
   handed to the `vine-coder` agent (the autonomous coding role — implements a ticketed slice
   end-to-end and opens a PR) instead of being run with a human in `/vine:navigate`. Emit a ticket
   per the **Autonomous Delegation** convention in shared.md — scope (which slices), the SPEC.md
   pointer, the constraints, and dispatch to `vine-coder` — and the PR it opens is reviewed (by the
   engineer or the `vine-reviewer` agent) before merge. Omit this block when the scope is
   interactive.

🌱 Phase retro:
   - CLAUDE.md suggestion: [any project conventions or decisions worth persisting]
   - Skill suggestion: [any design pattern that could be templated]
   - User note: [any architectural concepts the engineer found useful to discuss]
---
````
