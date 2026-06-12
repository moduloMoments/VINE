# Project Map: Coordination Spike (Cycle 0)
## Feature: .vine/projects/workflow/coordination-spike
## Created: 2026-06-11

### VINE Progress

| Phase | Status | Updated |
|-------|--------|---------|
| verify | ✅ | 2026-06-11 |
| inquire | ✅ | 2026-06-11 |
| navigate | ✅ | 2026-06-12 |
| evolve | ✅ | 2026-06-12 |

### Route <!-- throwaway scaffold (cycle-0 spike, Q1/Q6): scope-level route attribution; keep/discard at evolve -->

| Scope | Route | Actor | Gate record | Outcome |
|-------|-------|-------|-------------|---------|
| Spike artifacts (this feature) | interactive | Rob + Claude (shepherd) | n/a — shepherd default | cycle complete — EVOLUTION.md written 2026-06-12 |
| #47 consolidate AskUserQuestion constraints (delegated) | headless — Agent-tool subagent into worktree off `e017fca` (4th mechanism; 3 informative failures first — journal Slice 2) | claude (headless subagent) | PERMIT — NAVIGATION.md Slice 1, four-leg verdicts | delivered — `bfe5458`; reviewed: **request changes** (F1 init.md gap — journal Slice 3) |
| #47 review (delegated) | headless — Agent-tool subagent, cold context, recipe = `.vine/context/review.md` | claude (cold reviewer) | n/a — reviewer leg, read-only authority | report delivered — 4 findings + missing-context log + derived PR description (journal Slice 3) |
| #47 re-entry fix F1 (delegated) | headless re-entry — Agent-tool subagent, reviewer-triggered, durable envelope `delegation-prompt-47-reentry.md` | claude (re-entry actor) | inherited PERMIT + reviewer request-changes as trigger | delivered — `030836f` + `56856d5`, shepherd-verified (journal Slice 3) |
