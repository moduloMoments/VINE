# Feature Context: Payload-Relative Reference Convention
## Date: 2026-06-23
## Author: Rob + Claude

Shipped VINE skills and init's templates cite repo-internal locations (`references/STATE.md`,
`agents/…`) by bare paths that don't resolve where the code actually runs. This feature establishes
one convention for how shipped skills and the artifacts init writes reference payload-internal files,
and applies it consistently. It resolves three issues that share a single root cause:

- [#142](https://github.com/moduloMoments/VINE/issues/142) — shipped skill bodies cite
  `references/STATE.md` ~67× but it isn't in the plugin payload.
- [#141](https://github.com/moduloMoments/VINE/issues/141) — `vine:init` writes dead
  `references/STATE.md` pointers into a *consuming* repo's `.vine/README.md` and `CLAUDE.md`.
- [#138](https://github.com/moduloMoments/VINE/issues/138) — skills cite `agents/…`
  plugin-root-relative; correct for plugin users, ambiguous for contributors reading from repo root.

### Codebase Landscape

**Plugin payload boundary (the crux).** The product is published from `plugins/vine/` only
(marketplace `source: ./plugins/vine`). The payload contains `.claude-plugin/`, `skills/` (11),
`agents/` (2 shipped), `hooks/`. It does **not** contain `references/`, `.vine/`, `commands/`, or
the repo-resident autonomous-role agents under `.claude/agents/`. This was a deliberate v0.4.0
scoping decision (see Durable Decisions), not an oversight — and there is **no file-level inclusion
mechanism**, so the only way to ship a file is to put it inside the `source` dir.

**Where references run.** A skill executes with the **consuming repo as cwd**. So a bare relative
path like `references/STATE.md` resolves against the consumer's cwd (→ nothing) — not against the
plugin install dir and not against the marketplace repo where STATE.md actually sits
(`~/.claude/plugins/marketplaces/moduloMoments/references/STATE.md`).

**The references, by surface:**
- *Skill bodies → `references/STATE.md`* (~67 total): evolve 15, init 12, navigate 10,
  inquire 5, optimize 5, verify 5, pause 3, resume 3, status 1. (pair, help: 0.)
- *Skill bodies → `agents/…`*: `navigate/SKILL.md:459` and `evolve/SKILL.md:116` cite the
  verification checklist as `agents/vine-verification.md` (plugin-root-relative).
- *Init-written consumer artifacts*: `init/SKILL.md` step 4 (README template) and step 8
  (CLAUDE.md VINE pointer) inject `references/STATE.md` pointers into the *consuming* repo, where
  the file never exists.

**Two precedents already in the tree (the menu of fixes):**
- *Portable runtime read* — `help/SKILL.md:65-66` locates skills with the Glob
  `**/skills/<name>/SKILL.md`, which "resolves whether VINE is installed as a plugin, in the cache,
  or [in] repo." `hooks/hooks.json:10` uses `${CLAUDE_PLUGIN_ROOT}/hooks/journal-check.sh`. These
  are the building blocks if a reference must be resolvable at runtime (option b).
- *Operative copy + provenance citation* — `evolve/SKILL.md:387` already carries a routing rule as
  an *"operative copy — canonical version in `references/STATE.md`"*. The runtime-needed text lives
  inline in the skill; STATE.md is cited as provenance, not fetched. This is option (a) in miniature,
  and several skills already inline the artifact template headings the same way (verify, inquire).

### Current State

- **Works:** plugin install/payload is correct and verified (only the product ships). Skills run and
  produce artifacts because the runtime-critical bits (template headings, etc.) are largely inlined
  already; STATE.md references are mostly "consult for full detail" pointers, not hard dependencies.
- **Broken:** every `references/STATE.md` pointer is dead from a consuming repo — both the ~67 in
  skill bodies and the ones init *writes into* consumer README/CLAUDE.md. The `agents/…` citations
  resolve for plugin users but mislead contributors reading from repo root.
- **Severity:** mostly degraded-quality (an agent told to "consult STATE.md" can't, and silently
  proceeds on inlined context) rather than hard failure — but init actively *writes* dead links into
  other people's repos, which is user-visible breakage.
- **Recent history:** all of this is fallout from the v0.4.0 plugin-packaging cycle (#57) that
  introduced the `plugins/vine/` payload boundary. The skill-authoring convention predates it and
  was never reconciled.

### Edge Cases & Tribal Knowledge

- **The exclusion was intentional.** `references/` not shipping is a conscious payload-scoping call
  (payload-scope ADR), not a packaging miss. So "just ship STATE.md" (option b) partially *reverses*
  a just-shipped decision and must be argued, not assumed.
- **No file-level include exists.** You cannot add STATE.md to the payload with a manifest field or
  allowlist — the only lever is the `source` directory. Option (b) therefore means physically moving
  or copying `references/` *inside* `plugins/vine/`, with the duplication/sync cost that implies.
- **Local vs github source leak asymmetry** (from payload-scope ADR): a local-directory source copies
  gitignored files into the cache; a github source clones committed files only. Relevant if any fix
  relies on what's physically present in a dev cache.
- **Contributor-vs-user audience split** (#138): the *same* SKILL.md line is read by two audiences —
  plugin users (cwd = their repo, payload = the cache) and contributors (reading from repo root where
  paths look different). A convention has to be legible to both, or explicitly state which root paths
  are relative to.
- **Repo-owned-decisions instinct.** The team has twice now resolved "should VINE ship X" toward
  *documentation, not mechanism* (overlay-distribution ADR). STATE.md differs — it's VINE-authored,
  not consumer-authored — so that precedent informs but doesn't decide.

### Tech Debt in Affected Areas

- **No guard against regression.** Nothing stops a new bare repo-root-relative reference to a
  non-payload file from being added to a shipped skill. `/trellis` is the natural home for a check;
  without it, whatever convention we pick will drift again. (In scope for this cycle per the issues' ACs.)
- **67 references is a maintenance surface.** Whichever direction wins, the edit touches 9 skill
  files plus init's templates. The change is mechanical but broad; consistency matters more than
  cleverness.
- **Three issues, one fix.** Keeping #142/#141/#138 as separate tickets risks three partial,
  divergent fixes. Consolidating into one convention is the debt-avoidance move (decided: one feature).

### Documentation Gaps

- **`CLAUDE.md` "Skill Authoring Conventions"** has no rule for how shipped skills reference
  payload-internal vs. non-payload files — the gap that let this happen. The chosen convention should
  land here.
- **`references/STATE.md` "Reference Legibility" rule** governs glossing pointers but not
  path-resolution-by-audience; may need a companion note.
- **Init's README/CLAUDE.md templates** describe `references/STATE.md` as "the authoritative
  contract … in the repo root" — language that is false in a consuming repo and must change.

### Open Questions

1. **(HEADLINE — for inquire) Direction (a) vs (b).** Is `references/STATE.md` *contributor
   documentation* (→ stop instructing the runtime to read it; inline runtime needs via the
   evolve "operative copy" pattern; cite STATE.md as provenance) or a *runtime contract* (→ ship it
   inside the payload and reference it portably via `${CLAUDE_PLUGIN_ROOT}` / Glob)? Deliberately left
   open in verify. Prior judgment (payload-scope + overlay-distribution ADRs, the existing
   operative-copy precedent) leans (a); (b) must justify reversing the payload-scope exclusion and
   accept duplication/sync cost.
2. **Per-reference triage.** Are all ~67 STATE refs the same kind? Likely a mix of "consult for full
   detail" (provenance — safe to demote/inline) and a few that genuinely gate runtime behavior.
   inquire should classify them; the answer may differ per reference even within one direction.
3. **`agents/…` citations (#138).** Same convention, or a lighter touch (e.g. an explicit "paths in
   shipped skills are plugin-root-relative" note)? Does the help-skill Glob generalize here?
4. **Init's consumer-facing templates (#141).** Omit the STATE.md pointer entirely from consumer
   README/CLAUDE.md (it's framework-internal plumbing, not consumer doc), or rewrite it? #141 leans
   omit.
5. **The `/trellis` guard.** What exactly does it flag — any bare repo-root-relative path to a
   non-`plugins/vine/` file in a shipped skill? Define the rule precisely enough to implement.
6. **Where the convention is documented.** `CLAUDE.md` Skill Authoring Conventions is the likely
   home; confirm and decide whether STATE.md's "Reference Legibility" rule needs a companion clause.
