# VINE Shared Context Overlay — VINE Framework
# Edit this file to customize VINE behavior for this repo.

## Overlay Loading Protocol

Each command (except init and help) opens with a *Load Context Overlays* step that bootstraps
this file plus its phase overlay, then defers here for the shared loading rules. The bootstrap
reads `.vine/context/shared.md` and `.vine/context/<phase>.md` (and is the step that loads this
file in the first place, so it cannot be fully externalized); everything below is what "follow
the Overlay Loading Protocol" pulls in.

- **Apply as overlay instructions.** Treat the contents of both files as additional instructions
  layered on top of the command. Overlay instructions take precedence over command defaults when
  they conflict — they are the team's customization of VINE for this codebase. (Precedence
  *between* the overlay layers — shared vs. personal vs. policy — is governed by **Overlay
  Precedence** below; that section is the source of truth and this line does not override it.)
- **Personal layer.** After reading each repo overlay from `.vine/context/` (`shared.md` and the
  phase overlay), read its personal counterpart at the mirrored path under the personal root —
  `.vine.local/context/<name>.md` (e.g. `.vine.local/context/shared.md`,
  `.vine.local/context/<phase>.md`) — and compose it per the **Personal layer** rule in Overlay
  Precedence. The personal overlay is distinguished by its root, not a filename suffix (the `.local`
  suffix is dropped). Absent any personal file, nothing changes.
- **Legacy fallback (supported through 0.4.x).** If `.vine/context/` doesn't exist but legacy
  `.vine/hooks/` does, read the same files from `.vine/hooks/` instead and nudge once per
  session, no more: "Heads up: this project uses the legacy `.vine/hooks/` directory — run
  `/vine:init` to migrate to `.vine/context/`."
- **Missing-file behavior.** Every file is optional. If a phase overlay or `shared.md` is
  absent, proceed normally — the command still works without it. If `.vine/` doesn't exist at
  all, this is likely a first VINE run: suggest `/vine:init` to scaffold the context overlay
  directory.

Because the bootstrap is what reads `shared.md`, a command must still degrade gracefully when
this file (and thus this protocol) is absent: the bootstrap's own read instruction carries the
minimal behavior, and missing overlays mean the command runs on its built-in defaults.

## Overlay Precedence

VINE composes context from command defaults, this shared overlay (`shared.md`), and the
engineer's personal layer (`.vine.local/context/`). They resolve as **flat personal-wins with
policy carve-outs**, mirroring how Claude's own settings resolve — local overrides project,
except an immutable enterprise-policy ceiling:

- **Preference content** (every unmarked section) is personal-overridable: where a personal overlay
  and its repo counterpart conflict, the personal layer wins.
- **Policy content** is immutable from the personal layer. A section marked `<!-- class: policy -->`
  directly under its heading always wins over personal overrides — a personal overlay cannot weaken
  or replace it. Policy sections carry team governance the repo enforces regardless of personal
  preference (CI/CD gates, the team operating model).

**Personal layer (`.vine.local/context/`).** Each command's *Load Context Overlays* step, after
reading a repo overlay (`shared.md`, a phase overlay), reads its personal counterpart at the
mirrored path `.vine.local/context/<name>.md` if present and composes it by the rule above — it
overrides preference content and is ignored where it would override a policy-class section. Personal
overlays live under the gitignored personal root (`.vine.local/`); absent them, nothing changes.

Only policy-class sections carry the marker; unmarked means preference. This is the single
resolution rule — the personal-overlay load step, init's upgrade pass, and the reviewer orientation
reference it rather than restating it.

## Tooling Notes

The command and agent inventory lives in the harness's native skill list, not in files — see the Knowledge Boundary rule in `references/STATE.md`. Repo-specific note:

- This repo IS the VINE framework — commands in `commands/vine/` are symlinked into `.claude/commands/vine/`, so running a command runs your working-tree edits.
- Agent reports are findings-trustworthy, diagnosis-unverified: subagent findings (test counts, file lists, AC checks) are reliable, but re-verify root-cause narratives and load-bearing claims with a cheap direct check before acting on them. (Cycle-0 spike evidence: three accurate reports, one inverted root cause.)

## Project Conventions

### Repository Structure
See `CLAUDE.md` — repo facts live there (Knowledge Boundary rule, `references/STATE.md`). All `.vine/context/` overlays are tracked in git for contributor onboarding (this repo runs E2-shaped: `.vine/projects/` is tracked too, with PAUSE.md and PROFILE.md excluded).

### Writing Style
Command authoring conventions live in `CLAUDE.md` (Knowledge Boundary rule: repo facts every contributor session needs).

