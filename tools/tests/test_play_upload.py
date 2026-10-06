from __future__ import annotations

from pathlib import Path
from typing import Any

import pytest
import requests

import play_upload as upload
from store_release_status import StoreStatusError


def _write_notes(directory: Path, **texts: str) -> Path:
    directory.mkdir(parents=True, exist_ok=True)
    for language, text in texts.items():
        (directory / f"{language.replace('_', '-')}.txt").write_text(text, encoding="utf-8")
    return directory


class TestLoadReleaseNotes:
    def test_reads_supported_languages_in_order(self, tmp_path: Path) -> None:
        directory = _write_notes(tmp_path / "android", ja_JP="修正\n", en_US="  Fixes\n\n")
        assert upload.load_release_notes(directory) == [
            {"language": "en-US", "text": "Fixes"},
            {"language": "ja-JP", "text": "修正"},
        ]

    def test_no_directory_given(self) -> None:
        assert upload.load_release_notes(None) == []

    def test_missing_directory_warns(self, tmp_path: Path, capsys: pytest.CaptureFixture[str]) -> None:
        assert upload.load_release_notes(tmp_path / "missing") == []
        assert "No release notes directory" in capsys.readouterr().err

    def test_missing_language_warns_and_keeps_others(
        self, tmp_path: Path, capsys: pytest.CaptureFixture[str]
    ) -> None:
        directory = _write_notes(tmp_path / "android", en_US="Fixes")
        assert upload.load_release_notes(directory) == [{"language": "en-US", "text": "Fixes"}]
        assert "ja-JP" in capsys.readouterr().err

    def test_warning_uses_annotation_on_actions(
        self, tmp_path: Path, monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
    ) -> None:
        monkeypatch.setenv("GITHUB_ACTIONS", "true")
        upload.load_release_notes(tmp_path / "missing")
        assert capsys.readouterr().err.startswith("::warning::")

    def test_ignores_unsupported_languages(self, tmp_path: Path) -> None:
        directory = _write_notes(tmp_path / "android", en_US="Fixes", ja_JP="修正", de_DE="Fehler")
        languages = [note["language"] for note in upload.load_release_notes(directory)]
        assert languages == ["en-US", "ja-JP"]

    def test_empty_file_is_an_error(self, tmp_path: Path) -> None:
        directory = _write_notes(tmp_path / "android", en_US=" \n", ja_JP="修正")
        with pytest.raises(upload.PlayUploadError, match="empty"):
            upload.load_release_notes(directory)

    def test_limit_counts_characters_not_bytes(self, tmp_path: Path) -> None:
        directory = _write_notes(tmp_path / "android", en_US="a" * 500, ja_JP="修" * 500)
        assert len(upload.load_release_notes(directory)) == 2

    def test_over_limit_is_an_error(self, tmp_path: Path) -> None:
        directory = _write_notes(tmp_path / "android", en_US="a" * 501, ja_JP="修正")
        with pytest.raises(upload.PlayUploadError, match="501 characters"):
            upload.load_release_notes(directory)

    def test_committed_notes_fit(self) -> None:
        # Every committed Android note must pass the same checks CI applies.
        root = Path(__file__).resolve().parents[2] / "release-notes"
        for directory in sorted(root.glob("*/android")):
            assert upload.load_release_notes(directory), directory


class TestBuildRelease:
    def test_draft_with_version_code_and_notes(self) -> None:
        notes = [{"language": "en-US", "text": "Fixes"}]
        assert upload.build_release("2.1.0+58", notes) == {
            "name": "2.1.0 (58)",
            "versionCodes": ["58"],
            "status": "draft",
            "releaseNotes": notes,
        }

    def test_omits_empty_notes(self) -> None:
        assert "releaseNotes" not in upload.build_release("2.1.0+58", [])

    def test_rejects_malformed_version(self) -> None:
        with pytest.raises(StoreStatusError):
            upload.build_release("2.1.0", [])


