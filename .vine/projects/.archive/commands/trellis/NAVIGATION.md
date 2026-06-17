# Navigation: vine:trellis — Command Structure Validation
## Started: 2026-03-27

### Slice 1: Scaffold + Frontmatter Validation — Complete
**Started**: 2026-03-27
**Commit**: cfb2eee (cherry-picked from a2eb320 after branch move)
**Approach taken**: Created `commands/vine/trellis.md` with proper frontmatter, H1 title, and 4-step validation flow. Frontmatter parsing described as text-pattern matching (Check 1: fields present, Check 2: name matches filename). Built the known tool list derivation (Step 2) as foundation for later checks.
**Deviations from spec**: Added trellis itself as an exception alongside init for hook/profile checks (AC 11 only mentioned init). Decision made during implementation.
**Validation**: pass — re-read full file, verified document flow and frontmatter structure
**Decisions made during implementation**:
  - Exempt trellis from hook/profile checks alongside init: trellis is VINE-repo-only and doesn't need hooks or profile context (decided by: engineer)
**Acceptance criteria**:
  - [x] AC 1: commands/vine/trellis.md exists with valid YAML frontmatter
  - [x] AC 2: Reads all .md files in commands/vine/ and validates each
  - [x] AC 3: Frontmatter checks — all 4 required fields present; name matches vine:<filename>
**Engineer feedback incorporated**: Confirmed trellis exemption approach over alternatives (add hooks to trellis, or fail-and-document)
**Learnings**:
  - Engineer → Claude: Self-referential validation tools need to account for their own exceptional status
  - Claude → Engineer: The known tool list derivation (union across all commands) avoids maintaining a separate config

### Slice 2: Structural Checks — Complete
**Started**: 2026-03-27
**Commit**: 0e8ac73 (cherry-picked from d10f7c7 after branch move)
**Approach taken**: Refinement pass on all 7 checks from Slice 1. Tightened H1 check wording, defined section boundaries for hook reference search, replaced circular tool-union logic with 3 concrete sub-checks (well-formed, non-empty, known). Added new Check 6 (section ordering) to enforce hooks-before-profile convention.
**Deviations from spec**: Added section ordering check (not in original AC). Annotated in SPEC.md as AC 8b.
**Validation**: pass — re-read full file, verified document flow and check numbering
**Decisions made during implementation**:
  - Add section ordering check: enforces CLAUDE.md convention that hooks load before profile (decided by: claude, confirmed by engineer via approval)
**Acceptance criteria**:
  - [x] AC 4: H1 follows pattern
  - [x] AC 5: Hook section with phase-specific reference
  - [x] AC 6: Profile section heading
  - [x] AC 7: Tool list well-formed, non-empty, known
  - [x] AC 8: AskUserQuestion in body
  - [x] AC 11: init and trellis exempted
**Engineer feedback incorporated**: None needed — refinement pass on existing structure
**Learnings**:
  - Claude → Engineer: Section boundary definition (between `##` headings) makes text-pattern checks much more reliable than "within that section"

### Slice 3: Output Table + Self-Validation — Complete
**Started**: 2026-03-27
**Commit**: 43ac577
**Approach taken**: Added explicit self-validation callout in Step 1 ("eats its own cooking"). Clarified that skipped checks count as passing in summary line. Table and summary format were already in place from Slice 1 — this was a polish pass.
**Deviations from spec**: None
**Validation**: pass — re-read full file, verified document flow
**Decisions made during implementation**: None — straightforward
**Acceptance criteria**:
  - [x] AC 9: Summary table with ✅/❌/skip marks
  - [x] AC 10: Pass/fail summary line
  - [x] AC 12: Trellis validates itself as part of the run
**Engineer feedback incorporated**: None needed
**Learnings**:
  - Claude → Engineer: Implicit self-inclusion (glob catches everything) is fragile — explicit callout prevents future commands from accidentally filtering themselves out

### Discovered Items
- **navigate.md branch step**: Added step 2 (create feature branch) to vine:navigate. Committed separately (1d4ee35). This was discovered when trellis commits landed on the wrong branch.
