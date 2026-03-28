```typescript
   |
 //|\\  __   __  ___   _  _   ___
| /|\ | \ \ / / |_ _| | \| | | __|
 \/|\/   \ V /   | |  | .` | | _|
  \|/     \_/   |___| |_|\_| |___|
Verify · Inquire · Navigate · Evolve
```

# VINE

**Grow features on solid roots.**

VINE is a command chain for AI-assisted feature development in established codebases. It keeps the human connected, learning, and steering throughout — not watching from the sidelines while an AI codes autonomously.

> **Early adopter alert.** VINE is in active development. The commands work and we use them daily, but expect rough edges. See [CONTRIBUTING.md](CONTRIBUTING.md) for how to get involved, or open a [Discussion](../../discussions) if something breaks or feels off.

## Philosophy

Most AI coding frameworks optimize for speed. VINE optimizes for **three things growing together**:

1. **The product** — features built on solid understanding, not guesswork
2. **The agent** — Claude gets smarter about your codebase with every cycle
3. **The user** — the engineer learns patterns and deepens expertise alongside the AI

VINE is for engineers who want to stay engaged with their code, not delegate it away. The AI accelerates your work; it doesn't replace your judgment.

## The Four Phases

```
vine:verify  →  vine:inquire  →  vine:navigate  →  vine:evolve
   📡              📐               🧭                🌱
 Explore         Design           Build            Grow
```

### vine:verify — Context Building Spike

Research the codebase together. The engineer brings tribal knowledge, edge cases, and "the weird stuff." Claude reads broadly and asks questions. Together you produce a CONTEXT.md that captures the real landscape — not just what the code says, but what the docs don't.

**Output:** `.vine/projects/<domain>/<feature-slug>/CONTEXT.md`

### vine:inquire — Feature Specification

Design the feature on top of verified context. Discuss architecture, weigh tradeoffs (always 2-3 options), and get explicit human approval on every decision. Layer the spec on the foundation you built in verify.

**Output:** `.vine/projects/<domain>/<feature-slug>/SPEC.md`

### vine:navigate — Guided Implementation

Build the feature together. The engineer steers direction, Claude executes and explains. Both learn. No auto-commits — changes are surfaced for review. Every decision is documented.

**Output:** `.vine/projects/<domain>/<feature-slug>/NAVIGATION.md` + staged changes (not committed)

### vine:evolve — Triple Evolution

Verify against acceptance criteria, then drive three evolutions. Product quality (verification, PR prep). Agent capability (CLAUDE.md updates, new commands). User growth (knowledge gained, areas to explore).

**Output:** `.vine/projects/<domain>/<feature-slug>/EVOLUTION.md` + handoff package

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

## Key Principles

**Approve-edits mode.** VINE is a cooperative framework. Run with approve-edits enabled so the engineer reviews every change as it happens. Auto-accept defeats the purpose.

**Human decides, always.** Every design choice, tradeoff, and priority call is made by the engineer. Claude presents options, the human chooses.

**Commit per slice.** Each validated slice gets committed with its acceptance criteria. The engineer reviews every change via approve-edits before the commit happens — structured progress, not autonomous committing.

**Document as you go.** Each phase produces artifacts that persist across sessions, handoffs, and team members. Nothing lives only in a chat transcript.

**Chain, don't rush.** Each phase suggests the next step but doesn't auto-trigger. The engineer decides when to move forward. Each phase completion suggests a fresh session for the next phase — state flows through `.vine/` files, not chat context.

**Evolve everything.** Every feature is an opportunity to improve the product, make the agent smarter, and help the engineer grow. The retro block at the end of each phase captures all three.

## Installation

### Global (user-level)

Copy the commands directory into your user-level Claude config:

```bash
cp -r commands/vine ~/.claude/commands/vine
```

This makes all VINE commands (`/vine:verify`, `/vine:inquire`, `/vine:navigate`, `/vine:evolve`, `/vine:pair`) available in every project.

### Project-level

Copy the commands directory into your project's `.claude/commands/` directory:

```bash
cp -r commands/vine .claude/commands/vine
```

Or clone the repo and symlink.

### Piloting in an existing project (e.g., at work)

VINE creates a `.vine/` directory for feature artifacts and hooks. If you're trying VINE in a repo you don't want to modify tracked files in, add `.vine/` to your global gitignore so it stays local:

```bash
# Create a global gitignore if you don't have one
git config --global core.excludesFile ~/.gitignore_global

