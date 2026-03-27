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

## Load Project Hooks

Before starting this phase, check for project-level VINE hooks:

1. Read `.vine/hooks/shared.md` if it exists — repo-wide context for all VINE phases (available
   tools, agents, conventions, CI/CD patterns, team structure).
2. Read `.vine/hooks/evolve.md` if it exists — evolve-specific extensions for this project
   (PR creation tools, CI validation commands, repo-level agents and skills to suggest wiring
   into hooks, Jira/Linear integration for follow-up items).
3. Apply the contents of both as additional instructions layered on top of this command. Hook
   instructions take precedence over defaults when they conflict.

If neither file exists, proceed normally. If `.vine/` doesn't exist at all, suggest `/vine:init`.

---

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

### Trust Per-Slice Verification

Navigate now validates and commits each slice with its acceptance criteria. Don't re-read every
file or re-check per-slice ACs — trust the commit history. Instead, pull the verification
summary from NAVIGATION.md's slice entries (each has an acceptance criteria checklist and
validation status).

Present a rollup of per-slice results from NAVIGATION.md, then focus your effort on what
navigate couldn't verify:

### Cross-Slice Integration Check

This is where evolve adds value. Verify that the slices work together as a whole:

- Do the pieces integrate correctly? (data flows between modules, imports resolve, etc.)
- Run the full test suite (not just per-file tests from navigate's validation)
- Check for cross-cutting concerns: error handling paths, edge cases that span slices,
  performance implications of the combined changes
- If `.vine/hooks/evolve.md` defines integration validation commands, run those

### Review Spec Deviations

Since navigate now annotates deviations directly in SPEC.md (strikethroughs/addenda), the
deviations table should be straightforward to compile. For each deviation:
- Was it a justified tactical decision?
- Does it change the feature's behavior in ways stakeholders should know about?

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

Since each slice is already committed, use `git log --oneline <base>..HEAD` to build the
Changes section from the actual commit history rather than reconstructing a narrative:

```markdown
## Summary
[What this PR does, tied to the problem statement from SPEC.md]

## Changes
[Built from git log — each slice commit tells the story]

## Decisions Made
[Non-obvious choices with rationale, from NAVIGATION.md]

## Testing
[What's tested per-slice + integration results from evolve]

## Follow-up
[Items deferred or discovered during implementation]
```

**Reviewer notes:** What should the reviewer pay attention to? What context do they need?
Pull this from CONTEXT.md's tribal knowledge — things a reviewer wouldn't know from just
reading the diff.

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

### Convention Check for Created Artifacts

Before writing any persistent artifacts (CLAUDE.md entries, skills, commands, hook updates),
verify they follow current project conventions:

1. Check existing examples first (read other CLAUDE.md entries, existing skills/commands)
2. Match the naming, structure, and style of what's already there
3. Flag inconsistencies to the engineer before writing — don't silently create artifacts that
   don't fit the project's patterns

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

### Hook Update Suggestions

Review what tools, agents, and patterns proved useful during this VINE cycle and suggest
updates to `.vine/hooks/`:

- Tools or agents that should be auto-invoked in future cycles (add to navigate.md or evolve.md hooks)
- Validation commands that worked well (add to navigate.md hook)
- Conventions discovered that should apply to all future VINE work (add to shared.md hook)
- Domain-specific questions that should always be asked in verify (add to verify.md hook)

Use `AskUserQuestion` with `multiSelect: true` to let the engineer pick which hook updates
to apply. For each accepted suggestion, write the update directly to the hook file.

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
