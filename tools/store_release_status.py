#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "google-auth>=2.30",
#     "pyjwt[crypto]>=2.8",
#     "requests>=2.32",
# ]
# ///
"""Tell whether a production build is live in its store.

Prints `live` or `not-live` and exits 0 (live), 3 (not live) or 1 (error,
including missing credentials). Used by .github/workflows/sentry-prod-release.yml
to record Sentry deploys only once customers can install the build.

Usage:
    uv run tools/store_release_status.py <ios|android> <version+build>

    ios      App Store Connect API; env ASC_KEY_ID, ASC_ISSUER_ID and
             ASC_PRIVATE_KEY (the .p8 PEM content)
    android  Google Play Developer API v3; env GOOGLE_PLAY_SERVICE_ACCOUNT_JSON
             (the service account JSON key content)

Tests (no network; the live/not-live decisions are pure functions), from
the repository root:
    uv run --with pytest --with 'pyjwt[crypto]' --with google-auth \
        --with requests pytest -p no:cacheprovider tools/tests

Uncaught failures (network errors, unexpected response shapes) end in a
traceback, which Python also reports as exit status 1.
"""
from __future__ import annotations

import json
import os
import sys
import time
from collections.abc import Callable
from typing import Any

JsonObject = dict[str, Any]

IOS_BUNDLE_ID = "com.reedom.audiflow"
ANDROID_PACKAGE = "com.reedom.audiflow_app"

ASC_API = "https://api.appstoreconnect.apple.com/v1"
PLAY_API = "https://androidpublisher.googleapis.com/androidpublisher/v3/applications"
PLAY_SCOPE = "https://www.googleapis.com/auth/androidpublisher"
HTTP_TIMEOUT_SECONDS = 30

EXIT_LIVE = 0
EXIT_ERROR = 1
EXIT_NOT_LIVE = 3

# AppVersionState values meaning customers can get the version. Apple
# documents READY_FOR_DISTRIBUTION as the released state (a phased release
# is in it too). REPLACED_WITH_NEW_VERSION is a version that was released
# and then superseded; counting it lets a manual backfill for an older
# build still record its deploy. This reading of REPLACED_WITH_NEW_VERSION
# comes from the state's name and the older appStoreState lifecycle, not
# from an explicit statement in Apple's reference.
LIVE_APP_VERSION_STATES = frozenset({"READY_FOR_DISTRIBUTION", "REPLACED_WITH_NEW_VERSION"})
# The deprecated appStoreState equivalents, used only when appVersionState
# is absent from the response.
LIVE_APP_STORE_STATES = frozenset({"READY_FOR_SALE", "REPLACED_WITH_NEW_VERSION"})

# The only `tracks.releases.list` lifecycle state that reaches users: it
# covers full and staged rollouts (and a resumable halted one). The older
# edits API reports a release under review as `completed`, so it cannot tell
# a submitted build from a published one.
PUBLISHED_RELEASE_STATE = "RELEASE_LIFECYCLE_STATE_PUBLISHED"


class StoreStatusError(Exception):
    """A failure that should end the run with EXIT_ERROR."""


def split_version(version: str) -> tuple[str, str]:
    """Splits `2.1.0+58` into the marketing version and the build number."""
    marketing, separator, build = version.partition("+")
    if not separator or not marketing or not build.isdigit():
        raise StoreStatusError(f"Expected <version>+<build>, got {version!r}")
    return marketing, build


def find_app_id(apps_response: JsonObject, bundle_id: str) -> str | None:
    """Returns the App Store Connect app id whose bundle id matches exactly."""
    for app in apps_response.get("data", []):
        if app.get("attributes", {}).get("bundleId") == bundle_id:
            return app.get("id")
    return None


def _included_build_versions(versions_response: JsonObject) -> dict[str, str]:
    return {
        item["id"]: item.get("attributes", {}).get("version", "")
        for item in versions_response.get("included", [])
        if item.get("type") == "builds" and "id" in item
    }


def _attached_build_id(app_store_version: JsonObject) -> str | None:
    build = app_store_version.get("relationships", {}).get("build", {}).get("data")
    return build.get("id") if build else None


def _is_released_state(attributes: JsonObject) -> bool:
    app_version_state = attributes.get("appVersionState")
    if app_version_state is not None:
        return app_version_state in LIVE_APP_VERSION_STATES
    return attributes.get("appStoreState") in LIVE_APP_STORE_STATES


