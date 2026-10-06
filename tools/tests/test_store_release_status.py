from __future__ import annotations

from typing import Any

import pytest

import store_release_status as status


def _app_store_version(
    version_id: str,
    build_id: str | None,
    app_version_state: str | None = None,
    app_store_state: str | None = None,
) -> dict[str, Any]:
    attributes: dict[str, Any] = {"platform": "IOS", "versionString": "2.1.0"}
    if app_version_state is not None:
        attributes["appVersionState"] = app_version_state
    if app_store_state is not None:
        attributes["appStoreState"] = app_store_state
    build = {"type": "builds", "id": build_id} if build_id else None
    return {
        "type": "appStoreVersions",
        "id": version_id,
        "attributes": attributes,
        "relationships": {"build": {"data": build}},
    }


def _versions_response(*versions: dict[str, Any], builds: dict[str, str]) -> dict[str, Any]:
    return {
        "data": list(versions),
        "included": [
            {"type": "builds", "id": build_id, "attributes": {"version": number}}
            for build_id, number in builds.items()
        ],
    }


class TestSplitVersion:
    def test_splits_marketing_version_and_build(self) -> None:
        assert status.split_version("2.1.0+58") == ("2.1.0", "58")

    @pytest.mark.parametrize("value", ["2.1.0", "2.1.0+", "+58", "2.1.0+5a", ""])
    def test_rejects_malformed(self, value: str) -> None:
        with pytest.raises(status.StoreStatusError):
            status.split_version(value)


class TestFindAppId:
    def test_matches_bundle_id_exactly(self) -> None:
        response = {
            "data": [
                {"id": "1", "attributes": {"bundleId": "com.reedom.audiflow.stg"}},
                {"id": "2", "attributes": {"bundleId": "com.reedom.audiflow"}},
            ]
        }
        assert status.find_app_id(response, "com.reedom.audiflow") == "2"

    def test_missing_app(self) -> None:
        assert status.find_app_id({"data": []}, "com.reedom.audiflow") is None


class TestIosVersionLive:
    def test_released_version_with_matching_build_is_live(self) -> None:
        response = _versions_response(
            _app_store_version("v1", "b1", app_version_state="READY_FOR_DISTRIBUTION"),
            builds={"b1": "58"},
        )
        assert status.is_ios_version_live(response, "58")

    def test_wrong_build_is_not_live(self) -> None:
        response = _versions_response(
            _app_store_version("v1", "b1", app_version_state="READY_FOR_DISTRIBUTION"),
            builds={"b1": "57"},
        )
        assert not status.is_ios_version_live(response, "58")

    @pytest.mark.parametrize(
        "state",
        [
            "PREPARE_FOR_SUBMISSION",
            "WAITING_FOR_REVIEW",
            "IN_REVIEW",
            "PENDING_DEVELOPER_RELEASE",
            "PENDING_APPLE_RELEASE",
            "PROCESSING_FOR_DISTRIBUTION",
            "REJECTED",
        ],
    )
    def test_unreleased_states_are_not_live(self, state: str) -> None:
        response = _versions_response(
            _app_store_version("v1", "b1", app_version_state=state),
            builds={"b1": "58"},
        )
        assert not status.is_ios_version_live(response, "58")

    def test_superseded_version_counts_as_released(self) -> None:
        response = _versions_response(
            _app_store_version("v1", "b1", app_version_state="REPLACED_WITH_NEW_VERSION"),
            builds={"b1": "58"},
        )
        assert status.is_ios_version_live(response, "58")

    def test_falls_back_to_deprecated_app_store_state(self) -> None:
        response = _versions_response(
            _app_store_version("v1", "b1", app_store_state="READY_FOR_SALE"),
            builds={"b1": "58"},
        )
        assert status.is_ios_version_live(response, "58")

    def test_app_version_state_wins_over_deprecated_state(self) -> None:
        response = _versions_response(
            _app_store_version(
                "v1", "b1", app_version_state="IN_REVIEW", app_store_state="READY_FOR_SALE"
            ),
            builds={"b1": "58"},
        )
        assert not status.is_ios_version_live(response, "58")

    def test_missing_version_is_not_live(self) -> None:
        assert not status.is_ios_version_live({"data": [], "included": []}, "58")

    def test_version_without_build_is_not_live(self) -> None:
        response = _versions_response(
            _app_store_version("v1", None, app_version_state="READY_FOR_DISTRIBUTION"),
            builds={},
        )
        assert not status.is_ios_version_live(response, "58")


