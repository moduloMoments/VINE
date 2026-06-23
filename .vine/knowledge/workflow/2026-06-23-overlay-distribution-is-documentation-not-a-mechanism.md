# Overlay distribution is documentation, not a VINE mechanism — overlays are consumer-owned

## Status

Accepted — 2026-06-23
Source: workflow/plugin-packaging · Actor: Rob + Claude
Supersedes: none

## Context

The team-layer record (`2026-06-22-vine-ships-a-team-layer-recommendation-not-a-prescribed-mechanism`,
from cycle #52 — the personal/local split + team-overlay recommendation) deferred "cross-repo
distribution of overlays" to the plugin cycle (#57) and named the team-overlay recommendation as
"the explicit seam where plugin distribution attaches." That phrasing set an expectation that #57
would *attach a mechanism* at that seam — some way for a plugin to carry overlay content into a
consumer's repo.

Examining it during #57 dissolved the expectation. Overlay *content* is 100% consumer-owned: each
repo's `.vine/context/shared.md` encodes that repo's conventions, tools, and policy — there is no
VINE-authored overlay to ship. And a plugin has no native slot for delivering an arbitrary context
file into a consumer's working tree; the plugin payload is skills, agents, and hooks, none of which
is a repo's `.vine/context/`. The "seam" was a documentation boundary, never a hook for a feature.

## Decision

VINE ships **no overlay-distribution mechanism**. Overlay content stays repo-local and
consumer-authored. A company that wants conventions to travel across repos does so by **forking the
plugin and editing its skills/agents** — those distribute natively through the marketplace — while
each repo's `.vine/context/` overlays remain its own. The "harder half" of #57 is resolved by
scoping it out: the deliverable is documentation (README's solo→team graduation path, the team
recommendation in `shared.md`) plus this record — not a `vine:team`-style feature.

This **amends the team-layer record's seam expectation**: the seam carries documentation, not a
mechanism. An Amendment on that record points here so a reader doesn't trust the original "plugin
distribution attaches" wording as a promise of machinery.

## Consequences

- A cold reader who expected #57 to deliver overlay distribution learns here it was deliberately a
  non-feature — consumer-owned by nature, not overlooked. This is the repo-owned-decisions
  principle applied: don't ship a feature whose entire behavior is consumer-supplied config.
- The solo→team graduation path is documented as: commit `shared.md`, mark enforced sections
  `<!-- class: policy -->`, fork the plugin for cross-repo reach. No new file format, no command.
- Nothing is parked in the backlog for an overlay-distribution feature; reviving one needs a fresh,
  concrete need (the same bar the team-layer record set for a multi-team composition engine).
- Pairs with the plugin-only decision
  (`2026-06-23-vine-ships-as-a-plugin-and-drops-npx`): forking the plugin is the cross-repo
  reach, precisely because skills and agents are what the plugin distributes.
