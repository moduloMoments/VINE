# VINE ships a team-layer recommendation, not a prescribed team-overlay mechanism

## Status

Accepted — 2026-06-22 (amended 2026-06-23, #57 — the seam carries documentation, not a mechanism; see *Amendment* below)
Source: workflow/team-layer · Actor: Rob + Claude
Supersedes: 2026-06-16-defer-the-vine-gitignore-inversion-to-the-vine-local-work

## Context

Issue #52 ("Team layer") was originally scoped as a *mechanism*: VINE would ship named team-overlay
files (`context/teams/<name>.md`), a `vine:team` command to add/update them, and a cross-team
precedence engine resolving N team layers against the repo and personal overlays. The premise was
"team conventions should install with the project."

Two facts undercut the mechanism. First, team structure varies org to org — an engineer can belong
to platform *and* payments at once, with no canonical shape VINE can prescribe without imposing one
team's model on every adopter (the repo-owned-decisions principle: don't ship a feature whose entire
behavior is repo-supplied config). Second, the primitives a team layer needs already exist: a tracked
repo overlay (`.vine/context/shared.md`) that travels with the repo, and the `<!-- class: policy -->`
marker that makes a section immutable from the personal `.vine.local/` layer (a personal overlay
cannot weaken a policy-class section). A team that wants enforced conventions edits `shared.md` and
marks the governance sections policy-class — no new file format, no new command, no precedence engine.

What #52 *did* need to own is the personal/local split that makes "shared vs mine" real, and that is
what it ships: a gitignored sibling root `.vine.local/` mirroring `.vine/` (profile, personal
overlays, the `ACTIVE` sentinel, pause state, local-only projects); the track-by-default `.gitignore`
inversion (#108) that the prior deferral record gated specifically on this `.vine.local/` work;
per-feature shared/local visibility (verify's keep-local opt-out, evolve's local→shared promotion);
and a documented solo→team graduation path. Cross-repo distribution of overlays is a separate concern
owned by the plugin cycle (#57).

## Decision

Drop the prescribed team-overlay mechanism. The team layer is **repo-owned conventions**, expressed
with primitives VINE already ships: put team conventions in the tracked `.vine/context/shared.md`,
and mark anything the team enforces regardless of personal preference with `<!-- class: policy -->`.
That pair *is* the whole team layer — no `context/teams/<name>.md` format, no `vine:team` command, no
cross-team precedence engine. Cross-repo distribution of those overlays defers to plugins (#57); #52
finalizes the composition model #57 attaches to.

#52's actual deliverable is the **personal/local split** — `.vine.local/` as a gitignored sibling
root mirroring `.vine/`, plus the #108 inversion the deferral record (which this supersedes) held
specifically until `.vine.local/` landed. The inversion rode with the split in one coherent move,
exactly as the deferral predicted.

#52's original acceptance criteria are read as intent, not letter: "team conventions install with the
project" is satisfied by tracked `shared.md` + the policy marker (already shipped) + #57's
distribution; "conflict-safe shared conventions" is realized by the append-only, one-record-per-file
patterns the knowledge layer already uses.

## Consequences

- A cold reader who wonders why VINE has no `vine:team` command or team-overlay file format learns
  here that the mechanism was deliberately dropped as repo-owned over-engineering, not overlooked.
  The recommendation lives in `shared.md` ("Team conventions (recommendation)") and README's
  solo→team graduation path.
- The deferred gitignore inversion (`2026-06-16-defer-the-vine-gitignore-inversion-to-the-vine-local-work`,
  now superseded) is fulfilled: `.vine/` is track-by-default, ignoring only `.vine.local/` plus the
  ephemeral `.vine/ACTIVE` (and contributor-only `.vine/.trellis-ok`). The brittle
  deny-then-allowlist that record described is gone; #108 is closed. The supersession marks the
  deferral resolved so a reader doesn't trust a stale "Accepted — defer."
- #57 (plugin distribution) is unblocked: the overlay-composition model it builds on is final, and
  the team-overlay *recommendation* is the explicit seam where plugin distribution attaches.
- Reviving a VINE-level multi-team composition engine needs a fresh, concrete need — it was
  considered and rejected here as imposing shape orgs should own.

## Amendment (2026-06-23, #57): the seam carries documentation, not a mechanism

This record named the team-overlay recommendation as "the explicit seam where plugin distribution
attaches" (Consequences, above), which read as a promise that the plugin cycle (#57) would attach a
*mechanism* there. #57 resolved it the other way: VINE ships **no overlay-distribution mechanism** —
overlay content is consumer-owned, and cross-repo reach is achieved by forking the plugin's
skills/agents, not by VINE delivering overlays. The seam was a documentation boundary all along.
See `2026-06-23-overlay-distribution-is-documentation-not-a-mechanism` for the decision and its
rationale. The body above stands; this only corrects the forward-looking expectation so a reader
doesn't await machinery that was deliberately not built.
