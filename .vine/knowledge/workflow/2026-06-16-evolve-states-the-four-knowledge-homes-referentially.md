# Evolve states the four knowledge homes referentially, not by physical adjacency

## Status

Accepted — 2026-06-16
Source: workflow/durable-decisions · Actor: Rob + Claude
Supersedes: none

## Context

VINE routes every learning a cycle produces to exactly one of four homes — `.vine/knowledge/`
(durable judgment), `CLAUDE.md` (repo facts every session needs), `.vine/context/shared.md`
(cross-phase protocol), `.vine/PROFILE.md` (per-engineer depth). The durable-decisions cycle added
the fourth home and a single routing rule to disambiguate them. The spec asked to keep "the four
homes adjacent so the routing rule can be stated once right before them." Read literally, that
means restructuring `commands/vine/evolve.md` — hoisting all four routing flows into one preamble
before Evolution 2. `evolve.md` is already a long command carrying three separate routing flows
(CLAUDE.md Suggestions, Context Overlay Update, Update Engineer Profile); a restructure of that
size is high-risk churn against a file the trellis gate and many `step N` cross-references depend on.

## Decision

Satisfy "state the routing rule once, keep the homes adjacent" *referentially*, not *physically*.
The new `### Distill Durable Decisions` step lands at the end of Evolution 3 (after the three
existing flows run), and its head states the one five-step routing rule that *names* all four homes,
each tagged with the existing evolve step that already handles it. The four homes are adjacent in
the rule's text, not in the command's section layout. This meets AC4 ("single routing rule,
operative inline") without restructuring evolve into a fourth full flow — exactly the anti-bloat
mitigation the spec itself called for.

## Consequences

- A cold reader of `evolve.md` sees one routing rule naming all four homes at the Distill step head;
  they cannot recover from the diff *why* it wasn't hoisted into a preamble — that judgment lives
  here.
- No renumbering of evolve's steps, so no ripple through `references/STATE.md` or the command's own
  `step N` cross-references — the drift the trellis gate (Check 10) exists to catch.
- The "state once" goal is met by a rule that enumerates the homes, establishing the pattern that a
  shared rule referenced from one place beats the same rule physically co-located with each consumer.
- Trade-off: the four routing flows remain physically scattered across Evolutions 2–3, so a reader
  following the command top-to-bottom meets the homes one at a time before the unifying rule. The
  rule's up-front enumeration is what keeps that from being confusing.
