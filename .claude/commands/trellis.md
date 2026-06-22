---
name: trellis
description: "Lint and validate VINE command files — check frontmatter, section ordering, artifact format compliance, and structural conventions before committing"
argument-hint: ""
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
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

### Check 4: Load Context Overlays Section (non-init, non-help only)

**Skip this check for `init.md`** — init creates overlays rather than loading them.
**Skip this check for `help.md`** — help is a pure reference command that doesn't need project context.

The command must contain a `## Load Context Overlays` heading. Between that heading and the next
`##` heading, the text must contain the string `.vine/context/<phase>.md` where `<phase>` matches
the command's stem name (e.g., `verify.md` must contain `.vine/context/verify.md` in its
overlays section).

### Check 5: Load Engineer Profile Section (non-init, non-help only)

**Skip this check for `init.md`** — init introduces the profile concept but doesn't load it.
**Skip this check for `help.md`** — help is a pure reference command.

The command must contain a section with heading `## Load Engineer Profile` (or a heading that
starts with `## Load Engineer Profile`).

### Check 6: Section Ordering (non-init, non-help only)

**Skip this check for `init.md` and `help.md`.**

When both overlays and profile sections are present, the `## Load Context Overlays` heading must
appear before `## Load Engineer Profile` in the file. This matches the convention: load overlays
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

### Check 9: Legacy Reference Detection (warning-only)

Scan each command file for the string `.vine/hooks`. Legacy references are **warnings, not
failures** — they never affect a command's pass/fail status and have no column in the
Step 4 results table. Through 0.4.x, exactly two locations legitimately name the legacy
path. Allowlist them precisely:

1. **The fallback paragraph** (loading commands): the paragraph whose opening sentence
   begins "If `.vine/context/` doesn't exist but legacy `.vine/hooks/` does", including its
   nudge quote ("Heads up: this project uses the legacy `.vine/hooks/` directory — run
   `/vine:init` to migrate to `.vine/context/`."). Match the paragraph by its opening
   sentence, NOT by section position — a stray un-renamed reference elsewhere in the same
   Load Context Overlays section must still warn.
2. **init.md's Step 7 "Legacy Directory Migration" section**: every `.vine/hooks` reference
   between that heading and the next heading of equal or higher level. This section
   documents the migration offer and legitimately names the legacy path throughout 0.4.x.

Any `.vine/hooks` reference outside these two allowlisted locations produces a warning
recording the file, line number, and line text. When the 0.5 fallback removal lands, this
check (and both allowlist entries) is slated to harden to a failure.

### Check 10: Cross-Reference Anchors (repo-level)

The verification-tier contract spans three surfaces — `agents/vine-verification.md` (the
checklist), `commands/vine/navigate.md` and `commands/vine/evolve.md` (the tier pointers),
and `references/STATE.md` (the contract note) — held together by literal anchor strings.
This check verifies each anchor still resolves. It catches the drift class where a section
is renamed but its cross-references aren't updated (the stale "step 9" pointer this check
was born from).

Unlike Checks 1–8 this is repo-level, not per-command: it has no column in the Step 4 table
and is reported as its own line after the summary. A missing anchor is a **failure**, not a
warning — renaming an anchored section legitimately means updating the pair list, which is
exactly the sync act the old prose cross-references asked for but couldn't enforce.

Verify each file → anchor pair (literal substring match; the same list lives in
`.vine/scripts/trellis-check.sh` — keep the two lists identical):

| File | Expected anchor |
|------|-----------------|
| `references/STATE.md` | `**Verification-tier contract.**` |
| `agents/vine-verification.md` | `### Feature Verification (cross-change)` |
| `agents/vine-verification.md` | `**Phase-group scope**` |
| `agents/vine-verification.md` | `**Full-feature scope**` |
| `agents/vine-verification.md` | `**Base checks**` |
| `agents/vine-verification.md` | `**Cross-cutting checks**` |
| `commands/vine/navigate.md` | `verification-tier contract note` |
| `commands/vine/evolve.md` | `verification-tier contract note` |

The first six pairs confirm the pointed-at anchors exist (the contract note in STATE.md;
the mode and scope vocabulary in the agent). The last two confirm both commands still carry
their pointer to the contract note.

