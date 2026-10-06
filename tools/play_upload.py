#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "google-auth>=2.30",
#     "requests>=2.32",
# ]
# ///
"""Upload a production App Bundle to Google Play as a draft release.

Creates an edit, uploads the bundle, puts a `draft` release with the bundle's
version code (and the release notes, when present) on the production track,
and commits the edit. Nothing is sent for review or rolled out: a maintainer
publishes the draft in Play Console. On any failure the edit is deleted, so
no half-made change stays behind. Used by .github/workflows/deploy-prod.yml.

Usage:
    uv run tools/play_upload.py <aab> <version+build> [--release-notes-dir DIR]

    DIR holds <language>.txt files (en-US.txt, ja-JP.txt), normally
    release-notes/<version>/android. A missing directory or language file is
    a warning; the release is created without those notes.

Environment:
    GOOGLE_PLAY_SERVICE_ACCOUNT_JSON  service account JSON key content; the
        account needs permission to release to production in Play Console.

Exits 0 on success and 1 on any error. Tests (no network), from the
repository root:
    uv run --with pytest --with 'pyjwt[crypto]' --with google-auth \
        --with requests pytest -p no:cacheprovider tools/tests
"""
from __future__ import annotations

import argparse
import os
import sys
from collections.abc import Sequence
from pathlib import Path
from typing import Any

from store_release_status import ANDROID_PACKAGE, PLAY_API, StoreStatusError, play_session, split_version

JsonObject = dict[str, Any]

PLAY_UPLOAD_API = "https://androidpublisher.googleapis.com/upload/androidpublisher/v3/applications"
TRACK = "production"
RELEASE_STATUS = "draft"
RELEASE_NOTES_LANGUAGES = ("en-US", "ja-JP")
# Google Play's limit per language.
RELEASE_NOTES_MAX_CHARACTERS = 500
# Bundles are tens of megabytes; the upload can take minutes on a slow link.
UPLOAD_TIMEOUT_SECONDS = 600
HTTP_TIMEOUT_SECONDS = 60

EXIT_OK = 0
EXIT_ERROR = 1


class PlayUploadError(Exception):
    """A failure that should end the run with EXIT_ERROR."""


def warn(message: str) -> None:
    # The annotation form surfaces the warning on the Actions run summary.
    prefix = "::warning::" if os.environ.get("GITHUB_ACTIONS") == "true" else "warning: "
    print(f"{prefix}{message}", file=sys.stderr)


def _read_note(path: Path) -> str:
    text = path.read_text(encoding="utf-8").strip()
    if not text:
        raise PlayUploadError(f"Release notes file is empty: {path}")
    if RELEASE_NOTES_MAX_CHARACTERS < len(text):
        raise PlayUploadError(
            f"{path} has {len(text)} characters; Google Play allows {RELEASE_NOTES_MAX_CHARACTERS}"
        )
    return text


def load_release_notes(directory: Path | None) -> list[JsonObject]:
    """Reads `<language>.txt` per supported language into Play's
    `releaseNotes` form. Missing notes are warned about, not fatal."""
    if directory is None:
        return []
    if not directory.is_dir():
        warn(f"No release notes directory {directory}; the draft has no release notes")
        return []
    notes = []
    for language in RELEASE_NOTES_LANGUAGES:
        path = directory / f"{language}.txt"
        if not path.is_file():
            warn(f"Missing release notes {path}; {language} is left out")
            continue
        notes.append({"language": language, "text": _read_note(path)})
    return notes


def build_release(version: str, release_notes: Sequence[JsonObject]) -> JsonObject:
    """Builds the draft production release for `2.1.0+58`."""
    marketing, build = split_version(version)
    release: JsonObject = {
        "name": f"{marketing} ({build})",
        "versionCodes": [build],
        "status": RELEASE_STATUS,
    }
    if release_notes:
        release["releaseNotes"] = list(release_notes)
    return release


def build_track_payload(current_track: JsonObject, release: JsonObject) -> JsonObject:
    """Returns the production track with `release` as its only draft.

    Releases in other states (the live one, a staged rollout) are kept as
    they are, so the update cannot take them off the track; an older draft
    is replaced, since Play allows one draft per track."""
    kept = [
        existing
        for existing in current_track.get("releases", [])
        if existing.get("status") != RELEASE_STATUS
    ]
    return {"track": TRACK, "releases": [*kept, release]}


