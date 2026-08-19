<!-- markdownlint-disable -->

# Hardening Report: fabasoad--pascal-action/v1.1.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **fabasoad--pascal-action/v1.1.1** was hardened automatically. 4 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): Direct ${{ ... }} expression interpolation inside run: shell blocks. In functional-tests-local.yml and functional-tests-remote.yml, `${{ steps.pascal.outputs.result }}` is interpolated directly in a run: shell command (`[[ "Hello World!" == "${{ steps.pascal.outputs.result }}" ]] || exit 1;`). In pre-commit.yml, `${{ github.sha }}` and `${{ github.base_ref }}` are interpolated directly in run: commands (`pre-commit run --to-ref ${{ github.sha }} --from-ref origin/${{ github.base_ref }} ...`). These expressions are substituted by the Actions runner before the shell sees them, enabling script injection if the values contain shell metacharacters.

Locations:

- `.github/workflows/functional-tests-local.yml:21`
- `.github/workflows/functional-tests-remote.yml:21`
- `.github/workflows/pre-commit.yml:26`
- `.github/workflows/pre-commit.yml:27`

### unpinned-uses (severity: high)

Multiple workflow files reference external actions using mutable tags or branch names instead of pinned 40-character SHA commit hashes. Mutable refs can be silently updated to point to malicious code. Failing references include: functional-tests-local.yml: `actions/checkout@v4`; functional-tests-remote.yml: `actions/checkout@v4`, `fabasoad/pascal-action@main`; pre-commit.yml: `actions/checkout@v4`; release.yml: `actions/checkout@v4`, `simbo/changes-since-last-release-action@v1`, `softprops/action-gh-release@v1`, `fischerscode/tagger@v0`; update-license.yml: `actions/checkout@v4`, `FantasticFiasco/action-update-license-year@v3`.

Locations:

- `.github/workflows/functional-tests-local.yml:16`
- `.github/workflows/functional-tests-remote.yml:15`
- `.github/workflows/functional-tests-remote.yml:17`
- `.github/workflows/pre-commit.yml:20`
- `.github/workflows/release.yml:13`
- `.github/workflows/release.yml:17`
- `.github/workflows/release.yml:21`
- `.github/workflows/release.yml:30`
- `.github/workflows/update-license.yml:12`
- `.github/workflows/update-license.yml:15`

### missing-permissions (severity: medium)

None of the 5 workflow files define a top-level `permissions:` block, and no job within any of these files defines a job-level `permissions:` block. Without explicit permissions, workflows run with the default (potentially write) token permissions, violating the principle of least privilege.

Locations:

- `.github/workflows/functional-tests-local.yml:1`
- `.github/workflows/functional-tests-remote.yml:1`
- `.github/workflows/pre-commit.yml:1`
- `.github/workflows/release.yml:1`
- `.github/workflows/update-license.yml:1`

### github-env-injection (severity: high)

docker-entrypoint.sh writes the output of executing a user-supplied binary to $GITHUB_OUTPUT without sanitization. The script runs `result=$(${1%.*})` — where `$1` is the `inputs.path` argument passed from action.yml — and then writes `echo "result=${result}" >> "$GITHUB_OUTPUT"`. The result value is the stdout of an arbitrary compiled binary derived from the user-controlled input path. No `printf '%s' ... | tr -d '\n\r'` sanitization is applied before the write, allowing newline injection into the output file which could poison subsequent steps' environment.

Locations:

- `docker-entrypoint.sh:4`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, unpinned-uses, missing-permissions, github-env-injection

**Notes:**

Fixed all 4 findings across 6 files:

1. script-injection: Moved ${{ steps.pascal.outputs.result }} to env.PASCAL_RESULT in functional-tests-local.yml and functional-tests-remote.yml; moved ${{ github.sha }} and ${{ github.base_ref }} to env.GH_SHA and env.GH_BASE_REF in pre-commit.yml.

2. unpinned-uses: Pinned all 10 action references to full 40-char SHAs with original tag in comment: actions/checkout@v4→34e114876b0b11c390a56381ad16ebd13914f8d5, fabasoad/pascal-action@main→489a5dc854922250f778319ee7060e7fe764b906, simbo/changes-since-last-release-action@v1→45883b23a1c40599d6967b447b919a5663aaf23d, softprops/action-gh-release@v1→de2c0eb89ae2a093876385947365aca7b0e5f844, fischerscode/tagger@v0→5ca3fa63ce3003fb7183cae547644b29f3b632be, FantasticFiasco/action-update-license-year@v3→f180e962fa988db222d8f03ef4636750312d1b3d.

3. missing-permissions: Added top-level permissions blocks to all 5 workflow files with least-privilege permissions (contents:read for functional tests and pre-commit; contents:write for release; contents:write + pull-requests:write for update-license).

4. github-env-injection: Added newline sanitization in docker-entrypoint.sh using `safe=$(printf '%s' "$result" | tr -d '\n\r')` before writing to $GITHUB_OUTPUT.

### Iteration 2

**Fixes applied:** unpinned-uses

**Notes:**

Pinned the mutable 'ghcr.io/fabasoad/pre-commit-container:latest' container image in .github/workflows/pre-commit.yml (line 22) to the immutable digest 'ghcr.io/fabasoad/pre-commit-container:latest@sha256:fecc92b1ff972326be0bdffa956c16e957be05047120936dbe97ff283d9fea15'. The tag is preserved inline as required.

