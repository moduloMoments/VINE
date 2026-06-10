---
name: vine:optimize
description: "Audit and improve command discoverability — score descriptions for skill matching, detect workflow chains, reduce token waste, and optimize interactivity patterns"
argument-hint: ""
allowed-tools:
  - Read
  - Glob
  - Grep
  - Edit
  - Write
  - Bash
  - Agent
  - AskUserQuestion
---

# vine:optimize — Skill & Workflow Optimizer

## Load Context Overlays

Before starting, check for project-level VINE context overlays:

1. Read `.vine/context/shared.md` if it exists — repo-wide context for all VINE phases.
2. Read `.vine/context/optimize.md` if it exists — optimize-specific extensions for this project
   (custom discovery paths, description conventions, workflow patterns to enforce).
3. Apply the contents of both as additional instructions layered on top of this command. Overlay
   instructions take precedence over defaults when they conflict.

If `.vine/context/` doesn't exist but legacy `.vine/hooks/` does, read the same files from
`.vine/hooks/` instead and nudge once per session, no more: "Heads up: this project uses the
legacy `.vine/hooks/` directory — run `/vine:init` to migrate to `.vine/context/`."

If neither file exists, proceed normally. If `.vine/` doesn't exist at all, suggest `/vine:init`.

## Load Engineer Profile

Follow the Engineer Profile Protocol and Collaboration Stance from `.vine/context/shared.md`.

## What This Does

vine:optimize audits and improves how Claude Code discovers and chains the skills, commands,
and tools available in a repository. It works with the mechanisms Claude already has — skill
description matching, CLAUDE.md context loading, and command prose — rather than building
parallel systems.

Three phases:
1. **Discover** — Scan for all commands, skills, agents, and MCP servers
2. **Analyze** — Score descriptions, detect chains, identify workflow patterns
3. **Apply** — Improve descriptions, write the workflow map to shared.md, verify CLAUDE.md's
   pointer, add chain links to prose

Knowledge placement follows the Knowledge Boundary rule in `references/STATE.md`: the
workflow map is VINE routing knowledge, so it lives in `.vine/context/shared.md`; CLAUDE.md
carries only an availability-gated pointer; the command/agent inventory lives in the
harness's native skill list, never in files.

## Phase 1: Discover

Scan the repo for everything Claude can invoke or reference. Build a complete inventory.

### 1a. Commands and Skills

Scan these locations for `.md` files with YAML frontmatter:

- `.claude/commands/` and all subdirectories (slash commands)
- `~/.claude/commands/` (global commands — note which are global vs local)
- `.claude/skills/` and all subdirectories (auto-matched skills)

For each file found, extract:
- `name` — the invocable name
- `description` — the matching surface for Claude's skill discovery
- `allowed-tools` — what the command can do (shapes capability analysis)
- `argument-hint` — what input it expects
- Any mentions of other commands in the prose (e.g., "suggest running `/vine:evolve`")
- Any file artifacts it produces or consumes (e.g., "writes CONTEXT.md", "reads SPEC.md")

### 1b. MCP Servers

Check `.claude/settings.json` and `.claude/settings.local.json` for MCP server configurations.
For each server, note:
- Server name
- What tools it provides (if discoverable from the config)
- Transport type (stdio, sse, etc.)

### 1c. Agents

Check for agent definitions and usage patterns:

**Agent definitions** — Scan `.claude/agents/` for agent `.md` files with YAML frontmatter.
For each agent, extract:
- `name` and `description`
- `allowed-tools` — what the agent can do
- `model` — if specified, which model it targets
- What commands or workflows spawn this agent

**Agent usage within commands** — For every command that includes `Agent` in `allowed-tools`,
scan the command prose for how it spawns agents:
- What `subagent_type` values does it use?
- What prompts does it pass to agents?
- Does it spawn agents in parallel or sequentially?
- Are there agent patterns that could be extracted into reusable agent definitions?

**Agent optimization opportunities:**
- Commands that spawn agents with long inline prompts that could be agent definitions instead
- Agent definitions that overlap in capability (could be consolidated)
- Commands that could benefit from agent parallelization but currently run sequentially
- Agents whose descriptions don't match what they actually do (stale definitions)

