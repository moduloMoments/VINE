---
name: triage
description: "Scan GitHub issues to find what to work on next — surface open bugs, feature requests, and priorities, then discuss which to tackle"
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

## Consult the Roadmap (if present)

`gh issue list` answers "which open issue is highest priority." It does not answer "what cycle do I build next." When this repo carries a `ROADMAP.md` with a `### Cycle order` table, read it to add that sequence dimension.

This step is **VINE-on-VINE only and degrades gracefully**: check for `ROADMAP.md` first with Glob or `Read`. If it is absent (any repo that isn't this one), skip this section entirely and go straight to Discuss Next Steps — `triage` behaves exactly as the issue-priority tool it is without it. Never treat `ROADMAP.md` as a dependency.

When `ROADMAP.md` is present:

1. Read the `### Cycle order` table and the prose above it (a "Done so far" note records which cycles have shipped). The table columns are `#`, `Cycle`, `Issues`, `Mode`, and a rationale column; issue references appear as `#N` links in the `Issues` column.
2. Map the open milestone issues from the fetch above to their cycle by matching issue numbers against the `Issues` column. Issues with no cycle match are roadmap-unplaced (still triaged by priority, just not part of the sequence).
3. Surface the sequence position, not just the priority ranking:
   - **Current position** — the latest shipped cycle (from the "Done so far" note) and which cycle is next in line.
   - **Next cycle** — its name, its open issues (with numbers), and the one-line "why this order" rationale from the table.
   - **Side-track items runnable now** — rows marked as a side-track or "anytime" mode (e.g. a maintenance side-track), with the condition that unblocks them. Call these out separately so a contributor finishing a cycle sees what can run in parallel.

Present this as a short "Roadmap sequence" block after the priority tiers. Keep it to the current position, the next cycle, and any runnable side-track items — do not restate the whole table.

## Discuss Next Steps

Use `AskUserQuestion` to ask the user what they'd like to do:

- **Pick an issue to work on** — ask which one, then read its full body with `gh issue view <number>` and suggest an approach (which VINE command to start with, or direct implementation for small fixes). When a roadmap sequence was surfaced above, lead with the next cycle's issues and any runnable side-track items as the recommended picks
- **Bulk label/organize** — help apply labels to unlabeled issues
- **Close stale issues** — identify and suggest closing issues that are outdated
- **Create a new issue** — help draft one based on conversation context

When the user picks an issue to work on, read the full issue body and:
1. Summarize what needs to happen
2. Assess scope (trivial fix, small feature, or larger effort)
3. Recommend starting point — for larger efforts suggest `/vine:verify`, for small features `/vine:inquire`, for trivial fixes just start coding
