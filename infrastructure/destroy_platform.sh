#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo
echo "STEP 1/4 - Destroying Kubernetes resources..."
"$SCRIPT_DIR/kubernetes-resources/destroy_kubernetes_resources.sh"

echo
echo "STEP 2/4 - Destroying Azure infrastructure..."
"$SCRIPT_DIR/azure/destroy_azure_resources.sh"

echo
echo "Step 3/4 - Destroying the remote Terraform backend..."
"$SCRIPT_DIR/terraform-backend/destroy_remote_backend.sh"

echo

read -r -p  "Do you also want to destroy the Azure OIDC federation configuration? Type yes or no: " DESTROY_OIDC

if [[ "$DESTROY_OIDC" == "yes" ]]; then
    echo "STEP 4/4 - Destroying Azure OIDC for GitHub..."
    "$SCRIPT_DIR/azure/oidc/destroy_az_oidc.sh"
else
    echo 
    echo "STEP 4/4 - Skipping Azure OIDC federation destruction."
fi

echo
echo "Platform teardown completed."