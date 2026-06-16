# CLAUDE.md — VINE Framework

## What This Repo Is

VINE is a pure-markdown AI-assisted development framework. There is no build step, no runtime code, no compilation. The product is 11 command files in `commands/vine/` (init, verify, inquire, navigate, evolve, pair, pause, resume, status, help, optimize), a state reference at `references/STATE.md`, and a README.

**Editing a command file changes the tool itself.** Test changes by running the modified command on a real repo.

## Repository Structure

- `commands/vine/` — The 11 VINE command files (init, verify, inquire, navigate, evolve, pair, pause, resume, status, help, optimize). These ARE the product.
- `.claude/commands/` — Contributor tools (trellis, triage, pr). Not part of the distributed product.
- `agents/` — Shipped agent definitions, auto-delegated by description matching
- `references/STATE.md` — State artifact contracts between phases
- `ROADMAP.md` — Canonical cycle structure; the GitHub milestone is issue-level truth
- `.github/` — PR template, issue templates (bug, friction, idea)
- `.vine/context/` — Contributor context overlays (tracked)
- `.vine/projects/<domain>/<feature-slug>/` — Per-feature VINE artifacts (tracked; PAUSE.md gitignored)
- `.vine/PROFILE.md` — Engineer profile (gitignored)

## Command Authoring Conventions

- YAML frontmatter on every command: `name`, `description`, `argument-hint`, `allowed-tools`
- Valid tool names for `allowed-tools`: Read, Glob, Grep, Write, Edit, Bash, Agent, WebFetch, AskUserQuestion, TaskCreate, TaskUpdate, TaskList (the native task tools are used "when available" by navigate/resume for the live progress view; trellis validates the set by consensus — the union across all commands)
- Every command (except help) starts with a "Load Context Overlays" section (reads `.vine/context/shared.md` + `.vine/context/<phase>.md`, with a legacy `.vine/hooks/` fallback through 0.4.x)
- Every command (except init and help) follows overlays with a "Load Engineer Profile" section (reads `.vine/PROFILE.md`). Init creates overlays/profile rather than loading them. Help is a pure reference command that doesn't need project context.
- Load Context Overlays must appear before Load Engineer Profile — this ordering is enforced by `/trellis`
- Commands are written in second-person instructional markdown ("Scan the project for...", "Present a summary...")
- Sections use `##` headers for major steps, `###` for substeps; anti-patterns and constraints are called out explicitly
- `AskUserQuestion` is preferred for all decision points: max 4 questions per call, max 4 options per question, recommended option first with "(Recommended)" suffix
- Shared patterns (collaboration stance, profile protocol) live in `.vine/context/shared.md` — commands reference them with "Follow the [Protocol] from shared.md" rather than repeating the full block. This saves ~150 tokens per command invocation. Commands still work without shared.md (graceful fallback).
- Run `/trellis` to validate command structure and artifact format compliance before submitting changes

## State Artifact Chain

Features flow through: `CONTEXT.md` → `SPEC.md` → `NAVIGATION.md` → `EVOLUTION.md`. A
`ROUTE.md` (the routing gate record — verdict, allowlist, constraints, validation baseline)
optionally joins the chain between `SPEC.md` and `NAVIGATION.md`: `vine:navigate` writes it at
head when a scope is headless-eligible, and an interactive run omits it (graceful absence).

All live in `.vine/projects/<domain>/<feature-slug>/`. Formats are defined in `references/STATE.md`. Section headings in STATE.md templates use `<!-- required -->` / `<!-- optional -->` HTML comment markers — new sections must include a marker to prevent validation drift.

`vine:pair` is artifact-free — it produces code changes and a single commit but no CONTEXT/SPEC/NAVIGATION/EVOLUTION files.

`vine:optimize` is also artifact-free in the VINE project sense — it doesn't produce feature artifacts. Instead it analyzes and improves skill descriptions, workflow chains, token efficiency, and interactivity patterns across all commands and skills in the repo, maintaining the workflow map in `.vine/context/shared.md` and verifying CLAUDE.md's VINE pointer.

`vine:verify` also creates `PROJECT-MAP.md` as a progress tracker. For multi-PR features, `vine:inquire` adds a Milestones table mapping phase groups to PRs.

`vine:pause` writes an ephemeral `PAUSE.md` to the feature directory. `vine:resume` reads it (plus existing artifacts) to reconstruct session state. PAUSE.md is consumed-once: whatever picks the work back up deletes it (resume after displaying the notes, navigate, inquire, or evolve at session start), with evolve's `.resolved` write as the backstop. `vine:navigate` also maintains `.vine/ACTIVE`, a gitignored active-session sentinel that installed hooks use to scope their checks — full lifecycle in `references/STATE.md`.

## Engineer Profile

`.vine/PROFILE.md` tracks per-domain expertise (confident, familiar, learning, new). Commands use a one-sentence depth hint to adjust explanation depth:

> "The engineer's profile indicates they are [level] with the [domain] domain. Adjust your explanation depth accordingly — be concise where they're confident, explain the why behind decisions where they're learning or new."

If no profile exists or the domain isn't listed, commands behave exactly as they do without the feature.

## Pull Requests

PR descriptions are written for a reader with zero context — no VINE artifacts, no issue history, no memory of the session that produced the change. Make them digestible:

- **One screen, max.** If the description needs scrolling, cut it.
- **Plain language.** No internal shorthand (slice numbers, gearing, E1/E2/E3, cycle labels, "carried constraints") unless the PR is about those concepts — and then define each in a phrase.
- **What/Why in 2–4 sentences each.** State what changed and the problem it solves. Don't narrate decision trails or per-commit summaries — the commit log and diff already carry that detail.
- **Link, don't inline.** Point to issues, ROADMAP.md, or EVOLUTION.md for deep context instead of reproducing it.
- **How to test: 3 steps or fewer.**

This applies to PR bodies drafted anywhere — evolve's handoff package, the `/pr` command, or ad hoc. The general form — gloss every pointer so it reads without dereferencing — is the **Reference Legibility** rule in `references/STATE.md`, which applies to all durable VINE artifacts, not just PRs.

## VINE

This repo uses VINE. If vine commands are available in this session and `.vine/projects/`
has active features, suggest the matching phase — routing details in
`.vine/context/shared.md`.
