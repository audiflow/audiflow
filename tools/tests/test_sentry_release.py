"""Runs tools/sentry-release.sh against a fake sentry-cli and a scratch repo."""
from __future__ import annotations

import os
import subprocess
from pathlib import Path

import pytest

SCRIPT = Path(__file__).resolve().parent.parent / "sentry-release.sh"

# Logs each call and answers `releases info` / `deploys list` from env. With
# FAKE_API_ERROR set, lookups fail the way sentry-cli reports an API error;
# a missing release is a silent exit 1.
FAKE_SENTRY_CLI = """#!/usr/bin/env bash
echo "$*" >> "$FAKE_LOG"
if [ -n "$FAKE_API_ERROR" ]; then
  case "$*" in
    "releases info "*|"releases deploys "*" list")
      echo "error: API request failed" >&2
      exit 1
      ;;
  esac
fi
case "$*" in
  "releases info "*) [ -n "$FAKE_RELEASE_EXISTS" ] || exit 1 ;;
  "releases deploys "*" list") printf '%b' "$FAKE_DEPLOYS" ;;
esac
"""

DEPLOY_TABLE = (
    "+-------------+---------+----------+\\n"
    "| Environment | Name    | Finished |\\n"
    "+-------------+---------+----------+\\n"
    "| {env:<11} | unnamed | 1h ago   |\\n"
    "+-------------+---------+----------+\\n"
)


def _git(repo: Path, *arguments: str) -> None:
    subprocess.run(["git", *arguments], cwd=repo, check=True, capture_output=True)


@pytest.fixture
def workspace(tmp_path: Path) -> Path:
    repo = tmp_path / "repo"
    repo.mkdir()
    _git(repo, "init", "-q")
    _git(repo, "-c", "user.name=t", "-c", "user.email=t@example.com", "commit", "-q",
         "--allow-empty", "-m", "first")
    _git(repo, "tag", "v2.1.0+58")
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    fake = bin_dir / "sentry-cli"
    fake.write_text(FAKE_SENTRY_CLI)
    fake.chmod(0o755)
    return tmp_path


def _run(
    workspace: Path,
    *arguments: str,
    exists: bool = False,
    deploys: str = "No deploys found\\n",
    api_error: bool = False,
):
    log = workspace / "calls.log"
    log.write_text("")
    env = {
        **os.environ,
        "PATH": f"{workspace / 'bin'}{os.pathsep}{os.environ['PATH']}",
        "FAKE_LOG": str(log),
        "FAKE_RELEASE_EXISTS": "1" if exists else "",
        "FAKE_DEPLOYS": deploys,
        "FAKE_API_ERROR": "1" if api_error else "",
    }
    result = subprocess.run(
        ["bash", str(SCRIPT), *arguments], cwd=workspace / "repo", env=env,
        capture_output=True, text=True,
    )
    return result, log.read_text().splitlines()


def test_creates_both_platform_releases_without_deploy(workspace: Path) -> None:
    result, calls = _run(workspace, "prod", "2.1.0+58")
    assert result.returncode == 0, result.stderr
    assert "releases new com.reedom.audiflow@2.1.0+58" in calls
    assert "releases new com.reedom.audiflow_app@2.1.0+58" in calls
    assert not any("deploys" in call for call in calls)


@pytest.mark.parametrize(
    ("arguments", "app_id"),
    [
        (["--platform", "ios", "--deploy"], "com.reedom.audiflow"),
        (["--deploy", "--platform", "android"], "com.reedom.audiflow_app"),
    ],
)
def test_platform_restricts_to_one_release(workspace: Path, arguments: list[str], app_id: str) -> None:
    result, calls = _run(workspace, "prod", "2.1.0+58", *arguments)
    assert result.returncode == 0, result.stderr
    released = [call.split()[-1] for call in calls if call.startswith("releases new")]
    assert released == [f"{app_id}@2.1.0+58"]
    assert f"releases deploys {app_id}@2.1.0+58 new -e prod" in calls


CREATE_CALLS = ("releases new", "releases set-commits", "releases finalize")


def _created(calls: list[str]) -> list[str]:
    return [call for call in calls if call.startswith(CREATE_CALLS)]


