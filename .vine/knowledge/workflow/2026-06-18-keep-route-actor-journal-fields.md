# The Route/Actor journal fields stay as cross-actor attribution markers after ROUTE.md retires

## Status

Accepted — 2026-06-18
Source: workflow/cross-actor-state · Actor: Rob + Claude
Supersedes: none

## Context

The cross-actor-state cycle retired `ROUTE.md` the artifact and made every VINE command
human-triggered-only (see
`2026-06-18-autonomous-work-is-an-agent-role-not-headless-command-impersonation.md`). NAVIGATION.md's
per-slice journal entry carries three fields born of the old headless model:
`**Route**` (`interactive | headless | headless-reentry`), `**Actor**` (who produced the slice;
readers default a missing value to `human`), and a `**Decisions Taken Autonomously**` block plus the
Headless Handoff. The obvious move during the sweep was to rip all of these out alongside the artifact
and the headless prose — they look like residue of the thing being retired.

The judgment call was whether the fields are *vocabulary of the retired mechanism* (delete) or
*independently useful* (keep). A reverse-checklist sweep that deletes by association would have torn
out a still-useful field by accident — exactly the trap the SPEC flagged as a "conscious call, not a
side effect of the ROUTE.md grep."

## Decision

**KEEP** the `**Route**`/`**Actor**`/`**Decisions Taken Autonomously**`/Headless-Handoff journal
fields (all `<!-- optional -->`, reader-defaulted), and broaden the `**Actor**` template so its
purpose is explicit. The deciding rationale (Rob's): `**Actor**` attributes a slice to *whoever*
produced it — a specific person when several share one repo (the E2 "committed shared" environment),
or the autonomous `vine-coder` agent. That generalizes beyond human-vs-bot, which is what makes the
field earn its place on a shared repo regardless of whether anything runs headless. And the fields
have a **live writer**: `vine-coder` populates `**Route**: headless` / `**Actor**: vine-coder` and
writes the Headless Handoff when it stops on a `human-required` decision — they are the marker
`vine-reviewer` keys on to find autonomously-produced work.

`vine:navigate` (human, interactive) legitimately *omits* the fields — graceful absence means
`interactive`/`human` — so the trimmed navigate journal template and the kept STATE.md schema are
consistent, not contradictory.

## Consequences

- Retiring an artifact is cheaper than retiring its *vocabulary*: `ROUTE.md` the file went cleanly,
  but "headless" survives as accurate language for what a `vine-coder` run *is*, so the journal schema
  keeps it.
- The fields are the cross-actor seam the whole #79 cycle was nominally about — gutting them would
  have removed the one piece of multi-actor attribution that survives the reframe.
- trellis Check D (the `**Route**`-field shape check) is kept; only its ROUTE.md/PROJECT-MAP
  cross-references were scrubbed.
- A cold reader who finds "headless" fields in a "no headless command" framework now has this record
  explaining why — without it, the fields read as a missed cleanup.
