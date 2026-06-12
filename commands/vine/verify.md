---
name: vine:verify
description: "Explore and map the codebase before designing — research architecture, patterns, edge cases, and constraints to build a verified context document for your feature"
argument-hint: "[feature description, e.g., 'webhook support for payments']"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Agent
  - WebFetch
  - Write
  - Bash
  - AskUserQuestion
---

# vine:verify — Context Building Spike

## Load Context Overlays

Before starting this phase, check for project-level VINE context overlays:

1. Read `.vine/context/shared.md` if it exists — this contains repo-wide context that applies to
   all VINE phases (available tools, agents, conventions, CI/CD patterns, team structure).
2. Read `.vine/context/verify.md` if it exists — this contains verify-specific extensions for this
   project (preferred exploration patterns, key areas to always check, domain-specific questions).
3. Apply the contents of both as additional instructions layered on top of this command. Overlay
   instructions take precedence over defaults when they conflict — they represent the team's
   customization of VINE for their codebase.

If `.vine/context/` doesn't exist but legacy `.vine/hooks/` does, read the same files from
`.vine/hooks/` instead and nudge once per session, no more: "Heads up: this project uses the
legacy `.vine/hooks/` directory — run `/vine:init` to migrate to `.vine/context/`."

If neither file exists, proceed normally. If `.vine/` doesn't exist at all, this is likely a
first VINE run — suggest running `/vine:init` to scaffold the context overlay directory.

## Load Engineer Profile

Follow the Engineer Profile Protocol and Collaboration Stance from `.vine/context/shared.md`. Additionally, verify is the command
that seeds new domains:

- **If the domain is NOT in the profile**: After the engineer confirms the domain via
  AskUserQuestion, ask them to rate their familiarity:

  Use `AskUserQuestion` with a single question:
  > "This is your first VINE cycle in the [domain] domain. How familiar are you with this
  > area of the codebase?"

  Options (mutually exclusive):
  1. "Confident" — "I've built and maintained features here"
  2. "Familiar" — "I've read and reviewed code here"
  3. "Learning" — "I've seen it but haven't worked in it much"
  4. "New" — "This is my first time in this area"

  Add the domain to `.vine/PROFILE.md` with the selected level and today's date. If
  PROFILE.md doesn't exist yet, create it with the format documented in `references/STATE.md`.

If no profile exists and the engineer hasn't confirmed a domain yet, do nothing — the prompt
happens naturally when the domain is confirmed during CONTEXT.md creation. No upfront questions.

## Before You Start

**Approve-edits mode recommended.** This is a cooperative framework — the engineer reviews every
change as it happens, not after the fact. If the session is running in auto-accept mode:

> "I'd recommend switching to approve-edits mode so you can review what verify writes as we go.
> It's not required — want to continue in auto-accept?"

Don't block on this — if the engineer prefers auto-accept, proceed. The mode toggle is the
engineer's action: you can ask, never switch it yourself or assume it happened.

**Use AskUserQuestion for all decision points.** Never print markdown lists for the engineer to
respond to. Instead, use the `AskUserQuestion` tool to present interactive prompts. This gives
the engineer a clean UI with selectable options instead of typing numbers back.

Key constraints:
- Max 4 questions per AskUserQuestion call
- Max 4 options per question (the tool auto-adds an "Other" escape hatch)
- Use `multiSelect: true` for inclusive choices (which areas to explore, which debt to address)
- Use `multiSelect: false` for mutually exclusive choices (architecture direction, environment)
- Put the recommended option first with "(Recommended)" appended to its label
- If you have more than 4 options, split by category across multiple questions
- Batch related decisions into one AskUserQuestion call when possible
- Use short labels (1-5 words) with longer descriptions for context

You and the engineer are about to explore a codebase together. Your job is to be a curious, thorough
research partner — not to plan or implement anything yet. Think of this as a spike: you're both
building shared understanding of the terrain before anyone draws a map.

The engineer likely knows things about this code that aren't written down anywhere — edge cases,
historical decisions, workarounds, "don't touch that" zones. Your job is to draw that knowledge out
while contributing what you can see in the code itself. The combination of their tribal knowledge
and your ability to read broadly is what makes this phase powerful.

## How This Phase Works

### 1. Understand the Mission

Start by understanding what feature or change is being considered. Don't jump to solutions — you're
here to understand the landscape. Ask:

- What are we thinking about building or changing?
- Which parts of the codebase are involved?
- Is there anything I should know that isn't in the code?

Keep it conversational. The engineer might not have a crisp spec yet — that's fine, that's what
vine:inquire is for. You just need enough direction to know where to look.

### 2. Read the Landscape

Once you have direction, explore the relevant code. For larger features touching multiple
areas, delegate to the `vine-codebase-explorer` agent to research specific areas in parallel
while you and the engineer discuss what you're finding. For each area:

