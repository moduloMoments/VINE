---
name: vine:verify
description: "Context-building spike — explore the codebase together before designing or building"
argument-hint: "[feature description, e.g., 'webhook support for payments']"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Agent
  - WebFetch
---

# vine:verify — Context Building Spike

## Before You Start

**VINE requires approve-edits mode.** This is a cooperative framework — the engineer reviews every
change as it happens, not after the fact. If the session is running in auto-accept mode, suggest
switching before proceeding. The whole point is that both human and AI stay engaged with every
decision.

**Use structured questions throughout.** Whenever you're asking the engineer to make a choice,
present it as a structured select or multi-select rather than an open-ended question. This keeps
the flow tight and makes decisions explicit. Use single-select for mutually exclusive choices
(architecture direction, which pattern to follow) and multi-select for inclusive ones (which tech
debt items to address, which areas to explore). Always include a recommendation with brief
rationale, and always offer an "other" escape hatch for when none of your options fit. Example:

> **Which areas should we explore first?** (select all that apply)
> 1. Payment processing pipeline (recommended — most affected by this feature)
> 2. Notification service integration
> 3. Database migration history
> 4. Other: ___

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

Once you have direction, explore the relevant code. For each area:

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

Save this to a domain-namespaced directory under `.vine/`. The path follows the pattern:
`.vine/<domain>/<feature-slug>/CONTEXT.md`

The domain is the root area or module the feature lives in — not the repo name, but the
logical domain the work touches. For example:
- `.vine/payments/webhook-support/CONTEXT.md`
- `.vine/payments/retry-logic/CONTEXT.md`
- `.vine/auth/sso-migration/CONTEXT.md`
- `.vine/onboarding/welcome-flow/CONTEXT.md`

This two-level namespacing gives you collision prevention (multiple features in the same domain)
and discoverability (see all VINE work in a domain at a glance). It also survives across repos
if you work on the same domain in different services.

When starting, present the engineer with a structured choice for the domain and feature slug.
Use a select prompt to suggest likely domains based on the codebase areas discussed, with an
option to enter a custom one:

> **What domain does this feature belong to?**
> 1. payments (based on the modules we explored)
> 2. auth
> 3. [enter custom domain]
>
> **Feature slug?** (short, lowercase, hyphenated)
> Suggestion: `webhook-support`

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

1. Review CONTEXT.md together — make sure nothing's missing
2. Highlight the open questions that need resolution in inquire
3. Suggest next step:

```
---
✅ vine:verify complete → CONTEXT.md written to .vine/<domain>/<feature-slug>/CONTEXT.md
📋 Suggested next step: Run `vine:inquire` to build the feature spec.
   Key items to address:
   - [open question 1]
   - [open question 2]
   - [tech debt decision needed]

🔄 Start a fresh session for vine:inquire. Verify is exploratory — inquire
   needs a clean, decisive headspace. CONTEXT.md carries everything forward.

🌱 Phase retro:
   - CLAUDE.md suggestion: [any project-level context worth persisting]
   - Skill suggestion: [any repeated pattern worth codifying]
   - User note: [anything the engineer mentioned wanting to learn more about]
---
```

The retro block at the end is part of VINE's evolution philosophy. Every phase is an opportunity
to improve three things: the product, the agent's knowledge, and the user's growth.