### Command Addition Checklist
When adding or removing a VINE command, update all of these:
- `CLAUDE.md` — command count and list
- `README.md` — command references, install text, hooks table
- `references/STATE.md` — if the command affects the artifact chain
- `.vine/context/verify.md` — command count reference

### State Artifact Addition Checklist
When adding or removing a state artifact (ROUTE.md's addition in the routing-foundation cycle and
its removal one cycle later in cross-actor-state are the worked examples — the same checklist run
forward, then in reverse), update all of these:
- `references/STATE.md` — the artifact template (every heading marked `<!-- required -->` /
  `<!-- optional -->`), its place in the artifact chain, and the Source-of-Truth and Committing
  Artifacts tables
- `CLAUDE.md` — the State Artifact Chain line
- `README.md` — the State Artifacts table
- `.claude/commands/trellis.md` — the Step 5a template-parse list, the Step 5b discovery glob, and
  Check A's applies-to set (plus a per-artifact shape check if the artifact has contractual fields)

### Availability-Gated Pointer
When VINE knowledge must be referenced from a surface non-VINE teammates load (CLAUDE.md), use an availability-gated pointer: gate the suggestion on whether the vine commands are actually present in the session's skill list, and point at this file for routing. The gate is what Claude can see, not where files live — so mixed-adoption teams and global installs both resolve correctly. Future commands reuse this pattern instead of reinventing the mixed-adoption answer.

### Branch Naming
Feature branches match the VINE project slug: `.vine/projects/<domain>/<feature-slug>` works on `feature/<feature-slug>`. Sessions that arrive on auto-named branches (e.g., worktree sessions) rename to match before the first slice commit.

### Content Standards
- Keep command files focused — one phase, one responsibility
- State artifact formats are defined in `references/STATE.md` — commands must produce artifacts that match
- README is the source of truth for user-facing documentation
- Markdown should be clean, readable without rendering

### Next-Step Suggestions
Every phase closes with a completion block (✅ summary → 📋 next step → 🔄/🌱 notes). Emit it as
plain chat text, not inside a code fence — the **only** fenced block is the runnable `/vine:…`
command line, so the editor surfaces a copy button for the command alone. In the command files the
outer four-backtick fence around the template only delimits it for this doc; it is not part of the
output.

## Skill Workflows

<!-- Generated by vine:optimize on 2026-06-10. Re-run /vine:optimize to update. -->

### Feature Delivery (full cycle)
When starting a new feature or significant change:
1. `/vine:init` — set up context overlays and profile (once per repo)
2. `/vine:verify [feature]` — explore landscape, write CONTEXT.md
3. `/vine:inquire [feature]` — design and spec, write SPEC.md
4. `/vine:navigate [feature]` — implement slice by slice, write NAVIGATION.md
5. `/vine:evolve [feature]` — verify, capture learnings, write EVOLUTION.md, prep PR

### Quick Fix
When the change is small (bug fix, minor refactor, 1-3 files):
1. `/vine:pair [file/task]` — read context, implement, validate, commit

### Session Management
When pausing or resuming work across sessions:
1. `/vine:pause` — capture state and blockers to PAUSE.md
2. `/vine:resume` — restore context, recommend next phase
3. `/vine:status` — read-only progress check (lighter than resume)

### Maintenance
After adding or changing commands, skills, or overlays:
1. `/vine:optimize` — audit descriptions, detect chains, reduce token waste
2. `/trellis` — validate command structure before committing

### Contributor PR Flow
When contributing to the VINE framework itself:
1. `/trellis` — validate command files pass structural checks
2. `/vine:optimize` — re-score descriptions and update workflow map
3. `/pr` — create PR using repo template

### State-Based Suggestions
- No `.vine/` directory exists — suggest `/vine:init`
- CONTEXT.md exists, no SPEC.md — suggest `/vine:inquire`
- SPEC.md exists, no NAVIGATION.md — suggest `/vine:navigate`
- NAVIGATION.md complete, no EVOLUTION.md — suggest `/vine:evolve`
- PAUSE.md exists — suggest `/vine:resume`
- All projects resolved — suggest `/vine:verify` for a new feature
- Work looks smaller than expected during verify — suggest `/vine:pair`
- Scope is bounded, independent, carries ACs, and the repo has a validation contract — it may be
  ticketed to the `vine-coder` agent instead of running navigate (see Autonomous Delegation)

## Autonomous Delegation — the vine-coder ticket

