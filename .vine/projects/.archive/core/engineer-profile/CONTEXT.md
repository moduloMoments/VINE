# Feature Context: Engineer Profile
## Date: 2026-03-27
## Author: Rob + Claude

### Codebase Landscape

VINE is a pure-markdown framework — 5 command files in `commands/vine/` (init, verify, inquire, navigate, evolve), a state reference at `references/STATE.md`, and a README. No build step, no runtime code.

**Key patterns in use:**
- Every command file has YAML frontmatter (name, description, argument-hint, allowed-tools)
- Every command starts with a "Load Project Hooks" block that reads `.vine/hooks/shared.md` and `.vine/hooks/<phase>.md`
- State flows between phases via `.vine/<domain>/<feature-slug>/` artifacts (CONTEXT → SPEC → NAVIGATION → EVOLUTION)
- `AskUserQuestion` is the standard for all decision points (max 4 questions, max 4 options, recommended option first)
- Commands are written in second-person instructional markdown

**Files that will be modified:**
- `commands/vine/init.md` — add optional profile seeding
- `commands/vine/verify.md` — add profile loading + re-prompt for missing domain entries
- `commands/vine/inquire.md` — add profile loading, adjust explanation depth guidance
- `commands/vine/navigate.md` — add profile loading, adjust narration depth guidance (biggest consumer)
- `commands/vine/evolve.md` — add profile update step + Claude memory/CLAUDE.md suggestion step
- `references/STATE.md` — document PROFILE.md format and lifecycle
- `README.md` — add PROFILE.md to artifacts, explain the layered profile model

### Current State

**What works today:**
- The "User Evolution" section in evolve.md (lines 201-230) already captures per-cycle learnings — knowledge highlights, suggested explorations, what the engineer learned and taught
- This data currently goes into EVOLUTION.md and dies there — it's not persistent across cycles
- Every command already references "the engineer" extensively but treats all engineers identically

**What's missing:**
- No mechanism for VINE to know how familiar the engineer is with specific codebase domains
- No persistent record of which areas the engineer has worked in via VINE cycles
- The README claims VINE grows "the user" but there's no persistent artifact backing that claim
- Evolve captures growth observations but doesn't feed them into any lasting system (neither VINE artifacts nor Claude memory)

### Key Design Pivot: Layered Profile Model

During verify, we explored whether VINE should build a comprehensive user profile (skill levels, learning preferences, interaction style, growth edges) at `~/.vine/PROFILE.md`. We discovered this would **duplicate what Claude already provides** via:

| Claude feature | What it handles |
|----------------|----------------|
| **Global memory** (`~/.claude/memory/`) | Persistent user facts across projects — learning style, interaction preferences |
| **Project memory** (`~/.claude/projects/.../memory/`) | Per-repo persistent context |
| **User CLAUDE.md** (`~/.claude/CLAUDE.md`) | Global instructions and preferences |
| **Project CLAUDE.md** (`./CLAUDE.md`) | Per-repo conventions and instructions |

Rob already has a global memory entry: "User wants to learn the 'why' behind technical decisions" — exactly the kind of preference the original profile was going to capture.

**Refined scope:** VINE's profile should focus on what Claude's native features DON'T cover — **repo-domain expertise tracking**. What does this engineer know about THIS codebase's specific domains, based on actual VINE cycles completed?

The result is a two-layer model:
1. **VINE layer** (`.vine/PROFILE.md`): Repo-domain expertise and growth log — "confident in auth, learning payments"
2. **Claude layer** (memory + CLAUDE.md): General preferences, interaction style, learning patterns — suggested by vine:evolve

### Design Decisions Made

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Location** | Per-repo at `.vine/PROFILE.md` | Domain expertise is repo-specific. "Confident in auth" means *this repo's* auth module. |
| **Format** | Human-readable markdown | Engineer should want to read and edit it. No YAML frontmatter. |
| **Seeding** | At vine:init or first vine:verify | Skippable — if engineer skips, re-prompt at next verify start |
| **Re-prompting** | At each vine:verify start | Check for missing domain entries, offer to fill |
| **Primary behavior** | Adjust explanation depth | More narration in unfamiliar domains, more concise in comfort zones |
| **Updates** | Evolve suggests edits, engineer applies | Consistent with VINE's human-decides philosophy |
| **Claude integration** | Evolve suggests Claude memory + CLAUDE.md updates | VINE feeds Claude's native learning systems for general preferences |
| **Profile content** | Domain expertise + growth log | NOT general skills, learning prefs, or interaction style — Claude handles those |

