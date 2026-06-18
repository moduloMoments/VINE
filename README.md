# VINE — Verify, Inquire, Navigate, Evolve

**Grow features on solid roots.**

VINE is a command chain for AI-assisted feature development in established codebases. It keeps the human connected, learning, and steering throughout — not watching from the sidelines while an AI codes autonomously.

> **Early adopter alert.** VINE is in active development. The commands work and we use them daily, but expect rough edges. See [CONTRIBUTING.md](CONTRIBUTING.md) for how to get involved, or open a [Discussion](../../discussions) if something breaks or feels off.

## Philosophy

Most AI coding frameworks optimize for speed. VINE optimizes for **three things growing together**:

1. **The product** — features built on solid understanding, not guesswork
2. **The agent** — Claude gets smarter about your codebase with every cycle
3. **The user** — the engineer learns patterns and deepens expertise alongside the AI

VINE is for engineers who want to stay engaged with their code, not delegate it away. The AI accelerates your work; it doesn't replace your judgment. Every phase is a partnership — Claude flags its own uncertainty, names patterns as it uses them, and calibrates to your expertise. You steer, it executes, and both sides learn.

## The Four Phases

```
vine:verify  →  vine:inquire  →  vine:navigate  →  vine:evolve
   📡              📐               🧭                🌱
 Explore         Design           Build            Grow

         ╰─────── vine:pair ───────╯
                     🤝
                Quick changes
```

### vine:verify — Context Building Spike
Research the codebase together. The engineer brings tribal knowledge, edge cases, and "the weird stuff." Claude reads broadly and asks questions. Together you produce a CONTEXT.md that captures the real landscape — not just what the code says, but what the docs don't.

**Output:** `.vine/projects/<domain>/<feature-slug>/CONTEXT.md`

### vine:inquire — Feature Specification
Design the feature on top of verified context. Discuss architecture, weigh tradeoffs (always 2-3 options), and get explicit human approval on every decision. Layer the spec on the foundation you built in verify. When the draft is ready, inquire presents SPEC.md as a clickable link and gates completion on your explicit sign-off — approve to hand off to navigate, or request changes to iterate. (Verify presents CONTEXT.md the same way on creation. Auto-opening the file is optional repo wiring, never hardcoded — the clickable link is the portable default.)

**Output:** `.vine/projects/<domain>/<feature-slug>/SPEC.md`

### vine:navigate — Guided Implementation
Build the feature together. For each slice, choose your engagement level: **"free climb"** (Claude cranks, you review the diff at the slice boundary — pairs with **auto-accept-edits**) or **"walk me through this"** (full narration, pauses for feedback — pairs with **approve-edits**). Claude recommends the permission mode that matches your chosen gear, but flipping the toggle is always your move. Claude flags its own uncertainty in the preview so you know where to focus. Every decision is documented, every slice is committed with its acceptance criteria. When your harness provides native task tools, navigate also keeps an ephemeral live view of slice progress that mirrors NAVIGATION.md — a derived view, always rebuilt from the journal, never the reverse.

**Output:** `.vine/projects/<domain>/<feature-slug>/NAVIGATION.md` + committed changes (one commit per validated slice)

### vine:evolve — Triple Evolution
Verify against acceptance criteria, then drive three evolutions. Product quality (verification, PR prep). Agent capability (CLAUDE.md updates, new commands). User growth (knowledge gained, areas to explore).

**Output:** `.vine/projects/<domain>/<feature-slug>/EVOLUTION.md` + handoff package

## Multi-PR Features

For features that span multiple PRs, VINE tracks progress across phase groups with milestone
status. When `vine:inquire` detects a larger feature (>4 slices or phase groups), it offers to
set up multi-PR tracking in `PROJECT-MAP.md`. Each phase group maps to a milestone with its own
PR, and `vine:navigate` delegates a lightweight verification pass to its verification agent
before suggesting a PR at each phase boundary.

`vine:evolve` reviews prior PRs via `gh` CLI to surface reviewer feedback that may affect
cross-phase integration. `gh` CLI is optional — evolve works without it but can't check PR
status or review comments.

## Quick Mode: vine:pair

Not every change needs the full cycle. `vine:pair` is a lightweight command for quick fixes,
small features, and minor refactors — VINE's guided narration without the artifact ceremony.

```
> /vine:pair src/auth.ts
> /vine:pair "fix the retry logic in the payments module"
```

