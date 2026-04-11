output "resource_group_name" {
  value       = azurerm_resource_group.aks.name
  description = "Created Azure resource group"
}

output "aks_cluster_name" {
  value       = azurerm_kubernetes_cluster.aks.name
  description = "Created AKS cluster name"
}

output "aks_location" {
  value       = azurerm_kubernetes_cluster.aks.location
  description = "Azure location"
}