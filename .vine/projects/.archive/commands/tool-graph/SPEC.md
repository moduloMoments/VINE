# Feature Spec: Tool Graph
## Date: 2026-04-06
## Built on: CONTEXT.md (2026-04-06)
## Decisions made by: Rob Bruhn

### Problem Statement

VINE commands have no structured relationship metadata — cross-references are implicit in prose. Claude Code already has two discovery mechanisms (ToolSearch for deferred tool loading, description-based skill matching), but VINE doesn't optimize for either. Command descriptions weren't written for Claude's ~250 char matching window. No routing context exists to help Claude suggest the right command at the right time.

`vine:graph` audits and optimizes VINE's tool discovery layer. It adds structured relationship metadata, generates a routing-context artifact, and improves the descriptions that feed into Claude's built-in skill matching. No custom hooks, no runtime scripts — pure markdown, optimizing existing mechanisms.

### Approach

**Relationship frontmatter**: Extend all command files with a `relationships` field in YAML frontmatter. This is the authoritative source for tool relationships. Five relationship types:

| Type | Meaning | Example |
|------|---------|---------|
| `consumes` | Reads another command's output artifact | inquire consumes verify's CONTEXT.md |
| `produces-for` | Its output feeds another command | verify produces-for inquire |
| `suggests` | Recommends running another command | evolve suggests vine:graph |
| `switches-to` | Lateral context switch mid-session | verify switches-to pair |
| `extends` | One command augments another's capability | init extends via vine:graph |

Frontmatter format:
```yaml
relationships:
  - target: vine:verify
    type: consumes
  - target: vine:navigate
    type: produces-for
```

Unknown frontmatter fields are ignored by Claude Code — no impact on non-VINE users.

**TOOL-GRAPH.md artifact**: Generated to `.vine/TOOL-GRAPH.md`. Contains tool inventory, Mermaid relationship diagram, and relationship table. Designed as routing context — shared.md references it so every VINE session has relationship awareness.

**Description quality analysis**: vine:graph evaluates each command's `description` field against Claude's skill matching constraints (~250 chars, keyword density, action-verb clarity). Reports weak descriptions and offers to apply improvements with engineer approval.

**Context injection via shared.md**: Rather than adding boilerplate to every command or building custom hooks, vine:graph updates shared.md to include a "Load Tool Graph" instruction. Since every command already loads shared.md, this gives every session graph-informed routing context through the existing hook system.

### Key Decisions

1. **Optimize existing mechanisms over building parallel systems** — Claude Code already has ToolSearch and description-based skill matching. vine:graph improves the data these mechanisms consume rather than building custom hook scripts or a separate discovery layer.
2. **Relationship frontmatter over prose scanning** — One-time cost to update 13 files, but every future graph generation is deterministic and unambiguous. Prose scanning is noisy and interpretive.
3. **`.vine/TOOL-GRAPH.md` location** — `.vine/` becomes the repo's tool intelligence layer. Teams track hooks + graph while gitignoring personal project state.
4. **Report + offer to apply for descriptions** — vine:graph shows proposed description changes and asks permission before editing command files. Non-destructive by default.
5. **Shared.md as the context injection point** — Every command already loads shared.md. Adding a TOOL-GRAPH.md reference there gives universal routing context without per-command boilerplate.
6. **Workflows deferred** — Not an optimization of existing mechanisms. Deserves its own design cycle.
7. **Auto-suggestion hooks deferred** — The "optimize descriptions + routing context" approach may be sufficient. If not, hooks build on this foundation in a follow-up cycle.

### Acceptance Criteria

1. `vine:graph` command exists in `commands/vine/graph.md` with valid YAML frontmatter (name, description, argument-hint, allowed-tools, relationships)
2. All 13 existing command files (10 VINE + 3 contributor) have a `relationships` field in frontmatter with accurate type/target pairs using the five defined types
3. Running `vine:graph` produces `.vine/TOOL-GRAPH.md` containing:
   - Tool Inventory table (name, type, source, description, allowed-tools)
   - Mermaid relationship diagram showing all declared relationships
   - Relationship table (from, to, type, description)
   - Generated-at metadata (date, repo path)
4. vine:graph produces a description quality report evaluating each command's description against skill matching effectiveness
5. vine:graph offers to apply improved descriptions with engineer approval (via AskUserQuestion)
6. On repos without `.vine/`, vine:graph directs the user to run vine:init first
7. `references/STATE.md` has a TOOL-GRAPH.md section with template, lifecycle, and design constraints
8. `commands/vine/init.md` calls vine:graph as a step after hook setup
9. `commands/vine/evolve.md` suggests running vine:graph after suggesting new commands/skills
10. vine:graph updates `.vine/hooks/shared.md` to include a "Load Tool Graph" instruction referencing `.vine/TOOL-GRAPH.md`
11. CLAUDE.md, README.md, `.vine/hooks/shared.md` updated to reflect 11 commands
12. `/trellis` passes on all modified command files

### Work Slices

### Slice 1: Define TOOL-GRAPH.md format and relationship spec in STATE.md
**Goal**: Establish the artifact contract and relationship type definitions before building the command
**Depends on**: Nothing
**Files likely touched**: `references/STATE.md`
**Acceptance criteria**: STATE.md has a TOOL-GRAPH.md section with full template, relationship type definitions, lifecycle description, and design constraints. Uses `<!-- required -->` / `<!-- optional -->` markers on section headings.
**Complexity signal**: Low — adding a section to an existing reference doc