### 1d. CLAUDE.md and shared.md Context

Read `CLAUDE.md` (project root) and `.vine/context/shared.md` if they exist. Note:
- Whether CLAUDE.md contains the availability-gated VINE pointer block (see 3e)
- Whether CLAUDE.md still carries a full workflow map or command inventory (pre-0.4 layout —
  a move candidate for 3d/3e)
- Whether shared.md already has a workflow map (to update rather than create)
- Conventions in either file that affect skill behavior

Present the inventory:

> "Found [N] commands, [N] skills, [N] MCP servers, [N] agent definitions.
> Here's what I see:"
>
> [Compact inventory table: name | type | source | description snippet]
>
> "Ready to analyze, or did I miss anything?"

Wait for confirmation before proceeding.

## Phase 2: Analyze

Phase 2 is a set of named, self-contained audit checks. Each check defines what it
inspects and what it reports; none depends on another's internals. Future audits (e.g., a
validation-contract check) slot in as additional subsections — extend the list, don't
restructure it.

### 2a. Description Quality

For each command and skill, evaluate the `description` field against Claude's skill matching
constraints:

**Scoring criteria** (score each 1-5):

| Criterion | What to check |
|-----------|--------------|
| **Length efficiency** | Is it using the ~250 char matching window well? Too short wastes matching surface. Too long gets truncated. |
| **Keyword density** | Does it contain the words a user would naturally say when they need this tool? |
| **Action clarity** | Does it lead with what the tool DOES, not what it IS? |
| **Differentiation** | Could Claude confuse this with another command based on the description alone? |
| **Trigger coverage** | Does it mention the key scenarios that should invoke this command? |

For each command, produce:
- Current description
- Score (sum of criteria, out of 25)
- Specific weakness (if score < 20)
- Proposed improvement (if score < 20)

### 2b. Chain Detection

Detect relationships between commands by analyzing their prose and artifacts:

**Explicit chains** — Command A's prose mentions command B by name:
- "suggest running `/vine:evolve`" → navigate suggests evolve
- "run `/vine:init` first" → dependency on init
- "consider `/vine:pair` instead" → lateral switch

**Artifact chains** — Command A produces a file that command B consumes:
- verify writes CONTEXT.md → inquire reads CONTEXT.md
- inquire writes SPEC.md → navigate reads SPEC.md

**State-based triggers** — Conditions where a command becomes relevant:
- CONTEXT.md exists but no SPEC.md → inquire is the next step
- NAVIGATION.md has "Remaining Work" section → resume is relevant
- No `.vine/` directory → init should run first

**Capability chains** — Commands that share tool access patterns or domain overlap,
suggesting they work well in sequence.

For each detected chain, classify it:

| Chain Type | Meaning |
|------------|---------|
| `sequence` | A should run before B (artifact dependency) |
| `suggests` | A recommends B at completion |
| `switches-to` | A offers lateral switch to B mid-session |
| `requires` | A cannot run without B having run first |
| `enhances` | A's output improves B's effectiveness |

### 2c. Token Efficiency

Analyze each command and shared context file for token cost relative to instruction quality.
Every token in a command file is consumed when Claude loads it, and shared.md multiplies
across every phase invocation.

**Per-command analysis:**

| Anti-pattern | What to check |
|-------------|--------------|
| **Boilerplate bloat** | Repeated blocks (overlay loading, profile loading) that are longer than they need to be. Could the same instruction be conveyed in fewer lines without losing clarity? |
| **Over-explanation** | Instructions for things Claude already knows how to do (e.g., explaining what `git commit` does, restating tool behavior that's in Claude's training). |
| **Prose vs structure** | Paragraphs that convey tabular information. A 10-line paragraph explaining 4 options costs more tokens than a 4-row table saying the same thing. |
| **Redundant examples** | Examples that illustrate something the instruction already made clear. Examples are high-value when the pattern is novel; they're waste when the instruction is unambiguous. |
| **Dead principles** | Principles sections that restate what the command's steps already demonstrate through their structure. If the steps already embody the principle, stating it separately is redundant. |
| **Unused tool grants** | `allowed-tools` entries the command never actually uses in its instructions. Each granted tool has a cost in Claude's tool loading. |

**Cross-command analysis:**

