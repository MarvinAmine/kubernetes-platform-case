#!/usr/bin/env bash

load_repo_env() {
    local env_file="$1"
    local env_template="${2:-}"

    if [[ ! -f "$env_file" ]]; then
        if [[ -n "$env_template" ]]; then
            echo "Missing $env_file. Copy $env_template to $env_file and set the required values first."
        else
            echo "Missing $env_file."
        fi
        return 1
    fi

    set -a
    # shellcheck disable=SC1090
    source "$env_file"
    set +a
}

require_env_vars() {
    local env_file="$1"
    shift

    local missing=()
    local var_name
    for var_name in "$@"; do
        if [[ -z "${!var_name:-}" ]]; then
            missing+=("$var_name")
        fi
    done

    if (( ${#missing[@]} > 0 )); then
        echo "Missing required values in $env_file: ${missing[*]}"
        return 1
    fi
}

export_backend_bootstrap_tf_vars() {
    export TF_VAR_subscription_id="$SUBSCRIPTION_ID"
    export TF_VAR_location="$LOCATION"
    export TF_VAR_backend_resource_group_name="$TF_BACKEND_RESOURCE_GROUP"
    export TF_VAR_backend_storage_account_name="$TF_BACKEND_STORAGE_ACCOUNT"
    export TF_VAR_backend_container_name="$TF_BACKEND_CONTAINER"
}

export_azure_infra_tf_vars() {
    export TF_VAR_subscription_id="$SUBSCRIPTION_ID"
    export TF_VAR_resource_group_name="$RESOURCE_GROUP"
    export TF_VAR_location="$LOCATION"
    export TF_VAR_aks_cluster_name="$AKS_CLUSTER_NAME"
    export TF_VAR_dns_prefix="${DNS_PREFIX:-aks-stage1}"
    export TF_VAR_node_count="${NODE_COUNT:-1}"
    export TF_VAR_vm_size="${VM_SIZE:-Standard_D2as_v6}"
    export TF_VAR_tier="${TIER:-Free}"

    export TF_VAR_postgres_server_name="$POSTGRES_SERVER_NAME"
    export TF_VAR_postgres_database_name="$POSTGRES_DATABASE_NAME"
    export TF_VAR_postgres_admin_username="$POSTGRES_ADMIN_USERNAME"
    export TF_VAR_postgres_admin_password="$POSTGRES_ADMIN_PASSWORD"
    export TF_VAR_postgres_version="${POSTGRES_VERSION:-16}"
    export TF_VAR_postgres_sku_name="$POSTGRES_SKU_NAME"
    export TF_VAR_postgres_storage_mb="${POSTGRES_STORAGE_MB:-32768}"
    export TF_VAR_postgres_backup_retention_days="${POSTGRES_BACKUP_RETENTION_DAYS:-7}"
    export TF_VAR_postgres_zone="${POSTGRES_ZONE:-1}"

    export TF_VAR_vnet_name="${VNET_NAME:-vnet-stage1-platform}"
    export TF_VAR_vnet_address_space="${VNET_ADDRESS_SPACE:-10.20.0.0/16}"
    export TF_VAR_aks_subnet_name="${AKS_SUBNET_NAME:-snet-stage1-aks}"
    export TF_VAR_aks_subnet_prefix="${AKS_SUBNET_PREFIX:-10.20.1.0/24}"
    export TF_VAR_postgres_subnet_name="${POSTGRES_SUBNET_NAME:-snet-stage1-postgres}"
    export TF_VAR_postgres_subnet_prefix="${POSTGRES_SUBNET_PREFIX:-10.20.2.0/28}"
    export TF_VAR_postgres_private_dns_zone_name="${POSTGRES_PRIVATE_DNS_ZONE_NAME:-stage1-platform.postgres.database.azure.com}"
    export TF_VAR_postgres_private_dns_zone_link_name="${POSTGRES_PRIVATE_DNS_ZONE_LINK_NAME:-stage1-platform-postgres-dns-link}"
}
