# Feature Context: Tool Graph
## Date: 2026-04-06
## Author: Rob Bruhn + Claude

### Codebase Landscape

**Commands (the primary graph unit):**
- 10 VINE command files in `commands/vine/` with consistent YAML frontmatter: `name`, `description`, `argument-hint`, `allowed-tools`
- 3 contributor tools in `.claude/commands/`: trellis, triage, pr
- Commands reference each other extensively in prose but have no structured relationship metadata
- `allowed-tools` field is the only structured relationship data — which tools a command can use

**Existing relationship patterns already in the codebase:**
- Phase sequence: verify -> inquire -> navigate -> evolve (artifact chain via CONTEXT.md -> SPEC.md -> NAVIGATION.md -> EVOLUTION.md)
- Lateral: verify <-> pair (scope switch), navigate <-> pause, pause <-> resume
- Hub commands: help/status/init connect to everything
- Cross-references are implicit — commands mention other commands in their prose, not structured metadata

**Skills and MCP servers:**
- `.claude/skills/` is referenced by init's discovery but no skill files exist in this repo
- `.claude/settings.json` / `.claude/settings.local.json` can define MCP servers providing additional tools
- Skills use the same .md + YAML frontmatter pattern as commands

**Installation path:**
- `bin/cli.js` copies command .md files to `.claude/commands/vine/` (local) or `~/.claude/commands/vine/` (global)
- Only copies files — no graph generation at install time
- Upgrade path suggests running `/vine:init` to discover new tools

**Hook system:**
- `.vine/hooks/shared.md` loaded by all phases — contains command inventory, conventions, CI/CD
- Per-phase hooks (verify.md, navigate.md, evolve.md, pair.md) add phase-specific instructions
- Hooks are prose instructions, not structured data — the graph would provide the structured layer hooks draw from

### Current State

- Init's Step 1 (Discover Repo Capabilities) scans `.claude/commands/`, `.claude/skills/`, settings files, but persists findings only as prose in shared.md
- Help hardcodes the command list as a text block — no dynamic generation from structured data
- Evolve's Evolution 2 suggests skills, hook updates, and workflow improvements but without graph-informed context
- No mechanism exists to discover relationships between commands across repos — each init starts from scratch

### Edge Cases & Tribal Knowledge

- **VINE IS the product.** Editing a command file changes the tool itself. `vine:graph` will be a command that describes other commands — including potentially itself. Self-referential edge case.
- **Global vs local installs.** Commands can live in `~/.claude/commands/vine/` (global) or `.claude/commands/vine/` (local). Graph generation needs to handle both, plus non-VINE commands in `.claude/commands/`.
- **Command addition checklist.** Adding an 11th command requires updates to: CLAUDE.md (command count + list), README.md (command references), shared.md (command list), verify.md hook (command count reference). This is documented in shared.md hooks.
- **Pure markdown philosophy.** No build step, no runtime code. The issue proposed YAML workflow files but we've decided on markdown templates to stay consistent.
- **"Enhances any repo even if VINE were removed."** The standalone artifact (`.claude/TOOL-GRAPH.md`) must be useful for any Claude Code user. VINE-specific outputs (`.vine/workflows/`, hook suggestions) are the value-add layer.

### Tech Debt in Affected Areas

- **Init's discovery is unstructured.** Step 1 scans for capabilities but has no intermediate structured representation. Graph generation would benefit from a structured discovery pass that both the graph and hook generation can consume.
- **Help's hardcoded command list.** Could reference TOOL-GRAPH.md instead of maintaining a separate list, but this creates a dependency on the graph existing.
- **Shared.md duplicates discoverable info.** The "Available Tools & Agents" section in shared.md is essentially a manually-maintained version of what the graph would auto-generate.

### Documentation Gaps

- No documentation for `.claude/skills/` format — VINE references it in init but doesn't define the convention (Claude Code defines it)
- README doesn't mention command relationships or discoverability beyond the linear phase chain
- `references/STATE.md` would need a section for TOOL-GRAPH.md if it becomes a managed artifact
- No documentation for workflow templates (new concept with this feature)

### Open Questions

1. **TOOL-GRAPH.md format**: What sections should it contain? Mermaid diagram + relationship table + inventory is the starting point, but what else makes it "standalone useful"?
2. **Workflow template format**: Markdown files in `.vine/workflows/` — what frontmatter fields? How does a workflow reference steps that are commands vs manual actions?
3. **Init integration depth**: Does init just call `vine:graph` as a subprocess, or does it inline the graph logic? The former is cleaner but adds a dependency between commands.
4. **Evolve integration**: Should evolve automatically re-run graph generation after suggesting new skills/commands, or just suggest running `vine:graph`?
5. **Non-VINE repos**: When `vine:graph` runs on a repo without `.vine/`, should it still produce TOOL-GRAPH.md? (Yes — that's the standalone value prop. But should it also offer to create `.vine/workflows/`?)
6. **Graph staleness**: TOOL-GRAPH.md is a generated artifact. When commands change, the graph goes stale. Should there be a staleness check? Or is "run vine:graph to update" sufficient?
7. **Scope for this cycle**: The issue includes auto-suggestion hooks (UserPromptSubmit). Is that in scope or a follow-up? It's the most complex piece and may warrant its own cycle.
