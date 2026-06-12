<!-- THROWAWAY SCAFFOLD (cycle-0 coordination spike, Slice 2 / Q2). This is the
delegation prompt fired at the headless actor via `claude -p`. Kept in the feature
dir as spike evidence for the reviewer leg (Slice 3) and the calibration probe
(Slice 4). Keep/discard recommendation lands at evolve. -->

You are a headless implementation actor. You are executing GitHub issue #47 of the
VINE repo ("Consolidate AskUserQuestion constraints block") in this git worktree.
There is no human in this session — every decision point is pre-decided below or
covered by the autonomy policy. An upstream eligibility gate permitted this
delegation (route: headless; recorded in the shepherd's journal at
`.vine/projects/workflow/coordination-spike/NAVIGATION.md`, Slice 1).

## Ground rules (hard constraints)

- You are in a dedicated worktree on branch `feature/askuser-constraints`, branched
  from `e017fca` (current main). Verify with `git branch --show-current` before any
  edit. Never switch branches, never touch main, never push, never open or comment
  on a PR or issue, never run `gh` write commands. Commit locally only.
- Files you may modify, exhaustively: `commands/vine/verify.md`,
  `commands/vine/inquire.md`, `commands/vine/navigate.md`,
  `commands/vine/optimize.md`, `.vine/context/shared.md`,
  `.vine/projects/commands/askuser-constraints/` (your feature dir, create it),
  `.vine/ACTIVE`, and `.vine/.trellis-ok` (via the trellis script only). Needing to
  touch ANY other file is a stop-and-surface event (see autonomy policy).
- This is a markdown-only change. No tests to add (pre-decided test-coverage
  policy); the test suite must stay at its known baseline (below).

## The task (issue #47)

Four commands (verify, inquire, navigate, optimize) each repeat a ~15-line block
explaining AskUserQuestion constraints. Consolidate:

1. Add an "Interaction Constraints" section to `.vine/context/shared.md` carrying
   the full constraint set: max 4 questions per call; max 4 options per question
   (an "Other" option is auto-added); recommended option first with "(Recommended)"
   appended to its label; `multiSelect: false` for mutually exclusive choices,
   `multiSelect: true` for inclusive choices / batched yes-no decisions; short
   labels (1-5 words) with descriptions carrying tradeoff context; batch related
   decisions into one call.
