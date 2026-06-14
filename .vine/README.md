# Using VINE in this repo

This directory holds VINE's working state for **VINE Framework**. VINE is a pure-markdown,
AI-assisted development framework: features flow through phases — **verify → inquire → navigate
→ evolve** (plus lightweight **pair** for small changes) — and each phase reads shared context
from here and writes its artifacts back.

New here? Run `/vine:help` for the full command list, or `/vine:status` to see where the current
feature stands.

## What lives under `.vine/`

| Path | What it is |
|------|------------|
| `context/shared.md` | Repo-wide overlay, loaded by every phase |
| `context/<phase>.md` | Per-phase overlays — `verify.md`, `inquire.md`, `navigate.md`, `evolve.md`, `pair.md` |
| `context/shared.local.md` | Your personal overlay layer (optional, gitignored) |
| `projects/<domain>/<feature-slug>/` | Per-feature artifacts: CONTEXT → SPEC → NAVIGATION → EVOLUTION, plus PROJECT-MAP |
| `PROFILE.md` | Your per-domain expertise, used to tune explanation depth (gitignored) |
| `scripts/` | Native hook scripts (e.g. `journal-check.sh`) |
| `ACTIVE`, `projects/**/PAUSE.md` | Ephemeral session state (gitignored) |

`references/STATE.md` in the repo root is the **authoritative** contract for every artifact's
format and lifecycle. Treat this table as a map; consult STATE.md for the details.

## Context overlays

Each phase composes its context from up to three layers:

1. **`shared.md`** — repo-wide context every phase loads (conventions, tooling notes, the
   collaboration stance, the validation contract).
2. **`<phase>.md`** — guidance only one phase needs (which agents `navigate` invokes, what
   `verify` should always explore). These exist only where there's something to add.
3. **`shared.local.md`** — your personal layer. Gitignored; absent it, nothing changes.

### Overlay precedence

The layers resolve as **flat personal-wins with policy carve-outs** — like Claude's own
settings, where local overrides project except for an immutable policy ceiling:

- **Preference content** (every unmarked section) is personal-overridable: where
  `shared.local.md` and `shared.md` conflict, your personal layer wins.
- **Policy content** is immutable from the personal layer. A section marked
  `<!-- class: policy -->` directly under its heading (e.g. **Team Context**, **CI/CD**) always
  wins; `shared.local.md` can't weaken or replace it.

Only policy-class sections carry the marker — unmarked means preference.

## The `## Validation` block

`shared.md` may carry an optional `## Validation` section: a fenced YAML block that declares how
this repo's checks run, so verification doesn't have to guess.

```yaml
lint: <command>          # linter / formatter
typecheck: <command>     # static type check
test: <command>          # scoped / per-file tests
test-all: <command>      # full suite
build: <command>         # build / compile check
extra:                   # anything else
  - <command>
```

Every key is **optional** — declare only the checks this repo has. The `vine:verify`
verification agent and the `navigate` / `evolve` / `pair` phases read this block to run the right
checks; with no block (or missing keys) they fall back to inferring commands from package scripts
and config. Full schema: `references/STATE.md`.

## Customizing VINE for this repo

- **Edit the overlays.** `shared.md` and the per-phase files are plain markdown — change them to
  teach VINE this repo's conventions, tools, and gotchas. Re-running `/vine:init` in upgrade mode
  folds in newly discovered tooling without clobbering your edits.
- **Add per-phase guidance.** Create or extend `context/<phase>.md` to give one phase context the
  others don't need.
- **Keep personal tweaks local.** Drop preferences you don't want to commit into
  `context/shared.local.md` — it overrides preference sections but never policy ones.

### Plugins & team distribution (forward-looking)

Packaging VINE as a Claude Code plugin and distributing shared team overlays are on the roadmap,
not yet shipped. Track progress here:

- [VINE #57 — Claude Code plugin: packaging + team-overlay distribution](https://github.com/moduloMoments/VINE/issues/57)
- [VINE #52 — Team layer](https://github.com/moduloMoments/VINE/issues/52)

Until those land, share overlays the manual way: commit the files under `.vine/context/` you want
your team to share, and keep personal-only tweaks in the gitignored `.local` layer.
