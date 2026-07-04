# VINE — Verify, Inquire, Navigate, Evolve

**Grow features on solid roots.**

VINE is a command chain for AI-assisted feature development in established codebases. It keeps the human connected, learning, and steering throughout — not watching from the sidelines while an AI codes autonomously.

> **Early adopter alert.** VINE is in active development. The commands work and we use them daily, but expect rough edges. See [CONTRIBUTING.md](CONTRIBUTING.md) for how to get involved, or open a [Discussion](../../discussions) if something breaks or feels off.

## Quick Start

VINE installs as a native Claude Code plugin:

```bash
claude plugin marketplace add moduloMoments/VINE
claude plugin install vine@moduloMoments
```

Then, in a Claude Code session in your repo:

```
> /vine:init                # once per repo — scaffolds .vine/ context overlays
> /vine:verify I need to add webhook support to the payments service
```

That's the whole on-ramp. **Start with `verify` — the rest finds you.** Every phase ends by
suggesting the exact next command to run, so you never need to memorize the command list:
verify hands you to inquire, inquire to navigate, navigate to evolve. (Skipped `init`? Verify
still works and will suggest it.)

The install brings all 11 phases (`/vine:init`, `/vine:verify`, `/vine:inquire`, `/vine:navigate`, `/vine:evolve`, `/vine:pair`, `/vine:pause`, `/vine:resume`, `/vine:status`, `/vine:optimize`, `/vine:help`), the two agents the phases call (codebase exploration + verification), and the journal-check hook — available in every project.

### Updating

```bash
claude plugin update vine@moduloMoments
```

