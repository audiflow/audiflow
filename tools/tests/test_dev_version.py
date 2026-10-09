"""Runs tools/dev-version.sh against scratch repos."""
from __future__ import annotations

import subprocess
from pathlib import Path

import pytest

SCRIPT = Path(__file__).resolve().parent.parent / "dev-version.sh"


def _git(repo: Path, *arguments: str) -> None:
    subprocess.run(["git", *arguments], cwd=repo, check=True, capture_output=True)


def _commit(repo: Path, message: str) -> None:
    _git(repo, "-c", "user.name=t", "-c", "user.email=t@example.com", "commit", "-q",
         "--allow-empty", "-m", message)


@pytest.fixture
def repo(tmp_path: Path) -> Path:
    path = tmp_path / "repo"
    path.mkdir()
    _git(path, "init", "-q")
    _commit(path, "first")
    return path


def _run(cwd: Path) -> subprocess.CompletedProcess[str]:
    return subprocess.run(["bash", str(SCRIPT)], cwd=cwd, capture_output=True, text=True)


def test_prints_version_and_build_of_stg_tag(repo: Path) -> None:
    _git(repo, "tag", "stg-2.2.0+62")
    result = _run(repo)
    assert result.returncode == 0
    assert result.stdout == "2.2.0 62\n"


def test_uses_newest_stg_tag_behind_head(repo: Path) -> None:
    _git(repo, "tag", "stg-2.1.0+58")
    _commit(repo, "second")
    _git(repo, "tag", "stg-2.2.0+62")
    _commit(repo, "work in progress")
    assert _run(repo).stdout == "2.2.0 62\n"


def test_ignores_prod_tags(repo: Path) -> None:
    _git(repo, "tag", "stg-2.1.0+58")
    _commit(repo, "second")
    _git(repo, "tag", "v2.1.0+58")
    assert _run(repo).stdout == "2.1.0 58\n"


def test_prints_nothing_without_stg_tag(repo: Path) -> None:
    result = _run(repo)
    assert result.returncode == 0
    assert result.stdout == ""


def test_prints_nothing_for_malformed_tag(repo: Path) -> None:
    _git(repo, "tag", "stg-2.2.0")
    result = _run(repo)
    assert result.returncode == 0
    assert result.stdout == ""


def test_prints_nothing_outside_git_repo(tmp_path: Path) -> None:
    result = _run(tmp_path)
    assert result.returncode == 0
    assert result.stdout == ""
