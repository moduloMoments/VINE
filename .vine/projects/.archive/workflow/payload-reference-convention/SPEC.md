# Feature Spec: Payload-Relative Reference Convention
## Date: 2026-06-23
## Built on: CONTEXT.md (2026-06-23)
## Decisions made by: Rob

### Problem Statement

Shipped VINE skills cite VINE-source-repo-internal files — chiefly `references/STATE.md` (~67×)
and bare plugin paths like `agents/…` — that don't exist where the code runs. A shipped skill
executes with the **consuming repo as cwd**, and `references/` is deliberately *not* in the
`plugins/vine/` payload (a v0.4.0 scoping decision). So every `references/STATE.md` pointer is dead
from a consuming repo, and `vine:init` actively *writes* dead pointers into other repos' README and
CLAUDE.md. Three issues share this one root cause:
[#142](https://github.com/moduloMoments/VINE/issues/142) (skills cite a non-payload contract),
[#141](https://github.com/moduloMoments/VINE/issues/141) (init writes dead pointers into consumer
repos), [#138](https://github.com/moduloMoments/VINE/issues/138) (`agents/…` reads ambiguously for
contributors). The fix is one convention, applied consistently, plus a guard so it can't drift again.

### Approach

**Direction: shipped skills are self-contained.** `references/STATE.md` is *contributor
documentation*, not a runtime contract — so it does not ship, and the runtime is never told to read
it. This is stricter than "cite it as provenance": a shipped skill body references **no**
VINE-source-internal file at all. Any content a skill genuinely needs at runtime is inlined (the
existing *operative copy* pattern at `evolve/SKILL.md:387`). Honors the payload-scope and
overlay-distribution ADRs and the precedent already in the tree; no payload reversal, no
duplication/sync cost.

**The reference convention — three buckets.** A path in a shipped skill (or shipped agent/hook)
falls into exactly one:

1. **Payload-internal** (ships under `plugins/vine/`: skills, agents, hooks). Reference an agent or
   hook by its **invocable name** where possible (agents are invoked by name/description, not by
   path). When a literal path is unavoidable, write it `${CLAUDE_PLUGIN_ROOT}/…`. Never a bare
   plugin-root-relative path (`agents/…`).
2. **Consumer working tree** (`.vine/…`, `.vine.local/…` in the *consuming* repo — e.g. the
   `## Validation` block the shipped `vine-verification` agent reads from `.vine/context/shared.md`).
   Legitimate runtime paths; they resolve against the consumer's cwd. Cite as-is.
3. **VINE-source-repo-internal** (`references/…`, repo-root framework docs, `.claude/…`). These do
   **not** exist in a consuming repo. **Forbidden in shipped skills/agents/hooks.** Inline what the
   runtime needs; drop the rest.

**Rename `references/STATE.md` → `references/CONTRACTS.md`.** The file is far broader than "state"
(it carries the artifact templates *and* cross-cutting conventions: Knowledge Boundary, Reference
Legibility, Committing Artifacts, Chaining Protocol, the Filtering Convention). "STATE" also collides
with the *session* state the file merely documents (ACTIVE sentinel, PAUSE state). `CONTRACTS.md`
names the actual content. Done as the first slice so later edits touch each citation once, against
the new name. **Live/operative** references are updated (CLAUDE.md, README, `.vine/context/*`,
`.claude/agents/*`, `.claude/commands/*`, ROADMAP); **historical records** (CHANGELOG, dated
`.vine/knowledge/` ADRs) are left period-accurate.

**Init writes no VINE-internal pointer into consumer artifacts.** `vine:init` step 4 (README
template) and step 8 (CLAUDE.md pointer) drop the `references/…` pointer entirely — it's framework
plumbing the consumer repo doesn't have. The artifact table/map stays; only the dead pointer goes.

**A `/trellis` guard prevents regression.** A lean check flags bucket-3 paths (and non-portable
bucket-1 paths) in shipped skills/agents/hooks, so the convention can't silently drift back.

Verify-confirmed scoping fact: the shipped **agents and hooks already comply** — their only `.vine/`
references are bucket-2 (consumer working tree). The bucket-3 cleanup is **skills-only**.

### Acceptance Criteria

- `grep -rn "references/STATE.md" plugins/vine/skills/` returns **zero** matches; same for
  `references/CONTRACTS.md` and any other `references/…` path. (#142)
- No shipped skill body contains a bare `agents/…`, `skills/…`, or `hooks/…` path; payload
  cross-references are by invocable name or `${CLAUDE_PLUGIN_ROOT}/…`. (#138)
- `references/STATE.md` no longer exists; `references/CONTRACTS.md` does. No **live** file
  references `references/STATE.md`. CHANGELOG and dated `.vine/knowledge/` ADRs still say `STATE.md`
  (period-accurate).
- `vine:init`'s README (step 4) and CLAUDE.md (step 8) templates write no `references/…` pointer
  into a consuming repo. (#141)
- The convention is documented in CLAUDE.md "Skill Authoring Conventions" (all three buckets +
  the self-contained rule) and in a companion clause under "Reference Legibility" in
  `references/CONTRACTS.md`.
- Any runtime-critical content formerly behind a `STATE.md` pointer is inlined; a spot-run of at
  least one phase (e.g. `vine:inquire` or `vine:navigate`) still produces a correct artifact.
- `/trellis` **fails** when a `references/…` path is deliberately added to a shipped skill, and
  **passes** on the corrected tree; it does **not** trip on the shipped agent's bucket-2
  `.vine/context/…` references.

### Work Slices

#### Slice 0: Rename STATE.md → CONTRACTS.md (live surfaces)
**Goal**: `git mv references/STATE.md references/CONTRACTS.md` and update every **live/operative**
reference, so the new name is in place before any other edit.
**Depends on**: nothing (first).
**Files likely touched**: `references/CONTRACTS.md` (self-refs), `CLAUDE.md`, `README.md`,
`.vine/README.md`, `.vine/context/{shared,verify,navigate,evolve,pair}.md`,
`.claude/agents/vine-coder.md`, `.claude/commands/{trellis,pr-review}.md`, `ROADMAP.md`.
**Addendum (navigate, Slice 0)**: also updated `.vine/scripts/trellis-check.sh` and
`.vine/scripts/run-tests.sh` — both hardcode the Check 10 anchor pair
(`references/STATE.md|**Verification-tier contract.**`) and the test fixture that stubs it, so the
rename breaks `/trellis` unless they move to `references/CONTRACTS.md` too. Required to satisfy this
slice's own "`/trellis` passes" AC; not in the original list.
**Explicitly NOT touched**: `plugins/vine/skills/**` (their refs are *removed* in Slice 2, not
renamed), `CHANGELOG.md`, and dated `.vine/knowledge/workflow/*.md` (historical — left
period-accurate).
**Acceptance criteria**: `references/STATE.md` gone; `references/CONTRACTS.md` present; zero live
files reference `STATE.md`; CHANGELOG + dated ADRs unchanged; `/trellis` passes (cross-reference
anchors intact).
**Complexity signal**: Low — mechanical move + scoped find/replace, but the historical-records
carve-out must be respected, so no blanket repo-wide sed.

#### Slice 1: Document the convention
**Goal**: Write the Payload Reference Convention so Slice 2 has a rule of record to implement
against.
**Depends on**: Slice 0 (uses the `CONTRACTS.md` name).
**Files likely touched**: `CLAUDE.md` (Skill Authoring Conventions — the three-bucket rule +
self-contained-skills rule + init-omits-internal-pointers), `references/CONTRACTS.md` (companion
clause under "Reference Legibility": path resolution by audience/bucket).
**Acceptance criteria**: Both homes state the three buckets, the self-contained rule for shipped
skills, the name/`${CLAUDE_PLUGIN_ROOT}` rule for payload cross-refs, and that init writes no
VINE-internal pointer. Per the doc-growth guardrail, prefer tightening existing prose over adding
a new long section.
**Complexity signal**: Low — net-new prose in two known locations.

#### Slice 2: Make shipped skills self-contained (#142, #138, #141 write-half)
**Goal**: Apply the convention across all 9 affected skills.
**Depends on**: Slice 1 (the written rule).
**Sub-tasks**:
- Triage each `references/STATE.md` citation: runtime-critical → **inline** via the operative-copy
  pattern; provenance-only ("consult for full detail") → **remove**.
- Convert the two agent citations (`navigate/SKILL.md:459`, `evolve/SKILL.md:116`,
  "the checklist lives in `agents/vine-verification.md`") to invocable-name form
  ("the `vine-verification` agent owns the checklist").
- Remove the VINE-internal pointers init *writes* into consumer artifacts (README template step 4,
  CLAUDE.md template step 8).
- Confirm shipped agents/hooks stay clean (verify found only bucket-2 `.vine/` refs — leave them).
**Files likely touched**: `plugins/vine/skills/{evolve,init,navigate,inquire,optimize,verify,pause,resume,status}/SKILL.md`.
**Addendum (navigate, Slice 2)**: three additions beyond the spec's named scope.
(1) **optimize also writes a dead consumer pointer.** The spec named only init for the #141
write-half, but `optimize/SKILL.md`'s "Verify the CLAUDE.md Pointer" template (3e) injected the same
`(format in references/STATE.md)` into a *consumer's* CLAUDE.md. Removed there too — required by the
zero-`references/` AC regardless.
(2) **Stale Check 10 anchor pair.** Removing the bucket-3 "verification-tier contract note" pointer
from `navigate`/`evolve` left their `trellis-check.sh` Check 10 anchor expectations dangling, failing
`/trellis`. Removed the two navigate/evolve pairs from all three coupled homes
(`.vine/scripts/trellis-check.sh` PAIRS, `.claude/commands/trellis.md` Check 10 table + prose,
`.vine/scripts/run-tests.sh` fixture) — the same lockstep Slice 0 hit. The CONTRACTS.md + agent
anchors (6 pairs) still resolve.
(3) **Three descriptive bare-payload-path mentions** (`init` `skills/<name>/SKILL.md` and
`hooks/hooks.json`; `evolve` "skills/commands") reworded — within the #138 AC ("no bare
`agents/|skills/|hooks/` path in a skill body"), so the Slice 3 guard can be strict.
**Acceptance criteria**: the #142/#138/#141 ACs above all hold; a spot-run of one phase still
produces a correct artifact.
**Complexity signal**: High — broad (9 files, ~67 refs) though individually mechanical. Navigate may
checkpoint per-skill; consistency matters more than cleverness.

#### Slice 3: Add the /trellis regression guard
**Goal**: A lean check that fails the build on a new convention violation.
**Depends on**: Slice 2 (tree must be clean for the guard to pass).
**Rule**: In `plugins/vine/{skills,agents,hooks}/`, flag (1) any `references/…` path, and (2) any
bare `agents/…|skills/…|hooks/…` path not written `${CLAUDE_PLUGIN_ROOT}/…`. Do **not** flag
bucket-2 consumer paths (`.vine/…`, `.vine.local/…`) or name-based agent references.
**Files likely touched**: `.claude/commands/trellis.md` (+ `.vine/scripts/trellis-check.sh` /
`run-tests.sh` if the check is scripted for CI parity).
**Addendum (navigate, Slice 3)**: implemented as **Check 13** in `trellis-check.sh` (scripted for CI
parity) + documented in `trellis.md` + 3 tests in `run-tests.sh`. The bare-path regex anchors on a
non-slash boundary (every legitimate `agents|skills|hooks/` token is `/`-preceded). One surprise: the
guard flagged a *prose* "skills/agents" at `init/SKILL.md:45` ("available skills/agents") — a
two-word slash, not a path. Despaced to "skills and agents" (same fix as evolve "skills/commands"),
noted because prose `X/Y` is a known limitation of the non-slash-boundary heuristic.
**Acceptance criteria**: a deliberately-added `references/CONTRACTS.md` line in a skill fails
`/trellis`; the corrected tree passes; the shipped agent's `.vine/context/…` references do not trip
it.
**Complexity signal**: Medium — the regex must distinguish bucket-3 from the legitimate bucket-2
`.vine/` paths; test both directions.

### Tech Debt Integration

- **No regression guard** (CONTEXT) → **addressed now** (Slice 3) — the issues' ACs require it.
- **67-reference maintenance surface** (CONTEXT) → **reduced**: most refs are *removed*, not
  rewritten; the surface shrinks rather than persists (Slice 2).
- **Three issues, one fix** (CONTEXT) → the whole feature consolidates #142/#141/#138 into a single
  convention, avoiding three divergent partial fixes.
- **Doc gaps** (CONTEXT: CLAUDE.md authoring rule, CONTRACTS.md Reference Legibility companion,
  init's false "in the repo root" template language) → all closed in Slices 1–2.
- **New, consciously accepted**: the rename leaves CHANGELOG + dated ADRs naming `STATE.md`. This is
  intentional (historical records are period-accurate), not drift — documented in Slice 0.

### Backlog Updates

- None new. This feature closes #142, #141, #138 (use `Refs #N` on the implementation PR;
  evolve/knowledge ADR still owe their part per the issue-close-timing convention).
- Noted and already covered, so not a backlog item: re-confirm shipped agents/hooks during Slice 2
  (verify shows them clean today).

### Dependencies & Risks

- **Strictly sequential**: 0 → 1 → 2 → 3. Slice 0 renames before any citation edit; Slice 1's
  written rule guides Slice 2; Slice 3 needs Slice 2's clean tree to pass.
- **Risk — removing a load-bearing pointer.** A `STATE.md` pointer that actually gated runtime
  behavior, dropped without inlining, would silently degrade a skill. Mitigated by per-reference
  triage in Slice 2 + the spot-run AC. (Verify's read: runtime-critical bits are *largely* inlined
  already, so this set is small.)
- **Risk — rename breaks a cross-reference anchor** (`/trellis` Check 10 territory). Mitigated by
  running `/trellis` at the end of Slice 0.
- **Risk — Slice 2 breadth.** 9 files in one session; navigate may checkpoint per-skill.
- **Coordination**: none external — solo maintainer, single PR (4 slices, tightly coupled; shipping
  separately would risk the divergent partial fixes CONTEXT warns against).
