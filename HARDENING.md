<!-- markdownlint-disable -->

# Hardening Report: fabasoad--pascal-action/v1.1.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **fabasoad--pascal-action/v1.1.1** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### github-env-injection (severity: high)

In docker-entrypoint.sh, the variable `result` is populated by executing a user-controlled binary (`result=$(${1%.*})`), where `$1` is the caller-supplied `inputs.path` argument. The output is then written directly to $GITHUB_OUTPUT via `echo "result=${result}" >> "$GITHUB_OUTPUT"` without the required sanitization step (`printf '%s' "$result" | tr -d '\n\r'`). Because the Pascal script's stdout is fully attacker-controlled, it can contain newline characters that inject additional key=value pairs into $GITHUB_OUTPUT, potentially overwriting other step outputs or poisoning the workflow environment.

Locations:

- `docker-entrypoint.sh:4`

## Iteration Notes

### Iteration 1

**Fixes applied:** github-env-injection

**Notes:**

Fixed docker-entrypoint.sh at line 4: added newline sanitization before writing to $GITHUB_OUTPUT. The `result` variable (populated by executing the user-controlled Pascal binary output) is now sanitized via `safe_result=$(printf '%s' "$result" | tr -d '\n\r')` before being written as `echo "result=${safe_result}" >> "$GITHUB_OUTPUT"`. This prevents an attacker from injecting additional key=value pairs into $GITHUB_OUTPUT by embedding newline characters in the Pascal script's stdout.