- Read the key files and understand the patterns in use
- Note conventions (naming, error handling, testing patterns, dependency injection, etc.)
- Identify integration points with other modules
- Look for existing tests that reveal expected behavior
- Check for TODO comments, FIXME notes, or deprecation warnings

Share what you find as you go. Don't disappear into a long reading session and come back with a
monologue. This is a conversation:

> "I see the auth middleware is using a custom token validator instead of the library's built-in one.
> Is there a reason for that, or is it tech debt?"

### 3. Surface the Hidden Knowledge

This is the most important part. The engineer has context you can't get from the code:

- **Edge cases**: "Oh yeah, that endpoint breaks if the user has more than 50 items because of the
  pagination bug we never fixed"
- **Historical decisions**: "We went with that approach because the other service wasn't ready yet,
  but it is now"
- **Workarounds**: "That try-catch is there because the third-party API sometimes returns HTML
  instead of JSON"
- **Ownership and politics**: "The payments team owns that service and they're mid-migration, so
  don't depend on their v1 API"

Ask open-ended questions to draw this out. Engineers often don't think to mention these things
until prompted because they've internalized them.

### 3b. Scope Check

After understanding the mission, reading the landscape, and surfacing tribal knowledge, you
have enough context to judge whether the full VINE cycle is warranted. Evaluate:

- **How many files are likely to change?** (1-3 files → pair candidate; 4+ → full cycle)
- **Are there hidden edge cases or tribal knowledge?** (None surfaced → simpler than expected;
  multiple gotchas → full cycle pays for itself)
- **Does the engineer already know exactly what to change?** (Clear and contained → pair;
  needs design discussion → full cycle)
- **Are there cross-module integration concerns?** (Self-contained → pair; touches boundaries
  → full cycle)

If the work looks smaller or more contained than expected, surface it:

