---
name: pr
description: "Create a PR using the repo's template and contributing guidelines"
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
  - AskUserQuestion
---

# pr — Template-Aware Pull Request Creation

## Step 1: Understand Current State

Run these commands to gather context:

1. `git status` — check for uncommitted changes (warn if any exist)
2. `git log main..HEAD --oneline` — see all commits on this branch
3. `git diff main...HEAD --stat` — see which files changed

If the current branch is `main`, stop and tell the user to create a feature branch first.

If there are uncommitted changes, ask whether to proceed or commit first.

## Step 2: Load the PR Template

Read `.github/PULL_REQUEST_TEMPLATE.md` if it exists. This is the structure the PR body must follow.

If no template exists, use a minimal format:

```
## What

## Why

## How to test
```

## Step 3: Load Contributing Guidelines

Read `CONTRIBUTING.md` if it exists. Extract the PR submission rules — these inform what to check and how to frame the PR.

Key rules from VINE's contributing guide:
- Branch from `main`
- Keep changes focused — one concern per PR
- Run `/trellis` to validate structural conventions across command files
- Test commands in an actual VINE cycle if changing behavior
- Describe what you changed and why

## Step 4: Analyze Changes and Draft

Read `git diff main...HEAD` to understand the full diff. Then:

1. **Categorize the change** — is this a command behavior change, docs update, new contributor tool, bug fix, or structural change?
2. **Check focus** — if changes span multiple unrelated concerns, warn the user and suggest splitting.
3. **Check for command changes** — if any files in `commands/vine/` were modified, note that `/trellis` validation and VINE cycle testing are expected.

**Check for related issues** — scan the open issues (`gh issue list --state open`) for any that
this PR resolves. Match by topic, keywords, or explicit references in commit messages. If a
match is found, include `Closes #N` in the Why section. Use `AskUserQuestion` to confirm the
match before adding it — don't silently close issues.

Draft the PR body by filling in the template sections:
- **What** — concise summary of what changed
- **Why** — motivation, link to issue if one exists. Include `Closes #N` for issues this PR resolves.
- **How to test** — specific steps a reviewer can follow
- **Checklist** — pre-check items based on what actually changed (only check the box for VINE cycle testing if command behavior was modified)

## Step 5: Confirm with User

Use `AskUserQuestion` to present the draft PR title and body. Ask:

- Does the title capture the change? (suggest a concise title under 70 chars)
- Does the body look right? Any context to add?
- Ready to create, or want to edit?

Options: **Create PR (Recommended)**, **Edit title/body**, **Cancel**

## Step 6: Create the PR

Push the branch and create the PR:

```
git push -u origin HEAD
gh pr create --title "<title>" --body "<body>"
```

After creation, display the PR URL.

If the change touches areas listed under "What's not ready for contribution yet" in CONTRIBUTING.md (new phases/commands, core phase flow, CI/automation), add a note in the PR body acknowledging this and reference any related issue discussion.
