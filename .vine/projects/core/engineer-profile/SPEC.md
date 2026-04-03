# Feature Spec: Engineer Profile
## Date: 2026-03-27
## Built on: CONTEXT.md (2026-03-27)
## Decisions made by: Rob

### Problem Statement

VINE claims to grow "the user" but has no persistent artifact backing that claim. Evolve captures growth observations per cycle but they die in EVOLUTION.md — nothing carries forward across cycles. Every command treats all engineers identically regardless of their familiarity with specific codebase domains.

The goal: help engineers at every level grow in areas both new and familiar. With AI assistance, engineers — juniors to principals — are moving into unfamiliar domains at increasing speed. A principal exploring a new area deserves the same depth as a junior encountering it for the first time; a junior confident in their domain deserves the same concise respect as a senior. The profile tracks domain expertise, not seniority, so VINE meets each engineer where they are.

### Approach

**Layered profile model:**
1. **VINE layer** (`.vine/PROFILE.md`): Repo-domain expertise and growth log — "confident in auth, learning payments"
2. **Claude layer** (memory + CLAUDE.md): General preferences, interaction style, learning patterns — suggested by vine:evolve

This avoids duplicating what Claude already handles (global memory for preferences, project memory for context, CLAUDE.md for instructions). VINE focuses on what Claude doesn't cover: per-domain expertise tracking based on actual VINE cycles.

**Key decisions and rationale:**

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Location | Per-repo at `.vine/PROFILE.md` | Domain expertise is repo-specific |
| Format | Markdown table + growth log | Scannable, parseable, editable |
| Seeding | Init Step 5 + verify re-prompt | Init offers first creation; verify catches gaps |
| Updates | Evolve suggests, engineer applies | Human-decides philosophy |
| Domain matching | Exact match only | Simple, predictable, no fuzzy logic |
| Explanation depth | Light nudge (one sentence) | Inform commands without over-constraining |
| Agent framing | Claude-specific | VINE is a Claude Code tool; adapt if porting |
| Growth log | Grows indefinitely | History is valuable; volume is low |
| Hook-loading repetition | Accept consciously | Self-contained commands are better for Claude |
| Artifact validation | Defer to backlog | Profile format is simple enough |

**PROFILE.md format:**

```markdown
# Engineer Profile

## Domain Expertise

| Domain | Level | Last Updated | Notes |
|--------|-------|--------------|-------|
| auth | confident | 2026-03-15 | Built OAuth integration |
| payments | learning | 2026-03-27 | First cycle in progress |

## Growth Log

### 2026-03-27 — payments/webhook-support
- Explored webhook validation patterns
- First exposure to idempotency keys
```

**Expertise levels:** confident, familiar, learning, new

**Depth hint pattern** (one sentence, used by verify/inquire/navigate):
> "The engineer's profile indicates they are [level] with the [domain] domain. Adjust your explanation depth accordingly — be concise where they're confident, explain the why behind decisions where they're learning or new."

If no profile exists or the domain isn't listed, commands behave exactly as they do today — no hint, no warning.

### Acceptance Criteria

1. **Profile is fully opt-in**: Every command works identically without PROFILE.md. No errors, no warnings, no degraded behavior.
2. **Init seeds profile**: Step 5 offers to create PROFILE.md using domains discovered in Step 1. Uses AskUserQuestion for domain rating. Skippable.
3. **Verify re-prompts**: Loads profile after hooks. If the current feature's domain isn't in the profile, offers to add it. Sets depth hint for exploration.
4. **Inquire loads profile**: Reads profile after hooks. Sets depth hint for design discussion.
5. **Navigate loads profile**: Reads profile after hooks. Sets depth hint for narration (biggest consumer).
6. **Evolve suggests updates**: Proposes domain level changes and growth log entries via AskUserQuestion. Engineer approves. Writes accepted changes to PROFILE.md.
7. **Evolve suggests Claude updates**: Separately proposes Claude memory entries and CLAUDE.md lines based on cycle learnings. Claude-specific framing.
8. **STATE.md documents PROFILE.md**: New section covering format, lifecycle, and relationship to per-feature artifacts.
9. **README documents the feature**: Explains the layered model, lists PROFILE.md as an artifact.

### Work Slices

#### Slice 1: Define PROFILE.md format in STATE.md
**Goal**: Document the PROFILE.md artifact — format, lifecycle, relationship to per-feature artifacts
**Depends on**: Nothing
**Files likely touched**: `references/STATE.md`
**Acceptance criteria**: STATE.md has a PROFILE.md section with format spec, four expertise levels defined, growth log format shown
**Complexity signal**: Low — adding a new section to an existing reference doc

