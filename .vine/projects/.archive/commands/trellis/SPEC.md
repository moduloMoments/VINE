# Feature Spec: vine:trellis — Command Structure Validation
## Date: 2026-03-27
## Built on: CONTEXT.md (2026-03-27)
## Decisions made by: Rob

### Problem Statement

VINE's 5 command files follow structural conventions (YAML frontmatter, hook loading, profile loading, H1 titles) documented in CLAUDE.md but enforced nowhere. Cross-command changes can drift silently. vine:trellis gives contributors a fast structural validation check.

### Approach

A new command file `commands/vine/trellis.md` that reads all command files in `commands/vine/`, parses their structure, and validates against known conventions. It follows the same command structure it validates (frontmatter, H1 title) — eating its own cooking — but skips hook/profile loading since it's VINE-repo-only.

**Key decisions:**
- **Known tool list**: Derived by union of all `allowed-tools` across existing commands. A tool is valid if any command uses it. No external config needed.
- **Output format**: Summary table with commands as rows, checks as columns, ✅/❌ marks. Quick to scan.
- **Init exceptions**: Hard-coded. Init is the only command that skips hooks and profile loading — no abstraction needed for a single case.
- **Self-conforming**: Trellis has proper frontmatter and H1, validates itself in the run.
- **Scope**: Command files only. STATE.md validation deferred.
- **Pure validation**: No contributor guidance in output. CONTRIBUTING.md can reference trellis separately.

### Acceptance Criteria

1. `commands/vine/trellis.md` exists with valid YAML frontmatter (`name`, `description`, `argument-hint`, `allowed-tools`)
2. Reads all `.md` files in `commands/vine/` and validates each
3. **Frontmatter checks**: All 4 required fields present; `name` matches `vine:<filename-without-extension>`
4. **H1 check**: First H1 follows `# vine:<name> — <Subtitle>` pattern
5. **Hook section check** (non-init only): `## Load Project Hooks` section exists and references `.vine/hooks/<phase>.md`
6. **Profile section check** (non-init only): `## Load Engineer Profile` section exists
7. **Tool list check**: Every entry in `allowed-tools` is in the union of known tools across all commands
8. **AskUserQuestion check**: The string `AskUserQuestion` appears in the command body (below frontmatter)
8b. ~~Not in original spec~~ **Section ordering check** (non-init/trellis): hooks heading appears before profile heading. Added during navigate — enforces documented CLAUDE.md convention.
9. **Output**: Summary table with commands as rows, checks as columns, ✅/❌ marks
10. **Summary line**: Clear pass/fail at the end (e.g., "6/6 commands pass all checks" or "2 issues found in 1 command")
11. Init is hard-coded as exception for checks 5 and 6
12. Trellis validates itself as part of the run

### Work Slices

### Slice 1: Scaffold + Frontmatter Validation
**Goal**: Create the command file and implement frontmatter parsing/validation
**Depends on**: Nothing
**Files likely touched**: `commands/vine/trellis.md` (new)
**Acceptance criteria**: AC 1, 2, 3
**Complexity signal**: Medium — YAML parsing via text patterns in instructional markdown

### Slice 2: Structural Checks
**Goal**: Validate H1, hook section, profile section, tool list, AskUserQuestion reference
**Depends on**: Slice 1 (command exists with frontmatter loop)
**Files likely touched**: `commands/vine/trellis.md`
**Acceptance criteria**: AC 4, 5, 6, 7, 8, 11
**Complexity signal**: Medium — multiple pattern checks, init exception logic

### Slice 3: Output Table + Self-Validation
**Goal**: Format results as summary table with pass/fail summary line
**Depends on**: Slice 2 (all checks implemented)
**Files likely touched**: `commands/vine/trellis.md`
**Acceptance criteria**: AC 9, 10, 12
**Complexity signal**: Low — formatting and presentation

### Tech Debt Integration

- **Address now**: "No enforcement of conventions" — trellis IS the fix
- **Defer**: "No contributor tooling" — CONTRIBUTING.md update is a separate concern; can reference trellis later
- **Defer**: STATE.md validation — out of scope for v1

### Backlog Updates

- **New**: Update CONTRIBUTING.md to mention `vine:trellis` as a pre-PR check (after trellis ships)
- **New**: Consider adding STATE.md structural validation as a future trellis enhancement
- **Update**: Issue #4 (vine:dogfood) should reference vine:trellis naming
- **New**: Consider CLAUDE.md update to list valid tool names explicitly (trellis derives them, but documenting is nice)

### Dependencies & Risks

- **No external dependencies.** Pure markdown, reads files in the same repo.
- **Risk: Pattern matching fragility.** Trellis checks for text patterns in instructional markdown. If command structure evolves, trellis checks need updating. Mitigated by trellis validating itself — structural drift will show up immediately.
- **Risk: False positives on H1 pattern.** The `# vine:<name> — <Subtitle>` pattern needs to tolerate subtitle variations. Keep the regex loose on the subtitle side.
