# Feature Context: Multi-PR Tracking for Large Features
## Date: 2026-04-02
## Author: Rob + Claude

### Codebase Landscape

VINE's artifact chain (CONTEXT -> SPEC -> NAVIGATION -> EVOLUTION) assumes a single-PR lifecycle. The relevant touch points:

**Inquire (step 6b)** — Already supports grouping slices into "phases" for larger features. Each phase is described as "one vine:navigate session." But phases are session boundaries, not PR boundaries. There's no concept of "this phase = this PR."

**Navigate (step 9, "Between Phase Groups")** — Suggests `/clear` between phase groups and notes "the work so far should stand on its own." This is the closest thing to a multi-PR boundary, but it doesn't mention opening a PR, tracking PR status, or updating SPEC.md.

**Navigate (Phase Completion)** — The completion block suggests evolve after all slices, not after a phase group. There's a mismatch: phase groups suggest stopping points, but completion only triggers at the end.

**SPEC.md format (STATE.md)** — Has phase grouping syntax but no size flag, no PR mapping, and no "shipped" status per phase.

**NAVIGATION.md format** — Tracks per-slice progress but has no per-phase-group summary or PR reference.

### Current State

The phase grouping in inquire/navigate works for multi-session implementation but breaks down when the engineer wants to:
1. Open a PR after completing Phase 1 while Phase 2 is still unstarted
2. Get Phase 1 reviewed and merged independently
3. Come back to Phase 2 in a new session, knowing Phase 1 is shipped
4. Track overall progress across the feature without reading all artifact files

There's no document that says "Phase 1: PR #42 (merged), Phase 2: in progress, Phase 3: not started."

### Edge Cases & Tribal Knowledge

- In recent sessions, the `/clear` + evolve suggestion came before NAVIGATION.md was fully updated — this compounds the multi-PR problem because the journal is incomplete when it's time to open a PR
- The engineer wants to be able to step through a SPEC across multiple PRs and update the SPEC as each PR lands
- A "central project map" was suggested as an alternative to inferring progress from artifacts — something that shows at-a-glance where the project stands
- The 1000-line threshold was mentioned as a signal that a spec should be flagged for multi-PR treatment

### Tech Debt in Affected Areas

- Phase grouping in inquire (step 6b) and navigate (step 9) are underspecified — they describe session boundaries but not PR/shipping boundaries
- SPEC.md has no versioning or "as-shipped" annotations
- No size estimation happens anywhere in the flow — neither inquire nor navigate considers total LOC

### Documentation Gaps

- STATE.md doesn't document any multi-PR conventions
- No guidance in any command for "what to do when a feature spans multiple PRs"
- The relationship between phase groups and PRs is undefined

### UX Consideration

Artifact readability matters more for a project map than for other VINE artifacts — the whole point is at-a-glance status. Claude Code renders markdown in monospace terminal output. Engineers using VS Code can preview .md files natively. Terminal tools like `glow` could be wired into hooks for richer rendering. The project map design should prioritize scannability in plain terminal output (short lines, clear status markers, minimal prose).

### Open Questions

1. **New artifact vs. SPEC extension?** Should multi-PR tracking live in a new file (e.g., `PROJECT-MAP.md`) or as a new section in SPEC.md? A separate file is simpler to update incrementally; a SPEC extension keeps everything in one place.
2. **Size flag mechanism** — Should inquire estimate LOC and flag automatically, or should the engineer declare "this is multi-PR" explicitly? Or both (auto-flag with engineer override)?
3. **Phase-group-to-PR mapping** — Should each phase group automatically map to one PR, or should the engineer decide the PR boundaries independently of phase groups?
4. **Navigate per-phase completion** — Should navigate offer a "phase complete" flow (including a partial evolve or PR prep) at the end of each phase group, rather than only at the end of all slices?
5. **SPEC updates as PRs land** — What annotation style? Strikethrough shipped phases? Status markers? Something else?
