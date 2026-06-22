# Defer the .vine/ gitignore inversion to the .vine.local/ work rather than half-migrating now

## Status

Superseded by 2026-06-22-vine-ships-a-team-layer-recommendation-not-a-prescribed-mechanism — 2026-06-22
Source: workflow/durable-decisions · Actor: Rob

## Context

The repo's `.gitignore` tracks `.vine/` artifacts with a deny-everything-then-allowlist shape:
`.vine/*` is ignored, and each tracked subdirectory is re-admitted with its own negation
(`!.vine/context/`, `!.vine/projects/`, …). This cycle's bootstrap records under
`.vine/knowledge/workflow/` were silently untracked until a commit failed, because no negation
admitted them yet — slice 2 added `!.vine/knowledge/` to fix it. The shape is brittle: every new
tracked `.vine/` subdir needs its own negation or it vanishes from version control unnoticed. A
backlog idea (`references/STATE.md`, "Forward references") proposes `.vine.local/` — a gitignored
sibling root for personal work — which would let `.vine/` invert to *track-by-default* and ignore
only `.vine.local/` plus a couple of ephemeral sentinels (`.vine/ACTIVE`, `.vine/.trellis-ok`),
relocating `PROFILE.md` and `PAUSE.md` into `.vine.local/`. The question at the slice-2 boundary:
invert the gitignore now, or keep the minimal negation and wait?

## Decision

Keep the minimal `!.vine/knowledge/` negation now; defer the full inversion to the `.vine.local/`
work so the whole pattern flips at once. `!.vine/knowledge/` is correct under *either* model
(knowledge is team-shared and tracked-by-default in both), so adding it now buys nothing toward the
inversion and costs nothing if the inversion later lands. Inverting in this cycle would be a
half-migration — the deny+allowlist shape stays for `PROFILE.md`/`PAUSE.md` until `.vine.local/`
exists to receive them, so the repo would carry two competing models at once.

## Consequences

- A cold reader of `.gitignore` sees a brittle deny-then-allowlist and cannot recover from the diff
  that the cleaner inversion was *deliberately deferred*, not overlooked — that judgment lives here.
- Each new tracked `.vine/` subdir still needs its own negation until the inversion lands; the
  silent-untracking failure mode persists in the interim (mitigated only by a commit failing loudly).
- The inversion is now a backlog item gated on `.vine.local/` (filed as a follow-up issue this
  cycle), keeping the two coupled so the pattern flips in one coherent move rather than as drift.
- Establishes the general stance: when a cleanup is correct only as part of a larger not-yet-present
  change, take the minimal locally-correct step and defer the cleanup to the change that completes it.
