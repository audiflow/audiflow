#!/usr/bin/env bash
# Create the Sentry releases for one build, with the commits since the
# previous build of the same channel.
#
# The Sentry SDK names releases `<app id>@<version>+<build>`, one per
# platform, so this creates exactly those: commits and deploys recorded on a
# differently named release would never meet an event.
#
# Usage:
#   tools/sentry-release.sh <stg|prod> <version+build>
#       [--deploy | --check-deployed] [--platform ios|android]
#
#   stg   tag stg-<version+build>, apps com.reedom.audiflow.stg and
#         com.reedom.audiflow_app.stg, deploy environment `stg`
#   prod  tag v<version+build>, apps com.reedom.audiflow and
#         com.reedom.audiflow_app, deploy environment `prod`
#   --deploy    also record a deploy to the channel's environment; for prod,
#               pass it once the stores publish the build. An existing
#               release only gets the missing deploy; one that already has
#               a deploy to that environment is left untouched.
#   --check-deployed  change nothing; exit 0 when every selected release
#               already has a deploy to the channel's environment, else 4
#   --platform  only the iOS (ios) or the Android (android) release
#
# The build's tag must exist locally; the commit range starts at the
# previous tag of the same channel reachable from it. Auth comes from
# SENTRY_AUTH_TOKEN or ~/.sentryclirc; SENTRY_ORG and SENTRY_PROJECT default
# to reedom and audiflow.
set -euo pipefail

readonly SENTRY_REPO="audiflow/audiflow"

usage() {
  sed -n '9,23p' "$0" >&2
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

readonly EXIT_NOT_DEPLOYED=4

# Sets DEPLOY, CHECK_DEPLOYED and PLATFORM from the options after
# <channel> <version>.
parse_options() {
  DEPLOY=""
  CHECK_DEPLOYED=""
  PLATFORM=""
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --deploy) DEPLOY=1 ;;
      --check-deployed) CHECK_DEPLOYED=1 ;;
      --platform)
        [ "$#" -ge 2 ] || usage
        PLATFORM="$2"
        shift
        ;;
      *) usage ;;
    esac
    shift
  done
  [ -z "$DEPLOY" ] || [ -z "$CHECK_DEPLOYED" ] || usage
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

# `releases info` exits 1 for a missing release.
# sentry-cli exits 1 both for a missing release (silently) and for an API
# failure (with an `error:` line). Only the silent case means "missing"; an
# API failure aborts the script, since these helpers run inside `if`
# conditions where `set -e` does not apply.
release_exists() {
  local output
  if output="$(sentry-cli releases info "$1" 2>&1)"; then
    return 0
  fi
  if grep -q '^error:' <<<"$output"; then
    printf '%s\n' "$output" >&2
    echo "Looking up Sentry release $1 failed." >&2
    exit 1
  fi
  return 1
}

# Succeeds when the existing release $1 has a deploy to $2.
has_deploy() {
  local deploys
  if ! deploys="$(sentry-cli releases deploys "$1" list)"; then
    echo "Listing deploys of Sentry release $1 failed." >&2
    exit 1
  fi
  has_deploy_to "$2" <<<"$deploys"
}

create_release() {
  local release="$1" spec="$2"
  sentry-cli releases new "$release"
  sentry-cli releases set-commits "$release" --commit "$spec"
  sentry-cli releases finalize "$release"
}

# Creates a missing release, then records the deploy. An existing release
# is not touched again: `finalize` resets the release date to the current
# time on every call, which would move it to the day of the deploy.
deploy_release() {
  local release="$1" spec="$2" channel="$3"
  if ! release_exists "$release"; then
    create_release "$release" "$spec"
  elif has_deploy "$release" "$channel"; then
    echo "$release already has a deploy to $channel; skipping."
    return
  fi
  sentry-cli releases deploys "$release" new -e "$channel"
}

# Exits EXIT_NOT_DEPLOYED unless every release in APP_IDS has a deploy to $2.
check_deployed() {
  local version="$1" channel="$2" app_id release
  for app_id in "${APP_IDS[@]}"; do
    release="$app_id@$version"
    if ! release_exists "$release" || ! has_deploy "$release" "$channel"; then
      echo "$release has no deploy to $channel."
      exit "$EXIT_NOT_DEPLOYED"
    fi
    echo "$release already has a deploy to $channel."
  done
  exit 0
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

  [ -z "$CHECK_DEPLOYED" ] || check_deployed "$version" "$channel"

  local tag="$TAG_PREFIX$version" spec
  if ! git rev-parse -q --verify "refs/tags/$tag" >/dev/null; then
    echo "Tag $tag not found; create or fetch it first." >&2
    exit 1
  fi
  spec="$(commit_spec "$tag")"
  echo "Commits: $spec"

  local app_id
  for app_id in "${APP_IDS[@]}"; do
    if [ -n "$DEPLOY" ]; then
      deploy_release "$app_id@$version" "$spec" "$channel"
    else
      create_release "$app_id@$version" "$spec"
    fi
  done
}

main "$@"