class TestBuildTrackPayload:
    RELEASE = {"name": "2.1.0 (58)", "versionCodes": ["58"], "status": "draft"}

    def test_empty_track(self) -> None:
        assert upload.build_track_payload({"track": "production"}, self.RELEASE) == {
            "track": "production",
            "releases": [self.RELEASE],
        }

    def test_keeps_live_and_rollout_releases_and_replaces_old_draft(self) -> None:
        completed = {"versionCodes": ["51"], "status": "completed"}
        rollout = {"versionCodes": ["55"], "status": "inProgress", "userFraction": 0.2}
        old_draft = {"versionCodes": ["57"], "status": "draft"}
        current = {"track": "production", "releases": [completed, old_draft, rollout]}
        payload = upload.build_track_payload(current, self.RELEASE)
        assert payload["releases"] == [completed, rollout, self.RELEASE]


class FakeResponse:
    def __init__(self, status_code: int = 200, body: dict[str, Any] | None = None) -> None:
        self.status_code = status_code
        self.ok = status_code < 400
        self._body = body
        self.content = b"{}" if body is not None else b""
        self.text = str(body)

    def json(self) -> dict[str, Any]:
        return self._body or {}


class FakeSession:
    """Answers Play edits calls from a script and records what was sent."""

    def __init__(
        self,
        fail_on: str | None = None,
        version_code: int = 58,
        fail_delete: bool = False,
        raise_on: str | None = None,
        raise_error: Exception | None = None,
    ) -> None:
        self.calls: list[tuple[str, str, dict[str, Any]]] = []
        self._raise_on = raise_on
        self._raise_error = raise_error or requests.exceptions.ReadTimeout("timed out")
        self._fail_on = fail_on
        self._version_code = version_code
        self._fail_delete = fail_delete

    def request(self, method: str, url: str, **kwargs: Any) -> FakeResponse:
        self.calls.append((method, url, kwargs))
        step = self._step(method, url)
        if step == self._raise_on:
            raise self._raise_error
        if step == "delete" and self._fail_delete:
            return FakeResponse(500, {"error": "boom"})
        if step == self._fail_on:
            return FakeResponse(403, {"error": "denied"})
        return FakeResponse(200, self._body(step))

    @staticmethod
    def _step(method: str, url: str) -> str:
        if url.endswith(":commit"):
            return "commit"
        if "/bundles" in url:
            return "upload"
        if "/tracks/" in url:
            return "get_track" if method == "GET" else "update_track"
        return "insert" if method == "POST" else "delete"

    def _body(self, step: str) -> dict[str, Any] | None:
        bodies: dict[str, dict[str, Any] | None] = {
            "insert": {"id": "edit-1"},
            "upload": {"versionCode": self._version_code},
            "get_track": {"track": "production", "releases": []},
            "update_track": {"track": "production"},
            "commit": {"id": "edit-1"},
            "delete": None,
        }
        return bodies[step]

    def steps(self) -> list[str]:
        return [self._step(method, url) for method, url, _ in self.calls]


