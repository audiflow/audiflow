#!/usr/bin/env bash
# Create the Sentry releases for one build, with the commits since the
# previous build of the same channel.
#
# The Sentry SDK names releases `<app id>@<version>+<build>`, one per
# platform, so this creates exactly those: commits and deploys recorded on a
# differently named release would never meet an event.
#
# Usage:
#   tools/sentry-release.sh <stg|prod> <version+build> [--deploy]
#
#   stg   tag stg-<version+build>, apps com.reedom.audiflow.stg and
#         com.reedom.audiflow_app.stg, deploy environment `stg`
#   prod  tag v<version+build>, apps com.reedom.audiflow and
#         com.reedom.audiflow_app, deploy environment `prod`
#   --deploy  also record a deploy to the channel's environment; for prod,
#             pass it once the stores publish the build
#
# The build's tag must exist locally; the commit range starts at the
# previous tag of the same channel reachable from it. Auth comes from
# SENTRY_AUTH_TOKEN or ~/.sentryclirc; SENTRY_ORG and SENTRY_PROJECT default
# to reedom and audiflow.
set -euo pipefail

readonly SENTRY_REPO="audiflow/audiflow"

usage() {
  sed -n '9,18p' "$0" >&2
  exit 2
}

channel_settings() {
  case "$1" in
    stg)
      TAG_PREFIX="stg-"
      APP_IDS=(com.reedom.audiflow.stg com.reedom.audiflow_app.stg)
      ;;
    prod)
      TAG_PREFIX="v"
      APP_IDS=(com.reedom.audiflow com.reedom.audiflow_app)
      ;;
    *) usage ;;
  esac
}

# A `previous..current` range, or the single commit for a channel's first
# build. `--auto` cannot be used: it starts each release at the most recent
# release, so the second platform's release would get no commits.
commit_spec() {
  local commit previous
  commit="$(git rev-list -n 1 "$1")"
  previous="$(git describe --tags --abbrev=0 --match "${TAG_PREFIX}*" "$commit^" 2>/dev/null || true)"
  if [ -z "$previous" ]; then
    echo "$SENTRY_REPO@$commit"
    return
  fi
  echo "$SENTRY_REPO@$(git rev-list -n 1 "$previous")..$commit"
}

main() {
  [ "$#" -ge 2 ] || usage
  local channel="$1" version="$2" deploy="${3:-}"
  [ -z "$deploy" ] || [ "$deploy" = "--deploy" ] || usage
  channel_settings "$channel"

  export SENTRY_ORG="${SENTRY_ORG:-reedom}"
  export SENTRY_PROJECT="${SENTRY_PROJECT:-audiflow}"

  local tag="$TAG_PREFIX$version" spec
  if ! git rev-parse -q --verify "refs/tags/$tag" >/dev/null; then
    echo "Tag $tag not found; create or fetch it first." >&2
    exit 1
  fi
  spec="$(commit_spec "$tag")"
  echo "Commits: $spec"

  local app_id release
  for app_id in "${APP_IDS[@]}"; do
    release="$app_id@$version"
    sentry-cli releases new "$release"
    sentry-cli releases set-commits "$release" --commit "$spec"
    sentry-cli releases finalize "$release"
    if [ -n "$deploy" ]; then
      sentry-cli releases deploys "$release" new -e "$channel"
    fi
  done
}

main "$@"