def is_ios_version_live(versions_response: JsonObject, build_number: str) -> bool:
    """Decides from a `GET /v1/apps/{id}/appStoreVersions?include=build`
    response (already filtered to the platform and marketing version)
    whether the version with this build attached is released."""
    build_versions = _included_build_versions(versions_response)
    for app_store_version in versions_response.get("data", []):
        build_id = _attached_build_id(app_store_version)
        if build_id is None or build_versions.get(build_id) != build_number:
            continue
        if _is_released_state(app_store_version.get("attributes", {})):
            return True
    return False


def is_android_build_live(releases_response: JsonObject, build_number: str) -> bool:
    """Decides from a Play `tracks.releases.list` response for the production
    track whether a published release contains this version code."""
    for release in releases_response.get("releases", []):
        if release.get("releaseLifecycleState") != PUBLISHED_RELEASE_STATE:
            continue
        codes = (str(artifact.get("versionCode")) for artifact in release.get("activeArtifacts", []))
        if build_number in codes:
            return True
    return False


def _require_env(*names: str) -> list[str]:
    values = [os.environ.get(name, "") for name in names]
    missing = [name for name, value in zip(names, values) if not value]
    if missing:
        raise StoreStatusError(f"Missing environment: {', '.join(missing)}")
    return values


def _asc_token(key_id: str, issuer_id: str, private_key: str) -> str:
    import jwt

    now = int(time.time())
    # Apple rejects tokens that live longer than 20 minutes.
    payload = {"iss": issuer_id, "iat": now, "exp": now + 600, "aud": "appstoreconnect-v1"}
    return jwt.encode(payload, private_key, algorithm="ES256", headers={"kid": key_id})


def _get_json(session: Any, url: str, params: dict[str, str] | None = None) -> JsonObject:
    response = session.get(url, params=params, timeout=HTTP_TIMEOUT_SECONDS)
    if not response.ok:
        raise StoreStatusError(f"GET {url} failed: {response.status_code} {response.text[:500]}")
    return response.json()


def check_ios(version: str) -> bool:
    import requests

    marketing, build = split_version(version)
    token = _asc_token(*_require_env("ASC_KEY_ID", "ASC_ISSUER_ID", "ASC_PRIVATE_KEY"))
    session = requests.Session()
    session.headers["Authorization"] = f"Bearer {token}"
    apps = _get_json(session, f"{ASC_API}/apps", {"filter[bundleId]": IOS_BUNDLE_ID})
    app_id = find_app_id(apps, IOS_BUNDLE_ID)
    if app_id is None:
        raise StoreStatusError(f"No App Store Connect app with bundle id {IOS_BUNDLE_ID}")
    versions = _get_json(
        session,
        f"{ASC_API}/apps/{app_id}/appStoreVersions",
        {
            "filter[platform]": "IOS",
            "filter[versionString]": marketing,
            "include": "build",
            "fields[builds]": "version",
        },
    )
    return is_ios_version_live(versions, build)


def play_session() -> Any:
    """Returns a session authorized for the Play Developer API (shared with
    tools/play_upload.py)."""
    from google.auth.transport.requests import AuthorizedSession
    from google.oauth2 import service_account

    (raw_json,) = _require_env("GOOGLE_PLAY_SERVICE_ACCOUNT_JSON")
    try:
        info = json.loads(raw_json)
    except ValueError as error:
        raise StoreStatusError("GOOGLE_PLAY_SERVICE_ACCOUNT_JSON is not valid JSON") from error
    credentials = service_account.Credentials.from_service_account_info(info, scopes=[PLAY_SCOPE])
    return AuthorizedSession(credentials)


def check_android(version: str) -> bool:
    _, build = split_version(version)
    session = play_session()
    releases = _get_json(session, f"{PLAY_API}/{ANDROID_PACKAGE}/tracks/production/releases")
    return is_android_build_live(releases, build)


CHECKS: dict[str, Callable[[str], bool]] = {"ios": check_ios, "android": check_android}


def main(arguments: list[str]) -> int:
    if len(arguments) != 2 or arguments[0] not in CHECKS:
        print(__doc__, file=sys.stderr)
        return EXIT_ERROR
    platform, version = arguments
    try:
        live = CHECKS[platform](version)
    except StoreStatusError as error:
        print(f"error: {error}", file=sys.stderr)
        return EXIT_ERROR
    print("live" if live else "not-live")
    return EXIT_LIVE if live else EXIT_NOT_LIVE


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
