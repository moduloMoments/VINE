# Hold the autonomous-role agents out of the shipped plugin payload

## Status

Accepted — 2026-06-23
Source: workflow/plugin-packaging · Actor: Rob + Claude
Supersedes: none

## Context

VINE defines four agents, in two classes. **Phase-support** agents — `vine-codebase-explorer`
(structured exploration) and `vine-verification` (validation + AC checks) — are invoked *by the VINE
skills themselves* during normal interactive use; the product doesn't run without them.
**Autonomous-role** agents — `vine-coder` (the executor: ticket → implement → journal → validate →
commit → one PR → stop-and-surface) and `vine-reviewer` (the cold-review leash) — are the
autonomous-delegation layer, the far end of VINE's route-human-attention spectrum.

The packaging question: should the autonomous-role agents ship in the default plugin payload? Two
facts say not yet.

- **No safe trigger surface exists in the product.** The autonomous roles are meant to be invoked by
  *naming them* on a ticket/PR (pending company integration), not auto-delegated — that surface
  isn't built.
- **Agent definitions have no auto-delegation gate.** There is no `disable-model-invocation`
  equivalent for agents the way skills have one; delegation is pure description-matching. A shipped
  `vine-coder` — tools `Read, Edit, Write, Bash`, description "autonomously implement… commit per
  slice… open one PR" — would therefore be a *live auto-delegation target with write authority in
  every install*, able to act unprompted. That is exactly the surprise to avoid.

## Decision

Ship only the two phase-support agents in the plugin (`plugins/vine/agents/vine-codebase-explorer.md`,
`plugins/vine/agents/vine-verification.md`). Keep `vine-coder` and `vine-reviewer` **repo-resident**
at `.claude/agents/` — the native Claude Code project-agent directory, symmetric with
`.claude/commands/` holding the unshipped contributor commands. They load for contributors (so
`/pr-review` can still spawn `vine-reviewer`) and travel to anyone who clones or forks the repo, but
they sit *outside* the plugin `source` dir (`./plugins/vine`), so they are not in the published
payload. The autonomous-delegation flow stays **opt-in** until it has both an intentional trigger
surface and a guard against accidental auto-delegation.

`vine-reviewer` is report-only (its toolset excludes Edit/Write) and so is lower-risk on its own —
but it ships-or-holds *as a pair* with `vine-coder`: it is the leash for a delegated-work flow that
isn't shipped, so shipping the leash alone would be incoherent.

## Consequences

- No write-capable autonomous agent is a default auto-delegation target in a fresh install. The
  interactive product is unchanged — the phases only ever invoked exploration + verification.
- The autonomous-delegation *design* is fully intact: the ticket convention in `.vine/context/shared.md`,
  the role recipes, and the NAVIGATION `Route`/`Actor`/Headless-Handoff schema all stand. Only the
  *packaging* is scoped — the roles are defined and runnable, just repo-resident, not shipped.
- The scoped `source` dir is the mechanism that keeps `.claude/agents/` out of the payload — the same
  lever as `2026-06-23-scope-the-plugin-payload-with-a-plugins-vine-source-dir`; there is no
  file-level exclusion, so "outside the source dir" *is* "not shipped."
- Distribution asymmetry: forking the plugin reaches the shipped skills + two phase-support agents
  (`2026-06-23-overlay-distribution-is-documentation-not-a-mechanism`); the autonomous roles travel
  by cloning/forking the *repo*, not via the marketplace.
- Revisiting this (shipping the autonomous roles) is gated on the two missing pieces existing first:
  an intentional trigger surface, and an auto-delegation guard. Until then, holding them out is the
  safe default, not a permanent exclusion.
