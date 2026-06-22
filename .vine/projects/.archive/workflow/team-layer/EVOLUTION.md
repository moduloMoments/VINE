# Evolution Report: Personal/Local Layer (#52)
## Date: 2026-06-22

> The feature shipped across three merged PRs before this evolve ran. Phase 1 →
> [#122](https://github.com/moduloMoments/VINE/pull/122), Phase 2 →
> [#123](https://github.com/moduloMoments/VINE/pull/123), Phase 3 →
> [#126](https://github.com/moduloMoments/VINE/pull/126) (all merged; `feature/team-layer` is
> content-identical to `origin/main`). Evolve is therefore the cycle-close — verification rollup,
> learning capture, knowledge ADRs, issue close — not a prospective product handoff.

### Product Evolution

#### Acceptance Criteria Results

All 12 cycle-level criteria accounted for; **zero unaccounted**. Evidence is the branch's pre-squash
slice commits (squash-merged into main as `69909a6` / `3d141a4` / `b5ab37e`).

| Acceptance criterion (SPEC) | Evidence (slice / commit) |
|---|---|
| AC1 — `.gitignore` track-by-default | Slice 9 — `9c465dc` *(intent: also `.vine/ACTIVE` + contributor `.vine/.trellis-ok`)* |
| AC2 — overlay loader composes `.vine.local/context/<name>.md` over repo overlay | Slice 2 — `e28a5c8` |
| AC3 — profile loader reads `.vine.local/PROFILE.md` | Slice 3 — `df64d3b` |
| AC4 — navigate writes ACTIVE; hooks read it; fires per-worktree | Slice 5 — `0833865` *(intent: `.vine/ACTIVE`, not `.vine.local/ACTIVE`)* |
| AC5 — pause writes PAUSE under `.vine.local/projects/`; consumed-once | Slice 5 — `0833865` |
| AC6 — two-root discovery across commands + trellis, stated once + referenced | Slice 4 — `8cfbfcf` |
| AC7 — per-path `git check-ignore` commit test | Slice 6 — `d80a95e` (rule homed in Slice 1) |
| AC8 — verify keep-local opt-out; evolve local→shared promotion | Slice 7 — `2a07dfb` / Slice 8 — `8b17ec0` |
| AC9 — init scaffolds new gitignore; Upgrade Mode opt-in migration (decline = no-op) | Slice 9 — `9c465dc` |
| AC10 — this repo migrated as worked example; `git status` clean (104 tracked) | Slice 9 — `9c465dc` |
| AC11 — README / CLAUDE.md / init scaffold / STATE.md reflect the `.vine.local/` contract | Slice 10 — `924cfc8` |
| AC12 — `/trellis` passes; no command references a moved personal path | Slice 10 — `924cfc8` + re-verified at evolve |

#### Cross-Feature Integration Check (full-feature scope)

- **trellis-check: green** — 11/11 commands, 8 cross-ref anchor pairs. Only the two pre-existing,
  allowlisted legacy `.vine/hooks/` warnings (`init.md:105-106`), unrelated to this feature and
  slated to harden at the 0.5 fallback removal.
- **Stale-path sweep: clean.** Grep across `commands/`, `references/`, `README.md`, `CLAUDE.md`,
  `.vine/context/` found no live stale references to moved personal paths. Every `shared.local.md`,
  `.vine/PROFILE.md`, and old-gitignore-model match is legitimately inside init's Upgrade Mode
  "detect-and-migrate-from" prose — i.e. describing the model being migrated *away from*, not a
  current reference. Confirms the Slice 10 grep and the phase-group `vine-verification` pass.
- **Prior-PR review/CI:** no CI configured (pure-markdown repo, expected); no review comments or
  requested changes on #122 / #123 / #126 (solo self-merge, per Team Context). No red or pending
  checks carried forward.

#### Spec Deviations

All SPEC-annotated; all justified tactical decisions. None change user-facing behavior beyond what
the docs now describe.

- **ACTIVE stayed at `.vine/ACTIVE`** (Slice 5, engineer-directed). The original worktree ADR moved
  it to the per-worktree git dir; analysis showed a gitignored file inside the *tracked* `.vine/`
  tree is already per-worktree by checkout — equal correctness, zero `git rev-parse` in
  commands/hooks. ADR amended in place (same-cycle, git-dir half never shipped). *Stakeholder-visible:*
  the shipped init gitignore template is two lines (`.vine.local/` + `.vine/ACTIVE`), not one.
- **AC1 "single line" → two-line template / three-line this repo** (Slice 9, intent over letter):
  `.vine/ACTIVE` rides alongside `.vine.local/`, and this repo adds contributor-only
  `.vine/.trellis-ok`. AC1's intent (track-by-default, personal root ignored, `git check-ignore`
  clean across both roots) is met.
- **Profile writers moved with the reader** (Slice 3): AC3 named only the reader; moving the read
  path alone would break the profile (written to `.vine/`, read from `.vine.local/`). Correctness
  fix, invisible to stakeholders.
- **In-flow corrections** (Slices 4/7/8): root-aware archive destination + trellis profile-path fix
  (Slice 4); stale first-cycle gitignore note replaced (Slice 7); root-aware `.resolved` + archive
  (Slice 8). All planned/coupled to paths already being edited, recorded in SPEC addenda.

#### Follow-Up Items

- **#52** — still open at evolve start; closed at cycle-close (impl PRs used "Refs #52"). Summary
  comment posted.
- **#108** (gitignore inversion) — **closed** by Slice 9; the deferral the knowledge record gated on
  `.vine.local/` is performed.
- **#57** (plugin distribution) — correctly **stays open**; unblocked by this cycle, which finalizes
  the overlay-composition model and leaves the team-overlay *recommendation* as the seam #57 attaches
  to. Future cycle.
- **Cosmetic, self-resolved:** the primary checkout briefly showed `.vine.local/PROFILE.md` untracked
  until #126 merged; main now carries the track-by-default ignore, so it resolves on next sync.
- No new backlog tickets warranted.

### Agent Evolution

#### CLAUDE.md Suggestions

None. The Slice 10 documentation sweep already brought CLAUDE.md's repository-structure and
state-artifact-chain bullets current with the `.vine.local/` contract (identical to main). Adding
more would violate the doc-growth guardrail.

#### Context Overlay Updates

- **`evolve.md` — Multi-PR Features:** added a note that all-phases-merged is a valid evolve entry
  state — evolve then produces only cycle-close artifacts needing their own small PR, cut against
  current `origin/main` to avoid a stale-branch revert. (Accepted.)

#### Knowledge ADRs

- **New:** `2026-06-22-vine-ships-a-team-layer-recommendation-not-a-prescribed-mechanism` — records
  why #52 dropped the prescribed team-overlay mechanism (`context/teams/<name>.md`, a `vine:team`
  command, a cross-team precedence engine) as repo-owned over-engineering, shipping instead the
  `.vine.local/` split + the gitignore inversion + a documented team *recommendation*. A cold reader
  can't recover that "why-not" from the code.