| Anti-pattern | What to check |
|-------------|--------------|
| **shared.md / CLAUDE.md overlap** | Content that appears in both is read twice per invocation. Apply the Knowledge Boundary rule (`references/STATE.md`) to pick the single home and leave a one-line pointer at the other. |
| **Inventory in files** | Any command or agent enumeration in shared.md, CLAUDE.md, or an overlay is a finding, not a feature — the harness's native skill list is the inventory's home, and file copies can only drift. |
| **Inter-command duplication** | Multiple commands explaining the same convention independently. Could a shared reference (context overlays, CLAUDE.md) carry this once? |
| **Overlay redundancy** | Per-phase overlays that restate what the command prose already says. Overlays should add project-specific context, not echo the command's own instructions. |
| **Overlay coverage** | Each phase overlay should point at its phase-relevant tools, agents, and validation commands. A phase whose project-specific tooling is undiscoverable from its overlay is a gap — never fixed by adding a file-based inventory. |

**Context loading analysis:**

| Anti-pattern | What to check |
|-------------|--------------|
| **Broad reads** | Commands that read entire files when they only need a section. Flag instructions like "Read CONTEXT.md" when only one section is used. |
| **Speculative discovery** | Discovery scans that are broader than what the command actually needs. Does the command scan 5 directories but only use results from 2? |
| **Cascading loads** | Instructions that trigger reading file A, which mentions file B, which triggers reading file C — when only file C's content was actually needed. |

For each command, produce:
- **Token estimate**: Approximate token count of the command file
- **Density score** (1-5): How much of the content is load-bearing instruction vs filler
- **Top reduction opportunities**: Specific sections that could be shortened, with estimated
  token savings and a before/after sketch of the tighter version
- **Cross-file waste**: Any duplication with shared.md, CLAUDE.md, or other commands

Present the analysis as a ranked list, highest-waste commands first:

> "**Token Efficiency:**
> [Table: command | tokens | density | top opportunity | est. savings]
>
> **Cross-file duplication:**
> [Table: content | appears in | recommendation]"

When proposing reductions in Phase 3, show the tightened version alongside the original so the
engineer can verify no instruction quality was lost. Never cut content that changes Claude's
behavior — only cut content that restates what Claude would already do.

### 2d. Workflow Detection

Group chains into coherent workflows — sequences of commands that accomplish a goal together:

- **Linear workflows**: A → B → C → D (the main VINE cycle is one)
- **Branching workflows**: A → B or C depending on scope
- **Loop workflows**: A → B → C → back to A (iterative refinement)

Name each workflow and describe when it applies.

### 2e. Interactivity Analysis

Analyze each command for decision points that would benefit from structured user interaction
via `AskUserQuestion` instead of prose-based option lists or silent assumptions.

**What to look for:**

| Pattern | Issue | Recommendation |
|---------|-------|---------------|
| **Markdown option lists** | Command prints numbered options and waits for free-text response. Claude may misinterpret the response or the user may not realize a decision is expected. | Replace with `AskUserQuestion` — structured select with clear labels and descriptions. |
| **Silent defaults** | Command makes a choice without surfacing it. The user doesn't know a decision was made or that alternatives existed. | Add an `AskUserQuestion` call with the default as the recommended option. |
| **Open-ended questions** | Command asks "what do you want to do?" without constraining the answer space. Leads to ambiguous responses and follow-up clarification loops. | Convert to `AskUserQuestion` with concrete options derived from the command's context. |
| **Branching without gating** | Command has conditional paths (if X, do A; otherwise do B) but doesn't ask the user which path to take when the condition is ambiguous. | Add a decision point at the branch. |
| **Batch decisions** | Multiple independent yes/no decisions presented sequentially. Each round-trip costs tokens and time. | Batch into a single `AskUserQuestion` with `multiSelect: true`. |
| **Missing confirmation** | Command performs a consequential action (file writes, git operations, external calls) without confirming intent. | Add a confirmation `AskUserQuestion` before the action. |

**Constraints for `AskUserQuestion` recommendations:**
- Max 4 questions per call, max 4 options per question (auto-adds "Other")
- Recommended option first with "(Recommended)" appended
- Short labels (1-5 words) with descriptions for tradeoff context
- `multiSelect: false` for mutually exclusive choices, `true` for batched yes/no decisions

