#!/usr/bin/env python3
"""Idempotent GA4 custom-dimension provisioner for audiflow.

Reads `DIMENSIONS` (single source of truth) and creates any that are missing
on the target property. Existing dimensions with matching parameter name are
left untouched -- GA4 forbids editing the `parameterName` of a registered
dimension, so divergence requires manual archival first.

Auth: uses gcloud Application Default Credentials. Run
`gcloud auth application-default login` once before using.

Usage:
    tools/ga4_admin.py --list   --property 464978821
    tools/ga4_admin.py --apply  --property 464978821
    tools/ga4_admin.py --apply  --all      # dev + stg + prod (see PROPERTIES)
"""
from __future__ import annotations

import argparse
import json
import subprocess
import sys
import urllib.error
import urllib.request

API_BASE = "https://analyticsadmin.googleapis.com/v1beta"

# Property IDs per environment. Update if a new GA4 property is provisioned.
PROPERTIES: dict[str, str] = {
    "dev": "464978821",
    "stg": "464982575",
    "prod": "464963511",
}

# Custom dimensions to register. Order is preserved in the GA UI.
#
# `parameter_name` MUST exactly match the param key emitted from the app
# (see `audiflow_domain/lib/src/features/monitoring/models/analytics_event.dart`).
# Changing `parameter_name` after creation is impossible -- archive in the
# console and re-create instead.
#
# All dimensions are EVENT-scoped (no user-level identifiers other than the
# install UUID, which is already set via FirebaseAnalytics.setUserId and does
# not need a custom dimension).
DIMENSIONS: list[dict[str, str]] = [
    {"parameter_name": "podcast_id",    "display_name": "Podcast ID",        "description": "sha256(feedUrl) truncated to 16 hex chars."},
    {"parameter_name": "episode_id",    "display_name": "Episode ID",        "description": "sha256(rss guid) truncated to 16 hex chars."},
    {"parameter_name": "source",        "display_name": "Source",            "description": "Origin surface: search, library, queue, playlist, station, deeplink, discovery, opml, unknown."},
    {"parameter_name": "pattern_id",    "display_name": "Pattern ID",        "description": "Smart playlist pattern slug or hashed feedUrl fallback."},
    {"parameter_name": "playlist_id",   "display_name": "Playlist ID",       "description": "Smart playlist id within a pattern (regular/short/extras/...)."},
    {"parameter_name": "station_id",    "display_name": "Station ID",        "description": "sha256(installId + ':' + stationName) truncated to 16 hex chars."},
    {"parameter_name": "mode",          "display_name": "Sleep timer mode",  "description": "Sleep timer mode: duration, episodes, end_of_episode, end_of_chapter."},
    {"parameter_name": "value",         "display_name": "Sleep timer value", "description": "Sleep timer value (minutes for duration, count for episodes)."},
    {"parameter_name": "query_len",     "display_name": "Query length",     "description": "Length of the search query string (raw text never sent)."},
    {"parameter_name": "position_sec",  "display_name": "Position sec",     "description": "Playback position in seconds when paused."},
    {"parameter_name": "duration_sec",  "display_name": "Duration sec",     "description": "Episode duration in seconds at completion."},
    {"parameter_name": "from_sec",      "display_name": "From sec",         "description": "Seek source position in seconds."},
    {"parameter_name": "to_sec",        "display_name": "To sec",           "description": "Seek destination position in seconds."},
    {"parameter_name": "speed",         "display_name": "Speed",            "description": "Playback speed multiplier (1.0 = real-time)."},
    {"parameter_name": "bytes",         "display_name": "Bytes",            "description": "Downloaded episode size in bytes."},
]


def get_access_token() -> str:
    """Return an OAuth access token via `gcloud auth application-default print-access-token`."""
    try:
        proc = subprocess.run(
            ["gcloud", "auth", "application-default", "print-access-token"],
            check=True,
            capture_output=True,
            text=True,
        )
    except FileNotFoundError:
        sys.exit("gcloud CLI not found. Install Google Cloud SDK.")
    except subprocess.CalledProcessError as exc:
        sys.exit(
            "Failed to obtain access token. Run "
            "`gcloud auth application-default login` first.\n"
            f"{exc.stderr.strip()}"
        )
    return proc.stdout.strip()


def api_request(method: str, path: str, token: str, body: dict | None = None) -> dict:
    url = f"{API_BASE}/{path.lstrip('/')}"
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header("Authorization", f"Bearer {token}")
    if body is not None:
        req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req) as resp:
            payload = resp.read()
            return json.loads(payload) if payload else {}
    except urllib.error.HTTPError as exc:
        err = exc.read().decode("utf-8", errors="replace")
        sys.exit(f"HTTP {exc.code} on {method} {path}: {err}")


def list_dimensions(property_id: str, token: str) -> list[dict]:
    resp = api_request(
        "GET",
        f"properties/{property_id}/customDimensions?pageSize=200",
        token,
    )
    return resp.get("customDimensions", [])


def existing_parameter_names(property_id: str, token: str) -> set[str]:
    return {d["parameterName"] for d in list_dimensions(property_id, token)}


def create_dimension(property_id: str, token: str, spec: dict[str, str]) -> dict:
    body = {
        "parameterName": spec["parameter_name"],
        "displayName": spec["display_name"],
        "description": spec["description"],
        "scope": "EVENT",
    }
    return api_request(
        "POST",
        f"properties/{property_id}/customDimensions",
        token,
        body=body,
    )


def cmd_list(property_id: str, token: str) -> None:
    rows = list_dimensions(property_id, token)
    print(f"Property {property_id}: {len(rows)} custom dimension(s)")
    for row in rows:
        scope = row.get("scope", "EVENT")
        print(f"  {scope:5}  {row['parameterName']:14}  {row['displayName']}")


def cmd_apply(property_id: str, token: str) -> None:
    existing = existing_parameter_names(property_id, token)
    created = 0
    skipped = 0
    for spec in DIMENSIONS:
        param = spec["parameter_name"]
        if param in existing:
            print(f"  skip   {param:14}  (already registered)")
            skipped += 1
            continue
        create_dimension(property_id, token, spec)
        print(f"  create {param:14}  {spec['display_name']}")
        created += 1
    print(f"Property {property_id}: created={created}, skipped={skipped}")


def resolve_properties(args: argparse.Namespace) -> list[tuple[str, str]]:
    if args.all:
        return list(PROPERTIES.items())
    if args.env:
        try:
            return [(args.env, PROPERTIES[args.env])]
        except KeyError:
            sys.exit(f"Unknown env '{args.env}'. Known: {sorted(PROPERTIES)}")
    if args.property:
        env_name = next(
            (env for env, pid in PROPERTIES.items() if pid == args.property),
            "custom",
        )
        return [(env_name, args.property)]
    sys.exit("Provide one of --env, --property, or --all.")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    target = parser.add_mutually_exclusive_group(required=True)
    target.add_argument("--property", help="Numeric GA4 property id.")
    target.add_argument("--env", choices=sorted(PROPERTIES), help="Env name from PROPERTIES.")
    target.add_argument("--all", action="store_true", help="Apply to every env in PROPERTIES.")
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--list", action="store_true", help="List current custom dimensions.")
    mode.add_argument("--apply", action="store_true", help="Create any missing custom dimensions.")
    args = parser.parse_args()

    token = get_access_token()
    targets = resolve_properties(args)
    for env, property_id in targets:
        print(f"=== {env} (property {property_id}) ===")
        if args.list:
            cmd_list(property_id, token)
        else:
            cmd_apply(property_id, token)


if __name__ == "__main__":
    main()
