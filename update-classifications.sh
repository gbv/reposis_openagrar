#!/usr/bin/env bash
#
# Downloads classifications from a running MyCoRe/MIR instance and keeps the
# setup file in sync with the classification files on disk.
#
# By default only classifications that already exist in the local directory are
# refreshed. The remote id is taken from the root @ID of the local file, so a
# file name that differs from the classification id (sdnb.xml -> SDNB) works.
#
set -euo pipefail

BASE_URL="https://www.openagrar.de/api/v2/classifications"
RESOURCE_DIR=""
CLASS_DIR=""
SETUP_FILE=""
DRY_RUN=false
FETCH_ALL=false
EXTRA_IDS=()
EXIT_CODE=0

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'USAGE_EOF'
Usage: update-classifications.sh [OPTIONS]

Options:
  -u, --base-url URL   classification API base url
                       (default: https://www.openagrar.de/api/v2/classifications)
  -d, --dir DIR        classification directory
                       (default: <script dir>/src/main/resources/classifications)
  -s, --setup FILE     setup file to sync
                       (default: the only setup_*.txt next to the classification directory)
  -a, --add ID         additionally fetch this classification id, may be repeated
      --all            fetch every classification the server offers
  -n, --dry-run        report changes without writing anything
  -h, --help           show this help

Exit code is 1 if a classification could not be fetched.
USAGE_EOF
}

log() { printf '%s\n' "$*"; }
warn() { printf 'WARN  %s\n' "$*" >&2; }
die() { printf 'ERROR %s\n' "$*" >&2; exit 2; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    -u|--base-url) [[ $# -ge 2 ]] || die "missing value for $1"; BASE_URL="${2%/}"; shift 2 ;;
    -d|--dir)      [[ $# -ge 2 ]] || die "missing value for $1"; CLASS_DIR="$2"; shift 2 ;;
    -s|--setup)    [[ $# -ge 2 ]] || die "missing value for $1"; SETUP_FILE="$2"; shift 2 ;;
    -a|--add)      [[ $# -ge 2 ]] || die "missing value for $1"; EXTRA_IDS+=("$2"); shift 2 ;;
    --all)         FETCH_ALL=true; shift ;;
    -n|--dry-run)  DRY_RUN=true; shift ;;
    -h|--help)     usage; exit 0 ;;
    *)             die "unknown option: $1" ;;
  esac
done

for tool in curl xmllint; do
  command -v "$tool" >/dev/null 2>&1 || die "$tool is required but not installed"
done

[[ -n "$CLASS_DIR" ]] || CLASS_DIR="$SCRIPT_DIR/src/main/resources/classifications"
[[ -d "$CLASS_DIR" ]] || die "classification directory not found: $CLASS_DIR"
CLASS_DIR="$(cd -- "$CLASS_DIR" && pwd)"
RESOURCE_DIR="$(dirname -- "$CLASS_DIR")"

if [[ -z "$SETUP_FILE" ]]; then
  mapfile -t setup_candidates < <(find "$RESOURCE_DIR" -maxdepth 1 -type f -name 'setup_*.txt' | sort)
  case "${#setup_candidates[@]}" in
    0) die "no setup_*.txt found in $RESOURCE_DIR, use --setup" ;;
    1) SETUP_FILE="${setup_candidates[0]}" ;;
    *) die "several setup_*.txt found in $RESOURCE_DIR, use --setup" ;;
  esac
fi
[[ -f "$SETUP_FILE" ]] || die "setup file not found: $SETUP_FILE"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

# --- remote inventory ------------------------------------------------------

log "Fetching classification list from $BASE_URL/"
if ! curl -fsS -H 'Accept: application/xml' "$BASE_URL/" -o "$TMP_DIR/list.xml"; then
  die "could not fetch classification list"
fi
xmllint --xpath '//mycoreclass/@ID' "$TMP_DIR/list.xml" 2>/dev/null \
  | tr ' ' '\n' \
  | sed -n 's/^ID="\(.*\)"$/\1/p' \
  | sort > "$TMP_DIR/remote-ids.txt"
remote_count="$(wc -l < "$TMP_DIR/remote-ids.txt")"
[[ "$remote_count" -gt 0 ]] || die "classification list is empty, is $BASE_URL correct?"
log "Server offers $remote_count classifications"
log ""

# --- build work list: "<id> <filename>" ------------------------------------

