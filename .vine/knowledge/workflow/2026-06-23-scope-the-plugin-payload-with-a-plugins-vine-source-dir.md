# Scope the published plugin payload with a plugins/vine/ source dir — there is no file-level exclusion

## Status

Accepted — 2026-06-23
Source: workflow/plugin-packaging · Actor: Rob + Claude
Supersedes: none

## Context

The first manifest put the plugin at the repo root with marketplace `source: "./"`. That ships the
*entire repo* into the plugin cache — contributor tooling, `.vine/` (overlays, projects, knowledge),
`references/`, `package.json`, ROADMAP, and (for a local directory source) even gitignored personal
state like `.vine/ACTIVE` and `settings.local.json`. The Slice-1 discovered item proposed slimming
the payload with a `.claudeignore`-style allowlist.

Research against the official plugins/marketplaces docs settled the mechanism question: Claude Code
copies the `source` directory wholesale (minus `.git`) and has **no file-level payload exclusion** —
no `.claudeignore`, no `files`/`exclude` manifest field. The *only* control over what ships is which
directory `source` points at.

## Decision

Move the entire product into a **`plugins/vine/`** subdirectory — `.claude-plugin/plugin.json`,
`skills/`, `agents/`, `hooks/` — and set marketplace `source: "./plugins/vine"`. This does two
things at once: it adopts the **documented `plugins/<name>/` convention**, and it scopes the
published payload to product-only, since a scoped source dir is the sole available payload control.
The root keeps only the marketplace entry (`.claude-plugin/marketplace.json`) and contributor
material outside the source dir.

This **supersedes the Slice-1 `.claudeignore` backlog idea**: payload slimming is not achievable via
an ignore file (none is supported); the subdir restructure is the mechanism, and it resolves the
whole-repo-payload concern.

## Consequences

- Verified: the installed snapshot contains only the product — `.claude-plugin/ + skills(11) +
  agents(2) + hooks(2)` — `.vine/`, `commands/`, `bin/`, `references/`, `package.json`, the
  contributor-only hooks (`trellis-gate.sh`, `main-guard.sh`), and the repo-resident autonomous-role
  agents under `.claude/agents/` are all absent. AC5 ("contributor hooks not shipped") is met in
  *letter*, not merely intent — they aren't in the payload at all. (The scoped `source` dir is also
  what keeps `.claude/agents/` out — see
  `2026-06-23-hold-autonomous-role-agents-out-of-the-shipped-payload`.)
- A *local directory* source copies gitignored working files into the cache (a local-dev-only leak),
  but a *github* source (production) clones, so only committed files ship — the leak never reaches
  users.
- Trellis, the trellis-gate, the journal-check hook home, and every internal doc were retargeted to
  `plugins/vine/skills/<name>/SKILL.md` / `plugins/vine/hooks/` / `plugins/vine/agents/`.
- This is an independent structural call, not a restatement of the plugin-only decision
  (`2026-06-23-vine-ships-as-a-plugin-and-drops-npx`): *that* record decides VINE is a plugin;
  *this* one decides where in the repo it lives and why payload scope forces it.
