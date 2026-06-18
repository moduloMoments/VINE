---
name: vine:evolve
description: "Wrap up a feature — run final verification against acceptance criteria, update CLAUDE.md and context overlays, capture engineer growth, and prepare the PR handoff"
argument-hint: "[feature path, e.g., 'payments/webhook-support']"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
  - Edit
  - Bash
  - Agent
  - AskUserQuestion
---

# vine:evolve — Triple Evolution

## Load Context Overlays

Read `.vine/context/shared.md` and `.vine/context/evolve.md` if they exist, then follow the
**Overlay Loading Protocol** from `shared.md` for the rest (apply-as-overlay precedence, the
personal `.local` layer, the legacy-directory fallback, and missing-file behavior). The evolve
overlay carries evolve-specific extensions for this project (PR creation tools, CI validation
commands, repo-level agents and skills to suggest wiring into overlays, Jira/Linear integration for
follow-up items). If `shared.md` is absent, degrade gracefully: read the phase overlay if present,
otherwise proceed on command defaults.

## Load Engineer Profile

Follow the Engineer Profile Protocol and Collaboration Stance from `.vine/context/shared.md`. Note the
current domain expertise entries — you'll use this during Evolution 3 to propose updates.
If no profile exists, you'll offer to create one during Evolution 3.

---

The feature is implemented. Now you evolve three things: the product, the agent's capabilities,
and the user's knowledge. This is what makes VINE different from frameworks that just verify and
ship — every feature is an opportunity to grow on three dimensions.

## Getting Started

Identify the feature directory under `.vine/projects/` (e.g., `.vine/projects/payments/webhook-support/`). If
there are multiple feature directories, use `AskUserQuestion` to let the engineer pick which
feature to review. Filter out resolved projects (directories containing a `.resolved` file) and
archived projects (under `.vine/projects/.archive/`). If all projects are resolved or archived,
tell the engineer and suggest starting a new cycle with `/vine:verify` — present the command
in its own fenced code block so it's copy-pastable.

Read all VINE artifacts for this feature:
- `.vine/projects/<domain>/<feature-slug>/CONTEXT.md` (the landscape)
- `.vine/projects/<domain>/<feature-slug>/SPEC.md` (the design)
- `.vine/projects/<domain>/<feature-slug>/NAVIGATION.md` (the implementation journal)
- `.vine/projects/<domain>/<feature-slug>/PROJECT-MAP.md` (progress tracker, if it exists)

If any are missing, work with what you have. NAVIGATION.md is the most critical — it tells you
what was actually built versus what was planned.

If PROJECT-MAP.md exists, update the evolve row to 🚧 with today's date. If it has a Milestones
table, note which phases shipped in prior PRs — evolve's verification should focus on the final
phase group and cross-phase integration, not re-verify already-shipped work.

If the feature directory contains a PAUSE.md, picking the work back up consumes it: surface
its notes, then delete the file — a consumed pause must not linger suggesting `/vine:resume`.
Also delete `.vine/ACTIVE` (repo root) if it exists: any navigate session on this feature is
over, and a stale sentinel keeps installed hooks firing against work that's no longer active
(format and lifecycle in `references/STATE.md`).

## Evolution 1: Product

This is the verification and quality pass. The product should be better than when you started.

### Trust Per-Slice Verification

Navigate now validates and commits each slice with its acceptance criteria. Don't re-read every
file or re-check per-slice ACs — trust the commit history. Instead, pull the verification
summary from NAVIGATION.md's slice entries (each has an acceptance criteria checklist and
validation status).

Present a rollup of per-slice results from NAVIGATION.md, then focus your effort on what
navigate couldn't verify:

### Acceptance Criteria Traceability

SPEC.md's top-level `### Acceptance Criteria` is the cycle's contract — distinct from the
per-slice checklists navigate verified. Nothing else confirms every cycle-level criterion
actually landed in a slice, so build a two-column mapping of each criterion to its evidence:

| Acceptance criterion (SPEC) | Evidence (slice / commit) |
|---|---|
| [criterion text] | Slice N — [commit hash] |
| [criterion text] | **unaccounted** |

Pull the evidence from NAVIGATION.md's slice entries (their per-slice acceptance criteria and
commit hashes). This is a lookup against the record, not a re-verification — trust the
per-slice validation. A criterion with no slice/commit behind it is **unaccounted**: surface
it rather than letting it silently vanish. Unaccounted usually means one of two things — a
slice covered it without recording the link (fixable: note the evidence) or the cycle didn't
deliver it (a real gap for the engineer to decide on before shipping). This table is the
Acceptance Criteria Results in EVOLUTION.md.

