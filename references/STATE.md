# VINE State Reference

This document defines the state artifacts that flow between VINE phases. Each phase reads from the previous phase's output and writes its own artifacts. State is file-based and human-readable so context survives across sessions, handoffs, and team members.

## Directory Structure

Per-feature artifacts live under `.vine/projects/<domain>/<feature-slug>/` in the project root. The domain is the logical area the feature touches (e.g., `payments`, `auth`, `onboarding`). The feature slug is a short, lowercase, hyphenated name for the specific work (e.g., `webhook-support`, `retry-logic`). Both are confirmed with the engineer during vine:verify via structured select prompts.

This namespacing allows multiple features to be VINEd concurrently without collision — even features in the same domain. It also provides discoverability: `ls .vine/projects/payments/` shows all payment-related VINE work at a glance.

Per-repo artifacts (like `.vine/PROFILE.md`) live directly under `.vine/` and persist across all VINE cycles.

## State Files

### CONTEXT.md (produced by vine:verify)

The landscape document. Captures what exists, what's broken, what the codebase doesn't tell you but the engineer knows.

```markdown
# Feature Context: [Feature Name]
## Date: [YYYY-MM-DD]
## Author: [engineer name] + Claude

### Codebase Landscape <!-- required -->
- Relevant modules and their responsibilities
- Key patterns and conventions in use
- Dependencies and integration points

### Current State <!-- required -->
- What works today
- Recent changes that matter

### Edge Cases & Tribal Knowledge <!-- required -->
- Things the engineer knows that aren't documented
- Gotchas, workarounds, historical context
- "Here be dragons" areas

### Tech Debt in Affected Areas <!-- optional -->
- Known debt in modules this feature will touch
- Debt that may affect implementation choices

### Documentation Gaps <!-- optional -->
- Documentation that needs updating
- Missing architectural decision records
- Stale comments or misleading docs

### Open Questions <!-- optional -->
- Unresolved ambiguities for vine:inquire to address
```

### SPEC.md (produced by vine:inquire)

The feature specification. Built on top of CONTEXT.md — not from scratch.

```markdown
# Feature Spec: [Feature Name]
## Date: [YYYY-MM-DD]
## Built on: CONTEXT.md ([date])
## Decisions made by: [engineer name]

### Problem Statement <!-- required -->
- What we're solving and why

### Approach <!-- required -->
- Chosen architecture with rationale
- Key decisions and why they were made

### Acceptance Criteria <!-- required -->
- Verifiable conditions for "done"
- Edge cases explicitly handled
- Performance/security considerations

### Work Slices <!-- optional -->
Ordered, independent units of work. The `### Slice N:` headings are the required content;
`### Work Slices` itself is an optional umbrella (see Layouts below).

### Slice 1: [Name] <!-- required -->
- **Goal**: What this slice accomplishes
- **Depends on**: Previous slices or nothing
- **Files likely touched**: [list]
- **Acceptance criteria**: [specific, verifiable]
- **Complexity signal**: Low / Medium / High + brief rationale

A **conditional** slice is a `### Slice N:` heading suffixed `(CONDITIONAL)` with one extra
field — `**Condition**: Only if [condition from verify findings]` — so navigate can evaluate
it on arrival and skip cleanly when the condition isn't met.

**Layouts** — slices appear one of two ways; `### Slice N:` is the invariant either way:
- **Flat** (4 or fewer slices): `### Slice N:` headings sit under the optional `### Work
  Slices` umbrella.
- **Grouped** (larger / multi-PR features): `## Phase N: [Name]` group headings replace the
  flat umbrella, with the same `### Slice N:` headings under each phase. This is what
  `vine:inquire` produces for larger features; navigate works one phase group per session.

### Tech Debt Integration <!-- optional -->
- Debt items from CONTEXT.md addressed in this work
- Debt items deferred (with reasoning)
- New debt being consciously taken on

### Dependencies & Risks <!-- optional -->
- External dependencies or blockers
- Risk factors and mitigations

### Backlog Updates <!-- optional -->
- Items to add/modify in project backlog
- Dependencies on other work
```

### NAVIGATION.md (produced by vine:navigate)

The implementation journal. Built incrementally — each slice is appended as it's completed, with a commit per validated slice.

```markdown
# Navigation Log: [Feature Name]
## Date: [YYYY-MM-DD]

