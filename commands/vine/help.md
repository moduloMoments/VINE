---
name: vine:help
description: "Show available VINE commands and quick usage guide"
argument-hint: ""
allowed-tools:
  - Read
  - Glob
  - AskUserQuestion
---

# vine:help — VINE Command Reference

Display a quick reference of all VINE commands, what they do, and when to use them. No hooks
or profile loading needed — this is a pure reference command.

## Display Command Reference

Print the following reference block:

```
---
🌱 VINE — Verify, Inquire, Navigate, Evolve

Core phases (run in order for each feature):
  /vine:verify   [feature]    Context-building spike — explore the codebase together
  /vine:inquire  [feature]    Feature spec and design — build the spec on verified context
  /vine:navigate [feature]    Guided implementation — build the feature slice by slice
  /vine:evolve   [feature]    Triple evolution — verify, capture learnings, prep handoff

Quick mode:
  /vine:pair     [file/task]  Lightweight pair programming — quick fixes without artifacts

Session management:
  /vine:pause    [feature]    Capture where you stopped and why
  /vine:resume   [feature]    Pick up where you left off with full context
  /vine:status   [feature]    Quick read-only progress check

Setup:
  /vine:init                  Scaffold .vine/hooks/ for this repo
  /vine:help                  This reference

Typical flow:
  1. /vine:init              (once per repo)
  2. /vine:verify            (explore the landscape)
  3. /vine:inquire           (design the feature)
  4. /vine:navigate          (build it together)
  5. /vine:evolve            (verify, learn, ship)

Quick fix:
  /vine:pair src/auth.ts     (one command, one commit)

Tips:
  • Run /clear between phases — state flows through .vine/ files, not chat context
  • Use approve-edits mode — VINE is cooperative, not autonomous
  • Feature arguments are optional — VINE finds active projects automatically
  • Browse .vine/projects/ to see artifacts from past features
---
```

## Handle Questions

If the engineer asks a follow-up question about a specific command, read that command file
from `commands/vine/` (or `~/.claude/commands/vine/` for global installs) and give a concise
summary of what it does, its key sections, and when to use it.

Use `AskUserQuestion` if the engineer seems unsure which command fits their situation:

> "What are you trying to do?"

Options tailored to common scenarios:
1. "Start a new feature (Recommended)" — "Run /vine:verify to explore the codebase first"
2. "Quick fix or small change" — "Run /vine:pair for lightweight pair programming"
3. "Pick up where I left off" — "Run /vine:resume to see your progress and next step"
4. "Check progress on a feature" — "Run /vine:status for a quick read-only check"
