# VINE Verify Hooks — VINE Framework

## Areas to Always Explore

When verifying a feature for the VINE framework itself, always check:

- **Cross-phase consistency**: How does this change affect the contract between phases? Read `references/STATE.md` for artifact specs.
- **Command file structure**: Check all 8 command files for patterns that relate to the feature area. Changes often ripple across phases.
- **README alignment**: Does the README describe behavior that this feature would change?
- **Issue templates**: Would this change affect how bugs, friction, or ideas are reported?

## Domain-Specific Questions

- Does this change affect the state artifact format? If so, what happens to existing `.vine/` directories in user projects?
- Does this change the AskUserQuestion patterns? Check consistency across all commands.
- Is this a change to a single phase or does it affect the chain protocol between phases?
