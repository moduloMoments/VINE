# What controls what — VINE's precedence chain

Every VINE phase composes its behavior from up to five inputs. Four are instruction layers
that stack; the fifth (the profile) never overrides anything. One page, base to top:

```
                        ┌──────────────────────────────────────────┐
   never overridden ──▶ │  <!-- class: policy --> sections         │  team governance
                        │  (in .vine/context/*.md)                 │  (CI gates, operating model)
                        ├──────────────────────────────────────────┤
   wins preferences ──▶ │  .vine.local/context/<name>.md           │  your personal layer
                        │  (gitignored, mirrors each repo overlay) │  (never committed)
                        ├──────────────────────────────────────────┤
   wins over defaults ▶ │  .vine/context/shared.md                 │  repo overlays
                        │  .vine/context/<phase>.md                │  (tracked, team-shared)
                        ├──────────────────────────────────────────┤
              base ──▶  │  SKILL.md — the phase command itself     │  ships with the plugin
                        └──────────────────────────────────────────┘

    outside the stack:   .vine.local/PROFILE.md   → adjusts explanation depth, overrides nothing
                         journal-check hook       → mechanical git-commit gate, reads no overlays
```

## The layers

**1. The command file (`SKILL.md`).** Ships with the plugin; defines the phase's steps and
defaults. You never edit it — everything below customizes it from the outside.

**2. Repo overlays (`.vine/context/shared.md` + `.vine/context/<phase>.md`).** Tracked in the
repo, created by `/vine:init`. Every phase (except `init` and `help`) loads `shared.md` plus its
own phase file; both apply as additional instructions, and **overlay instructions win over
command defaults when they conflict**. The two repo files don't outrank each other — the phase
file just scopes its guidance to one phase, so put phase-specific content there and repo-wide
content in `shared.md`.

**3. Personal overlays (`.vine.local/context/<name>.md`).** A gitignored mirror of any repo
overlay (same filename, different root — `.vine.local/context/shared.md` pairs with
`.vine/context/shared.md`). Resolution is **flat personal-wins with policy carve-outs**, like
Claude Code's own settings:

- **Preference sections** (anything unmarked): your personal layer wins on conflict.
- **Policy sections** (marked `<!-- class: policy -->` directly under the heading): the repo
  overlay always wins — a personal overlay can't weaken team-enforced content.

**4. The engineer profile (`.vine.local/PROFILE.md`).** Not an instruction layer. It records
your per-domain familiarity (confident / familiar / learning / new), and phases use it only to
calibrate *explanation depth* — concise where you're confident, explain-the-why where you're
new. It never changes what a phase does, only how much it narrates.

## Quick conflict table

| If these disagree… | …this wins |
|---|---|
| Repo overlay vs. command file | Repo overlay |
| Personal overlay vs. repo overlay (unmarked section) | Personal overlay |
| Personal overlay vs. `<!-- class: policy -->` section | Repo overlay (policy is a ceiling) |
| Profile vs. anything | Nothing — the profile only tunes depth |

## Notes that keep this predictable

- **Every file is optional.** Missing overlays mean the phase runs on its built-in defaults;
  missing `.vine/` entirely gets a suggestion to run `/vine:init`. Nothing breaks by absence.
- **Where `.vine.local/` lives:** at the repo's *primary* worktree (resolved via
  `git rev-parse --git-common-dir`), so linked worktrees all see one profile and one personal
  layer. In a plain single checkout that's just the repo root.
- **"Hooks" means two things historically.** Pre-0.4 installs kept overlays in `.vine/hooks/`
  — that directory is the *same mechanism* as `.vine/context/` under an old name (phases fall
  back to it through 0.4.x; `/vine:init` migrates it). The *journal-check hook* is unrelated:
  a mechanical PreToolUse guard shipped with the plugin that blocks `git commit` during an
  active navigate session until the feature's NAVIGATION.md is updated. It's enforcement, not
  context — it doesn't read overlays and no overlay can change it.

The canonical wording of the loading and precedence rules lives in your repo's own
`.vine/context/shared.md` ("Overlay Loading Protocol" and "Overlay Precedence") once
`/vine:init` has scaffolded it; artifact contracts live in
[references/CONTRACTS.md](../references/CONTRACTS.md).