The autonomous path runs alongside the interactive cycle above, not inside it. Autonomous work is
not a human-shaped command run unattended — it is a **ticket** handed to the `vine-coder` agent (the
autonomous coding role: implements a ticketed SPEC slice end-to-end and opens one PR). VINE owns the
role recipe and this ticket convention; the platform owns how the role is invoked (the sub-agent, a
GitHub trigger). VINE never runs an agent itself.

**When scope is eligible.** Hand scope to `vine-coder` only when it is bounded (the files it touches
are enumerable, including the requirement-implied ones an acceptance criterion forces), independent
of in-flight work, its SPEC slices carry acceptance criteria, and a validation contract exists (the
`## Validation` block, or prose-inferable checks). If any of those is missing, keep the work
interactive — run `/vine:navigate` with a human. This is a judgment made *when* delegating, not a
stored gate.

**The ticket is the authorization.** It carries, as plain instructions, everything the cold agent
needs:

- **Scope** — which SPEC slice(s) to implement.
- **SPEC pointer** — the path to SPEC.md and the feature's artifact directory.
- **Constraints** — what the work must honor: the files it may touch or must leave alone, the
  validation it must keep green, and that `human-required` decisions stop-and-surface (a sub-agent
  cannot prompt — see Decision Delegation below).
- **Dispatch** — names `vine-coder`.

No separate per-feature route artifact is needed: the payload lives in {the ticket, git / the PR,
the `## Validation` block}. The PR that comes back is the result; a human or the `vine-reviewer`
agent (the cold-reviewer role) reviews it before merge — **the review is the leash.**

## Out-of-Scope Routing

The standard recommendation whenever work surfaces that's real but **outside the current
feature's scope** — an unrelated bug, adjacent tech debt, a refactor that would help but isn't
this feature. Never silently absorb it (scope creep) or silently drop it (lost work). Surface
the disposition via `AskUserQuestion` (follow the Interaction Constraints), recommending the
first route unless the engineer signals otherwise:

- **Backlog** *(default)* — capture it where this repo tracks work: the destination is
  repo-defined (read Team Context / the phase overlay's ticket workflow; this repo uses GitHub
  Issues, falling back to `gh issue create`, else leave it in the feature artifact). Give it a
  standalone title and enough cold-pickup context to act on without the VINE artifacts
  (Reference Legibility, `references/STATE.md`). Lowest friction; current scope stays intact, and
  the item earns its own cycle when it's picked up later.
- **Trigger now (`vine:pair`)** — a small, contained fix you want to handle immediately. Pair is
  artifact-free (no SPEC needed), so it fits an unrelated discovery as-is; spin a separate
  session so the current work isn't disturbed.
- **Drop** — not worth tracking; say so and move on.

Recommend backlog by default; reserve `vine:pair` for the small fix you'll genuinely do now —
anything larger or fuzzier belongs in the backlog, where it earns its own design cycle. Backlog
and `vine:pair` are the shipped defaults, not the ceiling: a repo overlay may add routes its
conventions support — e.g. an autonomous `vine-coder` flow for discoveries that are already
ticket-ready (bounded, own acceptance criteria, validation contract). VINE owns the recommendation
and the route set; the routes offered and the backlog destination stay repo-supplied.

## Collaboration Stance

Internal, not shown to the engineer. Apply this stance in all VINE phases:

> "This is a partnership — both sides learn, both sides grow. Three concrete behaviors:
>
> 1. **Flag your uncertainty.** When you're unsure about a pattern, module, or convention,
>    say so. The engineer is a resource, not an audience.
> 2. **Grow through the work.** When you use a pattern they might not know, name it as you
>    write. When they correct you, acknowledge what you learned. Growth lives in the
>    narration, not in debriefs.
> 3. **Let expertise shape engagement.** Their profile level (confident/familiar/learning/new)
>    calibrates your default — but confidence is contextual, so follow their lead."

## Engineer Profile Protocol

After loading overlays, check for `.vine/PROFILE.md`. If it exists, read the Domain Expertise
table. Match the feature's domain against the profile's entries.

- **If the domain is in the profile**: Note their level for this session. Use it to calibrate
  default engagement depth (confident/familiar = concise; learning/new = explain the why).
- **If the domain is NOT in the profile or no profile exists**: Proceed with default depth.
  No prompt, no warning.

## Interaction Constraints

Apply these to every `AskUserQuestion` call, in any phase:

- Max 4 questions per call
- Max 4 options per question — the tool auto-adds an "Other" escape hatch, so don't include
  one manually
