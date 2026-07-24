<!-- markdownlint-disable -->

# Hardening Report: fabasoad--pascal-action/v1.1.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **fabasoad--pascal-action/v1.1.3** was hardened automatically. 15 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): A ${{ ... }} expression is directly interpolated inside a run: shell command string. In functional-tests-local.yml (line 27): `[ "Hello World!" = "${{ steps.pascal.outputs.result }}" ] || exit 1;` — the step output is injected directly into the shell command before the shell ever sees it, allowing a malicious Pascal program output to inject shell metacharacters. The value should be passed via an env: variable and then double-quoted in the script.

Locations:

- `.github/workflows/functional-tests-local.yml:27`

### script-injection (severity: high)

Sub-rule (a): A ${{ ... }} expression is directly interpolated inside a run: shell command string. In functional-tests-remote.yml (line 28): `[ "Hello World!" = "${{ steps.pascal.outputs.result }}" ] || exit 1;` — same pattern as functional-tests-local.yml. The step output should be routed through an env: variable and double-quoted.

Locations:

- `.github/workflows/functional-tests-remote.yml:28`

### script-injection (severity: high)

Sub-rule (a): A ${{ ... }} expression is directly interpolated inside a run: shell command string. In security.yml (line 22): `docker save --output "${archive_path}" "${{ steps.build-image.outputs.digest }}"` — the build digest is injected directly into the shell command. It should be passed via an env: variable and double-quoted.

Locations:

- `.github/workflows/security.yml:22`

### unpinned-uses (severity: high)

The following uses: references are pinned to mutable tags or branch names instead of immutable 40-character commit SHAs, making them vulnerable to supply-chain attacks: `actions/checkout@v4` (line 21).

Locations:

- `.github/workflows/functional-tests-local.yml:21`

### unpinned-uses (severity: high)

The following uses: references are pinned to mutable tags or branch names instead of immutable 40-character commit SHAs: `actions/checkout@v4` (line 21), `fabasoad/pascal-action@main` (line 22).

Locations:

- `.github/workflows/functional-tests-remote.yml:21`
- `.github/workflows/functional-tests-remote.yml:22`

### unpinned-uses (severity: high)

The following uses: reference is pinned to a mutable branch name instead of an immutable 40-character commit SHA: `fabasoad/reusable-workflows/.github/workflows/wf-pre-commit.yml@main` (line 11).

Locations:

- `.github/workflows/linting.yml:11`

### unpinned-uses (severity: high)

The following uses: reference is pinned to a mutable branch name instead of an immutable 40-character commit SHA: `fabasoad/reusable-workflows/.github/workflows/wf-github-release.yml@main` (line 10).

Locations:

- `.github/workflows/release.yml:10`

### unpinned-uses (severity: high)

The following uses: references are pinned to mutable tags or branch names instead of immutable 40-character commit SHAs: `actions/checkout@v4` (line 14), `docker/build-push-action@v6` (line 18), `actions/upload-artifact@v4` (line 30), `fabasoad/reusable-workflows/.github/workflows/wf-security-sast.yml@main` (line 40).

Locations:

- `.github/workflows/security.yml:14`
- `.github/workflows/security.yml:18`
- `.github/workflows/security.yml:30`
- `.github/workflows/security.yml:40`

### unpinned-uses (severity: high)

The following uses: reference is pinned to a mutable branch name instead of an immutable 40-character commit SHA: `fabasoad/reusable-workflows/.github/workflows/wf-update-license.yml@main` (line 10).

Locations:

- `.github/workflows/update-license.yml:10`

### missing-permissions (severity: medium)

The workflow has no top-level permissions: key and the single job (functional-tests) has no job-level permissions: key either. Without explicit permissions, the workflow inherits the repository default (typically write-all for private repos), granting excessive access to the GITHUB_TOKEN.

Locations:

- `.github/workflows/functional-tests-local.yml:1`

### missing-permissions (severity: medium)

The workflow has no top-level permissions: key and no job-level permissions: key on any job. Without explicit permissions, the workflow inherits the repository default, granting excessive access to the GITHUB_TOKEN.

Locations:

- `.github/workflows/functional-tests-remote.yml:1`

### missing-permissions (severity: medium)

The workflow has no top-level permissions: key and the single job (pre-commit, via reusable workflow) has no job-level permissions: key. Without explicit permissions, the workflow inherits the repository default.

Locations:

- `.github/workflows/linting.yml:1`

### missing-permissions (severity: medium)

The workflow has no top-level permissions: key and the single job (github, via reusable workflow) has no job-level permissions: key. Without explicit permissions, the workflow inherits the repository default.

Locations:

- `.github/workflows/release.yml:1`

### missing-permissions (severity: medium)

The workflow has no top-level permissions: key and the build-image job has no job-level permissions: key (only the sast job has permissions). The build-image job runs with the repository default permissions, which may be overly broad.

Locations:

- `.github/workflows/security.yml:1`

### missing-permissions (severity: medium)

The workflow has no top-level permissions: key and the single job (maintenance, via reusable workflow) has no job-level permissions: key. Without explicit permissions, the workflow inherits the repository default.

Locations:

- `.github/workflows/update-license.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, unpinned-uses, missing-permissions

**Notes:**

Fixed all 6 workflow files:

**functional-tests-local.yml**: Added `permissions: {}` top-level, pinned `actions/checkout@v4` → SHA `11d5960a326750d5838078e36cf38b85af677262`, moved `${{ steps.pascal.outputs.result }}` into `env: PASCAL_RESULT` and referenced as `$PASCAL_RESULT` in the run script.

**functional-tests-remote.yml**: Added `permissions: {}` top-level, pinned `actions/checkout@v4` → SHA `11d5960a326750d5838078e36cf38b85af677262`, pinned `fabasoad/pascal-action@main` → SHA `33e089a71e00c93ef3b93a9758f75e93cf8bf32f`, moved `${{ steps.pascal.outputs.result }}` into `env: PASCAL_RESULT`.

**linting.yml**: Added `permissions: {}` top-level, pinned `fabasoad/reusable-workflows/...wf-pre-commit.yml@main` → SHA `c5bd8945762dab6d2f5168b65f10355887ea40a3`.

**release.yml**: Added `permissions: {}` top-level, pinned `fabasoad/reusable-workflows/...wf-github-release.yml@main` → SHA `c5bd8945762dab6d2f5168b65f10355887ea40a3`.

**update-license.yml**: Added `permissions: {}` top-level, pinned `fabasoad/reusable-workflows/...wf-update-license.yml@main` → SHA `c5bd8945762dab6d2f5168b65f10355887ea40a3`.

**security.yml**: Added `permissions: {}` top-level, added `permissions: contents: read` to build-image job, pinned `actions/checkout@v4` → SHA `11d5960a326750d5838078e36cf38b85af677262`, pinned `docker/build-push-action@v6` → SHA `10e90e3645eae34f1e60eeb005ba3a3d33f178e8`, pinned `actions/upload-artifact@v4` → SHA `ea165f8d65b6e75b540449e92b4886f43607fa02`, pinned `fabasoad/reusable-workflows/...wf-security-sast.yml@main` → SHA `c5bd8945762dab6d2f5168b65f10355887ea40a3`, moved `${{ steps.build-image.outputs.digest }}` into `env: BUILD_DIGEST` and referenced as `"$BUILD_DIGEST"` in the docker save command.

