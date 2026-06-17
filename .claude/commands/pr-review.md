---
name: pr-review
description: "Simulate a PR-reviewer auto-agent against a real PR — drive the review.md role recipe through a cold-reviewer subagent and surface its report"
argument-hint: "[PR number or URL]"
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
  - Agent
  - AskUserQuestion
---

# pr-review — Dogfood the review.md Reviewer Flow

This is a contributor-only tool. It does **not** ship as part of the VINE product. It exists to
**validate the `review.md` role recipe** by exercising it exactly the way an external PR-reviewer
auto-agent (e.g. a GitHub Action running Claude) would once it lands: take a real PR, hand a
cold-context subagent nothing but the durable state and the `review.md` recipe, and see whether it
can produce a sound review. The recipe's **Missing context log** is the validation signal — an empty
log means durable state carried enough; a non-empty one names exactly what `review.md` or the
artifacts failed to carry.

The reviewer subagent **reports only** — it never edits, commits, or comments. This command (acting
for you) is what optionally relays the report to the PR. That split mirrors `review.md`'s authority
boundary on purpose.

## Step 1: Resolve the PR

If a PR number or URL was passed as an argument, use it. Otherwise run:

```
gh pr list --state open --limit 20 --json number,title,headRefName,author,updatedAt
```

and use `AskUserQuestion` to let the contributor pick which PR to review.

Fetch the PR's metadata and check it out so the subagent can read artifacts and commits locally:

```
gh pr view <N> --json number,title,body,headRefName,baseRefName,author,url,closingIssuesReferences,files
gh pr checkout <N>
```

If `gh` is missing, unauthenticated, or there's no remote, report what went wrong and stop.

Capture for the subagent prompt: PR number + URL, head branch, base branch, the linked
issue(s) from `closingIssuesReferences` (or any `#N` references in the PR body), and the changed
file list.

## Step 2: Load the Role Recipe and Overlays

Read the files that seed the reviewer. These ARE the contract under test — pass them verbatim, don't
paraphrase:

1. `.vine/context/review.md` — the reviewer role recipe (orientation order, what to scrutinize, what
   to produce, the authority boundary). With a legacy `.vine/hooks/review.md` fallback through 0.4.x.
2. `.vine/context/shared.md` — the shared collaboration/profile/workflow overlay every VINE actor loads.

If `review.md` is absent, stop — there's nothing to validate.

## Step 3: Spawn the Reviewer Subagent

Spawn one subagent (Agent tool, `general-purpose` type) that plays the cold reviewer. Its prompt is:

- The full text of `review.md` and `shared.md` from Step 2, introduced as "This is your role recipe
  and shared operating context. Follow them exactly."
- The PR pointers from Step 1 (number, URL, head/base branch, linked issue(s), changed files) —
  **only pointers**, not a summary of the change. The whole point is to make the subagent orient from
  durable state the way an auto-agent must.
- A closing instruction: "You were not part of the session that produced this work. Orient strictly
  in the recipe's orientation order. Re-run cheap validation the recipe asks for. Produce the report
  in the recipe's 'What to Produce' shape. Log every missing fact as you hit it. Report only — do not
  edit, commit, or comment on the PR."

The subagent uses `gh pr diff`, `git log`/`git show`, and reads the feature's
`.vine/projects/<domain>/<feature-slug>/` artifacts and the originating issue to do its work.

Do not coach it mid-flight or supply context it didn't find — that would contaminate the validation.
Let it record gaps in its Missing context log instead.

## Step 4: Present the Report

Relay the subagent's report to the contributor in the recipe's structure: Verdict, Findings, Missing
context log, Sources consulted, Draft PR description.

Then add a short **review.md validation read-out** of your own — this is the reason the tool exists:

- **Missing context log** — empty (recipe + artifacts sufficient) or, if not, list each gap as a
  candidate fix to `review.md`, `references/STATE.md`, or the artifact templates.
- **Orientation friction** — did the subagent follow the orientation order cleanly, or did any step
  (issue → ROUTE.md → artifact dir → commits → final files) dead-end?
- **Output completeness** — were all five "What to Produce" sections derivable, especially the Draft
  PR description (could it be built mechanically from the handoff, or did it need fresh authoring)?

## Step 5: Optionally Relay to the PR

Posting to the PR is outward-facing — never automatic. Use `AskUserQuestion`:

- **Don't post (Recommended)** — keep the report local; this was a validation run.
- **Post as a PR comment** — relay the report via `gh pr comment <N> --body "<report>"`, simulating
  an auto-reviewer leaving feedback. Confirm the body before sending.

Never use `gh pr review --approve/--request-changes` from this tool — the reviewer's authority is to
report, and a contributor-run simulation shouldn't cast a real review verdict.

## Anti-Patterns

- **Don't pre-digest the PR for the subagent.** Pointers only. If you summarize the change, you've
  defeated the cold-reviewer simulation and the Missing context log goes artificially empty.
- **Don't let the subagent edit or commit.** It reports. Relaying is your action, gated by Step 5.
- **Don't fix `review.md` gaps inside this run.** Capture them in the validation read-out; fixing the
  recipe is separate work (a `pair` or `navigate` change), so the validation signal stays clean.
