#!/usr/bin/env bash
# Create the Sentry releases for one build, with the commits since the
# previous build of the same channel.
#
# The Sentry SDK names releases `<app id>@<version>+<build>`, one per
# platform, so this creates exactly those: commits and deploys recorded on a
# differently named release would never meet an event.
#
# Usage:
#   tools/sentry-release.sh <stg|prod> <version+build> [--deploy] [--platform ios|android]
#
#   stg   tag stg-<version+build>, apps com.reedom.audiflow.stg and
#         com.reedom.audiflow_app.stg, deploy environment `stg`
#   prod  tag v<version+build>, apps com.reedom.audiflow and
#         com.reedom.audiflow_app, deploy environment `prod`
#   --deploy    also record a deploy to the channel's environment; for prod,
#               pass it once the stores publish the build. A release that
#               already has a deploy to that environment is left untouched.
#   --platform  only the iOS (ios) or the Android (android) release
#
# The build's tag must exist locally; the commit range starts at the
# previous tag of the same channel reachable from it. Auth comes from
# SENTRY_AUTH_TOKEN or ~/.sentryclirc; SENTRY_ORG and SENTRY_PROJECT default
# to reedom and audiflow.
set -euo pipefail

readonly SENTRY_REPO="audiflow/audiflow"

usage() {
  sed -n '9,19p' "$0" >&2
  exit 2
}

channel_settings() {
  case "$1" in
    stg)
      TAG_PREFIX="stg-"
      IOS_APP_ID=com.reedom.audiflow.stg
      ANDROID_APP_ID=com.reedom.audiflow_app.stg
      ;;
    prod)
      TAG_PREFIX="v"
      IOS_APP_ID=com.reedom.audiflow
      ANDROID_APP_ID=com.reedom.audiflow_app
      ;;
    *) usage ;;
  esac
}

select_app_ids() {
  case "$1" in
    "") APP_IDS=("$IOS_APP_ID" "$ANDROID_APP_ID") ;;
    ios) APP_IDS=("$IOS_APP_ID") ;;
    android) APP_IDS=("$ANDROID_APP_ID") ;;
    *) usage ;;
  esac
}

# Sets DEPLOY and PLATFORM from the options after <channel> <version>.
parse_options() {
  DEPLOY=""
  PLATFORM=""
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --deploy) DEPLOY=1 ;;
      --platform)
        [ "$#" -ge 2 ] || usage
        PLATFORM="$2"
        shift
        ;;
      *) usage ;;
    esac
    shift
  done
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

# Reads `sentry-cli releases deploys <release> list` output on stdin and
# succeeds when a row's Environment column equals $1. sentry-cli prints
# either "No deploys found" or a `| Environment | Name | Finished |` table.
has_deploy_to() {
  awk -F'|' -v env="$1" '
    4 <= NF {
      cell = $2
      gsub(/^[ \t]+|[ \t]+$/, "", cell)
      if (cell == env) found = 1
    }
    END { exit found ? 0 : 1 }
  '
}

# Succeeds when the release exists and already has a deploy to $2. Listing
# the deploys of a missing release is an API error, hence the check first.
already_deployed() {
  local release="$1" environment="$2" deploys
  sentry-cli releases info "$release" >/dev/null 2>&1 || return 1
  deploys="$(sentry-cli releases deploys "$release" list)"
  has_deploy_to "$environment" <<<"$deploys"
}

publish_release() {
  local release="$1" spec="$2" channel="$3"
  # Skipping the whole release, not just the deploy, keeps `finalize` from
  # moving the release date: it resets it to the current time on every call.
  if [ -n "$DEPLOY" ] && already_deployed "$release" "$channel"; then
    echo "$release already has a deploy to $channel; skipping."
    return
  fi
  sentry-cli releases new "$release"
  sentry-cli releases set-commits "$release" --commit "$spec"
  sentry-cli releases finalize "$release"
  if [ -n "$DEPLOY" ]; then
    sentry-cli releases deploys "$release" new -e "$channel"
  fi
}

main() {
  [ "$#" -ge 2 ] || usage
  local channel="$1" version="$2"
  shift 2
  parse_options "$@"
  channel_settings "$channel"
  select_app_ids "$PLATFORM"

  export SENTRY_ORG="${SENTRY_ORG:-reedom}"
  export SENTRY_PROJECT="${SENTRY_PROJECT:-audiflow}"

  local tag="$TAG_PREFIX$version" spec
  if ! git rev-parse -q --verify "refs/tags/$tag" >/dev/null; then
    echo "Tag $tag not found; create or fetch it first." >&2
    exit 1
  fi
  spec="$(commit_spec "$tag")"
  echo "Commits: $spec"

  local app_id
  for app_id in "${APP_IDS[@]}"; do
    publish_release "$app_id@$version" "$spec" "$channel"
  done
}

main "$@"