vine:pair reads the target file and its immediate neighbors, asks what you want to change,
implements with brief narration, and produces a single commit. No CONTEXT.md, no SPEC.md —
just you and Claude working together on a small change.

If the work grows beyond a quick fix, pair suggests escalating to the full cycle.

## Session Management: vine:pause + vine:resume + vine:status

Long-running features span multiple sessions. `vine:pause` captures where you stopped and why,
`vine:resume` picks it back up, and `vine:status` gives a quick progress check.

```
> /vine:pause                    # saves session state + your notes to PAUSE.md
> /vine:resume                   # shows status, progress, and recommends next command
> /vine:status                   # quick read-only progress check
```

vine:pause detects your current phase from artifacts, asks for free-form notes, and writes a
lightweight `PAUSE.md` to the feature directory. vine:resume reads it (plus existing artifacts)
to tell you exactly where you are — no re-reading everything yourself.

vine:status is lighter than resume — it reads `PROJECT-MAP.md` (or detects artifacts) and
displays progress without loading session state or recommending next steps. Useful for a quick
check or when deciding which feature to pick up next.

Resume also works without PAUSE.md by reconstructing state from artifacts alone. PAUSE.md adds
your notes and explicit phase tracking, but it's not required.

## Key Principles

**Partnership, not delegation.** Claude flags its own uncertainty, names patterns as it uses them, and acknowledges when the engineer corrects its approach. The engineer steers, Claude executes, and both sides learn through the work — not in retrospective debriefs.

**Approve-edits mode recommended.** Run with approve-edits enabled so you review every change as it happens. VINE will suggest it, but the mode toggle is always yours — Claude can't switch permission modes for you. Navigate's per-slice gearing maps to a recommended mode: **"free climb"** → switch to **auto-accept-edits** yourself and back at the slice boundary; **"walk me through this"** → stay in **approve-edits** so each edit lands under your review. Speed when you trust the approach, control when you don't. (See [Enforced vs Advisory](#enforced-vs-advisory) for which guarantees are mechanical.)

**Human decides, always.** Every design choice, tradeoff, and priority call is made by the engineer. Claude presents options, the human chooses.

