# Feature Spec: Multi-PR Tracking for Large Features
## Date: 2026-04-02
## Built on: CONTEXT.md (2026-04-02)
## Decisions made by: Rob

### Problem Statement
VINE's artifact chain assumes a single-PR lifecycle. Phase grouping exists in inquire and navigate as session boundaries, but there's no concept of tracking progress across multiple PRs for a larger feature. Engineers can't see at-a-glance where a multi-session feature stands, which phases have shipped, or what's next.

Additionally, there's no universal progress indicator for where a feature is in the VINE cycle (verify → inquire → navigate → evolve) — the only way to know is to check which artifacts exist.

### Approach

**PROJECT-MAP.md as universal progress tracker.** Every VINE project gets a PROJECT-MAP.md created by verify. It always contains a VINE Progress table showing which phases are complete. For multi-PR features, inquire adds a Milestones table mapping phase groups to PR status.

**Key decisions:**
- **New file, not SPEC extension** — PROJECT-MAP.md is a dedicated, scannable artifact. Doesn't bloat SPEC.md. (Rationale: the whole point is at-a-glance status; mixing it into SPEC defeats that.)
- **Table layout** — Compact, grep-friendly, works in monospace terminal. No section-per-phase verbosity.
- **Auto-flag + engineer override** — Inquire suggests multi-PR when >4 slices or phase groups exist. Engineer confirms or dismisses. No false automation.
- **1:1 phase-to-PR default with override** — Each phase group maps to one PR by default. Engineer can combine or split if needed.
- **Navigate suggests PR, doesn't create it** — Phase completion flow updates PROJECT-MAP and suggests opening a PR. Keeps navigate tactical.
- **Full evolve at end only** — No mini-evolves per phase. Evolve is the capstone.
- **Status markers** — ✅ Shipped, 🚧 Active, ⬜ Pending. Scannable, grep-friendly.

### Acceptance Criteria

1. **Verify creates PROJECT-MAP.md** when writing CONTEXT.md — VINE Progress table with verify=✅, rest=⬜
2. **Inquire updates PROJECT-MAP.md** — sets inquire→🚧 on start, ✅ on completion; if multi-PR flagged, adds Milestones table
3. **Navigate updates PROJECT-MAP.md** — sets navigate→🚧 on start; at phase boundaries (multi-PR), updates milestone status and suggests PR; sets navigate→✅ on completion
4. **Evolve updates PROJECT-MAP.md** — sets evolve→🚧 on start, ✅ on completion
5. **Resume reads PROJECT-MAP.md** — shows VINE Progress and Milestones in resume summary
6. **Pause reads PROJECT-MAP.md** — includes current VINE phase in pause context
7. **Inquire auto-flags multi-PR** — when >4 slices or phase grouping, asks engineer; engineer can override
8. **STATE.md documents PROJECT-MAP.md** — full artifact definition with format, lifecycle, status markers
9. **Backward compatible** — projects without PROJECT-MAP.md work identically; no errors, no warnings
10. **Navigate phase completion flow** — at phase group boundaries, writes NAVIGATION.md, updates PROJECT-MAP milestone row, adds status marker to SPEC.md phase, suggests opening PR

### Work Slices

#### Slice 1: STATE.md — Define PROJECT-MAP.md Artifact
- **Goal**: Add PROJECT-MAP.md definition to STATE.md with format template, lifecycle rules, and status marker definitions
- **Depends on**: Nothing
- **Files likely touched**: `references/STATE.md`
- **Acceptance criteria**: PROJECT-MAP.md documented with VINE Progress table, optional Milestones table, three status markers defined, lifecycle (created by verify, updated by each phase, Milestones added by inquire)
- **Complexity signal**: Low — adding a new section to an existing reference doc

#### Slice 2: verify.md — Create PROJECT-MAP.md
- **Goal**: Verify writes PROJECT-MAP.md alongside CONTEXT.md at phase completion
- **Depends on**: Slice 1 (format defined in STATE.md)
- **Files likely touched**: `commands/vine/verify.md`
- **Acceptance criteria**: Verify creates PROJECT-MAP.md with feature name, feature path, VINE Progress table (verify=✅, inquire/navigate/evolve=⬜). No Milestones table at this point. Existing verify flow unchanged for readability.
- **Complexity signal**: Low — adding a write step to verify's completion block

