# Feature Spec: Phase Discipline (Navigate Completion + Partnership Model)
## Date: 2026-04-02
## Built on: CONTEXT.md (2026-04-02)
## Decisions made by: Rob

### Problem Statement

Two discipline gaps weaken the VINE cycle:

1. **Navigate can suggest evolve before NAVIGATION.md is complete.** The Phase Completion block has no gate — it fires when slices are "done" but doesn't verify the journal reflects reality (commit hashes, validation, acceptance criteria, learnings).

2. **The profile system's depth hint is too mechanical.** It frames expertise as "explain more or less" when the real goal is evolve's triple evolution philosophy: treat the engineer as a trusted pairing partner, learn from them, and help them grow. This philosophy should permeate the whole flow, not just live in evolve.

### Approach

**Navigate structural fix:** Merge the separate "Document as You Go" step (step 5) into the commit flow (step 4), making NAVIGATION.md updates inseparable from committing. Add a hard gate check to Phase Completion that verifies completeness before suggesting evolve — listing gaps and fixing inline when found.

**Collaboration stance (philosophy + concrete behaviors):** Replace the passive depth hint in "Load Engineer Profile" across all 7 commands with a stance that has two parts: a one-line philosophical anchor and specific behavioral rules. The philosophy says *what to value* ("this is a partnership, both sides grow"). The behaviors say *what to do*:

1. **Flag your own uncertainty.** When you're unsure about a pattern, module, or convention, say so. Don't present uncertain approaches with false confidence. The engineer is a resource — use them.
2. **Grow through the work, not around it.** When you use a pattern the engineer might not know, name it and say why it fits *as you write the code*. When the engineer corrects you, acknowledge what you learned, not just what you changed. Growth happens in the narration, not in retrospective check-ins.
3. **Let expertise shape engagement.** Use the profile's domain level to calibrate: concise where they're confident, explanatory where they're learning. But expertise is contextual — a confident engineer in unfamiliar code still needs the partnership.

The behavioral weight concentrates in navigate (where the partnership plays out). Evolve already nails the philosophy and stays untouched as the reference implementation.

**Per-slice gearing:** At each slice preview (step 3a), the engineer chooses the engagement level: "run with it" (lighter narration, fewer pauses — Claude cranks) or "walk me through this" (full partnership narration). Per-slice because confidence depends on both domain expertise *and* the specific code. The profile's expertise level informs the default recommendation but the engineer always decides.

When the engineer chose partnership mode, the Between Slices flow includes a brief reflection on what both sides learned during the slice. When they chose "run with it," the reflection is skipped — they signaled they don't need it.

### Key Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Gate check severity | Hard gate, inline fix | Lists gaps and helps fix them — disciplined without being obstructive |
| NAVIGATION.md timing | Merged into step 4 | Can't commit without updating the journal — eliminates the skip path |
| Profile creation paths | Verify-only | Keep the feature opt-in by design |
| Stance format | Philosophy + concrete behaviors | Philosophy says what to value; behaviors say what to do. Agents need both. |
| Philosophy location | Lean in profile, heavy in navigate | Concentrate behavioral specifics where the partnership plays out |
| Evolve changes | None | Already the reference implementation for triple evolution |
| "Run with it" mode | Per-slice gear, not session-wide | Confidence depends on domain + specific code; let the engineer choose per slice |
| Check-ins | Tied to gearing | Check-ins happen in partnership mode, skip in "run with it" — no separate opt-out needed |

### Acceptance Criteria

1. Navigate step 4 includes updating the slice's NAVIGATION.md entry (approach, commit hash, validation, acceptance criteria, learnings) as a prerequisite before committing
2. Navigate step 5 ("Document as You Go") no longer exists as a separate section — its content is folded into step 4
3. Navigate Phase Completion verifies all slices have: non-pending commit hash, validation status, at least one acceptance criterion checked, learnings captured
4. When the gate check finds gaps, it lists them per-slice and offers to update NAVIGATION.md inline before proceeding
5. ~~The "Load Engineer Profile" section across all 7 commands (inquire, navigate, evolve, pair, pause, resume, status)~~ The "Load Engineer Profile" section across 6 commands (inquire, navigate, evolve, pair, pause, resume — status excluded as read-only) uses a collaboration stance with a philosophical anchor and three concrete behaviors: flag uncertainty, grow through narration, let expertise shape engagement
6. The collaboration stance retains expertise level as one input, but frames it as contextual rather than deterministic
7. Navigate's "Important Principles" section reinforces the concrete behaviors — especially flagging uncertainty and growing through narration during implementation
8. Navigate offers per-slice gearing at each slice preview: "run with it" (lighter narration, fewer pauses) or full partnership mode — chosen by the engineer per slice, not locked in for the session
9. Navigate includes slice-boundary check-ins in "Between Slices" — triggered when the engineer chose "walk me through this" for the completed slice, skipped when they chose "run with it"
10. `/trellis` passes on all modified command files
11. STATE.md documents which NAVIGATION.md fields are required vs optional per slice

