# Contributing to VINE

Thanks for your interest in VINE! The project is early and the architecture is still settling, so the most valuable contributions right now are **feedback, bug reports, and ideas** rather than large code changes.

## Best ways to contribute

### Open an issue first

Before writing code, open an issue to discuss what you have in mind. This prevents wasted effort if the direction doesn't align with where VINE is heading.

Good issue topics:

- **Bug reports** — a command broke, produced unexpected output, or lost state
- **Friction reports** — something felt awkward or confusing during a VINE cycle
- **Ideas** — new phase behaviors, hook patterns, or workflow improvements
- **Questions** — if something isn't clear, that's a docs bug

### Share your experience

The most useful feedback right now is hearing how VINE works (or doesn't) in real codebases. If you've tried it, tell us:

- What kind of project did you use it on?
- Which phases worked well? Which felt off?
- What did you add to your `.vine/hooks/` to make it work for your repo?

## Pull requests

For small fixes (typos, broken formatting, clarifying wording), a PR without an issue is fine.

For anything larger, **please open an issue first** so we can discuss the approach. The command architecture is still evolving, and a conversation upfront saves everyone time.

When submitting a PR:

- Branch from `main`
- Keep changes focused — one concern per PR
- Run `/vine:trellis` to validate structural conventions across command files
- Test the commands in an actual VINE cycle if you're changing behavior
- Describe what you changed and why in the PR description

## What's not ready for contribution yet

These areas are actively being shaped and aren't ready for outside PRs:

- New phases or commands
- Changes to the core phase flow or state model
- CI/automation infrastructure

If you have ideas in these areas, open an issue — the discussion is welcome even if the code isn't yet.

## Code of conduct

Be kind, be constructive. We're all figuring this out together.

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).
