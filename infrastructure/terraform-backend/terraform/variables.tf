variable "subscription_id" {
    description = "Azure subscription ID"
    type        = string
}

variable "location" {
    description = "Azure region for the Terraform backend resources"
    type        = string
    default     = "canadacentral"
}

variable "backend_resource_group_name" {
    description = "Resource group that stores the Terraform backend"
    type        = string
    default     = "rg-stage1-tfstate"
}

variable "backend_container_name" {
    description = "Blob container name for Terraform state files"
    type        = string
    default     = "tfstate"
}

variable "backend_storage_account_name" {
    description = "Name of the backend storgage account name"
    type        = string
    default     = "marvintfbackendstage1"
}

variable "tags" {
    description = "Common tags for backend resources"
    type        = map(string)

    default = {
        environment = "stage1"
        owner       = "infrastructure-team"
        project     = "kubernetes-platform-case"
    }
}