---
name: triage
description: "Check GitHub issues, surface priorities, and discuss next steps"
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
  - AskUserQuestion
---

# triage — GitHub Issue Prioritization

## Fetch Open Issues

Run `gh issue list` to pull all open issues for this repo. Include labels, assignees, and timestamps:

```
gh issue list --state open --limit 50 --json number,title,labels,assignees,createdAt,updatedAt,milestone,body
```

If the command fails (no `gh` CLI, not authenticated, no remote), tell the user what went wrong and stop.

## Categorize and Prioritize

Sort the issues into priority tiers based on these signals (strongest first):

1. **Labels** — `bug`, `critical`, `security`, `blocking` rank highest; `enhancement`, `feature` mid; `idea`, `nice-to-have`, `question` lowest
2. **Milestone assignment** — issues in a milestone outrank unassigned ones
3. **Age** — older issues get a small boost (they've been waiting)
4. **Assignee** — unassigned issues are more actionable for the current user

If there are no priority-signaling labels, fall back to age + milestone only and note that labeling would help future triage.

## Present the Triage Summary

Show a concise summary grouped by tier:

### 🔴 High Priority
- `#N` — Title (labels, age)

### 🟡 Medium Priority
- `#N` — Title (labels, age)

### 🟢 Low Priority / Ideas
- `#N` — Title (labels, age)

Include a one-line count: "X open issues: H high, M medium, L low"

## Discuss Next Steps

Use `AskUserQuestion` to ask the user what they'd like to do:

- **Pick an issue to work on** — ask which one, then read its full body with `gh issue view <number>` and suggest an approach (which VINE command to start with, or direct implementation for small fixes)
- **Bulk label/organize** — help apply labels to unlabeled issues
- **Close stale issues** — identify and suggest closing issues that are outdated
- **Create a new issue** — help draft one based on conversation context

When the user picks an issue to work on, read the full issue body and:
1. Summarize what needs to happen
2. Assess scope (trivial fix, small feature, or larger effort)
3. Recommend starting point — for larger efforts suggest `/vine:verify`, for small features `/vine:inquire`, for trivial fixes just start coding
