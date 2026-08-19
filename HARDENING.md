<!-- markdownlint-disable -->

# Hardening Report: fabasoad--pascal-action/v1.1.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **fabasoad--pascal-action/v1.1.0** was hardened automatically. 5 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### github-env-injection (severity: high)

docker-entrypoint.sh writes the output of executing the user-supplied argument ($1, which is inputs.path from action.yml) to $GITHUB_OUTPUT without sanitization. The line `result=$(${1%.*})` executes the compiled binary derived from the user-controlled path, and `echo "result=${result}" >> "$GITHUB_OUTPUT"` writes the unsanitized result. An attacker-controlled input.path value could inject newlines into GITHUB_OUTPUT, enabling environment variable injection. The required sanitization (`printf '%s' "$result" | tr -d '\n\r'`) is absent.

Locations:

- `docker-entrypoint.sh:3`
- `docker-entrypoint.sh:4`

### script-injection (severity: high)

Rule (a): Direct expression interpolation of ${{ steps.pascal.outputs.result }} inside a run: shell command. The step output value is interpolated directly into the shell string before the shell parses it, enabling script injection if the output contains shell metacharacters.

Locations:

- `.github/workflows/functional-tests-local.yml:23`
- `.github/workflows/functional-tests-remote.yml:23`

### script-injection (severity: high)

Rule (a): Direct expression interpolation of GitHub context values inside run: shell commands. In the 'Update git config' step, `${{ github.repository }}` is interpolated directly into a shell command (`repo=$(echo "${{ github.repository }}" | cut -d "/" -f 2)`). In the 'Run pre-commit on changed files' step, `${{ github.sha }}` and `${{ github.base_ref }}` are interpolated directly into shell commands without quoting or env-var indirection. These allow an attacker-controlled branch name (github.base_ref) or repository name to inject shell metacharacters.

Locations:

- `.github/workflows/pre-commit.yml:28`
- `.github/workflows/pre-commit.yml:34`
- `.github/workflows/pre-commit.yml:35`

### missing-permissions (severity: medium)

None of the workflow files define a top-level `permissions:` key, and no job within any workflow defines job-level `permissions:`. This means all workflows run with the default (potentially broad) GITHUB_TOKEN permissions. Affected files: functional-tests-local.yml, functional-tests-remote.yml, pre-commit.yml, release.yml, update-license.yml.

Locations:

- `.github/workflows/functional-tests-local.yml:1`
- `.github/workflows/functional-tests-remote.yml:1`
- `.github/workflows/pre-commit.yml:1`
- `.github/workflows/release.yml:1`
- `.github/workflows/update-license.yml:1`

### unpinned-uses (severity: high)

Multiple workflow files reference actions using mutable tags or branch names instead of full 40-character commit SHAs. This exposes the workflow to supply-chain attacks if the referenced tag or branch is moved to a malicious commit. Failing references: functional-tests-local.yml: `actions/checkout@v3`; functional-tests-remote.yml: `actions/checkout@v3`, `fabasoad/pascal-action@main`; pre-commit.yml: `actions/checkout@v3`; release.yml: `actions/checkout@v3`, `simbo/changes-since-last-release-action@v1`, `softprops/action-gh-release@v1`, `fischerscode/tagger@v0`; update-license.yml: `actions/checkout@v3`, `FantasticFiasco/action-update-license-year@v3`.

Locations:

- `.github/workflows/functional-tests-local.yml:16`
- `.github/workflows/functional-tests-remote.yml:15`
- `.github/workflows/functional-tests-remote.yml:16`
- `.github/workflows/pre-commit.yml:23`
- `.github/workflows/release.yml:14`
- `.github/workflows/release.yml:18`
- `.github/workflows/release.yml:20`
- `.github/workflows/release.yml:31`
- `.github/workflows/update-license.yml:12`
- `.github/workflows/update-license.yml:14`

## Iteration Notes

### Iteration 1

**Fixes applied:** github-env-injection, script-injection, missing-permissions, unpinned-uses

**Notes:**

Fixed all 5 findings across 6 files:

1. docker-entrypoint.sh (github-env-injection): Added `safe=$(printf '%s' "$result" | tr -d '\n\r')` and write `$safe` to GITHUB_OUTPUT instead of the raw `$result`.

2. functional-tests-local.yml + functional-tests-remote.yml (script-injection): Moved `${{ steps.pascal.outputs.result }}` into an env var `PASCAL_RESULT` and referenced it as `$PASCAL_RESULT` in the shell run block.

3. pre-commit.yml (script-injection): Moved `${{ github.repository }}` → env var `REPOSITORY`, `${{ github.sha }}` → `GIT_SHA`, `${{ github.base_ref }}` → `BASE_REF`, all referenced as shell variables in run blocks.

4. All 5 workflow files (missing-permissions): Added `permissions: {}` at the top level. For release.yml job, added `permissions: contents: write` (needed to create releases and push tags). For update-license.yml job, added `permissions: contents: write` and `pull-requests: write` (needed to create PRs).

5. All unpinned actions pinned to full SHA:
   - actions/checkout@v3 → @a37ce9120846195fa4ece8f58b268e6043cb2f26
   - fabasoad/pascal-action@main → @489a5dc854922250f778319ee7060e7fe764b906
   - simbo/changes-since-last-release-action@v1 → @45883b23a1c40599d6967b447b919a5663aaf23d
   - softprops/action-gh-release@v1 → @de2c0eb89ae2a093876385947365aca7b0e5f844
   - fischerscode/tagger@v0 → @5ca3fa63ce3003fb7183cae547644b29f3b632be
   - FantasticFiasco/action-update-license-year@v3 → @f180e962fa988db222d8f03ef4636750312d1b3d

### Iteration 2

**Fixes applied:** unpinned-uses

**Notes:**

Pinned the container image reference in .github/workflows/pre-commit.yml from the mutable 'ghcr.io/fabasoad/pre-commit-container:latest' to the immutable digest 'ghcr.io/fabasoad/pre-commit-container:latest@sha256:88e853c27feb9988ec4b92727f99104e541875946464816d9755b49178f717bf'. The tag is preserved inline alongside the digest for readability.