class TestUploadDraft:
    RELEASE = upload.build_release("2.1.0+58", [{"language": "en-US", "text": "Fixes"}])

    def test_runs_edit_in_order(self) -> None:
        session = FakeSession()
        upload.upload_draft(upload.PlayEditsClient(session), b"aab", self.RELEASE)
        assert session.steps() == ["insert", "upload", "get_track", "update_track", "commit"]

    def test_sends_bundle_as_media_upload_and_draft_track(self) -> None:
        session = FakeSession()
        upload.upload_draft(upload.PlayEditsClient(session), b"aab", self.RELEASE)
        _, upload_url, upload_args = session.calls[1]
        assert upload_url.startswith(upload.PLAY_UPLOAD_API)
        assert upload_url.endswith("/com.reedom.audiflow_app/edits/edit-1/bundles")
        assert upload_args["params"] == {"uploadType": "media"}
        assert upload_args["data"] == b"aab"
        _, _, track_args = session.calls[3]
        assert track_args["json"] == {"track": "production", "releases": [self.RELEASE]}

    @pytest.mark.parametrize("failing_step", ["upload", "get_track", "update_track", "commit"])
    def test_failure_deletes_edit(self, failing_step: str) -> None:
        session = FakeSession(fail_on=failing_step)
        with pytest.raises(upload.PlayUploadError):
            upload.upload_draft(upload.PlayEditsClient(session), b"aab", self.RELEASE)
        steps = session.steps()
        assert steps[steps.index(failing_step) + 1 :] == ["delete"]

    def test_version_code_mismatch_deletes_edit(self) -> None:
        session = FakeSession(version_code=57)
        with pytest.raises(upload.PlayUploadError, match="version code 57"):
            upload.upload_draft(upload.PlayEditsClient(session), b"aab", self.RELEASE)
        assert session.steps() == ["insert", "upload", "delete"]

    def test_failed_cleanup_keeps_original_error(self, capsys: pytest.CaptureFixture[str]) -> None:
        session = FakeSession(fail_on="upload", fail_delete=True)
        with pytest.raises(upload.PlayUploadError, match="403"):
            upload.upload_draft(upload.PlayEditsClient(session), b"aab", self.RELEASE)
        assert "Could not delete edit edit-1" in capsys.readouterr().err


class TestUncertainCommit:
    RELEASE = upload.build_release("2.1.0+58", [])

    @pytest.mark.parametrize(
        "error",
        [requests.exceptions.ReadTimeout("timed out"), requests.exceptions.ConnectionError("reset")],
    )
    def test_no_response_keeps_edit(self, error: Exception) -> None:
        session = FakeSession(raise_on="commit", raise_error=error)
        with pytest.raises(upload.CommitOutcomeUnknownError):
            upload.upload_draft(upload.PlayEditsClient(session), b"aab", self.RELEASE)
        assert session.steps() == ["insert", "upload", "get_track", "update_track", "commit"]

    def test_http_error_from_commit_still_deletes_edit(self) -> None:
        session = FakeSession(fail_on="commit")
        with pytest.raises(upload.PlayUploadError) as caught:
            upload.upload_draft(upload.PlayEditsClient(session), b"aab", self.RELEASE)
        assert not isinstance(caught.value, upload.CommitOutcomeUnknownError)
        assert session.steps()[-1] == "delete"

    def test_no_response_before_commit_deletes_edit(self) -> None:
        session = FakeSession(raise_on="upload")
        with pytest.raises(requests.exceptions.ReadTimeout):
            upload.upload_draft(upload.PlayEditsClient(session), b"aab", self.RELEASE)
        assert session.steps() == ["insert", "upload", "delete"]

    def test_main_exits_with_distinct_code_and_error_annotation(
        self, tmp_path: Path, monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
    ) -> None:
        monkeypatch.setenv("GITHUB_ACTIONS", "true")
        monkeypatch.setattr(upload, "play_session", lambda: FakeSession(raise_on="commit"))
        bundle = tmp_path / "app.aab"
        bundle.write_bytes(b"aab")
        assert upload.main([str(bundle), "2.1.0+58"]) == upload.EXIT_COMMIT_UNKNOWN == 4
        error = capsys.readouterr().err
        assert error.startswith("::error::")
        assert "Play Console" in error


class TestMain:
    def test_missing_bundle_is_an_error(self, tmp_path: Path, capsys: pytest.CaptureFixture[str]) -> None:
        assert upload.main([str(tmp_path / "app.aab"), "2.1.0+58"]) == upload.EXIT_ERROR
        assert "App Bundle not found" in capsys.readouterr().err

    def test_missing_credentials_is_an_error(
        self, tmp_path: Path, monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
    ) -> None:
        monkeypatch.delenv("GOOGLE_PLAY_SERVICE_ACCOUNT_JSON", raising=False)
        bundle = tmp_path / "app.aab"
        bundle.write_bytes(b"aab")
        assert upload.main([str(bundle), "2.1.0+58"]) == upload.EXIT_ERROR
        assert "GOOGLE_PLAY_SERVICE_ACCOUNT_JSON" in capsys.readouterr().err
