# Skill over-specification audit — proposed cuts (July 2026)

**Status: proposal only — nothing here has been applied.** Three independent audit passes
covered all 11 shipped skills (3,900 lines total), cross-checked against
`.vine/scripts/trellis-check.sh` so no proposed cut touches a load-bearing anchor, heading,
or template field. Evidence from live cold-runs of init and verify on a fresh sample repo
informed the init findings. Every proposal preserves all behavior and semantics; generated
files stay byte-identical unless flagged.

## Headline numbers

| File | Lines | Proposed reduction | Mechanism |
|---|---:|---:|---|
| init | 699 | ~78 in-file + ~243 moved to template files | trims + template extraction + trigger table |
| evolve | 652 | ~45 (7%) | trims |
| navigate | 590 | ~47 (8%) | trims |
| optimize | 491 | ~46 (9%) | trims (Knowledge Boundary rule stated 5×) |
| verify | 390 | ~19 (5%) | trims — broadly healthy |
| inquire | 360 | ~18 (5%) | trims |
| resume | 233 | ~29 (12%) | duplicate status template → delta prose |
| pair | 169 | ~17 (10%) | principles section restates its own steps |
| status | 124 | ~10 (8%) | inline profile-resolution → defer to shared.md |
| pause | 120 | ~7 (6%) | rationale trims |
| help | 78 | ~1 | already tight |
| **Total** | **3,906** | **~317 in-file + ~243 extracted** | |

## The three big levers (init)

**1. Extract the two inline templates to payload files (~243 lines).** The `shared.md`
template (lines 85–262) and the `.vine/README.md` template (lines 298–384) are not
instructions — they're payload the model transcribes. Move each to
`${CLAUDE_PLUGIN_ROOT}/skills/init/templates/…` (payload-internal paths are sanctioned by the
reference convention) and have Steps 3–4 say "write the file from the template, filling the
bracketed placeholders." Generated output stays byte-identical. Cold-run evidence: ~80% of
init execution effort was reading/transcribing framework text, ~20% doing anything
repo-specific. *Check first:* whether trellis needs a carve-out for skills referencing
sibling template files.

**2. Step 8 trigger table with a fresh-run fast path (~200 lines skipped, not read).**
All seven Step-8 subsections (legacy migration, track-by-default, upgrade mode, dedup,
CLAUDE.md pointer, npx cleanup, archive sweep) were no-ops on a fresh repo, but each had to
be read to establish that. Open Step 8 with a 7-row trigger table (condition → offer →
subsection) and the rule "on a fresh repo where no row matches, skip the rest of Step 8."
Caution: two triggers (CLAUDE.md pointer, npx cleanup) can fire on fresh repos too — the
table must encode triggers precisely, and row order must preserve the existing ordering
invariants (legacy migration first; relocate-before-flip).

**3. De-duplicate the offer/decline scaffolding (~36 lines).** The same
AskUserQuestion pattern (`multiSelect: false`, "X (Recommended)" / "Not now — nothing changes
on disk") and the same "declining is a no-op; the offer repeats next init" sentence appear
seven times each. State both once in the Step 8 preamble; keep per-section text only where it
carries unique semantics (e.g. legacy fallback continues on decline; Validation's decline
leaves prose inference). *Tension to weigh:* the repetition is arguably deliberate teeth
against silent-mutation-on-decline — a strongly-worded single rule preserves the guarantee,
but test a decline path after the edit.

## Cross-cutting patterns (all files)

- **shared.md deference is applied inconsistently.** ~35 lines in navigate/evolve alone
  restate Collaboration Stance, Interaction Constraints, or Next-Step Suggestions content
  that the same file elsewhere correctly references by name. Caveat: shared.md is optional
  in consuming repos, so stance-related cuts trade lines against behavior in shared.md-less
  installs — cut conservatively there.
- **"Important Principles" trailer sections restate their own file's steps.** optimize and
  pair both close with principles already embedded at the operative steps (pair: 4 of 5
  principles are verbatim repeats). inquire's are mostly unique — keep 3 of 4.
- **Development archaeology leaks into shipped text.** "(Slices 15–16)" in navigate,
  "reviewer-ratifiable / fully backward-compatible" spec-review language in evolve, an
  evolve example quoting VINE's own dev cycle ("exclude status from the stance update").
  Strict improvements to cut — they violate the repo's own Reference Legibility rule.
  (The two naked `#58` pointers found in init were already fixed in this branch.)
- **resume carries two ~80%-identical status templates** (with/without PAUSE.md); the second
  can become delta prose (~15 lines).
- **The overlay bootstrap parenthetical** ("apply-as-overlay precedence, the personal `.local`
  layer, …") is a gloss of shared.md section names repeated in all 10 loading skills
  (~2–3 lines each). If trimmed, do it as one uniform sweep across all skills or not at all.

## Flagged, no behavior-preserving fix (design decisions, not cuts)

- **Version-skew in generated shared.md:** ~140 lines of invariant framework machinery
  (personal-root resolution, Overlay Precedence, Interaction Constraints, Out-of-Scope
  Routing) are copied verbatim into every consuming repo, where they drift against the
  plugin as it evolves. Any de-embedding changes generated files → its own design cycle.
- **evolve line ~346: recommended option listed third** in the engineer-contribution
  question, conflicting with shared.md's recommended-first rule — pre-existing
  inconsistency, one-line fix but it changes an option order, so flagged rather than applied.
- **Cross-file operative copies** (e.g. the verification-tier note in both navigate and
  evolve) are the self-contained-skills convention working as designed — not flagged as cuts.

## Full per-finding detail

The three raw audit reports (finding-by-finding line ranges, replacement sketches, and risk
notes — 75+ findings) are preserved in the session transcript. This page carries every
decision-relevant item; ask Claude to expand any row into its full finding if you want the
exact replacement text before applying.
