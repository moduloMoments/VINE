# VINE Evolve Hooks — VINE Framework

## PR Workflow

- Create PRs via `gh pr create` using the repo's PR template
- Link to related GitHub Issues when applicable
- PR title should reflect the VINE phase perspective (e.g., "Improve verify phase context discovery")

## Follow-up Tracking

- File follow-up items as GitHub Issues using the appropriate template:
  - Bugs: `.github/ISSUE_TEMPLATE/bug_report.md`
  - Friction: `.github/ISSUE_TEMPLATE/friction_report.md`
  - Ideas: `.github/ISSUE_TEMPLATE/idea.md`
- Use GitHub Discussions for broader design questions or community input

## Dogfooding Feedback Loop

Since this repo uses VINE on itself, evolve phases should pay special attention to:
- **Meta-friction**: Did VINE feel awkward when used to modify VINE? That's a first-class signal.
- **Command self-reference**: Did modifying a command while that command was guiding the work create confusion?
- **Hook improvements**: Update these hook files based on what was learned during the cycle.

## CLAUDE.md & Documentation

- Check that `CLAUDE.md` exists and suggest updates based on conventions discovered or changed during the cycle.
- **Doc growth guardrail**: Before suggesting additions to CLAUDE.md, README, STATE.md, or PROJECT-MAP.md, check if existing content already covers the topic. Prefer updating existing sections over adding new ones. Flag when a document is growing beyond its useful scope — concise docs get read, long docs get ignored.
- **Doc accuracy check**: Verify that README.md and CLAUDE.md claims about command behavior match what the commands actually do. If a command's output, flow, or capabilities changed during this cycle, check whether the docs still describe it correctly. Stale docs are worse than missing docs.
