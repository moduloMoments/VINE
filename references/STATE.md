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
## Author: [human] + Claude

### Codebase Landscape
- Relevant modules and their responsibilities
- Key patterns and conventions in use
- Dependencies and integration points

### Current State
- What works today
- Known tech debt in affected areas
- Recent changes that matter

### Edge Cases & Tribal Knowledge
- Things the engineer knows that aren't documented
- Gotchas, workarounds, historical context
- "Here be dragons" areas

### README/Doc Gaps Identified
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

### Problem Statement
- What we're solving and why

### Proposed Approach
- Architecture and design decisions
- Options considered with tradeoffs
- Human's chosen direction and rationale

### Acceptance Criteria
- Verifiable conditions for "done"
- Edge cases explicitly handled
- Performance/security considerations

### Work Slices
- Ordered, independent units of work
- Each with clear inputs/outputs
- Estimated complexity signals

### Tech Debt Integration
- Debt items from CONTEXT.md addressed in this work
- Debt items deferred (with reasoning)
- New debt being consciously taken on

### Backlog Updates
- Items to add/modify in project backlog
- Dependencies on other work
```

### NAVIGATION.md (produced by vine:navigate)

The implementation journal. Documents what was built, why deviations happened, and what the human learned.

```markdown
# Navigation Log: [Feature Name]
## Date: [YYYY-MM-DD]

### Completed Slices
For each work slice:
- What was implemented
- Deviations from spec (and why)
- Human decisions made during implementation
- Key code patterns introduced

### Staged Changes
- Files modified (not committed)
- Diff summary
- Suggested commit message(s)

### Learnings (Bidirectional)
- What the human learned from the AI
- What context the human provided that shaped implementation
- Patterns worth documenting

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
- Verification results against acceptance criteria
- Quality assessment
- Suggested follow-up work

### Agent Evolution
- CLAUDE.md updates suggested
- New skills or skill improvements identified
- Workflow patterns worth codifying

### User Evolution
- New knowledge or patterns the user encountered
- Areas for deeper learning
- Suggested resources or explorations

### Handoff
- Summary for PR description
- Reviewer notes
- Context for future sessions on this feature
```

## Chaining Protocol

Each phase ends with a **Next Step Suggestion** that tells the user exactly what to run next and why:

```
---
✅ vine:verify complete → CONTEXT.md written
📋 Suggested next step: Run `vine:inquire` to build the feature spec on top of this context.
   Key items for inquire to address: [list open questions from CONTEXT.md]
---
```

This is a suggestion, not an auto-trigger. The human decides when to proceed.