### Edge Cases & Tribal Knowledge

- **This repo IS the product.** Editing `commands/vine/` changes the tool itself. Changes here need to be tested by running the modified command on a real repo.
- **Solo maintainer, public repo.** Currently self-review and merge. Community contributors expected — the profile feature should be designed so contributors can test it without complex setup.
- **`.vine/` is gitignored by default** (both in this repo's `.gitignore` and recommended globally). PROFILE.md lives inside `.vine/` so it's naturally gitignored — no new gitignore patterns needed.
- **Profile is opt-in, never blocking.** Every command must work fine without a profile. The profile enhances VINE; it doesn't gate it. If `.vine/PROFILE.md` doesn't exist, commands behave exactly as they do today.
- **Agent-agnostic consideration.** The per-repo profile at `.vine/PROFILE.md` works for any AI tool. The Claude memory/CLAUDE.md suggestion step in evolve is Claude-specific — it should be gated on detecting Claude Code, or framed as a general "suggest updates to your AI agent's persistent memory" pattern.

### Tech Debt in Affected Areas

- **Repeated "Load Project Hooks" blocks:** All 5 commands have nearly identical hook-loading sections (lines 16-30 in each). Adding a "Load Engineer Profile" step to each will increase this repetition. Not blocking — the profile loading is simpler than hook loading (one file, one location).
- **Evolve's User Evolution section is thin:** Lines 201-230 capture learnings but don't give structured guidance on what to do with them. This feature adds two concrete actions: update PROFILE.md domain entries and suggest Claude memory updates.
- **No validation of artifact format:** Commands produce markdown artifacts but nothing checks their structure. The profile will need a clear enough format that commands can parse it reliably from section headers.

### Documentation Gaps

- **README needs a profile section.** Explain the layered model: VINE tracks domain expertise, Claude handles general preferences. This is also a selling point — VINE makes Claude smarter, not just the product.
- **STATE.md needs PROFILE.md.** Currently documents 4 per-feature artifacts. PROFILE.md is per-repo, not per-feature — needs its own section explaining the lifecycle.
- **Issue template gap.** `.github/ISSUE_TEMPLATE/bug_report.md` asks about installation type but not about profile state — if someone reports a bug related to profile loading, we'd want to know if they have one.

### Open Questions

1. **What should the seeding questions look like?** Since we're now focused on repo-domain expertise, the seeding flow changes. Instead of asking about general engineering experience, vine:verify needs to ask "which areas of this codebase are you comfortable with?" That requires knowing the repo's domain structure — which verify is already exploring.

2. **How does the domain expertise map to the `.vine/<domain>/` namespace?** The profile tracks domains like "auth", "payments". VINE cycles use the same domain names for feature directories. Should the profile auto-update when a cycle completes in a domain, or only when evolve explicitly suggests it?

3. **How should commands cross-reference profile domains with current work?** When navigate runs on `.vine/payments/webhook-support/`, it should check PROFILE.md for the engineer's comfort with "payments". What if the domain name doesn't match exactly (e.g., profile says "billing", feature is in "payments")?

4. **How prescriptive should the "adjust explanation depth" guidance be?** Simple version: "if confident, be concise; if learning, explain more." But navigate already has nuanced narration guidance — how much should the profile override vs inform?

5. **Claude memory suggestion format.** When evolve suggests Claude memory updates, what should it actually say? "Save this to Claude memory" is Claude-specific. The agent-agnostic framing would be "suggest this for your AI agent's persistent context" — but that's vague.

6. **Growth log vs. domain levels.** The profile has both domain expertise levels and a dated growth log. Should the log auto-roll (keep last N entries)? Or grow indefinitely as a useful history?
