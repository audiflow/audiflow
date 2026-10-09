#!/usr/bin/env bash
# Print "<version> <build>" of the highest stg-<version>+<build> tag behind
# HEAD of the git repository in the current directory.
#
# Dev builds use it in place of the pubspec version, which is only rewritten
# by the stg/prod release workflows and so lags behind on main. Prints
# nothing (exit 0) when no such tag is reachable, e.g. in a shallow CI
# checkout or outside a git repository, so callers keep the pubspec version.
set -euo pipefail

# Validate every candidate rather than picking one tag first, so a stray
# malformed tag never hides a valid one.
tags=$(git tag --merged HEAD --list 'stg-[0-9]*' --sort=-version:refname 2>/dev/null) || exit 0
while IFS= read -r tag; do
  if [[ "$tag" =~ ^stg-([0-9]+(\.[0-9]+)*)\+([0-9]+)$ ]]; then
    echo "${BASH_REMATCH[1]} ${BASH_REMATCH[3]}"
    exit 0
  fi
done <<< "$tags"
