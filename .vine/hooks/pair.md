# VINE Pair Hooks — VINE Framework

## Validation Commands

- **Structural check**: Run `/trellis` if any command file was modified
- **Cross-reference check**: If changing a command file, verify references in CLAUDE.md, README.md, and shared.md are still accurate
- **Frontmatter check**: Ensure YAML frontmatter has exactly: name, description, argument-hint, allowed-tools

## Scope Guardrails

- Pair sessions on this repo often touch command files — changes ripple. If a "quick fix" needs updates in more than 2 command files, suggest escalating to the full VINE cycle.
- Doc updates (README, CLAUDE.md, STATE.md) triggered by command changes are in-scope for pair, but track them explicitly so nothing gets missed.

## Commit Conventions

- Commit messages should match the repo's style: imperative mood, reference issue numbers when applicable
- Single commit per pair session — if the change needs multiple commits, it's too big for pair
