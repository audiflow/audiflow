#!/usr/bin/env bash
# Sync secret files between this repo and the private audiflow-secrets repo.
#
# audiflow-secrets mirrors this repo's paths: <secrets>/.env.dev is decrypted
# to ./.env.dev, and so on. Every file in it is sops-encrypted with age.
#
# Usage:
#   tools/secrets.sh pull               clone or update audiflow-secrets, then decrypt
#   tools/secrets.sh decrypt [path...]  decrypt every secret (or only the given paths) into this repo
#   tools/secrets.sh encrypt <path>...  encrypt plaintext files from this repo into audiflow-secrets
#   tools/secrets.sh updatekeys         re-encrypt every secret for the recipients in .sops.yaml
set -euo pipefail

readonly REPO_ROOT="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
# Worktrees live next to the primary checkout, so the sibling path resolves for both.
readonly SECRETS_DIR="${AUDIFLOW_SECRETS_DIR:-$(dirname "$REPO_ROOT")/audiflow-secrets}"
readonly SECRETS_REMOTE="git@github.com:audiflow/audiflow-secrets.git"

# dotenv stays structured so audiflow-secrets diffs show which key changed.
# Everything else is binary: sops's json store reformats on output, and the
# decrypted copy should match the original byte for byte.
sops_type_for() {
  case "$(basename "$1")" in
    .env.*) echo dotenv ;;
    *) echo binary ;;
  esac
}

# Accepts both a regular clone and a linked worktree (whose .git is a file).
is_secrets_checkout() {
  [[ -d "$SECRETS_DIR" ]] && git -C "$SECRETS_DIR" rev-parse --git-dir > /dev/null 2>&1
}

require_secrets_dir() {
  is_secrets_checkout && return 0
  echo "audiflow-secrets not found at $SECRETS_DIR." >&2
  echo "Maintainers: run 'mise run secrets:pull'." >&2
  echo "Contributors: create .env.* and Firebase configs yourself (see README)." >&2
  return 1
}

list_secret_files() {
  git -C "$SECRETS_DIR" ls-files | grep -vxE '\.sops\.yaml|README\.md'
}

decrypt_one() {
  local rel="$1" type
  type="$(sops_type_for "$rel")"
  mkdir -p "$(dirname "$REPO_ROOT/$rel")"
  (umask 077 && sops decrypt --input-type "$type" --output-type "$type" \
    "$SECRETS_DIR/$rel" > "$REPO_ROOT/$rel.tmp")
  mv "$REPO_ROOT/$rel.tmp" "$REPO_ROOT/$rel"
  echo "decrypted $rel"
}

decrypt_all() {
  require_secrets_dir || return 0
  local rel
  while IFS= read -r rel; do
    decrypt_one "$rel"
  done < <(list_secret_files)
}

# CI decrypts only what the job needs, so a missing path is an error, not a skip.
decrypt_paths() {
  require_secrets_dir
  local rel
  for rel in "$@"; do
    rel="${rel#./}"
    [[ -f "$SECRETS_DIR/$rel" ]] || { echo "not in audiflow-secrets: $rel" >&2; return 1; }
    decrypt_one "$rel"
  done
}

pull() {
  if is_secrets_checkout; then
    git -C "$SECRETS_DIR" pull --ff-only
  else
    git clone "$SECRETS_REMOTE" "$SECRETS_DIR"
  fi
  decrypt_all
}

# Fails when the encrypted copy does not decrypt back to the exact plaintext,
# e.g. a dotenv value that sops would requote.
verify_roundtrip() {
  local rel="$1" type="$2" encrypted="$3"
  sops decrypt --input-type "$type" --output-type "$type" "$encrypted" \
    | cmp -s - "$REPO_ROOT/$rel" && return 0
  echo "roundtrip mismatch for $rel; encrypted copy differs from plaintext" >&2
  return 1
}

encrypt_one() {
  local rel="$1" type
  [[ -f "$REPO_ROOT/$rel" ]] || { echo "no such file: $rel" >&2; return 1; }
  type="$(sops_type_for "$rel")"
  mkdir -p "$(dirname "$SECRETS_DIR/$rel")"
  # Encrypt into a temp file and swap it in only after the roundtrip passes,
  # so a failed run never truncates the existing encrypted copy. A unique name
  # keeps overlapping runs apart; the same directory keeps the mv atomic.
  local tmp
  tmp="$(mktemp "$SECRETS_DIR/$rel.XXXXXX")"
  # Run inside audiflow-secrets so sops picks up its .sops.yaml recipients.
  if ! (cd "$SECRETS_DIR" && sops encrypt --input-type "$type" --output-type "$type" \
      --filename-override "$rel" "$REPO_ROOT/$rel" > "$tmp") \
    || ! verify_roundtrip "$rel" "$type" "$tmp"; then
    rm -f "$tmp"
    return 1
  fi
  mv "$tmp" "$SECRETS_DIR/$rel"
  echo "encrypted $rel"
}

encrypt() {
  (( 0 < $# )) || { echo "usage: $0 encrypt <path>..." >&2; return 1; }
  require_secrets_dir
  local rel
  for rel in "$@"; do
    encrypt_one "${rel#./}"
  done
  echo "Review and commit in $SECRETS_DIR."
}

# sops guesses the format from the extension and reads .env.dev as binary,
# so pass the type explicitly, as decrypt and encrypt do.
updatekeys() {
  require_secrets_dir
  local rel
  while IFS= read -r rel; do
    (cd "$SECRETS_DIR" && sops updatekeys --yes --input-type "$(sops_type_for "$rel")" "$rel")
  done < <(list_secret_files)
  echo "Review and commit in $SECRETS_DIR."
}

main() {
  local command="${1:-}"
  shift || true
  case "$command" in
    pull) pull ;;
    decrypt) if (( 0 < $# )); then decrypt_paths "$@"; else decrypt_all; fi ;;
    encrypt) encrypt "$@" ;;
    updatekeys) updatekeys ;;
    *) sed -n '2,11p' "$0" >&2; return 1 ;;
  esac
}

main "$@"