def test_deploy_creates_missing_release_then_deploys(workspace: Path) -> None:
    result, calls = _run(workspace, "prod", "2.1.0+58", "--deploy", "--platform", "ios")
    assert result.returncode == 0, result.stderr
    assert [call.split()[1] for call in _created(calls)] == ["new", "set-commits", "finalize"]
    assert calls[-1] == "releases deploys com.reedom.audiflow@2.1.0+58 new -e prod"


def test_deploy_to_existing_release_only_records_deploy(workspace: Path) -> None:
    result, calls = _run(workspace, "prod", "2.1.0+58", "--deploy", "--platform", "ios", exists=True)
    assert result.returncode == 0, result.stderr
    # finalize would move the release date, so an existing release is left as is.
    assert _created(calls) == []
    assert "releases deploys com.reedom.audiflow@2.1.0+58 new -e prod" in calls


def test_records_deploy_when_only_other_environment_has_one(workspace: Path) -> None:
    result, calls = _run(workspace, "prod", "2.1.0+58", "--deploy", "--platform", "ios",
                         exists=True, deploys=DEPLOY_TABLE.format(env="production"))
    assert result.returncode == 0, result.stderr
    assert "releases deploys com.reedom.audiflow@2.1.0+58 new -e prod" in calls


def test_skips_release_already_deployed(workspace: Path) -> None:
    result, calls = _run(workspace, "prod", "2.1.0+58", "--deploy", "--platform", "ios",
                         exists=True, deploys=DEPLOY_TABLE.format(env="prod"))
    assert result.returncode == 0, result.stderr
    assert "already has a deploy to prod" in result.stdout
    assert _created(calls) == []
    assert not any(call.endswith("new -e prod") for call in calls)


def test_without_deploy_existing_release_is_updated(workspace: Path) -> None:
    result, calls = _run(workspace, "prod", "2.1.0+58", "--platform", "ios", exists=True)
    assert result.returncode == 0, result.stderr
    assert [call.split()[1] for call in _created(calls)] == ["new", "set-commits", "finalize"]


@pytest.mark.parametrize(
    ("exists", "deploys", "code"),
    [
        (True, DEPLOY_TABLE.format(env="prod"), 0),
        (True, DEPLOY_TABLE.format(env="production"), 4),
        (True, "No deploys found\\n", 4),
        (False, "No deploys found\\n", 4),
    ],
)
def test_check_deployed_reports_without_changing_anything(
    workspace: Path, exists: bool, deploys: str, code: int
) -> None:
    result, calls = _run(workspace, "prod", "2.1.0+58", "--check-deployed", "--platform", "android",
                         exists=exists, deploys=deploys)
    assert result.returncode == code, result.stderr
    assert _created(calls) == []
    assert not any(call.endswith("new -e prod") for call in calls)


@pytest.mark.parametrize(
    "arguments",
    [["--platform"], ["--platform", "web"], ["--bogus"], ["--deploy", "extra"],
     ["--deploy", "--check-deployed"]],
)
def test_rejects_bad_options(workspace: Path, arguments: list[str]) -> None:
    result, calls = _run(workspace, "prod", "2.1.0+58", *arguments)
    assert result.returncode == 2
    assert "Usage:" in result.stderr
    assert calls == []


@pytest.mark.parametrize("exists", [False, True])
def test_check_deployed_fails_on_sentry_errors(workspace: Path, exists: bool) -> None:
    result, _ = _run(
        workspace, "prod", "2.1.0+58", "--check-deployed", "--platform", "ios",
        exists=exists, api_error=True,
    )
    # Not EXIT_NOT_DEPLOYED (4): a broken token or an outage must not read
    # as a build that simply has no deploy yet.
    assert result.returncode not in (0, 4)
    assert "error: API request failed" in result.stderr


def test_deploy_stops_on_sentry_errors(workspace: Path) -> None:
    result, calls = _run(
        workspace, "prod", "2.1.0+58", "--deploy", "--platform", "ios", api_error=True,
    )
    assert result.returncode != 0
    assert not any(call.startswith("releases new") for call in calls)
    assert not any(call.endswith("new -e prod") for call in calls)
