resource "kubernetes_namespace" "app" {
  metadata {
    name = var.namespace_name
  }
}

resource "kubernetes_service_account" "app_runtime" {
  metadata {
    name      = var.app_service_account_name
    namespace = kubernetes_namespace.app.metadata[0].name
  }
}

resource "kubernetes_role" "app_runtime" {
  metadata {
    name      = var.app_role_name
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_role_binding" "app_runtime" {
  metadata {
    name      = var.app_role_binding_name
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.app_runtime.metadata[0].name
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.app_runtime.metadata[0].name
  }
}

resource "kubernetes_config_map" "platform_baseline" {
  metadata {
    name      = var.baseline_configmap_name
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  data = {
    ENV_NAME       = "stage1"
    PLATFORM_OWNER = "platform-team"
    LOG_LEVEL      = "INFO"
  }
}