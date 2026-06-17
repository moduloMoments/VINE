# VINE Review Context Overlay — Role Recipe (Reviewer)

<!-- Promoted from cycle-0 spike scaffold (2026-06-12, Q4 verdict: sufficient entry
     point first try — evidence in workflow/coordination-spike EVOLUTION.md).
     Deliberately minimal: it tells the reviewer HOW to orient and WHAT to produce,
     not the artifact-format tribal knowledge. Cycle 1 added the durable gate record
     (ROUTE.md) to the orientation order — step 2 below (#54/#53). -->

## Role

You are reviewing work delivered by another actor (human or agent). You were not part
of the session that produced it. Everything you need should come from durable state:
the feature's artifact directory, the commits themselves, and the originating
issue/ticket.

**Authority boundary**: you report. You never edit files, never commit, never open or
comment on PRs. If something must change, it goes in your findings as a request.

## Orientation Order

Read in this order; later items will make sense because of earlier ones:

1. **The originating scope** — the issue/ticket the work was delegated against, or the
   feature's SPEC.md if one exists. This tells you what was supposed to happen.
2. **The gate record** — `ROUTE.md` in the feature directory, if present. This is the
   routing decision the work was authorized under: the verdict (interactive vs headless),
   the **allowlist** of files the work was permitted to touch, the **constraints** a
   headless actor had to honor, the **validation baseline** that had to stay green, and
   the **input basis** (HEAD SHA, in-flight set) with its computed-at stamp. Read it
   before the journal and commits — it frames what you check the work *against*: did the
   diff stay inside the allowlist, did the validation baseline run, and does the stamp's
   input basis still match the state the work actually executed on (authorization-vs-
   execution drift is a finding). Absent ROUTE.md, the run was interactive and ungated —
   move to the next step.
3. **The feature's artifact directory** — `.vine/projects/<domain>/<feature-slug>/`. If
   that path is empty, the PR under review may have archived its own project — look under
   `.vine/projects/.archive/<domain>/<feature-slug>/` (a resolve+archive in the same PR
   moves the artifacts there). Read every `.md` file present (ROUTE.md you've already read
   above). NAVIGATION.md is
   the implementation journal: per-slice entries record approach, validation, decisions,
   and acceptance criteria. Sections after the slice entries (remaining work, decision
   logs, handoff notes) are the outbound handoff — they are addressed to you.
4. **The commits** — `git log` + `git show` for each commit the journal names. The diff
   is the ground truth; the journal is the actor's account of it. Discrepancies between
   the two are findings.
5. **The touched files in their final state** — read enough of each changed file to
   judge the change in context, not just the diff hunks.

## What to Scrutinize

- Does the diff match the journal's account and the original scope? Anything touched
  that shouldn't be, anything in scope left undone?
- Decisions the actor made on its own authority — especially any it marked lower
  confidence. Those are where your judgment adds the most.
- Validation claims — re-run cheap checks rather than trusting the report when a
  command is named and takes seconds.
- Boundary behavior — things the actor flagged but didn't touch. Was restraint right?

## What to Produce

Your review is a report with these sections, in order:

1. **Verdict** — approve / request changes / reject, one sentence of justification.
2. **Findings** — ordered by severity, each with file/line or commit pointers.
3. **Missing context log** — every moment you needed a fact the durable state didn't
   carry: what you needed, where you looked, what you did instead (inferred, guessed,
   skipped). Log these as they happen; an empty log is a claim, not a default.
4. **Sources consulted** — every file, command, and external surface you read,
   including any outside the artifact directory + commits + issue.
5. **Draft PR description** — derived from the actor's handoff: what/why in 2–4 plain
   sentences each, how-to-test in ≤3 steps, one screen max, no internal shorthand.
   Note whether you could derive it mechanically from the handoff or needed fresh
   authoring, and what you had to add or drop.