For each command, produce:
- Number of existing `AskUserQuestion` uses
- Number of decision points that should use `AskUserQuestion` but don't
- Specific locations and proposed conversions

Present the interactivity analysis:

> "**Interactivity:**
> [Table: command | existing AskUser calls | proposed additions | top opportunity]"

Present the full analysis:

> "**Description Quality:**
> [Table: command | score | status]
>
> **Token Efficiency:**
> [Table: command | tokens | density | top opportunity | est. savings]
>
> **Interactivity:**
> [Table: command | existing AskUser calls | proposed additions | top opportunity]
>
> **Chains Detected:**
> [Table: from → to | type | evidence]
>
> **Workflows:**
> [Named workflow descriptions]
>
> **Cross-file duplication:**
> [Table: content | appears in | recommendation]
>
> Want me to apply improvements?"

Use `AskUserQuestion` to let the engineer choose what to apply:
- "Apply all improvements (Recommended)" — descriptions + token reduction + interactivity + workflow map + prose links
- "Matching & efficiency" — descriptions + token reduction + interactivity (no workflow changes)
- "Workflows only" — workflow map + chain links (no command edits)
- "Review individually" — go through each change one by one

## Phase 3: Apply

### 3a. Improve Descriptions

For each command/skill with a score below 20, propose an improved description. Show the
before/after and get approval before editing:

> "**vine:evolve** (score: 16/25)
> Current: `Triple evolution — verify, capture learnings, and prep the handoff`
> Proposed: `Verify feature against acceptance criteria, update CLAUDE.md and context overlays, capture engineer growth — run after vine:navigate completes`
> Weakness: Doesn't mention acceptance criteria verification or when to trigger it"

If the engineer chose "Apply all improvements," apply without individual approval but show
a summary of all changes made. If they chose "Review individually," use `AskUserQuestion`
for each one.

**Constraint:** Never change a description in a way that would break existing matching
patterns. If a description currently triggers correctly for known use cases, preserve those
keywords even while improving other aspects.

### 3b. Reduce Token Waste

For commands with density scores below 3, propose tightened versions of their worst sections.
Show the original and the reduced version side by side so the engineer can verify no
instruction quality was lost.

> "**vine:navigate** — Overlay loading block (38 lines → 15 lines, ~200 token savings)
> This block repeats the same pattern as every other command but with more explanation
> than needed. Here's the tighter version:"
>
> [before/after comparison]

**Rules for reduction:**
- Never remove instructions that change Claude's behavior — only remove restatements
- Preserve all decision points and their options
- Keep examples that illustrate novel patterns; cut examples that illustrate obvious ones
- If a section is load-bearing (Claude would behave differently without it), don't touch it
- Show estimated token savings for each proposed reduction

For cross-file duplication, recommend which file should own the content and propose removing
it from the other, leaving a one-line pointer at the old home. The Knowledge Boundary rule in
`references/STATE.md` decides ownership: CLAUDE.md owns repo facts every session needs (paid
by every teammate, VINE or not); shared.md owns cross-phase VINE knowledge; phase overlays own
phase-specific mappings; the native skill list owns the inventory.

### 3c. Improve Interactivity

For commands with decision points that should use `AskUserQuestion` but don't, propose
the conversion. Show what the command currently does and what the structured interaction
would look like:

> "**vine:verify** — Scope decision (line ~85)
> Currently: Prints 3 options as a markdown list and waits for free-text response
> Proposed: `AskUserQuestion` with 3 options, 'Full VINE cycle (Recommended)' first"
>
> [proposed AskUserQuestion parameters]

For batch decision opportunities, show how multiple sequential questions collapse into
a single `multiSelect: true` call.

**Constraint:** Don't add interactivity where speed matters more than choice visibility.
If a command makes a reasonable default and the user can override by speaking up, that's
often better than a blocking prompt.

### 3d. Write Workflow Map to shared.md

Add or update a `## Skill Workflows` section in `.vine/context/shared.md`. The map is VINE
routing knowledge — workflow chains plus state-based suggestions — so it lives on the VINE
surface, loaded only by VINE sessions (Knowledge Boundary rule, `references/STATE.md`).
CLAUDE.md carries only the pointer verified in 3e.