### Check 11: Naked Issue Pointers (warning-only)

Scan each command body for a bare issue pointer — `#<digits>` that is neither a markdown link
(`[#56](…)`) nor immediately followed by a parenthetical gloss (`#56 (archive resolved
projects)`). A naked pointer names a location without saying what's there, so a reader has to
dereference it; the gloss makes the reference legible to humans and self-checking for agents
(see `references/STATE.md`, "Reference Legibility"). These are **warnings, not failures** — they
never affect pass/fail and have no column in the Step 4 table.

The floor covers the product surface (command files). The same rule applies by convention to the
artifact chain and decision records, but enforcement there rides the writing commands, not this
linter — and never runs retroactively against immutable historical artifacts.

### Check 12: Personal-Root Resolution (repo-level)

The high-frequency profile and personal-overlay reads must resolve the **shared personal root**
via `dirname "$(git rev-parse --git-common-dir)"` before reading `.vine.local/PROFILE.md` /
`context/<name>.md`, never a bare cwd-relative `.vine.local/` read — which a linked git worktree
does not check out, so the read silently returns nothing (issue #132). The contract lives in
`.vine/context/shared.md`: a named helper, **Resolving the personal root**, defined once in the
Overlay Loading Protocol and referenced from the Personal-layer rule and the Engineer Profile
Protocol.

Like Check 10 this is repo-level, not per-command, and inspects only `.vine/context/shared.md`
(command files inherit the fix by deferring to these protocols). It asserts:

- the helper is defined — `.vine/context/shared.md` contains the literal `**Resolving the personal
  root.**`; and
- the `## Engineer Profile Protocol` section references `Resolving the personal root` (reverting it
  to a bare cwd-relative `.vine.local/PROFILE.md` read drops the phrase and trips the check).

A gap is a **failure** that counts toward pass/fail, mirroring Check 10. Skipped when `shared.md`
is absent (it is optional). The same two assertions live in `.vine/scripts/trellis-check.sh` — keep
them in sync.

## Step 4: Format Results

Present results as a summary table with commands as rows and checks as columns:

```
| Command   | Frontmatter | Name | H1  | Overlays | Profile | Order | Tools | AskUser |
|-----------|-------------|------|-----|----------|---------|-------|-------|---------|
| init      | ✅          | ✅   | ✅  | skip     | skip    | skip  | ✅    | ✅      |
| verify    | ✅          | ✅   | ✅  | ✅       | ✅      | ✅    | ✅    | ✅      |
| ...       |             |      |     |          |         |       |       |         |
```

Use `✅` for pass, `❌` for fail, `skip` for checks that don't apply (init exceptions).

After the table, print a command-specific summary line. Skipped checks count as passing
(they're intentional exceptions, not failures).

- If all checks pass: **"✅ N/N commands pass all checks"**
- If any check fails: **"❌ N issues found across M commands"** followed by a brief list of
  each failure with the command name, check name, and what was wrong.

After the summary line, print any legacy-reference warnings from Check 9:

```
⚠️ Legacy `.vine/hooks/` references (warnings — slated to harden to failures with the 0.5
fallback removal):
- <file>:<line> — <line text>
```

Omit the block entirely when there are no warnings. Warnings never change the pass/fail
summary line.

Print Check 11's naked-pointer warnings the same way, under their own header:

```
⚠️ Naked issue pointers (bare #<n> with no gloss — see STATE.md Reference Legibility):
- <file>:<line> — <line text>
```

Omit when empty; these never change the pass/fail summary either.

After the warnings, print the Check 10 anchor result as its own line:

- All anchors resolve: **"✅ Cross-reference anchors resolve (N pairs)"**
- Any missing: **"❌ N cross-reference anchor(s) missing"** followed by one line per missing
  pair (file and expected anchor). Unlike Check 9's warnings, anchor failures count toward
  the pass/fail status the stamp records (Step 8).

Then print the Check 12 personal-root result as its own line:

- Wired: **"✅ Personal-root resolution wired into shared.md (#132 guard)"**
- Any gap: **"❌ N personal-root resolution gap(s) in shared.md"** followed by one line per gap.
  Like Check 10, gaps count toward the pass/fail status.

The combined summary (covering both command and artifact results) is printed in Step 7.

## Step 5: Parse STATE.md and Discover Artifacts

This step builds the data needed for artifact validation in Step 6. If `references/STATE.md`
does not exist, print a warning and skip Steps 5–7 entirely — command validation (Steps 1–4)
always runs regardless.

### 5a: Parse Artifact Templates from STATE.md

Read `references/STATE.md`. Locate each artifact template by finding the `### <Name>.md`
headings under `## State Files` (CONTEXT.md, SPEC.md, NAVIGATION.md, EVOLUTION.md)
and under `## Per-Repo Artifacts` (PROFILE.md).

Each template is enclosed in a markdown code fence (` ```markdown ... ``` `). For each template:

1. Extract the content inside the code fence
2. Find all headings (lines starting with `##` or `###`) that have a `<!-- required -->` or
   `<!-- optional -->` marker on the same line
3. Record each heading's text (without the marker), heading level, and whether it's required
   or optional
4. Map these to the artifact type (CONTEXT, SPEC, NAVIGATION, EVOLUTION, PROFILE)

**Handling dynamic headings**: Some template headings contain placeholders like `[Name]` or
`[Feature Name]`. For validation purposes, treat these as pattern prefixes. For example,
`### Slice 1: [Name]` means "any heading matching `### Slice N: ...`". NAVIGATION and SPEC
slice headings are repeating entries — at least one must exist for the `required` marker to
be satisfied.

**Unmarked headings**: If a heading inside a code fence has no `<!-- required -->` or
`<!-- optional -->` marker, record it as a warning. This catches marker drift when someone
adds a section to a template without annotating it.

If STATE.md exists but the template structure can't be parsed (no code fences found, no
markers found at all), print a warning and skip Steps 6–7.

### 5b: Discover Artifacts

Use Glob to find all artifacts per the Filtering Convention in `references/STATE.md` (both roots):

- Look for `CONTEXT.md`, `SPEC.md`, `NAVIGATION.md`, `EVOLUTION.md` under `.vine/projects/*/*/`
  **and** `.vine.local/projects/*/*/` (domain/feature-slug directories)
- Look for `PROFILE.md` at `.vine.local/PROFILE.md`
- **Filter out**: any path containing `.archive/` and any directory containing a `.resolved` file
- For each discovered artifact, record its path and artifact type

If neither root has a `projects/` directory or no artifacts are found, record this — Step 7 will
handle the "no artifacts" case cleanly.

## Step 6: Validate Artifacts

Using the parsed section requirements from Step 5a and the discovered artifacts from Step 5b,
run the following checks against each artifact. Skip this step entirely if Step 5 was skipped
(STATE.md missing/unparseable) or no artifacts were discovered.

For each discovered artifact, run the applicable checks from the tiers below. Track pass/fail
results per check per artifact.

### Check A: Required Sections Present

**Applies to**: all artifact types (CONTEXT, SPEC, NAVIGATION, EVOLUTION, PROFILE)

For each section marked `<!-- required -->` in the artifact's STATE.md template, verify that
a matching heading exists in the actual artifact file.

- Match headings by heading level and text prefix. For example, the template's
  `### Codebase Landscape` matches `### Codebase Landscape` in CONTEXT.md.
- For dynamic headings (those with placeholders like `[Name]`), match the fixed prefix.
  For example, `### Slice 1: [Name]` matches any `### Slice N: <anything>` heading.
  NAVIGATION and SPEC slice headings are repeating — at least one must exist for the check
  to pass.
- Optional sections are not checked — their absence is fine.
- **Legacy SPEC heading hint**: `### Slice N:` (h3) is the canonical slice heading. If a SPEC
  has no `### Slice N:` heading but does contain `#### Slice N:` (h4) headings, report the
  failure as "legacy h4 slice headings — re-level `#### Slice` → `### Slice`" so the update
  path is obvious. (Older specs used h4; `vine:inquire` now emits h3.)

### Check B: PROFILE Table Structure

**Applies to**: PROFILE.md only

If a `## Domain Expertise` section exists (it's required per Check A), verify the markdown
table inside it:

1. **Columns**: The table header must contain exactly these columns: Domain, Level,
   Last Updated, Notes (in any order).
2. **Level values**: Every value in the Level column must be one of: `confident`, `familiar`,
   `learning`, `new`. Case-sensitive.

If the Domain Expertise section exists but contains no table, this check fails.

### Check C: SPEC Slice Fields

**Applies to**: SPEC.md only

Find all SPEC slice headings — any `### Slice N: ...` heading — regardless of layout (flat
under a `### Work Slices` umbrella, or grouped under `## Phase N:` group headings). A
conditional slice is one whose heading is suffixed `(CONDITIONAL)`.

For each slice, verify these fields are present as bold-prefixed items (with or without a
leading `-` list marker):

- `**Goal**`
- `**Depends on**`
- `**Files likely touched**`
- `**Acceptance criteria**`
- `**Complexity signal**`

A `(CONDITIONAL)` slice must also have a `**Condition**` field.

"Present" means the bold-prefixed item exists in the slice's content — between this slice's
heading and the next heading of equal or higher level (the next `### Slice N:`, a
`## Phase N:` group heading, or any higher-level section). The value after the colon can be
anything — this is a structural check, not a content check.

### Check D: NAVIGATION Slice Fields

**Applies to**: NAVIGATION.md only

Find all slice headings (`### Slice N: ...`) in the file. For each slice, determine its
status:

- **Complete**: The slice heading contains "Complete" (case-insensitive), OR the slice has a
  `**Commit**` field with a value that is not "pending".
- **Pending/In Progress**: Everything else — these slices are allowed to have incomplete fields.

For completed slices only, verify these fields are present as bold-prefixed list items:

- `**Started**`
- `**Commit**`
- `**Approach taken**`
- `**Validation**`
- `**Acceptance criteria**`

Pending or in-progress slices are not checked — NAVIGATION.md is built incrementally and
partial files are expected.

**Optional route fields — shape when present (#90 journal schema).** A completed slice may
also carry the optional `**Route**`, `**Actor**`, `**Gear**` fields and a token-led
`**Validation**`. These are `<!-- optional -->`: their **absence is never a failure** (a missing
`Route` reads as `interactive`, a missing `Actor` as `human`). Validate only the shape of fields
that *are* present:

- `**Route**`, if present, uses exactly one of the closed vocabulary `interactive | headless`,
  followed by a `` `mechanism: ...` `` token (value may be `n/a`). The vocabulary
  is closed so the field stays machine-comparable across journals.
- `**Gear**`, if present, is one of `free-climb` or `walk-me-through`.
- `**Validation**` leads with a bare `pass` or `fail` token before any details.

Like Check 11's naked-pointer floor, this shape check **does not run retroactively against
immutable historical journals** — apply it to entries written under the current schema; a
pre-#90 entry that records validation as free prose is not a failure.

### Check E: Validation Block Shape (repo-level, when present)

**Applies to**: `.vine/context/shared.md` — repo-level, not a per-artifact check (so it has no
column in the Step 7 table; report it as its own line like Check 10).

When a `## Validation` block is present, verify it is a fenced YAML block whose keys are drawn
only from the documented set — `lint`, `typecheck`, `test`, `test-all`, `build`, `extra` — and
that `extra` (if present) is a list. An unknown key or a malformed block fails. **Absence is not
a failure**: a repo with no `## Validation` block falls back to prose inference (the contract is
optional, per `references/STATE.md`), so the check simply doesn't run.

Like all of Steps 5–7, Check E and the optional-route-field shape check are
**session-judged and do not gate the `.vine/.trellis-ok` stamp** (Step 8).

## Step 7: Format Artifact Results

Present artifact validation results after the command checks from Step 4. This step produces
output regardless of whether artifacts were found — the section should always appear so
contributors know artifact validation ran.

### Case 1: STATE.md Missing or Unparseable

If Step 5 was skipped, print:

```
## Artifact Validation

⚠️  Skipped — references/STATE.md is missing or could not be parsed.
Command validation results above are unaffected.
```

### Case 2: No Artifacts Found

If Step 5 ran but no artifacts were discovered in either projects root and no `.vine.local/PROFILE.md`
exists, print:

```
## Artifact Validation

No artifacts found in .vine/projects/, .vine.local/projects/, or .vine.local/PROFILE.md — nothing to validate.
This is expected if no VINE cycles have been run in this repo.
```

### Case 3: Artifacts Found

Print a results table with artifacts as rows and checks as columns:

```
## Artifact Validation

| Artifact                              | Sections | Table | Slice Fields | Nav Fields |
|---------------------------------------|----------|-------|--------------|------------|
| .vine.local/PROFILE.md                | ✅       | ✅    | —            | —          |
| .vine/projects/auth/login/CONTEXT.md  | ✅       | —     | —            | —          |
| .vine/projects/auth/login/SPEC.md     | ✅       | —     | ✅           | —          |
| .vine/projects/auth/login/NAV...md    | ✅       | —     | —            | ✅         |
| ...                                   |          |       |              |            |
```

Column mapping:
- **Sections** → Check A (applies to all)
- **Table** → Check B (PROFILE only)
- **Slice Fields** → Check C (SPEC only)
- **Nav Fields** → Check D (NAVIGATION only — includes the optional route-field shape check)

Use `✅` for pass, `❌` for fail, `—` for not applicable (the check doesn't apply to this
artifact type).

After the table, print any unmarked heading warnings from Step 5a (headings in STATE.md
templates that lack a `<!-- required -->` or `<!-- optional -->` marker).

Then print the Check E result as its own repo-level line (like Check 10's anchor line):

- `## Validation` block present and well-formed: **"✅ Validation block valid (N keys)"**
- Present but malformed (unknown key, or `extra` not a list): **"❌ Validation block: <what was
  wrong>"**
- Absent: **"— Validation block: none (prose-inference fallback)"** — not a failure.

### Combined Summary

After both the command table (Step 4) and artifact table (Step 7), print a combined summary:

- If everything passes: **"✅ All checks pass — N commands, M artifacts validated"**
- If only command checks fail: **"❌ N command issues found (artifact validation passed)"**
- If only artifact checks fail: **"❌ N artifact issues found (command validation passed)"**
- If both fail: **"❌ N command issues + M artifact issues found"**

Follow any failure summary with the detailed list of failures (command name or artifact path,
check name, what was wrong).

If all checks pass and there are uncommitted changes to command files, suggest:

> "All checks pass. If you're ready to submit, run `/pr` to create a pull request."

## Step 8: Stamp the Run (script-owned)

Do **not** write `.vine/.trellis-ok` yourself. The stamp is produced mechanically by the
check engine so it can't be confused with a hand-written pass ticket — run it with Bash:

```
sh .vine/scripts/trellis-check.sh
```

The script re-runs the command checks (Steps 1–4) mechanically over `commands/vine/*.md` —
including the repo-level Check 10 anchor pairs — and writes `.vine/.trellis-ok` (gitignored
via `.vine/*`) itself — `status: pass` and exit 0 on a green run, `status: fail` and exit 1
otherwise (a failed anchor pair flips it like any command check), overwriting any previous
stamp so a red tree can't ride through the gate on a stale green. The contributor trellis
gate (`.vine/scripts/trellis-gate.sh`, wired in this repo's `.claude/settings.json`) reads
that stamp before allowing commits that touch `commands/vine/` — a green script run is the
commit ticket for command changes.

If the script's verdict disagrees with your Step 4 results, the script wins for gating
purposes — report the divergence to the contributor, since it usually means a check has
drifted between this skill and `trellis-check.sh` and the drift itself needs fixing.

Scope notes: warnings (legacy references, unmarked headings) do not block a pass stamp.
Artifact validation failures don't either — artifacts are often work-in-progress journals,
and gating command commits on artifact state would block unrelated work. The stamp certifies
command structure and cross-reference anchors only; **all of Steps 5–7 stays session-judged and
is not stamped** — including the optional route-field shape check (D) and the repo-level
Validation-block check (E, which reads `.vine/context/shared.md`). The script never reads those
surfaces, so adding or malforming a route field or the Validation block can never block a command
commit.
