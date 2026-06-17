# ROUTE.md is the per-scope headless-eligibility gate record

## Status

Accepted — 2026-06-16
Source: workflow/routing-foundation · Actor: Rob + Claude
Supersedes: none

## Context

Deciding whether a scope may run headless depends on facts that decay fast — chiefly whether the
in-scope slices are independent of in-flight work, and whether their blast radius is bounded. In
the cycle-0 spike the independence leg decayed within hours as other PRs opened. A verdict
computed once and trusted later is therefore unsafe, and a reviewer checking a headless run after
the fact needs to see what was actually true at authorization time, not re-derive it. #97 (routing
gate: ROUTE.md record + navigate-head eligibility gate) is the PR that introduced the record.

## Decision

`vine:navigate` runs an eligibility gate once at navigate-head and writes `ROUTE.md` to the
feature directory. The record carries the verdict (`interactive` | `headless`), the four-leg
predicate results (validation contract, slice ACs, independence, bounded blast radius), the
allowlist, the validation baseline, the constraints a headless actor must honor, and the **input
basis** — `HEAD SHA` plus the in-flight set considered — under a `Computed at:` stamp. The
**interactive route is the default and is never gated**: graceful absence (no ROUTE.md) means
interactive, so an ordinary human-driven session is unchanged. The volatile legs (independence,
blast radius) are recomputed against fresh repo state on every evaluation and re-evaluation; a
stale stamp stays visible in git history for drift review.

## Consequences

- Headless authorization is **durable and reviewer-legible** — a reviewer compares
  authorization-time state (the stamp + input basis) against execution-time state without
  re-deriving the verdict.
- **Interactive flow is untouched**; the gate withholds only the *headless option* when a leg is
  missing, never blocking or degrading interactive work.
- ROUTE.md joins the artifact chain between SPEC.md and NAVIGATION.md as an **optional,
  gracefully-absent** record; PROJECT-MAP's Route table is a derived pointer to it, not a second
  source of truth.
- Touching a file outside the recorded allowlist is itself an escalation — the bounded blast
  radius *is* the authorization.
