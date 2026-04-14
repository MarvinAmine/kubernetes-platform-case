#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "STEP 1/4 - Creating or reconciling the remote Terraform backend..."
"$SCRIPT_DIR/terraform-backend/create_remote_backend.sh"

echo
echo "STEP 2/4 - Creating or reconciling Azure Infrastructure..."
"$SCRIPT_DIR/azure/create_azure_resources.sh"

echo
echo "STEP 3/4 - Creating or reconciling Kubernetes resources..."
"$SCRIPT_DIR/kubernetes-resources/apply_kubernetes_resources.sh"

echo
read -r -p  "Do you also want to create the Azure OIDC federation configuration? Type yes or no: " CREATE_OIDC

if [[ "$CREATE_OIDC" == "yes" ]]; then
    echo "STEP 4/4 - Creating or reconciling Azure OIDC for GitHub..."
    "$SCRIPT_DIR/azure/oidc/create_az_oidc.sh"
else
    echo
    echo "STEP 4/4 - Skipping the creation or reconciliation of Azure OIDC for GitHub."
fi

echo
echo "Platform provisioning completed."