# VINE Verify Context Overlay — VINE Framework

## Areas to Always Explore

When verifying a feature for the VINE framework itself, always check:

- **Cross-phase consistency**: How does this change affect the contract between phases? Read `references/CONTRACTS.md` for artifact specs.
- **Skill file structure**: Check all 11 phase skills (`plugins/vine/skills/<name>/SKILL.md`) for patterns that relate to the feature area. Changes often ripple across phases.
- **README alignment**: Does the README describe behavior that this feature would change?
- **Issue templates**: Would this change affect how bugs, friction, or ideas are reported?

## Domain-Specific Questions

- Does this change affect the state artifact format? If so, what happens to existing `.vine/` directories in user projects?
- Does this change the AskUserQuestion patterns? Check consistency across all commands.
- Is this a change to a single phase or does it affect the chain protocol between phases?
