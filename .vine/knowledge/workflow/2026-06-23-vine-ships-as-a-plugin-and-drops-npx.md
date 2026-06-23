# VINE ships as a Claude Code plugin (skills, not commands) and drops the npx installer

## Status

Accepted — 2026-06-23
Source: workflow/plugin-packaging · Actor: Rob + Claude
Supersedes: none

## Context

VINE shipped via `npx create-vine`, which file-copied 11 command files into a repo's (or
`~/.claude/`'s) `commands/vine/` directory. Cycle #57 (plugin packaging — repackage VINE for
Claude Code's native plugin system) set out to add a plugin distribution *alongside* npx, with
"keep npx working" stated as a hard gate.

Two findings reshaped that. First, the layout fork: a flat `commands/` directory in a plugin
cannot be made to namespace as `/vine:<name>` from a non-plugin-aware install, and nested
`commands/vine/*.md` is undocumented — but a plugin named `vine` with `skills/<name>/SKILL.md`
resolves to the exact colon form `/vine:<name>` (confirmed in the plugins reference and verified
empirically on one skill before any mass conversion). So **skills**, not commands, are the only
layout that preserves today's invocation. Second, the cost of the gate: maintaining two
distribution surfaces forever means a permanent sync seam and two-tree drift risk, paid against an
early, small installed base.

## Decision

Repackage VINE as a native plugin whose **sole** product representation is
`plugins/vine/skills/<name>/SKILL.md`, and **drop npx entirely this cycle** — `bin/cli.js`, the
`commands/vine/` tree, the dogfooding symlink, and the npm publish path are removed. This revises
#57's hard gate from "keep npx working" to "migrate npx users to the plugin."

- **Skills, not commands**, because only the plugin-name + skill-dir derivation guarantees the
  `/vine:<name>` colon form. A hyphen form (`/vine-navigate`) was the cycle's stop-and-flag risk;
  it was retired first, empirically, on one skill.
- **`disable-model-invocation: true` on every skill** — VINE phases are deliberate, user-driven
  gates; the model must never auto-fire `/vine:navigate`. (The `name` frontmatter field is
  *omitted*, not mapped — an explicit `name: vine:status` would double-namespace.)
- **Existing npx users migrate** via documented cleanup: remove the legacy `.claude/commands/vine/`
  and install the plugin. `/vine:init` detects the legacy directory and offers the removal;
  declining changes nothing (the #58 offer-migration pattern — init offers, never imposes).

## Consequences

- One distribution path: no sync surface, no two-tree drift. The conversion recipe is
  "verbatim body, frontmatter-only change," so behavior is identical (AC-1) and the bodies are
  provably unchanged.
- Stranded-npx risk is accepted and mitigated by README migration docs + init's cleanup offer —
  judged acceptable for the early installed base.
- New debt, consciously taken: the dev loop is now reinstall/refresh the local plugin rather than
  an instant symlink edit (documented in `.vine/context/shared.md`).
- Versioning, release flow, and payload scoping are forced follow-ons of dropping npm — captured in
  their own records (`2026-06-23-plugin-json-is-the-single-version-source-main-release-develop-integration`
  and `2026-06-23-scope-the-plugin-payload-with-a-plugins-vine-source-dir`) rather than restated here.
- The "harder half" of #57 — cross-repo overlay distribution — is resolved by scoping it *out*, not
  building it (`2026-06-23-overlay-distribution-is-documentation-not-a-mechanism`).