### Slice 1: [Name] — [Status: In Progress / Complete] <!-- required -->
- **Started**: [timestamp] <!-- optional -->
- **Commit**: [hash] (or 'pending' if in progress) <!-- required -->
- **Approach taken**: What was implemented and how <!-- optional -->
- **Deviations from spec**: Any changes and why <!-- optional -->
- **Validation**: [pass/fail — lint, typecheck, tests] <!-- required -->
- **Decisions made**: Engineer choices during implementation <!-- optional -->
- **Acceptance criteria**: [met/not met with details] <!-- required -->
- **Engineer feedback incorporated**: [what the engineer corrected or steered] <!-- optional -->
- **Learnings**: What both sides learned from this slice <!-- required -->

### Slice 2: [Name] — [Status: In Progress / Complete] <!-- required -->
(same structure, appended after slice 1 is committed)

### Remaining Work <!-- optional -->
- Incomplete slices
- Blockers encountered
- Handoff context for next session
```

**Slice-status contract.** The ` — [Status: In Progress / Complete]` suffix on each slice heading is a writer/reader contract: `vine:navigate` writes it (a slice is `In Progress` while being implemented, `Complete` once committed), and `vine:pause` reads it to locate the active slice when capturing pause state. Keep the literal words `In Progress` and `Complete` — pause matches on them. The suffix is part of the heading, so it doesn't affect trellis Check A, which matches slice headings by their `Slice N:` prefix.

**Remaining Work dependency.** The `### Remaining Work` section stays `<!-- optional -->` because it only exists at session boundaries — `vine:navigate` writes it when pausing between slices and at phase completion, so a mid-implementation journal legitimately won't have it (promoting it to required would fail validation on every in-progress journal). When it *is* present, two readers depend on it: `vine:resume`'s no-PAUSE.md path reconstructs handoff state from it, and native-task rebuild (see [Source of Truth vs Derived Views](#source-of-truth-vs-derived-views)) uses it for cross-slice context.

