# CLAUDE.md — VINE Framework

## What This Repo Is

VINE is a pure-markdown AI-assisted development framework, distributed as a native Claude Code plugin. There is no build step, no runtime code, no compilation. The product lives under `plugins/vine/`: 11 skills at `plugins/vine/skills/<name>/SKILL.md` (init, verify, inquire, navigate, evolve, pair, pause, resume, status, help, optimize), the two agents the phases invoke at `plugins/vine/agents/` (`vine-codebase-explorer`, `vine-verification`), and the journal-check hook at `plugins/vine/hooks/` — plus a state reference at `references/CONTRACTS.md` and a README. The plugin manifest is `plugins/vine/.claude-plugin/plugin.json`; the self-hosted marketplace entry is `.claude-plugin/marketplace.json` at the repo root. The two autonomous-role agents (`vine-coder`, `vine-reviewer`) are repo-resident under `.claude/agents/`, **not** in the plugin payload (see Repository Structure).

**Editing a skill file changes the tool itself.** Test changes by running the modified phase on a real repo (refresh the local plugin install to pick the edit up — see the dev loop in `.vine/context/shared.md`).

## Repository Structure

- `plugins/vine/skills/<name>/SKILL.md` — The 11 VINE phase skills (init, verify, inquire, navigate, evolve, pair, pause, resume, status, help, optimize). These ARE the product.
- `plugins/vine/agents/` — The two shipped agents the phases invoke (`vine-codebase-explorer`, `vine-verification`), auto-delegated by description matching
- `plugins/vine/hooks/` — The journal-check hook, wired via `hooks/hooks.json` (ships default-on with the plugin)
- `plugins/vine/.claude-plugin/plugin.json` — Plugin manifest; its `version` is VINE's single source of truth
- `.claude-plugin/marketplace.json` — Self-hosted marketplace entry (`source: ./plugins/vine`)
- `.claude/commands/` — Contributor tools (trellis, triage, pr, pr-review). Not part of the distributed product.
- `.claude/agents/` — The autonomous-role agents (`vine-coder`, `vine-reviewer`), repo-resident and **not** in the plugin payload. Available for contributor dogfooding (`/pr-review`) and for forks; the autonomous-delegation flow is opt-in (see the agent re-homing ADR in `.vine/knowledge/workflow/`)
- `references/CONTRACTS.md` — State artifact contracts between phases
- `ROADMAP.md` — Canonical cycle structure; the GitHub milestone is issue-level truth
- `.github/` — PR template, issue templates (bug, friction, idea)
- `.vine/context/` — Contributor context overlays (tracked)
- `.vine/projects/<domain>/<feature-slug>/` — Per-feature VINE artifacts (tracked)
- `.vine/knowledge/<domain>/` — Committed durable-decision ADR records (tracked); independent of the project lifecycle, never moved by archival
- `.vine.local/` — Gitignored personal root mirroring `.vine/`: engineer profile (`PROFILE.md`), personal overlays (`context/`), pause state, and local-only feature projects. The `.vine/ACTIVE` session sentinel stays gitignored in place.

## Skill Authoring Conventions

