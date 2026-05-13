#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
SOURCE_DIR="$REPO_ROOT/reliability/observability/grafana/dashboards"
TARGET_DIR="$SCRIPT_DIR/staged/reliability"

mkdir -p "$TARGET_DIR"

if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "ERROR: reliability dashboard source directory not found: $SOURCE_DIR"
    exit 1
fi

find "$TARGET_DIR" -maxdepth 1 -type f -name '*.json' -delete

copied_count=0
while IFS= read -r source_file; do
    cp "$source_file" "$TARGET_DIR/$(basename "$source_file")"
    copied_count=$((copied_count + 1))
done < <(find "$SOURCE_DIR" -maxdepth 1 -type f -name '*.json' | sort)

if [[ "$copied_count" -eq 0 ]]; then
    echo "ERROR: no reliability dashboard JSON files found in $SOURCE_DIR"
    exit 1
fi

echo "Staged ${copied_count} reliability dashboard(s) into ${TARGET_DIR}."