### Work Slices

#### Slice 1: Lean Collaboration Stance
**Goal**: Replace the passive depth hint in "Load Engineer Profile" with a short collaboration stance across all 7 commands
**Depends on**: Nothing
**Files likely touched**: `commands/vine/inquire.md`, `commands/vine/navigate.md`, `commands/vine/evolve.md`, `commands/vine/pair.md`, `commands/vine/pause.md`, `commands/vine/resume.md`, `commands/vine/status.md`

**Draft stance language** (adapt per command, but this is the template):

> **Collaboration stance** (internal, not shown to the engineer):
>
> "This is a partnership — both sides learn, both sides grow. Three concrete behaviors:
>
> 1. **Flag your uncertainty.** When you're unsure about a pattern, module, or convention,
>    say so. The engineer is a resource, not an audience.
> 2. **Grow through the work.** When you use a pattern they might not know, name it as you
>    write. When they correct you, acknowledge what you learned. Growth lives in the
>    narration, not in debriefs.
> 3. **Let expertise shape engagement.** Their profile level (confident/familiar/learning/new)
>    calibrates your default — but confidence is contextual, so follow their lead."

For navigate specifically, the stance replaces the expanded depth hint (lines 40-54). The per-level behavioral specifics (confident → lead with what, learning → explain the why) move to the per-slice gearing in slice 2 where the engineer chooses engagement level in context.

For evolve, keep the existing unique behavior (noting domain entries for Evolution 3) and only replace the depth hint preamble.

**Acceptance criteria**:
- All 7 commands use the new collaboration stance: one-line philosophical anchor + three concrete behaviors (flag uncertainty, grow through work, let expertise shape engagement)
- Expertise level is retained as one input, framed as contextual not deterministic
- Evolve's profile section keeps its existing unique behavior — only the depth hint preamble changes
- Navigate's expanded depth guidance (confident/familiar vs learning/new) is removed here, deferred to slice 2's per-slice gearing
- No other sections of the commands are modified
**Complexity signal**: Medium — each command's profile section is slightly different. Navigate has expanded guidance to remove, evolve has unique behavior to preserve. Not a pure find-and-replace.

#### Slice 2: Navigate Behavioral Integration + Per-Slice Gearing
**Goal**: Embed the three concrete behaviors into navigate's flow and add per-slice gearing to the slice preview (step 3a)
**Depends on**: Slice 1 (stance sets the foundation)
**Files likely touched**: `commands/vine/navigate.md`
**Acceptance criteria**:
- "Important Principles" reinforces the concrete behaviors from the stance — especially "flag your uncertainty" (adds to the existing "respect the engineer's expertise" principle) and "grow through the work" (strengthens the existing "the engineer is learning too" principle)
- Step 3a (slice preview) includes a self-assessment: when previewing the approach, explicitly flag areas of low confidence ("I'm less sure about this part — I haven't seen this pattern in this project")
- Step 3a adds a gear choice after the preview: "run with it" or "walk me through this" — folded into the existing "sound right?" confirmation, not a separate interaction
- "Run with it" means lighter narration and fewer interactive pauses — but validation, commits, and NAVIGATION.md updates stay firm. Concrete boundary: in "run with it," skip step 3b narration and step 3c review pauses. Still do 3a (preview), 3d (decisions), and all of step 4.
- The profile's expertise level informs the *default* recommendation but the engineer always chooses
- Step 3b (narration during implementation) adds: "When you use a pattern the engineer might not know, name it and briefly say why it fits. When the engineer corrects your approach, note what you learned in NAVIGATION.md's learnings section — not just the change you made."
**Complexity signal**: Medium — multiple touchpoints in navigate's step 3. The self-assessment in 3a is new behavior that needs to feel honest, not performative. The gear boundary must be concrete enough that agents follow it consistently.

