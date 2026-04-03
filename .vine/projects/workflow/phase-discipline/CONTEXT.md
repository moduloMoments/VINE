# Feature Context: Phase Discipline (Navigate Completion + Profile Enforcement)
## Date: 2026-04-02
## Author: Rob + Claude

### Codebase Landscape

Two related issues where VINE commands don't follow their own contracts:

**Navigate completion discipline:**

Navigate step 5 says "Update NAVIGATION.md incrementally throughout implementation. Don't save it for the end." But the Phase Completion block (lines 340-374) has no gate check — it can fire without verifying that every slice entry has:
- A commit hash (not "pending")
- Validation status filled in
- Acceptance criteria checked off
- Learnings captured

The completion block just says "When all slices are implemented (or the engineer decides to stop)" — there's no enforcement that NAVIGATION.md reflects reality before suggesting `/clear` + evolve.

**Profile enforcement across phases:**

Every command (inquire, navigate, evolve, pair, pause, resume) has a "Load Engineer Profile" section with the depth hint pattern. But:

1. **Profile creation is gated on verify.** Only `vine:verify` prompts to create a profile entry for a new domain. If verify is skipped (or init was never run), no profile ever gets created.
2. **The depth hint is passive.** The instruction says "set the depth hint for this session" but there's no concrete checkpoint or reminder later in the command to actually apply it. In a long command file, the hint set in paragraph 3 may not influence behavior in paragraph 30.
3. **No profile in other repos.** If `vine:init` wasn't run, PROFILE.md doesn't exist. All commands say "if no profile exists, proceed normally" — so the feature silently degrades to nonexistent.

### Current State

**Navigate:** The command text is 375 lines. The "update NAVIGATION.md incrementally" instruction is in step 5, but the actual implementation flow (steps 3-4) focuses on code changes and commits. It's easy for the agent to get absorbed in implementation and treat NAVIGATION.md as an afterthought.

**Profile:** The profile feature works in the VINE repo itself (where init was run and verify seeded the profile). But in other repos where users jump to `vine:verify` or `vine:navigate` without init, the profile never materializes. The feature is designed to be opt-in, which is correct — but it's so opt-in that it opts itself out.

### Edge Cases & Tribal Knowledge

- The engineer observed that in recent sessions, navigate suggested clearing and starting evolve before NAVIGATION.md was fully updated — this is the specific failure mode
- Profile wasn't referenced in another repo, likely because it was never created there
- The depth hint pattern ("The engineer's profile indicates they are [level]...") appears identically in every command but may not be strong enough to influence agent behavior across a long command file

### Tech Debt in Affected Areas

- Navigate's step 5 (documentation) is structurally separate from step 4 (commit) — they should be more tightly coupled so you can't commit without updating the journal
- The "Load Engineer Profile" section is copy-pasted across 7 commands. Changing the enforcement approach means editing all 7 files. This is intentional (commands are self-contained) but creates update burden.

### Documentation Gaps

- No guidance in navigate for what "incrementally" means concretely — at what points must NAVIGATION.md be updated?
- STATE.md doesn't specify which NAVIGATION.md fields are required vs. optional per slice
- No documentation on what happens when a profile doesn't exist for a domain — the behavior is defined by absence of instructions

### Open Questions

1. **Navigate gate check** — Should the Phase Completion block include an explicit checklist that must pass before suggesting evolve? (e.g., "Verify every slice in NAVIGATION.md has a non-pending commit hash and at least one acceptance criterion checked")
2. **Profile creation in non-verify paths** — Should inquire/navigate also offer to create a profile if one doesn't exist? Or should we strengthen the init->verify->profile pipeline and accept that skipping verify means no profile?
3. **Depth hint reinforcement** — Should there be a mid-command reminder (e.g., at each slice boundary in navigate) to re-apply the depth hint? Or is the problem that the hint format itself is too weak?
4. **NAVIGATION.md update timing** — Should updating NAVIGATION.md be part of step 4 (validate and commit) rather than a separate step 5? If the journal update is part of the commit flow, it can't be skipped.
