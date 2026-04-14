output "backend_resource_group_name" {
  description = "Terraform backend resource group"
  value       = azurerm_resource_group.tfstate.name
}

output "backend_storage_account_name" {
  description = "Terraform backend storage account"
  value       = azurerm_storage_account.tfstate.name
}

output "backend_container_name" {
  description = "Terraform backend blob container"
  value       = azurerm_storage_container.tfstate.name
}