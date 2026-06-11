# Feature Spec: Platform Alignment (v0.4.0 cycle 1)
## Date: 2026-06-10
## Built on: CONTEXT.md (2026-06-10)
## Decisions made by: Rob Bruhn

### Problem Statement

VINE shadows Claude Code's native tooling instead of building on it: it claims enforcement
it can't deliver (approve-edits "requirements", "revert at the boundary"), uses "hooks"
vocabulary that collides with native hooks, duplicates repo facts between CLAUDE.md and
shared.md, re-infers slice progress from markdown when native task tools exist, and breaks
under plan mode because verify/inquire write artifacts mid-command. Cycle 1 of v0.4.0 fixes
all five: rename hooks→context (#58), back enforcement claims with real native hooks (#59),
draw the CLAUDE.md/shared.md boundary (#60), adopt native task tracking (#61), and integrate
plan mode (#62).

**Hard gates:** backward compatibility — existing `.vine/` setups keep working unchanged, and
declining any init migration offer changes nothing on disk. #58 lands first; untracked
ROADMAP.md rides in PR 1. VINE stays usable on harnesses without these native features
(everything phrased "when available").

### Approach

Decisions made during inquire, with rationale:

1. **PR slicing: 4 PRs** — #58 / #59 / #60 / #61+#62. #61 and #62 share PR 4 because both
   teach commands to consume native session machinery, but they get separate navigate
   sessions (Phases 4 and 5).
2. **Workflow map: availability-gated pointer.** CLAUDE.md gets a ~5-line VINE block: "This
   repo uses VINE. If vine commands are available in this session and `.vine/projects/` has
   active features, suggest the matching phase — routing details in
   `.vine/context/shared.md`." Full workflow map + state-based suggestions move to shared.md.
   Rationale: teams have mixed adoption and commands may be installed globally rather than
   repo-level; non-VINE teammates pay ~50 tokens and get no dead suggestions (the gate is
   command availability, visible to Claude in its skill list). `vine:optimize` maintains the
   map in shared.md and only verifies the pointer exists in CLAUDE.md.
3. **Scaffolded hooks live in tracked `.claude/settings.json`** (not settings.local.json).
   They enforce guarantees the README advertises — team-shared behavior. The init offer
   remains declinable as the personal escape hatch. This repo's contributor trellis gate is
   also tracked.
4. **Fallback nudge lives in every command's Load Context Overlays section** — one line,
   fires at most once per session when a command falls back to legacy `.vine/hooks/`.
   Findability of the 0.5 cleanup: CHANGELOG note + a tracking issue filed when PR 1 lands.
5. **All three scaffold hooks ship**: journal-before-commit (PreToolUse Bash, exit 2),
   post-edit lint (PostToolUse Edit|Write), and this repo's trellis gate (this repo's
   settings only, not the user scaffold).
6. **Active-session detection: gitignored sentinel `.vine/ACTIVE`** containing feature path,
   phase, and started-at timestamp. Navigate writes it at session start; pause, evolve, and
   navigate session-end clear it. Hooks test existence and read the feature path — no
   grepping every project, and pulled In-Progress journals from teammates (this team commits
   select projects) can never trigger hooks because the sentinel never leaves the machine.
   Stale-sentinel escape hatch: the block message says `rm .vine/ACTIVE`. The sentinel is
   deliberately minimal — it is NOT a mini-PAUSE.md; handoff state stays in PAUSE.md. It is
   also the named enabler for a future `vine:next` command (backlog, not this cycle).
7. **Conditional slices become tasks with a "(conditional: …)" prefix** carrying the
   condition text. Navigate evaluates the condition on arrival and completes-or-skips.
8. **Resume rewords its identity to "writes no files."** Native tasks are ephemeral session
   state, not artifacts — rebuilding them is restoring context. Resume gains
   TaskCreate/TaskList in allowed-tools (trellis's consensus check passes automatically).
9. **Plan mode shape: the artifact content IS the plan.** Verify presents full CONTEXT.md
   content via ExitPlanMode; approval = sign-off; file written immediately after exit.
   Inquire gets the same shape for SPEC.md — ExitPlanMode becomes the sign-off gate that
   inquire currently lacks, with an AskUserQuestion gate as the fallback when plan mode is
   off.
10. **Trellis treats legacy `.vine/hooks/` references as warnings, not failures**, with the
    Load section's own fallback line allowlisted (it legitimately names the old path through
    0.4.x). Warnings can harden to failures when the 0.5 fallback removal lands.

### Acceptance Criteria (cycle level)

- All 11 commands + trellis reference `.vine/context/`; trellis passes on the renamed tree.
- The tracked overlay files remain in the git index after the rename (gitignore negation
  moved atomically with the `git mv`).
- A legacy `.vine/hooks/` setup works untouched on 0.4.x: every command falls back, with at
  most one nudge line per session.
- Every init upgrade offer (#58 move, #59 scaffold, #60 dedup) is independently declinable;
  declining changes nothing on disk.
- Hook scripts are POSIX sh, exit 0 as no-ops when `.vine/ACTIVE` is absent, and the journal
  hook exits 2 only when the sentinel exists AND NAVIGATION.md wasn't updated since the last
  commit.
- None of the 9 cataloged dishonest claims remain; no command claims enforcement that isn't
  backed by an installed hook ("enforced when the scaffold is installed" is the ceiling).
- CLAUDE.md's VINE footprint is the pointer block (~5 lines); the workflow map lives in
  shared.md; `vine:optimize` maintains it there.
- Navigate/resume create native tasks only "when available"; NAVIGATION.md is unchanged as
  the durable journal (a repo with no task tools behaves exactly as today).
- Verify and inquire complete cleanly with plan mode on AND off; with plan mode on,
  ExitPlanMode approval is the only gate before the artifact write.
- README documents enforced-vs-advisory guarantees and plan-mode behavior.

---

## Phase 1: The Rename (Slices 1–5) — #58, PR 1 ✅

Summary: Rename `.vine/hooks/` → `.vine/context/` across the repo with fallback, migration
offer, trellis validation, and docs. ROADMAP.md rides along in this PR.
Session boundary: After this phase, the rename is complete, trellis passes, and legacy
setups still work. PR 1 ships.

### Slice 1: Directory move + tracked overlays
**Goal**: `git mv .vine/hooks .vine/context`; update `.gitignore` (`!.vine/hooks/` →
  `!.vine/context/`) in the SAME commit; retitle overlay files
  (`.vine/context/{shared,verify,navigate,evolve,pair}.md`) and fix their self-referential
  paths. Note: no inquire.md overlay exists — don't create one.
**Depends on**: Nothing. First commit of the cycle.
**Files likely touched**: `.gitignore`, `.vine/context/*.md` (5 files)
**Acceptance criteria**: `git ls-files .vine/` still lists all 5 overlays post-commit; no
  file content references `.vine/hooks/` within the overlays.
**Complexity signal**: Medium — the gitignore negation ordering (`.vine/*` then
  `!.vine/context/`) is the silent-untracking trap from verify.

### Slice 2: Command rename + fallback pass
**Goal**: All 11 command files: `## Load Project Hooks` → `## Load Context Overlays`, all
  path references updated, PLUS the fallback logic ("check `.vine/context/` first; if absent,
  fall back to `.vine/hooks/` and nudge once per session: one line suggesting `vine:init` to
  migrate") written into the same Load sections. One pass — touch 11 files once, not twice.
**Depends on**: Slice 1 (paths must exist).
**Files likely touched**: `commands/vine/*.md` (11 files; densest: init ~20 refs, evolve ~16
  including Hook Update Suggestions flow, navigate 8 including custom-validation lookups at
  lines 201, 334)
**Acceptance criteria**: Zero `.vine/hooks/` references in commands EXCEPT the fallback line
  itself; nudge wording is identical across commands; help.md (2 refs) updated even though it
  has no Load section.
**Complexity signal**: Medium — mechanical but wide; evolve's Hook Update Suggestions flow
  needs renaming as a flow, not just paths.

### Slice 3: Init migration offer
**Goal**: Extend init Step 7 (existing upgrade pass, lines 174–191): when `.vine/hooks/`
  exists and `.vine/context/` doesn't, offer the directory move via AskUserQuestion.
  Declining changes nothing; commands keep working via fallback.
**Depends on**: Slice 2 (fallback must exist for the decline path to be safe).
**Files likely touched**: `commands/vine/init.md`
**Acceptance criteria**: Offer appears only in the legacy-dir condition; decline path
  explicitly documented as a no-op; accept path includes the user-repo .gitignore caveat.
**Complexity signal**: Low.

### Slice 4: Trellis update
**Goal**: Check 4 validates `## Load Context Overlays` + `.vine/context/<phase>.md`; Check 6
  ordering updated to the new heading. NEW legacy-detection: any `.vine/hooks/` reference
  warns (not fails), with the Load-section fallback line allowlisted.
**Depends on**: Slice 2 (new heading must exist to validate).
**Files likely touched**: `.claude/commands/trellis.md`
**Acceptance criteria**: Trellis passes on the renamed tree; injecting a stray
  `.vine/hooks/` ref into a command produces a warning naming file+line; the fallback line
  produces no warning. *Addendum (Slice 3)*: init's Step 7 "Legacy Directory Migration"
  section must also be allowlisted — it legitimately names the legacy path throughout 0.4.x.
**Complexity signal**: Medium — the exemption needs to be precise enough not to mask real
  stragglers.

### Slice 5: Docs periphery
**Goal**: Rename pass over README ("Project Hooks" section ~183–259), CLAUDE.md (7 refs),
  CONTRIBUTING.md, references/STATE.md (lines 150, 296), agents/vine-verification.md (line
  75), `.github/ISSUE_TEMPLATE/idea.md` ("hook pattern" disambiguation one-liner),
  `docs/artifact-preview.md` (SURGICAL: `.vine/hooks/artifact-preview.sh` path renames;
  `~/.claude/hooks/` and settings.json `"hooks"` key stay — both meanings appear on the same
  line in places, no find-replace), `bin/cli.js` line-77 message ("project hooks" → new
  vocabulary), CHANGELOG 0.4.0 entry (rename + migration documented; history entries
  untouched). Commit untracked ROADMAP.md in this PR.
**Depends on**: Slices 1–4 (documents the finished behavior).
**Files likely touched**: README.md, CLAUDE.md, CONTRIBUTING.md, references/STATE.md,
  agents/vine-verification.md, .github/ISSUE_TEMPLATE/idea.md, docs/artifact-preview.md,
  bin/cli.js, CHANGELOG.md, ROADMAP.md
**Acceptance criteria**: `grep -r '.vine/hooks'` across the repo hits only: command fallback
  lines, init's Step 7 legacy-migration section (added in Slice 3), the trellis exemption
  description, CHANGELOG history, and the "do not rename" set (ROADMAP native-hooks lines,
  CHANGELOG line 46); artifact-preview.md's native-hook references intact. *Addendum (Slice
  5)*: two new legitimate refs added by this slice — the CHANGELOG [Unreleased] rename entry,
  and the fallback-window notes in README's Context Overlays section + CLAUDE.md's Load
  section convention bullet. All three document the 0.4.x fallback and are removed with it
  in 0.5 (in scope for the cleanup tracking issue). Historical `.vine/projects/` artifacts
  are exempt (same don't-rewrite-history policy as CHANGELOG).
**Complexity signal**: Medium — artifact-preview.md is the collision-dense file.

---

## Phase 2: Honest Enforcement (Slices 6–10) — #59, PR 2 ✅

Summary: Sentinel lifecycle, native hook scripts, init scaffold offer, and the honest-prose
pass that makes every enforcement claim true or advisory.
Session boundary: After this phase, installed hooks mechanically enforce the journal and
lint guarantees, and no prose overclaims. PR 2 ships.

*Addendum (post-PR review, 2026-06-10, decided by: engineer)*: **post-edit-lint.sh removed
from the scaffold** while PR #65 was open. Rationale: per-edit validation is wholly
repo-dependent (the script was a hollow trigger with no validation logic), had no file
scoping (VINE's own artifact edits — journal updates, SPEC annotations — would fire it
constantly by design), and its claim (#9, per-slice validation) was already answered by the
agent-based slice check. When/how to run a repo's checks stays with the repo; native hooks
in settings.json are available directly. The scaffold ships ONE hook (journal-check); the
`hook-validation:` marker convention dies unshipped; #54's Validation block is the future
home if VINE grows a validation contract. Touch points unwound: Slice 7 (script + tests),
Slice 8 (init offer now single-hook, cli/package ship one script, settings.json has no
PostToolUse), Slice 9 (navigate's lint-hook parenthetical removed), Slice 10 (README
enforced table is one row + an explicit "validation is the repo's decision" boundary
statement). Tech-debt row "lint hook reads navigate-overlay validation commands until #54"
is resolved by removal.

### Slice 6: Sentinel lifecycle
**Goal**: Navigate writes `.vine/ACTIVE` at session start (feature path, phase, started-at
  timestamp — minimal, NOT a mini-PAUSE.md); pause, evolve, and navigate session-end clear
  it. Document in STATE.md as an ephemeral artifact (same class as PAUSE.md). Covered by
  existing `.vine/*` gitignore in user repos; verify this repo's gitignore covers it too.
**Depends on**: Phase 1 complete (touches the renamed Load sections' vocabulary).
  *Addendum (session decision, 2026-06-10)*: PAUSE.md becomes consumed-once — today nothing
  deletes it when work resumes (resume is read-only; only re-pause overwrites and
  evolve-resolve deletes), so a consumed pause lingers and keeps firing the "PAUSE.md exists
  → suggest resume" state suggestion. New rule: resume or any main phase command that picks
  work back up on a feature deletes that feature's PAUSE.md once the pause state is consumed
  (phase commands at session start, the same moment the sentinel is written; resume after
  displaying the notes — mechanics resolved in Slice 16). STATE.md's PAUSE lifecycle section
  documents the consumed-once rule.
**Files likely touched**: commands/vine/navigate.md, pause.md, evolve.md,
  references/STATE.md
**Acceptance criteria**: Every navigate exit path (complete, pause, abandon-via-evolve)
  clears the sentinel; STATE.md documents format + lifecycle + staleness escape hatch.
  *Addendum (2026-06-10)*: phase commands delete a PAUSE.md they find for the feature at
  session start; STATE.md's PAUSE lifecycle lists every deletion trigger (resume/phase
  consumption, evolve-resolve) — no consumed pause survives a restarted session.
**Complexity signal**: Low.

### Slice 7: Hook scripts
**Goal**: `.vine/scripts/journal-check.sh` (PreToolUse on Bash: if `.vine/ACTIVE` exists and
  the active feature's NAVIGATION.md is older than the last commit, exit 2 with a message
  naming the journal AND the `rm .vine/ACTIVE` escape hatch) and
  `.vine/scripts/post-edit-lint.sh` (PostToolUse on Edit|Write: if sentinel exists, run the
  custom validation command from the navigate overlay — interim source until #54's
  Validation block — exit 0 if none configured). Both POSIX sh, stdin-JSON tolerant, exit-0
  no-ops when no sentinel. Design constraint: scripts treat the feature path in
  `.vine/ACTIVE` as an opaque repo-relative string — no domain/slug parsing, no assumption
  that it lives under `.vine/projects/` — so future `.vine.local/` paths (see Backlog
  Updates) work unchanged.
**Depends on**: Slice 6 (sentinel contract).
**Files likely touched**: .vine/scripts/journal-check.sh (new), .vine/scripts/post-edit-lint.sh
  (new), references/STATE.md (scripts dir note)
**Acceptance criteria**: Scripts pass `sh -n`; no-sentinel invocation exits 0 with no
  output; journal-check exits 2 only under sentinel+stale-journal; lint script exits 0 when
  no validation command is configured; no bashisms; no domain/slug parsing of the sentinel's
  feature path anywhere in either script.
**Complexity signal**: High — exit-code semantics, stdin JSON without jq guarantees, and
  POSIX portability.

### Slice 8: Init scaffold offer + this repo's trellis gate
**Goal**: Init (new sub-step in Step 7 region) offers installing the two hooks into tracked
  `.claude/settings.json` + copying scripts into `.vine/scripts/` — each independently
  declinable, decline changes nothing. Separately: this repo gets a tracked
  `.claude/settings.json` with a PreToolUse trellis-gate hook (blocks commits touching
  `commands/vine/` unless trellis passed) — this-repo only, not in the user scaffold.
**Depends on**: Slice 7 (scripts must exist to scaffold).
**Files likely touched**: commands/vine/init.md, .claude/settings.json (new, this repo),
  .vine/scripts/trellis-gate.sh (new, this repo)
**Acceptance criteria**: Scaffold offer merges into existing settings.json without
  clobbering unrelated keys; each hook is a separate AskUserQuestion option (multiSelect);
  this repo's gate documented in shared.md CI/CD section.
**Complexity signal**: Medium — settings.json merge semantics need care in prose.

### Slice 9: Honest prose pass
**Goal**: Rewrite the 9 cataloged claims (verify.md 58–61; navigate.md 39–42, 121, 126–130,
  196–203, 210–211, 250–252; help.md 57; README.md 105–106) on pair.md 45–51's template:
  "recommended", soft ask, "don't block on this." Where the #59 scaffold exists, prose may
  say "enforced when the scaffold hooks are installed" — never stronger. Free-climb gear
  (navigate 126–130) reframed as a request to the engineer to switch modes, not a claim the
  model switches them.
**Depends on**: Slices 7–8 (the enforcement that prose may now reference).
**Files likely touched**: commands/vine/verify.md, navigate.md, help.md, README.md
**Acceptance criteria**: Each of the 9 inventory items diffed against its rewrite; no
  remaining claim that the model checks, switches, or reverts permission modes; navigate's
  journal claim now points at the journal-check hook as its mechanism.
**Complexity signal**: Medium — wording precision; memory note applies (modes need
  mechanical teeth, and now they have them).

### Slice 10: README enforced-vs-advisory section
**Goal**: New README section: which guarantees are enforced (journal-before-commit,
  post-edit lint — when scaffold installed) vs advisory (everything else), and how to
  install/decline the scaffold.
**Depends on**: Slice 9.
**Files likely touched**: README.md
**Acceptance criteria**: Every guarantee VINE mentions appears in exactly one column;
  section links from the old "approve-edits" tip locations.
**Complexity signal**: Low.

---

## Phase 3: Knowledge Boundary (Slices 11–13) — #60, PR 3 ✅

Summary: Define the CLAUDE.md/shared.md boundary rule, dedup this repo, move the workflow
map, and teach init to offer dedup.
Session boundary: After this phase, each fact has one home and optimize maintains the
boundary. PR 3 ships.

### Slice 11: Boundary rule + this-repo dedup
**Goal**: Document the rule in references/STATE.md: CLAUDE.md = repo facts every session
  needs (any teammate, any tool); `.vine/context/shared.md` = VINE workflow knowledge;
  `.vine/knowledge/<domain>.md` named as a FORWARD REFERENCE only (pointer-line convention
  defined now, implemented in cycle 3's #51). The rule paragraph also names the sharing
  boundary for projects: tracked `.vine/projects/` = team-shared; personal work lives
  outside the shared tree, with the `.vine.local/` backlog issue as the forward reference
  (same pattern as the #51 `.vine/knowledge` pointer). Then single-home this repo's
  near-verbatim duplicates (Repository Structure, authoring conventions, command inventory)
  per the rule. *Addendum (session decision, 2026-06-10)*: the rule defines four surfaces
  keyed to reader scope — CLAUDE.md (repo facts: every session, every teammate); the
  harness's native skill/agent list (the command/agent INVENTORY — enumerated nowhere in
  files, the harness provides it); `.vine/context/shared.md` (cross-phase only: protocols,
  project-development context, inter-phase routing); `.vine/context/<phase>.md`
  (phase-specific mappings: agents, validation commands). shared.md's identity in one line:
  cross-phase protocols + project-dev context + routing — nothing phase-specific, nothing
  the harness already surfaces. This repo's "command inventory" duplicate therefore resolves
  by deletion (the native list is its home), keeping only repo-specific notes (symlink
  topology) deduped against CLAUDE.md.
**Depends on**: Phase 1 (new paths/vocabulary).
**Files likely touched**: references/STATE.md, CLAUDE.md, .vine/context/shared.md
**Acceptance criteria**: No section appears near-verbatim in both files; each moved section
  leaves a one-line pointer at its old home; the rule text names both forward references
  explicitly (#51 `.vine/knowledge`, `.vine.local/` projects boundary); the rule is framed
  by cost — it states what a non-VINE teammate pays for
  anything homed in CLAUDE.md (every session, every teammate) vs shared.md (VINE sessions
  only), not just which file holds what. *Addendum (2026-06-10)*: the rule names the
  native-surface category explicitly (inventory lives nowhere; phase routing lives in
  overlays); shared.md's "Available Tools & Agents" section reduces to repo-specific notes
  with no command/agent enumeration.
**Complexity signal**: Medium — judgment calls on which home each section gets.

### Slice 12: Optimize rewrite + CLAUDE.md pointer
**Goal**: `vine:optimize` writes the workflow map (Skill Workflows + state-based
  suggestions) to shared.md; CLAUDE.md gets the availability-gated pointer block ("This repo
  uses VINE. If vine commands are available in this session and .vine/projects/ has active
  features, suggest the matching phase — routing in .vine/context/shared.md."); optimize
  verifies the pointer exists rather than maintaining a map in CLAUDE.md. Apply to this
  repo's CLAUDE.md as the first execution. *Addendum (session decision, 2026-06-10)*: the
  workflow map is chains + state-based suggestions ONLY — no command inventory; the native
  skill list is the inventory's home. Optimize's audit verifies each phase overlay points at
  its phase-relevant tools/agents instead of checking any file-based inventory for
  completeness.
**Depends on**: Slice 11 (boundary rule is the justification optimize cites).
**Files likely touched**: commands/vine/optimize.md, CLAUDE.md, .vine/context/shared.md
**Acceptance criteria**: CLAUDE.md's VINE content is ≤ ~10 lines; pointer makes no
  assumption about install location; optimize's write-target instructions name shared.md;
  the availability-gated pointer pattern (gate suggestions on whether the commands are
  actually present in the session) is recorded as a convention in shared.md so future
  commands reuse it instead of reinventing the mixed-adoption answer. *Addendum
  (2026-06-10)*: the map optimize writes contains no command enumeration; a command/agent
  inventory appearing in shared.md is an audit finding, not a feature. *Addendum (post-#65
  review, 2026-06-10)*: #54 (cycle 4) assigns optimize a standing Validation-block audit —
  stale commands, uncovered tooling, missing block (design in the #54 comment thread). The
  rewrite should structure optimize's audit sections so #54 adds a check, not another
  rewrite. Don't implement the audit in this slice.
**Complexity signal**: Medium.

### Slice 13: Init dedup offer
**Goal**: Init upgrade pass detects CLAUDE.md/shared.md overlap in user repos and offers
  single-homing per the boundary rule. Declinable; decline changes nothing.
**Depends on**: Slice 11 (the rule it applies).
**Files likely touched**: commands/vine/init.md
**Acceptance criteria**: Offer shows a concrete diff preview before asking; decline path is
  a documented no-op.
**Complexity signal**: Low.

---

## Phase 4: Native Tasks (Slices 14–16) — #61, PR 4 ✅

Summary: Navigate/resume/status adopt native task tools as the live progress view;
NAVIGATION.md stays the durable journal.
Session boundary: After this phase, task tracking works end-to-end where task tools exist
and changes nothing where they don't. PR 4 stays open for Phase 5.

### Slice 14: STATE.md contracts
**Goal**: Document the two undocumented writer/reader contracts: `Status: In Progress /
  Complete` heading suffix (written navigate line 215, read pause line 66 — add to the
  NAVIGATION template with a `<!-- required -->` marker) and `### Remaining Work` (promote
  from `<!-- optional -->` or document resume's and #61's dependency on it — decide in
  navigate based on template fit). Define the live-view (native tasks, ephemeral) vs
  durable-journal (NAVIGATION.md, source of truth) split.
**Depends on**: Phase 1 (STATE.md already touched there; rebase-clean).
**Files likely touched**: references/STATE.md
**Acceptance criteria**: Both contracts have required/optional markers; the split section
  states that tasks are rebuilt FROM the journal, never the reverse.
**Complexity signal**: Low.

### Slice 15: Navigate task tracking
**Goal**: At session start (after phase-group identification), when task tools are
  available, TaskCreate one task per remaining slice in the current phase group — conditional
  slices get a "(conditional: <condition>)" title prefix; navigate evaluates on arrival and
  completes-or-skips. TaskUpdate in_progress/completed at slice transitions, woven into the
  existing commit flow (journal update remains inseparable from commit). All phrased "when
  available" — absent task tools, behavior is exactly today's.
**Depends on**: Slice 14 (contracts it implements).
**Files likely touched**: commands/vine/navigate.md
**Acceptance criteria**: Task list matches SPEC.md's remaining slices for the current group;
  no NAVIGATION.md format change; allowed-tools gains TaskCreate/TaskUpdate/TaskList
  (trellis consensus check passes).
**Complexity signal**: Medium.

### Slice 16: Resume + status task awareness
**Goal**: Resume rebuilds the task list from NAVIGATION.md + SPEC.md (same conditional
  prefix rule) and rewords its identity from "read-only — shows status and recommends,
  nothing more" (resume.md 174) to "writes no files." Status gains optional TaskList
  awareness for its "[X of Y] slices" display and gets the wording fix for the "no deep file
  scanning" tension.
**Depends on**: Slice 15 (shared rebuild semantics).
  *Addendum (session decision, 2026-06-10)*: resume also deletes the feature's PAUSE.md
  after displaying it (the consumed-once rule from Slice 6's addendum). This needs a
  tooling change (resume currently has no Write/Bash) and softens the "writes no files"
  identity — reword to "creates no artifacts" (deleting consumed ephemeral session state
  is not artifact writing). Resolve the exact wording and tool grant in this slice.
**Files likely touched**: commands/vine/resume.md, status.md
**Acceptance criteria**: Resume's rebuilt list matches what navigate would create; resume
  still writes zero files; status works unchanged when task tools are absent. *Addendum
  (2026-06-10)*: "writes zero files" AC amended to "creates zero artifacts"; after a resume,
  the displayed PAUSE.md no longer exists.
**Complexity signal**: Medium.

---

## Phase 5: Mode, Gate & Commit Hygiene (Slices 17–20) — #62, PR 4 (shared) ⬜

Summary: SPEC.md is VINE's plan and the artifact chain + AskUserQuestion sign-offs are the gate —
harness plan mode is left to the harness, neither narrated nor integrated by VINE. This phase
sharpens navigate's gearing into an explicit permission-mode preference (free climb →
auto-accept-edits; walk-me-through → approve-edits), closes inquire's missing sign-off gate,
presents each artifact as a rendered, clickable link for review, and makes the artifact-commit
guidance for tracked repos consistent and complete.
Session boundary: Feature complete; PR 4 ships; cycle ready for evolve.

> **Reshape (navigate session, 2026-06-10).** The original Phase 5 made verify and inquire
> render their artifacts *through* `ExitPlanMode` as "the plan." Investigation (carried in the
> Phase 4 handoff, re-confirmed against the live tool this session) found this misaligned:
> `ExitPlanMode` takes **no content parameter** (it renders the harness's plan *file*) and its
> own documentation says it is for planning **code-writing** tasks and explicitly **not** for
> research — so verify (research) is a documented non-fit and inquire (spec) only a partial fit.
> Forcing the research/spec phases through `ExitPlanMode` re-introduces exactly the
> overclaim-the-harness-behavior anti-pattern Phase 2 ("Honest Enforcement") existed to remove.
> Decision (engineer): **SPEC.md is the plan**; the artifact chain + per-phase sign-off already
> gate writes, and the "clean break" between phases is itself the approval boundary. Reshape the
> phase from "ExitPlanMode integration" to "**plan-mode robustness + close inquire's real
> sign-off gate + honest docs**," and add an **artifact review-link** affordance (rendered
> artifact + clickable link at the sign-off/creation moment; auto-open documented as optional
> repo wiring, never hardcoded — OS-specific, dead in headless sessions, a repo-owned decision).
> The rendered-approval UX that made plan mode appealing is reconstructed natively: response
> output is rendered GFM, the artifact file opens rendered in the editor, AskUserQuestion is the
> gate.
>
> **Further redirect (same session).** The engineer then chose to drop plan mode from the cycle
> *entirely* — not even a robustness shim. Rationale: harness plan mode is a harness concern the
> harness already handles (Claude calls `ExitPlanMode` on its own when it needs to write); a VINE
> command teaching it that would be narrating behavior VINE doesn't own — the same repo/harness-
> owned-decision line drawn when the lint hook was pulled in Phase 2. Instead, Slice 17 becomes a
> **gearing ↔ permission-mode preference** in navigate: free climb recommends auto-accept-edits
> (or auto), walk-me-through recommends approve-edits (per-edit permission prompts). The
> recommendation is explicit; the toggle stays the engineer's action (honest-modes rule). verify
> and inquire already recommend approve-edits in "Before You Start" (no gearing, single mode), so
> Slice 17 is navigate-only. Slice 18 (inquire gate + review links) stands as reshaped (it never
> depended on plan mode).
>
> **Scope addition (same session).** Tracking platform-alignment's artifacts mid-cycle (every
> other VINE project commits its artifacts) surfaced a real gap: VINE's commit-contents guidance
> for tracked-artifact repos is inconsistent (navigate step 4c conditionalizes only NAVIGATION.md;
> evolve stages EVOLUTION.md unconditionally) and incomplete (no guidance for SPEC deviations or
> PROJECT-MAP/Milestones boundary commits). Engineer's call: fold a new **Slice 19 — artifact-
> commit guidance** into Phase 5. The README/CHANGELOG docs slice renumbers 19 → 20 and now also
> documents the commit guidance.

### Slice 17: Gearing ↔ permission-mode preference (navigate)
**Goal**: navigate's per-slice gearing decision recommends the permission mode that fits the
  chosen gear, making the existing implicit mapping explicit and symmetric: **free climb →
  auto-accept-edits (or auto)** so edits land without a prompt each time; **walk-me-through →
  approve-edits (per-edit permission prompts)** so the engineer reviews each edit as it lands.
  Surface the recommended mode in the gear-option descriptions and the Gearing prose. Honest-
  modes rule preserved: the command *recommends* the mode; the toggle is always the engineer's
  action — never flip it or assume it happened. No mention of harness plan mode anywhere (it is
  a harness concern the harness already handles). verify/inquire unchanged — they have no gearing
  and already recommend approve-edits in "Before You Start."
**Depends on**: Phase 4 merged into the PR branch (shared PR).
**Files likely touched**: commands/vine/navigate.md
**Acceptance criteria**: Both gear options name their recommended permission mode; the Gearing
  prose states the free-climb→auto-accept and walk-through→approve-edits preference symmetrically;
  every mode reference frames the toggle as the engineer's action (no model-switches-mode claim);
  no plan-mode or `ExitPlanMode` reference is introduced.
**Complexity signal**: Low.

### Slice 18: Inquire sign-off gate + artifact review links
**Goal**: inquire gains an explicit AskUserQuestion sign-off gate that closes the missing-gate
  tech debt. Model (engineer's call): **write-then-review** — the SPEC.md draft is written
  (step 8), then Phase Completion presents it for review (a clickable link so it opens rendered
  in the editor, plus a short summary), and an AskUserQuestion gate (Approve → hand to navigate /
  Request changes → revise + re-present, loop) gates *completion* (the PROJECT-MAP inquire ✅ and
  the navigate handoff), not the draft write itself. The multi-PR Milestones draft is part of the
  reviewed spec. Apply the same clickable review-link affordance to verify's CONTEXT.md creation.
  Auto-open is documented as optional repo wiring (a repo can wire its editor open command in the
  overlay), never hardcoded — the clickable link is the portable default.
**Depends on**: None (independent of Slices 17 and 19).
**Files likely touched**: commands/vine/inquire.md, commands/vine/verify.md
**Acceptance criteria**: inquire does not complete (PROJECT-MAP inquire ✅ / handoff to navigate)
  without an explicit AskUserQuestion sign-off on the written SPEC; the sign-off presents SPEC.md
  as a clickable link and supports a request-changes/iterate path; the Milestones draft is part of
  the reviewed spec; verify presents CONTEXT.md as a clickable link on creation; auto-open appears
  only as documented optional repo wiring; trellis passes on both edited commands.
**Complexity signal**: Medium.

> **Slice 18 design note (deviation from original AC).** The original AC read "no artifact write
> precedes approval" — borrowed from the (since-dropped) plan-mode model. A clickable review link
> needs the file written first, and the engineer asked to review via the file/preview, so the gate
> moved to *completion* (write draft → review via link → approve/iterate → gate the ✅ + handoff).
> SPEC.md as a working draft before sign-off is harmless; it gets revised on a request-changes loop.

### Slice 19: Artifact-commit guidance for tracked repos
**Goal**: Make VINE's commit-contents guidance consistent and complete for repos that track
  `.vine/` artifacts (the team-shared choice per the Knowledge Boundary rule). State one principle
  across the commands: a **slice commit** bundles the code with that slice's artifact mutations
  (the NAVIGATION.md journal entry and any SPEC.md deviation annotations from step 6); a
  **phase-group boundary commit** carries the tracker updates (PROJECT-MAP.md navigate row +
  Milestones row → status/PR#, and the SPEC.md phase header ⬜→✅); a **PR (= one phase group)**
  therefore carries the group's full artifact state (SPEC plan, NAVIGATION record, PROJECT-MAP
  tracker) alongside the diff. Align the existing inconsistency: navigate step 4c conditionalizes
  only NAVIGATION.md while evolve stages EVOLUTION.md unconditionally — both follow the same rule
  (**tracked → include the artifact; untracked / personal scope → unchanged**, the mtime-based
  journal guarantee still holds). STATE.md carries the principle as the single source.
**Depends on**: None (independent of Slices 17–18).
**Files likely touched**: commands/vine/navigate.md (step 4c + step 8), commands/vine/evolve.md
  (the EVOLUTION/commit step), references/STATE.md (artifact-commit principle).
**Acceptance criteria**: navigate and evolve each state their own staging rule **inline and
  self-sufficiently** (a user repo without STATE.md still commits correctly); STATE.md carries the
  consolidated cross-command contract (the per-commit-point table incl. the PR-level rollup) for
  contributors; the command `references/STATE.md` pointer is supplementary / harmless-if-absent;
  untracked-repo behavior is explicitly unchanged (mtime guarantee preserved); trellis passes on
  the edited commands.
**Complexity signal**: Medium.

> **Slice 19 design note (refinement).** Original goal said "STATE.md carries the principle as the
> single source." But `create-vine` ships only `bin`, `commands/vine`, `agents`, and
> `journal-check.sh` — **not `references/STATE.md`** (confirmed in package.json `files`). So the
> rule can't be load-bearing in STATE.md alone, or user repos would be pointed at a file they
> don't have. Resolution (engineer raised it): each shipped command states its own staging rule
> inline; STATE.md holds the consolidated cross-command contract as the contributor map; the
> `(see STATE.md)` pointer is supplementary, exactly like the existing sentinel/journal-check
> references. This is the Knowledge Boundary "same subject, different reader scope" case.

### Slice 20: README gearing↔mode + task + commit-guidance docs
**Goal**: README documents navigate's gearing↔permission-mode mapping (free climb →
  auto-accept-edits; walk-me-through → approve-edits, toggle is the engineer's action), the
  artifact review-link affordance + optional auto-open repo wiring, the task-tracking live-view
  (with the journal as source of truth), and the tracked-repo artifact-commit guidance from
  Slice 19 (what a slice commit vs a phase-group PR carries). CHANGELOG 0.4.0 entry completed
  for #59–#62.
**Depends on**: Slices 15–19.
**Files likely touched**: README.md, CHANGELOG.md
**Acceptance criteria**: A reader can predict the recommended permission mode for each gear, how
  artifact review links behave, and what a tracked-repo commit/PR carries; docs make no claim
  about harnesses where the features don't exist and introduce no plan-mode / `ExitPlanMode` claims.
**Complexity signal**: Low.

---

### Tech Debt Integration

| Debt | Decision | Where |
|------|----------|-------|
| CLAUDE.md ↔ shared.md duplication | Address now | Slice 11 |
| `Status: In Progress` contract undocumented | Address now | Slice 14 |
| Remaining Work optional-vs-depended | Address now | Slice 14 |
| inquire missing sign-off gate | Address now | Slice 18 |
| navigate/evolve artifact-commit guidance inconsistent + incomplete | Address now | Slice 19 (new) |
| idea.md "hook pattern" ambiguity | Address during | Slice 5 |
| status.md "no deep scanning" wording | Address during | Slice 16 |
| Stale tool-graph artifacts | Defer | #56, cycle 3 |
| **New debt accepted**: lint hook reads navigate-overlay validation commands until #54 lands | Accept consciously | Slice 7; #54 is the canonical home, noted in script comments and #54 |

### Backlog Updates

- **New**: `vine:next` command — auto-route to the next phase/slice using `.vine/ACTIVE` as
  its state source. The sentinel (Slice 6) is the named enabler. File as an idea issue.
- **New**: `.vine.local/` sibling root for personal (non-shared) projects — file as an idea
  issue. A gitignored root mirroring `.vine/`'s structure (precedent: settings.json vs
  settings.local.json, .env vs .env.local): the shared tree stays spec-shaped, gitignore is
  one root-level line with no negation traps, and discovery stays two-level under each root.
  Commands resolve features against `.vine/` then `.vine.local/`. Needs design for:
  root-resolution order, both-roots collision, which root verify writes to, whether local
  context overlays exist (v1: projects only). Only relevant for teams that track `.vine/`.
  Motivating bug the issue should note: the interim folk convention at pilots is
  `projects/_local/<domain>/<feature>` — three-level, so current two-level discovery
  globbing misses it.
- **New**: 0.5 cleanup tracking issue — remove the `.vine/hooks/` fallback + nudge, remove
  trellis's fallback-line exemption, consider hardening legacy warnings to failures. File
  when PR 1 lands; reference from the CHANGELOG 0.4.0 entry.
- **Note on #54** (cycle 4): when the Validation block lands, switch post-edit-lint.sh's
  command source from the navigate overlay to the block.
- **Unchanged**: #56 (tool-graph archival, cycle 3), #51 (.vine/knowledge, cycle 3 — now has
  a defined pointer convention waiting for it).
- **New (Slice 14)**: optional init-upgrade offer to normalize legacy `#### Slice` (h4) SPECs
  to the canonical `### Slice` (h3) — file as an idea issue. Surfaced when Slice 14 made
  `### Slice N:` the canonical trellis contract (h3-only); the four h4 specs in this repo are
  all resolved, so no live regression, but a reopened legacy spec would fail Check A. Interim
  update path ships in Slice 14: trellis's Check A names the re-level fix. The init offer is
  the "during upgrade" path — declinable like every other upgrade offer (decline = no-op);
  must NOT blanket-rewrite per-feature artifacts without explicit per-spec confirmation, since
  feature artifacts are often personal/gitignored.

### Dependencies & Risks

- **gitignore atomicity (Slice 1)** is the highest-blast-radius step — verified trap, must
  be one commit.
- **POSIX sh portability (Slice 7)**: no jq guarantee for stdin JSON; scripts must degrade
  gracefully. Highest-complexity slice in the cycle.
- **Mixed-adoption teams**: pointer gating and sentinel locality are the two mechanisms
  protecting non-VINE teammates; both must hold in review.
- **Harness variance**: task tools and plan mode are per-harness; every #61/#62 behavior is
  conditional ("when available"). VINE on other harnesses must be unaffected (closed #6
  commitment).
- **PR 4 spans two navigate sessions** (Phases 4 and 5) — phase-group verification runs
  after each phase; the PR opens only after Phase 5.
- **Solo maintainer, self-review**: trellis + the new trellis gate hook are the only
  mechanical reviewers; run `/trellis` before every commit touching commands (memory note).
- **Out-of-band change already in the working tree** (2026-06-10, post-inquire): verify.md,
  inquire.md, and navigate.md Phase Completion sections gained a "persist actionable retro
  items into the phase artifact before printing the retro block" instruction — retro blocks
  are ephemeral and die at `/clear`. Preserve this through the cycle's edits to those
  sections; natural commit home is PR 1's command pass (Slice 2 touches all 11 commands).