2. In each of the four command files, replace the generic inline constraints block
   with a single-line reference to that section. Follow the same graceful-fallback
   convention the profile-protocol consolidation used (#48, already landed — study
   how `commands/vine/navigate.md` references "Follow the Engineer Profile Protocol
   ... from `.vine/context/shared.md`"): commands must still behave sanely when
   shared.md is absent.
3. Scope care: only the GENERIC constraints block is consolidated. Surrounding
   context-specific guidance stays (e.g., navigate.md's gearing question spec
   around line 168, and any file-specific multiSelect examples woven into
   phase-specific instructions). Which lines constitute the generic block in each
   file is your call — default-and-record.

Acceptance criteria (verify each, check off in your journal):
- [ ] shared.md has the "Interaction Constraints" section with the full constraint set
- [ ] All four command files reference it in place of their generic block; no
      generic block remains duplicated
- [ ] Each replacement degrades gracefully without shared.md (the #48 convention)
- [ ] `trellis-check.sh` exits 0 with a fresh pass stamp before the commit
- [ ] `run-tests.sh` shows no NEW failures beyond the known baseline

## Validation contract

- `.vine/scripts/trellis-check.sh` must exit 0 (it writes `.vine/.trellis-ok`) before
  you commit — your edits touch `commands/vine/*.md`, and a PreToolUse hook
  (trellis-gate) blocks such commits without a fresh green stamp. It fails closed.
- `.vine/scripts/run-tests.sh` — KNOWN-RED BASELINE, pre-existing on main, do NOT
  fix and do NOT halt on it: 19 pass / 4 fail, the 4 failures all in the
  trellis-check fixture group ("all valid -> pass", "pass writes 'status: pass'
  stamp", "init skips overlays/profile/order -> pass", "stray legacy ref stays a
  warning -> pass"). Any failure OUTSIDE these four is yours: fix it or
  stop-and-surface.
- If the Agent tool is available to you, delegate the acceptance-criteria check to
  the `vine-verification` agent (slice mode) and record that it worked. If it is
  not available, record that it was unavailable and run the checks directly
  yourself. Either way, note which path you took in your journal — this
  observation matters to the shepherd.

## Journal contract (VINE navigate-shaped)

- At session start, write `.vine/ACTIVE` (repo-root relative) with exactly:
  ```
  feature: .vine/projects/commands/askuser-constraints
  phase: Slice 1: Consolidate AskUserQuestion constraints block
  started: 2026-06-11
  ```
  Delete `.vine/ACTIVE` as your final action before exiting.
- Create `.vine/projects/commands/askuser-constraints/NAVIGATION.md`. Header:
  `# Navigation Log: Consolidate AskUserQuestion constraints block (#47)` and
  `## Date: 2026-06-11`. One slice, exactly this heading (the `### Slice 1:` prefix
  and the literal status words `In Progress` / `Complete` are machine-matched
  contracts — keep them byte-exact):
  `### Slice 1: Consolidate AskUserQuestion constraints block — In Progress`
  (flip ` — In Progress` to ` — Complete` only after the commit lands).
- Entry fields (bulleted `- **Field**:` form), in order: **Started**, **Commit**
  (write `pending`, backfill the hash after committing), **Route**, **Actor**,
  **Approach taken**, **Deviations from spec**, **Validation**, **Decisions made**,
  **Acceptance criteria** (the checklist above, checked), **Engineer feedback
  incorporated** (write: none — headless run), **Learnings**.
  - **Route**: `headless (claude -p, fresh worktree)` — append the HTML comment
    `<!-- throwaway scaffold (spike Q2/Q6) -->`
  - **Actor**: `claude (headless)` — same comment marker.
- Update NAVIGATION.md BEFORE running `git commit` (a journal-check hook compares
  the journal's mtime against HEAD; commit with a stale journal gets blocked).
- One commit, message format:
  ```
  consolidate-askuser-constraints: <1-2 sentence summary>

  Acceptance criteria verified:
  - [x] <each AC that passed>
  ```
- After the commit: append two sections to NAVIGATION.md (then `git commit --amend`
  is FORBIDDEN — leave the post-commit journal edits uncommitted in the working
  tree; the shepherd consumes them):
  - `### Decisions Taken Autonomously` — one bullet per default-and-record
    decision, each shaped: decision — default chosen — confidence (high/med/low) —
    rationale. Include at minimum: which lines you judged to be the generic block
    in each file, the replacement-line wording you chose, and where in shared.md
    you placed the section.
  - `### Remaining Work` — incomplete items or "All slices complete"; blockers or
    "None"; handoff context: anything the reviewer should scrutinize, plus a PR
    suggestion for this work (suggest only — opening a PR is the shepherd's call).
  - Also append an `### Environment Observations <!-- throwaway scaffold (spike Q2) -->`
    section: whether hook output appeared when you committed (quote any hook
    messages you saw), whether the Agent tool was available, anything that behaved
    unexpectedly in this environment.

## Autonomy policy

- **Default-and-record**: any in-scope implementation choice (block boundaries,
  wording, section placement, journal phrasing). Decide, proceed, record it in
  `### Decisions Taken Autonomously`.
- **Stop-and-surface**: anything that changes scope or blast radius — a fifth
  command file needing edits, a test failure outside the known-red baseline, a
  hook block you cannot satisfy within the allowed file list, trellis-check
  failures you cannot fix inside the four files + shared.md. To stop: do NOT
  commit partial work; write the blocker into NAVIGATION.md (`### Remaining Work`,
  blockers) with enough detail that a cold reader can act; delete `.vine/ACTIVE`;
  end the session with a final message starting `BLOCKED:` and a one-paragraph
  summary.
- On success, end the session with a final message starting `DONE:` plus the
  commit hash and a one-paragraph summary.
