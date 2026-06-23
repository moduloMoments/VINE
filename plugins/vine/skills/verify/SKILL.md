---
description: "Explore and map the codebase before designing — research architecture, patterns, edge cases, and constraints to build a verified context document for your feature"
argument-hint: "[feature description, e.g., 'webhook support for payments']"
disable-model-invocation: true
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

Read `.vine/context/shared.md` and `.vine/context/verify.md` if they exist, then follow the
**Overlay Loading Protocol** from `shared.md` for the rest (apply-as-overlay precedence, the
personal `.local` layer, the legacy-directory fallback, and missing-file behavior). The verify
overlay carries verify-specific extensions for this project (preferred exploration patterns, key
areas to always check, domain-specific questions). If `shared.md` is absent, degrade gracefully:
read the phase overlay if present, otherwise proceed on command defaults.

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

  Add the domain to `PROFILE.md` at the resolved shared personal root (**Resolving the personal
  root** in `shared.md`'s Overlay Loading Protocol — `<personal-root>/.vine.local/PROFILE.md`, not
  cwd, so the profile is written and read at the same place from every worktree) with the selected
  level and today's date. If PROFILE.md doesn't exist there yet, create it with the format
  documented in `references/STATE.md`.

If no profile exists and the engineer hasn't confirmed a domain yet, do nothing — the prompt
happens naturally when the domain is confirmed during CONTEXT.md creation. No upfront questions.

## Before You Start

**Ask permissions mode recommended.** This is a cooperative framework — the engineer reviews every
change as it happens, not after the fact. If the session is running in Accept edits mode:

> "I'd recommend switching to Ask permissions mode so you can review what verify writes as we go.
> It's not required — want to continue in Accept edits?"

Don't block on this — if the engineer prefers Accept edits, proceed. The mode toggle is the
engineer's action: you can ask, never switch it yourself or assume it happened.

**Use AskUserQuestion for all decision points.** Never print markdown lists for the engineer to
respond to. Instead, use the `AskUserQuestion` tool to present interactive prompts. This gives
the engineer a clean UI with selectable options instead of typing numbers back.

Follow the Interaction Constraints from `.vine/context/shared.md` for every `AskUserQuestion` call.

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

**Start with prior judgment on record.** Before reading code, glob this domain's durable-decision
records — `.vine/knowledge/<domain>/` (and `.vine/knowledge/` broadly when the domain isn't pinned
down yet from step 1). These are the team's committed *judgment* about this area (format in
`references/STATE.md`, "Durable Decisions & Gotchas"): why past approaches were chosen over their
alternatives, gotchas that cost someone time. Present what you find in a dedicated **Durable
Decisions on record** subsection — each record's title, status, and gist — so you and the engineer
carry prior reasoning into the exploration instead of rediscovering it.

These records are *prior judgment, not current truth*. A record can read `Accepted` and still
describe a decision the code has since moved past. Where one appears to contradict what the live
code now does, **surface the mismatch for the engineer — never auto-trust the record** (consistent
with how verify treats every source: the contradiction call is the engineer's, not yours). A
still-live record is valuable context; a stale one is a signal worth a supersede when this cycle
reaches evolve.

**With no records present** — the common first-cycle case — this is a silent no-op: verify
proceeds exactly as it does today.

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

Most of these stay cataloged for inquire to weigh against the feature. But if something is
clearly unrelated to this feature and worth acting on regardless, apply the **Out-of-Scope
Routing** pattern from `.vine/context/shared.md` rather than letting it ride — backlog it by
default, or a `vine:pair` session for a small fix worth doing now.

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

Save this to a domain-namespaced directory. The path follows the pattern
`<root>/projects/<domain>/<feature-slug>/CONTEXT.md`, where `<root>` is `.vine/` for a shared
project (the default) or `.vine.local/` for a local one — the **Shared or local?** prompt below
decides which. The examples here show the shared default:

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

**Shared or local?** Once the domain and slug are confirmed, decide which root the project lives
under. Use `AskUserQuestion` (one question, per the Interaction Constraints in `shared.md`):

- **"Shared — commit with the repo (Recommended)"**: create under
  `.vine/projects/<domain>/<feature-slug>/`. This is the default — `.vine/` is tracked, so the
  artifacts travel with the repo and fit working in public. Most projects want this.
- **"Keep this local"**: create under `.vine.local/projects/<domain>/<feature-slug>/` instead. The
  `.vine.local/` root is gitignored entirely, so the project stays on this machine — nothing about
  it enters a commit. Use this for spikes, throwaway exploration, or work you're not ready to share.

Resolve `.vine.local/` at the shared personal root (the repo's primary worktree), per *The two
roots* in `references/STATE.md` — not cwd, so the choice holds across worktrees. Whichever root the
engineer picks, the rest of the cycle follows it automatically: discovery scans both roots, and the
per-path commit test (Sign-Off Gate, below) commits a shared project and skips a local one with no
special-casing.

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

When you and the engineer feel you have a solid understanding of the landscape, write
PROJECT-MAP.md alongside CONTEXT.md to track VINE progress for this feature:

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

### Sign-Off Gate

CONTEXT.md is written — now get explicit sign-off before handing to inquire. Don't infer approval
from the absence of objections; ask for it. This is the gate that closes verify, not a formality.

1. **Present the context for review.** Give the engineer a clickable link to the file (e.g.,
   `[CONTEXT.md](.vine/projects/<domain>/<feature-slug>/CONTEXT.md)`) so it opens rendered in their
   editor, plus a short summary of the landscape and the open questions that need resolution in
   inquire. (To open the file automatically, a repo can wire its editor's open command in
   `.vine/context/verify.md`; the clickable link is the portable default — don't shell out to an
   OS-specific opener yourself.)

2. **Gate on explicit sign-off.** Use `AskUserQuestion`:
   - **"Approve — hand to inquire (Recommended)"**: the context is ready to design against.
   - **"Request changes"**: something needs revision first.

   If the engineer requests changes, revise CONTEXT.md, re-present the link, and ask again. Loop
   until approved. The context isn't done until the engineer signs off.

Once approved:

1. If this feature directory is tracked (run `git check-ignore -q` against the **specific feature
   directory** — the per-path test in "Committing Artifacts", `references/STATE.md` — and it exits
   non-zero), commit CONTEXT.md and PROJECT-MAP.md now — this is their first entry into history. If
   the feature directory is gitignored (a local project under `.vine.local/projects/`), skip this
   step silently — personal-scope artifacts never enter a commit.
2. Persist actionable retro items before printing the completion block. The retro is
   conversation output and doesn't survive `/clear` — anything inquire should act on
   belongs in the relevant CONTEXT.md section (open questions, tribal knowledge,
   documentation gaps), not just the retro.
3. Suggest next step. Emit the block below per the Next-Step Suggestions convention in
   shared.md — plain chat text, with only the `/vine:inquire` command line in a fenced block.

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
