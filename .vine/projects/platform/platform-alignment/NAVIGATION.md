# Navigation Log: Platform Alignment (v0.4.0 cycle 1)
## Date: 2026-06-10
## Branch: feature/platform-alignment (recreated from main after PR #67 squash-merge)
## Phase group this session: Phase 4 — Native Tasks (Slices 14–16), #61, PR 4
## Prior sessions: Phase 1 (Slices 1–5) → PR #63; Phase 2 (Slices 6–10) → PR #65; Phase 3 (Slices 11–13) → PR #67

### Slice 1: Directory move + tracked overlays — Complete
- **Started**: 2026-06-10
- **Commit**: 7edfc68
- **Approach taken**: `git mv .vine/hooks .vine/context` with the `.gitignore` negation flip (`!.vine/hooks/` → `!.vine/context/`) in the same commit, per the silent-untracking trap from verify. Retitled all 5 overlay files to "Context Overlay" vocabulary (`# VINE <Phase> Context Overlay — VINE Framework`, shared = "Shared Context Overlay") and fixed self-referential paths: shared.md's init description, "This file" entry, and Command Addition Checklist paths; navigate overlay's "(after hooks)" ordering note; evolve overlay's "Hook improvements" → "Overlay improvements".
- **Deviations from spec**: None
- **Validation**: pass — `git ls-files .vine/` lists all 5 overlays at the new path (renames staged, R status); `grep -rn '.vine/hooks' .vine/context/` returns nothing; `git check-ignore` confirms the new path is not ignored; markdownlint not yet configured (overlay hook lists it as "once configured"), so validation was the AC greps + link check.
- **Decisions made during implementation**:
  - Overlay title pattern `# VINE <Phase> Context Overlay — VINE Framework`: rationale — matches the new "Load Context Overlays" section vocabulary commands adopt in Slice 2 (decided by: claude, free-climb mode)
  - Native tasks created for Phase 1's five slices at session start, dogfooding Slice 15's design ahead of its implementation (decided by: claude)
- **Acceptance criteria**:
  - [x] `git ls-files .vine/` still lists all 5 overlays post-commit
  - [x] No file content references `.vine/hooks/` within the overlays
- **Engineer feedback incorporated**: None — free-climb mode, approach approved at preview
- **Learnings**:
  - Claude → Engineer: after `git mv`, the harness's read-before-edit guard treats the new path as unread — re-read files at their post-move path before editing. Worth remembering for any future slice that moves then edits.

### Slice 2: Command rename + fallback pass — Complete
- **Started**: 2026-06-10
- **Commit**: 9c0a94f
- **Approach taken**: One pass over all 11 command files. Renamed `## Load Project Hooks` → `## Load Context Overlays`, updated every `.vine/hooks/` path to `.vine/context/`, and swapped hook vocabulary for overlay vocabulary throughout (frontmatter descriptions for init and evolve, evolve's "Hook Update Suggestions" → "Context Overlay Update Suggestions" flow, optimize's audit tables, init's generation/upgrade steps and output block, help's 2 refs). Added an identical fallback paragraph to all 9 loading commands: check `.vine/context/` first, fall back to legacy `.vine/hooks/` with the once-per-session nudge "Heads up: this project uses the legacy `.vine/hooks/` directory — run `/vine:init` to migrate to `.vine/context/`." Init's Step 7 upgrade trigger renamed to `.vine/context/` (Slice 3 adds the legacy-migration branch). The out-of-band retro-persistence edits (verify/inquire/navigate Phase Completion + 4 more files) ride in this commit as planned.
- **Deviations from spec**: None from SPEC. One process deviation: `/trellis` not run before this commit (memory note) because trellis still validates the old heading until Slice 4 — running it would fail on every file by design. Flagged in the slice preview; structural equivalents (frontmatter fields, overlays-before-profile ordering) checked inline and pass. Trellis goes green at Slice 4.
- **Validation**: pass — zero `.vine/hooks/` refs outside the 9 fallback blocks; zero `Load Project Hooks` headings; nudge wording byte-identical in all 9 loading commands (init/help correctly at 0); frontmatter fields present in all 11; overlay-before-profile ordering holds in the 9 applicable commands. Live skill-list refresh mid-session confirmed the symlink topology (new descriptions appeared immediately).
- **Decisions made during implementation**:
  - Nudge phrased as quoted engineer-facing line inside an instruction sentence, placed between the precedence paragraph and the "neither exists" line in every Load section (decided by: claude, free-climb mode)
  - Status.md keeps its shorter 3-item Load section shape (no precedence sentence, as before) — fallback paragraph added without restructuring (decided by: claude)
- **Acceptance criteria**:
  - [x] Zero `.vine/hooks/` references in commands except the fallback lines
  - [x] Nudge wording identical across commands
  - [x] help.md's 2 refs updated despite having no Load section
- **Engineer feedback incorporated**: None — free-climb mode; trellis-red window flagged at preview and accepted
- **Learnings**:
  - Claude → Engineer: editing command files while one of them is the running command is safe — the session works from its loaded copy, and the harness's skill list refreshes live, which doubles as a smoke test that the symlink dedup holds.

### Slice 3: Init migration offer — Complete
- **Started**: 2026-06-10
- **Commit**: 1300fc9
- **Approach taken**: Extended init.md Step 7 with two subsections: "Legacy Directory Migration" (new) ahead of "Upgrade Mode" (the pre-existing numbered flow, now under its own heading). The offer fires only when `.vine/hooks/` exists and `.vine/context/` doesn't, via AskUserQuestion (2 options, migrate recommended). Accept path: `git mv` if tracked / plain `mv` otherwise, the gitignore-negation caveat (`!.vine/hooks/` → `!.vine/context/` in the same commit, "negation lags the rename → tracked overlays silently fall out of the index"), then upgrade mode against the new path. Decline path: explicit no-op — nothing on disk changes, fallback + nudge carry the load, offer repeats on next init, upgrade mode runs against the legacy files. Both-dirs-exist case: `.vine/context/` is canonical; flag the leftover dir instead of guessing.
- **Deviations from spec**: None from the slice itself. Spec addenda made to downstream ACs (see decisions).
- **Validation**: pass — all 8 `.vine/hooks` refs in init.md are inside the Step 7 migration section (init has no Load section, so no fallback-line overlap); frontmatter valid; heading flow clean. Same process deviation as Slice 2: `/trellis` not run pre-commit because it still validates the old heading until Slice 4; structural equivalents checked inline.
- **Decisions made during implementation**:
  - Declined-offer behavior: upgrade mode still runs, against the legacy `.vine/hooks/` files — declining the move shouldn't cost legacy installs their overlay upgrades (decided by: claude, free-climb mode)
  - Discovered item → SPEC addenda: this slice adds legitimate `.vine/hooks/` refs to init.md beyond the fallback lines. Slice 4's trellis allowlist and Slice 5's repo-grep AC both assumed fallback-lines-only; both ACs annotated in SPEC.md to include init's Step 7 migration section (decided by: claude)
- **Acceptance criteria**:
  - [x] Offer appears only in the legacy-dir condition (plus explicit "don't show this offer in any other condition" guard)
  - [x] Decline path explicitly documented as a no-op
  - [x] Accept path includes the user-repo .gitignore caveat
- **Engineer feedback incorporated**: None — free-climb mode, chosen by the engineer at session resume
- **Learnings**:
  - Claude → Engineer: a slice that documents a legacy path creates new legitimate references to it — any "zero refs except X" acceptance criterion downstream needs re-checking whenever an intermediate slice legitimately names the old path.

