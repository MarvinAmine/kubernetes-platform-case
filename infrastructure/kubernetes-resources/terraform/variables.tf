variable "kubeconfig_path" {
  description = "Path to the kubeconfig file used to access the Kubernetes cluster"
  type        = string
  default     = "~/.kube/config"
}

variable "namespace_name" {
  description = "Platform-managed namespace for the application team"
  type        = string
  default     = "document-processing-stage1"
}

variable "app_service_account_name" {
  description = "Kubernetes service account used by the application runtime"
  type        = string
  default     = "app-runtime-sa"
}

variable "app_role_name" {
  description = "Role granted to the application runtime service account"
  type        = string
  default     = "app-runtime-role"
}

variable "app_role_binding_name" {
  description = "RoleBinding linking the runtime service account to its Role"
  type        = string
  default     = "app-runtime-rb"
}

variable "baseline_configmap_name" {
  description = "Platform-owned baseline ConfigMap shared with the application team"
  type        = string
  default     = "platform-baseline-config"
}