- **Superseded:** `2026-06-16-defer-the-vine-gitignore-inversion-to-the-vine-local-work` — Status
  flipped to `Superseded by …`; its deferred inversion shipped in Slice 9, so a reader no longer
  trusts a stale "Accepted — defer." (The git-anchored-root + ACTIVE pivot was already captured in
  `2026-06-22-anchor-the-personal-root-at-the-repo-shared-across-worktrees`, amended in place during
  Slice 5 — no new record needed.)

#### Skill Suggestions

None rose to the bar. The "stale-path grep sweep after a path/model migration" is a real verification
pattern, but trellis + the `vine-verification` agent already cover structural and cross-cutting checks;
a dedicated skill would be marginal.

#### VINE Process Observations (dogfooding)

- **Evolve assumes a prospective final PR.** Its "Prep the Handoff" / "Suggest Opening a PR" steps are
  written for the single-PR or final-phase-ships-here case. A multi-PR feature whose phases all merged
  before evolve runs has no product handoff — only cycle-close artifacts. Captured in the `evolve.md`
  overlay note above; the deeper command-level fix (a branch in evolve's flow for the all-merged case)
  is a candidate for a future workflow cycle, not forced here.
- **Contract-leads-implementation phasing worked.** STATE.md documented the `.vine.local/` end-state
  in Slice 1, ahead of the command/hook machinery that relocated over Phases 2–3. The per-PR lag was
  expected and kept each PR's STATE.md internally consistent.

### User Evolution

#### Engineer Contributions

- **The ACTIVE pivot (load-bearing).** Mid-Slice-5, the engineer challenged the inherited git-dir
  relocation of `ACTIVE` ("does it make sense?"), driving Option B — a gitignored `.vine/ACTIVE` that
  is per-worktree for free because `.vine/` is a tracked tree. Equal correctness, far less machinery,
  and the engineer chose to amend the same-cycle ADR in place rather than leave a confusing
  supersede-trail. The cleanest design move of the cycle.
- **"Document the end-state, not the transition"** (Slice 1) — directed STATE.md to describe the
  finished `.vine.local/` contract rather than a transitional note, setting the phasing for the whole
  multi-PR sequence.
- **"Check whether the convention actually shipped before building backward-compat"** (Slice 2) —
  confirmed the `shared.local.md` personal-layer convention never shipped, so no loader fallback was
  built; Upgrade Mode relocates it as a courtesy for source-trackers, not a compat requirement.

This was complex framework work squarely in the engineer's confident `workflow` domain — no
manufactured "growth" to report.

#### Profile Updates

- **`workflow`: unchanged at confident** (engineer choice). Already top level; this cycle demonstrated
  continued confident command. No growth-log entry this cycle (engineer's call).

#### Claude Memory Suggestions

None new. Every interaction pattern this cycle (questioning an over-built decision, amending a
same-cycle unshipped ADR in place, AC intent-over-letter) is an instance of an already-recorded
memory, not a fresh observation. No manufactured entries.

### Handoff Package

#### PR Description (cycle-close artifacts PR)

> The product already shipped (#122/#123/#126). This PR carries only the evolve cycle-close artifacts.

```markdown
## Summary
Close out the team-layer cycle (#52): the evolution report, a knowledge ADR recording why the
prescribed team-overlay mechanism was dropped, and the project's resolved/archive markers. No
product code — the feature itself shipped across PRs #122, #123, and #126.

## Changes
- EVOLUTION.md for the team-layer feature (AC traceability, integration check, deviations, learnings)
- Knowledge ADR: VINE ships a team-layer recommendation, not a prescribed mechanism (supersedes the
  2026-06-16 gitignore-deferral ADR, now fulfilled)
- evolve.md overlay: note that all-phases-merged is a valid evolve entry state
- PROJECT-MAP evolve row → complete; .resolved marker

## Testing
`/trellis` green (11/11 commands). Stale-path sweep across all command/doc surfaces clean.

## Follow-up
#57 (plugin distribution) unblocked for a future cycle; #52 closed.
```

#### Reviewer Notes

- This is an artifacts-only PR; the product merged earlier. The one thing worth a reviewer's eye is
  the **ADR supersession**: the new reshape ADR carries `Supersedes:` and the old deferral ADR's
  Status line was flipped to `Superseded by …` (body untouched, per the append-only rule).
- The cycle's central design call — `ACTIVE` staying at `.vine/ACTIVE` rather than relocating — is
  recorded in the worktree-anchoring ADR's Amendment section, not here; the reshape ADR is about the
  dropped team mechanism, a separate decision.

#### Multi-PR Summary

| Phase | Slices | Status | PR |
|-------|--------|--------|----|
| Phase 1: Composition Model | 1–3 | ✅ Merged | [#122](https://github.com/moduloMoments/VINE/pull/122) |
| Phase 2: Discovery & Session Plumbing | 4–6 | ✅ Merged | [#123](https://github.com/moduloMoments/VINE/pull/123) |
| Phase 3: Visibility, the Flip & Docs | 7–10 | ✅ Merged | [#126](https://github.com/moduloMoments/VINE/pull/126) |