**Commit per slice.** Each validated slice gets committed with its acceptance criteria and its NAVIGATION.md journal entry — the journal update is a prerequisite for committing, not an afterthought (and mechanically [enforced when the scaffold hooks are installed](#enforced-vs-advisory)).

**Chain, don't rush.** Each phase suggests the next step but doesn't auto-trigger. The engineer decides when to move forward. Each phase completion suggests a fresh session for the next phase — state flows through `.vine/` files, not chat context. Navigate can suggest a `/clear` between slices too, selectively — recommended when context has grown heavy or the next slice is independent; re-invoking `/vine:navigate` auto-resumes at the next unfinished slice, with the journal carrying everything forward.

**Evolve everything.** Every feature is an opportunity to improve the product, make the agent smarter, and help the engineer grow. The retro block at the end of each phase captures all three.

## Installation

### Global (user-level, recommended)

```bash
npx create-vine --global
```

This installs all VINE commands (`/vine:init`, `/vine:verify`, `/vine:inquire`, `/vine:navigate`, `/vine:evolve`, `/vine:pair`, `/vine:pause`, `/vine:resume`, `/vine:status`, `/vine:optimize`, `/vine:help`) to `~/.claude/commands/vine/`, making them available in every project.

### Project-level

```bash
npx create-vine
```

Installs to `.claude/commands/vine/` in the current project.

### Upgrade

```bash
npx create-vine@latest --global
```

This overwrites command files with the latest versions. Your `.vine/` directory (context overlays,
artifacts, profile) is untouched — only the commands in `.claude/commands/vine/` are updated. After upgrading,
run `/vine:init` to discover any new tools or conventions added in the update.

Check the [CHANGELOG](CHANGELOG.md) to see what's new, or watch
[releases](https://github.com/moduloMoments/VINE/releases) on GitHub for notifications.

### Manual install

If you prefer not to use npx, copy the commands directly:

```bash
# Global
cp -r commands/vine ~/.claude/commands/vine

# Project-level
cp -r commands/vine .claude/commands/vine
```

### Piloting in an existing project (e.g., at work)

VINE creates a `.vine/` directory for feature artifacts and context overlays. If you're trying VINE in a repo you don't want to modify tracked files in, add `.vine/` to your global gitignore so it stays local:

```bash
# Create a global gitignore if you don't have one
git config --global core.excludesFile ~/.gitignore_global

# Add .vine/ to it
echo '.vine/' >> ~/.gitignore_global
```

This keeps your `.vine/` artifacts out of version control across all repos. When your team is ready to adopt VINE together, you can remove it from the global gitignore and commit `.vine/context/` to the repo instead.

### Optional: GitHub CLI

VINE works without `gh` CLI, but `vine:evolve` uses it to review prior PRs in multi-PR features
and to suggest opening PRs at the end of a cycle. Install from [cli.github.com](https://cli.github.com)
if you want those capabilities.

## Usage

### First time in a repo

Run `/vine:init` to scaffold context overlays. This discovers your repo's tools, agents, CI, and
conventions, then generates `.vine/context/` with pre-filled templates:

```
> /vine:init
```

### Start a feature

```
> /vine:verify I need to add webhook support to the payments service
```

At the end of each phase, you'll see a suggested next step. Run it when you're ready.

## Context Overlays

VINE commands load project-specific extensions from `.vine/context/` before each phase starts.
This is how you customize VINE for your codebase — wire in your repo's agents, tools, test
commands, and conventions without forking the commands themselves. (Pre-0.4 installs used
`.vine/hooks/` — commands fall back to it through 0.4.x, and `/vine:init` offers the one-time
migration.)

```
.vine/
├── PROFILE.md                     # Engineer profile (per-repo, built over time)
├── context/
│   ├── shared.md                  # Loaded by ALL phases
│   ├── verify.md                  # verify-specific extensions
│   ├── inquire.md                 # inquire-specific extensions
│   ├── navigate.md                # navigate-specific extensions
│   ├── evolve.md                  # evolve-specific extensions
│   └── pair.md                    # pair-specific extensions
├── knowledge/                     # Durable decisions & gotchas (committed, append-only)
│   └── workflow/
│       └── 2026-06-15-cut-the-derived-map-cache.md
└── projects/
    ├── payments/
    │   ├── webhook-support/       # Feature 1 (complete)
    │   │   ├── CONTEXT.md
    │   │   ├── SPEC.md
    │   │   ├── NAVIGATION.md
    │   │   ├── EVOLUTION.md
    │   │   └── PROJECT-MAP.md     # Progress tracker
    │   └── retry-logic/           # Feature 2 (in progress)
    │       ├── CONTEXT.md
    │       ├── SPEC.md
    │       ├── PROJECT-MAP.md     # Progress + milestones (multi-PR)
    │       └── PAUSE.md           # Session state (ephemeral)
    └── auth/
        └── sso-migration/         # Feature 3 (in progress)
            └── CONTEXT.md
```

### shared.md

Loaded by every VINE phase. Contains repo-wide context:

- Available slash commands and agents with descriptions
- Project conventions (testing, linting, naming, architecture patterns)
- Team context (ownership, review patterns, external integrations)
- CI/CD commands (how to run tests, lint, build)

### Per-phase overlays

Only created when there's something phase-specific to add:

| File | Example content |
|------|----------------|
| `verify.md` | Key areas to always explore, domain-specific questions |
| `inquire.md` | Preferred architecture patterns, design review checklists |
| `navigate.md` | Agents to run after code changes, test commands per domain |
| `evolve.md` | PR creation workflow, CI validation, issue tracker integration |
| `pair.md` | Test commands, lint/format requirements, commit conventions for small changes |

### How overlays load

Each VINE command checks for `.vine/context/shared.md` and `.vine/context/<phase>.md` before
starting. If found, the contents are applied as additional instructions on top of the base
command. Overlay instructions take precedence when they conflict with defaults.

As you complete VINE cycles, `/vine:evolve` suggests updates to your overlay files based on
what you learn — tools that proved useful, patterns that should be default, agents that
should auto-run.

## Enforced vs Advisory

VINE is honest about what it can and can't make a session do. Most of its guarantees are
advisory — behaviors the commands request and Claude follows, with nothing blocking the
alternative. One becomes mechanical when you install the native hook scaffold.

### Enforced — when the scaffold hook is installed

| Guarantee | Mechanism |
|-----------|-----------|
| **Journal before commit** — `git commit` is blocked during an active navigate session until the feature's NAVIGATION.md has been updated | `journal-check.sh` (PreToolUse hook); blocks with the journal path and escape hatch in the message |

The hook scopes itself to active VINE sessions via the `.vine/ACTIVE` sentinel — navigate
writes it at session start; navigate, pause, and evolve clear it at session end. No
sentinel means the hook is a silent no-op, so non-VINE work in the same repo is never
affected. If a crashed session leaves the sentinel behind, `rm .vine/ACTIVE` disables the
hook (the block message says exactly that).

The staleness check compares the journal's file modification time against the last commit
— deliberately not git state — so it works identically whether your repo commits `.vine/`
artifacts or keeps them gitignored and personal.

**Installing**: project-level `npx create-vine` puts the script in `.vine/scripts/`;
`/vine:init` then offers to wire it into `.claude/settings.json`. **Declining changes
nothing on disk**, and every guarantee below stays advisory.

Lint and test enforcement are deliberately not part of the scaffold: when to run a
project's checks depends entirely on its tooling, so that decision stays with the repo —
native Claude Code hooks in `.claude/settings.json` are available directly to teams that
want them.

### Advisory — always

| Guarantee | What actually backs it |
|-----------|------------------------|
| Approve-edits mode during phases | A recommendation and a soft ask — the mode toggle is always yours |
| Free-climb boundary review | You switch to auto-accept and back yourself; Claude asks at the slice boundary |
| Per-slice validation via the verification agent | Command instructions; nothing blocks skipping them |
| Acceptance criteria checked before each commit | Command instructions, honor system |
| One commit per validated slice | Command structure, not enforcement |
| `/clear` between phases (and selectively between slices) | A printed suggestion |

Advisory doesn't mean unreliable — it means the command asks and Claude follows
instructions, rather than a hook blocking the alternative. The distinction matters most
when deciding how much to trust a long or lightly-attended session.

## State Artifacts

| File | Phase | Purpose |
|------|-------|---------|
| `CONTEXT.md` | verify | Codebase landscape, tribal knowledge, tech debt |
| `SPEC.md` | inquire | Feature design, acceptance criteria, work slices |
| `NAVIGATION.md` | navigate | Implementation journal, commit-per-slice log |
| `EVOLUTION.md` | evolve | Verification results, triple evolution report |
| `PROJECT-MAP.md` | verify (created), all phases (updated) | VINE progress tracker, multi-PR milestone status |
| `PAUSE.md` | pause | Session state, phase, active slice, engineer notes (ephemeral) |
| `PROFILE.md` | all phases | Engineer's domain expertise and growth log (per-repo) |

These files are human-readable, git-friendly, and designed to survive session boundaries. See the full [State Reference](references/STATE.md) for detailed artifact formats and the chaining protocol.

**When your repo tracks `.vine/` artifacts** (the team-shared choice), VINE keeps the committed artifacts in step with the code: each **slice commit** bundles the code with that slice's NAVIGATION.md journal entry and any SPEC.md deviation notes, and each **phase-group PR** carries the group's full artifact state — SPEC plan, NAVIGATION record, and PROJECT-MAP tracker — alongside the diff. Repos that keep `.vine/` gitignored or personal commit code only; the journal-before-commit guarantee compares file modification time, not commit contents, so it holds either way.

This repo uses VINE on itself — browse [`.vine/projects/`](.vine/projects/) to see real artifacts from completed features. Each resolved project shows how CONTEXT → SPEC → NAVIGATION → EVOLUTION builds up across the four phases.

## Durable Decisions

Some knowledge can't be recovered by reading the code: *why* an approach was chosen over its
alternatives, or a gotcha that cost someone time to learn. VINE keeps that durable judgment in a
committed, append-only layer — one Markdown file per record, under `.vine/knowledge/<domain>/`:

```
.vine/knowledge/
└── workflow/
    ├── 2026-06-15-cut-the-derived-map-cache.md
    └── 2026-06-16-decision-delegation-default-able-vs-human-required.md
```

Each record follows a lightweight [ADR](https://adr.github.io) shape — Title / Status / Context /
Decision / Consequences — with the title written as a declarative sentence, so `ls` of a domain is
its table of contents. Records are **committed by default**: durable judgment travels with the repo
for every teammate. They're immutable — a changed decision is a *new* record that supersedes the old
one (the old record's status flips to point forward), never an in-place edit. See the
[State Reference](references/STATE.md) for the full format and the five properties of a good record.

`vine:evolve` distills records from a finished cycle — you pick which decisions are worth keeping —
and `vine:verify` surfaces a domain's records at the start of exploration, as prior judgment that is
*never auto-trusted* (a record can describe a decision the code has since moved past). With no
records present, both commands behave exactly as before.

### Project lifecycle

VINE projects move through **active → resolved → archived**, all opt-in:

- **Active** — the default; work in progress.
- **Resolved** — after `vine:evolve`, you can mark a project resolved (an empty `.resolved` marker).
  Resolved projects drop out of command prompts but stay accessible by path.
- **Archived** — evolve offers to move a resolved project under `.vine/projects/.archive/`, getting
  completed work out of the way while preserving its artifacts. Always your call; VINE never
  auto-archives.

**Durable-decision records persist across archival.** They live in `.vine/knowledge/`, separate from
`.vine/projects/`, and are never moved when a project is archived — the judgment outlives the project
that produced it.

## Agents running VINE

The same phases a human drives can also run **headless** — an agent executes the work
unattended, and a reviewer (a person, or another agent) checks it afterward. Headless is
opt-in and gated: nothing about the normal human-driven flow changes unless you deliberately
delegate a scope.

**The routing gate.** At the start of `vine:navigate`, before any code is written, VINE decides
whether a scope is *eligible* to run headless. It checks four things: a validation baseline
exists (so the agent can verify its own work), the spec carries acceptance criteria, the work is
independent of anything in flight, and the files it will touch are enumerable. If any is missing,
the scope stays interactive — the gate only ever **withholds the headless option**; it never
alters or degrades the human-driven path. For an ordinary interactive session the gate is a
no-op.

**The gate record.** When a scope is eligible, the decision is written to a `ROUTE.md` in the
feature directory: the verdict, the **allowlist** of files the work may touch, the constraints
the agent must honor, the validation baseline that must stay green, and a stamp recording the
repo state the decision was made against. A headless run is bound by this record — touch only the
allowlist, keep validation green before each commit, and **escalate anything a human must own**.
Every decision point in the commands is tagged `human-required` or `default-able`; on a
human-required decision the agent writes a structured handoff to NAVIGATION.md and stops rather
than guessing.

**The reviewer.** [`agents/vine-reviewer.md`](agents/vine-reviewer.md) is the recipe for a fresh
reviewer who wasn't part of the session: how to orient (read the originating scope, then the
journal, then the commits and final files) and what to produce (a verdict, severity-ordered
findings, and a draft PR description). Its `tools` exclude Edit/Write, so "report only" is enforced
by the platform, not just asserted. Everything the reviewer needs lives in durable state, not
session memory.

**The agents.** [`agents/`](agents/) ships the agent definitions VINE auto-delegates to by
description match: `vine-verification` (runs the validation baseline and checks acceptance
criteria), `vine-codebase-explorer` (structured codebase exploration), `vine-coder` (the autonomous
coding role — implements a ticketed slice end-to-end and opens a PR), and `vine-reviewer` (the
cold-reviewer role described above). The verification and exploration agents work the same in an
interactive or headless run.

See the [State Reference](references/STATE.md) for the ROUTE.md format and the decision-delegation
and handoff contracts.

## Engineer Profile

With AI assistance, engineers at every level are moving into unfamiliar domains at increasing speed. A principal exploring a new area of the codebase deserves the same depth of explanation as a junior encountering it for the first time. A junior who's built confidence in their domain deserves the same concise respect as a senior. The profile tracks domain expertise, not seniority — helping juniors to principals grow in areas both new and familiar.

VINE tracks your growth through a layered profile model:

**VINE layer** (`.vine/PROFILE.md`) — Tracks which domains of this codebase you're comfortable with, based on actual VINE cycles. Four levels: **confident**, **familiar**, **learning**, **new**. Commands use this to calibrate the partnership — your expertise level informs the default engagement style and how much Claude narrates, but you always choose per-slice how closely to work together.

**Claude layer** (memory + CLAUDE.md) — General preferences, interaction style, learning patterns. Suggested by `vine:evolve` after each cycle.

The profile builds organically. The first time you run `vine:verify` in a new domain, you'll be asked to rate your familiarity. As you complete cycles, `vine:evolve` proposes level updates and growth log entries. No upfront setup required.

This separation avoids duplication: VINE handles what Claude doesn't cover (per-domain expertise tracking), while Claude's native memory handles what it's already good at (general preferences and interaction patterns).

## How VINE compares

The AI-assisted development field has settled into camps. **Spec-as-artifact** frameworks treat the written spec as the unit of work; **role-persona** frameworks orchestrate the work through named agent roles; **autonomous-speed** tools optimize for the AI writing code with the human approving at the end. VINE's bet is different: the scarce resource is **human attention**, so the framework's job is routing it — deciding per scope of work how much engagement it deserves, from walking through every change to trusting a slice entirely (and, on the [roadmap](ROADMAP.md), extending that same axis to parallel and headless execution).

Where the named players stand, as of June 2026:

- **[Spec-Kit](https://github.com/github/spec-kit)** (GitHub, 111k+ stars) anchors the spec-as-artifact camp, with a skills-based install for Claude Code and Codex and a large extension ecosystem. VINE shares the artifact discipline (CONTEXT → SPEC → NAVIGATION → EVOLUTION) but treats artifacts as the *handoff contract* of a routing loop, not the product.
- **Kiro** (AWS, GA) brings EARS-syntax requirements and a dedicated spec mode at a price premium — spec-as-artifact as a paid IDE feature. VINE is markdown in your repo, on the tooling you already run.
- **BMAD v6** leads the role-persona camp, building its agent roles on the same skills/subagents substrate VINE consumes. VINE is converging on roles from the opposite direction: a role is an overlay stack plus an entry point plus handoff contracts, earned through the routing loop rather than declared up front.
- **Augment Cosmos** is the strongest team-level shared-context product, and makes the opposite staleness bet: a persistent semantic index, where VINE (like the platform it rides) bets on live-reading the repo at session time so context is never older than the checkout.
- **agent-context** is the closest prior art to VINE's knowledge layer. Its multi-author and staleness story is git's defaults; VINE's knowledge lifecycle (promotion, archival, conflict-safe conventions) is the differentiation seam.
- **AGENTS.md**, now under the Linux Foundation's AAIF, is substrate, not competition — a standard VINE rides, the same way it consumes Claude Code's native hooks, tasks, and memory rather than rebuilding them.

The gap nobody has standardized: **configuration layering above repo scope** — how personal, team, and company context compose, and which layer wins on conflict. That's the territory VINE's overlay matrix targets ([roadmap](ROADMAP.md), "Overlay layers and precedence").

Against the autonomous-speed camp specifically:

| | Autonomous frameworks | VINE |
|---|---|---|
| **Optimizes for** | Speed | Growth (product + agent + user) |
| **Human role** | Approves at the end | Routes their own attention, steers where it matters |
| **AI transparency** | Confident by default | Flags its own uncertainty |
| **Engagement** | One mode fits all | Per-slice gearing (walk me through / free climb; hybrid-parallel and headless on the [roadmap](ROADMAP.md)) |
| **Commits** | Auto | Validated and journaled per slice |
| **Best for** | Greenfield / scripted tasks | Established codebases |
| **Learning model** | One-way (AI executes) | Partnership (both sides learn and teach) |

## Is VINE for you?

**VINE is a good fit if:**
- You're working in an **established codebase** with accumulated complexity, undocumented edge cases, or tribal knowledge that lives in people's heads rather than in docs
- You want to **stay engaged** with the code the AI writes — steering decisions, catching issues, understanding the implementation — not just reviewing a finished PR
- You've been burned by AI-generated code that **looked right but missed context** — the pagination bug nobody documented, the service that's mid-migration, the module with a circular dependency
- You want the AI to get **smarter about your specific codebase** over time, not start from scratch every session

**VINE is probably not for you if:**
- You're doing greenfield development with no existing patterns to navigate
- You prefer fully autonomous AI coding where you review the output at the end
- Your changes are consistently small and self-contained (though `vine:pair` handles quick fixes without the full cycle)

**VINE stays out of your way when you don't need it.** Verify evaluates scope early — if the work is simpler than expected, it suggests switching to `vine:pair` instead of the full cycle. Navigate's free climb mode lets you hand off slices where you trust the approach. Skip is always an option. The framework gets rigorous when complexity demands it and lightweight when it doesn't.

## Tips

- [Auto-preview artifacts with glow](docs/artifact-preview.md) — opens a formatted terminal preview when VINE writes phase artifacts

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines. The short version: open an issue or [Discussion](../../discussions) before submitting a PR.

## License

MIT

---

*Built by [ModuloMoments](https://github.com/modulomoments)*
