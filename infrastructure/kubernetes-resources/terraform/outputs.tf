output "app_service_account_name" {
    description = "Runtime service account created for the application team"
    value       = kubernetes_service_account.app_runtime.metadata[0].name
}

output "app_role_name" {
    description = "Role granted to the application runtime identity"
    value       = kubernetes_role.app_runtime.metadata[0].name
}

output "app_role_binding_name" {
    description = "RoleBinding connecting the runtime service account to its Role"
    value       = kubernetes_role_binding.app_runtime.metadata[0].name
}

output "baseline_configmap_name" {
    description = "Platform-owned baseline ConfigMap shared with the application team"
    value       = kubernetes_config_map.platform_baseline.metadata[0].name
}

output "namespace_name" {
    description = "Platform-managed namespace created for the application team"
    value       = kubernetes_namespace.app.metadata[0].name
}