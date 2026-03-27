---
name: vine:evolve
description: "Triple evolution — verify, capture learnings, and prep the handoff"
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

# vine:evolve — Triple Evolution

The feature is implemented. Now you evolve three things: the product, the agent's capabilities,
and the user's knowledge. This is what makes VINE different from frameworks that just verify and
ship — every feature is an opportunity to grow on three dimensions.

## Getting Started

Identify the feature directory under `.vine/` (e.g., `.vine/payments/webhook-support/`). If
there are multiple feature directories, use `AskUserQuestion` to let the engineer pick which
feature to review.

Read all VINE artifacts for this feature:
- `.vine/<domain>/<feature-slug>/CONTEXT.md` (the landscape)
- `.vine/<domain>/<feature-slug>/SPEC.md` (the design)
- `.vine/<domain>/<feature-slug>/NAVIGATION.md` (the implementation journal)

If any are missing, work with what you have. NAVIGATION.md is the most critical — it tells you
what was actually built versus what was planned.

## Evolution 1: Product

This is the verification and quality pass. The product should be better than when you started.

### Verify Against Acceptance Criteria

Go through each acceptance criterion in SPEC.md:

For each criterion:
1. Check whether the implementation satisfies it
2. If there are tests, run them
3. If there aren't tests but should be, note it
4. If the criterion was modified during navigate, check against the modified version

Present results clearly:

```
Acceptance Criteria Verification:
✅ AC-1: Payment factory returns correct provider — verified via unit test
✅ AC-2: Stripe charges process within 500ms — verified via integration test
⚠️  AC-3: Webhook signature validation — implemented but no test coverage
❌ AC-4: Retry logic on provider timeout — not implemented (deferred in Slice 3)
```

For anything that's not passing, discuss with the engineer. Some items may be acceptable
deferrals, others may need to be addressed before shipping.

### Review Spec Deviations

Check NAVIGATION.md for any deviations from SPEC.md. For each:
- Was it a justified tactical decision?
- Does it change the feature's behavior in ways stakeholders should know about?
- Should the spec be updated to reflect reality?

### Identify Follow-Up Work

Compile from NAVIGATION.md's "discovered items" and any gaps found during verification:
- Bugs found but not fixed
- Tech debt created or discovered
- Features that were descoped
- Documentation that needs updating
- Tests that should be added

Suggest concrete backlog items with enough context that someone else could pick them up.

### Prep the Handoff

Generate the materials the engineer needs to ship:

**Suggested PR description:**
```markdown
## Summary
[What this PR does, tied to the problem statement from SPEC.md]

## Changes
[Key changes organized by purpose, not by file]

## Decisions Made
[Non-obvious choices with rationale, from NAVIGATION.md]

## Testing
[What's tested, what's not, and why]

## Follow-up
[Items deferred or discovered during implementation]
```

**Reviewer notes:** What should the reviewer pay attention to? What context do they need?
Pull this from CONTEXT.md's tribal knowledge — things a reviewer wouldn't know from just
reading the diff.