**Deviation-closure contract.** When a slice's `**Deviations from spec**` field is anything but "None", `vine:navigate` step 6 also annotates the affected SPEC.md section (strikethrough/addendum), and navigate's completion gate verifies the pair held — an annotated-nowhere deviation is a gate gap, listed like a missing commit hash. The rule is load-bearing and lives in the command (this file is supplementary and doesn't ship via create-vine); it's recorded here so contributors editing the field keep both halves in sync.

**AC-traceability contract.** SPEC.md's top-level `### Acceptance Criteria` is the cycle contract, distinct from the per-slice `**Acceptance criteria**` checklists. `vine:evolve`'s verification rollup maps each cycle-level criterion to the slice/commit that satisfied it, flagging any with no evidence as **unaccounted** — this mapping is the EVOLUTION.md *Acceptance Criteria Results* table. As above, the rule lives in the command; this note keeps the two AC layers legible to contributors.

**Verification-tier contract.** VINE runs its cross-change verification at two tiers, both delegated to the `vine-verification` agent's feature-verification mode — the checklist itself lives only in `agents/vine-verification.md` (the one shipped surface both commands can depend on); neither command restates it. `vine:navigate` invokes the mode at **phase-group scope** at each phase-group boundary: the base checks (full test suite, cross-slice integration, acceptance criteria, test coverage) scoped to the phase group — a deliberately lighter pre-PR gate. `vine:evolve` invokes it at **full-feature scope** at cycle end: the base checks across the whole feature plus the cross-cutting checks (error paths, cross-slice edge cases, combined performance). The asymmetry is intentional. Evolve-only scope stays in evolve.md because it isn't agent-runnable: AC traceability, spec deviation review, follow-up triage, handoff prep, and multi-PR prior-PR review + CI status via `gh`. As above, the rules live in the agent and the commands; this note documents the boundary so contributors keep all three in sync.

### EVOLUTION.md (produced by vine:evolve)

The triple evolution report. Captures growth across product, agent, and user.

```markdown
# Evolution Report: [Feature Name]
## Date: [YYYY-MM-DD]

### Product Evolution <!-- required -->
- **Acceptance Criteria Results**: [pass/fail table for each criterion]
- **Spec Deviations**: [list with rationale]
- **Follow-Up Items**: [concrete backlog suggestions]

### Agent Evolution <!-- required -->
- **CLAUDE.md Suggestions**: Updates to project instructions
- **Command Suggestions**: New commands or improvements identified
- **Workflow Improvements**: Patterns worth codifying
- **Context Overlay Update Suggestions**: Updates to .vine/context/ based on learnings
- **VINE Process Observations**: What worked, what to adjust

### User Evolution <!-- required -->
- **Engineer Contributions**: Decisions and domain knowledge that shaped the implementation

### Handoff Package <!-- required -->
- **PR Description**: [ready to paste]
- **Reviewer Notes**: Context for code reviewers
- **Commit Suggestions**: [if changes aren't already committed]
- **Context for future sessions**: What someone picking this up should know
```

### PAUSE.md (produced by vine:pause, consumed by vine:resume)

An ephemeral session artifact. Captures where the engineer stopped and why — the context that existing artifacts don't preserve. Unlike other state files, PAUSE.md is **consumed-once**: it exists only between the pause and whatever picks the work back up. The command that resumes the work deletes it — a consumed pause that lingers keeps firing the "PAUSE.md exists → suggest `vine:resume`" suggestion and re-presents stale notes on the next resume.

```markdown
# Paused: [Feature Name]
## Paused at: [YYYY-MM-DD HH:MM]
## Phase: [verify | inquire | navigate | evolve]
## Active slice: [Slice N: Name — or "N/A" if not in navigate]

### Notes
[Free-form context from the engineer — why they stopped, what they were
thinking, what to pick up first, anything that won't survive a session break]
```

**Lifecycle:**

1. **Created** by `vine:pause` — detects current phase from artifact presence, asks the engineer for notes, writes PAUSE.md to the feature directory.
2. **Overwritten** by subsequent `vine:pause` calls — only one pause state exists per feature at a time.
3. **Consumed** (read, surfaced, then deleted) by whatever picks the work back up. Every deletion trigger:
   - `vine:resume` — after displaying the notes.
   - `vine:navigate` — at session start, the same moment `.vine/ACTIVE` is written; notes are surfaced in the starting-point summary first.
   - `vine:inquire` — at session start, after reading CONTEXT.md (handles a pause taken after verify); notes are surfaced in the context summary first.
   - `vine:evolve` — at session start, after reading the feature's artifacts; notes are surfaced first.
   - `vine:evolve` when writing `.resolved` — backstop; a resolved project's pause state is definitionally stale.

   No consumed pause survives a restarted session: if PAUSE.md still exists, the pause hasn't been picked back up yet.

**Design constraints:**

- **Optional.** Resume works without PAUSE.md by falling back to artifact-only detection. PAUSE.md adds engineer notes and explicit phase tracking but isn't required.
- **Ephemeral.** Not part of the permanent artifact chain. Not referenced by evolve's handoff package. Exists only to bridge session gaps.
- **One per feature.** No history of pause states. The most recent pause is the only one that matters.
- **Consumed-once.** Picking the work back up deletes the file. Notes worth keeping beyond the resume belong in NAVIGATION.md's Remaining Work, not in PAUSE.md.

### .vine/ACTIVE (active-session sentinel, written by vine:navigate)

An ephemeral repo-level sentinel marking "a navigate session is active on this feature right now." It lives at `.vine/ACTIVE` (repo root, not under a feature directory), is covered by the standard `.vine/*` gitignore, and never leaves the machine — so pulled In-Progress journals from teammates can never make installed hooks fire.

```
feature: .vine/projects/<domain>/<feature-slug>
phase: [phase group or slice being worked]
started: [YYYY-MM-DD HH:MM]
```

Its consumers are native hook scripts (see `.vine/scripts/`): they test the sentinel's existence to scope their checks to active work, and read the `feature:` line to find the journal. Hooks treat the feature path as an **opaque repo-relative string** — no domain/slug parsing, no assumption it lives under `.vine/projects/`.

**Lifecycle:**

1. **Written** by `vine:navigate` at session start, the same moment any PAUSE.md is consumed. At a phase group boundary where the engineer continues immediately, navigate updates the `phase:` line instead of rewriting.
2. **Deleted** at every session end: navigate's completion and pause-between-slices paths, `vine:pause`, and `vine:evolve` at session start (an evolve session means no navigate session is active).
3. **Stale sentinel escape hatch:** if a session dies without cleanup (crash, closed terminal), hooks may fire against inactive work. The fix is `rm .vine/ACTIVE` — hook block messages name this command.

**Design constraints:**

- **Deliberately minimal.** Feature path, phase, timestamp — nothing else. It is NOT a mini-PAUSE.md; handoff state lives in PAUSE.md.
- **Local-only.** Gitignored, never committed, never part of any handoff.
- **Optional.** Nothing breaks if it's absent — hooks exit as no-ops, and no command requires it to function.

### .vine/scripts/ (native hook scripts)

Shell-script home for VINE's native hook scripts — the enforcement layer behind guarantees that command prose can only request. Scripts are wired into a repo's hook configuration by init's scaffold offer (declinable; declining changes nothing on disk). All scripts are POSIX sh, treat `.vine/ACTIVE`'s feature path as an opaque repo-relative string, and **fail open**: no sentinel, missing tooling, or ambiguity exits 0 — enforcement degrades, sessions never break.

| Script | Hook event | Behavior |
|--------|------------|----------|
| `journal-check.sh` | PreToolUse (Bash) | Blocks `git commit` (exit 2) while a navigate session is active and the active feature's NAVIGATION.md is older than the last commit. The block message names the journal and the `rm .vine/ACTIVE` escape hatch. |

Validation/lint enforcement is deliberately outside the scaffold: when and how to run a project's checks depends on its tooling, so that decision stays with the repo (native hooks in `.claude/settings.json` are available directly). If VINE grows a validation contract, the Validation block proposed in #54 is its home.

A repo may carry additional scripts here beyond the user scaffold — the VINE framework repo itself keeps contributor-only tooling in the same directory (`trellis-check.sh`, the mechanical check engine that runs trellis's command and cross-reference anchor checks and writes the `.vine/.trellis-ok` stamp; `trellis-gate.sh`, the command-commit gate that reads that stamp; and `main-guard.sh`, which blocks commits on `main`; none ship via `create-vine`). The table above documents only the scaffold scripts.

### PROJECT-MAP.md (produced by vine:verify, updated by all phases)

The universal progress tracker. Shows at-a-glance where a feature stands in the VINE cycle and, for multi-PR features, which milestones have shipped. Designed for scannability in monospace terminal output — compact tables, short lines, clear status markers.

```markdown
# Project Map: [Feature Name]
## Feature: .vine/projects/<domain>/<feature-slug>
## Created: [YYYY-MM-DD]

### VINE Progress <!-- required -->

| Phase | Status | Updated |
|-------|--------|---------|
| verify | ✅ | [YYYY-MM-DD] |
| inquire | ⬜ | — |
| navigate | ⬜ | — |
| evolve | ⬜ | — |

### Milestones <!-- optional -->

| Phase | Slices | Status | PR |
|-------|--------|--------|----|
| Phase 1: [Name] | 1-3 | ⬜ Pending | — |
| Phase 2: [Name] | 4-5 | ⬜ Pending | — |
```

**Status markers** (three, used in both tables):

| Marker | Meaning | Used in |
|--------|---------|---------|
| ✅ | Complete / Shipped | VINE Progress (phase done), Milestones (PR merged) |
| 🚧 | Active / In Progress | VINE Progress (phase running), Milestones (being implemented) |
| ⬜ | Pending / Not Started | Both tables (not yet begun) |

**Lifecycle:**

1. **Created** by `vine:verify` — writes PROJECT-MAP.md alongside CONTEXT.md. VINE Progress table has verify=✅, all others=⬜. No Milestones table yet.
2. **Updated** by `vine:inquire` — sets inquire→🚧 on start, ✅ on completion. If the engineer confirms multi-PR treatment, adds the Milestones table with all phases as ⬜ Pending.
3. **Updated** by `vine:navigate` — sets navigate→🚧 on start. At phase group boundaries (multi-PR), updates the completed milestone row to ✅ Shipped and records the PR number if known. Sets navigate→✅ on completion.
4. **Updated** by `vine:evolve` — sets evolve→🚧 on start, ✅ on completion.
5. **Read** by `vine:resume` — displays VINE Progress and Milestones in the resume summary.
6. **Read** by `vine:pause` — uses current VINE phase for pause context.

**Design constraints:**

- **Optional.** Every command must work identically without PROJECT-MAP.md. No errors, no warnings. Commands check for its existence before reading or updating.
- **Created by verify only.** Other phases update it but never create it. If verify didn't create one (e.g., older project), downstream phases skip PROJECT-MAP updates silently.
- **Milestones table is conditional.** Only added by inquire when the engineer confirms multi-PR treatment. Single-PR features have a VINE Progress table but no Milestones table.
- **Scannable first.** Tables over prose. Short status markers over verbose descriptions. The whole file should be readable in a terminal glance.

## Per-Repo Artifacts

### PROFILE.md (seeded by vine:init, updated by vine:evolve)

The engineer profile. Tracks per-domain expertise within this specific repo so VINE commands can adjust explanation depth — more narration in unfamiliar areas, more concise in comfort zones.

Unlike per-feature artifacts, PROFILE.md lives at `.vine/PROFILE.md` (repo root, not under a feature directory). It persists across all VINE cycles and grows over time.

```markdown
# Engineer Profile

## Domain Expertise <!-- required -->

| Domain | Level | Last Updated | Notes |
|--------|-------|--------------|-------|
| auth | confident | 2026-03-15 | Built OAuth integration |
| payments | learning | 2026-03-27 | First cycle in progress |

## Growth Log <!-- optional -->

### 2026-03-27 — payments/webhook-support
- Explored webhook validation patterns
- First exposure to idempotency keys
```

**Expertise levels** (four, ordered by familiarity):

| Level | Meaning | Command behavior |
|-------|---------|-----------------|
| **confident** | Has built in this domain via VINE cycles | Concise narration, skip basics |
| **familiar** | Has explored or reviewed this domain | Light narration, explain non-obvious choices |
| **learning** | Currently working through first cycles | Full narration, explain the why behind decisions |
| **new** | No prior VINE exposure to this domain | Full narration, explain patterns and context |

**Lifecycle:**

1. **Introduced** at vine:init (Step 5) — informational only. Tells the engineer the profile exists and will build through vine:verify. No domain rating at init time.
2. **Re-prompted** at vine:verify start — if the current feature's domain isn't in the profile, offers to add it.
3. **Read** by vine:verify, vine:inquire, and vine:navigate — sets a one-sentence depth hint for the session. If no profile exists or the domain isn't listed, commands behave exactly as today.
4. **Updated** by vine:evolve — proposes domain level changes and growth log entries based on the completed cycle. Engineer approves via AskUserQuestion. Evolve also suggests Claude memory entries and CLAUDE.md lines for general preferences discovered during the cycle.

**Depth hint pattern** (used internally by commands, not shown to the engineer):

> "The engineer's profile indicates they are [level] with the [domain] domain. Adjust your explanation depth accordingly — be concise where they're confident, explain the why behind decisions where they're learning or new."

**Design constraints:**

- **Fully opt-in.** Every command works identically without PROFILE.md. No errors, no warnings, no degraded behavior.
- **Domain matching is exact.** The domain in PROFILE.md must match the `.vine/projects/<domain>/` namespace exactly. No fuzzy matching.
- **Engineer controls updates.** Evolve suggests changes; the engineer approves or modifies them. VINE never silently updates the profile.

## Knowledge Boundary

Repo knowledge has four homes, keyed to reader scope: every fact lives on the narrowest surface whose readers all need it, and appears there exactly once.

| Surface | Holds | Who pays the tokens |
|---------|-------|---------------------|
| `CLAUDE.md` | Repo facts every session needs — any teammate, any tool, VINE or not | Every session, every teammate |
| Native skill/agent list | The command and agent **inventory** — names and descriptions the harness already surfaces to Claude | Nobody — the harness provides it |
| `.vine/context/shared.md` | Cross-phase VINE knowledge: protocols, project-development context, inter-phase routing | VINE sessions only |
| `.vine/context/<phase>.md` | Phase-specific mappings: which agents, validation commands, and checks this phase uses | One phase's sessions only |

The cost framing is the rule's teeth: anything homed in CLAUDE.md is paid by every session of every teammate — including teammates who never run VINE. A non-VINE teammate should pay at most a few pointer lines for VINE's existence; workflow knowledge they'd never use belongs in shared.md, which only VINE sessions load.

The native-surface row has two consequences:

- **Inventories live nowhere in files.** A file-based list of available commands or agents duplicates what the harness already shows Claude, and can only drift. Files keep only what the native list can't carry (repo-specific topology, caveats).
- **Routing is not inventory.** "When X, run Y" chains and state-based suggestions are workflow knowledge — they live in shared.md (cross-phase) or a phase overlay (phase-specific), naming commands without enumerating them.

shared.md's identity in one line: cross-phase protocols + project-development context + inter-phase routing — nothing phase-specific, nothing the harness already surfaces.

When a fact moves homes, leave a one-line pointer at the old location.

**Forward references** (conventions defined now, implemented in later cycles):

- `.vine/knowledge/<domain>.md` (#51, cycle 3) — durable per-domain knowledge. When it lands, other surfaces reference a domain's knowledge file with a one-line pointer (`See .vine/knowledge/<domain>.md`), never by inlining it.
- `.vine.local/` (backlog idea) — the sharing boundary for projects: tracked `.vine/projects/` is team-shared; personal work lives outside the shared tree in a gitignored sibling root mirroring `.vine/`'s structure.

## Source of Truth vs Derived Views

Project *state* follows the same single-home discipline the Knowledge Boundary rule applies to project *facts*: every piece of state has one authoritative home, and everything that displays it is a **derived view** — a projection that can always be rebuilt from its source and never overrides it. "Derived from the artifacts" and "single source of truth" point the same direction: a view stays in sync precisely because it owns no state of its own.

**Sources of truth** (authoritative; each fact homed once, by altitude):

| State | Source of truth | Lifecycle |
|-------|-----------------|-----------|
| The plan — what slices and phase groups exist | `SPEC.md` | durable |
| Implementation progress — which slices are done, with commits, decisions, learnings | `NAVIGATION.md` | durable |
| What's active right now | `.vine/ACTIVE` | ephemeral |
| Handoff notes across a session gap | `PAUSE.md` | ephemeral |

**Derived views** (never authoritative; rebuilt from the sources above):

- **Native tasks** (`TaskCreate`/`TaskUpdate`/`TaskList`, when available) — the ephemeral, in-session **live view** of slice progress. It mirrors NAVIGATION.md: one task per slice in the current phase group, titled by the slice name, status `pending`/`in_progress`/`completed`, ordered to match slice dependencies, with a `(conditional: <condition>)` prefix on conditional slices. It holds the progress *skeleton only* — never the approach, decisions, commits, acceptance criteria, or learnings, which live solely in NAVIGATION.md. `vine:navigate` creates it at session start and updates it at slice transitions; `vine:resume` rebuilds it from NAVIGATION.md (which slices are Complete) plus SPEC.md (the full slice list). **Tasks are rebuilt FROM the journal, never the reverse** — if the session dies nothing is lost, because the live view carries no information the durable artifacts don't already have.
- **PROJECT-MAP.md** — a **durable** derived view: the scannable phase-level summary (VINE Progress + Milestones). Commands update its rows as a convenience, but every row is reconstructable from the authoritative artifacts (phase status from the artifact chain; slice and milestone status from NAVIGATION.md and SPEC.md). It is a cache for at-a-glance scanning, not a second source of truth — when it disagrees with the journal, the journal wins. This is why its schema stays coarse (phases and phase groups, not slices): pushing slice-level state into it would create a second writer for state the journal already owns.

**When task tools are unavailable** there is simply no live view: `vine:navigate`, `vine:resume`, and `vine:status` behave exactly as they do today, reading progress directly from the durable artifacts. Every consumer degrades to the source of truth.

## Committing Artifacts

Whether VINE artifacts (`CONTEXT.md`, `SPEC.md`, `NAVIGATION.md`, `EVOLUTION.md`, `PROJECT-MAP.md`) are committed is the repo's choice, drawn by `.gitignore`:

- **Tracked** (`.vine/projects/` not gitignored) = the team-shared choice (see the Knowledge Boundary rule). The artifacts travel with the code through history and PRs.
- **Untracked / personal scope** (gitignored, or a future `.vine.local/` root) = artifacts stay local to the engineer. Fully supported.

The journal-before-commit guarantee holds either way: `journal-check.sh` compares NAVIGATION.md's *modification time*, not commit contents (chosen precisely because the artifacts are gitignored in most repos). Tracking changes only *what each commit carries*, never the mechanics.

**When the repo tracks artifacts**, keep them in sync with the code as it changes — never let a tracked artifact lag the code it describes:

| Commit point | Carries (code) | Carries (tracked artifacts) |
|--------------|----------------|------------------------------|
| **Verify completion** (`vine:verify` wrap-up, after the engineer approves) | — | CONTEXT.md + PROJECT-MAP.md — their first entry into history |
| **Inquire completion** (`vine:inquire` sign-off) | — | SPEC.md + the PROJECT-MAP.md inquire row |
| **Slice commit** (`vine:navigate` step 4c) | the slice's code | that slice's NAVIGATION.md journal entry + any SPEC.md deviation annotations made during the slice (step 6) |
| **Phase-group boundary** (`vine:navigate` step 8) | — | PROJECT-MAP.md (navigate row, Milestones row → status / PR#) + the SPEC.md phase-group ✅ marker |
| **Evolve commit** (`vine:evolve`) | — | EVOLUTION.md and the `.resolved` marker |
| **PR** (= one phase group) | the group's commits | the group's full artifact state — SPEC (plan), NAVIGATION (record), PROJECT-MAP (tracker) — so a reviewer sees plan-vs-result beside the diff |

`CLAUDE.md` and `.vine/context/` overlays are ordinary tracked repo files — commit them whenever they change, regardless of the artifact-tracking choice. `PROFILE.md` is commonly gitignored (it's personal); commit it only if the repo tracks it.

**When the repo does not track artifacts**, commits carry code only; the artifacts still update on disk (for the mtime guarantee and the engineer's own continuity) but never enter a commit. No command should force-add a gitignored artifact.

## Artifact-Free Commands

Not all VINE commands produce state artifacts. `vine:pair` is a lightweight mode that compresses verify → navigate → evolve into a single session without writing CONTEXT.md, SPEC.md, NAVIGATION.md, or EVOLUTION.md. Its only outputs are code changes and a single commit.

Artifact-free commands still follow the structural conventions (frontmatter, overlays, profile loading) — they just don't participate in the state artifact chain.

## Project Lifecycle

VINE projects progress through an implicit lifecycle: active → resolved → archived. By default, all projects are active. The lifecycle is opt-in — projects without markers behave exactly as they always have.

### Resolved

After `vine:evolve` completes, the engineer can mark a project as resolved by placing a `.resolved` marker file in the project directory:

```
.vine/projects/<domain>/<feature-slug>/.resolved
```

The file is empty — its presence is the signal. Commands that list feature directories (inquire, navigate, evolve) filter out resolved projects from `AskUserQuestion` prompts. Resolved projects are still accessible by explicit path.

### Archived

Archiving moves a resolved project to `.vine/projects/.archive/`:

```
.vine/projects/.archive/<domain>/<feature-slug>/
```

This gets completed work fully out of the way while preserving artifacts. Archiving is manual — VINE doesn't auto-archive.

### Filtering Convention

Commands that present feature directory lists via `AskUserQuestion` must:

1. Skip directories containing a `.resolved` file
2. Skip anything under `.vine/projects/.archive/`
3. If all projects are resolved/archived, tell the engineer and suggest starting a new cycle with `vine:verify`

If the engineer needs to access a resolved project, they can pass its path explicitly as an argument.

## Chaining Protocol

Each phase ends with a **Next Step Suggestion** that tells the user exactly what to run next and why. Each phase also suggests starting a fresh session (`/clear`) so state flows through `.vine/` files rather than chat context:

```
---
✅ vine:verify complete → CONTEXT.md written
📋 Suggested next step: /clear, then run /vine:inquire to build the feature spec on top of this context.
   Key items for inquire to address: [list open questions from CONTEXT.md]
---
```

This is a suggestion, not an auto-trigger. The engineer decides when to proceed.

**Exception — `vine:resume`.** Resume does *not* suggest `/clear` before its recommended next
step. The `/clear` convention exists to flush a heavy phase's accumulated chat context so the
next phase reads state from `.vine/` files; resume is the inverse — it exists to *rebuild* that
context into the current session, so clearing would immediately discard what it just restored.
Resume hands the engineer back into the work that was already running, in the same session.
`vine:status` is also exempt: it neither chains nor suggests next steps.
