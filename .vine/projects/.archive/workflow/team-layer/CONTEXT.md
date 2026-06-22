# Feature Context: Team Layer (#52)

## Date: 2026-06-18
## Author: Rob + Claude

> Cycle 4 of the v0.4.0 delegation-routing roadmap. The "route stage's policy layering":
> team conventions that install with the project instead of living in one person's head.
> Source issue: [#52](https://github.com/moduloMoments/VINE/issues/52). Depends on the cycle-1
> precedence split and the cycle-2 knowledge layer, both shipped.

### Codebase Landscape

The feature touches five surfaces. Anchors are to the **main checkout** (this worktree mirrors it).

**1. `commands/vine/init.md` — the scaffolding command.** Step structure:
- `Step 2: Ask About Team Context` (`init.md:61`) — already the "gather what code can't tell you"
  step, capped at 1-2 question rounds. The natural slot for a solo-vs-team adoption question; the
  exact question set is left open today (`init.md:63` says use `AskUserQuestion`, no structured call).
- `Step 3: Generate Context Overlay Files` (`init.md:72`) — embeds the full `shared.md` template
  (`init.md:80-229`). Relevant template sections: `## Overlay Precedence` (`init.md:111`, defines the
  `<!-- class: policy -->` marker and "flat personal-wins with policy carve-outs"), `## Team Context`
  (`init.md:211`, **already `<!-- class: policy -->`** at `init.md:212`, body is a bare placeholder).
- `Step 6: Gitignore` (`init.md:367`) — target end-state is two root-`.gitignore` lines (`.vine/*` +
  `!.vine/README.md`); explicitly defers team sharing to manual negations / `git add -f` (`init.md:390`).
  **No `.vine/.gitignore` concept exists anywhere.**
- `Step 8: Upgrade Existing Projects` (`init.md:408`) — detects existing `.vine/context/`, runs
  `### Upgrade Mode` (`init.md:441`) with a "required shared.md sections" checklist (`init.md:449-456`).
  This is the backward-compatible migration hook the adoption-mode upgrade would extend.

**2. Project discovery across 7 commands + trellis.** Every command that enumerates features does a
prose "Scan `.vine/projects/` for feature directories" and filters only two things: `.resolved`
marker files and the `.archive/` subtree. Sites: `status.md:38`, `resume.md:39`, `pause.md:37`,
`navigate.md:60`, `inquire.md:44`, `evolve.md:42`, plus init's archive sweep (`init.md:587`). Trellis
is the only one with an explicit glob: `.vine/projects/*/*/` (`trellis.md:261`). The canonical path
rule is stated in the `shared.md` template (`init.md:135`) and `references/STATE.md:6-11`.

**3. Overlay composition model.** Today two layers compose: `shared.md` (repo) + `shared.local.md`
(personal, gitignored), resolved by `## Overlay Precedence` (`shared.md:33-55`) as **flat
personal-wins with a policy-class carve-out** (`<!-- class: policy -->` sections are immutable from
the personal layer). There is **no third (team/company) layer** — the roadmap wants team context to
relocate "from a shared.md section to a composable layer" (ROADMAP.md, "Overlay layers and precedence").

**4. Documentation: README.md + references/STATE.md + CLAUDE.md.**
- `README.md:158-170` "Piloting in an existing project" — global-gitignore-the-whole-`.vine/`
  starting posture with a *single* solo→team transition sentence (`README.md:170`) that names only
  `context/` as the team-shared piece.
- `references/STATE.md` carries the authoritative tracked-vs-untracked contract: `## Committing
  Artifacts` (`STATE.md:508-530`), the `**Forward references**` block (`STATE.md:484-486`), the
  `.vine/ACTIVE` "never leaves the machine" guarantee (`STATE.md:255-277`), the Durable-Decisions
  one-record-per-file rationale that **already cites #52** as the append-only-journal pattern's origin
  (`STATE.md:409`), and the Filtering Convention (`STATE.md:584-591`).
- `CLAUDE.md:17-21` — the repo-structure tracked/gitignored bullets.

**5. Conflict-safe conventions (#52 AC4).** Already partly realized: the knowledge layer's
one-record-per-file design (`STATE.md:402-417`) *is* the append-only/single-writer pattern, explicitly
sourced to #52. NAVIGATION.md is already append-only-per-slice. The conventions exist in practice;
#52's job is to **document them once on a shipped surface** and extend them to feature directories.

#### Durable Decisions on record (workflow domain)

Five records under `.vine/knowledge/workflow/`. Two are directly load-bearing here:

- **[defer-the-vine-gitignore-inversion-to-the-vine-local-work](.vine/knowledge/workflow/2026-06-16-defer-the-vine-gitignore-inversion-to-the-vine-local-work.md)** (Accepted 2026-06-16) — keeps the
  brittle root `.gitignore` deny-then-allowlist for now and **gates the full track-by-default inversion
  (#108) on `.vine.local/` landing**, so the whole pattern flips at once. #52 is the natural home for
  that `.vine.local/` work. *Still live and directly governs this cycle's gitignore decisions.*
- **[evolve-states-the-four-knowledge-homes-referentially](.vine/knowledge/workflow/2026-06-16-evolve-states-the-four-knowledge-homes-referentially.md)** (Accepted 2026-06-16) — establishes the anti-bloat stance
  (state a shared rule once and reference it, don't physically restructure long command files). The
  precedent for how team-layer conventions/overlay rules should be documented. *Still live.*

The other three (`cut-the-derived-map-cache`, `decision-delegation-default-able-vs-human-required`,
`route-md-headless-eligibility-gate`) are background context, not contradicted by this work.

### Current State

- **This repo is already E2-shaped.** `.vine/context/`, `.vine/projects/`, `.vine/knowledge/` are
  tracked via the root `.gitignore` allowlist (deny `.vine/*`, re-admit each subdir); `PROFILE.md`,
  `PAUSE.md`, `ACTIVE`, `*.local.md` stay gitignored. So "tracked-by-default" is *partly already done
  here* — but as a brittle allowlist, not the clean inversion #108 envisions.
- **The personal overlay layer already shipped** (cycle 1): `shared.local.md` + `## Overlay
  Precedence`. #52's overlay-composition half builds on a working two-layer model.
- **`## Team Context` is already a policy-class section** in `shared.md` (`init.md:211-214`,
  `shared.md:276`) — the policy infrastructure for team governance exists; what's missing is the
  adoption-mode question that *populates* it richly and/or a separate composable team layer.
- **No solo/team mode branch exists** in init (the words "solo"/"single-writer" appear nowhere in
  init.md / README.md / STATE.md). No `.vine/projects/.local/`, no `.vine.local/`, no `.vine/.gitignore`.

### Edge Cases & Tribal Knowledge

- **The issue predates the decisions that reshape it.** #52's body (2026-06-10, reframe 2026-06-11)
  specifies `.vine/projects/.local/` (a subdirectory) + a scaffolded `.vine/.gitignore`. But
  `STATE.md:484-486` (written later) specifies a **`.vine.local/` *sibling root*** mirroring `.vine/`'s
  structure — a different architecture for the same goal. **This mismatch is the central design
  decision for inquire** (see Open Questions). Treat the issue ACs as intent, not letter.
- **The gitignore inversion is deliberately deferred and coupled to this cycle.** Per the knowledge
  record, #108 (track-by-default inversion) was held *specifically* to flip alongside `.vine.local/`.
  If `.vine.local/` lands here, #108's inversion can/should ride with it — that's the "flip in one
  coherent move" the record protects. Doing the sibling-root without the inversion would be the
  half-migration the record warns against.
- **`.vine/ACTIVE` has a hook-safety guarantee not to disturb.** It's gitignored, "never leaves the
  machine," and hooks treat its `feature:` path as opaque (`STATE.md:257,265`). A `.vine.local/`
  project's ACTIVE path must still be written truthfully by navigate (`navigate.md:83` currently
  hardcodes the `.vine/projects/...` template) — but hooks already tolerate arbitrary paths, so the
  risk is in the *writing* command, not the hooks.
- **`git check-ignore -q .vine/projects`** is the commit-or-skip test in verify/inquire
  (`verify.md:331`, `inquire.md:314`). It checks the `projects/` root. A model where the shared tree is
  tracked but personal projects are gitignored needs a **per-path** ignore check, or it will
  misclassify personal projects as committable.
- **Discovery must learn one new exclusion (or one new inclusion).** Whichever path wins, the
  Filtering Convention (`STATE.md:584-591`) and 7 prose scan sites change together — a `.vine.local/`
  sibling root means commands scan *two* roots; a `.vine/projects/.local/` subdir means commands
  *exclude* it from the shared scan and add it back when the engineer is in personal mode.
- **Precedence is currently two-layer flat.** Adding a team/company layer means deciding where it sits
  relative to repo and personal: the roadmap's rule-class split says preference-type rules resolve
  personal-wins, policy-type rules resolve company-wins (`ROADMAP.md`, "Precedence on conflict"). The
  policy-class marker already exists; a *team* layer needs a file/composition story the two-layer model
  doesn't yet have.
- **Multiple teams, not a binary (maintainer steer, 2026-06-18).** An engineer/repo can belong to more
  than one team (e.g. platform *and* payments). So the model is not solo-vs-one-team — it's: init seeds
  *one* team layer, and a **separate add/update-team flow** composes *additional* team layers over time.
  This means team overlays are plural and named (e.g. `team-<name>.md` or a `teams/` dir), the
  composition resolves N team layers + repo + personal (precedence across *sibling* team layers is a new
  question the two-layer model never faced), and "add/update a team" needs a home — a new command, an
  init re-run sub-mode, or part of the upgrade pass. Connects to plugin distribution (#57): each team
  layer may arrive as its own plugin, so an engineer installs the team plugins they belong to.
- **Team overlay distribution is the plugin cycle's job (#57), which comes *after* this one.** #52's
  AC referencing "distributed as plugin content" can't fully land here — inquire must split what lands
  now (the layer + composition + precedence + local/shared mechanics) from what defers to #57
  (distribution/propagation).

### Tech Debt in Affected Areas

- **Brittle root `.gitignore`** (deny-then-allowlist): every new tracked `.vine/` subdir needs its own
  negation or it silently vanishes — the failure mode the gitignore-inversion record documents. In
  scope to *fix* here if `.vine.local/` lands (resolves #108); out of scope to touch otherwise (the
  record says don't half-migrate).
- **README "piloting" guidance is thin and slightly stale** — one transition sentence naming only
  `context/`. #52 explicitly calls for replacing it with a solo→team graduation path; fold the fix into
  this cycle rather than backlogging.
- **Prose-only project discovery** (no shared filter helper) means the `.local` rule must be restated
  at 7+ sites. Consistent with how VINE works today (prose instructions), but a candidate for the
  "state once, reference" pattern from the referential-homes record.

### Documentation Gaps

- `references/STATE.md` `**Forward references**` (`STATE.md:484-486`) will move from "backlog idea" to
  implemented — needs to become the real `.vine.local/` (or `.local`) contract.
- `## Committing Artifacts` (`STATE.md:508-530`) names "a future `.vine.local/` root" — must be
  formalized or superseded by whatever path inquire picks.
- README "Piloting" section (`README.md:158-170`) → solo→team graduation path + local-project escape
  hatch.
- `CLAUDE.md:17-21` tracked/gitignored bullets → add the team layer + local-project + any `.vine.local/`.
- The `.vine/README.md` scaffold template (`init.md:281-292` table + forward-looking #52 block at
  `init.md:349-358`) → reflect the now-real team layer.
- `references/STATE.md` Command/State Artifact Addition Checklists (`shared.md:72-90`) — if a new
  overlay file or directory convention is added, these checklists govern the ripple.

### Open Questions

1. **`.vine.local/` sibling root vs `.vine/projects/.local/` subdirectory** — the central architecture
   decision. The post-issue durable decisions favor the **sibling root** (`STATE.md:484-486`); the
   issue body says subdirectory. Inquire must pick one and reconcile/supersede the loser. (Lean:
   sibling root, since it's the recorded direction and unblocks the clean #108 inversion — but that's
   inquire's call.)
2. **Does the gitignore inversion (#108) ride this cycle?** The knowledge record gates #108 on
   `.vine.local/`. If we build `.vine.local/`, do we also flip the root `.gitignore` to track-by-default
   here (one coherent move, per the record), or land `.vine.local/` first and flip in a follow-up?
3. **Team layer as composable named overlays vs enriched policy-class `## Team Context`** — given
   multiple-teams (above), does team context become a set of named composable overlays (e.g.
   `team-<name>.md` or `context/teams/`) each with a precedence slot, or stay a richer policy-class
   section in `shared.md` for now with the composable layer deferred to plugin (#57)? If plural overlays,
   how do *sibling* team layers resolve against each other on conflict (declared order? all policy-class
   company-wins, so collisions must be rare by construction?)?
3b. **Home for the add/update-team flow** — init seeds the first team; adding/updating *additional*
   teams later needs a home. Options: a new `vine:team` command, an init re-run sub-mode, or an extension
   of init's Upgrade Mode. Whichever is chosen must honor the backward-compat gate and the
   Command Addition Checklist (`shared.md:72-78`) if it's a new command.
4. **Where's the solo/team line at scaffold time?** What exactly does team mode scaffold differently
   (a `.vine/.gitignore`? richer Team Context? the `.vine.local/` root)? And does this repo (already
   E2-shaped) need anything, or is it the worked example?
5. **Per-feature visibility mechanism** — where does the team-shared-vs-local-only choice live: a
   prompt in `vine:verify` at project creation (the only command that *creates* projects), and how does
   `evolve` offer local→shared promotion?
6. **Backward-compat migration** — what does init's upgrade pass offer an existing solo `.vine/`, and
   how do we guarantee declining changes nothing (the #58 rename-fallback pattern the roadmap mandates)?
7. **Scope split vs #57** — draw the line between what team-layer ships now and what plugin distribution
   (#57) carries, so neither cycle blocks the other.
