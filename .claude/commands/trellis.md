---
name: trellis
description: "Validate structural conventions across VINE command files"
argument-hint: ""
allowed-tools:
  - Read
  - Glob
  - Grep
  - AskUserQuestion
---

# trellis — Command Structure Validation

Validate that all VINE command files in `commands/vine/` follow the structural conventions
documented in CLAUDE.md. This is a contributor-only tool — it validates the framework's own
command files but is not part of the distributed VINE product.

## Step 1: Discover Command Files

Use Glob to find all `.md` files in `commands/vine/`. These are the VINE command files to validate.

Read each file in full — you'll need the complete contents for all checks.

## Step 2: Build the Known Tool List

Before validating individual commands, derive the set of valid tool names by collecting the
union of all `allowed-tools` entries across every command file. A tool name is valid if any
command uses it. Store this set for use in Step 3.

## Step 3: Validate Each Command

For each command file, run the following checks. Track pass/fail results per check per command.

### Check 1: YAML Frontmatter Present

The file must start with `---` on line 1, followed by YAML content, followed by a closing `---`.
The frontmatter must contain exactly these four fields:
- `name`
- `description`
- `argument-hint`
- `allowed-tools`

If any field is missing, this check fails. If extra fields are present, this check fails.

### Check 2: Name Matches Filename

The `name` field must equal `vine:<stem>` where `<stem>` is the filename without the `.md`
extension. For example, `verify.md` must have `name: vine:verify`.

### Check 3: H1 Title Format

The first line starting with `# ` (after the frontmatter closing `---`) must follow this pattern:

```
# vine:<stem> — <Subtitle>
```

Where `<stem>` is the filename without `.md` (e.g., `verify.md` → `# vine:verify — ...`).
The subtitle can be any text. The separator must be ` — ` (space, em dash, space) — not a
hyphen, not a dash without spaces.

### Check 4: Load Project Hooks Section (non-init only)

**Skip this check for `init.md`** — init creates hooks rather than loading them.

The command must contain a `## Load Project Hooks` heading. Between that heading and the next
`##` heading, the text must contain the string `.vine/hooks/<phase>.md` where `<phase>` matches
the command's stem name (e.g., `verify.md` must contain `.vine/hooks/verify.md` in its hooks
section).

### Check 5: Load Engineer Profile Section (non-init only)

**Skip this check for `init.md`** — init introduces the profile concept but doesn't load it.

The command must contain a section with heading `## Load Engineer Profile` (or a heading that
starts with `## Load Engineer Profile`).

### Check 6: Section Ordering (non-init only)

**Skip this check for `init.md`.**

When both hooks and profile sections are present, the `## Load Project Hooks` heading must
appear before `## Load Engineer Profile` in the file. This matches the convention: load hooks
first (they may affect how the rest of the command behaves), then load the profile.

### Check 7: Allowed Tools Valid

The `allowed-tools` field must be a YAML list of strings (each prefixed with `  - `). Verify:

1. **Well-formed**: Each entry is a single capitalized word (e.g., `Read`, `AskUserQuestion`),
   not a sentence or path.
2. **Non-empty**: At least one tool is listed.
3. **Known**: Each tool appears in the known tool set derived in Step 2 (the union across all
   commands). Since the union includes every command's tools, a tool that only one command uses
   is still valid — this check catches misspellings, not novel tools.

### Check 8: AskUserQuestion Referenced

The string `AskUserQuestion` must appear somewhere in the command body (the content after
the closing `---` of the frontmatter). This confirms the command references the preferred
interaction pattern.

## Step 4: Format Results

Present results as a summary table with commands as rows and checks as columns:

```
| Command   | Frontmatter | Name | H1  | Hooks | Profile | Order | Tools | AskUser |
|-----------|-------------|------|-----|-------|---------|-------|-------|---------|
| init      | ✅          | ✅   | ✅  | skip  | skip    | skip  | ✅    | ✅      |
| verify    | ✅          | ✅   | ✅  | ✅    | ✅      | ✅    | ✅    | ✅      |
| ...       |             |      |     |       |         |       |       |         |
```

Use `✅` for pass, `❌` for fail, `skip` for checks that don't apply (init exceptions).

After the table, print a summary line. Skipped checks count as passing (they're intentional
exceptions, not failures).

- If all checks pass: **"✅ N/N commands pass all checks"**
- If any check fails: **"❌ N issues found across M commands"** followed by a brief list of
  each failure with the command name, check name, and what was wrong.

## Step 5: Parse STATE.md and Discover Artifacts

This step builds the data needed for artifact validation in Step 6. If `references/STATE.md`
does not exist, print a warning and skip Steps 5–7 entirely — command validation (Steps 1–4)
always runs regardless.

### 5a: Parse Artifact Templates from STATE.md

Read `references/STATE.md`. Locate each artifact template by finding the `### <Name>.md`
headings under `## State Files` (CONTEXT.md, SPEC.md, NAVIGATION.md, EVOLUTION.md) and
under `## Per-Repo Artifacts` (PROFILE.md).

Each template is enclosed in a markdown code fence (` ```markdown ... ``` `). For each template:

1. Extract the content inside the code fence
2. Find all headings (lines starting with `##` or `###`) that have a `<!-- required -->` or
   `<!-- optional -->` marker on the same line
3. Record each heading's text (without the marker), heading level, and whether it's required
   or optional
4. Map these to the artifact type (CONTEXT, SPEC, NAVIGATION, EVOLUTION, PROFILE)

**Handling dynamic headings**: Some template headings contain placeholders like `[Name]` or
`[Feature Name]`. For validation purposes, treat these as pattern prefixes. For example,
`### Slice 1: [Name]` means "any heading matching `### Slice N: ...`". NAVIGATION slice
headings are repeating entries — at least one must exist for the `required` marker to be
satisfied.

**Unmarked headings**: If a heading inside a code fence has no `<!-- required -->` or
`<!-- optional -->` marker, record it as a warning. This catches marker drift when someone
adds a section to a template without annotating it.

If STATE.md exists but the template structure can't be parsed (no code fences found, no
markers found at all), print a warning and skip Steps 6–7.

### 5b: Discover Artifacts

Use Glob to find all artifacts in `.vine/projects/`:

- Look for `CONTEXT.md`, `SPEC.md`, `NAVIGATION.md`, `EVOLUTION.md` under
  `.vine/projects/*/*/` (domain/feature-slug directories)
- Look for `PROFILE.md` at `.vine/PROFILE.md`
- **Filter out**: any path containing `.archive/` and any directory containing a `.resolved` file
- For each discovered artifact, record its path and artifact type

If no `.vine/projects/` directory exists or no artifacts are found, record this — Step 7 will
handle the "no artifacts" case cleanly.