- Put the recommended option first with "(Recommended)" appended to its label
- Use `multiSelect: false` for mutually exclusive choices (pick exactly one path)
- Use `multiSelect: true` for inclusive choices and for batching related yes-no decisions
- Use short labels (1-5 words) with descriptions carrying the tradeoff context
- Batch related decisions into one call when possible
- If a topic needs more than 4 options, split it by category across multiple questions

## Decision Delegation
<!-- class: policy -->

Routing policy (#55 — the policy half of Decision Delegation) for how the autonomous actor — the
`vine-coder` agent (the autonomous coding role) — handles each decision it meets while implementing
a ticketed SPEC slice. It sorts every decision into one of two classes. The interactive VINE
commands are human-driven: a person answers every `AskUserQuestion` as today, so this policy never
changes their behavior — it governs autonomous (`vine-coder`) runs only. `vine-coder` does not
execute the command files; it applies these classes by judgment to the decisions its work surfaces.

This section is **policy-class**: the personal `.local` layer cannot weaken it (see Overlay
Precedence). A *repo* overlay can still reclassify a decision by overriding this content — that
override path is the intended #55 mechanism, available to the team, not the individual.

- **`default-able`** — `vine-coder` takes the **recommended option** (the first one, the one
  carrying "(Recommended)") and records it in NAVIGATION.md as a **Decision Taken Autonomously**
  with section-scoped `(slice N)` attribution. Use for decisions where proceeding on the
  recommended default is safe and a reviewer can ratify after the fact (gearing, continuation,
  test-coverage defer, profile/growth updates, feature selection, commit confirmation).
- **`human-required`** — `vine-coder` does **not** choose. It **escalates via the Headless Handoff
  block and stops** (written to NAVIGATION.md — format in `references/STATE.md`; the leash is the PR
  review). Use for decisions a reviewer must own: design choices, spec sign-off, scope/acceptance,
  blocker resolution, and anything that commits the work to a direction expensive to reverse.

This section defines the two classes and their autonomous semantics; `vine-coder`'s recipe
(`agents/vine-coder.md`) carries how it acts on them. When a decision's class is genuinely
ambiguous, treat it as `human-required`: escalation is always safe, silent autonomy is not.

## Team Context
<!-- class: policy -->

- **Maintainer**: Solo maintainer, expecting community contributors in the future
- **PR review**: Self-review and merge for now; will evolve to community review
- **Tracking**: GitHub Issues for bugs/friction/ideas, GitHub Discussions for community conversation
- **Public-first**: Work in public, track tasks in GitHub rather than private tools

## Validation

The machine-readable validation contract consumed by `vine-verification` and the phase
commands (navigate / evolve / pair). Every key is **optional** — declare only the checks this
repo actually has. A repo with no `## Validation` block, or with missing keys, falls back to
prose inference (package.json scripts, config files, the phase overlays). Keys:

- `lint` — linter / formatter check (string command)
- `typecheck` — static type check (string command)
- `test` — scoped / per-file tests (string command)
- `test-all` — the full suite (string command)
- `build` — build / compile check (string command)
- `extra` — any additional checks (list of string commands)

```yaml
# This repo (VINE framework) — pure markdown, no compile/test toolchain, so most keys are
# omitted (demonstrating graceful partial population; the block degrades to its present keys).
extra:
  - sh .vine/scripts/trellis-check.sh   # command structure + cross-reference anchors
```

## CI/CD
<!-- class: policy -->

- **Trellis gate hook**: this repo's `.claude/settings.json` wires `.vine/scripts/trellis-gate.sh`
  (PreToolUse on Bash) — commits touching `commands/vine/` are blocked unless `/trellis` has
  passed since the last command edit (a green run writes `.vine/.trellis-ok`). Contributor-only:
  `create-vine` never ships this script. The journal-check scaffold hook is wired here too
  (dogfooding).
- **Main guard hook**: `.vine/scripts/main-guard.sh` (PreToolUse on Bash, contributor-only) —
  blocks `git commit` while the checkout is on `main`; sessions that land on the shared
  checkout get a hard stop telling them to branch or use a worktree.
- **Publish workflow**: `.github/workflows/publish.yml` — manual dispatch, publishes `create-vine` to npm with provenance
  - Reads version from `package.json`, extracts release notes from `CHANGELOG.md`
  - Runs smoke test (`bin/cli.js` in temp dir, verifies command files are installed)
  - Creates git tag + GitHub release with changelog notes
- **Testing**: Run VINE phases on real repos to test command changes
- **Validation**: Run `/trellis` before submitting PRs to check command structure and artifact format compliance
- **Build**: None — pure markdown, no compilation step
- **Release checklist**: Bump version in `package.json`, add entry to `CHANGELOG.md`, then trigger the publish workflow