Format:

```markdown
## Skill Workflows

<!-- Generated by vine:optimize on [date]. Re-run /vine:optimize to update. -->

### [Workflow Name]
[When this workflow applies]
1. `/command-a` — [what it does in this workflow]
2. `/command-b` — [what it does in this workflow]
3. `/command-c` — [what it does in this workflow]

### State-Based Suggestions
- [condition] → suggest `/command`
- [condition] → suggest `/command`
```

**Rules for the workflow map:**
- Chains and state-based suggestions ONLY — no command or agent inventory. The harness's
  native skill list is the inventory's home; an enumeration in the map can only drift.
- Keep it concise — this is routing context, not documentation
- Each workflow should be 3-7 steps max
- State-based suggestions use observable conditions (file exists, git state, etc.)
- Include the generation date so staleness is visible
- If a workflow map already exists, update it rather than duplicating
- If CLAUDE.md still carries a full workflow map (pre-0.4 layout), offer to move it here
  and replace it with the pointer block from 3e

### 3e. Verify the CLAUDE.md Pointer

CLAUDE.md gets a pointer, never the map. Check that CLAUDE.md contains an availability-gated
VINE pointer block; if it's missing, offer to add it:

```markdown
## VINE

This repo uses VINE. If vine commands are available in this session and `.vine/projects/`
has active features, suggest the matching phase — routing details in
`.vine/context/shared.md`.
```

The gate is command availability — visible to Claude in its own skill list — so the block
works whether VINE is installed repo-level or globally, and a teammate who doesn't use VINE
pays only these few lines. Verify the pointer exists and is accurate; never expand it into
a map.

### 3f. Add Chain Links to Command Prose

For commands that don't already suggest their next step, add a brief suggestion at the
natural completion point. This is the lightest touch — one line that tells Claude what
comes next:

> "📋 Suggested next step: Run `/vine:inquire <domain>/<feature-slug>` to design the feature on top of this context."

Only add chain links where:
- The chain is a `sequence` or `suggests` type
- The command doesn't already have a suggestion at that point
- The engineer approved the change

Use `AskUserQuestion` to confirm which chain links to add if the engineer chose
"Review individually."

### 3g. Summary

After applying changes, present a summary:

```
---
✅ vine:optimize complete

📊 Analysis:
   Commands/skills scanned: [N]
   Description improvements: [N applied] / [N proposed]
   Token reductions: [N applied] (~[N] tokens saved)
   Interactivity improvements: [N applied] / [N proposed]
   Chains detected: [N]
   Workflows mapped: [N]

📝 Changes applied:
   - [list of files modified with what changed]
   - shared.md: [added/updated] Skill Workflows map
   - CLAUDE.md: pointer [verified / added / replaced a full map]
   - Token savings: ~[N] tokens per session across [N] commands

🔄 To re-run after adding or changing commands: /vine:optimize
   Last optimized: [date]

📋 If command files were modified, run `/trellis` to validate structural compliance.

🌱 Session retro:
   - CLAUDE.md suggestion: [patterns discovered about this repo's skill landscape]
   - Skill suggestion: [any automation worth building based on what was found]
   - User note: [observations about the command/skill organization]
---
```

## Running on a Schedule

vine:optimize works best when re-run after significant changes to commands, skills, or
workflows. The engineer can:

1. **Manual**: Run `/vine:optimize` whenever commands change
2. **Post-evolve**: vine:evolve suggests re-running optimize when it recommends new commands
   or skills (if the integration is wired up)
3. **Scheduled**: Use Claude Code's `/schedule` to run optimize on a cron (e.g., weekly)

The command is idempotent — re-running it updates existing analysis rather than duplicating.
The workflow map in shared.md includes a generation date so staleness is visible.

## Important Principles

**Don't break what works.** If a command currently triggers correctly, preserve those
matching patterns even while improving the description.

**Chains emerge from prose and artifacts.** The relationship data already exists in how
commands reference each other and what files they produce/consume. This command surfaces
and formalizes those relationships — it doesn't invent them.

**The engineer decides.** Every change is presented for approval. vine:optimize reports and
recommends; it doesn't edit silently.