### Session decisions (between slices) — local-projects convention, 2026-06-10
Folded in from a side-chat decision. Context: the work pilot keeps non-shared projects under `.vine/projects/_local/<domain>/<feature>` — a three-level folk convention that current two-level discovery globbing misses.
- **Decision**: the cleaner long-term design is a gitignored sibling root `.vine.local/` mirroring `.vine/`'s structure (precedent: settings.json vs settings.local.json, .env vs .env.local) — shared tree stays spec-shaped, gitignore is one root-level line with no negation traps, discovery stays two-level under each root. (decided by: engineer, side chat)
- **SPEC.md updated — Backlog Updates**: new idea issue for the `.vine.local/` sibling root. Commands resolve features against `.vine/` then `.vine.local/`. Open design questions captured: root-resolution order, both-roots collision, which root verify writes to, whether local context overlays exist (v1: projects only). Only relevant for teams that track `.vine/`; the pilots' three-level `_local` convention defeating two-level discovery is noted as the motivating bug.
- **SPEC.md updated — Slice 7**: design constraint added — hook scripts treat the feature path in `.vine/ACTIVE` as an opaque repo-relative string (no domain/slug parsing, no root assumption), so future `.vine.local/` paths work unchanged. Mirrored into the slice's acceptance criteria.
- **SPEC.md updated — Slice 11 (Phase 3)**: the STATE.md boundary-rule paragraph also names the sharing boundary for projects — tracked `.vine/projects/` = team-shared; personal work lives outside the shared tree — with the `.vine.local` backlog issue as the forward reference (same pattern as the #51 `.vine/knowledge` pointer).

### Slice 4: Trellis update — Complete
- **Started**: 2026-06-10
- **Commit**: 6e955cd
- **Approach taken**: Check 4 renamed (title + heading requirement `## Load Context Overlays` + substring `.vine/context/<phase>.md`); Check 6 ordering re-anchored on the new heading; Step 4 table column "Hooks" → "Overlays". New Check 9 "Legacy Reference Detection (warning-only)": any `.vine/hooks` ref warns, never fails, no table column; warnings print in their own block after the summary (reusing the Step 5a unmarked-heading warning pattern) with a "hardens to failure at 0.5" note. Allowlist is two-mode by design: the fallback paragraph is TEXT-ANCHORED (matched by its canonical opening sentence, not section position — a Slice 2 straggler in the same Load section would still warn), init's Step 7 "Legacy Directory Migration" section is SECTION-SCOPED (safe because init has no Load section; verified all 8 refs sit between that heading and `### Upgrade Mode`).
- **Deviations from spec**: None.
- **Validation**: pass — /trellis run in-session: 11/11 commands pass all checks, zero legacy warnings (all 9 fallback paragraphs + init's 8 migration refs allowlisted). Negative test verified by inspection: a stray ref matches neither anchor → warns with file+line. Artifact validation surfaced one PRE-EXISTING failure unrelated to this slice (see discovered items).
- **Decisions made during implementation**:
  - Fallback exemption text-anchored, init exemption section-scoped: section-scoping the fallback would mask stragglers in the very section where Slice 2's misses would live (decided by: claude, walk-through mode)
  - Check 9 has no results-table column; warnings get a separate block mirroring the existing unmarked-heading warning pattern (decided by: claude)
  - Check titles renamed too (not just logic) so failure messages speak the new vocabulary (decided by: claude)
- **Acceptance criteria**:
  - [x] Trellis passes on the renamed tree (command validation 11/11)
  - [x] Injecting a stray `.vine/hooks/` ref produces a warning naming file+line (verified by inspection of anchor logic)
  - [x] Fallback line produces no warning; init's Step 7 migration section allowlisted (zero warnings on current tree)
- **Engineer feedback incorporated**: Walk-through gearing chosen per last session's handoff. Mid-slice design discussion (engineer-raised) produced the shared.md identity decision — see session decisions below.
- **Discovered items**:
  - SPEC template drift: STATE.md requires `### Work Slices`, but phase-grouped specs (inquire 6b layout) use `## Phase N:` + `### Slice N:` headings — this feature's own SPEC.md fails trellis Check A. Pre-existing, not caused by this slice. Natural home: Slice 14 (STATE.md contracts).
  - init.md's generated shared.md template (line ~80) scaffolds an "Available Tools & Agents" inventory section into user repos — Phase 3 must update the template per the shared.md identity decision, not just this repo's shared.md.
- **Learnings**:
  - Engineer → Claude: the native skill list already carries the command inventory — a file-based inventory is shadowing, the same anti-pattern this cycle exists to remove. Led to the shared.md identity decision.
  - Claude → Engineer: when legitimate legacy refs and potential stragglers share a section, anchor the allowlist to the exempted TEXT, not the section — section-scoped exemptions are only safe where stragglers can't occur.

### Slice 5: Docs periphery — Complete
- **Started**: 2026-06-10
- **Commit**: 4694582
- **Approach taken**: Rename pass in three tiers. Mechanical: CLAUDE.md (structure line, convention bullets now naming the fallback, shared-patterns path, Skill Workflows vocabulary), CONTRIBUTING.md (2 refs incl. line 15's "hook patterns" mirroring idea.md), agents/vine-verification.md, STATE.md (EVOLUTION template field "Hook Update Suggestions" → "Context Overlay Update Suggestions" + line ~296 "hooks" → "overlays"), bin/cli.js line 77, idea.md about-line. README: "Project Hooks" section → "Context Overlays" (heading, paths, tree diagram `hooks/` → `context/`, "Per-phase overlays", "How overlays load") plus a fallback-window note; gitignore tip, upgrade note, init description. Surgical: artifact-preview.md lines 17 + 70 only — `~/.claude/hooks/`, settings `"hooks"` key, PostToolUse all untouched. Additive: CHANGELOG entry under [Unreleased] (3 bullets: rename+fallback, init migration offer, trellis legacy detection) with the 0.5 tracking-issue pointer; history entries untouched. ROADMAP.md staged into this commit, unmodified (native-hooks lines preserved).
- **Deviations from spec**: artifact-preview.md's project-level script path renamed to `.vine/scripts/artifact-preview.sh` instead of the literal `.vine/context/` — Phase 2's Slice 7 already establishes `.vine/scripts/` as the shell-script home, so this avoids touching the doc twice and keeps scripts out of the markdown-overlay directory (decided by: engineer). SPEC Slice 5 AC annotated: this slice's CHANGELOG entry + README/CLAUDE.md fallback-window notes are new legitimate legacy refs, all in 0.5-cleanup scope.
- **Validation**: pass — repo grep: zero `.vine/hooks` refs outside the allowlist (command fallback lines, init migration section, trellis Check 9 text, CHANGELOG history, the three new documented-fallback refs, historical `.vine/projects/` artifacts); zero live "project hooks" vocabulary outside history; artifact-preview native refs intact; ROADMAP native-hooks lines intact; `node --check bin/cli.js` passes.
- **Decisions made during implementation**:
  - CHANGELOG entry placed under existing `[Unreleased]` heading per Keep a Changelog convention — becomes 0.4.0 at release when the version bumps (decided by: claude, free-climb mode)
  - README's Context Overlays section gains a 2-line pre-0.4 fallback note — users on legacy installs need the migration story in the section they'll land on (decided by: claude)
- **Acceptance criteria**:
  - [x] Repo-wide `.vine/hooks` grep hits only allowlisted locations (per annotated AC)
  - [x] artifact-preview.md's native-hook references intact (surgical edits only)
  - [x] CHANGELOG documents rename + migration; history entries untouched
  - [x] ROADMAP.md committed in this PR, native-hooks lines unrenamed
- **Engineer feedback incorporated**: Script path decision (`.vine/scripts/`) made by the engineer at the AskUserQuestion fork.
- **Learnings**:
  - Claude → Engineer: a rename pass that documents its own fallback necessarily creates new legitimate legacy refs (CHANGELOG, README, CLAUDE.md) — the "zero refs except X" AC needed its third annotation this cycle. Slice 3's learning generalizes: every slice that documents the old path extends the allowlist.

### Session decisions (between slices) — shared.md identity, 2026-06-10
Raised by the engineer during Slice 4: shared.md's "Available Tools & Agents" inventory
duplicates what the harness already loads natively (skill descriptions and agent lists are
in every session's context — confirmed live in this session, which sees all 11 commands +
contributor tools + both agents without shared.md loaded). An inventory in shared.md shadows
the native skill list the same way "hooks" shadowed native hooks.
- **Decision**: shared.md's identity is the cross-phase layer — cross-phase protocols
  (Collaboration Stance, Profile Protocol), project-development context spanning phases
  (team structure, CI/CD, Command Addition Checklist), and inter-phase routing (workflow
  map + state-based suggestions). Nothing phase-specific (overlays' job), nothing the
  harness already surfaces (the native list IS the inventory). Four surfaces keyed to
  reader scope: CLAUDE.md / native skill list / shared.md / per-phase overlays. (decided
  by: engineer)
- **SPEC.md updated — Slice 11**: goal + AC addenda — the boundary rule names the
  native-surface category ("inventory lives nowhere; phase routing lives in overlays");
  this repo's command-inventory duplicate resolves by deletion; shared.md's tools section
  reduces to repo-specific notes.
- **SPEC.md updated — Slice 12**: goal + AC addenda — the workflow map is chains +
  state-based suggestions only, no command enumeration; optimize's audit checks phase
  overlays point at their phase-relevant tools instead of checking an inventory; an
  inventory in shared.md becomes an audit finding.
- Open judgment deferred to Phase 3's session: where Team Context / CI-CD ultimately land
  (cost framing keeps them in shared.md for now; #51's `.vine/knowledge/` is the future
  relief valve for "needed by some sessions, not all").

### Session decisions (between slices) — PAUSE.md consumed-once, 2026-06-10
Raised by the engineer after Phase 1 shipped: this morning's resume displayed the pause
state but nothing deleted it — PAUSE.md's lifecycle only had re-pause (overwrite) and
evolve-resolve (delete), so a consumed pause lingers, keeps firing the "PAUSE.md exists →
suggest resume" state suggestion, and re-presents stale notes on the next resume.
- **Decision**: PAUSE.md is consumed-once. Resume or any main phase command that picks the
  work back up deletes the feature's PAUSE.md once the pause state is consumed — phase
  commands at session start (the same moment Slice 6's sentinel is written), resume after
  displaying the notes. The stale pre-Slice-4 PAUSE.md was deleted immediately. (decided
  by: engineer)
- **SPEC.md updated — Slice 6**: goal + AC addenda — consumed-once rule joins the sentinel
  lifecycle; STATE.md's PAUSE section lists every deletion trigger.
- **SPEC.md updated — Slice 16**: resume deletes PAUSE.md after display; needs a tool grant
  (currently no Write/Bash) and the "writes no files" identity rewords to "creates no
  artifacts." Mechanics resolved in that slice.
- Design tension noted for Slice 16: deleting consumed ephemeral session state vs resume's
  write-free identity — the reword draws the line at artifacts, not file operations.

### Slice 6: Sentinel lifecycle (.vine/ACTIVE) + PAUSE.md consumed-once — Complete
- **Started**: 2026-06-10
- **Commit**: 6a4b56c
- **Approach taken**: navigate.md gains a "Mark the session active" block at the end of step 1 (writes `.vine/ACTIVE` — feature path / phase / started, with the not-a-mini-PAUSE.md framing and opaque-path note) plus a "Consume any pause state" block (surface PAUSE.md notes in the starting-point summary, then delete). Sentinel cleared on every navigate exit path: step 7 pause-between-slices (with a note that vine:pause also clears it, covering the engineer who closes without running it), step 8 phase-group boundary (delete on session end, update the `phase:` line if continuing immediately), and Phase Completion. pause.md gains Bash in allowed-tools and a "Clear the Active-Session Sentinel" section. evolve.md consumes PAUSE.md + deletes the sentinel at session start (after artifact reads); its `.resolved` deletion stays as the documented backstop. STATE.md: PAUSE.md section rewritten to consumed-once (intro, lifecycle enumerating all four deletion triggers, new design constraint) and a new `### .vine/ACTIVE` section (format block, lifecycle, `rm .vine/ACTIVE` staleness escape hatch, design constraints: minimal / local-only / optional / opaque feature path). Dogfooded immediately — this session wrote `.vine/ACTIVE` after the slice landed.
- **Deviations from spec**: One file beyond the spec's list — CLAUDE.md line 42 still described the old PAUSE lifecycle ("deleted when evolve writes `.resolved`"); updated to consumed-once + sentinel pointer since no later slice owns that doc. Trellis's union-derived tool consensus meant pause.md's Bash grant needed no trellis change.
- **Validation**: pass — vine-verification agent ran trellis's checks (11/11 commands, zero legacy warnings), frontmatter valid in all three changed commands (pause.md's Bash entry well-formed), document flow clean, all 5 ACs verified with file:line evidence. `git check-ignore .vine/ACTIVE` confirms gitignore coverage in this repo (`.vine/*`, no negation).
- **Decisions made during implementation**:
  - Sentinel write placed at the end of navigate step 1 (not a new numbered step): avoids renumbering steps 2–8 and the cross-references that point at them (decided by: claude, free-climb mode)
  - Phase-group boundary clears OR updates the sentinel: deleting unconditionally would leave a continuing same-session group unmarked; updating `phase:` keeps the sentinel truthful (decided by: claude)
  - pause.md gains Bash (smallest grant that can delete a file); trellis consensus check passes automatically since Bash is already in the union (decided by: claude)
  - inquire.md NOT touched: it can also find a PAUSE.md (post-verify pause) but isn't in this slice's file list and needs the same tool-grant decision the engineer deferred to Slice 16 for resume — logged as a discovered item instead (decided by: claude)
- **Acceptance criteria**:
  - [x] Every navigate exit path clears the sentinel (step 7 pause, step 8 group boundary, Phase Completion; plus vine:pause and evolve session start)
  - [x] STATE.md documents format + lifecycle + staleness escape hatch (`rm .vine/ACTIVE` named in hook block messages)
  - [x] Phase commands delete a found PAUSE.md at session start (navigate at sentinel-write moment, evolve after artifact reads — both surface notes first)
  - [x] STATE.md's PAUSE lifecycle lists every deletion trigger (resume-after-display, navigate start, evolve start, evolve-.resolved backstop)
- **Engineer feedback incorporated**: None — free-climb mode; evolve's clearing point (session start, not `.resolved`) flagged at preview with no redirect.
- **Discovered items**:
  - inquire.md doesn't consume PAUSE.md (the post-verify pause leak path) and lacks Bash to delete one. Candidate: fold into Slice 16 alongside resume's tool grant, where the same "creates no artifacts" wording question is already being resolved.
  - STATE.md's resume deletion trigger carries a "(deletion mechanics land with resume's task-awareness update)" parenthetical — remove it in Slice 16.
- **Learnings**:
  - Claude → Engineer: trellis deriving its valid-tool set from the union of all commands' allowed-tools means tool grants self-ratify — adding Bash to pause needed no trellis edit, but it also means a typo'd tool name in any one command would legitimize itself. Worth a thought when Slice 8 touches trellis territory.

### Slice 7: POSIX hook scripts — Complete
- **Started**: 2026-06-10
- **Commit**: 2b9e616
- **Approach taken**: Two scripts in `.vine/scripts/` (new dir, gitignore negation `!.vine/scripts/` added in the same commit — Slice 1's silent-untracking trap applies). `journal-check.sh` (PreToolUse Bash): sentinel check → stdin read → commit detection (jq parses `tool_input.command` when present; otherwise deliberate substring over-match `*git*commit*` — false block costs one explained retry, false allow voids the guarantee) → opaque feature path via one `sed` line → staleness as journal mtime vs `git log -1 --format=%ct` (BSD `stat -f %m` first, GNU `stat -c %Y` fallback) → exit 2 message naming the journal and `rm .vine/ACTIVE`. `post-edit-lint.sh` (PostToolUse Edit|Write): sentinel check → reads opt-in marker line `hook-validation: <command>` from the navigate overlay (legacy `.vine/hooks/navigate.md` honored through 0.4.x) → runs it from repo root → exit 2 with output on failure. Every ambiguous/missing-tooling path in both scripts fails open. STATE.md gains a `.vine/scripts/` section (script table, fail-open posture, marker convention with #54 as its successor).
- **Deviations from spec**: `.gitignore` touched beyond the spec's file list (required to track the scripts — negation rides in the same commit). Commit detection added to journal-check (the spec's goal text reads as guarding every Bash call, but the spec's own decision list names the hook "journal-before-commit"; an unfiltered guard would block `ls` on a stale journal).
- **Validation**: pass — `sh -n` and `dash -n` clean on both; functional matrix exercised in temp repos: journal-check 7/7 (no-sentinel silent no-op, non-commit allowed, no-journal allowed, stale blocked exit 2, same-second tie allowed, fresh allowed, no-jq substring path blocks), post-edit-lint 7/7 (no-sentinel/no-overlay/no-marker all exit 0, prose backticks never executed, passing cmd silent, failing cmd exit 2 with output, legacy overlay honored). Bashism grep clean (two false positives were POSIX `[[:space:]]` classes); no domain/slug parsing outside comments; `git check-ignore` confirms scripts trackable. Trellis not run — no command files changed this slice.
- **Decisions made during implementation**:
  - Staleness comparison is `-ge`, not `-gt`: second-granularity mtimes make same-second ties ambiguous, and ties fail open — caught live when the fresh-journal test was falsely blocked (decided by: claude, confirmed by test)
  - Commit detection over-matches by design (substring `*git*commit*` without jq): prefer rare false blocks with a clear escape hatch over silent false allows (decided by: claude, narrated)
  - Lint command source is an opt-in `hook-validation:` marker line, not prose-backtick scraping — fails safe, one-line POSIX parse, never runs "(once configured)" commands (decided by: engineer)
  - post-edit-lint honors the legacy `.vine/hooks/navigate.md` overlay location: a repo can accept the hook scaffold while declining the directory migration (decided by: claude)
- **Acceptance criteria**:
  - [x] Scripts pass `sh -n` (and `dash -n`)
  - [x] No-sentinel invocation exits 0 with no output
  - [x] journal-check exits 2 only under sentinel + stale journal (and only for commit commands)
  - [x] Lint script exits 0 when no validation command is configured
  - [x] No bashisms
  - [x] No domain/slug parsing of the sentinel's feature path in either script
- **Engineer feedback incorporated**: Marker-line decision made at the AskUserQuestion fork; journal-check approved at mid-slice review with no changes.
- **Discovered items**:
  - npm distribution: `.vine/scripts/` must ship in the `create-vine` package for init's scaffold offer to have a copy source — check `package.json` files/include during Slice 8.
- **Learnings**:
  - Engineer → Claude: choosing walk-through for the high-complexity slice paid off at the design fork — the marker-line convention exists because scraping prose was surfaced as a real risk rather than silently implemented.
  - Claude → Engineer: with second-granularity mtimes, strict `>` comparisons against commit timestamps fail on same-second writes — anywhere a guard compares mtimes, ties need an explicit fail-open/fail-closed decision.

### Slice 8: Init scaffold offer + this repo's trellis gate — Complete
- **Started**: 2026-06-10
- **Commit**: 02f278a
- **Approach taken**: init.md gains `### Native Hook Scaffold` (end of Step 7): fires whenever settings.json doesn't wire the hooks (fresh or upgrade); missing-scripts case offers `npx create-vine`; AskUserQuestion multiSelect with each hook independently declinable; merge instructions cover file-absent and file-exists without clobbering; decline is a documented no-op; lint hook's `hook-validation:` marker documented including the legacy-overlay location (worded without the literal legacy path — see decisions). Trellis gains Write + `## Step 8: Write the Pass Stamp`: green command validation writes `.vine/.trellis-ok` (`status: pass`), red overwrites with `status: fail` (status line instead of deletion because trellis has no Bash); warnings and artifact failures don't block the stamp. `trellis-gate.sh` (this-repo-only): commit detection as journal-check, gates on `git status --porcelain -- commands/vine` (catches compound add+commit), requires fresh `status: pass` stamp (`find -newer`), fails CLOSED on stale/missing stamp — that's its job. This repo's `.claude/settings.json` (new, tracked) wires all three hooks; arms next session. Distribution: cli.js copies SCAFFOLD_SCRIPTS allowlist (journal-check, post-edit-lint) on project installs only, chmod 755, skips on --global; package.json `files` lists the two scripts individually. shared.md CI/CD documents the gate.
- **Deviations from spec**: bin/cli.js + package.json touched beyond the spec list (anticipated by Slice 7's discovered item — init's offer needs a copy source in user repos). Stamp-file design (`.vine/.trellis-ok` + trellis.md changes) resolves the spec's unstated "unless trellis passed" signal — gate-signal design chosen by the engineer at the slice fork.
- **Validation**: pass — trellis 11/11 via verification agent (three runs: full suite, then init.md re-checks after each finding fix), final run zero Check 9 warnings; stamp written by the agent's green run per the Step 8 contract; `node --check bin/cli.js` clean; `npm pack --dry-run` ships exactly the two scaffold scripts (trellis-gate excluded — first dry-run caught it shipping, fixed by listing files individually); settings.json validated with JSON.parse; trellis-gate.sh `sh -n`/`dash -n` clean, functional matrix 7/7 (no-command-changes allowed, no-stamp blocked, red-stamp blocked, fresh-green allowed, edit-after-stamp blocked, non-commit allowed).
- **Decisions made during implementation**:
  - Stamp invalidation by status line (`status: fail` overwrite) rather than deletion: trellis has Write but not Bash; mtime-only freshness would let a red run refresh the gate (decided by: claude)
  - Gate checks `git status --porcelain` (any change set) not staged-only: compound `git add && git commit` calls stage after the PreToolUse hook fires (decided by: claude)
  - Artifact failures don't block the pass stamp: artifacts are work-in-progress journals; gating command commits on artifact state would deadlock on the known SPEC template drift until Slice 14 (decided by: claude)
  - package.json `files` lists the two scaffold scripts individually, not the directory: first `npm pack --dry-run` showed trellis-gate.sh shipping in the tarball despite the cli.js allowlist (decided by: claude, caught by dry-run)
  - Marker-reminder reworded to avoid the literal legacy path: the agent confirmed the first wording produced a standing Check 9 warning; rewording beats extending the allowlist a third time (decided by: claude)
  - settings.json write explicitly authorized by the engineer after a scoping question (what reaches user repos): the harness's permission classifier blocked hook-config self-modification until authorization was on record (decided by: engineer)
- **Acceptance criteria**:
  - [x] Scaffold offer merges into existing settings.json without clobbering unrelated keys (both file-exists and file-absent paths documented)
  - [x] Each hook is a separate AskUserQuestion option (multiSelect: true), independently declinable, decline = no-op on disk
  - [x] This repo's gate documented in shared.md CI/CD section
- **Engineer feedback incorporated**: Gate-signal design (green-run stamp file) chosen at the slice fork; settings.json write authorized after the scoping answer (only two inert scripts reach user repos, only on project-level installs, execution only behind init's explicit offer).
- **Discovered items**:
  - The hooks arm next session in this repo: every commit then runs journal-check, and command-file commits require a fresh green stamp — future sessions must run /trellis before command commits or be blocked (the memory note becomes mechanical).
  - Trellis's tool-consensus self-ratification concern from Slice 6's learnings stands unchanged — Write joining trellis's own allowed-tools is invisible to the consensus check because trellis validates commands/vine/ only, not itself.
- **Learnings**:
  - Claude → Engineer: `npm pack --dry-run` is the only honest test of a `files` allowlist — the cli.js copy allowlist looked sufficient until the dry-run showed the contributor-only script riding the tarball anyway. Distribution exclusions need checking at every layer that ships bytes.
  - Engineer → Claude: the scoping question before authorizing settings.json ("where does this require users to install code?") is the right reflex for any change that wires execution into config — the answer (two inert files, execution strictly behind an explicit offer) is now documented in this entry for the PR description.

### Slice 9: Honest prose pass — Complete
- **Started**: 2026-06-10
- **Commit**: 4228f94
- **Approach taken**: All 9 inventory items relocated by text (inquire-time line numbers had drifted ~25 lines after Slice 6) and rewritten on pair.md's template. Claims 1–2 (verify/navigate "VINE requires approve-edits"): "recommended" + quoted soft ask + "Don't block on this" + explicit "the mode toggle is the engineer's action: you can ask, never switch it yourself or assume it happened." Claim 3 (help tip): "recommended … (the toggle is yours)". Claim 4 (README, worst in repo): "Claude can't switch permission modes for you … you switch to auto-accept yourself and back at the slice boundary." Claims 5–6 (free-climb gear + description): every mode action engineer-attributed; boundary line becomes "ask the engineer to switch back"; option description first-person "I'll review the diff at the slice boundary myself." Claim 7: review depth framed as gear-choice consequence, no enforcement implied. Claim 8: journal prerequisite now names journal-check.sh, conditional "mechanically enforced when the scaffold hooks are installed … Without the scaffold, honoring the ordering is on you — never stronger than that." Claim 9: post-edit lint referenced as installation-conditional parenthetical; agent delegation remains the primary check.
- **Deviations from spec**: None.
- **Validation**: pass — verification agent quoted and judged each rewrite against the rules (no model-as-actor mode claims anywhere; scaffold ceiling never exceeded; claims 1–2 template-conformant): 9/9 honest. Full-repo sweep for missed overclaims: none (evolve.md's "real mode shift" line is an engineer-contribution example, not a model claim; "enforced" appears exactly once, correctly qualified). Trellis 11/11, zero legacy warnings, stamp refreshed after the final command read (status: pass, 13:55).
- **Decisions made during implementation**:
  - Claim 9 handled as a parenthetical on the existing validation step rather than a rewrite: the agent delegation isn't dishonest per se — the gap was that nothing mechanical backed it; the parenthetical adds the hook reference without demoting the agent check (decided by: claude, free-climb mode)
  - README's "Commit per slice" principle line left untouched: Slice 10 owns README's enforced-vs-advisory presentation and will map that guarantee to its column there — avoids double-touching the same paragraph in consecutive slices (decided by: claude)
- **Acceptance criteria**:
  - [x] Each of the 9 inventory items diffed against its rewrite (quoted + judged by the verification agent)
  - [x] No remaining claim that the model checks, switches, or reverts permission modes
  - [x] Navigate's journal claim points at the journal-check hook as its mechanism, conditional on installation
- **Engineer feedback incorporated**: None — free-climb mode.
- **Learnings**:
  - Claude → Engineer: the memory note ("modes need mechanical teeth") closes cleanly this cycle — free climb's mechanical teeth turn out to be the engineer's own toggle plus the boundary ask, and the only honest enforcement vocabulary is "blocked by an installed hook." Everything else is a request.

### Slice 10: README enforced-vs-advisory section — Complete
- **Started**: 2026-06-10
- **Commit**: 9ffedab
- **Approach taken**: New `## Enforced vs Advisory` section after Context Overlays (the scaffold builds on the same machinery): enforced table (journal-before-commit via journal-check.sh, post-edit validation via post-edit-lint.sh + marker line), sentinel-scoping paragraph (no sentinel = silent no-ops; `rm .vine/ACTIVE` escape hatch), install/decline story (create-vine copies scripts, init wires settings, each hook independently declinable, decline = no-op), advisory table (approve-edits, free-climb boundary review, per-slice agent validation, AC checks, commit-per-slice, /clear), closing distinction ("the command asks and Claude follows instructions, rather than a hook blocking the alternative"). Links added from both old tip locations in Key Principles: the approve-edits paragraph and the commit-per-slice paragraph (anchor `#enforced-vs-advisory`, verified).
- **Deviations from spec**: None.
- **Validation**: pass — README-only slice (no command files, trellis not applicable). Anchor + both inbound links verified by grep. Column-exclusivity AC checked by inventory: 8 guarantees mentioned across VINE docs, each in exactly one column (2 enforced, 6 advisory).
- **Decisions made during implementation**:
  - Section placed after Context Overlays rather than near Key Principles: it documents machinery (scripts, sentinel, settings) that the overlays section just introduced; Key Principles links down to it (decided by: claude, free-climb mode)
  - help.md's tip not linked (it's terminal output where markdown anchors don't render); README locations only (decided by: claude)
- **Acceptance criteria**:
  - [x] Every guarantee VINE mentions appears in exactly one column
  - [x] Section links from the old approve-edits tip locations (Key Principles ×2)
- **Engineer feedback incorporated**: None — free-climb mode.
- **Learnings**:
  - Claude → Engineer: None beyond Slice 9's — this slice is the documentation surface of the same honesty rule.

### Session decision (post-PR review) — post-edit-lint.sh removed, 2026-06-10
Raised by the engineer reviewing hook overhead/risk after PR #65 opened ("are we
over-indexing on when to validate?"). Probing established: the script contained no
validation logic (a generic trigger; the repo supplies 100% of behavior via the marker),
had no file discrimination (fires on every Edit/Write — including VINE's own journal/spec
edits, guaranteed by the workflow itself), shipped inert everywhere (no repo has the
marker), and was redundant with the agent-based per-slice validation it was meant to back.
- **Decision**: drop it as a configurable hook entirely — when and how to validate is the
  repo's decision based on its own tooling; teams can wire native hooks directly. The
  scaffold ships one hook (journal-check, kept as shipped). The marker convention dies
  unshipped. #54's Validation block is the future home for any VINE validation contract.
  (decided by: engineer)
- **Unwound in PR #65**: script deleted; run-tests.sh 17→11 cases (all passing); settings.json
  PostToolUse block removed; cli.js allowlist + package.json ship one script (npm pack
  verified); init's scaffold section rewritten single-hook (multiSelect dropped — 2-option
  offer); navigate's step-4a parenthetical removed; README enforced table one row + explicit
  "validation belongs to the repo" boundary statement; STATE.md scripts table + marker
  paragraph replaced with the same boundary statement; shared.md CI/CD updated. SPEC Phase 2
  header carries the full addendum.
- **Learning (Claude → Engineer)**: the tell was patch accumulation — rescuing per-edit
  validation needed three fixes ($VINE_FILE scoping, .vine/ exclusion, suitability gating)
  before it was defensible. A hook whose entire behavior is repo-supplied configuration is
  a decision VINE was making on the repo's behalf.

### Session decision (post-PR review) — validation contract routed to #54, 2026-06-10
Follow-on from the lint-hook removal: the engineer reviewed VINE's verification landscape
(three advisory agent-based checkpoints — per slice, per phase group, per feature — plus the
journal process gate) and chose the direction for validation reliability: **the specific
commands live in the repo's overlays; init suggests them, optimize maintains them.**
- **Decision**: captured as a design comment on #54 (implementation stays cycle 4) rather
  than pulled into this cycle. Key additions to #54's proposal: init smoke-runs discovered
  commands before writing the block (verify the verifiers); optimize becomes the standing
  auditor (stale commands, uncovered tooling, missing block); the block is the repo-owned
  answer to enforcement — teams wire their own settings.json hooks at it, VINE supplies the
  contract, never the trigger; paths updated post-#58 (`.vine/context/`), shared.md
  placement confirmed against the shared.md identity decision (validation is cross-phase).
  (decided by: engineer)
- **SPEC updated — Slice 12**: addendum — the optimize rewrite must structure audit
  sections so #54 adds a check rather than another rewrite; the audit itself is NOT
  implemented in this cycle.
- Identified but not yet filed (candidates for evolve's follow-up triage): coverage-check
  asymmetry (the untested-slice question only fires at multi-PR phase-group boundaries —
  single-PR features never get it; natural fix is evolve's verification), and CI status
  invisible to VINE (evolve reads prior PR comments via gh but never `gh pr checks`).

### Session decision (post-PR review) — uncommitted-artifacts story documented, 2026-06-10
The engineer asked what #65 needs for users who never commit VINE artifacts (gitignored
`.vine/`, or the future `.vine.local/` personal scope). Assessment: the design already
handles it — journal-check's staleness is mtime-based, not git-state-based, chosen exactly
because NAVIGATION.md is gitignored in most repos; the sentinel never leaves the machine;
the opaque-feature-path constraint pre-clears `.vine.local/` paths; missing journals fail
open. Two prose gaps closed in #65 (both files already in the diff):
- navigate step 4c's staging instruction no longer assumes tracked artifacts ("Include
  NAVIGATION.md in the commit only when the repo tracks `.vine/` artifacts... the guarantee
  compares file modification time, not commit contents").
- README's Enforced vs Advisory section states the mtime design explicitly so adopters with
  personal/gitignored artifacts know the guarantee holds for them.
Trellis 11/11 post-edit; agent confirmed 4b (journal update required) and 4c (staging
optional) read as orthogonal, mutually reinforcing rules. Added triage candidate: evolve's
"Commit Evolve Changes" step carries the same tracked-artifact assumption (stages
EVOLUTION.md unconditionally) — pre-existing, outside #65's diff, fix alongside the other
evolve candidates.

### Session decision (post-PR review) — artifact-coherence checks filed as #66, 2026-06-10
The engineer asked whether VINE should verify artifacts against each other through the flow
(SPEC vs CONTEXT, NAVIGATION vs SPEC, general cohesion). Assessment: a general cohesion
check was rejected — expensive, vague, prone to performative findings; the broad case is
already covered by phases reading upstream artifacts at session start, navigate step 7's
assumption re-check, and evolve's deviation review. Two targeted gaps with mechanical teeth
were filed as idea issue #66 (decided by: engineer):
- Deviation closure: navigate's completion gate verifies every non-"None" slice deviation
  has a matching SPEC annotation (enforces step 6's dual-update discipline).
- AC traceability: evolve's rollup maps every cycle-level SPEC criterion to slice/commit
  evidence or flags it unaccounted.
Backlog scope — not part of this cycle's remaining phases. Adjacent observation recorded in
the issue: structural artifact validation (trellis) is contributor-only; user repos have
none.

### Phase 2 group verification — 2026-06-10
Pre-PR product check per navigate step 8 (delegated to vine-verification):
- **Full validation**: trellis 11/11; `sh -n` + `dash -n` on all scripts; `node --check` cli.js; settings.json JSON-valid; npm pack ships exactly the two scaffold scripts.
- **Cross-slice integration**: 7/7 contracts verified — sentinel format (navigate prose ↔ journal-check sed ↔ STATE.md), stamp format (trellis Step 8 ↔ gate grep), marker convention (init/README docs ↔ lint-script sed, incl. legacy fallback), settings matchers ↔ STATE table ↔ script headers, sentinel/PAUSE lifecycle closure (every documented trigger has command prose; resume's deferral self-documented), README enforced-section claims ↔ actual script semantics, honest-prose ceiling held across the full diff.
- **Findings resolved**: STATE.md scripts table now notes contributor-only scripts share the directory (30baf39). resume.md PAUSE-deletion gap left as designed (Slice 16). README's collapsed "navigate clears it" summary accepted (info-level).
- **Test coverage decision (engineer)**: committed `.vine/scripts/run-tests.sh` — 17-case temp-repo matrix for all three scripts, 17/17 passing (30baf39). Contributor-only, not shipped.
- **AC rollup**: 10/10 criteria met across Slices 6–10 (table in this entry's slices).
- **Commits this group**: 6a4b56c, 2b9e616, 02f278a, 4228f94, 9ffedab, 30baf39.

### Slice 11: Boundary rule + this-repo dedup — Complete
- **Started**: 2026-06-10 16:18
- **Commit**: 96bb20a
- **Approach taken**: Rule first, dedup second. STATE.md gains a top-level `## Knowledge Boundary` section (between Per-Repo Artifacts and Artifact-Free Commands): a four-surface table keyed to reader scope with a "Who pays the tokens" column, the cost-framing paragraph (non-VINE teammate pays for CLAUDE.md, never shared.md), two explicit consequences of the native-surface row (inventories live nowhere in files; routing is not inventory), shared.md's one-line identity, the pointer-on-move rule, and both forward references (#51 `.vine/knowledge/<domain>.md` pointer convention; `.vine.local/` projects sharing boundary). Then this repo deduped per the rule: shared.md's VINE Commands + Contributor Tools enumerations deleted (native skill list is the home), keeping one repo-specific note (symlink topology = working-tree dogfooding); Repository Structure and Writing Style reduced to one-line pointers at CLAUDE.md; Command Addition Checklist loses its "shared.md — command list and count" entry (no list exists there anymore). CLAUDE.md absorbed the two orphaned unique facts: `.github/` line in Repository Structure, section-header/anti-pattern bullet in Command Authoring Conventions.
- **Deviations from spec**: None.
- **Validation**: pass — vine-verification agent, 8/8 checks (dedup completeness, pointer integrity, both forward refs, cost framing, native-surface category, no enumeration in shared.md, structural sanity, cross-reference targets exist). No markdownlint config in repo; no command files touched (trellis gate not in play).
- **Decisions made during implementation**:
  - Knowledge Boundary placed as a top-level STATE.md prose section (peer of Project Lifecycle), not inside any artifact template — no required/optional markers needed since the marker convention governs template headings (decided by: claude, free-climb mode)
  - shared.md's Content Standards, Command Addition Checklist, Team Context, CI/CD stay put — contributor process knowledge, not near-verbatim duplicated, fits "cross-phase project-development context" (decided by: claude, free-climb mode)
  - "Editing a command file changes the tool itself" deleted from shared.md (CLAUDE.md already owns it verbatim); symlink note kept and sharpened to say *why* it matters (working-tree edits are live) (decided by: claude, free-climb mode)
- **Acceptance criteria**:
  - [x] No section appears near-verbatim in both files
  - [x] Each moved section leaves a one-line pointer at its old home
  - [x] Rule text names both forward references explicitly (#51 `.vine/knowledge`, `.vine.local/`)
  - [x] Rule framed by cost — states what a non-VINE teammate pays per home
  - [x] Rule names the native-surface category explicitly; shared.md's Available Tools & Agents reduces to repo-specific notes with no enumeration
- **Engineer feedback incorporated**: None — free-climb mode.
- **Learnings**:
  - Claude → Engineer: The verification agent flagged that the Engineer Profile Protocol (shared.md, operational how-to) vs Engineer Profile (CLAUDE.md, summary contract) split looks like duplication at a glance but isn't — the boundary rule's "same subject, different reader scope" distinction may be worth a future example in the rule text if it confuses contributors.

### Slice 12: Optimize rewrite + CLAUDE.md pointer — Complete
- **Started**: 2026-06-10 16:25
- **Commit**: 8497ff3
- **Approach taken**: optimize.md re-aimed at the new knowledge surfaces: "What This Does" gains a knowledge-placement paragraph citing the Knowledge Boundary rule; 1d becomes "CLAUDE.md and shared.md Context" (checks for the pointer, detects pre-0.4 full-map layout as a move candidate); 2c's cross-command table gains two boundary rows ("Inventory in files" = audit finding, "Overlay coverage" = each phase overlay points at its phase-relevant tooling, never fixed by file inventory) and the overlap row now cites the rule; Phase 2 gets an extensibility contract ("named, self-contained audit checks... extend the list, don't restructure it") so #54 adds a subsection, not a rewrite — audit NOT implemented; 3b's ownership paragraph rewritten to cite the four-surface rule; 3d becomes "Write Workflow Map to shared.md" (chains + state-based suggestions ONLY, no inventory rule first in the list, pre-0.4 migration offer); NEW 3e "Verify the CLAUDE.md Pointer" with the canonical pointer block (old 3e/3f renumbered 3f/3g, summary block updated). First execution on this repo: CLAUDE.md's 46-line generated map replaced by the 5-line `## VINE` pointer; map moved to shared.md minus the Available Agents inventory (native list is its home); `agents/` line added to CLAUDE.md Repository Structure so the shipped-agents fact survives the inventory deletion; CLAUDE.md's optimize description corrected ("maintaining the workflow map in shared.md and verifying CLAUDE.md's VINE pointer"). Availability-gated pointer recorded as a Project Conventions entry in shared.md. Rider: evolve.md line 245 ("workflow map in CLAUDE.md" → shared.md), found by grep before editing.
- **Deviations from spec**: None.
- **Validation**: pass — trellis 11/11 (stamp written 16:32, gate satisfied; known pre-existing artifact finding: SPEC.md lacks `### Work Slices` heading, owned by Slice 14); vine-verification agent 9/9 (pointer ≤10 lines and install-agnostic, write-target = shared.md, convention recorded, no enumeration in map, #54 extensibility, evolve.md consistency, 3a–3g renumbering integrity, shared.md flow + generation date).
- **Decisions made during implementation**:
  - Phase 2 extensibility note avoids hardcoding "(2a–2e)" — a literal range goes stale on the first added check, defeating the contract it announces (decided by: claude, free-climb mode)
  - #54 named generically in optimize.md as "a validation-contract check" — issue numbers don't belong in shipped command files (decided by: claude, free-climb mode)
  - `agents/` added to CLAUDE.md Repository Structure — the directory's existence is a repo fact; only the per-agent enumeration dies (decided by: claude, free-climb mode)
  - evolve.md rider folded into this slice — same fact correction, one-line diff (decided by: claude, free-climb mode)
- **Acceptance criteria**:
  - [x] CLAUDE.md's VINE content is ≤ ~10 lines (pointer block is 5)
  - [x] Pointer makes no assumption about install location (gates on session availability)
  - [x] optimize's write-target instructions name shared.md
  - [x] Availability-gated pointer pattern recorded as a convention in shared.md
  - [x] Map contains no command enumeration; inventory in shared.md is an audit finding (2c row)
  - [x] Audit sections structured so #54 adds a check, not another rewrite; audit not implemented
- **Engineer feedback incorporated**: None — free-climb mode.
- **Learnings**:
  - Claude → Engineer: Verification flagged that shared.md's "## Available Tools & Agents" heading now reads like an inventory home while holding only the symlink note — rename candidate for evolve (e.g., "Tooling Notes"); left as-is because the spec addendum names the section by its current title.

### Slice 13: Init dedup offer — Complete
- **Started**: 2026-06-10 16:40
- **Commit**: 5f196e5
- **Approach taken**: New `### Knowledge Boundary Dedup` subsection in init's Step 7, sequenced inside upgrade mode (Legacy Directory Migration → Upgrade Mode → Knowledge Boundary Dedup → Native Hook Scaffold): compares CLAUDE.md and shared.md for near-verbatim duplicates and pre-0.4 full-map/inventory layout, shows a concrete diff preview before the AskUserQuestion (which file keeps content per the rule, the pointer line the other file gets, exact lines removed), accept path bounded to "exactly the previewed moves," decline is a documented no-op repeating next init, no-overlap is an explicit silent skip. Riders folded in per the Phase 3 handoff: the generated shared.md template's "Available Tools & Agents" bracket guidance rewritten to notes-not-inventory (cites the rule, routes phase-specific mappings to per-phase overlays); "What This Does" gains item 7.
- **Deviations from spec**: None against the slice spec. One addition beyond the spec'd file list: `Edit` added to init's allowed-tools — the dedup offer has init surgically editing CLAUDE.md (a user-owned file) and init previously had only Write; whole-file rewrite is the wrong tool for that. Trellis Check 7 passes (Edit is in the cross-command union).
- **Validation**: pass — trellis re-run on init.md after edits, fresh stamp 16:44 (only init.md changed since the full 11/11 run); vine-verification agent 7/7 (preview-before-ask with bounded accept, decline no-op + silent skip, upgrade-mode-only scoping, AskUserQuestion conventions, template consistency cross-checked against STATE.md's rule, internal numbering/frontmatter/ordering, zero regression to flanking Step 7 sections).
- **Decisions made during implementation**:
  - Template keeps the "## Available Tools & Agents" heading (only the bracket guidance changed) — renaming would put a gratuitous diff in every existing install's upgrade pass; the rename idea stays an evolve candidate alongside this repo's same-named section (decided by: claude, free-climb mode)
  - Edit tool grant added (see Deviations) (decided by: claude, free-climb mode)
- **Acceptance criteria**:
  - [x] Offer shows a concrete diff preview before asking
  - [x] Decline path is a documented no-op
- **Engineer feedback incorporated**: None — free-climb mode.
- **Learnings**:
  - Claude → Engineer: The tool-grant gap (init editing a user's CLAUDE.md with only Write available) only surfaced on the full re-read of the command — the slice spec's "files likely touched: init.md" was accurate but the frontmatter is part of the file's behavior surface, not just its metadata.

### Phase 3 group verification — 2026-06-10
Pre-PR product check per navigate step 8:
- **Full validation**: trellis 11/11 (fresh stamp); hook test matrix `run-tests.sh` 11/11; `node --check` cli.js OK; settings.json JSON-valid.
- **Cross-slice integration** (vine-verification agent, 7/7 contracts): rule ↔ consumers (all citers point at STATE.md and rely only on what the rule says); pointer chain integrity (CLAUDE.md → shared.md map, shared.md pointers → real CLAUDE.md sections); optimize 3e's canonical pointer block byte-identical to this repo's `## VINE` block; init template coherent with the rule and with optimize's map ownership; vocabulary consistent across all five surfaces; no orphaned references to the moved map/deleted enumerations; trellis dependencies untouched.
- **Findings**: CHANGELOG.md's most recent map description (0.3.0 entry, "Skill Workflows in CLAUDE.md") is now stale with no [Unreleased] counterpart — deferred to Slice 19, which already owns the CHANGELOG 0.4.0 entry for #59–#62 (same treatment as PR #65). Stale worktree copy under `.claude/worktrees/` noted, not in the working tree, no action.
- **Test coverage decision**: no new untested behavior — Phase 3 is command/reference prose; the hook matrix (unchanged scripts) stays at 11/11.
- **AC rollup**: 13/13 criteria met across Slices 11–13 (5 + 6 + 2; per-slice tables above).
- **Commits this group**: 96bb20a, 8497ff3, 5f196e5.

### Slice 14: STATE.md contracts — Complete
- **Started**: 2026-06-10 19:02
- **Commit**: 9368236
- **Approach taken**: Four parts in `references/STATE.md` + `.claude/commands/trellis.md`. (1) **Slice-status contract**: NAVIGATION template's two slice headings gained the `— [Status: In Progress / Complete]` suffix (marker intact), plus a prose note documenting the navigate-writes / pause-reads contract and the "keep the literal words" warning. (2) **Remaining Work dependency**: documented why `### Remaining Work` stays `<!-- optional -->` (only exists at session boundaries — promoting would fail Check A on every mid-implementation journal) and named its two readers (resume no-PAUSE path, native-task rebuild). (3) **New top-level `## Source of Truth vs Derived Views` section** (before Artifact-Free Commands): sources of truth by altitude (SPEC=plan, NAVIGATION=progress, .vine/ACTIVE=active-now, PAUSE=handoff) vs derived views — native tasks (ephemeral live view, *rebuilt FROM the journal, never the reverse*) and PROJECT-MAP.md (durable derived view, journal wins on disagreement, schema stays coarse to avoid a second writer). Generalized from the spec'd live-view/journal split per the engineer's "document the principle" choice on the PROJECT-MAP single-source-of-truth question. (4) **SPEC phase-grouped drift fix**: moved `<!-- required -->` from `### Work Slices` (now optional umbrella) onto `### Slice 1: [Name]` (h3, the invariant across both layouts), described conditional (`(CONDITIONAL)` suffix) + flat/grouped layouts in prose, corrected the template's h4→h3 drift; trellis Check A repeating-entry prose generalized to SPEC slices (two spots) + a legacy-h4 hint, Check C finds `### Slice N:` regardless of umbrella with `(CONDITIONAL)`-suffix detection and marker-agnostic fields.
- **Deviations from spec**: `.claude/commands/trellis.md` touched beyond the spec's "STATE.md only" file list — necessary because Check A/C are mechanically coupled to the SPEC template and the whole point is making trellis pass on this feature's own grouped SPEC. The `## Source of Truth vs Derived Views` section was generalized beyond the spec'd "live-view vs durable-journal split" to also cover PROJECT-MAP as a derived view (engineer-chosen, see decisions).
- **Validation**: pass — vine-verification agent ran trellis's full check suite: 11/11 commands pass; **SPEC drift fixed** (platform-alignment SPEC.md now passes Check A via its 19 `### Slice N:` headings and Check C with all 5 fields on each — previously failed Check A on the missing `### Work Slices`); NAVIGATION.md still passes Check A (the `— Complete` suffix doesn't disturb the `Slice N:` prefix match) + Check D; zero new Step 5a unmarked-heading warnings; six other specs correctly `.resolved`-filtered; 17/17 ACs verified with file:line evidence; no regressions.
- **Decisions made during implementation**:
  - Remaining Work documented (kept optional) rather than promoted to required — promoting fails Check A on every mid-implementation journal since Remaining Work only exists at session boundaries (decided by: claude, confirmed by engineer at the part-1/2 review pause)
  - Live-view section generalized to state the source-of-truth-vs-view principle once, naming both native tasks (ephemeral) and PROJECT-MAP (durable) as derived views — answers the engineer's "single source of truth for project state" question in the file without enriching PROJECT-MAP's schema or adding a second writer (decided by: engineer, "Document the principle")
  - SPEC slice contract is **h3-only canonical** (`### Slice N:`), matching what inquire emits today; the four legacy `#### Slice` (h4) specs are all `.resolved` so no live regression (decided by: engineer)
  - Legacy-h4 update path: trellis Check A names the re-level fix when it sees h4-only slices ("after"/anytime path); a declinable init-upgrade normalization offer filed as a backlog idea ("during upgrade" path, not built this cycle, must not blanket-rewrite personal artifacts) (decided by: engineer, raised the update-path question)
- **Acceptance criteria**:
  - [x] Both contracts have required/optional markers (Status suffix = required on the slice heading; Remaining Work = optional + documented dependency)
  - [x] The split section states tasks are rebuilt FROM the journal, never the reverse
  - [x] (Drift fix) trellis passes on this feature's phase-grouped SPEC; the contract aligns to inquire's actual `### Slice N:` emission
- **Engineer feedback incorporated**: Walk-through gearing. Engineer steered three calls: keep Remaining Work optional (confirmed), document the PROJECT-MAP-as-derived principle (chose "Document the principle" over scoping to just tasks or filing a backlog issue), and h3-only canonical with a documented update path (raised the "update path during/after upgrade" question that produced the trellis hint + backlog idea).
- **Discovered items**:
  - The repo contains two historical slice-heading conventions (`#### Slice` h4 in 4 resolved specs, `### Slice` h3 in newer ones). All h4 specs resolved; the h3-only contract is forward-correct. Backlog idea filed (SPEC Backlog Updates) for an optional init normalization offer.
- **Learnings**:
  - Engineer → Claude: "derived from docs" and "single source of truth" are the same direction, not a tradeoff — a view stays in sync precisely because it owns no state. The fix for the single-source question is to keep PROJECT-MAP derived, not to enrich it.
  - Claude → Engineer: matching the contract to what the *writer* actually emits (inquire → h3 slices) is the same discipline applied to the honest-prose pass — the SPEC template had silently drifted to h4 while inquire moved to h3, and trellis inherited the stale level.

### Slice 15: Navigate task tracking — Complete
- **Started**: 2026-06-10 19:55
- **Commit**: 4b55f33
- **Approach taken**: Five edits to `commands/vine/navigate.md` (the shipped command), every task instruction guarded "when available". (1) Frontmatter `allowed-tools` += `TaskCreate`/`TaskUpdate`/`TaskList` (after AskUserQuestion). (2) Session-start "Build the live task view (when available)" block, placed after the sentinel + pause-consumption and before the starting-point summary: `TaskCreate` one task per remaining slice in the current phase group, `blockedBy`-ordered, skip slices already `Complete` in NAVIGATION.md, conditional slices prefixed `(conditional: <condition>)` and left pending, pointing at Slice 14's "Source of Truth vs Derived Views" definition rather than re-specifying — with an explicit blanket clause: "**When task tools aren't available, skip this and every other (when available) task step below**" (the master gate). (3) Step 3 lead-in: `TaskUpdate` the slice's task to `in_progress` as it begins. (4) Step 4c, woven into the existing commit flow after the `**Commit**`-field update: `TaskUpdate` to `completed` once the commit lands ("the live view follows the journal, so it flips only after the durable record is written"). (5) Step 7.4 conditional disposition: drop the prefix and proceed if the condition holds, `TaskUpdate` to `deleted` + note the skip if not. Rider: `CLAUDE.md` line 23 valid-tools list += the three Task tools with a "when available, by navigate/resume, trellis validates by consensus" note.
- **Deviations from spec**: One rider beyond the spec's navigate.md-only file list — `CLAUDE.md`'s valid-tools authoring list (contributor doc, not shipped) updated for accuracy; done once here so Slice 16 needn't re-touch it. The rider names "navigate/resume" as consumers though resume's frontmatter gets the tools in Slice 16 — a deliberate same-PR forward reference (the live progress view is a navigate+resume feature per STATE.md; "when available" framing holds regardless).
- **Validation**: pass — vine-verification agent: trellis 11/11 commands (navigate's three new tools self-ratify via Check 7's consensus union; Check 8 AskUserQuestion still referenced; overlays-before-profile ordering intact — task block sits in section 1, well after the Load sections); stamp written `status: pass` 20:17. **Backward-compat gate confirmed**: every one of the 5 instructions carries a "when available" guard, the blanket skip clause is the master gate, NAVIGATION.md journal template unchanged (task tracking is additive, zero new fields), and no task step is load-bearing — removing them all leaves preview→implement→validate→journal→commit intact. Agent's explicit conclusion: navigate behaves byte-identically when task tools are absent. Lifecycle coherent: create→in_progress→completed (only after commit+journal)→deleted (conditional only). 3/3 ACs met.
- **Decisions made during implementation**:
  - Live-view block placed after pause-consumption / before the starting-point summary (session-setup grouping), not as a new numbered step — avoids renumbering steps 2–8 (decided by: claude, free-climb mode)
  - Create tasks for *remaining* (not-yet-Complete) slices only, skipping ones already in the journal — matches the spec's "one task per remaining slice"; resume's fuller rebuild (completed + remaining) is Slice 16's job (decided by: claude, free-climb mode)
  - `completed` transition sequenced strictly after the `**Commit**`-field/journal update — encodes "the view follows the journal, never leads it" from Slice 14's source-of-truth principle (decided by: claude)
  - CLAUDE.md valid-tools rider done now rather than deferred to Slice 16 — the set is union-wide, so one edit covers both commands (decided by: claude, free-climb mode)
- **Acceptance criteria**:
  - [x] Task list matches SPEC.md's remaining slices for the current phase group (sourced from SPEC + NAVIGATION, skipping Complete)
  - [x] No NAVIGATION.md format change (journal template untouched; task tracking additive)
  - [x] allowed-tools gains TaskCreate/TaskUpdate/TaskList; trellis consensus check passes (11/11)
- **Engineer feedback incorporated**: Free-climb gearing. The engineer's pre-slice scoping correction (trellis/STATE.md don't ship; only `commands/vine/*` reaches user projects) set the validation priority — the backward-compat gate ("byte-identical when task tools absent") was made the primary verification target and confirmed.
- **Learnings**:
  - Engineer → Claude: the only Slice-14/15 change that reaches user projects is `commands/vine/navigate.md`; trellis (contributor-only) and references/STATE.md (unshipped) don't. Scoping the validation to user-facing impact — the "when available / byte-identical absent" gate — is the check that matters, not trellis aesthetics.
  - Claude → Engineer: dogfooding Slice 15's pattern *before* writing it (this session created tasks #14–16 at start with blockedBy ordering) meant the slice codified a proven flow — the spec, the live run, and the written instruction all matched, so validation was confirmation rather than discovery.

### Slice 16: Resume + status task awareness — Complete
- **Started**: 2026-06-10 20:30
- **Commit**: 9e4b7de
- **Approach taken**: Four files. **resume.md**: frontmatter += `Edit`/`Bash`/`TaskCreate`/`TaskUpdate`/`TaskList`; identity reworded "read-only — shows status and recommends, nothing more" → "**creates no artifacts**" (never writes the CONTEXT/SPEC/NAVIGATION/EVOLUTION chain; touches only ephemeral/derived state — task view, consumed PAUSE.md, PROJECT-MAP PR backfill); new "**Resume is the `/clear` exception**" paragraph + both recommendation blocks drop the `/clear` prefix; new "## Restore Session State" section with (a) native task rebuild *when available* matching navigate's Slice-15 rules (remaining slices in current group, `blockedBy`-ordered, skip Complete, conditional prefix, `TaskUpdate` the In-Progress slice) and (b) PAUSE consumption *if present* (delete after display). **status.md**: frontmatter += `TaskList` (read-only); "Fast" principle rewritten to fix the "no deep file scanning" overclaim ("counting `Complete` slice headings is the deepest it reads") + optional TaskList awareness (honest that a fresh session has no list). **inquire.md**: frontmatter += `Bash`; PAUSE-consumption block at end of "Load the Context" (the Slice 6 post-verify leak path). **STATE.md**: removed the resolved "(deletion mechanics land with resume's task-awareness update)" parenthetical + added `vine:inquire` to the PAUSE deletion triggers; added the `/clear`-exception paragraph to the Chaining Protocol (resume + status exempt).
- **Deviations from spec**: Two engineer-directed additions beyond the spec's Slice 16 goal. (1) **resume granted `Edit`** and its pre-existing PR-backfill (claims to update PROJECT-MAP.md but lacked the tool) made honest — engineer chose "resume should have edit power, do what makes sense" over the minimal Bash+Task grant. Justified by the "creates no artifacts" reword (PROJECT-MAP is a derived view, not a chain artifact). (2) **resume `/clear` exception** — engineer raised that resume "is just a quick handoff to whatever was already running," so it shouldn't suggest `/clear` (it just rebuilt the context `/clear` would discard). Folded into both resume.md and STATE.md's Chaining Protocol since it crystallizes resume's identity.
- **Validation**: pass — vine-verification agent: trellis 11/11 (resume's Edit/Bash/Task tools, status's TaskList, inquire's Bash all self-ratify via Check 7 consensus; overlays-before-profile ordering intact in all three; AskUserQuestion still referenced); stamp `status: pass` 21:05. **Backward-compat confirmed**: task rebuild "when available", PAUSE consumption "if present", status stays read-only (TaskList is a read tool, "never writes" principle uncontradicted) — absent task tools + absent PAUSE.md, all three behave as before, only genuine change is the PAUSE-deletion bugfix. **4/4 ACs met**: resume's rebuild rules match navigate.md:108–114; resume has no `Write` (zero chain-artifact writes; Edit only touches derived PROJECT-MAP); status unchanged absent task tools; consumed PAUSE.md no longer exists post-resume. **Cross-file consistency**: `/clear` exception agrees resume.md ↔ STATE.md; all 5 PAUSE-deletion triggers (resume/navigate/inquire/evolve×2) verified against actual command prose.
- **Decisions made during implementation**:
  - resume's full grant (Edit + Bash + Task tools) over minimal — engineer chose to fix the pre-existing PR-backfill inconsistency now rather than defer it; the "creates no artifacts" reword licenses it (none touch the chain) (decided by: engineer)
  - `/clear` exception applies to resume AND status (status is exempt because it doesn't chain or recommend at all) — documented in STATE.md's Chaining Protocol so the protocol and commands agree (decided by: claude, walk-through)
  - resume's rebuild adds an `In Progress → in_progress` TaskUpdate beyond navigate's create-only rules — resume reconstructs an in-flight state where a slice may already be active, which navigate would have set live; keeps "matches what navigate would create" true for the resumed moment (decided by: claude, walk-through)
  - status's TaskList framed as usually-absent (fresh session has no list) — honest about the marginal benefit rather than implying a populated list is the norm (decided by: claude)
- **Acceptance criteria**:
  - [x] Resume's rebuilt list matches what navigate would create (remaining slices, blockedBy, skip Complete, conditional prefix — resume.md:172–175 vs navigate.md:108–114)
  - [x] Resume creates zero chain artifacts (no `Write` granted; Edit only on derived PROJECT-MAP; identity reworded to "creates no artifacts")
  - [x] Status works unchanged when task tools are absent (derives [X of Y] from NAVIGATION.md as before)
  - [x] After a resume that displayed a PAUSE.md, the PAUSE.md no longer exists (delete instruction + Bash grant)
- **Engineer feedback incorporated**: Walk-through gearing. Engineer steered two material additions — the Edit grant + PR-backfill fix ("do what makes sense here"), and the `/clear` exception ("it is just a quick handoff to whatever was already running"). Also confirmed the "creates no artifacts" wording and approved adding the Chaining Protocol exception note to STATE.md.
- **Discovered items**:
  - The desktop empirical finding (this session): native `TaskCreate` todos render only as a transient "Todos Updated" line, not a persistent panel; the subagents pane shows background work, not the todo list. The "live view" benefit of #61 is narrower than the SPEC framed — real value is the resume-rebuild source + agent-side structure. Decision (engineer): keep #61 as-is, no refinement edits; ensure Slice 19's README states it plainly (structured progress + resume rebuild, not a watchable dashboard). Carried to evolve / PR description.
- **Learnings**:
  - Engineer → Claude: resume's identity is "restore context and hand back into the running work" — which is why it's the `/clear` exception. The reword from "read-only" to "creates no artifacts" was the right line: resume does write (PAUSE delete, PROJECT-MAP backfill, task rebuild), it just never produces a chain artifact.
  - Claude → Engineer: granting a command a tool surfaces latent inconsistencies — resume's PR-backfill had always claimed to edit PROJECT-MAP without an Edit grant; adding Edit for the slice's needs was the moment to make the pre-existing claim honest rather than leave a documented-but-impossible action.

### Phase 5 session start — Plan Mode (#62) reshaped, 2026-06-10
Resumed for Phase 5. Before implementing, surfaced the Phase 4 handoff's flagged tension and
re-confirmed it against the live tool: `ExitPlanMode` takes no content param (it renders the
harness plan *file*) and its own docs say it's for planning code-writing tasks, explicitly not
research — making verify a documented non-fit and inquire only a partial fit for the original
"artifact-as-the-plan" design.
- **Decision (engineer)**: SPEC.md is VINE's plan; the artifact chain + AskUserQuestion sign-offs
  are the gate; the clean phase break is itself the approval boundary. Then a further call: **drop
  harness plan mode from the cycle entirely** — it's a harness concern the harness already handles
  (Claude calls `ExitPlanMode` itself when it needs to write; a VINE command teaching it that
  narrates behavior VINE doesn't own). Same repo-owned-decision line as the Phase 2 lint-hook removal.
- **Phase 5 reshaped** (SPEC.md Phase 5 reshape note + Slices 17–19 rewritten):
  - Slice 17: gearing ↔ permission-mode preference in navigate (was "verify plan-mode integration").
  - Slice 18: inquire sign-off gate + artifact review links (unchanged — never depended on plan mode).
  - Slice 19: README gearing↔mode + task docs (plan-mode docs dropped).
- Clarified for the engineer: outside plan mode the rendered-review UX is already native (response
  output is rendered GFM, the artifact file opens rendered in the editor, AskUserQuestion is the
  gate) — so SPEC-as-the-plan loses no review UX. Artifact auto-open stays optional repo wiring
  (OS-specific, dead headless), not VINE-hardcoded; the default is a clickable artifact link (Slice 18).

### Slice 17: Gearing ↔ permission-mode preference (navigate) — Complete
**Started**: 2026-06-10 21:34
**Commit**: 2921233
**Approach taken**: One file (`commands/vine/navigate.md`), the gearing portion of step 3a. Made the
implicit gear→mode mapping explicit and symmetric: the two AskUserQuestion gear-option descriptions
now name the paired mode ("(pairs with auto-accept-edits)" / "(pairs with approve-edits)"); the
**Gearing** prose lead-in states the choice sets engagement level *and* the fitting permission mode,
guarded by the honest-modes rule ("Recommend the matching mode — the toggle is always the engineer's
action; you can suggest it, never flip it or assume it happened"); free climb recommends
auto-accept-edits (or full auto), walk-me-through recommends approve-edits (per-edit permission
prompts). No plan-mode/`ExitPlanMode` reference introduced. verify/inquire untouched (no gearing;
they already recommend approve-edits in "Before You Start").
**Deviations from spec**: None against the reshaped Slice 17. The reshape itself (plan mode dropped)
is recorded in the session note above and SPEC.md's Phase 5 reshape note.
**Validation**: pass — `/trellis` in-session: 11/11 commands pass all checks, zero legacy warnings;
artifact validation all pass (PROFILE + platform-alignment CONTEXT/SPEC/NAVIGATION; 6 resolved
features filtered); stamp written `status: pass` 21:57.
**Decisions made during implementation**:
  - Mode named in the option *description*, not the label — labels stay short ("Free climb" / "Walk
    me through this"); the "(pairs with …)" hint rides the description (decided by: claude, free-climb mode)
**Acceptance criteria**:
  - [x] Both gear options name their recommended permission mode
  - [x] Gearing prose states free-climb→auto-accept and walk-through→approve-edits symmetrically
  - [x] Every mode reference frames the toggle as the engineer's action (no model-switches-mode claim)
  - [x] No plan-mode or `ExitPlanMode` reference introduced
**Engineer feedback incorporated**: The slice exists in this form because the engineer redirected
twice — first "SPEC is the plan; is tapping harness plan mode worth it at all?", then "don't mention
plan mode; have a mode preference per gear (accept-edits/auto for free climb, permissions for
walk-me-through)."
**Learnings**:
  - Engineer → Claude: harness plan mode is the harness's job — VINE teaching Claude to call
    `ExitPlanMode` would narrate behavior it doesn't own. The VINE-level value was never plan-mode
    integration; it was aligning the permission mode with the gearing intent the engineer already signals.

### Remaining Work
- **Incomplete slices**: Phases 1–3 shipped (PR #63, PR #65, PR #67). Phase 4 — Native Tasks (#61) complete (Slices 14–16). **Phase 5 — reshaped (see session note): Slice 17 ✅ complete this session; Slices 18–19 remaining.** Phases 4 and 5 share PR 4, which opens only after Phase 5.
- **Phase 5 design input (this session)**: investigated plan-mode mechanics before implementing Slices 17–19. Key finding — `ExitPlanMode` takes NO content param; it renders the **harness-designated plan file** (the model writes its plan there, ExitPlanMode signals done). To surface an artifact as the plan, write the artifact body into that plan file, then persist to the real path on approval. Also: `ExitPlanMode`'s own guidance says it's for *planning the implementation of a code-writing task*, and explicitly NOT for research — so verify (research) is a documented non-fit, inquire (spec) a partial fit, and **navigate is the textbook fit** (plan the phase-group slices → approve → implement, task list as live view after). This is in tension with the SPEC's verify/inquire-only Phase 5 scope. Desktop has separate `plan` and `tasks` panes (confirmed). **Revisit Slices 17–19 before implementing** — possibly reframe navigate plan-mode integration from backlog to in-scope. Backlog idea NOT yet filed (engineer dismissed the file/continue prompt): "navigate/evolve plan-mode integration — present the phase-group slice plan via ExitPlanMode at session start when in plan mode, then fall to the tasks-pane live view; also fixes navigate breaking when launched in plan mode."
- **Blockers**: None.
- **Blockers encountered**: None.
- **Handoff context**: Next session: Phase 4 — Native Tasks (#61, Slices 14–16). After #67 merges, recreate the branch from main (this session's lesson: GitHub auto-deletes the head branch on merge, so the stale local tracking ref made the remote look diverged — the push was clean; `git checkout -B feature/platform-alignment origin/main` after a fetch is the whole dance). Hooks are armed and behaved mechanically all session: journal-check passed on all three commits, the trellis gate consumed fresh stamps for the two command-file commits. Standing context for Phase 4: this session **dogfooded native task tracking ahead of Slice 15** (TaskCreate one task per slice at session start with blockedBy ordering, in_progress/completed at slice transitions) — the pattern worked and matches the spec'd design. Slice 14 also owns the SPEC phase-grouped template drift (trellis artifact validation currently fails SPEC.md on the missing `### Work Slices` heading — slices live under `## Phase N` groups). Slice 16 owns: resume's PAUSE-deletion mechanics + tool grant, the STATE.md parenthetical removal ("deletion mechanics land with resume's task-awareness update"), inquire's missing PAUSE consumption, and status wording. Slice 19 owns the CHANGELOG 0.4.0 entry for #59–#62 — note the Phase 3 verification finding: the 0.3.0 entry ("Skill Workflows in CLAUDE.md") is now stale, so the [Unreleased] entry must document the map's move to shared.md. Evolve candidates carried forward: rename "Available Tools & Agents" (this repo's shared.md + init's template — it now holds notes, not an inventory); coverage-check asymmetry; `gh pr checks` invisible to evolve; evolve's unconditional EVOLUTION.md staging. Retro items persisted here: a `.vine/scripts/`-style mechanical script for trellis's checks would make the stamp reproducible instead of session-interpreted (this session ran them as ad-hoc shell); the boundary rule's "same subject, different reader scope" distinction (Engineer Profile Protocol vs Engineer Profile) may deserve an example in the rule text if it confuses contributors.
