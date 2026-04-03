# Feature Context: vine:trellis — Command Structure Validation
## Date: 2026-03-27
## Author: Rob + Claude

### Codebase Landscape

**The product is 5 markdown command files** in `commands/vine/` plus `references/STATE.md`. There is no build step, no runtime code. Editing a command file changes the tool itself.

**Command files:**
- `init.md` — Project setup (intentional exception: no hook/profile loading)
- `verify.md` — Context-building spike
- `inquire.md` — Feature specification
- `navigate.md` — Guided implementation
- `evolve.md` — Triple evolution

**Structural patterns shared across commands:**

| Pattern | init | verify | inquire | navigate | evolve |
|---------|------|--------|---------|----------|--------|
| YAML frontmatter (name, description, argument-hint, allowed-tools) | yes | yes | yes | yes | yes |
| H1 title: `# vine:<name> — <subtitle>` | yes | yes | yes | yes | yes |
| Load Project Hooks section | **no** | yes | yes | yes | yes |
| Load Engineer Profile section | **no** | yes | yes | yes | yes |
| AskUserQuestion referenced | yes | yes | yes | yes | yes |

**Key structural rules:**
1. YAML frontmatter must be present and contain exactly: `name`, `description`, `argument-hint`, `allowed-tools`
2. `name` must match `vine:<phase-name>` and be consistent with the filename
3. `allowed-tools` must be a list of valid Claude Code tool names
4. H1 title must follow `# vine:<name> — <Subtitle>` pattern
5. Non-init commands must have a `## Load Project Hooks` section referencing `.vine/hooks/<phase>.md`
6. Non-init commands must have a `## Load Engineer Profile` section
7. All commands should reference `AskUserQuestion` (it's the preferred interaction pattern)

**Valid tool names observed across commands:**
Read, Glob, Grep, Write, Edit, Bash, Agent, WebFetch, AskUserQuestion

### Current State

- No CI/CD pipeline — validation is entirely manual
- Testing = running commands on real repos
- No structural validation exists today
- CLAUDE.md documents conventions but nothing enforces them
- The engineer profile feature was just added across all 4 non-init commands, demonstrating how cross-command changes can drift

### Edge Cases & Tribal Knowledge

- **init is the intentional exception.** It doesn't load hooks or profiles because it creates them. Any validation rule about "all commands must have X" needs an init escape hatch.
- **Commands are instructional markdown, not executable code.** "AskUserQuestion referenced" means the text describes using it, not that it's called programmatically. Validation is about text patterns, not AST parsing.
- **Hook section references a phase-specific file.** The hook loading section in each command references `.vine/hooks/<phase>.md` where `<phase>` matches the command name. This must be consistent.
- **Profile loading varies by phase.** verify prompts to add new domains, inquire/navigate silently skip missing profiles, evolve offers to create/update. The structure is similar but the behavior described differs.

### Tech Debt in Affected Areas

- **No enforcement of conventions.** CLAUDE.md says what to do; nothing checks compliance. vine:trellis fills this gap.
- **No contributor tooling.** CONTRIBUTING.md asks contributors to "test the commands in an actual VINE cycle" but provides no quick structural check. Trellis gives a fast feedback loop.

### Documentation Gaps

- CLAUDE.md lists command authoring conventions but doesn't enumerate valid tool names or the exact frontmatter schema
- README doesn't mention contributor tooling (appropriate — trellis is VINE-repo-only)
- Issue #4 (vine:dogfood) should be updated to reflect the vine:trellis naming

### Open Questions

1. **Should trellis validate allowed-tools against a known list, or just check that it's a non-empty list?** A known list is more useful but requires maintenance. Could derive the list from existing commands as a baseline.
2. **Should trellis follow the same command structure it validates?** (YAML frontmatter, H1 title, etc.) — Eating your own cooking. Likely yes, but it won't have hook/profile loading since it's VINE-repo-only.
3. **Output format:** Pass/fail checklist per command? Summary table? Both?
4. **Scope of init's exceptions:** Should trellis hard-code "init is special" or should there be a way for commands to declare themselves as exceptions?
5. **Should trellis also validate references/STATE.md structure?** Could check that artifact format definitions match what commands describe. Deferred for v1 — start with command files only.
