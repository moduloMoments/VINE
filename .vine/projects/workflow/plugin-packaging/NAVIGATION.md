# Navigation Journal: Claude Code Plugin Packaging

## Feature: .vine/projects/workflow/plugin-packaging
## Branch: feature/plugin-packaging
## Started: 2026-06-23

---

## Phase 1: Scaffold + Invocation Proof

### Slice 1: Plugin manifest, marketplace, and invocation spike — Complete
**Started**: 2026-06-23 00:13
**Commit**: 0d53055
**Gear**: walk-me-through
**Approach taken**: Stood up `.claude-plugin/plugin.json` (name `vine`, version `0.4.0`) and
`.claude-plugin/marketplace.json` (marketplace name `moduloMoments`, one plugin entry `vine`,
`source: "./"`). Converted `commands/vine/status.md` → `skills/status/SKILL.md` verbatim body,
revised frontmatter. Validated manifests with `claude plugin validate .` (pass), installed at
**local scope** (`claude plugin marketplace add ./ --scope local` + `claude plugin install
vine@moduloMoments --scope local`), and confirmed the installed snapshot carries the skill + all 4
agents and resolves version 0.4.0 from plugin.json.

Before writing, researched the exact plugin/skill schema two ways: (1) claude-code-guide agent
against current docs, (2) the installed GSD framework as a real-world commands→skills reference.
GSD inspection corrected a guide-agent claim (see Learnings) and shaped the frontmatter decision.

**Deviations from spec**:
  - SPEC Slice 1 said map frontmatter `name/description/argument-hint/allowed-tools`. We **omit
    `name`** instead — for a plugin skill at `skills/status/`, the `/vine:` namespace derives from
    plugin name + dir name, and an explicit `name: vine:status` risks double-namespacing. Kept
    `argument-hint` + `allowed-tools` (GSD evidence shows both are tolerated), added the spec'd
    `disable-model-invocation: true`. SPEC.md annotated.
  - SPEC said marketplace `source = github tracking the default branch, no ref`. For a plugin in
    the **same repo** as the marketplace, the correct schema is the relative `source: "./"` (a
    github-source object is for a plugin in a *different* repo). Same intent achieved: a user who
    runs `claude plugin marketplace add moduloMoments/VINE` clones the default branch (`main`) and
    resolves `"./"` within it — zero ref/sha management, no `version` in the entry (plugin.json
    wins). SPEC.md annotated.
