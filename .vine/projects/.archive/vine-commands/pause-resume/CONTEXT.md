# Feature Context: vine:pause + vine:resume
## Date: 2026-03-27
## Author: Rob + Claude

### Codebase Landscape

**The product is 6 command files in `commands/vine/`.** Adding pause and resume brings it to 8. Each command follows strict structural conventions enforced by `/trellis`: YAML frontmatter, Load Project Hooks section, Load Engineer Profile section (except init), second-person instructional markdown, AskUserQuestion for all decision points.

**Artifact chain:** Features flow through `.vine/projects/<domain>/<feature-slug>/` as:
- `CONTEXT.md` (verify) -> `SPEC.md` (inquire) -> `NAVIGATION.md` (navigate) -> `EVOLUTION.md` (evolve)
- `.resolved` marker signals cycle completion
- `.vine/projects/.archive/` for long-term storage

**Directory scanning pattern** (identical in inquire/navigate/evolve):
1. Scan `.vine/projects/` for feature directories
2. Filter out `.resolved` and `.archive/`
3. If one active feature, use it; if multiple, AskUserQuestion to pick
4. If none active, suggest `vine:verify`

**Phase detection is implicit** — determined by which artifacts exist:
| Artifacts | State |
|---|---|
| None | Pre-verify |
| CONTEXT.md | Ready for inquire |
| CONTEXT.md + SPEC.md | Ready for navigate |
| CONTEXT.md + SPEC.md + NAVIGATION.md | Navigate in-progress or complete |
| All 4 | Evolve complete |
| .resolved | Cycle finished |

**Mid-navigate detection** requires cross-referencing NAVIGATION.md slice entries (with `Status: In Progress / Complete` and commit hashes) against SPEC.md's slice list. Navigate already does this for session resumption (navigate.md:83-87).

**Pair is artifact-free** — no state to pause or resume.

### Current State

**What works:**
- Phase chaining works via artifact presence — each command checks for prerequisites
- Navigate handles mid-session resumption by reading existing NAVIGATION.md
- The "continue or pause" prompt exists at navigate slice boundaries (navigate.md:273)
- Phase group boundaries are natural stopping points with `/clear` suggestions

**What's missing:**
- No explicit pause artifact — when an engineer stops, context is lost with the chat session
- Navigate's "Remaining Work" section (defined in STATE.md template) is never explicitly written by the navigate command
- No cross-feature dashboard showing status of all active VINE work
- No way to distinguish "stopped mid-navigate deliberately" from "navigate session crashed"

### Edge Cases & Tribal Knowledge

- **vine:pair leaves no trace** — resume should not try to detect or surface pair sessions
- **Phase groups in SPEC.md** — larger features split navigate into multiple sessions. Resume needs to detect which group is current.
- **CONDITIONAL slices** — SPEC.md can mark slices as conditional. Resume should surface whether conditions were met.
- **Command addition checklist** exists in shared.md — adding 2 commands requires updating CLAUDE.md, README.md, references/STATE.md, .vine/hooks/shared.md, .vine/hooks/verify.md

### Tech Debt in Affected Areas

1. **Navigate doesn't write "Remaining Work" section** — STATE.md's NAVIGATION.md template includes it, but the navigate command never instructs writing it. Severity: Low for existing usage, but matters for resume. Could be addressed as part of this feature.

2. **No explicit state machine** — phase detection is ad-hoc per command. Each command re-implements the same scanning/filtering logic. Not blocking, but resume adds another consumer of this pattern.

### Documentation Gaps

- README will need updating with 2 new commands (pause, resume)
- CLAUDE.md command count ("6 VINE command files") becomes 8
- STATE.md needs PAUSE.md artifact format
- .vine/hooks/shared.md command list needs updating
- .vine/hooks/verify.md references command count

### Open Questions

1. **PAUSE.md format** — What should the pause artifact contain? Minimum: current phase, active slice (if navigate), timestamp, free-form notes. Should it also snapshot the last few decisions/context from the session?

2. **Who writes PAUSE.md?** — vine:pause as a dedicated command, or should existing commands (navigate, inquire) offer to write it at natural stopping points? The dedicated command approach is cleaner; the integrated approach is more discoverable.

3. **Resume action** — Should resume just show status and recommend a command, or should it offer to launch the next command directly? (e.g., "You're mid-navigate on slice 3. Launch vine:navigate now?")

4. **Pause without resume** — If an engineer pauses but never resumes (starts a new feature instead), should PAUSE.md be cleaned up? Or is it harmless stale state?

5. **Allowed tools for resume** — Resume is read-only (just analyzes artifacts and shows status). It needs Read, Glob, Grep, AskUserQuestion. Pause needs Write to create PAUSE.md. Neither needs Edit, Bash, or Agent.

6. **Hook files** — Should there be `pause.md` and `resume.md` hook files, or are these simple enough to not need per-project customization?
