from __future__ import annotations

import json
from pathlib import Path

import pytest

import asc_apple_id

APPS = {
    "applications": [
        {"Name": "audiflow stg", "ReservedBundleIdentifier": "com.reedom.audiflow.stg", "AppleID": 222},
        {"Name": "audiflow", "ReservedBundleIdentifier": "com.reedom.audiflow", "AppleID": 111},
    ]
}


class TestFindAppleId:
    def test_matches_bundle_id_exactly_despite_prefix_overlap(self) -> None:
        assert asc_apple_id.find_apple_id(APPS, "com.reedom.audiflow") == "111"
        assert asc_apple_id.find_apple_id(APPS, "com.reedom.audiflow.stg") == "222"

    def test_accepts_adam_id_and_string_values(self) -> None:
        data = [{"bundleId": "com.reedom.audiflow", "adamId": "333"}]
        assert asc_apple_id.find_apple_id(data, "com.reedom.audiflow") == "333"

    def test_ignores_non_numeric_ids(self) -> None:
        data = [{"bundleId": "com.reedom.audiflow", "appleId": "n/a"}]
        assert asc_apple_id.find_apple_id(data, "com.reedom.audiflow") is None

    def test_unknown_bundle_id(self) -> None:
        assert asc_apple_id.find_apple_id(APPS, "com.reedom.audiflow.dev") is None


class TestMain:
    def test_prints_apple_id(self, tmp_path: Path, capsys: pytest.CaptureFixture[str]) -> None:
        path = tmp_path / "apps.json"
        path.write_text(json.dumps(APPS), encoding="utf-8")
        assert asc_apple_id.main([str(path), "com.reedom.audiflow"]) == 0
        assert capsys.readouterr().out == "111\n"

    @pytest.mark.parametrize("content", [None, "not json"])
    def test_unreadable_listing_prints_nothing(
        self, tmp_path: Path, capsys: pytest.CaptureFixture[str], content: str | None
    ) -> None:
        path = tmp_path / "apps.json"
        if content is not None:
            path.write_text(content, encoding="utf-8")
        assert asc_apple_id.main([str(path), "com.reedom.audiflow"]) == 0
        assert capsys.readouterr().out == ""