### Cross-Slice Integration Check

This is where evolve adds value. Delegate to the `vine-verification` agent in **feature
verification mode at full-feature scope** — the checklist, including the cross-cutting
checks that full-feature scope adds, lives in the agent definition; don't restate it here.
Pass the agent:

- The feature's changed files and the acceptance criteria from SPEC.md
- Custom integration validation commands from `.vine/context/evolve.md`, if defined (the agent
  otherwise reads the `## Validation` block in `.vine/context/shared.md`, prose-inference fallback)

> **Verification tiers:** This is the full-feature tier; navigate runs the phase-group tier
> at phase group boundaries. The boundary between them — and the intentional asymmetry — is
> documented in the verification-tier contract note in `references/STATE.md`. The checklist
> itself lives in `agents/vine-verification.md`.

**For multi-PR features**: If PROJECT-MAP.md has a Milestones table with PR numbers, and
`gh` CLI is available, review the prior PRs as part of integration verification:

- Run `gh pr view <number>` for each shipped phase's PR to check status and review comments
- Run `gh api repos/{owner}/{repo}/pulls/<number>/comments` to surface reviewer feedback
  that may affect the current phase
- Run `gh pr checks <number>` for each shipped phase's PR to read CI status — a framework
  that preps the handoff shouldn't be blind to red checks
- Flag any unresolved review comments or requested changes from prior PRs — these could
  indicate integration issues or concerns that carry forward
- Flag any failing or still-pending checks from prior PRs — surface them in the Product
  Evolution section so they're visible before the handoff
- Include a summary of cross-PR review findings and CI status in the Product Evolution section

### Review Spec Deviations

Since navigate now annotates deviations directly in SPEC.md (strikethroughs/addenda), the
deviations table should be straightforward to compile. For each deviation:
- Was it a justified tactical decision?
- Does it change the feature's behavior in ways stakeholders should know about?

### Identify Follow-Up Work

Compile from NAVIGATION.md's "discovered items" and any gaps found during verification:
- Bugs found but not fixed
- Tech debt created or discovered
- Features that were descoped
- Documentation that needs updating
- Tests that should be added

Suggest concrete backlog items with enough context that someone else could pick them up.

If there are actionable follow-up items (not just "consider someday" notes), offer to create
tickets. Use `AskUserQuestion` with `multiSelect: true` to let the engineer pick which items
should become tickets. For each selected item:

- A title that stands alone (not "follow-up from [feature]")
- Body with enough context from CONTEXT.md and NAVIGATION.md that someone could pick it up
  without reading the VINE artifacts

If `.vine/context/evolve.md` defines a ticket creation workflow (Jira, Linear, etc.), use that.
Otherwise, default to `gh issue create` if `gh` CLI is available — include labels if the
project uses them (check existing issues for conventions).

If no ticket tool is available or the engineer skips, just leave the items in EVOLUTION.md —
they're still captured.

### Prep the Handoff

Generate the materials the engineer needs to ship:

**Suggested PR description:**

Since each slice is already committed, use `git log --oneline <base>..HEAD` to build the
Changes section from the actual commit history rather than reconstructing a narrative:

```markdown
## Summary
[What this PR does, tied to the problem statement from SPEC.md]

## Changes
[Built from git log — each slice commit tells the story]

## Decisions Made
[Non-obvious choices with rationale, from NAVIGATION.md]

## Testing
[What's tested per-slice + integration results from evolve]

## Follow-up
[Items deferred or discovered during implementation]
```

**Reviewer notes:** What should the reviewer pay attention to? What context do they need?
Pull this from CONTEXT.md's tribal knowledge — things a reviewer wouldn't know from just
reading the diff.

## Evolution 2: Agent

The agent (Claude + its configuration) should be more capable after every feature. This is
where VINE compounds — each feature makes the next one easier.

### CLAUDE.md Suggestions

