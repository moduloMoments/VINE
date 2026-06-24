---
name: release-plugin
description: "Cut a VINE plugin release — bump the version, finalize the changelog, and drive the develop→main release flow up to the publish workflow"
argument-hint: "[patch|minor|major]"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Edit
  - AskUserQuestion
---

# release-plugin — Cut a VINE Plugin Release

Contributor/maintainer command. Cuts a tagged plugin release following VINE's branch model:
`main` = release, `develop` = integration. The version in
`plugins/vine/.claude-plugin/plugin.json` is the **single source of truth**; the marketplace entry
omits `version` so plugin.json wins. The release is the proven two-PR pattern — **stamp** the
version on `develop` (cf. #139), then **cut** `develop`→`main` (cf. #140) — followed by the
manual `publish.yml` dispatch that tags and publishes.

This command does the mechanical work (version math, file edits, branch, commits, push, PRs) and
**hands off the merges and the publish dispatch to the maintainer** — every merge here hits a
1-review branch-protection gate that a self-reviewing solo maintainer satisfies by merging
directly. The command never bypasses that gate for you.

## Step 1: Preconditions

1. `git status` — the working tree must be clean. If not, stop and tell the user to commit or stash.
2. `git fetch origin develop main --tags` — sync refs and tags.
3. Confirm `origin/develop` is the release source and is ahead of `origin/main` (there is something
   to release): `git log --oneline origin/main..origin/develop`. If it's empty, stop — `main`
   already holds everything on `develop`; there is nothing to release.
4. Confirm CI is green on `develop`: `gh run list --branch develop --limit 1` (or check the latest
   merged PR's checks). Don't cut a release over red CI — surface it and stop.

Do **not** run this from `main` or a detached HEAD. The command operates on `origin/develop` and
creates its own `release/x.y.z` branch.

## Step 2: Determine the version bump

Read the current version from `plugins/vine/.claude-plugin/plugin.json` (the single source of truth).

Apply VINE's SemVer rules for a behavior-only product (no API, only command behavior) — judge them
against the **shipped plugin payload** (`plugins/vine/`), not contributor tooling under `.claude/`:

- **major** — a shipped skill removed/renamed, or an invocation / state-artifact-contract break.
- **minor** — a new shipped skill, agent, hook, or capability.
- **patch** — prose/doc/non-behavioral fixes, and bugfixes to existing shipped behavior.

If `$ARGUMENTS` names a level (`patch`/`minor`/`major`), use it. Otherwise inspect what landed on
`develop` since the last release (`git log --oneline origin/main..origin/develop`, focusing on
`plugins/vine/` changes) and use `AskUserQuestion` to confirm the level — recommend the level the
diff implies, first, with "(Recommended)". Compute the new `X.Y.Z`.

**Guard:** verify the tag doesn't already exist — `git rev-parse vX.Y.Z` must fail. If it exists,
stop; `publish.yml` would refuse the duplicate. Pick the next open version.

## Step 3: Confirm the changelog has release notes

`publish.yml` extracts release notes by matching the exact header `## [X.Y.Z]` in `CHANGELOG.md`
and reading until the next `## [` — so the finalized section must be non-empty.

Read the `## [Unreleased]` section. If it has no entries, stop and tell the user there's nothing to
release notes-wise — features are expected to have added `[Unreleased]` entries as they merged. The
stamp in Step 4 renames `[Unreleased]` to the new version; it does not invent notes.

## Step 4: Stamp the version on `develop` (prep PR — cf. #139)

Create the release branch and make the single stamping commit:

```
git checkout -b release/X.Y.Z origin/develop
```

Then two edits:
1. `plugins/vine/.claude-plugin/plugin.json` — bump `"version"` to `X.Y.Z`.
2. `CHANGELOG.md` — rename `## [Unreleased]` to `## [X.Y.Z] - YYYY-MM-DD` (today's date), and add a
   fresh empty `## [Unreleased]` line above it so the next cycle has a landing spot.

Commit, push, and open the prep PR **into `develop`**:

```
git commit -am "Release prep: stamp X.Y.Z (plugin.json + CHANGELOG)"
git push -u origin release/X.Y.Z
gh pr create --base develop --title "Release prep: stamp X.Y.Z" --body "<notes>"
```

The PR body should quote the finalized `## [X.Y.Z]` changelog section so the maintainer reviews the
exact release notes. Then **hand off**: tell the maintainer to merge this PR into `develop` (it hits
the 1-review gate — self-merge). Do not merge it yourself.

## Step 5: Cut `develop` → `main` (release PR — cf. #140)

After the stamp PR is merged to `develop` (confirm: `git fetch origin develop` and check
`plugins/vine/.claude-plugin/plugin.json` on `origin/develop` now reads `X.Y.Z`), open the release
PR. Its head is `develop` itself — no new commits, it just promotes the stamped `develop` to `main`:

```
gh pr create --base main --head develop --title "Release vX.Y.Z" --body "<summary + changelog link>"
```

Hand off again: the maintainer merges `develop`→`main`. `main` is release-only — never commit to it
directly (the repo's `main-guard` hook enforces this for local commits).

## Step 6: Publish (tag + GitHub release)

`publish.yml` is `workflow_dispatch` (manual). Once `main` carries the bumped `plugin.json`, it can
run. It reads the version from `plugin.json`, re-checks the tag is free, validates the plugin
(`trellis-check.sh`), extracts the `## [X.Y.Z]` changelog notes, creates tag `vX.Y.Z`, and cuts the
GitHub release.

Triggering it creates a **public tag and release** — an outward, hard-to-reverse action. Use
`AskUserQuestion` to let the maintainer choose:

1. **You trigger it (Recommended)** — the maintainer runs the workflow from the Actions tab (or you
   run `gh workflow run publish.yml` *only if they explicitly say so this turn*).
2. **Maintainer handles it** — stop here; the release is staged on `main` and ready to dispatch.

After a dispatch, verify: `gh release view vX.Y.Z` and `git ls-remote --tags origin vX.Y.Z`.

## Step 7: Report

Summarize what shipped: the version, the two PR links, the changelog section, and the release URL
(or the pending-dispatch state). Users update via `/plugin update vine`.

## Guardrails

- **plugin.json is the only version field.** Never reintroduce a competing version (no `package.json`
  version, no `version` in `marketplace.json`).
- **Never bypass branch protection.** If a merge is blocked on review, hand it to the maintainer —
  don't reach for `--admin` on the user's behalf.
- **Stamp before cut.** The version must be on `develop` before the `develop`→`main` PR, or the
  release PR carries no bump.
- **One concern.** This command cuts a release; it does not bundle feature work. Run it on a clean
  `develop`.
