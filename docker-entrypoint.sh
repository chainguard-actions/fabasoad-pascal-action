#!/usr/bin/env bash
fpc "$1"
result=$(${1%.*})
safe_result=$(printf '%s' "$result" | tr -d '\n\r')
echo "result=${safe_result}" >> "$GITHUB_OUTPUT"
