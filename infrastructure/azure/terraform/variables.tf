variable "resource_group_name" {
  description = "Azure resource group name"
  type        = string
  default     = "rg-stage1-aks"
}

variable "location" {
  description = "Zone of the Azure AKS cluster"
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
  default     = "Standard_B2s"
}

variable "tier" {
  description = "Tier of the AZURE subscription"
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
  description = "Name of the cluster on AKS"
  type        = string
  default     = "aks-stage1-platform"
}