(Or `/plugin` inside a session to manage plugins interactively. The bare name `vine` won't
resolve — include the `@moduloMoments` marketplace suffix.) Your `.vine/` directory (context
overlays, artifacts) and the personal `.vine.local/` root (profile, personal overlays) are
untouched — only the plugin is updated. Check the [CHANGELOG](CHANGELOG.md) to see what's new,
or watch [releases](https://github.com/moduloMoments/VINE/releases) on GitHub.

### Migrating from npx

Earlier versions of VINE installed command files via `npx create-vine` (into `.claude/commands/vine/`).
The commands now ship as plugin skills, so a legacy install is no longer needed — remove it and install
the plugin instead:

```bash
rm -rf .claude/commands/vine    # or ~/.claude/commands/vine for a global install
claude plugin marketplace add moduloMoments/VINE
claude plugin install vine@moduloMoments
```

`/vine:init` also detects a legacy `.claude/commands/vine/` directory and offers to remove it for you;
declining changes nothing.

### Piloting in an existing project (e.g., at work)

VINE creates a `.vine/` directory for context overlays and feature artifacts, and tracks it by default — the artifacts are meant to travel with the repo (work-in-public). Personal and ephemeral state stays out of git in the sibling `.vine.local/` root (your profile, personal overlays, pause state). Two ways to pilot before committing to the shared tree:

- **Keep individual features local.** At project creation, `vine:verify` offers a "keep local" option that routes the feature into the gitignored `.vine.local/projects/` instead of the tracked tree.
- **Keep everything local.** To try VINE in a repo without adding any tracked files, add `.vine/` to your global gitignore:

```bash
git config --global core.excludesFile ~/.gitignore_global
echo '.vine/' >> ~/.gitignore_global
```

**Graduating to a team.** When your team adopts VINE together, commit the overlays under `.vine/context/` you want shared and mark team-enforced sections `<!-- class: policy -->` so a personal overlay can't weaken them — see the team-overlay recommendation in `.vine/context/shared.md`. Overlay *content* stays repo-local and consumer-authored: VINE ships no overlay-distribution mechanism. A company that wants conventions to travel across repos can fork the plugin and edit its skills and agents — those distribute natively through the marketplace — while each repo's `.vine/context/` overlays remain its own.

### Optional: GitHub CLI

VINE works without `gh` CLI, but `vine:evolve` uses it to review prior PRs in multi-PR features
and to suggest opening PRs at the end of a cycle. Install from [cli.github.com](https://cli.github.com)
if you want those capabilities.

## The Core Loop

```
vine:verify  →  vine:inquire  →  vine:navigate  →  vine:evolve
   📡              📐               🧭                🌱
 Explore         Design           Build            Grow
```

One feature, four phases, each handing verified state to the next through files in
`.vine/projects/` — so each phase can start in a fresh session with nothing lost.

### vine:verify — Context Building Spike

**This is where every feature starts.** Research the codebase together. The engineer brings tribal knowledge, edge cases, and "the weird stuff." Claude reads broadly and asks questions. Together you produce a CONTEXT.md that captures the real landscape — not just what the code says, but what the docs don't. If the work turns out simpler than expected, verify says so and offers to drop into lightweight `vine:pair` instead of the full cycle.

**Output:** `.vine/projects/<domain>/<feature-slug>/CONTEXT.md`

### vine:inquire — Feature Specification

Design the feature on top of verified context. Discuss architecture, weigh tradeoffs (always 2-3 options), and get explicit human approval on every decision. When the draft is ready, inquire presents SPEC.md as a clickable link and gates completion on your explicit sign-off — approve to hand off to navigate, or request changes to iterate.

**Output:** `.vine/projects/<domain>/<feature-slug>/SPEC.md`

### vine:navigate — Guided Implementation

Build the feature together. For each slice, choose your engagement level: **"free climb"** (Claude cranks, you review the diff at the slice boundary) or **"walk me through this"** (full narration, pauses for feedback). Claude flags its own uncertainty in the preview so you know where to focus. Every decision is documented, every slice is committed with its acceptance criteria.

**Output:** `.vine/projects/<domain>/<feature-slug>/NAVIGATION.md` + committed changes (one commit per validated slice)

### vine:evolve — Triple Evolution

Verify against acceptance criteria, then drive three evolutions. Product quality (verification, PR prep). Agent capability (CLAUDE.md updates, overlay improvements). User growth (knowledge gained, areas to explore).

**Output:** `.vine/projects/<domain>/<feature-slug>/EVOLUTION.md` + handoff package

## When You Need Them

The rest of VINE stays out of the way until a phase suggests it or you go looking:

**`vine:pair` — quick changes.** Not every change needs the full cycle. Pair reads the target
file and its neighbors, asks what you want, implements with brief narration, and produces a
single commit. No CONTEXT.md, no SPEC.md. If the work grows, pair suggests escalating to the
full cycle — and verify's scope check suggests de-escalating to pair.

```
> /vine:pair src/auth.ts
> /vine:pair "fix the retry logic in the payments module"
```

**`vine:pause` / `vine:resume` / `vine:status` — session management.** Long features span
sessions. Pause captures where you stopped and why (a lightweight PAUSE.md with your notes);
resume reads it plus the artifacts to tell you exactly where you are; status is a quick
read-only progress check. Resume also works without a PAUSE.md by reconstructing state from
artifacts alone.

**Multi-PR features.** When `vine:inquire` detects a larger feature (>4 slices or phase
groups), it offers milestone tracking in `PROJECT-MAP.md` — each phase group maps to its own
PR, with a lightweight verification pass at each boundary. `vine:evolve` reviews prior PRs via
`gh` CLI to surface feedback affecting cross-phase integration.

**`vine:optimize` / `vine:help` — maintenance and reference.** Optimize tunes your overlay
files and workflow chains as your repo's tooling evolves; help lists every command with usage.

## Philosophy

Most AI coding frameworks optimize for speed. VINE optimizes for **three things growing together**:

1. **The product** — features built on solid understanding, not guesswork
2. **The agent** — Claude gets smarter about your codebase with every cycle
3. **The user** — the engineer learns patterns and deepens expertise alongside the AI

VINE is for engineers who want to stay engaged with their code, not delegate it away. The AI accelerates your work; it doesn't replace your judgment. Every phase is a partnership — Claude flags its own uncertainty, names patterns as it uses them, and calibrates to your expertise. You steer, it executes, and both sides learn.

### Key Principles

**Partnership, not delegation.** Claude flags its own uncertainty, names patterns as it uses them, and acknowledges when the engineer corrects its approach. The engineer steers, Claude executes, and both sides learn through the work — not in retrospective debriefs.

**Ask permissions mode recommended.** Run with edit approval on so you review every change as it happens. VINE will suggest it, but the mode toggle is always yours — Claude can't switch permission modes for you. Navigate's per-slice gearing maps to a recommended mode: **"free climb"** → switch to **auto-accept-edits** yourself and back at the slice boundary; **"walk me through this"** → stay in **approve-edits** so each edit lands under your review. (See [Enforced vs Advisory](#enforced-vs-advisory) for which guarantees are mechanical.)

**Human decides, always.** Every design choice, tradeoff, and priority call is made by the engineer. Claude presents options, the human chooses.

**Commit per slice.** Each validated slice gets committed with its acceptance criteria and its NAVIGATION.md journal entry — the journal update is a prerequisite for committing, not an afterthought (and mechanically [enforced by the plugin's journal-check hook](#enforced-vs-advisory)).

**Chain, don't rush.** Each phase suggests the next step but doesn't auto-trigger. The engineer decides when to move forward. Each phase completion suggests a fresh session for the next phase — state flows through `.vine/` files, not chat context.

**Evolve everything.** Every feature is an opportunity to improve the product, make the agent smarter, and help the engineer grow. The retro block at the end of each phase captures all three.

## Context Overlays

VINE commands load project-specific extensions from `.vine/context/` before each phase starts.
This is how you customize VINE for your codebase — wire in your repo's agents, tools, test
commands, and conventions without forking the commands themselves. (Pre-0.4 installs used
`.vine/hooks/` — commands fall back to it through 0.4.x, and `/vine:init` offers the one-time
migration.)

```
.vine/                             # Tracked — travels with the repo
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
├── projects/
│   ├── payments/
│   │   ├── webhook-support/       # Feature 1 (complete)
│   │   │   ├── CONTEXT.md
│   │   │   ├── SPEC.md
│   │   │   ├── NAVIGATION.md
│   │   │   ├── EVOLUTION.md
│   │   │   └── PROJECT-MAP.md     # Progress tracker
│   │   └── retry-logic/           # Feature 2 (in progress)
│   │       ├── CONTEXT.md
│   │       ├── SPEC.md
│   │       └── PROJECT-MAP.md     # Progress + milestones (multi-PR)
│   └── auth/
│       └── sso-migration/         # Feature 3 (in progress)
│           └── CONTEXT.md
└── ACTIVE                         # Active-session sentinel (gitignored, per-worktree)

.vine.local/                       # Personal root — gitignored, mirrors .vine/
├── PROFILE.md                     # Engineer profile (per-repo, built over time)
├── context/
│   └── shared.md                  # Your personal overlay (optional; overrides preference sections)
└── projects/
    └── payments/
        └── retry-logic/
            └── PAUSE.md           # Session state (ephemeral, mirrors the feature's path)
```

The framework's own machinery (overlay loading and precedence rules, the collaboration stance,
interaction constraints) ships *with the plugin* — its `PROTOCOL.md`, loaded by every phase
before the overlays — so it updates with the plugin and never goes stale in your repo. Your
overlays carry only repo-specific context: `shared.md` is loaded by every phase (conventions,
team context, the validation contract); per-phase overlays exist only where one phase needs
something the others don't. Overlay instructions take precedence over plugin defaults when they
conflict; your personal layer in `.vine.local/context/` overrides preference sections but never
`<!-- class: policy -->` ones. **The full who-wins-over-what chain — plugin, repo overlays,
personal overlays, profile, and the hook — is one page:
[What controls what](docs/precedence.md).**

As you complete VINE cycles, `/vine:evolve` suggests updates to your overlay files based on
what you learn — tools that proved useful, patterns that should be default, agents that
should auto-run.

## Enforced vs Advisory

VINE is honest about what it can and can't make a session do. Most of its guarantees are
advisory — behaviors the commands request and Claude follows, with nothing blocking the
alternative. One is mechanical — the plugin ships the journal-check hook default-on.

### Enforced — the journal-check hook (ships with the plugin)

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

**Installing**: nothing to install — the hook ships *with the plugin* and is wired
automatically, so installing VINE turns it on. Lint and test enforcement are deliberately
not part of the scaffold: when to run a project's checks depends entirely on its tooling,
so that decision stays with the repo — native Claude Code hooks in `.claude/settings.json`
are available directly to teams that want them.

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
| `PAUSE.md` | pause | Session state, phase, active slice, engineer notes (ephemeral; in `.vine.local/`) |
| `PROFILE.md` | all phases | Engineer's domain expertise and growth log (per-repo; in `.vine.local/`) |

These files are human-readable, git-friendly, and designed to survive session boundaries. See the full [State Reference](references/CONTRACTS.md) for detailed artifact formats and the chaining protocol.

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
[State Reference](references/CONTRACTS.md) for the full format and the five properties of a good record.

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

## Autonomous delegation

Most VINE work is human-driven — you run the phases and review every change. But a scope that's
**bounded, independent, and carries acceptance criteria** can be delegated to run **unattended**,
with a reviewer (a person, or another agent) checking the result afterward. Delegation is opt-in:
nothing about the normal human-driven flow changes unless you deliberately hand work off.

**The ticket.** Autonomous work isn't an agent impersonating a human running `vine:navigate` — it's
a **ticket** handed to the [`vine-coder`](.claude/agents/vine-coder.md) agent (the autonomous coding role).
The ticket carries everything a cold agent needs as plain instructions: which SPEC slice(s) to
implement, a pointer to SPEC.md and the feature's artifact directory, and any scope constraints.
`vine-coder` orients from the ticket, implements within scope (deriving its own touched-file
discipline), syncs the NAVIGATION.md journal per slice, runs the repo's validation contract,
commits per slice, and opens **one PR** with a handoff. Because a sub-agent can't prompt a human
mid-task, a decision a human must own is escalated in the handoff and the run stops — never guessed.

**The leash is the PR review.** The PR that comes back is the result; a human or the
[`vine-reviewer`](.claude/agents/vine-reviewer.md) agent reviews it before merge. `vine-reviewer` is the
recipe for a fresh reviewer who wasn't part of the session: how to orient (read the originating
scope, then the journal, then the commits and final files) and what to produce (a verdict,
severity-ordered findings, and a draft PR description). Its `tools` exclude Edit/Write, so "report
only" is enforced by the platform, not just asserted. Everything the reviewer needs lives in
durable state, not session memory.

**The agents.** The plugin ships the two agents the interactive phases call, auto-delegated by
description match: [`vine-verification`](plugins/vine/agents/vine-verification.md) (runs the
validation baseline and checks acceptance criteria) and
[`vine-codebase-explorer`](plugins/vine/agents/vine-codebase-explorer.md) (structured codebase
exploration). The two **autonomous-role** agents — [`vine-coder`](.claude/agents/vine-coder.md) (the
autonomous coding role above) and [`vine-reviewer`](.claude/agents/vine-reviewer.md) (the
cold-reviewer role above) — live in the repo under `.claude/agents/`, **not** in the plugin payload.
They're available to contributors and to anyone who forks VINE, but the delegation flow is opt-in and
deliberately not shipped on-by-default: until it has an intentional trigger surface and a guard
against accidental auto-delegation (agent definitions carry no `disable-model-invocation` equivalent
today), a write-capable autonomous coder shouldn't be a live delegation target in every install. The
verification and exploration agents work the same whether a human or `vine-coder` drives the work.

VINE owns the role recipes and the ticket convention; the platform owns how a role is invoked (the
sub-agent, a CI trigger) — VINE never implements an agent runner. See the
[State Reference](references/CONTRACTS.md) for the journal and handoff contracts, and the ticket
convention ("Autonomous Delegation — the vine-coder ticket") in `.vine/context/shared.md`.

## Engineer Profile

With AI assistance, engineers at every level are moving into unfamiliar domains at increasing speed. A principal exploring a new area of the codebase deserves the same depth of explanation as a junior encountering it for the first time. A junior who's built confidence in their domain deserves the same concise respect as a senior. The profile tracks domain expertise, not seniority — helping juniors to principals grow in areas both new and familiar.

VINE tracks your growth through a layered profile model:

**VINE layer** (`.vine.local/PROFILE.md`) — Tracks which domains of this codebase you're comfortable with, based on actual VINE cycles. Four levels: **confident**, **familiar**, **learning**, **new**. Commands use this to calibrate the partnership — your expertise level informs the default engagement style and how much Claude narrates, but you always choose per-slice how closely to work together.

**Claude layer** (memory + CLAUDE.md) — General preferences, interaction style, learning patterns. Suggested by `vine:evolve` after each cycle.

The profile builds organically. The first time you run `vine:verify` in a new domain, you'll be asked to rate your familiarity. As you complete cycles, `vine:evolve` proposes level updates and growth log entries. No upfront setup required.

This separation avoids duplication: VINE handles what Claude doesn't cover (per-domain expertise tracking), while Claude's native memory handles what it's already good at (general preferences and interaction patterns).

## How VINE compares

The AI-assisted development field has settled into camps. **Spec-as-artifact** frameworks treat the written spec as the unit of work; **role-persona** frameworks orchestrate the work through named agent roles; **autonomous-speed** tools optimize for the AI writing code with the human approving at the end. VINE's bet is different: the scarce resource is **human attention**, so the framework's job is routing it — deciding per scope of work how much engagement it deserves, from walking through every change to trusting a slice entirely, to delegating a bounded scope to an agent that runs unattended (with parallel execution on the [roadmap](ROADMAP.md)).

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
| **Engagement** | One mode fits all | Per-slice gearing (walk me through / free climb) + agent delegation; parallel on the [roadmap](ROADMAP.md) |
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
