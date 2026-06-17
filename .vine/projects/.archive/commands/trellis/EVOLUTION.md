# Evolution Report: vine:trellis — Command Structure Validation
## Date: 2026-03-27

### Product Evolution

#### Acceptance Criteria Results

| AC | Description | Status |
|----|-------------|--------|
| 1  | trellis.md exists with valid frontmatter | Pass |
| 2  | Reads all .md files in commands/vine/ | Pass |
| 3  | Frontmatter checks (4 fields, name match) | Pass |
| 4  | H1 follows pattern | Pass |
| 5  | Hook section with phase-specific reference | Pass |
| 6  | Profile section heading | Pass |
| 7  | Tool list well-formed, non-empty, known | Pass |
| 8  | AskUserQuestion in body | Pass |
| 8b | Section ordering (hooks before profile) | Pass |
| 9  | Summary table with marks | Pass |
| 10 | Pass/fail summary line | Pass |
| 11 | Init and trellis exempted | Pass |
| 12 | Trellis validates itself | Pass |

**Cross-slice integration**: Ran trellis checks manually against all 6 commands. 6/6 pass all applicable checks. Known tool union correctly derives 9 tools. Init/trellis exceptions work. Section ordering enforcement works.

#### Spec Deviations

1. **Trellis exempted alongside init** (Slice 1) — AC 11 only mentioned init. Justified: trellis is VINE-repo-only and doesn't need hooks/profile loading. No stakeholder impact.
2. **Section ordering check added** (Slice 2) — Not in original spec, annotated as AC 8b. Justified: enforces the CLAUDE.md convention that hooks load before profile. Strengthens the tool.

#### Follow-Up Items

- **Update CONTRIBUTING.md** to mention `vine:trellis` as a pre-PR structural check
- **Update Issue #4** (vine:dogfood) to reference the vine:trellis naming
- **STATE.md validation** — natural next enhancement for trellis (deferred from v1 scope)
- **Consider CLAUDE.md update** to list valid tool names explicitly (trellis derives them, but documenting is nice)

### Agent Evolution

#### CLAUDE.md Updates (Accepted)

All 4 suggestions accepted and applied:
- Updated command count from 5 to 6 (two locations)
- Documented init/trellis as exceptions for hook/profile loading
- Added section ordering convention (hooks before profile)
- Added note to run `/vine:trellis` before submitting changes

#### Additional Updates Applied

- **README.md**: Added note that trellis is copied but only useful in the VINE repo
- **shared.md hook**: Updated command list and command count to include trellis

#### Skill Suggestions

None. Trellis itself is the reusable tool born from this feature — no other repeatable workflow pattern emerged.

#### VINE Process Observations

- **Navigate was missing a branch creation step.** Discovered when trellis commits landed on the wrong branch. Fixed in commit 1d4ee35. Signal that navigate's "getting started" could be more thorough about workspace setup.
- **Self-referential validation works well.** Trellis eating its own cooking is a good pattern for framework repos — it catches structural drift immediately.
- **The verify-inquire-navigate flow was smooth** for this feature. No phase felt too heavy or too light for a single-file utility command.

### User Evolution

#### Knowledge Highlights

This feature was in your comfort zone — you designed the structural conventions and know the command files well. Clean decisions throughout: the trellis exemption was a good call, and adding section ordering enforcement shows good instinct for codifying implicit conventions. The branch issue catch mid-flight led to a useful navigate improvement.

#### Suggested Explorations

None — this was a utility feature, not a learning-edge feature. The next trellis enhancement (STATE.md validation) could be more interesting territory.

### Handoff Package

#### PR Description

```markdown
## What

Add `vine:trellis` — a structural validation command that checks all VINE command files
against the conventions documented in CLAUDE.md (frontmatter, H1 format, hook/profile
sections, tool lists, section ordering).

## Why

VINE's conventions are documented but enforced nowhere. Cross-command changes (like the
recent engineer profile addition) can drift silently. Trellis gives contributors a fast
structural check before submitting PRs.

Closes #4

## Changes

- cfb2eee Scaffold vine:trellis with frontmatter validation
- 0e8ac73 Refine structural checks: precision, ordering, tool validation
- 43ac577 Add self-validation callout and clarify output formatting
- 1d4ee35 Add feature branch creation step to vine:navigate (discovered during trellis work)

## How to test

1. Run `/vine:trellis` in the VINE repo — should show 6/6 commands passing
2. Intentionally break a command's frontmatter and re-run — should catch the issue
3. Verify trellis validates itself (appears in its own output table)

## Checklist

- [x] I've tested this in an actual VINE cycle (trellis was built using VINE on VINE)
- [x] Changes are focused on a single concern (structural validation)
- [x] Any new behavior is documented in the README or command file
```

#### Reviewer Notes

- Trellis is intentionally VINE-repo-only — it validates the framework's own command files, not user projects. It's exempted from hook/profile loading alongside init.
- The known tool list is derived dynamically (union across all commands), so adding a new tool to any command automatically makes it valid for all. No external config to maintain.
- The navigate.md change (branch creation step) is a separate commit but was discovered during this work — review independently.
- Section ordering check (AC 8b) was added during implementation, not in the original spec. It enforces an existing CLAUDE.md convention.
