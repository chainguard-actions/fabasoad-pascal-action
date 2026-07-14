<!-- markdownlint-disable -->

# Hardening Report: fabasoad--pascal-action/v1.1.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **fabasoad--pascal-action/v1.1.3** was hardened automatically. 3 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a) violation: ${{ ... }} expressions are directly interpolated inside run: shell command strings. In functional-tests-local.yml and functional-tests-remote.yml, `${{ steps.pascal.outputs.result }}` is embedded directly in a shell comparison command — an attacker who controls the action output could inject shell metacharacters. In security.yml, `${{ steps.build-image.outputs.digest }}` is interpolated directly into a `docker save` command inside a run: block. These values should be passed via env: variables and then double-quoted in the shell script.

Locations:

- `.github/workflows/functional-tests-local.yml:27`
- `.github/workflows/functional-tests-remote.yml:28`
- `.github/workflows/security.yml:27`

### unpinned-uses (severity: high)

Multiple workflow files reference actions and reusable workflows using mutable tags or branch names instead of immutable 40-character SHA commit digests. Failing references include: functional-tests-local.yml: `actions/checkout@v4`; functional-tests-remote.yml: `actions/checkout@v4`, `fabasoad/pascal-action@main`; linting.yml: `fabasoad/reusable-workflows/.github/workflows/wf-pre-commit.yml@main`; release.yml: `fabasoad/reusable-workflows/.github/workflows/wf-github-release.yml@main`; security.yml: `actions/checkout@v4`, `docker/build-push-action@v6`, `actions/upload-artifact@v4`, `fabasoad/reusable-workflows/.github/workflows/wf-security-sast.yml@main`; update-license.yml: `fabasoad/reusable-workflows/.github/workflows/wf-update-license.yml@main`. These mutable refs are vulnerable to supply-chain attacks if the referenced repository is compromised.

Locations:

- `.github/workflows/functional-tests-local.yml:21`
- `.github/workflows/functional-tests-remote.yml:21`
- `.github/workflows/functional-tests-remote.yml:23`
- `.github/workflows/linting.yml:11`
- `.github/workflows/release.yml:10`
- `.github/workflows/security.yml:21`
- `.github/workflows/security.yml:24`
- `.github/workflows/security.yml:32`
- `.github/workflows/security.yml:38`
- `.github/workflows/update-license.yml:10`

### missing-permissions (severity: medium)

Several workflow files have no top-level `permissions:` key and contain jobs without job-level `permissions:` blocks, meaning they run with the default (potentially broad) GITHUB_TOKEN permissions. Affected files: functional-tests-local.yml (no top-level permissions, functional-tests job has none); functional-tests-remote.yml (no top-level permissions, functional-tests-remote job has none); linting.yml (no top-level permissions, pre-commit job has none); release.yml (no top-level permissions, github job has none); update-license.yml (no top-level permissions, maintenance job has none). In security.yml, the build-image job also lacks job-level permissions while only the sast job defines them. All workflows should declare minimal explicit permissions (e.g. `permissions: contents: read`) to follow the principle of least privilege.

Locations:

- `.github/workflows/functional-tests-local.yml:1`
- `.github/workflows/functional-tests-remote.yml:1`
- `.github/workflows/linting.yml:1`
- `.github/workflows/release.yml:1`
- `.github/workflows/security.yml:1`
- `.github/workflows/update-license.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, unpinned-uses, missing-permissions

**Notes:**

Fixed all three finding types across six workflow files:

1. script-injection: In functional-tests-local.yml and functional-tests-remote.yml, moved `${{ steps.pascal.outputs.result }}` into an env: block as PASCAL_RESULT and referenced it as "$PASCAL_RESULT" in the shell script. In security.yml, moved `${{ steps.build-image.outputs.digest }}` into an env: block as BUILD_IMAGE_DIGEST and referenced it as "$BUILD_IMAGE_DIGEST".

2. unpinned-uses: Pinned all mutable action references to full SHA digests: actions/checkout@v4→34e114876b0b11c390a56381ad16ebd13914f8d5, fabasoad/pascal-action@main→63480abdb285112e4e6ea5b978bb22f643991a6e, docker/build-push-action@v6→10e90e3645eae34f1e60eeb005ba3a3d33f178e8, actions/upload-artifact@v4→ea165f8d65b6e75b540449e92b4886f43607fa02, fabasoad/reusable-workflows@main→e4ff663d3bc9ff9d225d2e967a0f94aad342d218.

3. missing-permissions: Added top-level `permissions: contents: read` to all six workflow files (functional-tests-local.yml, functional-tests-remote.yml, linting.yml, release.yml, security.yml, update-license.yml). Also added job-level `permissions: contents: read` to the build-image job in security.yml.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed `docker-entrypoint.sh` line 4: the Pascal binary output stored in `result` is now sanitized with `printf '%s' "$result" | tr -d '\n\r'` before being written to `$GITHUB_OUTPUT`. This strips any embedded newline or carriage-return characters that could inject additional key=value pairs into the output file and poison downstream steps.

