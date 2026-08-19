<!-- markdownlint-disable -->

# Hardening Report: fabasoad--pascal-action/v1.2.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **fabasoad--pascal-action/v1.2.0** was hardened automatically. 4 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Multiple workflow files reference actions and reusable workflows using mutable tags or branch names instead of full 40-character commit SHAs, making them vulnerable to supply-chain attacks.

Failing references:
- functional-tests.yml: `actions/checkout@v4`
- security.yml: `actions/checkout@v4`, `docker/build-push-action@v6`, `actions/upload-artifact@v4`
- linting.yml: `fabasoad/reusable-workflows/.github/workflows/wf-pre-commit.yml@main`
- release.yml: `fabasoad/reusable-workflows/.github/workflows/wf-github-release.yml@main`
- update-license.yml: `fabasoad/reusable-workflows/.github/workflows/wf-update-license.yml@main`
- security.yml: `fabasoad/reusable-workflows/.github/workflows/wf-security-sast.yml@main`

Locations:

- `.github/workflows/functional-tests.yml:24`
- `.github/workflows/security.yml:17`
- `.github/workflows/security.yml:21`
- `.github/workflows/security.yml:37`
- `.github/workflows/security.yml:44`
- `.github/workflows/linting.yml:11`
- `.github/workflows/release.yml:10`
- `.github/workflows/update-license.yml:9`

### script-injection (severity: high)

Sub-rule (a): GitHub Actions expressions are interpolated directly inside `run:` shell command strings, allowing injection of arbitrary shell commands if the expression value contains shell metacharacters.

1. functional-tests.yml — `run:` block contains: `[ "Hello World!" = "${{ steps.pascal.outputs.result }}" ] || exit 1;` — the step output is interpolated directly into the shell command before the shell parses it.

2. security.yml — `run:` block contains: `docker save --output "${archive_path}" "${{ steps.build-image.outputs.digest }}"` — the step output digest is interpolated directly into the shell command.

Locations:

- `.github/workflows/functional-tests.yml:30`
- `.github/workflows/security.yml:25`

### github-env-injection (severity: high)

The 'Save image' run block in security.yml writes to $GITHUB_OUTPUT using values derived from `${{ steps.build-image.outputs.digest }}` — a step output (workflow-controlled, untrusted source) — interpolated directly into the shell command without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`) before the write. An attacker who can influence the build digest output could inject newlines to poison GITHUB_OUTPUT.

Offending lines:
  `docker save --output "${archive_path}" "${{ steps.build-image.outputs.digest }}"`
  `echo "path=${archive_path}" >> "$GITHUB_OUTPUT"`
  `echo "name=${artifact_name}" >> "$GITHUB_OUTPUT"`

Locations:

- `.github/workflows/security.yml:23`

### missing-permissions (severity: medium)

The following workflow files have no top-level `permissions:` key and at least one job also lacks a `permissions:` key. Without explicit permissions, workflows run with the default (often broad) token permissions, violating the principle of least privilege.

- functional-tests.yml: no top-level permissions, no job-level permissions on `run-script` job.
- linting.yml: no top-level permissions, no job-level permissions on `pre-commit` job.
- release.yml: no top-level permissions, no job-level permissions on `github` job.
- update-license.yml: no top-level permissions, no job-level permissions on `maintenance` job.
- security.yml: no top-level permissions; `build-image` job has no job-level permissions (only the `sast` job has permissions defined).

Locations:

- `.github/workflows/functional-tests.yml:1`
- `.github/workflows/linting.yml:1`
- `.github/workflows/release.yml:1`
- `.github/workflows/update-license.yml:1`
- `.github/workflows/security.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, script-injection, github-env-injection, missing-permissions

**Notes:**

Fixed all findings across 5 workflow files:

1. unpinned-uses: Pinned actions/checkout@v4→SHA, docker/build-push-action@v6→SHA, actions/upload-artifact@v4→SHA, and all three fabasoad/reusable-workflows@main references→SHA (10062f81...).

2. script-injection: In functional-tests.yml, moved `${{ steps.pascal.outputs.result }}` to env var PASCAL_RESULT. In security.yml, moved `${{ steps.build-image.outputs.digest }}` to env var BUILD_DIGEST.

3. github-env-injection: In security.yml Save image step, all values written to GITHUB_OUTPUT are now sanitized with `printf '%s' ... | tr -d '\n\r'` before writing.

4. missing-permissions: Added `permissions: {}` at top-level to all 5 workflow files. Added `permissions: contents: read` at job-level to run-script (functional-tests.yml) and build-image (security.yml) jobs.

