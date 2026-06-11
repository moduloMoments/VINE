# Feature Context: Platform Alignment (v0.4.0 cycle 1)
## Date: 2026-06-10
## Author: Rob Bruhn + Claude

Cycle 1 of the v0.4.0 milestone: align VINE with Claude Code's native tooling instead of
shadowing it. Issues: [#58](https://github.com/moduloMoments/VINE/issues/58) rename
hooks→context, [#59](https://github.com/moduloMoments/VINE/issues/59) native hook
enforcement + honest prose, [#60](https://github.com/moduloMoments/VINE/issues/60)
CLAUDE.md/shared.md boundary, [#61](https://github.com/moduloMoments/VINE/issues/61) native
task tracking, [#62](https://github.com/moduloMoments/VINE/issues/62) plan mode integration.

**Hard constraints (from ROADMAP.md):**
- Backward compatibility is a hard gate: existing `.vine/` setups keep working unchanged, or
  `vine:init`'s upgrade pass offers an explicit migration — and declining changes nothing.
- #58 lands first within the cycle; the uncommitted ROADMAP.md rides along in the first PR.
- Multi-PR cycle: PROJECT-MAP.md gets a Milestones table during inquire.

### Codebase Landscape

**Edit-once topology.** `.claude/commands/vine` is a symlink to `../../commands/vine` — each
command file is edited exactly once. (An explorer agent initially reported them as copies;
verified false.) `.claude/agents` is also a symlink to `../agents`. The npm package
(`package.json` files array) ships only `bin`, `commands/vine`, `agents` — `.vine/` is never
distributed; `bin/cli.js` copies command files and prints one conceptual "project hooks"
message (line 77).

**#58 rename surface — 27 unique files.** Full per-file inventory with line numbers gathered
during verify (agent report; spot-checked). Anchors:

- All 11 command files: `## Load Project Hooks` section heading + `.vine/hooks/shared.md` /
  `.vine/hooks/<phase>.md` paths. Densest: init.md (~20 refs), evolve.md (~16, including the
  `### Hook Update Suggestions` flow), navigate.md (8, including custom-validation-command
  lookups at lines 201, 334).
- `.claude/commands/trellis.md`: Check 4 requires the literal heading `## Load Project Hooks`
  and the substring `.vine/hooks/<phase>.md`; Check 6 enforces hooks-before-profile ordering
  by heading string. #58 acceptance requires trellis to validate the NEW naming and flag
  legacy references — checks need a legacy-detection mode, not just a string swap.
- `.gitignore`: the `!.vine/hooks/` negation tracks the overlay files. **Renaming the
  directory without updating this line silently untracks shared.md and the per-phase
  overlays.** Must become `!.vine/context/` in the same commit as the `git mv`.
- `commands/vine/init.md` Step 7 (lines 174–191) is the existing upgrade pass (triggers when
  `.vine/hooks/` exists, diffs via AskUserQuestion, merges without overwriting custom
  content). The #58 directory migration and #60 dedup offer both hang off this step.
- Tracked overlay files themselves (`.vine/hooks/{shared,verify,navigate,evolve,pair}.md`)
  carry "Hooks" titles and self-referential paths. Note: no `inquire.md` overlay exists.
- Docs: README (entire "Project Hooks" section, lines ~183–259), CLAUDE.md (7 refs),
  CONTRIBUTING.md (1), references/STATE.md (2: EVOLUTION template line 150, abstract use
  line 296), agents/vine-verification.md (1, line 75), help.md (2),
  `.github/ISSUE_TEMPLATE/idea.md` ("hook pattern", ambiguous).

**"Hooks" that must NOT be renamed** (they mean native Claude Code hooks):
- `docs/artifact-preview.md` — the collision-dense file: a shell script placed at
  `.vine/hooks/artifact-preview.sh` (VINE path → renames) registered via `~/.claude/hooks/`
  and a settings.json `"hooks"` key (native → stays). Both on the same line in places;
  surgical edits, no blanket find-replace.
- ROADMAP.md lines 13, 32, 35 ("native tooling (hooks, …)", "native hook enforcement",
  "Builds on native hooks (#59)").
- CHANGELOG.md line 46 ("glow and Claude Code hooks").

**#59 surface — current enforcement state.** No `.claude/settings.json` exists (only
`settings.local.json` with a single `Skill(trellis)` permission). No `.vine/scripts/`. Zero
mentions of PreToolUse/PostToolUse/plan mode/ExitPlanMode anywhere in commands or README.
Dishonest-prose inventory (file:line, verified by audit agent):

1. verify.md 58–61 — "**VINE requires approve-edits mode**" (can't check or switch modes)
2. navigate.md 39–42 — same "requires" claim
3. help.md 57 — "Use approve-edits mode" as a tip framed as requirement
4. README.md 105–106 — "edits auto-accept for the current slice and revert at the boundary"
   (worst claim in the repo; model can toggle neither)
5. navigate.md 126–130 — free climb gear: "Auto-accept edits for this slice… revert to
   approve-edits mode at the boundary"
6. navigate.md 121 — free climb option description implies an enforced boundary review
7. navigate.md 250–252 — "engineer still reviews every code change via approve-edits before
   the commit happens" (not enforced; self-contradicting parenthetical)
8. navigate.md 210–211 — "you can't commit without updating the journal" (nothing blocks it)
9. navigate.md 196–203 — per-slice vine-verification delegation is honor-system (the
   candidate for a PostToolUse lint hook)

**pair.md 45–51 is the honest template to copy**: "recommended", explicit soft ask, "Don't
block on this." Memory note applies: behavioral modes need observable mechanical
differences, not just tonal changes — #59's settings.json hooks are exactly that.

**#60 surface — current duplication.** This repo's CLAUDE.md vs `.vine/hooks/shared.md`:
- Near-verbatim duplicates: Repository Structure (CLAUDE.md "Repository Structure" vs
  shared.md lines 30–37), authoring conventions (CLAUDE.md "Command Authoring Conventions"
  vs shared.md "Writing Style"), command inventory (both list all 11 + contributor tools).
- Already correctly single-homed in shared.md: Collaboration Stance, Engineer Profile
  Protocol, Team Context, CI/CD/publish workflow, Command Addition Checklist.
- Tension to resolve in inquire: `vine:optimize` writes its workflow-map ("Skill Workflows")
  to CLAUDE.md, but #60's rule says the VINE command inventory belongs in overlays. Decide
  which way the workflow map goes.
- The boundary rule must name `.vine/knowledge/<domain>.md` (#51, cycle 3) as a forward
  reference only — pointer line convention defined now, implemented later.

**#61 surface — slice-progress machinery today.** All progress is LLM inference over
markdown:
- NAVIGATION.md slice entries (STATE.md lines 109–131): required fields Commit, Validation,
  Acceptance criteria, Learnings. Slices identified by `### Slice N:` headings — no index.
- Phase-group detection (navigate.md 70–71): "Identify which group is next based on
  NAVIGATION.md progress" — pure inference, no structured current-group field.
- resume (read-only: Read/Glob/Grep/AskUserQuestion only) cross-references NAVIGATION.md
  entries against SPEC.md's slice list; renders a markdown pseudo-task-list (lines 150–152).
- pause detects the active slice via `Status: In Progress` in slice headings.
- Trellis's allowed-tools check is **consensus-based** (union of all frontmatter entries), so
  adding TaskCreate/TaskUpdate/TaskList to navigate/resume passes validation automatically.

**#62 surface — writes that collide with plan mode's edit block.**
- verify writes CONTEXT.md (lines 196–248), PROJECT-MAP.md (270–289), PROFILE.md (46–52).
  Prose says "Don't write code… read-only exploration" while frontmatter includes Write.
- inquire writes SPEC.md (line 267), PROJECT-MAP.md inquire row (289), Milestones table
  (200–218), SPEC.md phase markers (212–219). Its "engineer has signed off" (line 287) has
  **no AskUserQuestion gate** before the writes — the sign-off is prose judgment. Native
  ExitPlanMode maps cleanly onto it as the single approval moment.
- Neither command handles "write was blocked" — in plan mode today they'd fail at the
  artifact step after all exploration work succeeded.

### Current State

- main is clean except untracked ROADMAP.md (rides in this cycle's first PR) and untracked
  `.vine/projects/commands/tool-graph/` (superseded — see tribal knowledge).
- v0.3.0 shipped (vine:optimize, reusable agents, skill-matching improvements); publish
  workflow is manual-dispatch npm with provenance.
- 11 commands, all trellis-compliant today; trellis Check 4 skips init/help, Check 6
  enforces hooks-before-profile ordering.
- Two undocumented contracts discovered (writer/reader pairs not in STATE.md):
  1. `Status: In Progress / Complete` heading suffix — written by navigate (line 215), read
     by pause (line 66). Not in STATE.md's NAVIGATION template.
  2. `### Remaining Work` is marked `<!-- optional -->` in STATE.md but resume's no-PAUSE.md
     path depends on it, and #61 makes it the task-rebuild source. Likely promote or
     document the dependency.

### Edge Cases & Tribal Knowledge

- **tool-graph is superseded.** `.vine/projects/commands/tool-graph/` (navigate 🚧,
  2026-04-06) evolved into vine:optimize and shipped. Leave untracked; archival is #56
  (cycle 3). Out of scope here.
- **The symlink is the dedup mechanism** for command files; don't let anything (scripts,
  installers) replace it with copies.
- **gitignore negation ordering matters**: `.vine/*` then `!.vine/context/` — the rename
  commit must move the negation atomically with the `git mv` or tracked overlays vanish
  from the index.
- **CHANGELOG history stays as-is**: historical entries referencing `.vine/hooks/` describe
  past releases truthfully; only a new 0.4.0 entry documents the rename + migration. (Same
  policy as any changelog — don't rewrite history.)
- **One-minor-version fallback** (#58): commands check `.vine/context/` first, fall back to
  `.vine/hooks/` with a one-line nudge through 0.4.x; fallback removed in 0.5. The nudge
  must not nag — once per session at most.
- **Declining migration changes nothing** is the test for every init upgrade offer in this
  cycle (#58 directory move, #59 hook scaffold, #60 dedup). Each is independently
  declinable.
- **#59's PostToolUse lint hook has a dependency wrinkle**: the issue says it consumes #54's
  Validation block, but #54 is cycle 4. Interim source for the lint command:
  `.vine/context/navigate.md` custom validation commands (the existing override mechanism,
  navigate.md lines 201, 334), with the #54 block as the future canonical home.
- **Native hooks read stdin JSON and exit-code semantics** (exit 2 blocks the tool call for
  PreToolUse). Scripts in `.vine/scripts/` must be POSIX-sh-safe and degrade to exit 0
  no-ops when no VINE session/feature is active (detected via NAVIGATION.md state per #59).
- **Plan mode availability is per-harness**: all #61/#62 behavior phrased as "when
  available/active" — VINE stays usable on other harnesses (agent-agnostic goal, closed #6).
- **Maintainer is solo, public-first**: PRs self-reviewed; milestone status lives in GitHub,
  not ROADMAP.md.

### Tech Debt in Affected Areas

| Debt | Severity | Relevance |
|------|----------|-----------|
| CLAUDE.md ↔ shared.md near-verbatim duplication (structure, conventions, inventory) | Medium | Resolved by #60 this cycle |
| `Status: In Progress` contract missing from STATE.md template | Medium | Must be documented for #61's task rebuild; cheap to fix in the #61 PR |
| Remaining Work `<!-- optional -->` vs functional dependency in resume | Low | Document or promote alongside #61 |
| status.md tension: shows "[X of Y] slices" but claims "no deep file scanning" | Low | Worth a wording fix if status gets TaskList awareness; otherwise leave |
| inquire has no AskUserQuestion gate at spec sign-off | Medium | Folded into #62 (ExitPlanMode becomes the gate; AskUserQuestion fallback off-plan-mode) |
| `.github/ISSUE_TEMPLATE/idea.md` "hook pattern" ambiguity | Low | One-line fix in the #58 PR |
| Stale tool-graph artifacts untracked in working tree | Low | Deliberately deferred to #56 (cycle 3) |

### Documentation Gaps

- README documents no permission-mode reality and no enforced-vs-advisory distinction —
  #59 acceptance requires a "which guarantees are enforced vs advisory" section.
- README/commands have zero plan-mode interaction docs — #62 requires plan-mode-on/off
  behavior documented in verify, inquire, and README.
- STATE.md lacks: the Status-suffix contract, the live-view vs durable-journal split (#61),
  and the CLAUDE.md/shared.md/knowledge boundary rule (#60).
- `docs/artifact-preview.md` will need its VINE paths updated and is the natural place to
  point at the new "hooks means native hooks" vocabulary.
- bin/cli.js console message says "set up project hooks" — update to new vocabulary.

### Open Questions

1. **PR slicing.** #58 must land first (with ROADMAP.md riding along). Natural grouping for
   the rest: #59 standalone (scripts + prose pass), #60 standalone (boundary + dedup),
   #61+#62 possibly together (both are "consume native session machinery" changes to
   navigate/resume and verify/inquire respectively)? Inquire decides the Milestones table.
2. **Fallback nudge mechanics** (#58): where does the one-line nudge live — in every
   command's Load Context Overlays section, or only in init/status? How is "one minor
   version" stated so 0.5 cleanup is findable (CHANGELOG note + tracking issue?).
3. **Workflow map destination** (#60): vine:optimize currently writes the Skill Workflows
   map to CLAUDE.md; the boundary rule says command inventory belongs in overlays. Move the
   map to shared.md, or carve an exception (workflow map = repo fact)?
4. **#59 scaffold contents**: exactly which hooks ship in the init offer — journal-before-
   commit (PreToolUse Bash), post-edit lint (PostToolUse Edit/Write), contributor trellis
   gate for this repo — and what the "active navigate session" detection looks like
   concretely (NAVIGATION.md mtime vs commit timestamps? a sentinel file?).
5. **Tracked vs local settings**: do scaffolded hooks go in `.claude/settings.json`
   (team-shared, tracked) or `settings.local.json` (personal)? This repo's contributor
   trellis gate has the same question.
6. **#61 task granularity**: one task per remaining slice in the current phase group —
   what happens to conditional slices (create as task with "conditional" prefix, or prompt
   first)? Resume needs the same answer.
7. **resume's read-only identity** (#61): adding task creation contradicts "Resume is
   read-only — it shows status and recommends, nothing more" (resume.md 174). Reword as
   "writes no files" or move task rebuild elsewhere?
8. **#62 CONTEXT.md write-at-the-gate**: present full CONTEXT.md content for approval inside
   plan mode then write after exit, or write-as-the-exit-artifact? Affects verify's
   completion flow shape.
9. **Trellis legacy detection** (#58): should trellis fail or warn on `.vine/hooks/`
   references post-rename? (Acceptance says "flags legacy references" — warn seems right,
   but the fallback prose itself legitimately mentions the old path for one version.)