**Suggested commit message(s):** If the engineer hasn't committed yet, suggest how to
structure the commits (one per slice, or squashed, depending on the team's convention).

## Evolution 2: Agent

The agent (Claude + its configuration) should be more capable after every feature. This is
where VINE compounds — each feature makes the next one easier.

### CLAUDE.md Suggestions

Review everything you learned during this feature and suggest updates to CLAUDE.md (or the
project's equivalent configuration). These might include:

- **Coding conventions** discovered: "This project uses the repository pattern for all data
  access. New services should follow src/repositories/ for reference."
- **Architectural patterns**: "Feature flags are managed via src/config/flags.ts. All new
  features should be gated."
- **Testing conventions**: "Integration tests use the test database defined in docker-compose.test.yml.
  Always reset state between tests."
- **Tribal knowledge codified**: Things from CONTEXT.md that should be persistent project knowledge
  rather than living in one VINE session's artifacts.

Use `AskUserQuestion` with `multiSelect: true` to let the engineer batch their decisions on
which suggestions to accept. Max 4 options per question — if you have more suggestions, split
across multiple calls by category. Put the strongest recommendation first with "(Recommended)"
in its label.

For each accepted suggestion, draft the exact text to add. The engineer manages the file —
you draft, they commit.

### Skill Suggestions

Look at the workflow patterns from this feature:

- Did you and the engineer develop a repeatable workflow? (e.g., "every time we add a new provider,
  we do X, Y, Z" → that's a skill)
- Was there a boilerplate pattern? (e.g., "new API endpoints always need these 5 files" → scaffold skill)
- Did you write utility scripts during navigate that would be useful again?
- Is there a verification checklist specific to this domain that should be codified?

Describe each potential skill concisely:

> **Suggested skill: `add-provider`**
> When triggered: "add a new payment provider"
> What it does: Scaffolds the provider class, factory registration, tests, and config.
> Estimated value: Saves ~30 min per new provider, ensures consistency.

### Workflow Improvements

Reflect on how the VINE process itself went:

- Did any phase feel too heavy or too light?
- Were there moments where the handoff between phases was clunky?
- Did you wish you had information in one phase that you only got in another?

Note these for the engineer. They might want to customize VINE for their team.

## Evolution 3: User

The engineer should know more after this feature than before. This isn't about teaching — it's
about recognizing what they learned and where they might want to go deeper.

### Knowledge Captured

Review the bidirectional learnings from NAVIGATION.md:

- What patterns or approaches did the engineer engage with during navigate?
- What questions did they ask that suggest curiosity about a topic?
- What did they teach you that showed deep expertise in an area?

Summarize without being condescending. The engineer doesn't need a report card — they need a
mirror:

> "During this feature, you spent time understanding the factory pattern implementation and
> asked good questions about when it's worth the abstraction overhead. The retry logic discussion
> touched on circuit breaker patterns — that might be worth exploring if your services see
> intermittent upstream failures."

### Suggested Explorations

Based on what you observed, suggest 1-2 areas the engineer might find valuable:

- A pattern they used that has deeper applications
- A library or tool related to what they built
- An architectural concept adjacent to decisions they made

Keep it light. One or two sentences each, not a curriculum.

## Write EVOLUTION.md

Compile everything into `.vine/<domain>/<feature-slug>/EVOLUTION.md`:

```markdown
# Evolution Report: [Feature Name]
## Date: [YYYY-MM-DD]

### Product Evolution
#### Acceptance Criteria Results
[Pass/fail table]

#### Spec Deviations
[List with rationale]

#### Follow-Up Items
[Concrete backlog suggestions]

### Agent Evolution
#### CLAUDE.md Suggestions
[List with engineer's decisions: accepted/rejected/deferred]

#### Skill Suggestions
[Potential skills with trigger and description]

#### VINE Process Observations
[What worked, what to adjust]

### User Evolution
#### Knowledge Highlights
[What the engineer learned and taught]

#### Suggested Explorations
[1-2 areas to explore]

### Handoff Package
#### PR Description
[Ready to paste]

#### Reviewer Notes
[Context for reviewers]

#### Commit Suggestions
[Suggested structure]
```

## Phase Completion

```
---
✅ vine:evolve complete → EVOLUTION.md written to .vine/<domain>/<feature-slug>/EVOLUTION.md
📦 Handoff package ready:
   - PR description drafted
   - Reviewer notes compiled
   - [N] follow-up items for backlog
   - [N] CLAUDE.md suggestions for review
   - [N] potential skills identified

🌱 VINE cycle complete for [Feature Name].
   Three evolutions captured:
   - Product: [brief summary of quality state]
   - Agent: [brief summary of capability growth]
   - User: [brief summary of knowledge growth]

   "Grow features on solid roots."
---
```

## Important Principles

**Verification is not a formality.** Actually check things. Run tests. Read the code against
the criteria. If something doesn't pass, say so. The engineer needs honest assessment, not
cheerleading.

**Agent evolution compounds.** Every CLAUDE.md update and every skill suggestion makes the
next VINE cycle faster and better. Take this seriously — it's the long game.

**User evolution requires tact.** You're reflecting back what someone learned, not evaluating
their performance. Be a mirror, not a teacher. If they didn't learn anything new, that's fine
— maybe this feature was in their comfort zone. Don't manufacture growth that didn't happen.

**The handoff is for humans.** PR descriptions, reviewer notes, and commit messages are read
by people. Write them clearly, with context, assuming the reader doesn't have VINE artifacts
in front of them.
