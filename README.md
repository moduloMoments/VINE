# VINE — Verify, Inquire, Navigate, Evolve

**Grow features on solid roots.**

VINE is a command chain for AI-assisted feature development in established codebases. It keeps the human connected, learning, and steering throughout — not watching from the sidelines while an AI codes autonomously.

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

**Output:** `.vine/<domain>/<feature-slug>/CONTEXT.md`

### vine:inquire — Feature Specification
Design the feature on top of verified context. Discuss architecture, weigh tradeoffs (always 2-3 options), and get explicit human approval on every decision. Layer the spec on the foundation you built in verify.

**Output:** `.vine/<domain>/<feature-slug>/SPEC.md`

### vine:navigate — Guided Implementation
Build the feature together. The engineer steers direction, Claude executes and explains. Both learn. No auto-commits — changes are surfaced for review. Every decision is documented.

**Output:** `.vine/<domain>/<feature-slug>/NAVIGATION.md` + staged changes (not committed)

### vine:evolve — Triple Evolution
Verify against acceptance criteria, then drive three evolutions. Product quality (verification, PR prep). Agent capability (CLAUDE.md updates, new skills). User growth (knowledge gained, areas to explore).

**Output:** `.vine/<domain>/<feature-slug>/EVOLUTION.md` + handoff package

## Key Principles

**Approve-edits mode.** VINE is a cooperative framework. Run with approve-edits enabled so the engineer reviews every change as it happens. Auto-accept defeats the purpose.

**Human decides, always.** Every design choice, tradeoff, and priority call is made by the engineer. Claude presents options, the human chooses.

**No auto-commits.** VINE never touches git. Changes are presented for review. The engineer commits when ready.

**Document as you go.** Each phase produces artifacts that persist across sessions, handoffs, and team members. Nothing lives only in a chat transcript.

**Chain, don't rush.** Each phase suggests the next step but doesn't auto-trigger. The engineer decides when to move forward. Each phase completion suggests a fresh session for the next phase — state flows through `.vine/` files, not chat context.

**Evolve everything.** Every feature is an opportunity to improve the product, make the agent smarter, and help the engineer grow. The retro block at the end of each phase captures all three.

## Installation

### Global (user-level)

Copy the commands directory into your user-level Claude config:

```bash
cp -r commands/vine ~/.claude/commands/vine
```

This makes `/vine:verify`, `/vine:inquire`, `/vine:navigate`, and `/vine:evolve` available in every project.

### Project-level

Copy the commands directory into your project's `.claude/commands/` directory:

```bash
cp -r commands/vine .claude/commands/vine
```

Or clone the repo and symlink.

## Usage

Start with verify and let the chain guide you:

```
> /vine:verify I need to add webhook support to the payments service
```

At the end of each phase, you'll see a suggested next step. Run it when you're ready.

## State Artifacts

VINE uses a `.vine/<domain>/<feature-slug>/` directory in your project root to store state. The domain groups features by the logical area they touch, and the feature slug identifies the specific work. Multiple features can be VINEd concurrently without collision — even in the same domain.

```
.vine/
├── payments/
│   ├── webhook-support/          # Feature 1 (complete)
│   │   ├── CONTEXT.md
│   │   ├── SPEC.md
│   │   ├── NAVIGATION.md
│   │   └── EVOLUTION.md
│   └── retry-logic/              # Feature 2 (in progress)
│       ├── CONTEXT.md
│       └── SPEC.md
└── auth/
    └── sso-migration/            # Feature 3 (in progress)
        └── CONTEXT.md
```

| File | Phase | Purpose |
|------|-------|---------|
| `CONTEXT.md` | verify | Codebase landscape, tribal knowledge, tech debt |
| `SPEC.md` | inquire | Feature design, acceptance criteria, work slices |
| `NAVIGATION.md` | navigate | Implementation journal, decisions, learnings |
| `EVOLUTION.md` | evolve | Verification results, triple evolution report |

These files are human-readable, git-friendly, and designed to survive session boundaries.

## Comparison

| | GSD | PAUL | VINE |
|---|---|---|---|
| **Optimizes for** | Speed | Quality | Growth (product + agent + user) |
| **Human role** | Approves | Reviews | Steers throughout |
| **Commits** | Auto | Auto | Manual (engineer commits) |
| **Best for** | Greenfield | Quality-critical | Established codebases |
| **Learning model** | One-way (AI executes) | One-way (AI executes + verifies) | Two-way (both learn) |

## License

MIT

---

*Built by [ModuloMoments](https://github.com/modulomoments)*
