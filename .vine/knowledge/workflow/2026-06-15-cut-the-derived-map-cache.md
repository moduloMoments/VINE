# Cut the derived-map cache; keep decisions as committed markdown

## Status

Accepted — 2026-06-15
Source: workflow/brain-descope · Actor: Rob + Claude
Supersedes: none

## Context

Early VINE designs imagined a "bespoke brain" — a persistent, VINE-maintained map of the
codebase (structure, call graphs, where-is-X) that commands would read instead of exploring.
The trouble is that every fact in such a map is *recoverable from the code itself*, so the
cache goes stale the moment the code changes, and keeping it fresh costs tokens and erodes
trust the instant it's wrong. Meanwhile the genuinely valuable, non-recoverable thing — *why*
an approach was chosen over its alternatives, and hard-won gotchas — had no durable home at
all. #96 (descope the bespoke brain to a durable-decisions convention) is the PR that made
the call.

## Decision

Cut the derived-map cache entirely. Facts recoverable from the code regenerate on demand via
agentic search (the "Source of Truth vs Derived Views" discipline). Persist only
non-regenerable *judgment* — decisions and gotchas — as committed markdown, one file per
record, under `.vine/knowledge/<domain>/`. This became the Durable Decisions & Gotchas
convention in `references/STATE.md`.

## Consequences

- **Nothing goes stale.** There is no cache to invalidate; regenerable facts are never stored,
  so they can't drift.
- **Durable judgment becomes first-class** and travels with the repo (tracked by default).
- **Capture is now a deliberate step**, not an automatic byproduct: `vine:evolve` distills
  records on engineer approval rather than a background process maintaining a map.
- Established the broader Source-of-Truth-vs-Derived-Views principle that later shaped the
  journal/live-view split and PROJECT-MAP's "derived view, not second source" status.