#### Slice 2: Add profile seeding to vine:init
~~**Goal**: New Step 5 — offer to create PROFILE.md using discovered repo structure~~
**Goal (revised)**: New Step 5 — inform engineer about the profile concept. No domain rating at init time.
**Depends on**: Slice 1 (format defined)
**Files likely touched**: `commands/vine/init.md`
~~**Acceptance criteria**: Init offers profile creation after hooks are generated. Uses AskUserQuestion to present discovered domains and let engineer rate them. Creates PROFILE.md in documented format. Entire step is skippable.~~
**Acceptance criteria (revised)**: Init mentions the profile concept after hooks are generated. No AskUserQuestion for domain rating — that moves to vine:verify. Output section references PROFILE.md.
**Complexity signal**: Low — informational step, no interactive seeding
**Deviation**: Engineer decided domain rating at init hurts momentum for repos with many domains. Profile builds organically through vine:verify instead.

#### Slice 3: Add profile loading + re-prompt to vine:verify
**Goal**: Verify loads PROFILE.md after hooks, checks for missing domains, offers to add them
**Depends on**: Slice 1
**Files likely touched**: `commands/vine/verify.md`
**Acceptance criteria**: Verify reads profile after hook loading. If the current feature's domain isn't in the profile, offers to add it via AskUserQuestion. Sets one-sentence depth hint. Works fine without profile.
**Complexity signal**: Medium — new loading block plus re-prompt logic

#### Slice 4: Add profile loading to vine:inquire
**Goal**: Inquire loads PROFILE.md after hooks, uses depth hint for design discussion
**Depends on**: Slice 1
**Files likely touched**: `commands/vine/inquire.md`
**Acceptance criteria**: Inquire reads profile after hook loading. Sets depth hint for design explanations. Works fine without profile.
**Complexity signal**: Low — loading block plus one-line hint, follows same pattern as other commands

#### Slice 5: Add profile loading to vine:navigate
**Goal**: Navigate loads PROFILE.md after hooks, adjusts narration depth
**Depends on**: Slice 1
**Files likely touched**: `commands/vine/navigate.md`
**Acceptance criteria**: Navigate reads profile after hook loading. Sets depth hint for implementation narration. Works fine without profile.
**Complexity signal**: Low-Medium — loading block plus hint, but navigate has the most narration guidance to integrate with

#### Slice 6: Add profile update + Claude memory suggestions to vine:evolve
**Goal**: Evolve suggests PROFILE.md edits and Claude memory/CLAUDE.md updates
**Depends on**: Slice 1
**Files likely touched**: `commands/vine/evolve.md`
**Acceptance criteria**: Evolve proposes domain level changes and growth log entries via AskUserQuestion. Writes accepted changes to PROFILE.md. Separately suggests Claude memory entries and CLAUDE.md lines. Enriches the existing User Evolution section with concrete actions.
**Complexity signal**: Medium-High — most new behavior, extends existing thin section with two concrete output types

#### Slice 7: Update README.md
**Goal**: Document the profile feature for users
**Depends on**: All previous slices (needs final shape)
**Files likely touched**: `README.md`
**Acceptance criteria**: README explains the layered profile model, lists PROFILE.md in artifacts, mentions the four expertise levels
**Complexity signal**: Low — documentation addition to existing README

### Tech Debt Integration

**Addressed during this work:**
- **Evolve User Evolution is thin** (lines 201-230): Adding profile suggestions and Claude memory suggestions gives this section concrete, actionable output instead of just reflection.
- **STATE.md missing PROFILE.md**: Adding a new section for the per-repo artifact.

**Consciously accepted:**
- **Repeated loading blocks**: Each command gets its own "Load Engineer Profile" block (~8 lines). Self-contained commands are better for Claude consumption than factored-out shared preambles.

**Deferred to backlog:**
- **No artifact format validation**: Nothing checks that PROFILE.md matches expected structure. Profile format is simple enough (markdown table) that this isn't blocking. Add validation if parsing issues emerge.
- **Issue template gap**: Bug report template doesn't ask about profile state. Low priority — add when/if profile-related bugs are reported.

### Dependencies & Risks

- **No external dependencies.** Pure markdown changes to command files.
- **Risk: profile parsing fragility.** Commands need to extract domain + level from a markdown table. If the engineer edits PROFILE.md into an unexpected format, parsing could fail. Mitigation: the format is simple, and the opt-in design means failure = no profile = commands work as today.
- **Risk: depth hints feel patronizing.** "You're new to this domain" could read badly. Mitigation: hints are written for Claude, not shown to the engineer. They adjust behavior, not visible output.

### Backlog Updates

- **New: artifact format validation** — consider adding lightweight structural checks for all VINE artifacts (PROFILE.md, CONTEXT.md, SPEC.md, etc.)
- **New: issue template update** — add profile state to bug report template when profile-related bugs are reported
- **Existing: hook-loading repetition** — consciously accepted; revisit if a 6th command is added
