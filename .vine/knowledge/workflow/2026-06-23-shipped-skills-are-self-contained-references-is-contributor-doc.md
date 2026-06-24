# Shipped skills are self-contained — `references/` is contributor documentation, not a runtime contract

## Status

Accepted — 2026-06-23
Source: workflow/payload-reference-convention · Actor: Rob + Claude
Supersedes: none

## Context

A shipped VINE skill runs with the *consuming* repo as cwd. After the v0.4.0 payload-slimming
(`source: ./plugins/vine`, see `2026-06-23-scope-the-plugin-payload-with-a-plugins-vine-source-dir`),
`references/` is deliberately **not** in the payload — so the ~67 `references/STATE.md` pointers in
shipped skill bodies all resolved to nothing from a consuming repo, and `vine:init` actively *wrote*
dead `references/…` pointers into other repos' README/CLAUDE.md (#142, #141, #138).

Two directions were on the table:

- **(a) Self-contained skills.** Treat `references/STATE.md` as *contributor documentation*. Stop
  instructing the runtime to read it; inline whatever a skill genuinely needs via the existing
  *operative-copy* pattern (`evolve/SKILL.md` already carried one); cite nothing VINE-source-internal
  on a shipped surface.
- **(b) Ship the contract.** Move/copy `references/` *inside* `plugins/vine/` and reference it
  portably (`${CLAUDE_PLUGIN_ROOT}/…`, the help-skill Glob). There is no file-level payload
  exclusion, so this means physically duplicating the file into the source dir.

## Decision

Take **(a): shipped skills, agents, and hooks are self-contained.** A path on a shipped surface must
fall into exactly one of three buckets:

1. **Payload-internal** (`plugins/vine/`): reference an agent/hook by its **invocable name**; when a
   literal path is unavoidable, write `${CLAUDE_PLUGIN_ROOT}/…` — never a bare `agents/…`, `skills/…`,
   `hooks/…`.
2. **Consumer working tree** (`.vine/…`, `.vine.local/…`): legitimate runtime paths resolving against
   the consumer's cwd — cite as-is.
3. **VINE-source-internal** (`references/…`, repo-root docs, `.claude/…`): does not exist in a
   consuming repo — **forbidden** on a shipped surface. Inline what the runtime needs; drop the rest.

Direction (b) was rejected: it partially *reverses* the just-made payload-scope exclusion and accepts
a duplication/sync cost, to ship a file that is contributor documentation in the first place. This is
the **third** time the team has resolved "should VINE ship X?" toward *documentation, not mechanism* —
after `2026-06-23-overlay-distribution-is-documentation-not-a-mechanism` and the payload-scope record.
The thread is now a settled heuristic: VINE ships the product, not its own contributor contracts.

The rule itself is the operative authority and lives where every contributor session loads it —
CLAUDE.md "Skill Authoring Conventions" (the three buckets + self-contained rule) and
`references/CONTRACTS.md` "Path resolution by audience" (the why: the #138 two-audience split between
a plugin user's cwd and a contributor's repo root). This record is the durable *judgment* behind that
rule — why (a) beat (b) — not the rule's text.

## Consequences

- 60 `references/` citations removed from skill bodies; runtime-critical content (chiefly the
  PROFILE.md `## Domain Expertise` format) inlined via operative-copy. Triage was near-binary: the
  vast majority were provenance pointers ("see X for detail"), safe to drop because the runtime-needed
  text was already inlined — confirming verify's read that hard dependencies were rare.
- `references/STATE.md` was renamed to `references/CONTRACTS.md` (the file carries the artifact
  templates *and* cross-cutting conventions, far broader than "state," which also collided with
  *session* state). Historical records (CHANGELOG, dated `.vine/knowledge/` ADRs) were left naming
  `STATE.md`, period-accurate.
- A `/trellis` Check 13 guard now fails the build on any bucket-3 path or bare bucket-1 path on a
  shipped surface, so the convention can't silently drift back.
- A removed cross-reference can break `/trellis` from the *other* side: Check 10 couples a skill's
  pointer phrase to an anchor pair, so deleting a pointer requires deleting its pair (the rename
  lockstep, run in reverse). Anchor pairs live in three coupled homes — `trellis-check.sh`,
  `trellis.md`, `run-tests.sh` — and move together or the check fails.