: > "$TMP_DIR/work.txt"
for file in "$CLASS_DIR"/*.xml; do
  [[ -e "$file" ]] || continue
  name="$(basename -- "$file")"
  id="$(xmllint --xpath 'string(/mycoreclass/@ID)' "$file" 2>/dev/null || true)"
  if [[ -z "$id" ]]; then
    warn "$name has no /mycoreclass/@ID, skipped"
    EXIT_CODE=1
    continue
  fi
  printf '%s %s\n' "$id" "$name" >> "$TMP_DIR/work.txt"
done

add_remote_id() {
  local id="$1"
  grep -qx "$id" "$TMP_DIR/remote-ids.txt" || { warn "unknown classification id on server: $id"; EXIT_CODE=1; return; }
  awk -v id="$id" '$1 == id { found = 1 } END { exit !found }' "$TMP_DIR/work.txt" && return
  printf '%s %s.xml\n' "$id" "$id" >> "$TMP_DIR/work.txt"
}

if [[ "$FETCH_ALL" == true ]]; then
  while read -r id; do add_remote_id "$id"; done < "$TMP_DIR/remote-ids.txt"
fi
for id in ${EXTRA_IDS[@]+"${EXTRA_IDS[@]}"}; do add_remote_id "$id"; done

sort -k2 -o "$TMP_DIR/work.txt" "$TMP_DIR/work.txt"

# --- download --------------------------------------------------------------

created=0
updated=0
unchanged=0
failed=0

normalize() {
  # pretty print and match the formatting of the existing classification files
  local src="$1" dst="$2"
  xmllint --format "$src" \
    | sed -e '1s|.*|<?xml version="1.0" encoding="UTF-8"?>|' \
          -e 's|"/>$|" />|' > "$dst"
  if ! grep -q 'xsi:noNamespaceSchemaLocation' "$dst"; then
    sed -i '0,/<mycoreclass /s|\(<mycoreclass [^>]*\) ID="|\1 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="MCRClassification.xsd" ID="|' "$dst"
  fi
}

while read -r id name; do
  target="$CLASS_DIR/$name"
  raw="$TMP_DIR/raw.xml"
  new="$TMP_DIR/new.xml"

  http_code="$(curl -sS -w '%{http_code}' -H 'Accept: application/xml' "$BASE_URL/$id" -o "$raw" || echo 000)"
  if [[ "$http_code" != "200" ]]; then
    hint="$(grep -ix "$id" "$TMP_DIR/remote-ids.txt" | head -n1 || true)"
    if [[ -n "$hint" && "$hint" != "$id" ]]; then
      warn "$name: id '$id' -> HTTP $http_code, server spells it '$hint'"
    else
      warn "$name: id '$id' -> HTTP $http_code"
    fi
    failed=$((failed + 1))
    EXIT_CODE=1
    continue
  fi

  normalize "$raw" "$new"
  got_id="$(xmllint --xpath 'string(/mycoreclass/@ID)' "$new" 2>/dev/null || true)"
  if [[ "$got_id" != "$id" ]]; then
    warn "$name: server returned id '$got_id' instead of '$id', skipped"
    failed=$((failed + 1))
    EXIT_CODE=1
    continue
  fi

  if [[ ! -f "$target" ]]; then
    log "new       $name ($id)"
    created=$((created + 1))
    [[ "$DRY_RUN" == true ]] || cp "$new" "$target"
  elif cmp -s "$new" "$target"; then
    unchanged=$((unchanged + 1))
  else
    log "updated   $name ($id, $(diff <(cat "$target") "$new" | grep -c '^[<>]') changed lines)"
    updated=$((updated + 1))
    [[ "$DRY_RUN" == true ]] || cp "$new" "$target"
  fi
done < "$TMP_DIR/work.txt"

# --- sync setup file -------------------------------------------------------

log ""
log "Syncing $(basename -- "$SETUP_FILE")"

added_lines=0
for file in "$CLASS_DIR"/*.xml; do
  [[ -e "$file" ]] || continue
  name="$(basename -- "$file")"
  if grep -qE "classifications/${name//./\\.}[[:space:]]*$" "$SETUP_FILE"; then
    continue
  fi
  line="update classification from uri resource:classifications/$name"
  log "added     $line"
  added_lines=$((added_lines + 1))
  if [[ "$DRY_RUN" == false ]]; then
    [[ -s "$SETUP_FILE" && -z "$(tail -c1 "$SETUP_FILE")" ]] || printf '\n' >> "$SETUP_FILE"
    printf '%s\n' "$line" >> "$SETUP_FILE"
  fi
done

dangling=0
while read -r name; do
  [[ -n "$name" ]] || continue
  if [[ ! -f "$CLASS_DIR/$name" ]]; then
    warn "$(basename -- "$SETUP_FILE") references $name, but no such file in $CLASS_DIR"
    dangling=$((dangling + 1))
    EXIT_CODE=1
  fi
done < <(sed -n 's|.*resource:classifications/\([^[:space:]]*\.xml\).*|\1|p' "$SETUP_FILE")

# --- summary ---------------------------------------------------------------

log ""
log "new: $created, updated: $updated, unchanged: $unchanged, failed: $failed"
log "setup lines added: $added_lines, dangling setup lines: $dangling"
[[ "$DRY_RUN" == true ]] && log "dry run, nothing was written"

exit "$EXIT_CODE"
