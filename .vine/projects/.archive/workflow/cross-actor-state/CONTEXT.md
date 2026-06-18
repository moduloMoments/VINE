# Feature Context: Cross-actor live execution state
## Date: 2026-06-16
## Author: Rob Bruhn + Claude

> Scope source: [issue #79](https://github.com/moduloMoments/VINE/issues/79) — "Cross-actor
> live execution state: slice ownership, in-flight state, and the E2 redesign of PAUSE.md /
> ACTIVE / PROFILE.md". Roadmap cycle 3 (full cycle), v0.4.0 milestone. The issue asks for
> **one** cross-actor state model with the three broken artifacts redesigned inside it — not
> piecemeal patches.

### Environment framing (the axis everything below is measured against)
VINE targets three environments (`ROADMAP.md`, "Target environments"):
- **E1 — local personal.** Today's design center. One human, one machine. Backward
  compatibility here is the hard gate: existing setups must keep working unchanged, or init's
  upgrade pass offers an explicit migration whose decline is a no-op.
- **E2 — committed shared.** `.vine/` tracked in git, **multiple actors on one repo**. This is
  where slice ownership and cross-actor state earn their keep, and the environment this cycle
  targets.
- **E3 — remote verification.** A reviewer (or headless agent) works from the artifact chain
  alone. The headless route's verification leg.

The **guiding principle** bounds the solution space (`ROADMAP.md`): *VINE owns the decision
criteria, contracts, and handoff artifacts; the platform owns execution mechanics — subagents,
headless invocation, progress UI, and **memory primitives**. VINE never implements an agent
runner.* Prior decision [#61] settled the single-session split — native tasks are the live
view, markdown the durable journal — and stays closed; neither side covers state **between**
concurrent actors, which is the gap #79 opens.

---

### Codebase Landscape

VINE is pure markdown — the "code" is the command files in `commands/vine/*.md`, the artifact
contract in `references/STATE.md`, and the POSIX-sh hook scripts in `.vine/scripts/`. Four
surfaces are in play:

- **`commands/vine/*.md`** — eleven phase commands. The session-state writes/deletes live as
  *prose instructions* Claude follows, not as enforced code. navigate, pause, resume, inquire,
  evolve, init all touch the three artifacts.
- **`references/STATE.md`** — the artifact-format contract. Templates carry
  `<!-- required -->` / `<!-- optional -->` markers per heading; the journal-schema contract
  (the six Route/Actor/Gear rules) lives here.
- **`.vine/scripts/`** — the enforcement layer. `journal-check.sh` is the only one of these
  that ships to user repos (listed in `package.json` `files`); `main-guard.sh`,
  `trellis-gate.sh`, `trellis-check.sh`, `run-tests.sh` are contributor-only.
- **`.claude/settings.json`** — wires the three hook scripts as PreToolUse-on-Bash hooks.

#### The three artifacts, mapped

**PAUSE.md** — ephemeral per-feature handoff notes (`.vine/projects/<domain>/<slug>/PAUSE.md`).
- *Format/lifecycle:* `references/STATE.md:268-301`. Consumed-once; one per feature; not in the
  permanent chain.
- *Single writer:* `vine:pause` (`pause.md:84-96`) — overwrites if present.
- *Five deletion triggers* (the coordination problem): `resume.md:181`, `navigate.md:92-96` (at
  session start), `inquire.md:66`, `evolve.md:63` (session start), and `evolve.md:524` (the
  `.resolved` backstop, which deletes **silently without surfacing notes**). The first four
  surface notes before deleting; the fifth does not.

**`.vine/ACTIVE`** — repo-root active-session sentinel; three lines (`feature:` / `phase:` /
`started:`); gitignored so it never leaves the machine.
- *Format/lifecycle:* `references/STATE.md:303-325`.
- *Armed by:* `vine:navigate` at session start (`navigate.md:79-90`); `phase:` line updated in
  place between phase groups (`navigate.md:603-605`).
- *Read by:* only `journal-check.sh` (existence check + the `feature:` line) — `pause`/`evolve`
  read it only to decide whether to delete.
- *Disarmed by:* five sites — navigate completion (`navigate.md:680`), navigate
  pause-between-slices (`navigate.md:541`), navigate between-phase-groups session-end
  (`navigate.md:603`), `vine:pause` (`pause.md:100`), and `vine:evolve` at session start
  (`evolve.md:65`). **Last-writer-wins, identity-blind** — any session's cleanup deletes a
  sentinel another session may have written.

**PROFILE.md** — per-engineer domain-expertise + growth (`.vine/PROFILE.md`); gitignored.
- *Format/lifecycle:* `references/STATE.md:404-436`. One `## Domain Expertise` row per domain;
  four levels (confident / familiar / learning / new).
- *Written by:* `vine:verify` (seeds a new domain, `verify.md:46-48`) and `vine:evolve`
  (proposes a level change + optional growth entry, `evolve.md:310-352`). Both last-write-wins,
  no merge.
- *Read by:* the **Engineer Profile Protocol** (`shared.md:165-174`) in verify, inquire,
  navigate, pair, pause, resume, optimize, status. The behavioral consumer that matters for E3
  is **navigate's gearing default** (`navigate.md:279-280`): the recommended gear is set from
  the profile level (confident/familiar → free-climb; learning/new → walk-me-through), and the
  gearing question is `decision-class: default-able` — so a headless actor *takes* a default
  calibrated for whichever human owns the profile.

**NAVIGATION.md actor attribution** (the adjacent primitive) — the per-slice journal entry
*already has* an `**Actor**` field (`references/STATE.md:189`, `<!-- optional -->`, readers
default a missing value to `human`). Gaps, not absence: (a) no controlled vocabulary for the
identifier (unlike `**Route**`'s closed `interactive | headless | headless-reentry` set);
(b) `claude` is hardcoded in the autonomous-attribution line `(decided by: claude — autonomous,
slice N)` (`STATE.md:195`, `navigate.md:386`), which would be factually wrong for a non-Claude
actor.

**journal-check.sh** — the cross-machine-broken hook.
- Compares two timestamps: NAVIGATION.md's local-filesystem **mtime** (`stat -f %m` / `-c %Y`)
  against the latest commit's committer time (`git log -1 --format=%ct`). If `mtime < last`,
  blocks `git commit` (exit 2) on the theory the journal is stale.
- *Why it's meaningless across machines:* `git pull` rewrites a file's mtime to pull-time, not
  author-time, so after a pull the comparison carries no signal — it can block a valid commit or
  pass a stale one by wall-clock coincidence. `.vine/ACTIVE` scopes it (gitignored → a pulled
  In-Progress journal with no local sentinel produces no check).
- Silent on every pass path (no stdout/stderr) — the subject of open issue
  [#99](https://github.com/moduloMoments/VINE/issues/99).

---

### Current State

**What works (E1):** the three artifacts function correctly for one human on one machine. PAUSE
bridges session gaps; ACTIVE scopes the journal guard to active work; PROFILE calibrates
explanation depth. journal-check enforces "journal before commit" within a single filesystem.

**What's structurally broken under E2/E3** (the issue's framing — these are *design* breaks, not
bugs):
- **PAUSE.md** — five uncoordinated deletion triggers; re-pausing overwrites, silently losing a
  second actor's notes. No actor scoping.
- **`.vine/ACTIVE`** — single last-writer-wins sentinel; actor B's evolve silently disarms actor
  A's journal guard. Gitignored, so E3 has zero visibility into who holds what.
- **PROFILE.md** — one engineer per repo; last evolve wins; under E3 a headless agent applies a
  human's depth preferences to itself.
- **NAVIGATION.md** — `**Actor**` exists but underspecified; no controlled identifier vocabulary.
- **journal-check.sh** — mtime comparison is single-machine-only by construction.

**What this cycle is NOT** (boundary set by the guiding principle and #61): not an agent runner,
not a live progress UI, not a memory primitive, not a federated state-sync system. VINE consumes
the platform's execution mechanics; it owns the *contracts* around ownership and handoff.

---

### Edge Cases & Tribal Knowledge

- **Agents are stateless per session — so does an agent even need a profile?** (Rob.) Each
  headless session is a reset; there is no persistent agent identity to accumulate
  depth/growth. This reframes the PROFILE.md "multi-actor" gap: the fix is probably **not**
  "give agents their own profiles" but **guarding the human-profile read under headless** so an
  agent doesn't self-apply a human's depth prefs. Whether PROFILE.md needs any *structural*
  change beyond that read-guard is an open question (see Open Questions).
- **PROFILE.md is gitignored but ships to VINE-consuming repos.** (Rob.) Any later change to
  PROFILE's shape (the #55 reshape especially) has to account for profiles already sitting in
  downstream repos — flag this when the #55 work lands; it's a migration surface.
- **The `**Actor**` field is already there.** Don't design it from scratch — formalize the
  identifier vocabulary and de-hardcode `claude`. Backward-compatible: the field is already
  optional and reader-defaulted to `human`.
- **Native-task rebuild and Remaining Work are coupled** (`STATE.md:228`): NAVIGATION.md's
  `### Remaining Work` is read both by resume's no-PAUSE path and by native-task rebuild —
  whatever happens to PAUSE/handoff must keep that section's two readers intact.
- **Double-delete is already tolerated:** navigate's pause-between-slices deletes ACTIVE then
  suggests `/vine:pause`, which deletes it again (handled gracefully). The current design
  already leans on idempotent deletes — a redesign can use that.
- **All hook scripts fail open** (`STATE.md:329`): no sentinel, missing tooling, or ambiguity
  exits 0. Any journal-check replacement must preserve fail-open — enforcement degrades,
  sessions never break.
- **#52's single-writer-per-feature-directory is the stated starting answer** for slice
  ownership (issue #79 proposal) — not yet designed, but the convention to build from.
- **Agent-report caveat** (`shared.md:62`): the three explorer reports backing this map are
  findings-trustworthy (file/line citations verified against STATE.md directly) but treat any
  root-cause narrative as unverified until checked.

---

### Tech Debt in Affected Areas

- **STATE.md's PROFILE readers list is stale** (`STATE.md:434` lists only verify/inquire/
  navigate; the actual readers also include pair/pause/resume/optimize/status). Low severity,
  doc-only — but this cycle touches PROFILE, so fix it in passing.
- **journal-check's `*git*commit*` over-match** (`journal-check.sh`, jq-fallback path): a
  command like `echo "git commit"` trips the guard. Acknowledged in-script as an intentional
  fail-safe-toward-blocking. Relevant only if the redesign rewrites the script.
- **journal-check passes on a bare `touch`** — it checks mtime, not content, so a no-op touch
  satisfies "journal updated." Any replacement should decide whether content-awareness matters.
- **Five PAUSE deletion sites + five ACTIVE deletion sites** are the debt the issue names
  directly: uncoordinated triggers that a single state model would consolidate.

### Documentation Gaps

- **STATE.md lifecycle sections will need rewriting**, not just extending: PAUSE.md
  (`268-301`), `.vine/ACTIVE` (`303-325`), PROFILE.md (`404-436`), and the journal-schema
  contract (`220-226`) all describe single-actor behavior.
- **README** State Artifacts table + hooks table reference these artifacts — check alignment
  (per the State Artifact Addition Checklist in `shared.md:79`).
- **`.vine/context/verify.md`** carries a command-count reference; unaffected unless a command
  is added/removed.
- If a new state artifact is introduced, the full **State Artifact Addition Checklist**
  (`shared.md:79-88`) applies: STATE.md template + chain + tables, CLAUDE.md chain line, README
  table, and trellis's Step 5a/5b/Check-A sets.

---

### Open Questions
*(These are inquire's to resolve — captured here, not decided.)*

1. **Where does in-flight/live state live — platform or markdown?** *(GENUINELY OPEN — flag
   both.)* The guiding principle and #61 push toward the platform owning live state (native
   tasks / git refs), with VINE owning only the durable ownership + handoff contract. The
   alternative is a committed markdown in-flight artifact. inquire should lay out both paths
   and their tradeoffs before choosing; neither is pre-decided.
2. **Does PROFILE.md need structural change, or just a headless read-guard?** Given agents are
   stateless per session, the minimal fix may be: suppress the profile-driven gearing default
   when running headless (navigate), leaving PROFILE.md's shape alone. Confirm the agent-profile
   premise is unnecessary before designing anything bigger. The depth+growth *reshape* is #55's
   job — keep this cycle to the multi-actor/headless-read concern and flag the #55 dependency.
3. **What replaces journal-check's mtime comparison cross-machine?** Candidates to weigh:
   git-based (is NAVIGATION.md staged/modified in the working tree vs. the commit?), content
   hash, or retiring the guard for E2 and relying on the journal-schema contract. Must stay
   fail-open and keep shipping via `create-vine`.
4. **Slice ownership mechanism.** #52's single-writer-per-feature-directory is the starting
   answer — what records ownership (a field in NAVIGATION? a new sentinel? ACTIVE extended?),
   and how does an actor see another's in-flight slice without reading their session?
5. **Redesign vs. retire, per artifact.** The issue allows "redesigned within it **or**
   explicitly retired with migration." For each of PAUSE/ACTIVE/PROFILE, which? (Early lean:
   PROFILE stays human-only + read-guard; PAUSE/ACTIVE redesigned into the one state model.)
6. **Actor-identifier vocabulary.** What is the controlled value set for `**Actor**` (mirroring
   `**Route**`'s closed set), and how is a headless actor's identifier formed? De-hardcode
   `claude` in the autonomous-attribution line.
7. **Single PR or multi-PR?** This spans STATE.md + several commands + a script. inquire decides
   whether it needs a Milestones table / multi-PR treatment.
8. **#55 sequencing.** This cycle (PROFILE multi-actor concern) vs. #55 (PROFILE depth+growth
   reshape) — confirm the boundary so the two don't collide on the same file.