### Slice 2: Add relationship frontmatter to all commands
**Goal**: Give every command structured relationship metadata
**Depends on**: Slice 1 (relationship types defined in STATE.md)
**Files likely touched**: All 13 files in `commands/vine/` and `.claude/commands/`
**Acceptance criteria**: Each command has a `relationships` field with accurate type/target pairs using the five defined types (consumes, produces-for, suggests, switches-to, extends). Every command relates to at least one other. Relationships are bidirectional where applicable (if A produces-for B, B consumes A).
**Complexity signal**: Medium — 13 files, need to map all relationships correctly across the full command graph

### Slice 3: Build vine:graph core — discovery and TOOL-GRAPH.md generation
**Goal**: The core command that discovers tools, parses frontmatter, and generates the graph artifact
**Depends on**: Slice 1 (artifact format), Slice 2 (frontmatter to read)
**Files likely touched**: `commands/vine/graph.md` (new file)
**Acceptance criteria**: Command follows VINE structural conventions (frontmatter, hook loading, profile loading). Scans `.claude/commands/`, `.claude/skills/`, and settings files for MCP servers. Parses YAML frontmatter including relationships. Generates `.vine/TOOL-GRAPH.md` matching the STATE.md contract with all three sections (inventory, Mermaid diagram, relationship table). Handles non-VINE repos by directing to init. Works on this repo as a smoke test.
**Complexity signal**: High — largest slice, core discovery and generation logic

### Slice 4: Description quality analyzer
**Goal**: Evaluate command descriptions against Claude's skill matching and offer improvements
**Depends on**: Slice 3 (runs as part of vine:graph)
**Files likely touched**: `commands/vine/graph.md` (extend with analysis section)
**Acceptance criteria**: vine:graph evaluates each command's description for: length vs. ~250 char matching window, keyword density for intent matching, action-verb clarity, uniqueness across commands. Produces a quality report. Uses AskUserQuestion to offer applying improved descriptions — engineer approves each change individually. Does not edit files without approval.
**Complexity signal**: Medium — analysis logic plus interactive approval flow

### Slice 5: Integrate with init, evolve, and shared.md
**Goal**: Wire vine:graph into the VINE lifecycle and enable routing context in every session
**Depends on**: Slice 3 (command exists), Slice 4 (complete command)
**Files likely touched**: `commands/vine/init.md`, `commands/vine/evolve.md`, `.vine/hooks/shared.md`
**Acceptance criteria**: Init has a step that calls vine:graph after hook setup. Evolve suggests running vine:graph when it recommends new commands or skills. shared.md includes a "Load Tool Graph" section that instructs commands to read `.vine/TOOL-GRAPH.md` for routing context.
**Complexity signal**: Low — adding steps to existing command prose and a section to shared.md

### Slice 6: Documentation and checklist updates
**Goal**: Update all tracking documents for the 11th command
**Depends on**: Slices 3-5 (command and integrations finalized)
**Files likely touched**: `CLAUDE.md`, `README.md`, `.vine/hooks/shared.md`
**Acceptance criteria**: All references to command count say 11. vine:graph appears in command lists with accurate description. Command addition checklist from shared.md is fully satisfied. `/trellis` passes on all modified files.
**Complexity signal**: Low — mechanical updates across known files

### Tech Debt Integration

- **Init's unstructured discovery** — Address during (Slice 5): graph gives init a structured source. Init's Step 1 can reference TOOL-GRAPH.md rather than doing its own ad-hoc scan.
- **Help's hardcoded command list** — Defer: could reference TOOL-GRAPH.md later, but adding that dependency now complicates this cycle. Backlog item.
- **Shared.md duplicates discoverable info** — Partially address (Slice 5): shared.md gains a reference to TOOL-GRAPH.md. The manually-maintained command list in shared.md remains for now but the graph provides the structured complement.

### Dependencies & Risks

- **Trellis validation**: Adding a `relationships` field to frontmatter may require trellis updates if it validates frontmatter strictly. Check trellis before Slice 2.
- **Command count cascade**: The command addition checklist touches 4+ files. Missing one creates inconsistency. Slice 6 handles this systematically.
- **Self-referential edge case**: vine:graph describes commands including itself. The relationships frontmatter in graph.md must accurately declare its own relationships without circular generation issues.
- **Description changes need care**: Skill descriptions are the primary matching surface for Claude's auto-invocation. Improving them is high-value but wrong changes could break existing matching patterns. The report-and-approve flow mitigates this.

### Backlog Updates

- **Follow-up: Auto-suggestion hooks** — If optimized descriptions + routing context aren't sufficient for auto-suggestion, UserPromptSubmit hooks can be layered on top. The graph artifact is the data layer they'd query.
- **Follow-up: Workflow templates** — Structured multi-step recipes. Not an optimization of existing mechanisms — needs its own design cycle.
- **Follow-up: Context-aware vine:help** — Help reads TOOL-GRAPH.md + current project state to suggest commands based on where the user is in their workflow. Replaces hardcoded command list.
- **Follow-up: Graph-informed evolve** — Evolve reads the graph to make more targeted suggestions about new skills, hook updates, and command improvements.
