# Feature Context: Durable Decisions Convention (wiring)
## Date: 2026-06-16
## Author: Rob + Claude

### Codebase Landscape

This is ROADMAP Cycle 2 ("Durable decisions convention" — [ROADMAP.md:148](../../../../ROADMAP.md), a Light
cycle). The **record format already exists** — it was written into the spec by the brain-descope
work ([#96](https://github.com/moduloMoments/VINE/pull/96)). What's missing is the **command
wiring**. Modules involved:

- **`references/STATE.md`** — already defines the convention:
  - "Durable Decisions & Gotchas" ([STATE.md:455](../../../../references/STATE.md)) — the
    `.vine/knowledge/<domain>/<slug>.md` layout, the Nygard ADR template (Title / Status / Context /
    Decision / Consequences), the five properties, tracked-by-default.
  - "Knowledge Boundary" ([STATE.md:502](../../../../references/STATE.md)) — the four-home table
    (CLAUDE.md / native skill list / shared.md / phase overlay) plus the forward reference to
    `.vine/knowledge/` at line 526.
  - "Reference Legibility" ([STATE.md:575](../../../../references/STATE.md)) — gloss-on-first-mention;
    enforcement "rides the writing commands, not the linter."
  - "Project Lifecycle" ([STATE.md:601](../../../../references/STATE.md)) — active → resolved →
    archived already defined; `.resolved` marker and `.archive/` filtering already documented.
- **`commands/vine/evolve.md`** — the writer. Already has three "where does this learning go"
  flows: CLAUDE.md Suggestions ([evolve.md:210](../../../../commands/vine/evolve.md)), Context
  Overlay Update Suggestions ([evolve.md:276](../../../../commands/vine/evolve.md)), and Profile
  growth. Adds `.vine/knowledge/` as a fourth. Resolution + `.resolved` write live in
  [evolve.md:464](../../../../commands/vine/evolve.md) (where the #56 archive-move offer attaches).
- **`commands/vine/verify.md`** — the reader. Globs the domain's records before exploring and
  surfaces (never auto-trusts) contradictions. No knowledge-glob step exists today.
- **`README.md`** — must document the layer, its commit-by-default stance, and active → resolved →
  archived.
- **`.claude/commands/trellis.md`** — checked, but **no new check this cycle** (steered below).

### Current State

- `.vine/knowledge/` does not exist on disk. No command reads or writes it.
- The format spec is complete and shipped; this cycle is pure wiring + a small spec-consistency fix.
- Cycle 1 (routing foundation, [#97](https://github.com/moduloMoments/VINE/pull/97)–[#100](https://github.com/moduloMoments/VINE/pull/100))
  just landed: shared.md's "Decision Delegation" section (policy-class routing criteria) and
  ROUTE.md (the per-scope eligibility gate record). That's the substrate evolve's routing-criteria
  calibration plugs into.
- Backward compatibility (the roadmap's hard gate): absent `.vine/knowledge/` files → exactly
  current behavior. No migration. #51 confirms this.

### Edge Cases & Tribal Knowledge

- **Supersession is bidirectional, and the spec is currently inconsistent about it.** Nygard
  practice: the new record carries `Supersedes: <old-slug>`, AND the old record's Status flips from
  `Accepted` to `Superseded by <new-slug>`. STATE.md property 4 ("supersede, don't edit",
  [STATE.md:471](../../../../references/STATE.md)) describes only the new record's back-link, but the
  template's Status comment ([STATE.md:483](../../../../references/STATE.md)) shows `Superseded by …`
  — which can only be written by editing the old record later. Both can't hold under a strict
  "never touch an existing file" reading. Without the flip, a cold reader landing on the old record
  sees `Accepted` and never learns it was replaced — breaks legibility-without-dereference.
- **"Immutable" means body-immutable.** Context / Decision / Consequences are frozen forever; the
  Status line is a one-time forward-pointer that flips on supersession. That Status flip is the one
  sanctioned edit to an existing record.
- **The Status flip slightly dents the "two actors never edit the same file" claim**
  ([STATE.md:464](../../../../references/STATE.md)). In practice supersession is rare and the flip is
  a single status line, not a body rewrite — the concurrent-safety guarantee is really about not
  rewriting a record's *body* concurrently. inquire/STATE.md should state this rather than leave the
  contradiction.
- **"Surface contradictions" can't be auto-detected.** Verify can glob and *present* records, but
  "this record contradicts the live code" is a surfaced-for-human judgment, consistent with the
  "never auto-trust" rule. The mechanical part is the glob + present; the contradiction call is the
  engineer's.
- **Knowledge-home overlap is the central correctness risk.** With `.vine/knowledge/` as a fourth
  home alongside CLAUDE.md / shared.md / profile, a "decision" could plausibly land in several
  places. The Knowledge Boundary table is the disambiguation lever but doesn't yet route to
  `.vine/knowledge/`. inquire must define a crisp rule (rough cut: non-regenerable *judgment* tied
  to a domain → knowledge record; repo facts every session needs → CLAUDE.md; cross-phase VINE
  protocol → shared.md; per-engineer depth → profile).

### Tech Debt in Affected Areas

- **None blocking.** The STATE.md property-4-vs-template inconsistency (above) is the only pre-existing
  defect, and fixing it is in scope this cycle.
- Evolve is already a long command with three knowledge-routing flows; adding a fourth raises the
  risk of reader confusion. Watch for an opportunity to state the routing rule once and reference it,
  per the shared-pattern convention, rather than duplicating disambiguation prose.

### Documentation Gaps

- **README** has no mention of `.vine/knowledge/` (the layer, commit-by-default) or the
  active → resolved → archived lifecycle. Both are AC items (#51, #56).
- **Knowledge Boundary table** (STATE.md) doesn't yet include `.vine/knowledge/` as a home with a
  "who pays the tokens" row — the forward reference at line 526 should graduate to a first-class row
  once the wiring lands.

### Open Questions

Steers already captured (do not re-litigate in inquire):

- **Bootstrap = seed a few real records.** This cycle writes 2–3 genuine `workflow`-domain records
  (the brain-descope decision — already the STATE.md example — and routing-foundation decisions), so
  the format is proven end-to-end and verify's glob has something to surface immediately.
- **Trellis = no new check.** Records aren't chain artifacts, so the State Artifact Addition
  Checklist doesn't apply; enforcement rides the writing commands (Reference Legibility's stated
  stance).
- **Routing-criteria calibration = Option A.** Evolve writes a knowledge ADR per recalibration (the
  supersede chain *is* the calibration history); any actual shared.md/ROUTE.md policy edit rides
  evolve's existing human-approved overlay-update flow ([evolve.md:276](../../../../commands/vine/evolve.md)).
  No new policy-editing mechanism; the immutable layer never couples to mutable policy files.
- **STATE.md supersede wording fix = in scope.** Add the carve-out (body immutable, Status pointer
  updatable on supersede only) and the concurrent-safety nuance.

Genuinely open for inquire to resolve:

1. **Knowledge-home routing rule** — the exact decision tree for knowledge record vs CLAUDE.md vs
   shared.md vs profile, stated once and referenced (see tribal knowledge above).
2. **Evolve's distillation UX** — how evolve proposes records: AskUserQuestion `multiSelect` over
   candidate decisions/gotchas mined from NAVIGATION.md + CONTEXT.md, one file per accepted record.
   Where in the evolve flow it sits relative to the existing CLAUDE.md/overlay/profile steps.
3. **Verify's glob placement + contradiction-surfacing** — where in verify's "Read the Landscape"
   the glob runs, and exactly how a contradicting record is presented (surfaced, not trusted).
4. **#56 archive-move flow** — the AskUserQuestion offer after `.resolved` is written; interaction
   with the consumed-once PAUSE.md rule and the existing `.archive/` filtering.
5. **Slug derivation for records** — how the declarative-sentence title maps to a filename slug, and
   collision handling within a domain.
6. **Multi-PR shape** — whether #51 (writer/reader wiring + bootstrap) and #56 (archive housekeeping)
   are one PR or two; they're independent now that #56 no longer depends on #51.
