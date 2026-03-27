---
name: vine-inquire
description: >
  VINE Phase 2: Inquire — Feature specification and design, built on top of verified context.
  This phase takes the CONTEXT.md from vine:verify and layers the feature spec on top of it.
  Claude and the engineer discuss architecture, weigh tradeoffs, and produce a SPEC.md with
  acceptance criteria, work slices, and tech debt integration. The engineer approves every
  design decision — nothing proceeds without explicit sign-off.
  Use this skill after vine:verify when you have a CONTEXT.md and need to design the feature,
  or when the engineer says "let's figure out how to build this", "design this feature",
  "what's the approach", or "spec this out."
  Trigger on: "vine:inquire", "design this feature", "spec this out", "how should we build this",
  "what's the approach", "plan the feature", "architecture discussion", "feature spec",
  "vine inquire", "let's figure out how to build this", "design phase", "propose an approach".
---

# vine:inquire — Feature Specification & Design

You and the engineer are designing a feature. The landscape has already been mapped in vine:verify
— there should be a CONTEXT.md with codebase knowledge, edge cases, tech debt, and open questions.
Your job now is to build the feature specification on top of that foundation.

This is a design conversation, not a monologue. Present options with tradeoffs, let the engineer
decide, and document everything. The output is a SPEC.md that vine:navigate can execute against.

## Getting Started

### 1. Load the Context

Identify the feature directory under `.vine/`. Look for the domain/feature-slug path
(e.g., `.vine/payments/webhook-support/`). If there's only one feature directory, use that.
If there are multiple, present a select prompt:

> **Which feature are you working on?**
> 1. payments/webhook-support (last modified: today)
> 2. auth/sso-migration (last modified: 3 days ago)
> 3. Other: ___

Read `.vine/<domain>/<feature-slug>/CONTEXT.md` from the project. If it doesn't exist, tell the engineer:

> "I don't see a CONTEXT.md from a verify phase. We can either run vine:verify first to map the
> landscape, or if you're confident we have enough context, I can work from what you tell me.
> What do you prefer?"

If CONTEXT.md exists, read it and summarize the key points back to the engineer:

> "Based on our verify phase, here's what I'm working with: [brief summary]. The open questions
> were: [list]. Let's start by resolving those."

### 2. Resolve Open Questions

CONTEXT.md will have open questions from the verify phase. Address each one:

- Present 2-3 options with tradeoffs where there's genuine ambiguity
- Ask the engineer for their call
- Document the decision and rationale

Don't manufacture false choices. If there's an obvious right answer, say so and ask if they agree.
The goal is informed decisions, not decision theater.

### 3. Design the Approach

Now propose the architecture. For each significant design decision:

**Present options as structured choices.** Use single-select prompts for architecture decisions.
Always lead with your recommendation and explain why, but give real alternatives:

> **How should we handle payment provider abstraction?**
> 1. Factory pattern (recommended) — cleanest extension path, each provider is a class.
>    Tradeoff: more boilerplate upfront.
> 2. Strategy pattern — lighter weight, providers are functions.
>    Tradeoff: harder to test in isolation.
> 3. Direct integration — fastest to ship, refactor later.
>    Tradeoff: tech debt, coupling.
> 4. Other: ___

For tech debt triage, use multi-select so the engineer can batch decisions:

> **Which tech debt items should we address during this feature?** (select all that apply)
> 1. Migrate off deprecated auth middleware (recommended — it's in our critical path)
> 2. Clean up dead code in payment utils
> 3. Add missing index on transactions table
> 4. None — defer all to backlog

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

Save to `.vine/<domain>/<feature-slug>/SPEC.md`.

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

When the spec is solid and the engineer has signed off:

```
---
✅ vine:inquire complete → SPEC.md written to .vine/<domain>/<feature-slug>/SPEC.md
📋 Suggested next step: Run `vine:navigate` to begin implementation.
   Starting with [Phase 1: name / Slice 1: name]
   [1-2 sentence summary of what's first]

🔄 Start a fresh session for vine:navigate. Inquire is analytical — navigate
   needs a tactical, implementation-focused headspace. SPEC.md carries everything forward.

🌱 Phase retro:
   - CLAUDE.md suggestion: [any project conventions or decisions worth persisting]
   - Skill suggestion: [any design pattern that could be templated]
   - User note: [any architectural concepts the engineer found useful to discuss]
---
```
