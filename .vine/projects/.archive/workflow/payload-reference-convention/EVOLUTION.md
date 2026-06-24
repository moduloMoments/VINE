# Evolution Report: Payload-Relative Reference Convention
## Date: 2026-06-23

### Product Evolution

#### Acceptance Criteria Results

Cycle-level contract from SPEC.md, mapped to evidence. All pass — verified by grep battery +
`trellis-check.sh` (11/11 skills, exit 0) + `run-tests.sh` (30/30).

| Acceptance criterion (SPEC) | Evidence (slice / commit) |
|---|---|
| `grep references/STATE.md plugins/vine/skills/` returns zero; same for any `references/…` (#142) | Slice 2 — e72f448 (grep: 0 matches) |
| No bare `agents/`, `skills/`, `hooks/` path in a skill body; cross-refs by name or `${CLAUDE_PLUGIN_ROOT}` (#138) | Slice 2 — e72f448 (grep: 0 matches) |
| `references/STATE.md` gone; `references/CONTRACTS.md` present; no live file references `STATE.md`; CHANGELOG + dated ADRs period-accurate | Slice 0 — e75b744 (file moved; 5 CHANGELOG + 6 ADR refs preserved) |
| `vine:init` README (step 4) + CLAUDE.md (step 8) write no `references/…` pointer (#141) | Slice 2 — e72f448 (grep: 0 in init/optimize) |
| Convention documented in CLAUDE.md "Skill Authoring Conventions" + CONTRACTS.md "Reference Legibility" companion | Slice 1 — bc04aef (both homes present) |
| Runtime-critical content inlined; a spot-run of one phase still produces a correct artifact | Slice 2 — e72f448 (PROFILE.md format inlined in verify+evolve; the live navigate session itself + this evolve run are the spot-run) |
| `/trellis` fails on a deliberate `references/…` injection, passes on the corrected tree, does not trip on bucket-2 `.vine/context/…` | Slice 3 — 01db36c (Check 13; 3 CI-parity tests, both directions) |

No **unaccounted** criteria. The three remaining `STATE.md` reference sites are all
period-accurate by design: CHANGELOG (5), this feature's own CONTEXT/SPEC/NAVIGATION, and the
dated `.vine/knowledge/workflow/` ADRs.

#### Spec Deviations

All three were navigate-annotated in SPEC.md addenda — justified, in-scope tactical extensions,
none changing user-facing behavior beyond what the issues' ACs already required:

| Deviation | Slice | Verdict |
|---|---|---|
| `optimize/SKILL.md` also wrote a dead `references/STATE.md` pointer into a consumer CLAUDE.md (spec named only init) | 2 | Justified — required by the zero-`references/` AC regardless; same #141 class as init |
| Removed the navigate/evolve "verification-tier contract" pointer broke `/trellis` Check 10; removed the two stale anchor pairs from all three coupled homes | 2 | Justified — mechanical consequence of pointer removal; CONTRACTS + agent anchors (6 pairs) still resolve |
| Three descriptive bare-payload-path prose mentions reworded (init `skills/<name>/SKILL.md`, init `hooks/hooks.json`, evolve "skills/commands"); plus a prose "skills/agents" despaced for the guard | 2, 3 | Justified — within the #138 no-bare-path AC; the prose `X/Y` despace is a known limitation of Check 13's non-slash-boundary heuristic, documented in the check prose |

#### Follow-Up Items

None new. The cycle closes #142, #141, #138 in full. Two pre-existing, already-tracked notes
remain (not new work this cycle introduced):
- Legacy `.vine/hooks/` fallback warnings in init harden to failures at 0.5 (tracked with the
  0.4.0 release; warning-only by design today).
- Version bump (patch vs minor) is a release-time call — see Handoff. A `[Unreleased]` CHANGELOG
  entry was staged this cycle.

### Agent Evolution

#### CLAUDE.md Suggestions

None to draft — the convention itself was written into CLAUDE.md "Skill Authoring Conventions"
during Slice 1 (bc04aef), with the rationale in CONTRACTS.md "Path resolution by audience." The
agent-capability gain this cycle is already committed.

#### Skill Suggestions

None. No repeatable scaffold or workflow emerged — this was a one-time convention cleanup.

#### VINE Process Observations

- **Dogfooding meta-note**: this very evolve run executed from a *cached 0.4.0 plugin copy* whose
  body still cites `references/STATE.md` — the exact dead-pointer the feature fixes, surviving in
  the install cache until the next plugin refresh. A live demonstration of why the convention
  matters, and a reminder that contributor sessions should refresh the local plugin install after
  editing skills (the dev loop). Transient, no action needed.
- The strictly-sequential 0→1→2→3 slicing held cleanly: rename first meant Slice 2 touched each
  citation once against the final name. The one recurring friction was Check 10's anchor coupling
  surfacing twice (Slice 0 forward, Slice 2 in reverse) — captured as durable knowledge below.

#### Context Overlay Updates

None. The Check 13 guard is already wired into `trellis-check.sh`, which the `## Validation` block
in `shared.md` already points at — no overlay edit needed.

### User Evolution

#### Engineer Contributions

- **The (a) vs (b) direction call** — choosing "shipped skills are self-contained / `references/`
  is contributor-doc" over "ship `references/` into the payload." This was the headline open
  question left deliberately open at verify; resolving it toward documentation-not-mechanism
  extended an established thread rather than reversing the just-shipped payload-scope decision.
- **The STATE → CONTRACTS rename insight** — recognizing the file's name had outgrown its content
  ("state" was both too narrow and colliding with session state), folded into Slice 0 so later
  edits touched each citation once.
- **The period-accurate historical carve-out** — insisting CHANGELOG and dated ADRs keep saying
  `STATE.md`. This is the same instinct applied before (issue freshness, knowledge immutability):
  historical records are period-accurate, not drift.

#### Profile Updates

No change. `workflow` stays `confident` — this cycle was convention-cleanup squarely in the
engineer's wheelhouse (they drove the v0.4.0 payload-scope decisions this builds on). No growth
log entry (engineer's call: skip).

#### Claude Memory Suggestions

None surfaced. No new general interaction preference emerged — the cycle ran free-climb,
batch-by-size, consistent with existing recorded preferences.

#### Durable Decisions Distilled

One knowledge record written: `.vine/knowledge/workflow/2026-06-23-shipped-skills-are-self-contained-references-is-contributor-doc.md`
— captures *why* direction (a) beat (b), the non-regenerable judgment CLAUDE.md's rule-text doesn't
preserve. The guard's non-slash-boundary regex heuristic was considered and skipped (recoverable
from the script + comments).

### Handoff Package

#### PR Description

```markdown
## Summary
Shipped VINE skills cited `references/STATE.md` (~67×) and bare `agents/…` paths that don't
exist where the code runs — a skill executes with the *consuming* repo as cwd, and `references/`
isn't in the plugin payload. `vine:init` even wrote those dead pointers into other repos' README
and CLAUDE.md. This establishes one convention — shipped skills are self-contained — and applies
it everywhere, with a guard so it can't drift back. Closes #142, #141, #138.

## Changes
- **Rename** `references/STATE.md` → `references/CONTRACTS.md` (name now matches the content —
  artifact templates plus cross-cutting conventions, not just "state"). Live references updated;
  CHANGELOG and dated knowledge ADRs left period-accurate. (e75b744)
- **Document** the three-bucket reference convention in CLAUDE.md and CONTRACTS.md. (bc04aef)
- **Apply** it across 9 skills: ~60 dead `references/` pointers removed (runtime-critical content
  inlined), agent citations switched to invocable names, and init/optimize no longer write
  VINE-internal pointers into consumer repos. (e72f448)
- **Guard** it: `/trellis` Check 13 fails on any shipped-surface VINE-internal reference. (01db36c)

## Decisions Made
- Direction: `references/` is contributor documentation, not a runtime contract — so it doesn't
  ship and the runtime is never told to read it. Honors the payload-scope and overlay-distribution
  decisions; no payload duplication.
- Historical records (CHANGELOG, dated ADRs) keep naming `STATE.md` — period-accurate, not drift.

## Testing
- `grep -rn "references/" plugins/vine/skills/` → 0 matches; no bare `agents|skills|hooks/` paths.
- `sh .vine/scripts/trellis-check.sh` → exit 0 (11/11 skills, Check 13 green).
- `sh .vine/scripts/run-tests.sh` → 30/30 (includes 3 new Check 13 tests, both directions).

## Follow-up
None — the three issues are fully closed. Version bump (patch vs minor) is a release-time call;
a `[Unreleased]` CHANGELOG entry is staged.
```

#### Reviewer Notes

- **The rename is the riskiest mechanical bit.** Check 10 in `/trellis` couples a skill's pointer
  phrase to an anchor pair living in three places (`trellis-check.sh`, `trellis.md`,
  `run-tests.sh`). The rename and the later pointer removals each had to update all three in
  lockstep; the green `trellis-check` + 30/30 tests confirm they did.
- **Three navigate addenda go beyond SPEC's named scope** (optimize's consumer pointer, the
  removed Check 10 anchor pairs, the despaced prose `X/Y`). All are annotated in SPEC.md and
  required by the issues' ACs — not scope creep.
- **Bucket-2 is legitimate.** The shipped `vine-verification` agent reads `.vine/context/shared.md`
  (the consumer's working tree) — that's a valid runtime path and Check 13 correctly leaves it
  alone. Don't "fix" it.

#### Commit Suggestions

Already committed as 4 slice commits (e75b744, bc04aef, e72f448, 01db36c) plus the navigate close
(c3911f5). The evolve commit adds EVOLUTION.md, the knowledge ADR, the CHANGELOG entry, and the
PROJECT-MAP update.

#### Multi-PR Summary

Not applicable — single PR, no Milestones table. All four slices ship together (tightly coupled;
shipping separately would risk the divergent partial fixes CONTEXT warned against).