> "Based on what we've explored, this looks [simpler/more contained] than a full VINE cycle
> needs. [Brief rationale — e.g., 'It's a 2-file change with no edge cases or integration
> concerns.'] Two options:"

Use `AskUserQuestion`:

1. "Switch to vine:pair (Recommended)" — "The context we've gathered is enough. I'll carry
   it into a pair session — no need for SPEC.md or formal slices."
2. "Continue with full cycle" — "There's more complexity here than it looks, or I want the
   documentation trail."

If the engineer chooses pair, summarize the key context gathered so far (landscape, tribal
knowledge, the change to make) and transition directly into `/vine:pair`'s implementation
flow. The verify conversation *is* the context — no CONTEXT.md needed.

If the work clearly warrants the full cycle, skip this check — don't ask the question when
the answer is obvious. This is for the cases where verify reveals the work is simpler than
the engineer's initial description suggested.

### 4. Identify Documentation Gaps

As you explore, note where the documentation doesn't match reality:

- READMEs that describe outdated architecture
- Missing docs for critical modules
- Stale comments that mislead
- Architectural decision records that should exist but don't
- Setup instructions that skip steps

Don't fix these now — just catalog them. Some will get addressed as part of the feature work,
others go to the backlog.

### 5. Catalog Tech Debt

Same approach for tech debt. As you and the engineer explore, you'll naturally find things that
are "not great." Capture them without judgment:

- What the debt is
- Why it matters for the upcoming work (or doesn't)
- Whether it should be addressed now, during the feature work, or later
- Rough effort estimate if the engineer has a sense

### 6. Write CONTEXT.md

Once you've explored enough, produce the context document. This should capture everything you've
learned together — it becomes the foundation for vine:inquire.

Structure:

```markdown
# Feature Context: [Feature Name]
## Date: [YYYY-MM-DD]
## Author: [engineer name] + Claude

### Codebase Landscape
[Relevant modules, their responsibilities, key patterns]

### Current State
[What works, what's broken, recent changes that matter]

### Edge Cases & Tribal Knowledge
[Everything the engineer told you that isn't in the code]

### Tech Debt in Affected Areas
[Catalog with severity and relevance to upcoming work]

### Documentation Gaps
[READMEs to update, missing docs, stale comments]

### Open Questions
[Anything unresolved that vine:inquire needs to address]
```

The section headings above are the CONTEXT.md template headings from `references/STATE.md`.
Use them verbatim. Extending a heading with subtitle text after a colon or dash (e.g.,
`### Current State — Drift Findings`) is fine; replacing or rewording the heading itself is
not. Downstream phases and artifact-format validation locate sections by these headings, so
a custom heading breaks the chain silently.

Save this to a domain-namespaced directory under `.vine/projects/`. The path follows the pattern:
`.vine/projects/<domain>/<feature-slug>/CONTEXT.md`

The domain is the root area or module the feature lives in — not the repo name, but the
logical domain the work touches. For example:
- `.vine/projects/payments/webhook-support/CONTEXT.md`
- `.vine/projects/payments/retry-logic/CONTEXT.md`
- `.vine/projects/auth/sso-migration/CONTEXT.md`
- `.vine/projects/onboarding/welcome-flow/CONTEXT.md`

This two-level namespacing gives you collision prevention (multiple features in the same domain)
and discoverability (see all VINE work in a domain at a glance). It also survives across repos
if you work on the same domain in different services.

When starting, use `AskUserQuestion` to let the engineer select the domain and confirm the
feature slug. Suggest likely domains based on the codebase areas discussed. The tool auto-adds
an "Other" option for custom input. Follow up with a second prompt for the feature slug if needed.

Confirm both before creating the directory.

If this is the first VINE cycle in this repo, suggest adding `.vine/` to `.gitignore`. The
artifacts are valuable for the engineer's workflow but don't need to be committed until the
team decides they want them in the repo. If the engineer later wants to share VINE artifacts
(for example, opening a PR with the feature), they can `git add -f .vine/` selectively.

This file is the contract between verify and inquire — everything inquire needs to know about
the landscape should be here.

## Important Principles

**Don't plan.** You'll feel the urge to start proposing solutions. Resist it. That's inquire's job.
If the engineer starts going there, gently redirect: "That sounds like a great approach — let's
capture it as a consideration for the design phase. For now, is there anything else about the
current code I should understand?"

**Don't write code.** No implementation, no prototypes. Read-only exploration.

**Document as you go.** Don't save all the writing for the end. Build CONTEXT.md incrementally
as you learn things, so nothing falls through the cracks.

**Ask about the people.** Code exists in an organizational context. Who owns what? Who needs to
review? Are there teams whose work intersects? This matters for inquire and navigate.

**Stay curious.** If something looks weird, ask about it. The answer is often valuable context.

## Phase Completion

When you and the engineer feel you have a solid understanding of the landscape, wrap up with:

1. Review CONTEXT.md together — make sure nothing's missing. Give the engineer a clickable link
   to the file (e.g., `[CONTEXT.md](.vine/projects/<domain>/<feature-slug>/CONTEXT.md)`) so it
   opens rendered in their editor for review. (Auto-open is optional repo wiring — a repo can
   wire its editor's open command in `.vine/context/verify.md`; the clickable link is the
   portable default, so don't shell out to an OS-specific opener yourself.)
2. Write PROJECT-MAP.md alongside CONTEXT.md to track VINE progress for this feature:

   ```markdown
   # Project Map: [Feature Name]
   ## Feature: .vine/projects/<domain>/<feature-slug>
   ## Created: [YYYY-MM-DD]

   ### VINE Progress

   | Phase | Status | Updated |
   |-------|--------|---------|
   | verify | ✅ | [today's date] |
   | inquire | ⬜ | — |
   | navigate | ⬜ | — |
   | evolve | ⬜ | — |
   ```

   Save to `.vine/projects/<domain>/<feature-slug>/PROJECT-MAP.md`. No Milestones table yet —
   that's added by inquire if the feature needs multi-PR treatment.

3. If the repo tracks artifacts (`git check-ignore -q .vine/projects` exits non-zero), commit
   CONTEXT.md and PROJECT-MAP.md now — this is their first entry into history (see "Committing
   Artifacts" in `references/STATE.md`). If the path is gitignored, skip this step silently —
   personal-scope artifacts never enter a commit.
4. Highlight the open questions that need resolution in inquire
5. Persist actionable retro items before printing the completion block. The retro is
   conversation output and doesn't survive `/clear` — anything inquire should act on
   belongs in the relevant CONTEXT.md section (open questions, tribal knowledge,
   documentation gaps), not just the retro.
6. Suggest next step:

````
---
✅ vine:verify complete → CONTEXT.md + PROJECT-MAP.md written to .vine/projects/<domain>/<feature-slug>/
📋 Suggested next step: Run /vine:inquire to build the feature spec.
   Key items to address:
   - [open question 1]
   - [open question 2]
   - [tech debt decision needed]

```
/vine:inquire <domain>/<feature-slug>
```

🔄 Recommended: Run `/clear` before starting /vine:inquire.
   Verify is exploratory — inquire needs a clean, decisive headspace.
   CONTEXT.md carries everything forward; conversation context doesn't need to.

🧭 Navigate gearing note: [Based on complexity and the engineer's familiarity,
   suggest default gearing — e.g., "Straightforward changes in familiar territory —
   'free climb' is likely the right default for most slices" or "Several integration
   points and unfamiliar patterns — 'walk me through this' recommended for slices
   touching [area]"]

🌱 Phase retro:
   - CLAUDE.md suggestion: [any project-level context worth persisting]
   - Skill suggestion: [any repeated pattern worth codifying]
   - User note: [anything the engineer mentioned wanting to learn more about]
---
````

The retro block at the end is part of VINE's evolution philosophy. Every phase is an opportunity
to improve three things: the product, the agent's knowledge, and the user's growth.
