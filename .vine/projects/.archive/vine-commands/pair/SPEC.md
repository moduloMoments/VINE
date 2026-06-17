# Feature Spec: vine:pair — Lightweight Mode
## Date: 2026-03-27
## Built on: CONTEXT.md (2026-03-27)
## Decisions made by: Rob

### Problem Statement

VINE's four-phase cycle (verify → inquire → navigate → evolve) is powerful but heavyweight for
small tasks — quick fixes, minor features, small refactors. Engineers need a way to get VINE's
guided implementation and narration benefits without the ceremony of artifacts, specs, and slices.

vine:pair is a lightweight, artifact-free command for pair-programming small changes.

### Approach

**A single command file** (`commands/vine/pair.md`) that compresses verify → navigate → evolve
into one session. No artifacts written to `.vine/projects/`. The command follows all existing
structural conventions (frontmatter, hooks, profile) so it integrates cleanly with trellis
validation and the hook system.

**Key architectural decisions:**

| Decision | Choice | Rationale |
|---|---|---|
| Artifacts | Zero — no CONTEXT.md, SPEC.md, etc. | Quick mode shouldn't produce ceremony files |
| Context gathering | Argument (file/description) + 1-hop neighbors | Targeted, 2-3 min max, not a broad scan |
| Profile handling | Load for narration depth, never prompt for domain | Domain registration is verify's job |
| Narration depth | One-liner per change, profile-adjusted | Brief "what + why" before each edit |
| Commit strategy | Single commit at end | Pair work is small enough for one commit |
| Approve-edits mode | Recommend but don't block | Reduces friction while encouraging review |
| Escape hatch | Suggest full cycle at retro if work grew | Natural place, doesn't interrupt flow |
| Allowed tools | Read, Glob, Grep, Write, Edit, Bash, Agent, AskUserQuestion | Consistent with other commands; Agent helps parallel reads |
| README placement | Separate section after the four phases | Keeps phase narrative clean, gives pair its own spotlight |
| Retro format | Same block as other phases + escape hatch | Consistent pattern across all commands |

### Acceptance Criteria

1. `commands/vine/pair.md` exists with valid YAML frontmatter (`name`, `description`, `argument-hint`, `allowed-tools`)
2. Passes all `/trellis` structural checks (hooks section references `pair.md`, hooks before profile, etc.)
3. Takes a file path or description as argument, reads the target + immediate imports/callers (1 hop)
4. Summarizes context and asks what the engineer wants to change via `AskUserQuestion`
5. Implements with one-liner narration per change; profile adjusts density (confident = minimal, learning = more)
6. Recommends approve-edits mode at session start without blocking on it
7. Produces a single commit at end with a suggested message the engineer approves
8. Shows retro block: CLAUDE.md suggestion + skill suggestion + user note + escape hatch to full cycle
9. Loads `shared.md` + `pair.md` hooks; loads engineer profile but never prompts for domain registration
10. README has a separate "Quick Mode" section after the four phases explaining vine:pair
11. CLAUDE.md, CONTRIBUTING.md, and `references/STATE.md` updated to reference vine:pair and artifact-free commands

### Work Slices

### Slice 1: Write pair.md command file
**Goal**: Create the core vine:pair command with full structural compliance and all behavioral logic
**Depends on**: Nothing
**Files likely touched**: `commands/vine/pair.md` (new file)
**Acceptance criteria**: AC 1, 2, 3, 4, 5, 6, 7, 8, 9
**Complexity signal**: Medium — new content but follows established patterns from existing commands

The command flow:
1. YAML frontmatter (name, description, argument-hint, allowed-tools)
2. Load Project Hooks section (shared.md + pair.md)
3. Load Engineer Profile section (read only, never prompt)
4. Recommend approve-edits mode (suggest, don't block)
5. Targeted context check: read argument file + 1-hop neighbors, summarize
6. Ask what the engineer wants to change (AskUserQuestion)
7. Implement with one-liner narration, profile-adjusted depth
8. Single commit: suggest message, engineer approves
9. Retro block: CLAUDE.md/skill/user suggestions + escape hatch

### Slice 2: Update documentation
**Goal**: Update all docs to reference vine:pair as the 6th command and explain artifact-free mode
**Depends on**: Slice 1 (need to know final command shape for accurate doc references)
**Files likely touched**: `README.md`, `CLAUDE.md`, `CONTRIBUTING.md`, `references/STATE.md`
**Acceptance criteria**: AC 10, 11
**Complexity signal**: Low — straightforward text updates across 4 files

Specific updates:
- **README.md**: Add "Quick Mode: vine:pair" section after the four phases section. Update any "5 commands" references.
- **CLAUDE.md**: Update Repository Structure section to list pair. Update command count references.
- **CONTRIBUTING.md**: Update the explicit command list.
- **references/STATE.md**: Add a note about commands that don't produce state artifacts.

### Slice 3: Validate with trellis
**Goal**: Run `/trellis` to confirm pair.md passes all 8 structural checks
**Depends on**: Slice 1
**Files likely touched**: None expected; possibly `pair.md` if trellis reveals issues
**Acceptance criteria**: AC 2 (full validation pass)
**Complexity signal**: Low — mechanical validation, may surface minor formatting fixes

### Tech Debt Integration

- **Address during (Slice 2)**: README, CLAUDE.md, CONTRIBUTING.md all hardcode "5 commands" — updated as part of doc slice
- **Address during (Slice 2)**: STATE.md has no guidance for artifact-free commands — add a note
- **No new debt**: vine:pair follows all existing conventions; no shortcuts needed

### Backlog Updates

- Consider: vine:init should scaffold `pair.md` hook file alongside other per-phase hooks
- Consider: Future README diagram update if the ASCII art grows to include pair as a sidebar mode

### Dependencies & Risks

- **Trellis compatibility**: pair.md must pass all structural checks. The hook reference to `pair.md` is the main thing to get right — trellis Check 4 requires it.
- **No external dependencies**: Pure markdown, no build, no runtime.
- **Risk: scope creep during implementation**: The command needs to stay genuinely lightweight. If the implementation guidance section grows to navigate-length, pair loses its reason to exist. Keep it compressed.
