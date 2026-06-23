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
**Commit**: pending
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
    snapshot. Refines the Slice 1 dev-loop note.
