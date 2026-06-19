<!-- markdownlint-disable -->

# Hardening Report: fabasoad--pascal-action/v1.1.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **fabasoad--pascal-action/v1.1.0** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### github-env-injection (severity: high)

In docker-entrypoint.sh, the variable `result` captures the stdout of executing a user-supplied compiled Pascal binary (derived from `inputs.path` via `$1`). This value is then written directly to $GITHUB_OUTPUT with `echo "result=${result}" >> "$GITHUB_OUTPUT"` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). An attacker-controlled Pascal script could produce output containing newlines that inject arbitrary key=value pairs into the GitHub Actions environment output, potentially hijacking subsequent workflow steps.

Locations:

- `docker-entrypoint.sh:4`

## Iteration Notes

### Iteration 1

**Fixes applied:** github-env-injection

**Notes:**

Fixed docker-entrypoint.sh: Added a sanitization step that strips newlines and carriage returns from the Pascal binary's output before writing it to $GITHUB_OUTPUT. The raw `result` variable is now passed through `printf '%s' "$result" | tr -d '\n\r'` into `safe_result`, which is then written to $GITHUB_OUTPUT. This prevents an attacker-controlled Pascal script from injecting arbitrary key=value pairs into the GitHub Actions environment by embedding newlines in its stdout.

