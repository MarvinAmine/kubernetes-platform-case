variable "resource_group_name" {
  description = "Azure resource group name"
  type        = string
  default     = "rg-stage1-aks"
}

variable "location" {
  description = "Azure region for the AKS cluster and PostgreSQL resources"
  type        = string
  default     = "canadacentral"
}

variable "dns_prefix" {
  description = "DNS prefix for AKS"
  type        = string
  default     = "aks-stage1"
}

variable "node_count" {
  description = "Number of AKS nodes"
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_D2as_v6"
}

variable "tier" {
  description = "AKS SKU tier"
  type        = string
  default     = "Free"
}

variable "tags" {
  description = "Common tags of the Azure resources (environment, owner and project)"
  type        = map(string)

  default = {
    environment = "stage1"
    owner       = "infrastructure-team"
    project     = "kubernetes-platform-case"
  }
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "aks-stage1-platform"
}

variable "postgres_server_name" {
  description = "Name of the Azure Database for PostgreSQL Flexible Server"
  type        = string
}

variable "postgres_database_name" {
  description = "Name of the PostgreSQL database used by the application"
  type        = string
}

variable "postgres_admin_username" {
  description = "Administrator username for PostgreSQL Flexible Server"
  type        = string
}

variable "postgres_admin_password" {
  description = "Administrator password for PostgreSQL Flexible Server"
  type        = string
  sensitive   = true
}

variable "postgres_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "16"
}

variable "postgres_sku_name" {
  description = "SKU name for PostgreSQL Flexible Server"
  type        = string
}

variable "postgres_storage_mb" {
  description = "Storage size in MB for PostgreSQL Flexible Server"
  type        = number
  default     = 32768
}

variable "postgres_backup_retention_days" {
  description = "Backup retention in days"
  type        = number
  default     = 7
}

variable "postgres_zone" {
  description = "Availability zone for PostgreSQL Flexible Server"
  type        = string
  default     = "1"
}


variable "vnet_name" {
  description = "Name of the platform virtual network"
  type        = string
  default     = "vnet-stage1-platform"
}

variable "vnet_address_space" {
  description = "Address space for the platform virtual network"
  type        = string
  default     = "10.20.0.0/16"
}

variable "aks_subnet_name" {
  description = "Name of the AKS subnet"
  type        = string
  default     = "snet-stage1-aks"
}

variable "aks_subnet_prefix" {
  description = "Address prefix for the AKS subnet"
  type        = string
  default     = "10.20.1.0/24"
}

variable "postgres_subnet_prefix" {
  description = "Address prefix for the PostgreSQL delegated subnet"
  type        = string
  default     = "10.20.2.0/28"
}

variable "postgres_private_dns_zone_link_name" {
  description = "Private DNS zone link name for the platform virtual network"
  type        = string
  default     = "stage1-platform-postgres-dns-link"
}

variable "postgres_subnet_name" {
  description = "Name of the PostgreSQL delegated subnet"
  type        = string
  default     = "snet-stage1-postgres"
}

variable "postgres_private_dns_zone_name" {
  description = "Private DNS zone for PostgreSQL Flexible Server"
  type        = string
  default     = "stage1-platform.postgres.database.azure.com"
}