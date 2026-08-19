#!/usr/bin/env bash
fpc "$1"
result=$(${1%.*})
safe=$(printf '%s' "$result" | tr -d '\n\r')
echo "result=${safe}" >> "$GITHUB_OUTPUT"
