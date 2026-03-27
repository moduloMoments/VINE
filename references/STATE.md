# VINE State Reference

This document defines the state artifacts that flow between VINE phases. Each phase reads from the previous phase's output and writes its own artifacts. State is file-based and human-readable so context survives across sessions, handoffs, and team members.

## Directory Structure

All artifacts live under `.vine/<domain>/<feature-slug>/` in the project root. The domain is the logical area the feature touches (e.g., `payments`, `auth`, `onboarding`). The feature slug is a short, lowercase, hyphenated name for the specific work (e.g., `webhook-support`, `retry-logic`). Both are confirmed with the engineer during vine:verify via structured select prompts.

This two-level namespacing allows multiple features to be VINEd concurrently without collision — even features in the same domain. It also provides discoverability: `ls .vine/payments/` shows all payment-related VINE work at a glance.

## State Files

### CONTEXT.md (produced by vine:verify)

The landscape document. Captures what exists, what's broken, what the codebase doesn't tell you but the engineer knows.

```markdown
# Feature Context: [Feature Name]
## Date: [YYYY-MM-DD]
## Author: [engineer name] + Claude

### Codebase Landscape
- Relevant modules and their responsibilities
- Key patterns and conventions in use
- Dependencies and integration points

### Current State
- What works today
- Recent changes that matter

### Edge Cases & Tribal Knowledge
- Things the engineer knows that aren't documented
- Gotchas, workarounds, historical context
- "Here be dragons" areas

### Tech Debt in Affected Areas
- Known debt in modules this feature will touch
- Debt that may affect implementation choices

### Documentation Gaps
- Documentation that needs updating
- Missing architectural decision records
- Stale comments or misleading docs

### Open Questions
- Unresolved ambiguities for vine:inquire to address
```

### SPEC.md (produced by vine:inquire)

The feature specification. Built on top of CONTEXT.md — not from scratch.

```markdown
# Feature Spec: [Feature Name]
## Date: [YYYY-MM-DD]
## Built on: CONTEXT.md ([date])
## Decisions made by: [engineer name]

### Problem Statement
- What we're solving and why

### Approach
- Chosen architecture with rationale
- Key decisions and why they were made

### Acceptance Criteria
- Verifiable conditions for "done"
- Edge cases explicitly handled
- Performance/security considerations

### Work Slices
Ordered, independent units of work:

#### Slice 1: [Name]
- **Goal**: What this slice accomplishes
- **Depends on**: Previous slices or nothing
- **Files likely touched**: [list]
- **Acceptance criteria**: [specific, verifiable]
- **Complexity signal**: Low / Medium / High + brief rationale

#### CONDITIONAL Slice: [Name]
- **Condition**: Only if [condition from verify findings]
- (same fields as above)

For larger features, slices are grouped into phases:
- **Phase 1**: Core functionality (slices 1-3)
- **Phase 2**: Edge cases and polish (slices 4-5)

### Tech Debt Integration
- Debt items from CONTEXT.md addressed in this work
- Debt items deferred (with reasoning)
- New debt being consciously taken on

### Dependencies & Risks
- External dependencies or blockers
- Risk factors and mitigations

### Backlog Updates
- Items to add/modify in project backlog
- Dependencies on other work
```

### NAVIGATION.md (produced by vine:navigate)

The implementation journal. Built incrementally — each slice is appended as it's completed, with a commit per validated slice.

```markdown
# Navigation Log: [Feature Name]
## Date: [YYYY-MM-DD]

### Slice 1: [Name]
- **Started**: [timestamp]
- **Commit**: [hash] (or 'pending' if in progress)
- **Approach taken**: What was implemented and how
- **Deviations from spec**: Any changes and why
- **Validation**: [pass/fail — lint, typecheck, tests]
- **Decisions made**: Engineer choices during implementation
- **Acceptance criteria**: [met/not met with details]
- **Engineer feedback incorporated**: [what the engineer corrected or steered]
- **Learnings**: What both sides learned from this slice

### Slice 2: [Name]
(same structure, appended after slice 1 is committed)

### Remaining Work
- Incomplete slices
- Blockers encountered
- Handoff context for next session
```

### EVOLUTION.md (produced by vine:evolve)

The triple evolution report. Captures growth across product, agent, and user.

```markdown
# Evolution Report: [Feature Name]
## Date: [YYYY-MM-DD]

### Product Evolution
- **Acceptance Criteria Results**: [pass/fail table for each criterion]
- **Spec Deviations**: [list with rationale]
- **Follow-Up Items**: [concrete backlog suggestions]

### Agent Evolution
- **CLAUDE.md Suggestions**: Updates to project instructions
- **Command Suggestions**: New commands or improvements identified
- **Workflow Improvements**: Patterns worth codifying
- **Hook Update Suggestions**: Updates to .vine/hooks/ based on learnings
- **VINE Process Observations**: What worked, what to adjust

### User Evolution
- **Knowledge Highlights**: New patterns or concepts the engineer encountered
- **Suggested Explorations**: Areas for deeper learning

### Handoff Package
- **PR Description**: [ready to paste]
- **Reviewer Notes**: Context for code reviewers
- **Commit Suggestions**: [if changes aren't already committed]
- **Context for future sessions**: What someone picking this up should know
```

## Chaining Protocol

Each phase ends with a **Next Step Suggestion** that tells the user exactly what to run next and why. Each phase also suggests starting a fresh session (`/clear`) so state flows through `.vine/` files rather than chat context:

```
---
✅ vine:verify complete → CONTEXT.md written
📋 Suggested next step: /clear, then run /vine:inquire to build the feature spec on top of this context.
   Key items for inquire to address: [list open questions from CONTEXT.md]
---
```

This is a suggestion, not an auto-trigger. The engineer decides when to proceed.
