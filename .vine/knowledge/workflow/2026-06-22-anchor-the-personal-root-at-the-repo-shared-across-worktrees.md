# Anchor the .vine.local/ personal root at the repository, shared across worktrees, not at the working directory

## Status

Accepted — 2026-06-22 (amended 2026-06-22 during Slice 5 implementation — see *Amendment* below;
`ACTIVE` stays at `.vine/ACTIVE` gitignored rather than moving to the private git dir, the shared-root
anchoring is unchanged)
Source: workflow/team-layer · Actor: Rob + Claude
Supersedes: none

## Context

The team-layer cycle (#52) moves all personal/ephemeral VINE state into a gitignored sibling root,
`.vine.local/` — profile, personal overlays, the `ACTIVE` sentinel, `PAUSE.md`, and local-only
projects. The Phase 1 contract (`references/STATE.md`) describes it as a sibling root resolved at the
project root, i.e. relative to the current working directory.

That resolution is wrong for git worktrees and fresh clones, and the failure is silent. Gitignored
files are not checked out into a `git worktree`, so a worktree session never sees the personal state
that lives in the main checkout. Observed concretely during this cycle: the main checkout carries a
real `.vine/PROFILE.md`, but the ~19 worktrees (including the one running this navigate session) have
no copy — every worktree session ran as if no profile existed, with no depth calibration. Moving the
state into a gitignored `.vine.local/` inherits the blind spot unchanged and consolidates *more*
state behind it.

The root cause: personal state was keyed to the **working directory** (`./.vine.local/`) when it
should be keyed to the **repository**. The worktree case also exposes that "personal state" is two
scopes, not one:

- **Per-repo / per-developer** — profile, personal overlays, local-only projects, pause notes. Want
  to be **shared** across every worktree of the repo (you have one expertise profile, not one per
  branch).
- **Per-working-tree** — the `ACTIVE` sentinel, whose whole job is "a navigate session is active *in
  this tree*." Must stay **local**: a shared `ACTIVE` would make the installed hooks in worktree B
  fire against a session running in worktree A.

A single uniformly-shared `.vine.local/` fixes the profile but breaks `ACTIVE`'s hook scoping; a
single uniformly-local one (the Phase 1 contract) keeps `ACTIVE` correct but loses the profile. The
two scopes must resolve to different anchors.

## Decision

Resolve the personal root from git, not from the working directory, and split it by scope:

- **Shared personal root** — anchor `.vine.local/` at the repository's *primary* worktree, found via
  `git rev-parse --git-common-dir` (identical from every linked worktree; its parent is the main
  worktree root). Profile, personal overlays, local-only projects, and pause state live there once
  and are seen identically from every worktree. It remains a visible sibling root at the main
  checkout.
- **`ACTIVE` sentinel** — keep it at `.vine/ACTIVE` (gitignored), **not** in `.vine.local/`.
  *(Amended — the original decision moved it into the per-worktree private git dir via
  `git rev-parse --git-dir`; see Amendment below for why `.vine/ACTIVE` is simpler and equally
  correct.)* Because `.vine/` is a tracked tree, every worktree checks out its own working copy, so a
  gitignored `.vine/ACTIVE` written in one worktree exists only in that worktree's filesystem — it is
  per-tree by construction, with no `git rev-parse` resolution. The gitignore inversion keeps it
  ignored with an explicit `.vine/ACTIVE` rule alongside `.vine.local/`.

Commands and hook scripts resolve these anchors rather than assuming a cwd-relative `./.vine.local/`.
A non-git directory (no `git` available) falls back to the cwd-relative root — the single-checkout
case is unaffected.

This is folded into **Phase 2 (Discovery & Session Plumbing)** of #52, which relocates `PAUSE` to the
shared personal root and amends the `references/STATE.md` contract to specify git-anchored resolution
of that root. (`ACTIVE` does not relocate and the hook scripts are unchanged — see Amendment.) Phase 1's
composition model is unchanged — `.vine.local/` at the main checkout is still the correct literal
path; Phase 2 only adds *how a worktree resolves to it*. Considered and rejected: a `~/.vine/<repo-key>/`
home outside the repo — it also survives clones, but loses in-repo discoverability and complicates
local-only projects living next to their code; reach for it only if clone-portability becomes a goal.

## Consequences

- Worktree and main-checkout sessions share one profile / personal-overlay set per repo, so the
  silent "no profile here" failure disappears. A cold reader of a worktree that lacks a literal
  `.vine.local/` learns from this record that resolution is git-anchored by design, not missing.
- `ACTIVE` stays out of `.vine.local/` (the shared personal root), correcting the conflation of an
  ephemeral session sentinel with durable personal state; `.vine/ACTIVE` is per-worktree by checkout
  and keeps the hooks from cross-firing between concurrent worktree sessions.
- Phase 2's implementation cost is narrower than first scoped: only the **shared** personal root needs
  `git rev-parse --git-common-dir` resolution (discovery, profile, overlays, pause). `ACTIVE` stays a
  literal `.vine/ACTIVE` with no resolution, so the hook scripts and every command's `ACTIVE` read/write
  are unchanged. STATE.md's contract is amended for the shared-root resolution.
- Pairs with the deferred gitignore inversion (`2026-06-16-defer-the-vine-gitignore-inversion-to-the-vine-local-work`):
  the inversion ignores `.vine.local/` at the main checkout, which this resolution model keeps as the
  one shared personal root, so the two remain coherent.
- A short-term stopgap exists independent of the redesign: symlink a worktree's `.vine/PROFILE.md`
  (or `.vine.local/`) to the main checkout's. Used this cycle to unblock the live worktree; not a
  substitute for git-anchored resolution.

## Amendment (2026-06-22, Slice 5)

The original Decision moved `ACTIVE` into the per-worktree private git dir
(`$(git rev-parse --git-dir)/vine/ACTIVE`). During Slice 5 we kept it at `.vine/ACTIVE` (gitignored)
instead. The simpler option was simply not considered when the record was first written.

**Why.** `ACTIVE`'s only hard requirement is to be *per-working-tree* (so worktree B's hooks don't fire
on worktree A's session). `.vine/` is a **tracked** tree, so each worktree already checks out its own
working copy — a gitignored `.vine/ACTIVE` therefore exists only in the worktree that wrote it, which
is per-tree *for free*, with no `git rev-parse` resolution at any command or hook site. The git dir
would also have worked, but it pushed `git rev-parse` prose into navigate/pause/evolve and the hook
scripts (a real burden and fumble-risk for a markdown framework) and wrote app state into git's private
directory, all to avoid one extra gitignore glob.

**Cost accepted.** The track-by-default gitignore inversion is no longer a single `.vine.local/` rule —
it carries an explicit `.vine/ACTIVE` line alongside it (and the contributor-only `.vine/.trellis-ok`).
Two simple globs, still far less brittle than the deny-then-allowlist #108 removes.

**Unchanged.** The shared-personal-root anchoring (`dirname "$(git rev-parse --git-common-dir)"` for
profile, overlays, local projects, pause) — the core fix this record exists for — stands exactly as
decided.

## Amendment (issue #132): loading surface adopts the resolution

When this record shipped, the contract (`references/STATE.md`) and this ADR specified git-anchored
resolution of the shared personal root, but the two high-frequency read protocols in
`.vine/context/shared.md` — the Engineer Profile Protocol and the Overlay Loading Protocol's
Personal-layer rule — still read cwd-relative `.vine.local/…`. From a linked worktree, where
`.vine.local/` is gitignored and not checked out, those reads silently returned nothing — the
"short-term stopgap" (the symlink, Consequences above) was the only thing bridging the gap.

Issue #132 closes it. `shared.md` now defines the resolution once as a named helper — **Resolving
the personal root** — in the Overlay Loading Protocol, and the Personal-layer rule and Engineer
Profile Protocol reference it before any `PROFILE.md` / `context/<name>.md` read. The
profile-writing command paths (`verify`, `evolve`) and `status`'s inline read were routed through
the same resolution; `init` carries the matching scaffold. A `trellis` Check 12 guards against a
cwd-relative read regressing. The symlink stopgap is now obsolete. `ACTIVE` is untouched, per the
Slice 5 amendment above.
