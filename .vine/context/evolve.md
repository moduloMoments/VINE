# VINE Evolve Context Overlay — VINE Framework

## PR Workflow

- Create PRs via `gh pr create` using the repo's PR template
- Link to related GitHub Issues when applicable
- PR title should reflect the VINE phase perspective (e.g., "Improve verify phase context discovery")

## Multi-PR Features

- **Confirm phase-group PRs before assuming you must open one.** For features with a Milestones
  table, run `gh pr list --state merged --search <feature-slug>` (or check the table's PR column
  against `git log origin/main`) at the start of evolve. A phase group can ship in a parallel
  session and leave PROJECT-MAP's PR cell stale (`—`), so evolve must verify against `main` rather
  than trust the tracker — otherwise it tries to re-open work that already merged, or worse, opens a
  PR from a now-stale branch that reverts later main commits.

## Follow-up Tracking

- File follow-up items as GitHub Issues using the appropriate template:
  - Bugs: `.github/ISSUE_TEMPLATE/bug_report.md`
  - Friction: `.github/ISSUE_TEMPLATE/friction_report.md`
  - Ideas: `.github/ISSUE_TEMPLATE/idea.md`
- Use GitHub Discussions for broader design questions or community input

## GitHub Issue Edits

When a cycle edits live issue bodies (reshaping, freshness passes):
- **Verify against the working tree before drafting** — issues old enough to predate a rename
  or refactor may have silently landed; close-as-landed beats a stale path fix.
- **Batch-draft all public edits and present them for review before any fires** — issue edits
  are live and unreviewed; the batch is the draft stage.
- **"No stale references" means a cold actor wouldn't act wrongly** — not zero occurrences of
  the old string. Historical/feature-naming mentions are compliant.

## Dogfooding Feedback Loop

Since this repo uses VINE on itself, evolve phases should pay special attention to:
- **Meta-friction**: Did VINE feel awkward when used to modify VINE? That's a first-class signal.
- **Command self-reference**: Did modifying a command while that command was guiding the work create confusion?
- **Overlay improvements**: Update these context overlay files based on what was learned during the cycle.

## CLAUDE.md & Documentation

- Check that `CLAUDE.md` exists and suggest updates based on conventions discovered or changed during the cycle.
- **Doc growth guardrail**: Before suggesting additions to CLAUDE.md, README, STATE.md, or PROJECT-MAP.md, check if existing content already covers the topic. Prefer updating existing sections over adding new ones. Flag when a document is growing beyond its useful scope — concise docs get read, long docs get ignored.
- **Doc accuracy check**: Verify that README.md and CLAUDE.md claims about command behavior match what the commands actually do. If a command's output, flow, or capabilities changed during this cycle, check whether the docs still describe it correctly. Stale docs are worse than missing docs.