- YAML frontmatter on every skill: `description`, `argument-hint`, `allowed-tools`, and `disable-model-invocation: true`. There is **no `name` field** — the `/vine:<name>` colon form derives from the plugin name (`vine`) plus the skill directory name, so an explicit `name` risks double-namespacing. `disable-model-invocation: true` keeps phases user-driven (they never auto-fire from model reasoning).
- Valid tool names for `allowed-tools`: Read, Glob, Grep, Write, Edit, Bash, Agent, WebFetch, AskUserQuestion, TaskCreate, TaskUpdate, TaskList (the native task tools are used "when available" by navigate/resume for the live progress view; trellis validates the set by consensus — the union across all skills)
- Every skill (except help) starts with a "Load Context Overlays" section (reads `.vine/context/shared.md` + `.vine/context/<phase>.md`, with a legacy `.vine/hooks/` fallback through 0.4.x)
- Every skill (except init and help) follows overlays with a "Load Engineer Profile" section (reads `.vine.local/PROFILE.md`). Init creates overlays/profile rather than loading them. Help is a pure reference skill that doesn't need project context.
- Load Context Overlays must appear before Load Engineer Profile — this ordering is enforced by `/trellis`
- Skills are written in second-person instructional markdown ("Scan the project for...", "Present a summary...")
- Sections use `##` headers for major steps, `###` for substeps; anti-patterns and constraints are called out explicitly
- When adding to a skill, prefer an unnumbered `###` section over renumbering existing steps — renumbering ripples through every `step N` cross-reference (in the skill and in `references/CONTRACTS.md`), the exact drift `/trellis` Check 10 catches. An unnumbered section also signals "runs once / out of the numbered flow" (e.g. navigate's Completion Gate Check)
- `AskUserQuestion` is preferred for all decision points: max 4 questions per call, max 4 options per question, recommended option first with "(Recommended)" suffix
- Shared patterns (collaboration stance, profile protocol) live in `.vine/context/shared.md` — skills reference them with "Follow the [Protocol] from shared.md" rather than repeating the full block. This saves ~150 tokens per skill invocation. Skills still work without shared.md (graceful fallback).
- Run `/trellis` to validate skill structure and artifact format compliance before submitting changes

## State Artifact Chain

Features flow through: `CONTEXT.md` → `SPEC.md` → `NAVIGATION.md` → `EVOLUTION.md`.

All live in `.vine/projects/<domain>/<feature-slug>/`. Formats are defined in `references/CONTRACTS.md`. Section headings in CONTRACTS.md templates use `<!-- required -->` / `<!-- optional -->` HTML comment markers — new sections must include a marker to prevent validation drift.

`vine:pair` is artifact-free — it produces code changes and a single commit but no CONTEXT/SPEC/NAVIGATION/EVOLUTION files.

`vine:optimize` is also artifact-free in the VINE project sense — it doesn't produce feature artifacts. Instead it analyzes and improves skill descriptions, workflow chains, token efficiency, and interactivity patterns across all skills in the repo, maintaining the workflow map in `.vine/context/shared.md` and verifying CLAUDE.md's VINE pointer.

`vine:verify` also creates `PROJECT-MAP.md` as a progress tracker. For multi-PR features, `vine:inquire` adds a Milestones table mapping phase groups to PRs.

`vine:pause` writes an ephemeral `PAUSE.md` to the feature's mirrored path under `.vine.local/projects/`. `vine:resume` reads it (plus existing artifacts) to reconstruct session state. PAUSE.md is consumed-once: whatever picks the work back up deletes it (resume after displaying the notes, navigate, inquire, or evolve at session start), with evolve's `.resolved` write as the backstop. `vine:navigate` also maintains `.vine/ACTIVE`, a gitignored active-session sentinel that installed hooks use to scope their checks — full lifecycle in `references/CONTRACTS.md`.

## Engineer Profile

`.vine.local/PROFILE.md` tracks per-domain expertise (confident, familiar, learning, new). Commands use a one-sentence depth hint to adjust explanation depth:

> "The engineer's profile indicates they are [level] with the [domain] domain. Adjust your explanation depth accordingly — be concise where they're confident, explain the why behind decisions where they're learning or new."

If no profile exists or the domain isn't listed, commands behave exactly as they do without the feature.

## Pull Requests

PR descriptions are written for a reader with zero context — no VINE artifacts, no issue history, no memory of the session that produced the change. Make them digestible:

- **One screen, max.** If the description needs scrolling, cut it.
- **Plain language.** No internal shorthand (slice numbers, gearing, E1/E2/E3, cycle labels, "carried constraints") unless the PR is about those concepts — and then define each in a phrase.
- **What/Why in 2–4 sentences each.** State what changed and the problem it solves. Don't narrate decision trails or per-commit summaries — the commit log and diff already carry that detail.
- **Link, don't inline.** Point to issues, ROADMAP.md, or EVOLUTION.md for deep context instead of reproducing it.
- **How to test: 3 steps or fewer.**

This applies to PR bodies drafted anywhere — evolve's handoff package, the `/pr` command, or ad hoc. The general form — gloss every pointer so it reads without dereferencing — is the **Reference Legibility** rule in `references/CONTRACTS.md`, which applies to all durable VINE artifacts, not just PRs.

## VINE

This repo uses VINE. If vine commands are available in this session and `.vine/projects/`
has active features, suggest the matching phase — routing details in
`.vine/context/shared.md`. Durable design decisions are recorded as committed ADR records
under `.vine/knowledge/<domain>/` (format in `references/CONTRACTS.md`).
