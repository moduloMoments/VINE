# Navigation Log: Consolidate AskUserQuestion constraints block (#47)

## Date: 2026-06-12

### Slice 1: Consolidate AskUserQuestion constraints block — Complete

- **Started**: 2026-06-12
- **Commit**: bfe5458
- **Route**: headless (Agent-tool subagent, local worktree) <!-- throwaway scaffold (spike Q2/Q6) -->
- **Actor**: claude (headless subagent) <!-- throwaway scaffold (spike Q2/Q6) -->
- **Approach taken**: Added an "Interaction Constraints" section to `.vine/context/shared.md` carrying the full generic AskUserQuestion constraint set. In each of the four command files (verify, inquire, navigate, optimize), kept the phase-specific intro sentence ("Use AskUserQuestion for...") and replaced only the bulleted generic constraint list with a one-line reference to the shared section, mirroring the #48 profile-protocol convention.
- **Deviations from spec**: None.
- **Validation**: `trellis-check.sh` exit 0 (11/11 commands pass, fresh `status: pass` stamp in `.vine/.trellis-ok`). `run-tests.sh`: 19 passed / 4 failed — the 4 failures are exactly the known-red trellis-check fixture baseline; no new failures. Acceptance criteria checked directly by this actor (Agent tool unavailable in session — no `vine-verification` delegation possible). Grep sweep confirmed no duplicated generic constraint list remains in `commands/vine/`.
- **Decisions made**: Kept each file's phase-specific "Use AskUserQuestion for..." intro sentence as the graceful-fallback layer; replaced only the bulleted constraint list. Placed the shared section after "Engineer Profile Protocol". Dropped per-file parenthetical multiSelect examples that lived inside the generic lists (they were illustrations of the generic rules, not phase instructions); preserved truly phase-specific blocks untouched (navigate's gearing question spec, optimize's pattern table). Details in "Decisions Taken Autonomously" below.
- **Acceptance criteria**:
  - [x] shared.md has the "Interaction Constraints" section with the full constraint set
  - [x] All four command files reference it in place of their generic block; no generic block remains duplicated
  - [x] Each replacement degrades gracefully without shared.md (the #48 convention)
  - [x] trellis-check.sh exits 0 with a fresh pass stamp before the commit
  - [x] run-tests.sh shows no NEW failures beyond the known baseline
- **Engineer feedback incorporated**: none — headless run
- **Learnings**: The #48 convention's "graceful fallback" is structural, not textual — there is no fallback sentence anywhere; sanity without shared.md comes from the inline behavioral instruction that stays in each command. Mirroring that meant keeping the intro sentences rather than collapsing entire sections to one line. evolve.md carries a one-phrase "Max 4 options" mention (line ~220) woven into phase instructions — out of #47's four-file scope, left alone.

### Slice 2: Re-entry fix — init.md scaffolds Interaction Constraints (F1) — Complete

- **Started**: 2026-06-12
- **Commit**: pending
- **Route**: headless re-entry (Agent-tool subagent, reviewer-triggered) <!-- throwaway scaffold (spike Q2/Q6) -->
- **Actor**: claude (headless re-entry actor) <!-- throwaway scaffold (spike Q2/Q6) -->
- **Approach taken**: Made exactly the two edits reviewer finding F1 requested in `commands/vine/init.md`: (1) added an "Interaction Constraints" section to the Step-3 shared.md scaffold template, carrying this worktree's shared.md constraint set verbatim, placed after "Engineer Profile Protocol" and before "Team Context" to match shared.md's actual section order; (2) added "Interaction Constraints" to the upgrade-mode required-sections checklist alongside the existing two entries.
- **Deviations from spec**: None.
- **Validation**: `trellis-check.sh` exit 0 (11/11 commands pass, cross-reference anchors resolve, fresh `status: pass` stamp written to `.vine/.trellis-ok` at 2026-06-12 08:56, before the commit). `run-tests.sh`: 19 passed / 4 failed — the 4 failures are exactly the known-red trellis-check fixture group; no new failures. Both checks run with `CLAUDE_PROJECT_DIR` set explicitly to the worktree root.
- **Decisions made**: Copied the constraint set verbatim (it is generic, not repo-derived, so no bracketed placeholder); matched shared.md's section ordering for placement; used the short "— if missing, add it" phrasing for the new checklist bullet; committed the fix + full journal first with this field as pending, then recorded the real hash in a follow-up journal-only commit. Details under "Decisions Taken Autonomously" below, prefixed (re-entry).
- **Acceptance criteria**:
  - [x] init.md's Step-3 scaffold template contains an "Interaction Constraints" section consistent with this worktree's shared.md section
  - [x] Upgrade-mode required-sections checklist includes "Interaction Constraints"
  - [x] trellis-check.sh exits 0 with a fresh pass stamp before the commit
  - [x] run-tests.sh shows no NEW failures beyond the known 19/4 baseline
  - [x] Journal entry appended with the literal heading contract and all required fields; journal updated before the commit
- **Engineer feedback incorporated**: none — headless re-entry run
- **Learnings**: The original actor's #48-mirroring was incomplete in exactly the way the reviewer predicted — the #48 precedent includes init's scaffold and upgrade checklist, so any future "consolidate into shared.md" change should treat init.md as in-scope by default, not as a follow-up. The template carries generic shared-pattern content verbatim and uses [bracketed] placeholders only for repo-derived sections, which made the adaptation question answer itself.

### Decisions Taken Autonomously

- Generic-block boundaries in verify.md — chose the "Key constraints:" line plus its 8 bullets (pre-edit lines 76-84); kept the bolded "Use AskUserQuestion for all decision points" intro paragraph (72-74) — confidence: high — the intro carries the phase-scoped behavioral instruction and is the graceful-fallback layer; only the bullet list was the duplicated generic content.
- Generic-block boundaries in inquire.md — chose "Key constraints:" plus its 9 bullets (pre-edit lines 102-110); kept the "Use AskUserQuestion for all design decisions" intro (98-100) — confidence: high — same reasoning as verify.
- Generic-block boundaries in navigate.md — chose "Key constraints for `AskUserQuestion`:" plus its 6 bullets (pre-edit lines 230-236); kept the step-3d intro (226-228) and left the gearing question spec (lines ~166-172) completely untouched — confidence: high — the gearing spec is explicitly named as phase-specific in the issue.
- Generic-block boundaries in optimize.md — chose "**Constraints for `AskUserQuestion` recommendations:**" plus its 4 bullets (pre-edit lines 267-271); left the interactivity pattern table (including its `multiSelect: true` batch-decisions row) untouched — confidence: high — the table is optimize's analysis rubric, not the generic constraints block.
- Replacement-line wording — "Follow the Interaction Constraints from `.vine/context/shared.md` for every `AskUserQuestion` call." in verify/inquire/navigate; "Proposed conversions must follow the Interaction Constraints from `.vine/context/shared.md`." in optimize — confidence: high — mirrors the #48 "Follow the [Protocol] from shared.md" phrasing; optimize's variant fits its context (it recommends AskUserQuestion conversions rather than making calls at that point).
- shared.md placement — new "## Interaction Constraints" section inserted after "Engineer Profile Protocol", before "Team Context" — confidence: medium — keeps all three command-referenced shared patterns (Collaboration Stance, Engineer Profile Protocol, Interaction Constraints) adjacent; no ordering contract exists for shared.md sections.
- Constraint-set merge — union of the four lists plus the issue's spec: added "split by category across multiple questions" (present in verify/inquire lists, absent from the issue's enumeration) and phrased multiSelect rules generically, dropping per-file parenthetical examples ("which areas to explore", "architecture + tech debt triage") — confidence: medium — the examples illustrated the generic rules rather than carrying phase instructions; reviewer may want one or two examples restored in shared.md.
- evolve.md line ~220 "Max 4 options per question — if you have more suggestions, split" — left untouched — confidence: high — single phrase woven into evolve's suggestion-review step, not the ~15-line generic block; evolve.md is outside the issue's four-file scope and my allowed file list. Flagged below for the shepherd.
- (re-entry) Template placement — inserted "## Interaction Constraints" after "Engineer Profile Protocol" and before "## Team Context" in init.md's Step-3 scaffold — confidence: high — F1 says to match shared.md's actual section order, and that is exactly where the section sits in this worktree's shared.md.
- (re-entry) Template content — copied shared.md's eight constraint bullets verbatim, no [bracketed] placeholder — confidence: high — the set is generic rather than repo-derived, and the template already carries its other two shared patterns (Collaboration Stance, Engineer Profile Protocol) verbatim while reserving brackets for repo-specific sections.
- (re-entry) Upgrade-checklist phrasing — added `"Interaction Constraints" — if missing, add it` without repeating the first bullet's "(commands now reference this from shared.md)" parenthetical — confidence: medium — mirrors the adjacent "Engineer Profile Protocol" bullet's short form; the parenthetical reads as a one-time explanation attached to the checklist's first item.
- (re-entry) Commit topology — fix + full journal committed first with **Commit** as `pending`, then a journal-only follow-up commit recording the real hash — confidence: medium — the hash cannot be known before committing and an amend would orphan whatever hash the journal recorded; two local commits keep the journal accurate while still committing everything as the envelope requires.