#### Slice 3: Merge Step 5 into Step 4
**Goal**: Make NAVIGATION.md updates part of the commit flow so they can't be skipped
**Depends on**: Slice 2 (partnership language may affect narration in step 4)
**Files likely touched**: `commands/vine/navigate.md`
**Acceptance criteria**:
- Step 4 includes updating NAVIGATION.md (approach, commit hash, validation, acceptance criteria, learnings) before committing
- Step 5 ("Document as You Go") is removed as a separate section
- Steps 6-9 are renumbered to 5-8
- The slice journal template from old step 5 is preserved in the merged step 4
**Complexity signal**: Medium — structural surgery on navigate. Need to merge content carefully without losing the journal template or the "Between Slices" flow.

#### Slice 4: Phase Completion Gate Check + Gear-Linked Check-ins
**Goal**: Add completion gate to Phase Completion and gear-linked check-ins to Between Slices
**Depends on**: Slice 3 (gate checks fields that step 4 now populates; check-ins go in "Between Slices" which may be renumbered)
**Files likely touched**: `commands/vine/navigate.md`
**Acceptance criteria**:
- Phase Completion reads NAVIGATION.md and verifies per-slice: commit hash not "pending", validation status exists, at least one acceptance criterion checked, learnings not empty
- Gaps are listed per-slice with what's missing; engineer offered inline fix
- "Between Slices" section includes a brief check-in *only when the completed slice was in partnership mode* ("walk me through this"): what was learned, what shaped the approach
- When the completed slice was in "run with it" mode, skip the check-in — the engineer already signaled they don't need the reflection
- Check-ins are lightweight (2-3 sentences of shared awareness, not a feedback form)
**Complexity signal**: Medium — the gate check has well-defined criteria. The gear-linked check-in logic is simple (if partnership → check in, if run-with-it → skip) but the tone needs care.

#### Slice 5: STATE.md Field Requirements (CONDITIONAL)
**Condition**: Only if the gate check's required fields (commit hash, validation, acceptance criteria, learnings) survive navigate unchanged. If navigate reveals different fields should be required, update this slice's criteria before implementing.
**Goal**: Document which NAVIGATION.md fields are required vs optional per slice
**Depends on**: Slice 4 (gate check defines what's required)
**Files likely touched**: `references/STATE.md`
**Acceptance criteria**:
- NAVIGATION.md template in STATE.md marks each field with `<!-- required -->` or `<!-- optional -->` HTML comment markers
- Required fields match what the gate check actually verifies (may differ from initial plan)
- Optional fields are explicitly marked
**Complexity signal**: Low — adding markers to an existing template.

### Tech Debt Integration

| Item | Action | Rationale |
|------|--------|-----------|
| Step 5 separate from step 4 | Address now (Slice 3) | Core of the navigate fix |
| Profile section across 7 commands | Address during (Slice 1) | Already editing all 7 for the stance update |

No new tech debt being taken on.

### Backlog Updates

- Consider a `vine:check` diagnostic command that validates artifacts against STATE.md contracts (generalized gate check)
- README could reference the partnership philosophy to set expectations for VINE's tone
- Explore whether "run with it" mode should be available in inquire too (fast-track design for repeat patterns)

### Dependencies & Risks

- **7-file edit surface (Slice 1)**: Risk of inconsistency across commands. Mitigation: draft the stance text once, then adapt per-command. Run `/trellis` after.
- **Navigate is 439 lines**: Structural changes on a long file across slices 2-4. Mitigation: re-read the full file before each slice, verify with `/trellis` after each.
- **Per-slice gearing overhead**: Adding a gear question to every slice preview could feel bureaucratic. Mitigation: fold it into the existing "sound right?" confirmation, not a separate interaction. Profile expertise informs the default recommendation so the engineer can just confirm.
- **"Run with it" boundaries**: The mode needs to clearly define what gets lighter (narration, pauses, check-ins) vs. what stays firm (validation, commits, NAVIGATION.md). If the boundaries are vague, agents will either ignore the mode or skip important steps.
- **Check-in tone in partnership mode**: Check-ins that feel like performance reviews will be annoying. They need to feel like shared awareness. Tying them to the gear choice helps — the engineer only sees check-ins when they opted into partnership mode.
- **Self-assessment honesty**: "Flag your uncertainty" only works if the agent genuinely self-assesses rather than performing humility. The instruction needs to be specific enough that false confidence feels like a violation, not just a missed suggestion.
