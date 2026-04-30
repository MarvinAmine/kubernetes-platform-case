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

output "postgres_server_name" {
  description = "Name of the PostgreSQL Flexible Server"
  value       = azurerm_postgresql_flexible_server.app.name
}

output "postgres_fqdn" {
  description = "FQDN of the PostgreSQL Flexible Server"
  value       = azurerm_postgresql_flexible_server.app.fqdn
}

output "postgres_database_name" {
  description = "Application PostgreSQL database name"
  value       = azurerm_postgresql_flexible_server_database.app.name
}

output "postgres_admin_username" {
  description = "Administrator username for PostgreSQL Flexible Server"
  value       = azurerm_postgresql_flexible_server.app.administrator_login
}

output "vnet_name" {
  description = "Platform virtual network name"
  value       = azurerm_virtual_network.platform.name
}

output "aks_subnet_name" {
  description = "AKS subnet name"
  value       = azurerm_subnet.aks.name
}

output "postgres_subnet_name" {
  description = "PostgreSQL delegated subnet name"
  value       = azurerm_subnet.postgres.name
}

output "postgres_private_dns_zone_name" {
  description = "Private DNS zone used by PostgreSQL Flexible Server"
  value       = azurerm_private_dns_zone.postgres.name
}