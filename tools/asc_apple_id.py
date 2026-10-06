#!/usr/bin/env python3
"""Print the numeric App Store Connect Apple ID for a bundle id.

Reads the JSON from `xcrun altool --list-apps --output-format json` and
prints the Apple ID of the app whose bundle id equals the given one exactly,
so `com.reedom.audiflow` never picks `com.reedom.audiflow.stg`. Prints
nothing when the file is unreadable or no app matches; the caller decides
whether to upload without `--apple-id`. Always exits 0.

Xcode 26 altool can fail with "Cannot determine the Apple ID from Bundle ID"
when bundle id prefixes overlap (fastlane#29698, #29820), so the production
deploy workflow passes the Apple ID explicitly. Same lookup as the inline
script in .github/workflows/deploy-stg.yml.

Usage:
    python3 tools/asc_apple_id.py <altool-list-apps.json> <bundle-id>
"""
from __future__ import annotations

import json
import re
import sys
from typing import Any

# altool's JSON key names are not documented; match the likely spellings.
APPLE_ID_KEY = re.compile(r"apple.?id|adam.?id", re.IGNORECASE)


def _apple_id_in(node: dict[str, Any]) -> str | None:
    for key, value in node.items():
        if APPLE_ID_KEY.search(key) and str(value).isdigit():
            return str(value)
    return None


def find_apple_id(node: Any, bundle_id: str) -> str | None:
    """Searches the altool output for an object holding `bundle_id` as an
    exact string value and returns its numeric Apple ID."""
    if isinstance(node, dict):
        if bundle_id in (value for value in node.values() if isinstance(value, str)):
            found = _apple_id_in(node)
            if found:
                return found
        children: Any = node.values()
    elif isinstance(node, list):
        children = node
    else:
        return None
    for child in children:
        found = find_apple_id(child, bundle_id)
        if found:
            return found
    return None


def main(arguments: list[str]) -> int:
    if len(arguments) != 2:
        print(__doc__, file=sys.stderr)
        return 0
    path, bundle_id = arguments
    try:
        with open(path, encoding="utf-8") as file:
            data = json.load(file)
    except (OSError, ValueError):
        return 0
    apple_id = find_apple_id(data, bundle_id)
    if apple_id:
        print(apple_id)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
