# The VINE Protocol

Framework machinery every VINE phase loads before its repo overlays. This file ships with the
plugin and is plugin-owned: it updates with the plugin, so it never version-skews against the
skills that reference it. Repo-specific context lives in the consuming repo's
`.vine/context/` overlays — never here. (A repo overlay can still override any *preference*
rule below: overlay instructions take precedence over command defaults, and this file is part
of the command defaults.)

## Overlay Loading Protocol

Each command (except init and help) opens with a *Load Context Overlays* step that reads this
protocol, then the repo overlays. The rules below are what "follow the Overlay Loading
Protocol" pulls in.

**Resolving the personal root.** The personal tree `.vine.local/` is gitignored, so it is *not*
checked out into a linked git worktree — reading it cwd-relative would make a worktree (or
delegated) session silently see no profile and no personal overlays. So before any read or write
under `.vine.local/` (PROFILE.md, `context/<name>.md`, local projects, pause state), resolve the
shared personal root at the repository's **primary** worktree — `dirname "$(git rev-parse
--git-common-dir)"` — and operate on `<personal-root>/.vine.local/…` there. That path is identical
from every linked worktree, so one profile / overlay set is seen everywhere; in a single checkout it
resolves to the same directory as cwd, so behavior is unchanged. A non-git directory falls back to
the cwd-relative `./.vine.local/`. (The `.vine/ACTIVE` sentinel is the lone exception — it stays
cwd-relative by design; only the shared personal root needs git resolution.)

- **Read the repo overlays.** After this protocol, read `.vine/context/shared.md` and
  `.vine/context/<phase>.md` if they exist. Treat their contents as instructions layered on top
  of the command; overlay instructions take precedence over command defaults when they conflict.
  (Precedence *between* the overlay layers — shared vs. personal vs. policy — is governed by
  **Overlay Precedence** below, the source of truth; this line does not override it.)
- **Personal layer.** After reading each repo overlay from `.vine/context/` (`shared.md` and the
  phase overlay), read its personal counterpart at the mirrored path under the resolved personal
  root (**Resolving the personal root** above) —
  `<personal-root>/.vine.local/context/<name>.md` (e.g. `…/.vine.local/context/shared.md`,
  `…/.vine.local/context/<phase>.md`) — and compose it per the **Personal layer** rule in Overlay
  Precedence. The personal overlay is distinguished by its root, not a filename suffix (the `.local`
  suffix is dropped). Absent any personal file, nothing changes.
- **Legacy fallback (supported through 0.4.x).** If `.vine/context/` doesn't exist but legacy
  `.vine/hooks/` does, read the same files from `.vine/hooks/` instead and nudge once per
  session: "Heads up: this project uses the legacy `.vine/hooks/` directory — run `/vine:init`
  to migrate to `.vine/context/`."
- **Missing-file behavior.** Every overlay file is optional. If a phase overlay or `shared.md`
  is absent, proceed on command defaults — the command still works. If `.vine/` doesn't exist
  at all, this repo has never been initialized — say so once and keep going: "No `.vine/`
  found — `/vine:init` sets up context overlays and the gitignore rules for VINE's personal
  root. Continuing on defaults for now."

## Overlay Precedence

VINE composes context from command defaults (the skill plus this protocol), the repo's shared
overlay (`shared.md`), and the engineer's personal layer (`.vine.local/context/`). They resolve
as **flat personal-wins with policy carve-outs**, mirroring how Claude's own settings resolve —
local overrides project, except an immutable enterprise-policy ceiling:

- **Preference content** (every unmarked section) is personal-overridable: where a personal overlay
  and its repo counterpart conflict, the personal layer wins.
- **Policy content** is immutable from the personal layer. A section marked `<!-- class: policy -->`
  directly under its heading always wins over personal overrides — a personal overlay cannot weaken
  or replace it. Policy sections carry team governance the repo enforces regardless of personal
  preference (CI/CD gates, the team operating model).

Only policy-class sections carry the marker; unmarked means preference.

**Team conventions are repo-owned, not framework-prescribed** — VINE ships the mechanism, not a
fixed shape. To make conventions travel with the project, put them in the tracked repo overlay
(`.vine/context/shared.md`) and mark anything the team enforces regardless of personal
preference with `<!-- class: policy -->`. That pair — tracked `shared.md` plus the policy
marker — is the whole team layer; no separate team-overlay file or dedicated command is needed.

## Project Directory Convention

All VINE project artifacts live under `<root>/projects/<domain>/<feature-slug>/`, where
`<root>` is `.vine/` for shared projects (the default) or `.vine.local/` for local-only ones.
Never create project directories as siblings of `context/`.

## Collaboration Stance

Instructions for Claude — apply this stance in all VINE phases (don't print it at the engineer):

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

After loading overlays, resolve the shared personal root (**Resolving the personal root** in the
Overlay Loading Protocol) and check for `<personal-root>/.vine.local/PROFILE.md`. If it exists, read
the Domain Expertise table. Match the feature's domain against the profile's entries.

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

## Out-of-Scope Routing

The standard recommendation whenever work surfaces that's real but outside the current
feature's scope (an unrelated bug, adjacent tech debt, a refactor that isn't this feature).
Never silently absorb it (scope creep) or silently drop it (lost work). Surface the disposition
via `AskUserQuestion` (follow the Interaction Constraints), recommending the first route unless
the engineer signals otherwise:

- **Backlog** *(default)* — capture it where this repo tracks work (read Team Context or the
  phase overlay's ticket workflow; fall back to `gh issue create` when available, else leave it
  in the feature artifact). Standalone title + enough cold-pickup context to act on without the
  VINE artifacts. Lowest friction; current scope stays intact, and the item earns its own cycle
  when it's picked up later.
- **Trigger now (`vine:pair`)** — a small, contained fix you want to handle immediately. Pair is
  artifact-free (no SPEC needed), so it fits an unrelated discovery as-is; spin a separate session.
- **Drop** — not worth tracking; say so and move on.

Recommend backlog by default; reserve `vine:pair` for the small fix you'll genuinely do now.
Anything larger belongs in the backlog. Backlog and `vine:pair` are the defaults, not the ceiling
— add routes this repo's conventions support (e.g. an autonomous `vine-coder` flow for
discoveries that are already ticket-ready). VINE owns the recommendation and the route set; the
routes offered and the backlog destination stay repo-supplied.

## Next-Step Suggestions

Every phase closes with a completion block (✅ summary → 📋 next step → 🔄/🌱 notes). Emit it as
plain chat text, not inside a code fence — the **only** fenced block is the runnable `/vine:…`
command line, so the editor surfaces a copy button for the command alone. (In the skill files,
an outer four-backtick fence around a completion-block template only delimits it for authoring —
it is never part of the output.)