# Add .vine/ to it
echo '.vine/' >> ~/.gitignore_global
```

This keeps your `.vine/` artifacts out of version control across all repos. When your team is ready to adopt VINE together, you can remove it from the global gitignore and commit `.vine/hooks/` to the repo instead.

## Usage

### First time in a repo

Run `/vine:init` to scaffold project hooks. This discovers your repo's tools, agents, CI, and
conventions, then generates `.vine/hooks/` with pre-filled templates:

```
> /vine:init
```

### Start a feature

```
> /vine:verify I need to add webhook support to the payments service
```

At the end of each phase, you'll see a suggested next step. Run it when you're ready.

## Project Hooks

VINE commands load project-specific extensions from `.vine/hooks/` before each phase starts.
This is how you customize VINE for your codebase — wire in your repo's agents, tools, test
commands, and conventions without forking the commands themselves.

```
.vine/
├── PROFILE.md                     # Engineer profile (per-repo, built over time)
├── hooks/
│   ├── shared.md                  # Loaded by ALL phases
│   ├── verify.md                  # verify-specific extensions
│   ├── inquire.md                 # inquire-specific extensions
│   ├── navigate.md                # navigate-specific extensions
│   ├── evolve.md                  # evolve-specific extensions
│   └── pair.md                    # pair-specific extensions
└── projects/
    ├── payments/
    │   ├── webhook-support/       # Feature 1 (complete)
    │   │   ├── CONTEXT.md
    │   │   ├── SPEC.md
    │   │   ├── NAVIGATION.md
    │   │   └── EVOLUTION.md
    │   └── retry-logic/           # Feature 2 (in progress)
    │       ├── CONTEXT.md
    │       └── SPEC.md
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

### Per-phase hooks

Only created when there's something phase-specific to add:

| File          | Example content                                                               |
| ------------- | ----------------------------------------------------------------------------- |
| `verify.md`   | Key areas to always explore, domain-specific questions                        |
| `inquire.md`  | Preferred architecture patterns, design review checklists                     |
| `navigate.md` | Agents to run after code changes, test commands per domain                    |
| `evolve.md`   | PR creation workflow, CI validation, issue tracker integration                |
| `pair.md`     | Test commands, lint/format requirements, commit conventions for small changes |

### How hooks load

Each VINE command checks for `.vine/hooks/shared.md` and `.vine/hooks/<phase>.md` before
starting. If found, the contents are applied as additional instructions on top of the base
command. Hook instructions take precedence when they conflict with defaults.

As you complete VINE cycles, `/vine:evolve` suggests updates to your hook files based on
what you learn — tools that proved useful, patterns that should be default, agents that
should auto-run.

## State Artifacts

| File            | Phase      | Purpose                                               |
| --------------- | ---------- | ----------------------------------------------------- |
| `CONTEXT.md`    | verify     | Codebase landscape, tribal knowledge, tech debt       |
| `SPEC.md`       | inquire    | Feature design, acceptance criteria, work slices      |
| `NAVIGATION.md` | navigate   | Implementation journal, commit-per-slice log          |
| `EVOLUTION.md`  | evolve     | Verification results, triple evolution report         |
| `PROFILE.md`    | all phases | Engineer's domain expertise and growth log (per-repo) |

These files are human-readable, git-friendly, and designed to survive session boundaries. See the full [State Reference](references/STATE.md) for detailed artifact formats and the chaining protocol.

## Engineer Profile

With AI assistance, engineers at every level are moving into unfamiliar domains at increasing speed. A principal exploring a new area of the codebase deserves the same depth of explanation as a junior encountering it for the first time. A junior who's built confidence in their domain deserves the same concise respect as a senior. The profile tracks domain expertise, not seniority — helping juniors to principals grow in areas both new and familiar.

VINE tracks your growth through a layered profile model:

**VINE layer** (`.vine/PROFILE.md`) — Tracks which domains of this codebase you're comfortable with, based on actual VINE cycles. Four levels: **confident**, **familiar**, **learning**, **new**. Commands use this to meet you where you are — more context and explanation in unfamiliar areas, more concise and focused where you're confident.

**Claude layer** (memory + CLAUDE.md) — General preferences, interaction style, learning patterns. Suggested by `vine:evolve` after each cycle.

The profile builds organically. The first time you run `vine:verify` in a new domain, you'll be asked to rate your familiarity. As you complete cycles, `vine:evolve` proposes level updates and growth log entries. No upfront setup required.

This separation avoids duplication: VINE handles what Claude doesn't cover (per-domain expertise tracking), while Claude's native memory handles what it's already good at (general preferences and interaction patterns).

## How VINE compares

Most AI coding frameworks optimize for autonomous speed — the AI writes code, the human approves. VINE takes a different approach:

|                    | Autonomous frameworks       | VINE                            |
| ------------------ | --------------------------- | ------------------------------- |
| **Optimizes for**  | Speed                       | Growth (product + agent + user) |
| **Human role**     | Approves at the end         | Steers throughout               |
| **Commits**        | Auto                        | Engineer commits per slice      |
| **Best for**       | Greenfield / scripted tasks | Established codebases           |
| **Learning model** | One-way (AI executes)       | Two-way (both learn)            |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines. The short version: open an issue or [Discussion](../../discussions) before submitting a PR.

## License

MIT

---

_Built by [ModuloMoments](https://github.com/modulomoments)_