**Validation**: pass — manifests pass `claude plugin validate .`; local install succeeds and
version 0.4.0 resolves; skill + 4 agents present in snapshot. **Colon-form gate confirmed by the
engineer** in an authenticated session: `/vine:status` resolves in COLON form (the worktree showed
two identical `vine:status` entries — the legacy command symlink + the new plugin skill — proving
the plugin's skill is colon, not hyphen; a hyphen failure would have read `vine-status`). The
duplicate is the documented "coexistence duplicates, doesn't collide" and clears in Slice 5 when the
command tree + symlink are removed. No-auto-fire holds (skill only appeared on explicit invocation;
`disable-model-invocation: true` set).
**Decisions made during implementation**:
  - Keep `argument-hint` + `allowed-tools` in SKILL.md; omit `name`: rationale above (decided by: engineer) [confidence: high]
  - Marketplace name `moduloMoments`, plugin name `vine` → install `vine@moduloMoments`: publisher-as-marketplace convention; plugin name locked to `vine` for the namespace (decided by: claude) [confidence: medium]
  - Verify via local-scope install (not global): isolates to this worktree's gitignored settings.local.json, reversible (decided by: claude) [confidence: high]
  - **Conversion recipe = verbatim body, frontmatter-only changes** (sets Slice 2 pattern): grounded in the canonical skill-creator guide — for `disable-model-invocation` skills the description-triggering pillar is moot, and VINE already does the progressive-disclosure pillar (commands point to STATE.md / shared.md). `<objective>` is GSD house style (all 64 of its `<objective>` skills auto-invoke; 0 disable it), not a canonical requirement. Restructuring would be cosmetic and would violate AC-1 "behavior identical" (decided by: engineer) [confidence: high]
**Acceptance criteria**:
  - [x] AC1 invocation colon form `/vine:status` — confirmed by engineer (two identical `vine:status` entries, not `vine-status`)
  - [x] AC2 no auto-fire — `disable-model-invocation: true` set; skill only ran on explicit invocation
  - [x] AC3 argument preserved — `$ARGUMENTS` carried over (frontmatter `argument-hint` retained)
  - [x] AC4 4 agents load via plugin — present in installed snapshot
**Engineer feedback incorporated**: Chose to keep both frontmatter fields after I surfaced GSD
evidence that disproved the "skills ignore allowed-tools" premise.
**Learnings**:
  - Engineer → Claude: Asked me to check how GSD handled the same commands→skills migration —
    GSD is the on-disk reference that corrected the docs-agent claim.
  - Claude → Engineer: (1) The claude-code-guide agent's "skills don't honor `allowed-tools`" was
    empirically false — 66/68 installed GSD skills carry it. Agent-diagnosis-unverified discipline
    paid off. (2) GSD installs as flat prefixed skills (`/gsd-help`, hyphen) — the colon form is a
    *plugin-namespace* property, not a `name`-field property; copying GSD's `name:` habit is the one
    thing that could break VINE's colon form. (3) A `directory`-source install is a snapshot copy
    into `~/.claude/plugins/cache/.../0.4.0/`; the dev loop is edit → `claude plugin marketplace
    update moduloMoments` (or `/reload-plugins`) to pick up changes.

### Discovered Items (not in scope — for evolve/triage)
  - **Whole-repo plugin payload**: `source: "./"` ships the *entire repo* in the plugin cache
    (commands/, .vine/, README, package.json, ROADMAP, …). Slice 5 removes commands//package.json/bin,
    but `.vine/`, `references/`, agents/, docs still ship. Consider a plugin file-allowlist /
    `.claudeignore` to slim the user-facing payload. Candidate backlog item.
  - **Automated invocation testing is blocked by auth**: nested `claude -p --plugin-dir … "/vine:…"`
    returns 401 (no inherited session credentials), so the colon-form gate can't be CI-automated this
    way. Relevant if a future cycle wants automated plugin smoke tests.
  - **Oversized skill bodies** (`init` ~38KB, `evolve` ~32KB, `navigate` ~30KB) exceed the skill-creator
    <500-line "ideal." Not a conversion blocker (kept verbatim per recipe decision), but a candidate
    trim — overlaps the existing optimize-scope per-phase context-trim backlog item. Route there, not
    into this packaging cycle.

---

## Phase 2: Convert the Product to Skills

### Slice 2: Convert the remaining 10 commands to skills — Complete
**Started**: 2026-06-23 06:05
**Commit**: 508ae18
**Gear**: free-climb
**Approach taken**: Applied the Slice 1 recipe to all 10 remaining commands (init, verify, inquire,
navigate, evolve, pair, pause, resume, help, optimize) → `skills/<name>/SKILL.md`. Per-file frontmatter
transform: drop `name:`, insert `disable-model-invocation: true` after `argument-hint` (matching
`status`'s field order), keep `description`/`argument-hint`/`allowed-tools` verbatim; body copied
byte-for-byte. Done with a deterministic awk frontmatter-rewrite rather than hand-copy — precisely
because AC-1 demands behavior-identical bodies and several are 30KB+, so transcription drift was the
only real risk and a script removes it.
**Deviations from spec**: None — recipe applied as designed; the schema deviations (drop `name`, add
the flag) were already recorded in Slice 1's SPEC addendum.
**Validation**: pass — (1) all 10 bodies diff byte-identical to their source commands
(697/373/342/574/640/151/104/212/65/475 lines); (2) frontmatter check across all 10 — `name:` absent,
exactly one `disable-model-invocation: true`, `argument-hint` preserved; (3) `claude plugin validate .`
passes; (4) local-scope reinstall refreshes the `0.4.0` snapshot, which now carries all 11 skills + 4
agents with the converted frontmatter intact.
**Decisions made during implementation**:
  - Deterministic awk conversion + body-diff proof instead of file-by-file hand edit: byte-identical bodies are an AC-1 correctness requirement, not a stylistic preference (decided by: engineer) [confidence: high]
  - Insert `disable-model-invocation` after `argument-hint` (status's field order) for consistency across all 11 skills (decided by: claude) [confidence: high]
**Acceptance criteria**:
  - [x] AC1 colon form `/vine:<name>` — structurally identical to `status` (plugin `vine` + skill dir name); the recipe was empirically proven colon in Slice 1; all 11 skills present in the installed snapshot. Final cross-skill colon re-confirm is the human-only gate (nested `claude -p` 401s — Slice 1 discovered item).
  - [x] AC2 no auto-fire — `disable-model-invocation: true` on all 10 (verified count)
  - [x] AC3 arguments preserved — `argument-hint` retained; `$ARGUMENTS` carried in the verbatim bodies
**Engineer feedback incorporated**: Chose free-climb for the mechanical 10x repeat, with the body-diff
proof standing in as the review surface.
**Learnings**:
  - Engineer → Claude: None new — Slice 1's recipe carried over directly.
  - Claude → Engineer: A local-scope marketplace (Slice 1's `--scope local`) is invisible to user-scope
    `claude plugin marketplace update <name>` ("marketplace not found"); the dev-loop refresh from a
    worktree is re-`marketplace add ./ --scope local` + reinstall, which re-syncs the directory-source
    snapshot. Refines the Slice 1 dev-loop note. **Update**: a *same-version* reinstall is a no-op
    ("already installed") and does NOT re-copy the snapshot — a forced refresh needs `uninstall` +
    `install`.

### Slice 3: Ship journal-check as a plugin hook (+ payload-slimming restructure) — Complete
**Started**: 2026-06-23 06:10
**Commit**: c679792
**Gear**: free-climb
**Approach taken**: Two parts. (1) **Journal-check as a plugin hook** — moved `journal-check.sh` out of
`.vine/scripts/` into the plugin's `hooks/`, wired via `hooks/hooks.json` (PreToolUse/Bash →
`sh "${CLAUDE_PLUGIN_ROOT}/hooks/journal-check.sh"`). Script logic unchanged (it keys off
`CLAUDE_PROJECT_DIR`, the user's project). Dropped journal-check from the contributor `.claude/settings.json`
(the plugin provides it now); `trellis-gate.sh` + `main-guard.sh` stay there, unshipped. (2) **Payload-slimming
restructure** (engineer pulled this into the slice) — research confirmed Claude Code has NO file-level payload
exclusion (no `.claudeignore`, no `files`/`exclude` field; verified against official docs); the only control is
which directory `source` points at. So moved the entire product into `plugins/vine/`
(`.claude-plugin/plugin.json`, `skills/`, `agents/`, `hooks/`) and set marketplace `source: "./plugins/vine"`.
This both adopts the documented `plugins/<name>/` convention and scopes the payload to product-only.
**Deviations from spec**:
  - **Plugin moved from repo root to `plugins/vine/`** (SPEC Slice 1 / AC11 assumed product at root, `source: "./"`).
    Forced by the payload-slimming decision + the no-file-exclusion finding; also lands us on the documented
    convention. SPEC annotated (Slice 3 addendum + AC11).
  - **`hooks/journal-check.sh` is the single home** (SPEC said "moved/copied from .vine/scripts/") — chose move,
    no drift, and dropped its `.claude/settings.json` entry. SPEC Slice 3 annotated.
  - **`.claude/agents` symlink repointed** to `../plugins/vine/agents` so contributor agent-loading survives
    the move; final symlink disposition belongs to Slice 5 (annotated there).
**Validation**: pass — `claude plugin validate .` passes; a forced reinstall yields a snapshot containing ONLY
`.claude-plugin/ + skills(11) + agents(4) + hooks(2)` — `.vine/`, `.claude/`, `commands/`, `bin/`, `docs/`,
`references/`, `package.json`, and `trellis-gate.sh`/`main-guard.sh` are all absent. journal-check resolves at
`${CLAUDE_PLUGIN_ROOT}/hooks/journal-check.sh` and fires correctly (stale → exit 2 BLOCK, current → exit 0
ALLOW, non-commit → 0).
**Decisions made during implementation**:
  - Move plugin into `plugins/vine/` for payload control (decided by: engineer, after research showed no file-level exclusion exists) [confidence: high]
  - Adopt the documented `plugins/<name>/` layout rather than a generic `plugin/` (decided by: claude, ratified by engineer's convention question) [confidence: high]
  - Repoint `.claude/agents` rather than delete it now — non-breaking; Slice 5 finalizes (decided by: claude) [confidence: medium]
**Acceptance criteria**:
  - [x] AC5 hook native — journal-check fires via `hooks/hooks.json` + `${CLAUDE_PLUGIN_ROOT}`; tested stale/current/non-commit against the installed snapshot. `trellis-gate.sh`/`main-guard.sh` now absent from the payload entirely (met in letter, not merely intent).
**Engineer feedback incorporated**: Engineer pulled payload-slimming into this slice, then chose the subdir
restructure once research showed it was the only viable mechanism, and asked whether we follow the GitHub
convention — confirmed the restructure adopts the documented `plugins/<name>/` layout.
**Learnings**:
  - Engineer → Claude: Pushed for *true* payload slimming (not accept-by-intent) and for convention alignment — both converged on the same subdir restructure.
  - Claude → Engineer: (1) Claude Code copies the `source` directory wholesale (minus `.git`) — NO `.claudeignore`/`files`/`exclude` exists; payload control is purely "scope the source dir." (2) A local *directory* source copies gitignored working files (`.vine/ACTIVE`, `settings.local.json`) into the cache, but a *github* source (production) clones — so only committed files ship; the personal-state leak is local-dev-only. (3) The `plugins/<name>/` layout is both the documented convention and the slimming mechanism — one move.

### Discovered Items — Slice 3 (for later slices / evolve)
  - **Slice 4 retarget**: `/trellis` + `trellis-gate.sh` must validate/watch `plugins/vine/skills/<name>/SKILL.md`
    (not root `skills/`). SPEC Slice 4 annotated.
  - **Slice 5 addition**: the `.claude/agents` symlink (repointed this slice) joins `.claude/commands/vine` in
    the symlink-cleanup list — agents now arrive via the plugin. SPEC Slice 5 annotated.
  - **Slice 8 (docs)**: skills reference `references/STATE.md` + `.vine/context/shared.md`, which are now outside
    the plugin payload (`plugins/vine/` only). For plugin users these were already cwd-relative pointers (a
    pre-existing Reference Legibility concern); the restructure just makes "not shipped" explicit. Docs should
    address how skills cite repo-internal contracts for plugin users. Routed to Slice 8.
  - **Supersedes the Slice-1 `.claudeignore` backlog note**: payload slimming is NOT achievable via an ignore
    file (none supported); the subdir restructure done here is the mechanism, and it resolves the Slice-1
    "whole-repo payload" item for the product payload.
  - **init Native Hook Scaffold is now obsolete for plugin users** (plugin ships the hook default-on) → folded
    into Slice 6 per engineer decision; SPEC Slice 6 annotated.