### Remaining Work

- All slices complete. Reviewer finding F1 (init.md's scaffold template and upgrade checklist missing the new "Interaction Constraints" section) — resolved by Slice 2.
- Blockers: None.
- Handoff context for the reviewer: (1) check whether the dropped per-file multiSelect examples should be partially restored as examples inside shared.md's new section; (2) evolve.md retains a one-phrase constraint mention ("Max 4 options per question", ~line 220) — consistent with #47's scope but a candidate for a tiny follow-up if full consolidation is wanted; (3) CLAUDE.md's "Shared patterns (collaboration stance, profile protocol) live in .vine/context/shared.md" sentence could now also mention interaction constraints — CLAUDE.md was outside this run's allowed file list, so it was not touched.
- PR suggestion (shepherd's call to open): title "Consolidate AskUserQuestion constraints into shared.md (#47)"; body: What — the four commands (verify, inquire, navigate, optimize) each repeated the same ~8-bullet AskUserQuestion constraint list; it now lives once in shared.md's "Interaction Constraints" section, with each command keeping its phase-specific instruction plus a one-line reference. `vine:init` now scaffolds that section into new repos' shared.md and checks for it in upgrade mode, so the section the commands reference always exists. Why — removes 4-way duplication that had already drifted (each copy worded the same rules differently) and saves tokens per invocation, following the same pattern as the profile-protocol consolidation (#48). How to test — run `.vine/scripts/trellis-check.sh` (expect 11/11 pass), diff any command's reference line against shared.md's section, confirm commands read sanely with shared.md absent.

### Environment Observations <!-- throwaway scaffold (spike Q2) -->

- `CLAUDE_PROJECT_DIR`: unset/empty in this subagent's environment (`echo "$CLAUDE_PROJECT_DIR"` printed an empty string). I set it explicitly for the trellis-check invocation and ran the script with cwd in the worktree.
- cwd at session start: `/Users/robbruhn/Documents/GitHub/VINE/.claude/worktrees/distracted-hopper-cdc7c2` — a DIFFERENT worktree (the shepherd's), not my assigned workspace. All work was done via absolute paths into `headless-47`; bash cwd resets between calls were observed as warned.
- Hook output on git commit: none — the commit at bfe5458 produced no PreToolUse hook messages; trellis-gate and journal-check did not visibly fire or block.
- Hook output on Edit calls: a PreToolUse:Edit hook fired on every edit to an existing file with this message (verbatim, filename varying): "READ-BEFORE-EDIT REMINDER: You are about to modify "shared.md" which already exists. If you have not already used the Read tool to read this file in the current session, you MUST Read it first before editing. The runtime will reject edits to files that have not been read. Use the Read tool on this file path, then retry your edit." It was advisory only — all edits succeeded because each file had been Read first.
- Agent tool: NOT available in this session (absent from both the active tool list and the deferred ToolSearch list), so the `vine-verification` (slice mode) delegation could not run; acceptance criteria were checked directly by this actor (trellis exit 0, test baseline match, grep sweep for residual duplication).
- Unexpected behavior: none beyond the above; the worktree was clean and on the expected branch at session start.
