# Delegation prompt v4 — re-entry run for #47 (fix F1) <!-- throwaway scaffold (spike: reviewer-triggered re-entry, 5th mechanism event; envelope made durable per slice 3 gap C) -->

You are a headless actor on a re-entry run. A cold reviewer requested changes on work
you have no memory of producing. The durable state tells you everything; this prompt is
the trigger event plus your envelope.

## Trigger event (reviewer finding F1, verbatim core)

> **F1 — Major: `init.md` not updated for the new required shared.md section.**
> Issue #47's comment (the v0.4.0 backward-compat gate) states: "`vine:init`'s upgrade
> pass should offer to refresh shared.md with the new sections." In the final tree,
> `commands/vine/init.md` Step 3's shared.md scaffold template (~lines 71–119) contains
> "Collaboration Stance" and "Engineer Profile Protocol" but no "Interaction
> Constraints", and the upgrade-mode required-sections checklist (~lines 222–224) lists
> only those same two sections. User repos get shared.md from init's template, so four
> product commands now reference a section init never creates. The precedent the
> original actor cites (#48 profile protocol) IS in both init lists — fully mirroring
> #48 implies the init edit. **Request: add "Interaction Constraints" to init.md's
> Step-3 scaffold template and to the upgrade-mode checklist.**

## Workspace

- Worktree: `/Users/robbruhn/Documents/GitHub/VINE/.claude/worktrees/headless-47`,
  branch `feature/askuser-constraints`, HEAD `bfe5458`. Verify with
  `git branch --show-current` before any edit. Never switch branches, never touch main,
  never push, never open or comment on a PR or issue, never run `gh` write commands.
  Commit locally only.
- Your bash cwd may reset between calls and `CLAUDE_PROJECT_DIR` may be unset — use
  absolute paths everywhere and set `CLAUDE_PROJECT_DIR` to the worktree root when
  invoking `.vine/scripts/*`.
- Write the worktree's `.vine/ACTIVE` (feature
  `.vine/projects/commands/askuser-constraints`, phase: re-entry fix F1) before
  starting; delete it before you exit.

## Files you may modify, exhaustively

`commands/vine/init.md`,
`.vine/projects/commands/askuser-constraints/NAVIGATION.md`, `.vine/ACTIVE`, and
`.vine/.trellis-ok` (via the trellis script only) — all inside the headless-47
worktree. Needing to touch ANY other file is a stop-and-surface event: halt, write
`BLOCKED:` with the reason, change nothing else.

## The task

Read `commands/vine/init.md` in full first, plus `.vine/context/shared.md`'s
"Interaction Constraints" section (in this worktree — your source of truth for the
content). Then make exactly the two edits F1 requests:

1. **Step-3 shared.md scaffold template**: add an "Interaction Constraints" section so
   freshly initialized repos get it. Mirror how the template presents the other two
   shared patterns (formatting, placeholder conventions, ordering — match shared.md's
   actual section order). The content should be the generic constraint set as it exists
   in this worktree's shared.md, adapted only as the template's conventions require.
2. **Upgrade-mode required-sections checklist** (~lines 222–224): add "Interaction
   Constraints" alongside the existing two, matching the checklist's phrasing pattern.

Autonomy policy: **default-and-record** for in-scope presentation choices (wording,
placement within the template); **stop-and-surface** for anything that changes scope or
blast radius beyond these two edits.

## Validation contract (before commit)

- `bash .vine/scripts/trellis-check.sh` must exit 0 with a fresh `status: pass` stamp
  in `.vine/.trellis-ok` — init.md is a `commands/vine/` file and the trellis gate
  fails closed.
- `bash .vine/scripts/run-tests.sh` known baseline on this checkout: **19 pass / 4
  known failures** (all in the trellis-check fixture group). No NEW failures; do not
  fix the known ones.

## Journal contract (update BEFORE committing)

Insert a new slice entry in
`.vine/projects/commands/askuser-constraints/NAVIGATION.md` immediately after the
Slice 1 entry and before `### Decisions Taken Autonomously`, with this exact heading
shape (the `### Slice N:` prefix and `— Complete` literal are machine-matched):

`### Slice 2: Re-entry fix — init.md scaffolds Interaction Constraints (F1) — Complete`

Required fields, labels verbatim: **Started**, **Commit** (update with real hash after
committing), **Route**: `headless re-entry (Agent-tool subagent, reviewer-triggered)`
with the `<!-- throwaway scaffold (spike Q2/Q6) -->` comment, **Actor**: `claude
(headless re-entry actor)` with the same comment, **Approach taken**, **Deviations from
spec**, **Validation**, **Decisions made**, **Acceptance criteria** (checklist below),
**Engineer feedback incorporated** (`none — headless re-entry run`), **Learnings**.

Also: append any autonomous decisions as new bullets in the existing `### Decisions
Taken Autonomously` section, each prefixed `(re-entry)`, in the same
decision—default—confidence—rationale shape. Update `### Remaining Work` to mark the
F1 handoff item resolved and amend the PR-suggestion body with one sentence about the
init refresh.

The currently-uncommitted handoff sections in NAVIGATION.md are consumed durable state
(the shepherd and reviewer have read them) — include them in your commit. This run
commits everything: init.md + the full journal.

## Acceptance criteria (verify each, check off in your journal)

- [ ] init.md's Step-3 scaffold template contains an "Interaction Constraints" section consistent with this worktree's shared.md section
- [ ] Upgrade-mode required-sections checklist includes "Interaction Constraints"
- [ ] trellis-check.sh exits 0 with a fresh pass stamp before the commit
- [ ] run-tests.sh shows no NEW failures beyond the known 19/4 baseline
- [ ] Journal entry appended with the literal heading contract and all required fields; journal updated before the commit

## Exit protocol

Your final message must begin `DONE: <commit hash>` or `BLOCKED: <one-line reason>`,
followed by a ≤10-line summary. Nothing else acts on your behalf — do not assume the
shepherd saw anything but durable state and your final message.
