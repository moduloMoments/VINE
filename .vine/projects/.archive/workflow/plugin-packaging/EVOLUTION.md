# Evolution Report: Claude Code Plugin Packaging
## Date: 2026-06-23

Cycle 5 of the v0.4.0 roadmap ([#57](https://github.com/moduloMoments/VINE/issues/57)). Repackaged
VINE from an `npx create-vine` file-copy installer into a native Claude Code **plugin** (`plugins/vine/`,
11 skills + 2 shipped agents + a journal-check hook) distributed via a self-hosted marketplace. Shipped
across four phases / three PRs.

### Product Evolution

#### Acceptance Criteria Results

All 11 cycle-level acceptance criteria accounted, zero unaccounted. Lookup against the per-slice record
(NAVIGATION.md), with the validation contract (`trellis-check`, `run-tests.sh`) re-run green during evolve.

| Acceptance criterion (SPEC) | Evidence (slice / commit) | Status |
|---|---|---|
| 1. Invocation unchanged (colon form) | Slice 1 `0d53055` — engineer-confirmed `/vine:status` colon; Slice 2 `508ae18` structurally identical ×10 | ✅ (human-confirmed for `status`; see human-only gate) |
| 2. No auto-fire | Slices 1–2; enforced by trellis Check 2 (Slice 4 `e5252db`); 11/11 `disable-model-invocation` re-verified | ✅ |
| 3. Arguments preserved | Slices 1–2 — `argument-hint` retained, verbatim bodies | ✅ |
| 4. Agents intact | Slice 1; re-homing `73862bb` — 2 ship + 2 repo-resident, all 4 recipes load | ✅ |
| 5. Hook native | Slice 3 `c679792`/`8d87cb3` — `hooks.json` + `${CLAUDE_PLUGIN_ROOT}` | ✅ |
| 6. Marketplace install works | Slice 1/3 local install verified | ✅ (human-only re-confirm) |
| 7. npx removed cleanly | Slice 5 `04bbb2f` — `bin/cli.js`, `commands/vine/`, `package.json` gone | ✅ |
| 8. Tooling rewired | Slice 4 `e5252db` + Slice 5; trellis-check 11/11, run-tests 27/27 | ✅ |
| 9. Docs current | Slice 7 `2e3af85` (README+CHANGELOG), Slice 8 `c5056ad` (internal) | ✅ |
| 10. Decisions recorded | Slice 9 `ca91e83` — 4 ADRs + team-layer amendment; +re-homing ADR `73862bb` | ✅ |
| 11. Versioning coherent | Slice 5 `04bbb2f` + Slice 8; `plugin.json` 0.4.0 sole source, no `package.json` | ✅ |

**Cross-slice integration (full-feature scope):** payload product-only (`plugins/vine/` = 11 skill dirs,
agents = `vine-codebase-explorer` + `vine-verification`, `vine-coder`/`vine-reviewer` re-homed to
`.claude/agents/`); version coherent (`plugin.json` 0.4.0, marketplace `source: ./plugins/vine` no
`version`, no `package.json` anywhere); dangling-reference sweep clean (every residual `commands/vine`/
`create-vine`/`npx` mention is intentional migration or legacy-cleanup context).

**Multi-PR / prior-PR review:** #134 and #135 **merged** into `develop` (CI green, no review comments);
**#136 open** (base `develop`, mergeable, CI green, no comments) — the Phase-4 handoff. This branch
cleanly contains all of `origin/develop`; no parallel landings.

**Human-only acceptance gate:** AC1 (cross-skill colon-form re-confirm under a real plugin install) can't
be CI-automated — nested `claude -p` returns 401 (no inherited session credentials). Slice 1 confirmed it
empirically for `status`; the other 10 skills are structurally identical. Captured as a follow-up
([#137](https://github.com/moduloMoments/VINE/issues/137)).

#### Spec Deviations

All justified tactical calls, recorded inline in NAVIGATION/SPEC as they happened. None degrade
user-facing behavior.

- **Omit the `name` frontmatter field** (vs SPEC "map name") — the `/vine:` colon form derives from
  plugin name + skill dir; an explicit `name` risks double-namespacing. Schema reality. (Slice 1)
- **Marketplace `source` = relative subdir** (`./` then `./plugins/vine`, vs a github-source object) —
  correct schema for a plugin in the same repo as its marketplace. (Slices 1, 3)
- **Plugin moved to `plugins/vine/` for payload-slimming** — Claude Code has no file-level payload
  exclusion (no `.claudeignore`/`files`/`exclude`); a scoped `source` subdir is the only control. Also
  lands the product on the documented `plugins/<name>/` convention. (Slice 3)
- **trellis Check 2 repurposed** ("name matches filename" → "no-auto-fire") rather than delete-and-renumber
  — avoids the cross-reference renumber ripple trellis itself guards, and converts AC2 from convention to
  enforced check. (Slice 4)
- **`trellis.yml` not created** — `ci.yml` already runs trellis-check on PRs; a separate workflow would
  double-run it. Engineer call. (Slice 5)
- **Engineer scope-folds:** the `run-tests.sh` CI-fix (Slice 5), the init hook-scaffold revision (Slice 6),
  and the `main`→`develop` retarget of `pr.md`+`CONTRIBUTING.md` (Slice 8) were folded into their slices so
  each conceptual change ships coherently in one PR.
- **Agent re-homing (post-completion, `73862bb`)** — the deviation stakeholders should know: a
  write-capable autonomous `vine-coder` is deliberately **not shipped** by default (no auto-delegation
  guard exists yet). The cycle ships 2 agents, not 4; all 4 recipes still load (AC4 holds).

#### Follow-Up Items

- [#137](https://github.com/moduloMoments/VINE/issues/137) — Automate the cross-skill colon-form smoke
  test (auth-blocked: nested `claude -p` 401s). Related to #116, whose "CI gate" half landed this cycle.
- [#138](https://github.com/moduloMoments/VINE/issues/138) — navigate/evolve SKILL.md cite
  `agents/vine-verification.md` plugin-root-relative; correct for plugin users, ambiguous for contributors
  reading from the repo root. Low priority.
- **Already routed (no new ticket):** oversized skill bodies (`init`/`evolve`/`navigate` >500 lines) →
  existing optimize-scope context-trim backlog; contributor skill-dev hot-reload helper → SPEC backlog.
- **Repo-admin owed (manual, not a ticket):** set `develop` as the GitHub default PR base + branch
  protection. The branch model is documented (shared.md, CONTRIBUTING, pr.md, ADR-c) but the forge setting
  is manual.

### Agent Evolution

#### CLAUDE.md Suggestions

None. CLAUDE.md was fully rewritten for the skills/plugin product in Slice 8 and updated again in the agent
re-homing pass (added the `.claude/agents/` row). It is current.

#### Skill Suggestions

None new. The only candidate — a contributor skill-dev hot-reload/`make dev` helper — is already a SPEC
backlog note, gated on the dev-loop friction proving real.

#### Context Overlay Updates (applied)

- **`evolve.md` Multi-PR Features** — added an explicit open-PR check. The section previously greped only
  `gh pr list --state merged`, so it couldn't see an already-open handoff PR; that's what made evolve miss
  #136 until the engineer flagged it. The fix instructs evolve to also check `--state open --head
  <branch>`, and when the handoff PR is already open, to commit its cycle-close artifacts to that branch
  (riding the open PR) rather than opening a new one. Dogfooding meta-friction → first-class overlay fix.

#### VINE Process Observations

- **Dogfooding caught a real overlay gap.** The multi-PR check assumed evolve opens the handoff PR, but
  navigate *suggests* it, so it's frequently open already. Fixed in the overlay (above).
- **Process slip to avoid:** a placeholder `gh issue create` fired a real issue (#137) with a stub body;
  recovered by editing in place. `gh issue create` has no dry-run — never use it as a no-op.

### User Evolution

#### Engineer Contributions

This was platform/packaging work in the engineer's confident zone; the value was in the load-bearing calls,
not new learning.

- **Payload-slimming restructure** — pushed for *true* slimming (the `plugins/vine/` subdir) over accepting
  AC5 "in intent," after research confirmed no file-level exclusion mechanism exists. This is what scoped
  the published payload to product-only.
- **Agent re-homing** — the security judgment: a write-capable autonomous `vine-coder` shouldn't ship to
  every install while there's no guard against accidental auto-delegation. Reframed the packaging as "2
  ship, 2 repo-resident" and had everything updated as if that were the plan from the start.
- **Coherent scope-folding** — repurposing trellis Check 2 (vs the renumber ripple), skipping the redundant
  `trellis.yml`, and folding the `main`→`develop` retarget in so the branch model ships in one coherent PR
  rather than dangling across changes.

#### Profile Updates

- **platform** — kept at `confident` (this cycle reinforced the level rather than changing it); notes
  refreshed to record the plugin/marketplace distribution calls (payload scoping, `plugin.json` single
  version source, the agent ship-vs-hold security call) and re-dated to 2026-06-23.
- **Growth log** — none (engineer declined; the notes refresh captures the cycle).

#### Claude Memory Suggestions

None. No new general cross-domain preference surfaced — the cycle reinforced existing memories. The one
process learning (check open PRs, not just merged) was captured durably in the `evolve.md` overlay rather
than as a personal memory.

#### Durable Decisions (Knowledge ADRs)

Captured during Slice 9 (`ca91e83`) and the re-homing pass (`73862bb`); no new records rose during evolve.
Five records under `.vine/knowledge/workflow/`:

- `2026-06-23-vine-ships-as-a-plugin-and-drops-npx` — plugin-only, skills-not-commands, revised #57 gate.
- `2026-06-23-overlay-distribution-is-documentation-not-a-mechanism` — overlays are consumer-owned.
- `2026-06-23-plugin-json-is-the-single-version-source-main-release-develop-integration` — versioning +
  branch model.
- `2026-06-23-scope-the-plugin-payload-with-a-plugins-vine-source-dir` — no file-level exclusion; scoped
  `source` subdir is the only payload control.
- `2026-06-23-hold-autonomous-role-agents-out-of-the-shipped-payload` — ship phase-support agents, hold the
  write-capable autonomous roles.

Plus an amendment to `2026-06-22-vine-ships-a-team-layer-recommendation-not-a-prescribed-mechanism`
correcting its "seam where plugin distribution attaches" expectation (the seam carries documentation, not a
mechanism).

### Handoff Package

The product handoff is the **already-open PR [#136](https://github.com/moduloMoments/VINE/pull/136)** (base
`develop`, CI green). Evolve's cycle-close artifacts (this report, the `.resolved` marker, the PROJECT-MAP
evolve row) ride in the same branch rather than a new PR. #136's existing description is concise and
zero-context-correct; no rewrite needed.

#### PR Description (as merged into #136)

> **What** — Brings every doc and decision record in line with VINE now shipping as a native Claude Code
> plugin (code migration landed in earlier PRs). Rewrites the README install path, updates internal docs
> and contributor tooling to the skills/plugin layout and the `main`-release/`develop`-integration branch
> model, adds five decision records, and scopes the shipped plugin to the two agents the workflow invokes.
>
> **Why** — The migration changed how VINE is installed, versioned, and laid out, but the docs still
> described the old npx install — a new reader would follow dead instructions. The decision records capture
> the load-bearing calls so they're recoverable. And shipping a write-capable autonomous coder to every
> install, with no guard against accidental auto-delegation, isn't something to default-on yet.
>
> Refs #57.

#### Reviewer Notes

- The payload-slimming subdir (`plugins/vine/`) is the *only* mechanism for scoping the published payload —
  Claude Code has no `.claudeignore`/`files`/`exclude`. ADR-d records why.
- Agents split by stakes: phase-support agents ship (invoked by skills); autonomous-role agents stay
  repo-resident (no safe trigger surface + no auto-delegation guard yet).
- AC1 (colon-form invocation) rode on human confirmation for `status`, not CI — the auth blocker is #137.
  The other 10 skills are byte-identical-recipe conversions.

#### Multi-PR Summary

| Phase | Slices | Status | PR |
|-------|--------|--------|----|
| Phase 1: Scaffold + Invocation Proof | Slice 1 | Shipped | [#134](https://github.com/moduloMoments/VINE/pull/134) (merged) |
| Phase 2: Convert the Product to Skills | Slices 2–3 | Shipped | [#135](https://github.com/moduloMoments/VINE/pull/135) (merged) |
| Phase 3: Remove npx + Rewire Tooling | Slices 4–6 | Shipped | [#135](https://github.com/moduloMoments/VINE/pull/135) (merged) |
| Phase 4: Docs + Cycle Knowledge | Slices 7–9 | Complete | [#136](https://github.com/moduloMoments/VINE/pull/136) (open) |

**#57 closes** after #136 merges (the impl PR uses `Refs #57`; this report is the cycle-close).
