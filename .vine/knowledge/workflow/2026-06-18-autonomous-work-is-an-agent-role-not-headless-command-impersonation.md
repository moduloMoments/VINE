# Autonomous VINE work runs through a dedicated agent role, not an agent impersonating a headless command run

## Status

Accepted — 2026-06-18
Source: workflow/cross-actor-state · Actor: Rob + Claude
Supersedes: 2026-06-16-route-md-headless-eligibility-gate.md

## Context

The prior cycle (routing-foundation) modeled unattended execution as *a VINE phase command run
headless* — `vine:navigate` running with no human, gated at its head by an eligibility check whose
verdict it wrote to a per-feature `ROUTE.md` artifact, and steered mid-run by per-site
`<!-- decision-class: ... -->` tags scattered through every command. That model carried real weight:
ROUTE.md as an artifact in the chain (CONTEXT → SPEC → **ROUTE** → NAVIGATION), a navigate-head
routing gate, 36 decision-class tags across 8 commands, and a hardcoded `claude` autonomous
attribution. It also raised follow-on problems #79 set out to solve — slice ownership, a PROFILE.md
read-guard so an agent wouldn't self-apply a human's depth preferences, cross-machine journal checks.

The cross-actor-state inquire took that framing apart. The realization: an agent does **not** become
autonomous by pretending to be a human running a command. The Claude Code platform already provides
the right primitive — a sub-agent with a fresh isolated context, its own tool allowlist, and a
structured final message. So autonomy is better modeled as a **role** the platform runs, scoped by a
**ticket** and checked by a **PR review**, than as a command running in a degraded headless mode.
Once that is the model, most of #79's machinery dissolves: git already isolates one-ticket→one-branch→
one-PR units (no cross-actor live-state race to model); the agent role simply has no profile-read step
(no read-guard needed); and ROUTE's entire payload (verdict, allowlist, constraints, validation
baseline, input basis) has a home in {the ticket, git/the PR, the `## Validation` block in
`.vine/context/shared.md`}.

## Decision

VINE ships two **agent-role recipes** (standard Claude Code sub-agent definitions in `agents/`):

- **`vine-coder`** — implements a ticketed SPEC slice end-to-end and opens one PR. It derives its own
  bounded touched-file discipline (the leash ROUTE's allowlist used to carry), syncs the NAVIGATION
  journal per slice, runs the repo's `## Validation` contract, and commits per slice.
- **`vine-reviewer`** — cold-reviews delivered work; report-only, with `tools` excluding Edit/Write so
  the "never edit, never commit" boundary is *mechanically* enforced, not merely asserted in prose.

The **ticket is the authorization** — it carries scope (which slice), a SPEC pointer, and
constraints, and names `vine-coder`. The **PR review is the leash.** No pre-committed per-feature
route artifact is needed, so `ROUTE.md` retires from the artifact chain (chain is now
CONTEXT → SPEC → NAVIGATION → EVOLUTION; downstream `ROUTE.md` files are inert and may be deleted).
`vine:navigate` becomes **interactive-only** — its headless-execution prose and routing gate are
removed. The decision-handling that the per-site `decision-class` tags encoded relocates into
`vine-coder`'s recipe as **judgment applied at runtime** (`default-able` → take the recommended
option and log it; `human-required` → stop and surface in the PR/handoff, never via `AskUserQuestion`
which sub-agents cannot call), so all 36 tags were removed and the **Decision Delegation** policy in
`shared.md` was reframed to governance the agent applies rather than a per-command tag roster.

The two-class split itself (`default-able` vs `human-required`, see
`2026-06-16-decision-delegation-default-able-vs-human-required.md`) is **unchanged and still in
force** — only its *delivery mechanism* moved from inline tags to agent judgment, and its *pairing*
moved from ROUTE.md to the ticket.

## Consequences

- VINE owns the **role recipes and the ticket convention**; the platform owns **how the role is
  invoked** (the sub-agent, a GitHub trigger). VINE never implements an agent runner.
- The cold-actor property comes **for free** from sub-agent isolation: a non-fork sub-agent loads
  CLAUDE.md + the memory hierarchy + a git-status snapshot but not the session conversation and not
  the Engineer Profile step — so no human-depth calibration leaks in, with no read-guard to maintain.
- Authority boundaries get **mechanical teeth**: `vine-reviewer` cannot write because its toolset
  cannot; `vine-coder` gets the least-privilege implement-and-commit set.
- Retiring `ROUTE.md` one cycle after shipping it is a **deliberate reversal, not debt** — a migration
  note in `references/STATE.md` discharges the downstream obligation.
- The `**Route**`/`**Actor**` journal *fields* are kept (see
  `2026-06-18-keep-route-actor-journal-fields.md`) — the *artifact* retired, the *vocabulary* earns
  its keep as the marker the autonomous actor writes for the reviewer.
