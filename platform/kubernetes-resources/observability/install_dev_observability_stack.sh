#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLATFORM_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

"$PLATFORM_ROOT/scripts/cloud/validate_dev_cluster_access.sh"

exec "$SCRIPT_DIR/scripts/cluster/install_shared_observability_stack.sh" "$@"