class TestAndroidBuildLive:
    """Fixtures follow `tracks.releases.list`; the first is the real response
    seen while 2.1.0 (58) was in review."""

    @staticmethod
    def _releases(*releases: tuple[str, int]) -> dict[str, Any]:
        return {
            "releases": [
                {
                    "releaseName": f"{code}",
                    "activeArtifacts": [{"versionCode": code}],
                    "releaseLifecycleState": f"RELEASE_LIFECYCLE_STATE_{state}",
                    "track": "production",
                }
                for state, code in releases
            ]
        }

    def test_in_review_release_is_not_live(self) -> None:
        response = self._releases(("IN_REVIEW", 58), ("PUBLISHED", 51))
        assert not status.is_android_build_live(response, "58")

    def test_published_release_is_live(self) -> None:
        response = self._releases(("PUBLISHED", 58), ("PUBLISHED", 51))
        assert status.is_android_build_live(response, "58")

    def test_wrong_build_is_not_live(self) -> None:
        response = self._releases(("PUBLISHED", 57))
        assert not status.is_android_build_live(response, "58")

    @pytest.mark.parametrize(
        "state",
        ["DRAFT", "NOT_SENT_FOR_REVIEW", "APPROVED_NOT_PUBLISHED", "NOT_APPROVED", "UNSPECIFIED"],
    )
    def test_unpublished_states_are_not_live(self, state: str) -> None:
        response = self._releases((state, 58), ("PUBLISHED", 57))
        assert not status.is_android_build_live(response, "58")

    def test_string_version_codes_are_accepted(self) -> None:
        response = {
            "releases": [
                {
                    "activeArtifacts": [{"versionCode": "58"}],
                    "releaseLifecycleState": "RELEASE_LIFECYCLE_STATE_PUBLISHED",
                }
            ]
        }
        assert status.is_android_build_live(response, "58")

    def test_empty_response_is_not_live(self) -> None:
        assert not status.is_android_build_live({}, "58")


class TestMain:
    def test_missing_ios_credentials_is_an_error(
        self, monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
    ) -> None:
        for name in ("ASC_KEY_ID", "ASC_ISSUER_ID", "ASC_PRIVATE_KEY"):
            monkeypatch.delenv(name, raising=False)
        assert status.main(["ios", "2.1.0+58"]) == status.EXIT_ERROR
        assert "ASC_KEY_ID" in capsys.readouterr().err

    def test_missing_play_credentials_is_an_error(self, monkeypatch: pytest.MonkeyPatch) -> None:
        monkeypatch.delenv("GOOGLE_PLAY_SERVICE_ACCOUNT_JSON", raising=False)
        assert status.main(["android", "2.1.0+58"]) == status.EXIT_ERROR

    def test_unknown_platform_is_an_error(self) -> None:
        assert status.main(["web", "2.1.0+58"]) == status.EXIT_ERROR

    @pytest.mark.parametrize(("live", "output", "code"), [(True, "live", 0), (False, "not-live", 3)])
    def test_reports_outcome(
        self,
        monkeypatch: pytest.MonkeyPatch,
        capsys: pytest.CaptureFixture[str],
        live: bool,
        output: str,
        code: int,
    ) -> None:
        monkeypatch.setitem(status.CHECKS, "ios", lambda _version: live)
        assert status.main(["ios", "2.1.0+58"]) == code
        assert capsys.readouterr().out.strip() == output


def test_asc_token_is_es256_with_key_id() -> None:
    import jwt
    from cryptography.hazmat.primitives import serialization
    from cryptography.hazmat.primitives.asymmetric import ec

    key = ec.generate_private_key(ec.SECP256R1())
    pem = key.private_bytes(
        serialization.Encoding.PEM,
        serialization.PrivateFormat.PKCS8,
        serialization.NoEncryption(),
    ).decode()
    token = status._asc_token("KEY123", "issuer-uuid", pem)
    assert jwt.get_unverified_header(token) == {"alg": "ES256", "kid": "KEY123", "typ": "JWT"}
    claims = jwt.decode(token, key.public_key(), algorithms=["ES256"], audience="appstoreconnect-v1")
    assert claims["iss"] == "issuer-uuid"
    assert claims["exp"] - claims["iat"] <= 1200
