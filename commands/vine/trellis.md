---
name: vine:trellis
description: "Validate structural conventions across VINE command files"
argument-hint: ""
allowed-tools:
  - Read
  - Glob
  - Grep
  - AskUserQuestion
---

# vine:trellis — Command Structure Validation

Validate that all VINE command files in `commands/vine/` follow the structural conventions
documented in CLAUDE.md. This is a VINE-repo-only tool — it validates the framework's own
command files.

## Step 1: Discover Command Files

Use Glob to find all `.md` files in `commands/vine/`. These are the command files to validate.
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

The first H1 heading (line starting with `# `) must follow the pattern:

```
# vine:<name> — <Subtitle>
```

Where `<name>` matches the `name` field from frontmatter (without the `vine:` prefix on the
left side — the full `vine:<name>` appears after `# `). The subtitle can be any text. The
em dash ` — ` (space, em dash, space) is required as the separator.

### Check 4: Load Project Hooks Section (non-init only)

**Skip this check for `init.md` and `trellis.md`** — init creates hooks and trellis is a
VINE-repo-only validation tool; neither loads project hooks.

The command must contain a `## Load Project Hooks` section. Within that section, the text must
reference `.vine/hooks/<phase>.md` where `<phase>` matches the command's stem name (e.g.,
`verify.md` must reference `.vine/hooks/verify.md`).

### Check 5: Load Engineer Profile Section (non-init/trellis only)

**Skip this check for `init.md` and `trellis.md`** — init introduces the profile concept but
doesn't load it; trellis is a structural validation tool that doesn't need profile context.

The command must contain a section with heading `## Load Engineer Profile` (or a heading that
starts with `## Load Engineer Profile`).

### Check 6: Allowed Tools Valid

Every entry in the command's `allowed-tools` list must appear in the known tool set derived
in Step 2. If a command introduces a tool name that no other command uses, that's fine — it
adds to the union. This check catches typos, not novel tools.

Since the known set is the union of all commands, this check effectively verifies that no
command has a tool name that appears in only that one command's list AND looks like a typo
of a known tool. In practice: verify the tools parse as a clean YAML list of strings.

### Check 7: AskUserQuestion Referenced

The string `AskUserQuestion` must appear somewhere in the command body (the content after
the closing `---` of the frontmatter). This confirms the command references the preferred
interaction pattern.

## Step 4: Format Results

Present results as a summary table with commands as rows and checks as columns:

```
| Command   | Frontmatter | Name | H1  | Hooks | Profile | Tools | AskUser |
|-----------|-------------|------|-----|-------|---------|-------|---------|
| init      | ✅          | ✅   | ✅  | skip  | skip    | ✅    | ✅      |
| verify    | ✅          | ✅   | ✅  | ✅    | ✅      | ✅    | ✅      |
| trellis   | ✅          | ✅   | ✅  | skip  | skip    | ✅    | ✅      |
| ...       |             |      |     |       |         |       |         |
```

Use `✅` for pass, `❌` for fail, `skip` for checks that don't apply (init exceptions).

After the table, print a summary line:

- If all checks pass: **"✅ N/N commands pass all checks"**
- If any check fails: **"❌ N issues found across M commands"** followed by a brief list of
  each failure with the command name, check name, and what was wrong.
