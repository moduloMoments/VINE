# VINE Navigate Context Overlay — VINE Framework

## After Code Changes

- Re-read any modified skill file in full to verify the change didn't break the document flow
- Check that YAML frontmatter is still valid (description, argument-hint, allowed-tools, disable-model-invocation; no `name`)
- If modifying state artifact formats, verify `references/CONTRACTS.md` is updated to match

## Validation Commands

- **Markdown lint**: `npx markdownlint-cli2 "plugins/vine/skills/*/SKILL.md" "references/*.md" "README.md"` (once configured)
- **Link check**: Verify any cross-references between files still resolve
- **Frontmatter check**: Ensure all command files have valid YAML frontmatter with required fields

## Pre-Evolve Check

- Run `/trellis` after completing all slices to validate command structure and artifact format compliance before evolve. Catches structural issues earlier than waiting for the evolve phase.

## Domain-Specific Validation

- If changing a phase skill: mentally trace a feature through the full chain (verify -> inquire -> navigate -> evolve) to confirm the change doesn't break handoff
- If changing CONTRACTS.md: check that all skills that produce or consume that artifact section are updated
- If modifying skill files: preserve the "Load Engineer Profile" block (after the Load Context Overlays section). If adding new sections, place them after profile loading.