class PlayEditsClient:
    """The Play Developer API edits calls this tool needs, on one session."""

    def __init__(self, session: Any, package: str = ANDROID_PACKAGE) -> None:
        self._session = session
        self._edits_url = f"{PLAY_API}/{package}/edits"
        self._upload_url = f"{PLAY_UPLOAD_API}/{package}/edits"

    def _request(self, method: str, url: str, **kwargs: Any) -> JsonObject:
        kwargs.setdefault("timeout", HTTP_TIMEOUT_SECONDS)
        response = self._session.request(method, url, **kwargs)
        if not response.ok:
            raise PlayUploadError(f"{method} {url} failed: {response.status_code} {response.text[:500]}")
        return response.json() if response.content else {}

    def insert_edit(self) -> str:
        return self._request("POST", self._edits_url)["id"]

    def upload_bundle(self, edit_id: str, bundle: bytes) -> JsonObject:
        return self._request(
            "POST",
            f"{self._upload_url}/{edit_id}/bundles",
            params={"uploadType": "media"},
            data=bundle,
            headers={"Content-Type": "application/octet-stream"},
            timeout=UPLOAD_TIMEOUT_SECONDS,
        )

    def get_track(self, edit_id: str) -> JsonObject:
        return self._request("GET", f"{self._edits_url}/{edit_id}/tracks/{TRACK}")

    def update_track(self, edit_id: str, track: JsonObject) -> JsonObject:
        return self._request("PUT", f"{self._edits_url}/{edit_id}/tracks/{TRACK}", json=track)

    def commit_edit(self, edit_id: str) -> JsonObject:
        return self._request("POST", f"{self._edits_url}/{edit_id}:commit")

    def delete_edit(self, edit_id: str) -> None:
        self._request("DELETE", f"{self._edits_url}/{edit_id}")


def _check_version_code(uploaded: JsonObject, expected: str) -> None:
    actual = str(uploaded.get("versionCode", ""))
    if actual != expected:
        raise PlayUploadError(f"Uploaded bundle has version code {actual or '?'}, expected {expected}")


def _fill_edit(client: PlayEditsClient, edit_id: str, bundle: bytes, release: JsonObject) -> None:
    uploaded = client.upload_bundle(edit_id, bundle)
    _check_version_code(uploaded, release["versionCodes"][0])
    track = build_track_payload(client.get_track(edit_id), release)
    client.update_track(edit_id, track)
    client.commit_edit(edit_id)


def upload_draft(client: PlayEditsClient, bundle: bytes, release: JsonObject) -> None:
    """Runs one edit end to end; deletes the edit if any step fails."""
    edit_id = client.insert_edit()
    try:
        _fill_edit(client, edit_id, bundle, release)
    except Exception:
        try:
            client.delete_edit(edit_id)
        except Exception as cleanup_error:  # The original failure matters more.
            warn(f"Could not delete edit {edit_id}: {cleanup_error}")
        raise


def _parse_arguments(arguments: Sequence[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Upload an AAB to Google Play as a production draft.")
    parser.add_argument("aab", type=Path, help="path to the .aab file")
    parser.add_argument("version", help="version and build, e.g. 2.1.0+58")
    parser.add_argument("--release-notes-dir", type=Path, help="directory with <language>.txt files")
    return parser.parse_args(arguments)


def _run(options: argparse.Namespace) -> None:
    if not options.aab.is_file():
        raise PlayUploadError(f"App Bundle not found: {options.aab}")
    release = build_release(options.version, load_release_notes(options.release_notes_dir))
    bundle = options.aab.read_bytes()
    upload_draft(PlayEditsClient(play_session()), bundle, release)
    print(f"Created draft release {release['name']} on the {TRACK} track of {ANDROID_PACKAGE}")


def main(arguments: Sequence[str]) -> int:
    options = _parse_arguments(arguments)
    try:
        _run(options)
    except (PlayUploadError, StoreStatusError) as error:
        print(f"error: {error}", file=sys.stderr)
        return EXIT_ERROR
    return EXIT_OK


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
