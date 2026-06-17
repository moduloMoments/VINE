# Decision Delegation sorts every prompt into default-able vs human-required

## Status

Accepted — 2026-06-16
Source: workflow/routing-foundation · Actor: Rob + Claude
Supersedes: none

## Context

For a VINE phase to run headless (an unattended actor executes; a reviewer checks after), every
`AskUserQuestion` decision point needs a rule for what the actor does with no human present.
Without one, a headless actor has only two bad options: stall on every prompt, or guess on all
of them. Neither is safe — some decisions (gearing, continuation) are trivially ratifiable after
the fact, while others (design sign-off, scope, blocker resolution) commit the work to a
direction expensive to reverse. #98 (headless autonomy contract: decision classes, handoff,
journal schema) is where this landed.

## Decision

Sort every decision into two classes, tagged at each `AskUserQuestion` site in the commands with
a `<!-- decision-class: ... -->` marker:

- **`default-able`** — the actor takes the recommended option (the first / "(Recommended)" one)
  and records it in NAVIGATION.md as a *Decision Taken Autonomously* with `(slice N)` attribution.
- **`human-required`** — the actor does not choose; it writes the structured Headless Handoff and
  stops in a clean committed state.

An untagged or genuinely ambiguous site defaults to `human-required` — escalation is always
safe, silent autonomy is not. The policy lives in `shared.md` as a **policy-class** section: the
personal `.local` layer cannot weaken it, but a *repo* overlay can reclassify a decision (the
intended team-level override path).

## Consequences

- Headless runs proceed autonomously on safe defaults and stop cleanly on consequential ones.
- **Interactive sessions are completely unaffected** — the section is inert; a human answers every
  prompt exactly as before.
- The per-site `decision-class` tags become a maintenance surface every command must carry and
  keep accurate; a mis-tagged site is a latent headless-safety bug.
- Pairs with ROUTE.md (the eligibility gate) — delegation governs *how* a decision is made once a
  scope is already authorized to run headless.