#### Slice 3: inquire.md — Multi-PR Flag + PROJECT-MAP Update
- **Goal**: Inquire updates its status in PROJECT-MAP.md, auto-detects multi-PR candidates, adds Milestones table when confirmed
- **Depends on**: Slice 1 (format), Slice 2 (PROJECT-MAP.md exists)
- **Files likely touched**: `commands/vine/inquire.md`
- **Acceptance criteria**: (a) Reads PROJECT-MAP.md if present, updates inquire→🚧 on start, ✅ on completion. (b) After step 6b (phase grouping), if >4 slices or phase groups exist, uses AskUserQuestion to ask about multi-PR treatment. (c) If confirmed, writes Milestones table to PROJECT-MAP.md with all phases as ⬜ Pending. (d) SPEC.md phase group headers get status markers (⬜ by default). (e) If no PROJECT-MAP.md exists, proceed normally — backward compatible.
- **Complexity signal**: Medium — new step between 6b and 7, conditional PROJECT-MAP writes, AskUserQuestion integration

#### Slice 4: navigate.md — Phase Completion Flow + PROJECT-MAP Updates
- **Goal**: Navigate updates its status in PROJECT-MAP.md and offers a phase completion flow at group boundaries for multi-PR features
- **Depends on**: Slice 1 (format), Slice 3 (Milestones table may exist)
- **Files likely touched**: `commands/vine/navigate.md`
- **Acceptance criteria**: (a) Reads PROJECT-MAP.md if present, updates navigate→🚧 on start. (b) Step 9 (Between Phase Groups) is expanded: if PROJECT-MAP.md has a Milestones table, update the completed phase row to ✅ Shipped, update SPEC.md phase header with ✅ marker, suggest opening a PR. (c) Final completion block updates navigate→✅. (d) If no PROJECT-MAP.md or no Milestones table, current behavior unchanged.
- **Complexity signal**: Medium — reworking step 9, adding PROJECT-MAP reads/writes, keeping backward compat

#### Slice 5: evolve.md — Multi-PR Awareness
- **Goal**: Evolve reads PROJECT-MAP.md for context, updates its status, and references milestone progress in the handoff package
- **Depends on**: Slices 1-4
- **Files likely touched**: `commands/vine/evolve.md`
- **Acceptance criteria**: (a) Reads PROJECT-MAP.md if present, updates evolve→🚧 on start, ✅ on completion. (b) If Milestones table exists, reads it to understand which phases shipped in prior PRs. (c) Handoff package includes a "Multi-PR Summary" section referencing PROJECT-MAP when applicable. (d) If no PROJECT-MAP.md, proceed normally.
- **Complexity signal**: Low-Medium — reading + status update + minor handoff section

#### Slice 6: pause.md + resume.md — PROJECT-MAP Awareness
- **Goal**: Resume shows PROJECT-MAP progress in its summary; pause includes current VINE phase from PROJECT-MAP
- **Depends on**: Slice 1 (format)
- **Files likely touched**: `commands/vine/pause.md`, `commands/vine/resume.md`
- **Acceptance criteria**: (a) Resume reads PROJECT-MAP.md if present and includes VINE Progress table + Milestones (if present) in the status summary. (b) Pause reads current VINE phase from PROJECT-MAP.md when available (falls back to artifact detection if not). (c) If no PROJECT-MAP.md, both commands work identically to today.
- **Complexity signal**: Low — reading existing data and including in output

### Tech Debt Integration

**Addressed now:**
- Phase grouping in inquire (step 6b) and navigate (step 9) are underspecified → fully fleshed out with multi-PR awareness, status markers, and PR suggestions
- No size estimation in the flow → inquire gets auto-flag heuristic for multi-PR detection

**Addressed during:**
- SPEC.md has no "as-shipped" annotations → navigate adds status markers to SPEC.md phase headers as phases complete

**Deferred:**
- No SPEC.md versioning beyond status markers — full versioning would add complexity without clear payoff for this feature

### Dependencies & Risks

- **No external dependencies** — all changes are markdown edits to command files and STATE.md
- **Risk: Scope creep in navigate step 9** — the phase completion flow adds significant new behavior. Keep it focused on: write NAVIGATION.md, update PROJECT-MAP, suggest PR. Don't add PR creation logic.
- **Risk: Backward compatibility** — every PROJECT-MAP.md read must be guarded with "if it exists." Commands must work identically without it.

### Backlog Updates

- **New: `vine:status` command** — lightweight command that reads PROJECT-MAP.md and shows progress. Currently resume does this, but standalone status would be useful.
- **New: PR # backfill** — resume could prompt for missing PR numbers on shipped phases. Deferred from this work.
- **New: `glow` rendering hook** — shared hook could suggest `glow -w 100` for PROJECT-MAP terminal rendering.
