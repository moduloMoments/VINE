# Feature Spec: vine:pause + vine:resume
## Date: 2026-03-27
## Built on: CONTEXT.md (2026-03-27)
## Decisions made by: Rob

### Problem Statement

When an engineer stops a VINE session mid-work (between phases, mid-navigate, or at any point), context is lost with the chat session. There's no explicit pause artifact, no way to capture why they stopped or what they were thinking, and no quick way to pick up where they left off. The artifact chain carries forward *what was done* but not *where they were* or *what's next*.

### Approach

Add two new dedicated commands — vine:pause and vine:resume — that create and consume a lightweight PAUSE.md artifact in the feature directory. Keep it minimal: lean on existing artifacts (NAVIGATION.md, SPEC.md) for the heavy context, and use PAUSE.md only for session-specific state that isn't captured elsewhere.

**Key decisions and rationale:**

1. **Dedicated commands over integrated prompts** — Cleaner separation of concerns. vine:pause is explicit and works from any phase. Avoids adding complexity to every existing command.

2. **Show status + recommend, don't auto-launch** — Resume displays where you are and suggests the next command. The engineer launches it themselves after `/clear`. This keeps resume read-only and respects the VINE principle that the engineer decides.

3. **Minimal PAUSE.md** — Current phase, active slice (if navigate), timestamp, free-form notes. No session context snapshots. Existing artifacts carry the detailed state; PAUSE.md captures only what they don't.

4. **No hook files** — Pause and resume are simple enough that per-project customization adds complexity without clear value. Can be added later if demand emerges.

5. **Auto-cleanup on resolve** — Evolve silently deletes PAUSE.md when writing `.resolved`. A resolved project's pause state is definitionally stale.

6. **Fix navigate's Remaining Work section** — Navigate currently never writes the "Remaining Work" section defined in STATE.md's NAVIGATION.md template. Fixing this as part of this feature makes resume's job easier and makes navigate more complete.

### Acceptance Criteria

1. `commands/vine/pause.md` exists with valid YAML frontmatter, Load Project Hooks, Load Engineer Profile, and passes `/trellis`
2. `commands/vine/resume.md` exists with same structural compliance
3. `references/STATE.md` includes PAUSE.md artifact template and lifecycle description
4. vine:pause detects current phase from artifacts, asks for free-form notes via AskUserQuestion, and writes PAUSE.md to the active feature directory
5. vine:resume reads PAUSE.md + existing artifacts, displays a status summary, and recommends the next command without launching it
6. vine:navigate writes a "Remaining Work" section to NAVIGATION.md when a session ends (all slices done or engineer pauses)
7. vine:evolve silently deletes PAUSE.md (if present) when writing `.resolved`
8. All documentation updated: CLAUDE.md, README.md, .vine/hooks/shared.md, .vine/hooks/verify.md reflect 8 commands
9. `/trellis` passes on both new command files

### Work Slices

#### Slice 1: PAUSE.md artifact format in STATE.md
- **Goal**: Define the PAUSE.md artifact template in `references/STATE.md`
- **Depends on**: Nothing
- **Files likely touched**: `references/STATE.md`
- **Acceptance criteria**: STATE.md includes a PAUSE.md section between EVOLUTION.md and Per-Repo Artifacts, with template (phase, active slice, timestamp, notes) and lifecycle notes
- **Complexity signal**: Low — adding a template section to an existing reference doc

#### Slice 2: vine:pause command
- **Goal**: Create the pause command that writes PAUSE.md to the active feature directory
- **Depends on**: Slice 1 (PAUSE.md format)
- **Files likely touched**: `commands/vine/pause.md`
- **Acceptance criteria**: Valid frontmatter (allowed-tools: Read, Glob, Grep, Write, AskUserQuestion), Load Project Hooks + Load Engineer Profile sections, scans for active feature (same filtering as inquire/navigate/evolve), detects current phase from artifact presence, asks for free-form notes, writes PAUSE.md matching STATE.md template, completion block with resume suggestion
- **Complexity signal**: Medium — new command file following established patterns

#### Slice 3: vine:resume command
- **Goal**: Create the resume command that reads PAUSE.md + artifacts and recommends next steps
- **Depends on**: Slice 1 (PAUSE.md format)
- **Files likely touched**: `commands/vine/resume.md`
- **Acceptance criteria**: Valid frontmatter (allowed-tools: Read, Glob, Grep, AskUserQuestion), Load Project Hooks + Load Engineer Profile sections, reads PAUSE.md and existing artifacts, displays status summary (phase, slice progress, engineer notes, time since pause), recommends next command, does not auto-launch, handles missing PAUSE.md gracefully (falls back to artifact-only detection)
- **Complexity signal**: Medium — read-only analysis command with detection logic

#### Slice 4: Navigate "Remaining Work" fix
- **Goal**: Add instructions to navigate to write the "Remaining Work" section when a session ends
- **Depends on**: Nothing
- **Files likely touched**: `commands/vine/navigate.md`
- **Acceptance criteria**: Navigate writes "Remaining Work" to NAVIGATION.md with incomplete slices, blockers, and handoff context — both when all slices are done and when the engineer pauses mid-session
- **Complexity signal**: Low — small addition to existing command's completion logic

#### Slice 5: Evolve PAUSE.md cleanup
- **Goal**: Add silent PAUSE.md deletion to evolve's resolve flow
- **Depends on**: Slice 1 (PAUSE.md format knowledge)
- **Files likely touched**: `commands/vine/evolve.md`
- **Acceptance criteria**: When evolve writes `.resolved`, it also deletes PAUSE.md if present in the feature directory. No prompt, no message to the engineer.
- **Complexity signal**: Low — small addition to existing resolve logic

#### Slice 6: Documentation updates
- **Goal**: Update all docs to reflect 8 commands
- **Depends on**: Slices 2-3 (final command names/descriptions)
- **Files likely touched**: `CLAUDE.md`, `README.md`, `.vine/hooks/shared.md`, `.vine/hooks/verify.md`
- **Acceptance criteria**: All "6 command" references become "8 commands", command lists include pause and resume with descriptions, README includes pause/resume in the command table and any relevant examples
- **Complexity signal**: Low — mechanical updates across known locations

### Tech Debt Integration

- **Address now**: Navigate's missing "Remaining Work" section (Slice 4). Directly in the critical path — resume reads this data.
- **Defer**: No explicit state machine for phase detection. Each command re-implements artifact scanning. Pause and resume add two more consumers of this pattern, but formalizing it is a larger refactor that doesn't block this feature. Worth noting as backlog.
- **New debt accepted**: None — this feature follows existing patterns without introducing new shortcuts.

### Backlog Updates

- **Add**: "Formalize phase detection into a shared pattern" — 6 commands (soon 8) all implement the same scan-filter-select logic independently. Not urgent but growing.
- **Add**: "Cross-feature dashboard" — CONTEXT.md noted the lack of a status view across all active VINE work. Resume was scoped to single-feature focus, but a `/vine:status` command could fill this gap later.

### Dependencies & Risks

- **No external dependencies** — pure markdown, no build step
- **Trellis compliance** — both new commands must pass `/trellis`. Low risk since the pattern is well-established.
- **Documentation surface area** — 4 files need updating (CLAUDE.md, README.md, shared.md, verify.md). The command addition checklist in shared.md tracks this, so risk of missing one is low.
- **Navigate modification** — Slice 4 edits a core command. Keep the change minimal and test by running navigate on a real feature.
