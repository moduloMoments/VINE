# VINE Navigate Hooks — VINE Framework

## After Code Changes

- Re-read any modified command file in full to verify the change didn't break the document flow
- Check that YAML frontmatter is still valid (name, description, argument-hint, allowed-tools)
- If modifying state artifact formats, verify `references/STATE.md` is updated to match

## Validation Commands

- **Markdown lint**: `npx markdownlint-cli2 "commands/vine/*.md" "references/*.md" "README.md"` (once configured)
- **Link check**: Verify any cross-references between files still resolve
- **Frontmatter check**: Ensure all command files have valid YAML frontmatter with required fields

## Pre-Evolve Check

- Run `/trellis` after completing all slices to validate command structure and artifact format compliance before evolve. Catches structural issues earlier than waiting for the evolve phase.

## Domain-Specific Validation

- If changing a phase command: mentally trace a feature through the full chain (verify -> inquire -> navigate -> evolve) to confirm the change doesn't break handoff
- If changing STATE.md: check that all commands that produce or consume that artifact section are updated
- If modifying command files: preserve the "Load Engineer Profile" block (after hooks). If adding new sections, place them after profile loading.
