# Evolution Report: Engineer Profile
## Date: 2026-03-27

### Product Evolution

#### Acceptance Criteria Results

| # | Criterion | Status |
|---|-----------|--------|
| 1 | Profile is fully opt-in | Pass — all commands work identically without PROFILE.md |
| 2 | Init seeds profile | Pass (revised) — init informs about profile concept, no interactive rating |
| 3 | Verify re-prompts | Pass — loads profile, offers to add missing domains via AskUserQuestion |
| 4 | Inquire loads profile | Pass — reads profile, sets depth hint |
| 5 | Navigate loads profile | Pass — reads profile, sets depth hint with level-specific narration guidance |
| 6 | Evolve suggests updates | Pass — proposes domain changes and growth log via AskUserQuestion |
| 7 | Evolve suggests Claude updates | Pass — proposes Claude memory and CLAUDE.md entries |
| 8 | STATE.md documents PROFILE.md | Pass — new Per-Repo Artifacts section with full format spec |
| 9 | README documents the feature | Pass — explains layered model, lists PROFILE.md, mentions four levels |

#### Spec Deviations

| Deviation | Slice | Justified | Impact |
|-----------|-------|-----------|--------|
| Init changed from interactive domain rating to informational introduction | 2 | Yes — engineer's call based on real friction with large repos | None — profile builds organically through verify. Better UX. |

#### Follow-Up Items

1. **Artifact format validation** — Nothing checks PROFILE.md structure. Failure = graceful fallback, so low priority.
2. **Bug report template update** — Add profile state to issue template if profile-related bugs are reported.
3. **Hook-loading repetition** — 5 commands each have ~16 lines of hook + profile loading. Revisit if a 6th command is added.
4. **Domain name fuzzy matching** — Exact match only. Could enhance if engineers report friction with mismatched domain names.

### Agent Evolution

#### CLAUDE.md Updates

Created `CLAUDE.md` with four sections (all accepted by engineer):
- Repo conventions (pure markdown, editing commands changes the tool)
- VINE artifact conventions (state chain, directory structure)
- Command authoring conventions (frontmatter, hooks, profile loading, AskUserQuestion patterns)
- Depth hint pattern documentation

#### Skill Suggestions

**`add-command-section`** — accepted for future creation
- When triggered: Adding a new section to all 5 command files
- What it does: Scaffolds the block in all commands with consistent formatting
- Estimated value: Saves ~20 min per cross-command addition, prevents drift

**`vine:dogfood`** — accepted for future creation
- When triggered: After modifying VINE commands using VINE
- What it does: Validates command structure (frontmatter, hooks, AskUserQuestion patterns)
- Estimated value: Catches structural issues before testing on real repos

#### Hook Updates Applied

- **evolve.md**: Added CLAUDE.md check reminder and doc growth guardrail
- **navigate.md**: Added reminder to preserve Load Engineer Profile blocks when modifying commands

#### VINE Process Observations

- No meta-friction this cycle — slices were scoped to one file each, avoiding the "editing the tool while it guides you" problem
- Navigate's per-slice commits let evolve trust the history completely
- The verify → inquire handoff was strong — CONTEXT.md captured the design pivot cleanly
- Slice 2's deviation was handled well with spec strikethroughs and revised criteria

### User Evolution

#### Knowledge Highlights

Strong architectural instinct on display: recognized that a comprehensive VINE user profile would duplicate Claude's native memory system, and redirected scope to the one gap (per-domain expertise tracking). Also caught a UX friction point the spec missed — domain rating at init hurts adoption for large repos — showing practical tool-design thinking.

#### Suggested Explorations

1. **Progressive disclosure patterns** — The depth hint system is a lightweight version. VS Code's settings UI and Stripe's API docs are good case studies for how other tools layer complexity based on user expertise.
2. **Self-modifying tool design** — VINE editing VINE is an interesting design challenge. Emacs's self-documenting design and Smalltalk's live editing both deal with "editing the tool while using the tool."

### Handoff Package

#### PR Description

```markdown
## Summary

Add an engineer profile system to VINE that tracks per-domain expertise across cycles. Commands adjust explanation depth based on the engineer's familiarity with a codebase domain — more context where they're learning, more concise where they're confident.

Uses a layered model: VINE tracks domain expertise (`.vine/PROFILE.md`), while Claude's native memory handles general preferences.

## Changes

- eeb1222 Define PROFILE.md format in STATE.md
- f0ff847 Add profile introduction to vine:init
- f1d1a36 Add profile loading and domain re-prompt to vine:verify
- 8bd2165 Add profile loading to vine:inquire
- 8793dd4 Add profile loading to vine:navigate
- aeb2fd2 Add profile updates and Claude memory suggestions to vine:evolve
- d6a4dac Document engineer profile in README
- ea37958 Clarify profile intent: AI accelerates cross-domain work at every level

## Decisions Made

- **Layered profile model**: VINE tracks domain expertise only; Claude handles general preferences. Avoids duplication.
- **Organic seeding**: No upfront domain rating at init (too much friction for large repos). Profile builds through vine:verify as engineers work in domains.
- **Exact domain matching**: Simple and predictable. Fuzzy matching deferred.
- **Self-contained commands**: Each command has its own profile loading block (~8 lines). Intentional repetition for Claude consumption.

## Testing

- Each slice validated during navigate (frontmatter, document flow, cross-references)
- Cross-slice integration verified during evolve: consistent profile loading blocks, correct allowed-tools, data flow from init → verify → inquire/navigate → evolve
- No runtime code — testing means running modified commands on real repos

## Follow-up

- Artifact format validation (low priority — graceful fallback on parse failure)
- Bug report template update (when profile-related bugs are reported)
- Two potential skills identified: `add-command-section`, `vine:dogfood`
```

#### Reviewer Notes

- This is a pure-markdown change (251 lines added across 7 files). No runtime behavior to test — review focuses on command clarity and consistency.
- The "Load Engineer Profile" block appears in 4 commands with intentionally identical structure. This is by design, not a DRY violation — each command file needs to be self-contained for Claude consumption.
- The depth hint is written for Claude, not shown to the engineer. It adjusts AI behavior without visible "you're a beginner" messaging.
- `.vine/PROFILE.md` is gitignored by default — it's a local artifact like `.vine/hooks/`.
- Key context from CONTEXT.md: the original design was a comprehensive user profile at `~/.vine/PROFILE.md`. It was scoped down to per-repo domain tracking after realizing Claude's memory system already covers general preferences.
