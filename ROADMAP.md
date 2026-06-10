# VINE Roadmap

The issue-level source of truth is the
[v0.4.0 milestone](https://github.com/moduloMoments/VINE/milestone/1). This file names the
VINE cycles that deliver it, their order, and why the order matters. Each cycle is run as a
VINE feature on this repo (dogfooding is the test suite); small mechanical items go through
`vine:pair` instead of the full chain.

## v0.4.0 — Platform-native, team & agent ready

**Goal:** make VINE the best framework for individuals and teams of humans, local agents, and
auto-agents to build and maintain established codebases while sharing context — by building
*with* Claude Code's native tooling (hooks, plan mode, task tools, CLAUDE.md memory, headless
invocation) instead of alongside it.

### Guiding principle

Before adding a VINE mechanism, check whether the harness already provides it. VINE's job is
the artifact chain, the collaboration contract, and the knowledge lifecycle. Loops, gates,
enforcement, progress UI, and memory primitives belong to the platform; VINE consumes them.

**Backward compatibility is a hard gate for every cycle.** Existing `.vine/` setups must keep
working unchanged, or `vine:init`'s upgrade pass must offer an explicit migration — and
declining the migration must change nothing. The rename fallback in
[#58](https://github.com/moduloMoments/VINE/issues/58) and the backfill mode in
[#56](https://github.com/moduloMoments/VINE/issues/56) are the patterns to copy.

### Cycle order

| # | Cycle | Issues | Mode | Why this order |
|---|-------|--------|------|----------------|
| 1 | **Platform alignment** | [#58](https://github.com/moduloMoments/VINE/issues/58) rename hooks→context, [#59](https://github.com/moduloMoments/VINE/issues/59) native hook enforcement, [#60](https://github.com/moduloMoments/VINE/issues/60) CLAUDE.md boundary, [#61](https://github.com/moduloMoments/VINE/issues/61) native task tracking, [#62](https://github.com/moduloMoments/VINE/issues/62) plan mode integration | Full cycle | Changes vocabulary and structure every later cycle builds on. #58 lands first within the cycle. |
| 2 | **Maintenance batch** | [#46](https://github.com/moduloMoments/VINE/issues/46), [#47](https://github.com/moduloMoments/VINE/issues/47), [#48](https://github.com/moduloMoments/VINE/issues/48) consolidation; [#49](https://github.com/moduloMoments/VINE/issues/49), [#50](https://github.com/moduloMoments/VINE/issues/50) descriptions | `vine:pair` | Consolidation targets shared.md, so it lands *after* the rename to avoid double-touching. #49/#50 can go anytime. |
| 3 | **Knowledge lifecycle** | [#51](https://github.com/moduloMoments/VINE/issues/51) durable knowledge layer, [#56](https://github.com/moduloMoments/VINE/issues/56) archival + backfill | Full cycle (multi-PR) | Promotion and archival share the SUMMARY/knowledge formats. Backfill quality depends on the knowledge format being settled, so they ship together. |
| 4 | **Agent-native** | [#54](https://github.com/moduloMoments/VINE/issues/54) validation contract, [#53](https://github.com/moduloMoments/VINE/issues/53) headless autonomy contract | Full cycle | Headless agents need discoverable validation, so #54 precedes #53. Builds on native hooks (#59) and headless invocation patterns. |
| 5 | **Team mode** | [#52](https://github.com/moduloMoments/VINE/issues/52) team-aware init + local projects, [#55](https://github.com/moduloMoments/VINE/issues/55) profile rework | Full cycle | Team-shared knowledge (#51) and the CLAUDE.md boundary (#60) must exist before there's something coherent to share. |
| 6 | **Plugin** | [#57](https://github.com/moduloMoments/VINE/issues/57) Claude Code plugin packaging | `vine:pair` or light cycle | Ships last so the plugin's first release carries the v0.4.0 feature set. |

### Out of scope for v0.4.0

Open issues not in the milestone ([#36](https://github.com/moduloMoments/VINE/issues/36) vine:grow,
[#39](https://github.com/moduloMoments/VINE/issues/39) integration-checker,
[#40](https://github.com/moduloMoments/VINE/issues/40) design-checker,
[#42](https://github.com/moduloMoments/VINE/issues/42) debugger agent,
[#43](https://github.com/moduloMoments/VINE/issues/43) UI audit) are deferred — they add agents and
phases, and the platform-alignment principle says to revisit them after v0.4.0 to see how much the
native tooling already covers.

Also deliberately deferred: parallel slice execution (premature until the headless contract in
[#53](https://github.com/moduloMoments/VINE/issues/53) exists), HTML output, and org-level agents
(risk auditors, summary agents) — those live a layer above a per-repo framework.

### Process notes

- Each full cycle gets its own `.vine/projects/` feature with PROJECT-MAP.md; multi-PR cycles use
  the Milestones table.
- Run `/trellis` before committing command changes; `/vine:optimize` after each cycle that touches
  descriptions or workflows.
- This file is updated at each cycle boundary (evolve's handoff step) — status lives in the GitHub
  milestone, not here.