Review everything you learned during this feature and suggest updates to CLAUDE.md (or the
project's equivalent configuration). These might include:

- **Coding conventions** discovered: "This project uses the repository pattern for all data
  access. New services should follow src/repositories/ for reference."
- **Architectural patterns**: "Feature flags are managed via src/config/flags.ts. All new
  features should be gated."
- **Testing conventions**: "Integration tests use the test database defined in docker-compose.test.yml.
  Always reset state between tests."
- **Tribal knowledge codified**: Things from CONTEXT.md that should be persistent project knowledge
  rather than living in one VINE session's artifacts.

Use `AskUserQuestion` with `multiSelect: true` to let the engineer batch their decisions on
which suggestions to accept. Max 4 options per question — if you have more suggestions, split
across multiple calls by category. Put the strongest recommendation first with "(Recommended)"
in its label.

For each accepted suggestion, draft the exact text to add. The engineer manages the file —
you draft, they commit.

### Convention Check for Created Artifacts

Before writing any persistent artifacts (CLAUDE.md entries, skills, commands, overlay updates),
verify they follow current project conventions:

1. Check existing examples first (read other CLAUDE.md entries, existing skills/commands)
2. Match the naming, structure, and style of what's already there
3. Flag inconsistencies to the engineer before writing — don't silently create artifacts that
   don't fit the project's patterns

### Skill Suggestions

Look at the workflow patterns from this feature:

- Did you and the engineer develop a repeatable workflow? (e.g., "every time we add a new provider,
  we do X, Y, Z" → that's a skill)
- Was there a boilerplate pattern? (e.g., "new API endpoints always need these 5 files" → scaffold skill)
- Did you write utility scripts during navigate that would be useful again?
- Is there a verification checklist specific to this domain that should be codified?

Describe each potential skill concisely:

> **Suggested skill: `add-provider`**
> When triggered: "add a new payment provider"
> What it does: Scaffolds the provider class, factory registration, tests, and config.
> Estimated value: Saves ~30 min per new provider, ensures consistency.

### Workflow Improvements

Reflect on how the VINE process itself went:

- Did any phase feel too heavy or too light?
- Were there moments where the handoff between phases was clunky?
- Did you wish you had information in one phase that you only got in another?

Note these for the engineer. They might want to customize VINE for their team.

If this cycle produced new skills, commands, or significant overlay changes, suggest running
`/vine:optimize` to update the workflow map and re-score descriptions:

> "This cycle [added new skills / changed commands / updated overlays]. Running `/vine:optimize`
> would update the workflow map in shared.md and check if descriptions still match well."

### Context Overlay Update Suggestions

Review what tools, agents, and patterns proved useful during this VINE cycle and suggest
updates to `.vine/context/`:

- Tools or agents that should be auto-invoked in future cycles (add to the navigate.md or evolve.md overlay)
- Validation commands that worked well (add to the navigate.md overlay)
- Conventions discovered that should apply to all future VINE work (add to the shared.md overlay)
- Domain-specific questions that should always be asked in verify (add to the verify.md overlay)

Use `AskUserQuestion` with `multiSelect: true` to let the engineer pick which overlay updates
to apply. For each accepted suggestion, write the update directly to the overlay file.

## Evolution 3: User

This section is about what the engineer contributed, not what they "learned." The engineer
shaped the implementation through their decisions, corrections, and domain knowledge. Capture
that contribution and update the profile if appropriate.

### Engineer Contributions

Review NAVIGATION.md for what the engineer brought to this cycle:

- Decisions that steered the implementation away from a worse path
- Domain knowledge that shaped the approach (from CONTEXT.md's tribal knowledge)
- Corrections to Claude's approach — these are the most valuable; they show where the
  engineer's judgment was load-bearing

Frame this as contribution, not education:

> "Your call to exclude status from the stance update avoided unnecessary complexity — the
> interaction surface principle you applied there is a clean design heuristic. The auto-accept
> addition to gearing turned a stylistic toggle into a real mode shift."

**Do not summarize what the engineer "learned."** If they explored something new, they know.
If they didn't, don't invent growth. If the cycle was routine work in their comfort zone,
say so and move on — not every feature is a learning experience.

### Update Engineer Profile

Based on the completed cycle, propose updates to `.vine/PROFILE.md`. This is the concrete,
persistent output of user evolution — the profile grows with each VINE cycle.

**Domain expertise update:**

Check the current feature's domain against the profile:

- **If the domain exists**: Consider whether the level should change based on what happened
  during this cycle. Did the engineer demonstrate deeper confidence? Did they struggle with
  areas that suggest the level was too high? Propose an update only if the level should change.
- **If the domain doesn't exist**: Propose adding it with a level based on what you observed
  during the cycle.
- **If no profile exists yet**: Offer to create `.vine/PROFILE.md` with an initial entry for
  this domain.

Use `AskUserQuestion` to present the proposed change:

> "Based on this cycle, I'd suggest updating your profile for the [domain] domain:"

Options (mutually exclusive):
1. "[proposed level] (Recommended)" — "[rationale based on cycle observations]"
2. "[alternative level]" — "[why this might also fit]"
3. "Keep current" — "Leave the profile as-is"
4. "Skip" — "Don't update the profile this time"

**Growth log entry:**

Ask the engineer if they want to add a growth log entry for this cycle. Don't draft one —
the engineer writes their own narrative:

> "Want to add a growth log entry for this cycle? It's a few bullet points on what stood
> out — your call whether anything is worth recording."

Use `AskUserQuestion`:
1. "Use your draft" — "I'll draft bullet points from the cycle; you can edit before saving"
2. "I'll write my own" — "I'll add the date/domain header, you fill in the bullets"
3. "Skip (Recommended)" — "Not every cycle needs a log entry"

Put "Skip" as recommended. Growth log entries should be the exception, not the default —
only when the engineer genuinely wants to record something. If they choose the draft option,
write bullet points focused on the engineer's contributions and decisions — not what they
"learned." Present the draft for editing before writing to the file.

For each accepted change, write the update to `.vine/PROFILE.md` directly. Create the file
if needed, using the format documented in `references/STATE.md`.

### Suggest Claude Memory Updates

Separately from profile updates, review the cycle for general preferences and interaction
patterns worth persisting in Claude's memory or CLAUDE.md. These are things that apply
beyond this specific domain — how the engineer likes to work, not what they know.

Examples of what to surface:
- Communication preferences: "Engineer prefers seeing the diff before hearing the rationale"
- Decision-making patterns: "Engineer consistently chooses simpler approaches over flexible ones"
- Learning style: "Engineer engages most when patterns are compared to ones they already know"
- Review preferences: "Engineer wants to see smaller code chunks more frequently"

Use `AskUserQuestion` with `multiSelect: true` to let the engineer pick which observations
to persist. For each accepted item, suggest the exact Claude memory entry or CLAUDE.md line.

> "These observations from this cycle might be worth saving to Claude's memory so they apply
> across future sessions:"

If no general preferences were discovered this cycle, skip this section — don't manufacture
observations. Domain-specific knowledge goes in the profile, not here.

### Distill Durable Decisions

This cycle produced *judgment* a cold reader can't recover from the code — why an approach won
over its alternatives, a hard-won gotcha. That judgment has a durable home: `.vine/knowledge/<domain>/`,
the committed, append-only ADR layer (format and the five properties in `references/STATE.md`,
"Durable Decisions & Gotchas"). This is the **fourth and last** of evolve's "where does this learning
go" homes; the routing rule below decides which learnings belong here versus the three you just handled.

**Routing rule (operative copy — canonical version in `references/STATE.md`, "Knowledge Boundary").**
Route each candidate learning to exactly one home, first match wins:

1. Regenerable from the code? (structure, where-is-X) → home it nowhere; it regenerates on demand.
2. Non-regenerable judgment or gotcha tied to a domain? → `.vine/knowledge/<domain>/` (**this step**).
3. Per-engineer depth or expertise? → `.vine/PROFILE.md` (handled in *Update Engineer Profile*).
4. Cross-phase VINE protocol / inter-phase routing? → `.vine/context/shared.md` (*Context Overlay Update*).
5. Repo fact every session needs, VINE or not? → `CLAUDE.md` (*CLAUDE.md Suggestions*).

The subtle cut is knowledge vs `CLAUDE.md`: a non-regenerable *judgment* a cold reader can't recover
from the code goes to knowledge; a *fact* every session needs to be told goes to `CLAUDE.md`.

**Mine candidates.** Read NAVIGATION.md (each slice's "Decisions made during implementation" and
"Learnings", plus any "Discovered Items") and CONTEXT.md (tribal knowledge, edge cases) for decisions
and gotchas that route to the knowledge home (item 2 above) — durable judgment tied to this feature's domain. A choice made over
a real alternative, or a gotcha that cost time to learn, is a candidate. A restatement of what the code
plainly shows is not.

**Let the engineer choose.** Present the mined candidates via `AskUserQuestion` (`multiSelect: true`)
so the engineer picks which become records. Proposing a record is
reviewer-ratifiable, so a headless run takes the recommended set and records the choice; an interactive
engineer decides directly. Batch into one call; if there are more than four candidates, split by
category across calls (Interaction Constraints, `shared.md`). **If no candidate rises to a durable
record, write nothing** — declining all is current behavior, fully backward-compatible.

**Write each accepted record.** One date-prefixed file per record under `.vine/knowledge/<domain>/`,
named `YYYY-MM-DD-<kebab-of-title>.md`, following the Nygard ADR template and the five properties from
`references/STATE.md`:
- Title is the decision as a declarative sentence (the filename slug derives from it).
- Self-contained Context a cold reader understands without session memory; gloss every reference.
- Status block: `Accepted — <date>` / `Source: <domain>/<feature-slug> · Actor: <who>` /
  `Supersedes: <old-slug>` (or `none`).

Follow the *Convention Check for Created Artifacts* above — match the existing records in the domain
(`ls .vine/knowledge/<domain>/`) before writing a new one.

**Supersession — the one sanctioned edit to an existing record.** If a new record replaces an existing
one, do both halves of the bidirectional link:
1. The new record carries `Supersedes: <old-slug>`.
2. Flip the *old* record's Status line from `Accepted — <date>` to `Superseded by <new-slug> — <date>`.

Edit the Status line **only** — never the old record's Context / Decision / Consequences. The body is
immutable; the single Status-line flip is the lone exception that keeps the layer append-only and
concurrent-safe (`references/STATE.md`, property 4). Without the flip, a cold reader landing on the old
record would trust a stale `Accepted` and never learn it was replaced.

**Records persist beyond the project.** These files live in `.vine/knowledge/<domain>/`, separate from
`.vine/projects/`. Resolving or archiving this project (below) never moves or deletes them — durable
judgment outlives the project that produced it.

## Write EVOLUTION.md

Compile everything into `.vine/projects/<domain>/<feature-slug>/EVOLUTION.md`:

```markdown
# Evolution Report: [Feature Name]
## Date: [YYYY-MM-DD]

### Product Evolution
#### Acceptance Criteria Results
[Pass/fail table]

#### Spec Deviations
[List with rationale]

#### Follow-Up Items
[Concrete backlog suggestions]

### Agent Evolution
#### CLAUDE.md Suggestions
[List with engineer's decisions: accepted/rejected/deferred]

#### Skill Suggestions
[Potential skills with trigger and description]

#### VINE Process Observations
[What worked, what to adjust]

### User Evolution
#### Engineer Contributions
[Decisions and domain knowledge that shaped the implementation]

#### Profile Updates
[Domain level changes and growth log entries — accepted/rejected]

#### Claude Memory Suggestions
[General preferences proposed — accepted/rejected/deferred]

### Handoff Package
#### PR Description
[Ready to paste]

#### Reviewer Notes
[Context for reviewers]

#### Commit Suggestions
[Suggested structure]

#### Multi-PR Summary (if PROJECT-MAP.md has Milestones)
[Table from PROJECT-MAP.md showing all phases, their PR numbers, and status.
 Gives reviewers of the final PR context on what shipped previously.]
```

## Phase Completion

Update PROJECT-MAP.md (if it exists) — set the evolve row to ✅ with today's date.

```
---
✅ vine:evolve complete → EVOLUTION.md written to .vine/projects/<domain>/<feature-slug>/EVOLUTION.md
📦 Handoff package ready:
   - PR description drafted
   - Reviewer notes compiled
   - [N] follow-up items for backlog
   - [N] CLAUDE.md suggestions for review
   - [N] potential skills identified

🌱 VINE cycle complete for [Feature Name].
   Three evolutions captured:
   - Product: [brief summary of quality state]
   - Agent: [brief summary of capability growth]
   - User: [brief summary of knowledge growth]
   - Profile: [updated/created/unchanged] (.vine/PROFILE.md)

   "Grow features on solid roots."
---
```

### Mark as Resolved

After presenting the completion block, offer to mark the project as resolved using
`AskUserQuestion`:

> "This VINE cycle is complete. Want to mark this project as resolved? Resolved projects
> are filtered out of future command prompts but stay accessible by explicit path."

Options (mutually exclusive):
1. "Mark resolved (Recommended)" — "Add .resolved marker to this project directory"
2. "Keep active" — "Leave the project in active state for now"

If the engineer chooses to resolve, write an empty `.resolved` file to
`.vine/projects/<domain>/<feature-slug>/.resolved`. Then consume any
`.vine/projects/<domain>/<feature-slug>/PAUSE.md` that still exists — the backstop delete. Evolve's
session-start consumption normally removed it already, so a PAUSE.md surviving to here appeared
*after* evolve began and its notes aren't necessarily stale: surface them to the engineer first,
then delete the file. Never delete it silently — the same surface-then-delete rule the other
consumption triggers follow (PAUSE.md lifecycle in `references/STATE.md`).

**Offer to archive (#56 — move resolved work out of the way).** Only when the engineer just resolved
the project, offer to archive it — move it to `.vine/projects/.archive/<domain>/<feature-slug>/`, which
preserves the artifacts but gets completed work fully out of the way (lifecycle in `references/STATE.md`,
"Project Lifecycle"). An active project is never archived. Use `AskUserQuestion`:

Options (mutually exclusive):
1. "Archive now (Recommended)" — "Move the project under `.vine/projects/.archive/`"
2. "Keep in place" — "Leave it resolved-but-unarchived; archive later by hand"

If the engineer archives, move the project directory — `git mv` when the repo tracks artifacts so
history follows, plain `mv` when untracked:

```
mkdir -p .vine/projects/.archive/<domain>
git mv .vine/projects/<domain>/<feature-slug> .vine/projects/.archive/<domain>/<feature-slug>
```

The move carries the artifacts only: PAUSE.md is already gone (consumed-once, deleted at resolve above),
and **`.vine/knowledge/<domain>/` records are never moved** — they're physically separate from
`.vine/projects/` and keep their own Accepted→Superseded lifecycle, so durable judgment outlives the
archived project. The *Commit Evolve Changes* step below then stages the artifacts at whichever path they
now live. Declining leaves the project resolved-but-unarchived — a fine terminal state.

### Commit Evolve Changes

After resolving (or choosing to keep active), commit the changes generated during the evolve
phase. What to stage follows the artifact-tracking rule (full breakdown in `references/STATE.md`
under *Committing Artifacts*):

- **CLAUDE.md** and **`.vine/context/`** overlay updates (if accepted) — ordinary tracked repo
  files; commit them whenever they change, regardless of the artifact-tracking choice.
- **EVOLUTION.md** and the **`.resolved`** marker (if resolved) — VINE artifacts; stage them
  **only when the repo tracks `.vine/` artifacts**. When artifacts are untracked (gitignored, or
  a personal scope) they update on disk but stay out of the commit.
- **`.vine/PROFILE.md`** updates (if accepted) — commonly gitignored (it's personal); stage only
  if the repo tracks it.

Never force-add a gitignored artifact. If the project was just archived, its artifacts now live
under `.vine/projects/.archive/<domain>/<feature-slug>/` — `git mv` already staged the rename, so
stage any post-move edits at that path. Stage the applicable files and commit with a message like:

```
evolve: [feature name] — evolution report and cycle artifacts

VINE cycle complete. Captures product verification, agent evolution
(CLAUDE.md/overlay updates), and user profile growth.
```

Present the commit message for the engineer's approval before committing.

### Suggest Opening a PR

After committing, suggest opening a PR using the handoff package drafted earlier. First, if
the cross-slice integration check captured CI status from prior phase PRs (`gh pr checks`),
restate any failing or still-pending checks here — don't suggest a handoff over red or
in-flight CI without the engineer seeing it. No-op if `gh` was unavailable or all checks passed.

> "Ready to open a PR? I have the description and reviewer notes drafted in EVOLUTION.md."

Use `AskUserQuestion`:

Options (mutually exclusive):
1. "Open PR (Recommended)" — "Create PR using the drafted description and reviewer notes"
2. "Skip" — "I'll handle the PR myself"

If the engineer chooses to open a PR, create it using `gh pr create` with the PR description
from the handoff package. If `.vine/context/evolve.md` defines PR workflow conventions, follow
those.

## Important Principles

**Verification is not a formality.** Actually check things. Run tests. Read the code against
the criteria. If something doesn't pass, say so. The engineer needs honest assessment, not
cheerleading.

**Agent evolution compounds.** Every CLAUDE.md update and every skill suggestion makes the
next VINE cycle faster and better. Take this seriously — it's the long game.

**User evolution requires tact.** You're reflecting back what someone learned, not evaluating
their performance. Be a mirror, not a teacher. If they didn't learn anything new, that's fine
— maybe this feature was in their comfort zone. Don't manufacture growth that didn't happen.

**The handoff is for humans.** PR descriptions, reviewer notes, and commit messages are read
by people. Write them clearly, with context, assuming the reader doesn't have VINE artifacts
in front of them.
