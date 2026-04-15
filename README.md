# Stage 1 of 3 - Java microservice backend deployed to AKS using Terraform, GitHub Actions, Helm, and Docker

Production-style Java Spring Boot microservice packaged with Docker and deployed with Helm to AKS (Azure Kubernetes Service) using GitHub Actions and Azure OIDC federation. The platform includes operational checks, observability, and simulated failure scenarios with documented troubleshooting. Responsibilities are explicitly split between the infrastructure team and the application team.

Important: this project uses a remote Terraform backend in Azure Storage so local runs and CI/CD executions share the same infrastructure state instead of relying on local Terraform state files.

![alt text](environment_bootstrap_path.png)
![alt text](app_delivery_path.png)

## 0. How to use it?

### 0.1 Setup the environment file

The infrastructure scripts use a shared environment file at `infrastructure/.env`:

Create it from:

```bash
cp infrastructure/.env.example infrastructure/.env
```

Fill these values in the `.env`:

| Variable | Required | Example / default | Description |
| --- | --- | --- | --- |
| `REPO_OWNER` | Yes | `MarvinAmine` | GitHub user or organization that owns the repository. Used by the Azure OIDC scripts to build the federated credential subject for GitHub Actions. |
| `SUBSCRIPTION_ID` | Yes | `<your-azure-subscription-id>` | Azure subscription ID used by all local infrastructure scripts, Terraform layers, and the OIDC setup. |
| `RESOURCE_GROUP` | Yes for Azure and Kubernetes provisioning | `rg-stage1-aks` | Azure resource group name for the AKS platform resources. Passed into the Azure Terraform layer and reused by the Kubernetes validation scripts. |
| `REPO_NAME` | Yes for OIDC setup | `kubernetes-platform-case` | GitHub repository name used by `infrastructure/azure/oidc/create_az_oidc.sh` when it renders the GitHub federated credential. |
| `GITHUB_BRANCH` | Yes for OIDC setup | `main` | Git branch allowed to authenticate through the Azure federated credential. |
| `LOCATION` | Yes for backend and Azure provisioning | `canadacentral` | Azure region for the Terraform backend resource group and AKS infrastructure. This becomes `AKS_LOCATION` in GitHub Actions repo variables. |
| `APP_NAME` | Recommended | `sp-github-oidc-stage1-platform` | Display name for the Azure Entra application and service principal created for GitHub OIDC. |
| `ROLE_NAME` | Recommended | `Contributor` | Azure role assigned to the OIDC service principal at subscription scope. |
| `AKS_CLUSTER_NAME` | Yes for Azure and Kubernetes provisioning | `aks-stage1-platform` | AKS cluster name created by the Azure Terraform layer and later targeted by the Kubernetes resources layer. |
| `DNS_PREFIX` | Optional | `aks-stage1` | DNS prefix passed to the Azure Terraform layer for the AKS cluster. |
| `NODE_COUNT` | Optional | `1` | Initial AKS node count passed to Terraform. |
| `VM_SIZE` | Optional | `Standard_D2as_v6` | AKS node VM size used by local scripts. The GitHub workflow also supports the same value through a repository variable. |
| `TIER` | Optional | `Free` | AKS SKU tier passed to the Azure Terraform layer. |
| `TF_BACKEND_RESOURCE_GROUP` | Yes after the first backend bootstrap | `rg-stage1-tfstate` | Azure resource group that hosts the remote Terraform state storage account. Required by local scripts and GitHub Actions. |
| `TF_BACKEND_STORAGE_ACCOUNT` | Yes after the first backend bootstrap | `<real-storage-account-name>` | Azure Storage Account name used as the remote Terraform backend. This is intentionally blank in the template until the backend is created or known. |
| `TF_BACKEND_CONTAINER` | Yes after the first backend bootstrap | `tfstate` | Blob container name that stores the Terraform state files. |

Minimal first edit before the initial bootstrap:

```conf
REPO_OWNER=...
SUBSCRIPTION_ID=...
```

If you do not have an Azure subscription selected yet, follow the setup steps in [infrastructure/docs/README.md](infrastructure/docs/README.md).

### 0.2 Local platform provisioning

Provision the full platform locally:

```bash
./infrastructure/provision_platform.sh
```

### 0.3 Complete the environment values and GitHub configuration

On the first run, `infrastructure/provision_platform.sh` bootstraps the remote Terraform backend and prints the backend values that must be copied into `infrastructure/.env`.

Update `.env` with these real backend values:

| Variable | Required after first run | Description |
| --- | --- | --- |
| `TF_BACKEND_RESOURCE_GROUP` | Yes | Resource group that hosts the remote Terraform backend. |
| `TF_BACKEND_STORAGE_ACCOUNT` | Yes | Storage account that stores the Terraform state files. |
| `TF_BACKEND_CONTAINER` | Yes | Blob container inside the backend storage account, usually `tfstate`. |

Confirm these GitHub repository variables are also set:

| Repository variable | Required | Description |
| --- | --- | --- |
| `TF_BACKEND_RESOURCE_GROUP` | Yes | Mirrors `infrastructure/.env` so GitHub Actions can initialize the Terraform backend. |
| `TF_BACKEND_STORAGE_ACCOUNT` | Yes | Mirrors `infrastructure/.env` so GitHub Actions can reach the backend storage account. |
| `TF_BACKEND_CONTAINER` | Yes | Mirrors `infrastructure/.env` so GitHub Actions can select the Terraform state container. |
| `RESOURCE_GROUP` | Yes | Resource group expected by the Azure and Kubernetes workflows. Should match `RESOURCE_GROUP` in `infrastructure/.env`. |
| `AKS_LOCATION` | Yes | Azure region for the AKS layer. This should match `LOCATION` from `infrastructure/.env`. |
| `AKS_CLUSTER_NAME` | Yes | AKS cluster name expected by the Azure and Kubernetes workflows. Should match `AKS_CLUSTER_NAME` in `infrastructure/.env`. |
| `VM_SIZE` | Optional | Optional CI override for the AKS node size. If unset, workflows default to `Standard_D2as_v6`. |

![GitHub Actions repository variables](github_actions_variables.png)

If you also run the Azure OIDC setup, the script `infrastructure/azure/oidc/create_az_oidc.sh` prints the GitHub repository secrets to configure.

Confirm these GitHub repository secrets are set:

| Repository secret | Required | Description |
| --- | --- | --- |
| `AZURE_SUBSCRIPTION_ID` | Yes | Azure subscription used by GitHub Actions. Mirrors `SUBSCRIPTION_ID` from `infrastructure/.env`. |
| `AZURE_CLIENT_ID` | Yes | Application ID of the Azure Entra app created for GitHub OIDC. |
| `AZURE_TENANT_ID` | Yes | Azure tenant ID used by `azure/login@v2` during GitHub Actions authentication. |

![GitHub Actions repository secrets](OIDC_secrets.png)

### 0.4 GitHub Actions

> Requirements: 
> 1. The [remote Terraform backend](infrastructure/terraform-backend/docs/README.md) is created.
> 2. The [Azure OIDC credentials for GitHub Actions](infrastructure/azure/docs/OIDC.md) are created.
> 3. The 6 GitHub repository variables are set and valid. `VM_SIZE` is optional and defaults to `Standard_D2as_v6`.
> 4. The 3 GitHub repository secrets are set and valid.

When changes are pushed to the tracked infrastructure paths, GitHub Actions automatically runs Terraform checks for the corresponding layer.

On `push`, the workflows run formatting, initialization, validation, and planning steps.

On `workflow_dispatch`, the Azure provisioning workflow can also run `terraform apply`.

### 0.5 Destroy the full platform

> It is important to destroy the resources after use. Azure services such as AKS and VMs can generate ongoing costs if they are left running.

You can destroy the platform with this command:
```bash
./infrastructure/destroy_platform.sh
```

It destroys:
1. Kubernetes resources
2. Azure infrastructure
3. The remote Terraform backend
4. The Azure OIDC integration, if you choose to remove it

![alt text](iac_lifecycle_dependencies.png)


## 1. ENVIRONMENT BOOTSTRAP PATH MANAGED BY THE INFRASTRUCTURE TEAM 

```text
[Infrastructure Team]
      │
      │ pushes platform bootstrap code
      ▼
┌──────────────────────────────────────────────┐
│            GitHub                            │
│----------------------------------------------│
│ infrastructure/                              │
│ - terraform/                                 │
│ - docs/                                      │
│ - GitHub Actions workflow for terraform/     │
└──────────────────────────────────────────────┘
      │
      │ triggers
      ▼
┌──────────────────────────────┐
│        GitHub Actions        │
│------------------------------│
│ Runs Terraform plan/apply    │
│ for platform-owned resources │
└──────────────────────────────┘
      │
      │ bootstraps environment in
      ▼
┌──────────────────────────────────────────────────────────────┐
│                   AKS  Kubernetes Cluster                    │
│--------------------------------------------------------------│
│ Namespace: document-processing-stage1                        │
│                                                              │
│  Platform-owned resources:                                   │
│  ┌──────────────────────────────┐                            │
│  │ Namespace                    │                            │
│  └──────────────────────────────┘                            │
│                                                              │
│  ┌──────────────────────────────┐                            │
│  │ ServiceAccount               │                            │
│  └──────────────────────────────┘                            │
│                                                              │
│  ┌──────────────────────────────┐                            │
│  │ Role                         │                            │
│  └──────────────────────────────┘                            │
│                                                              │
│  ┌──────────────────────────────┐                            │
│  │ RoleBinding                  │                            │
│  └──────────────────────────────┘                            │
│                                                              │
│  ┌──────────────────────────────┐                            │
│  │ Baseline ConfigMap           │                            │
│  │------------------------------│                            │
│  │ Shared platform convention   │                            │
│  │ example: ENV_NAME, LOG_LEVEL │                            │
│  └──────────────────────────────┘                            │
└──────────────────────────────────────────────────────────────┘
```

## 2. APP DELIVERY PATH USED BY THE APPLICATION TEAM 


```text
[Application Developer]
      │
      │ pushes app code / Helm changes
      ▼
┌──────────────────────────────┐
│            GitHub            │
│------------------------------│
│ application-team/            │
│ - Spring Boot app            │
│ - Dockerfile                 │
│ - Helm chart                 │
│ - app docs                   │
│ - workflow for app delivery  │
└──────────────────────────────┘
      │
      │ triggers
      ▼
┌────────────────────────────────────────────┐
│            GitHub Actions Pipeline         │
│--------------------------------------------│
│ 1. Checkout code                           │
│ 2. Build Spring Boot app                   │
│ 3. Run tests                               │
│ 4. Package JAR                             │
│ 5. Build Docker image                      │
│ 6. Validate Helm chart                     │
│ 7. Deploy with Helm                        │
│ 8. Post-deploy validation                  │
└────────────────────────────────────────────┘
      │
      ├───────────────────────────────┐
      │                               │
      │ builds                        │ uses
      ▼                               ▼
┌──────────────────────────────┐   ┌──────────────────────────────┐
│         Docker Image         │   │             Helm             │
│------------------------------│   │------------------------------│
│ Spring Boot microservice     │   │ App deployment package       │
│                              │   │ Templates Kubernetes objects │
└──────────────────────────────┘   └──────────────────────────────┘
              ▲                                │
(by reference)│ Pulls and runs                 │ deploys to
              │                                ▼
┌──────────────────────────────────────────────────────────────┐
│                 AKS Kubernetes Cluster                       │
│--------------------------------------------------------------│
│ Namespace: document-processing-stage1                        │
│                                                              │
│ App-team-owned resources:                                    │
│  ┌──────────────────────────────┐                            │
│  │ Deployment                   │                            │
│  │------------------------------│                            │
│  │ Spring Boot Pod(s)           │                            │
│  │ - image from pipeline        │                            │
│  │ - readiness probe            │                            │
│  │ - liveness probe             │                            │
│  │ - requests/limits            │                            │
│  │ - env from ConfigMap/Secret  │                            │
│  │ - uses ServiceAccount        │                            │
│  └──────────────────────────────┘                            │
│                                                              │
│  ┌──────────────────────────────┐                            │
│  │ Service                      │                            │
│  └──────────────────────────────┘                            │
│                                                              │
│  ┌──────────────────────────────┐                            │
│  │ App ConfigMap                │                            │
│  │------------------------------│                            │
│  │ App-specific config          │                            │
│  │ example: PROCESSING_MODE     │                            │
│  └──────────────────────────────┘                            │
│                                                              │
│  ┌──────────────────────────────┐                            │
│  │ Secret                       │                            │
│  │------------------------------│                            │
│  │ Placeholder secret pattern   │                            │
│  └──────────────────────────────┘                            │
└──────────────────────────────────────────────────────────────┘
```

## 3. APPLICATION RUNTIME

```text
Client
  │
  ├── GET /api/status
  │      -> service status, version, processing mode
  │
  ├── GET /api/documents/{id}
  │      -> fake document state
  │         RECEIVED / VALIDATING / PROCESSED / REJECTED
  │
  ├── GET /api/config-check
  │      -> config validation result
  │
  └── /actuator/*
         -> health / info / prometheus
```

## 4. OBSERVABILITY PATH

```text
Kubernetes / Application
      │
      ├── health checks
      ├── logs
      └── metrics
             │
             ▼
┌──────────────────────────────┐
│         Prometheus           │
│------------------------------│
│ Scrapes /actuator/prometheus │
│ Collects service metrics     │
└──────────────────────────────┘
             │
             ▼
┌──────────────────────────────┐
│           Grafana            │
│------------------------------│
│ Dashboard examples:          │
│ - app up/down                │
│ - request count              │
│ - response time              │
│ - JVM / memory basics        │
│ - health trend               │
└──────────────────────────────┘
```

## 5. Repo architecture
The structure below represents the current Stage 1 repository architecture:
```
kubernetes-platform-case/
├── .github/
│   └── workflows/
│       ├── azure-provision.yml
│       ├── azure-destroy.yml
│       ├── kubernetes-resources-provision.yml
│       ├── kubernetes-resources-destroy.yml
│       └── app-delivery.yml
│
├── infrastructure/
│   ├── .env
│   ├── .env.example
│   ├── provision_platform.sh
│   ├── destroy_platform.sh
│   ├── terraform-backend/
│   │   ├── create_remote_backend.sh
│   │   ├── destroy_remote_backend.sh
│   │   ├── terraform/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   ├── outputs.tf
│   │   │   ├── providers.tf
│   │   │   └── versions.tf
│   │   └── docs/
│   │       └── README.md
│   │
│   ├── azure/
│   │   ├── create_azure_resources.sh
│   │   ├── destroy_azure_resources.sh
│   │   ├── terraform/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   ├── outputs.tf
│   │   │   ├── providers.tf
│   │   │   ├── backend.tf
│   │   │   └── versions.tf
│   │   ├── oidc/
│   │   │   ├── create_az_oidc.sh
│   │   │   ├── destroy_az_oidc.sh
│   │   │   ├── github-oidc-credential.template.json
│   │   │   └── github-oidc-credential.json
│   │   ├── scripts/
│   │   │   ├── create_aks_cluster_and_connect_with_kubectl.sh
│   │   │   └── delete_azure_resource_group_manually.sh
│   │   └── docs/
│   │       └── README.md
│   │
│   ├── kubernetes-resources/
│   │   ├── apply_kubernetes_resources.sh
│   │   ├── destroy_kubernetes_resources.sh
│   │   ├── terraform/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   ├── outputs.tf
│   │   │   ├── providers.tf
│   │   │   ├── backend.tf
│   │   │   └── versions.tf
│   │   ├── scripts/
│   │   │   └── validate-cluster-access.sh
│   │   └── docs/
│   │       └── README.md
│   │
│   └── docs/
│       └── README.md
│
├── application/
│   ├── app/
│   │   ├── src/
│   │   ├── pom.xml
│   │   └── README.md
│   │
│   ├── docker/
│   │   └── Dockerfile
│   │
│   ├── helm/
│   │   └── document-processing-status/
│   │       ├── Chart.yaml
│   │       ├── values.yaml
│   │       └── templates/
│   │           ├── deployment.yaml
│   │           ├── service.yaml
│   │           ├── configmap.yaml
│   │           └── serviceaccount.yaml
│   │
│   ├── scripts/
│   │   ├── smoke-test.sh
│   │   ├── validate-helm.sh
│   │   └── debug-rollout.sh
│   │
│   └── docs/
│       ├── README.md
│       ├── runbook.md
│       ├── failure-scenarios.md
│       └── case-study-stage1.md
│
├── observability/
│   ├── prometheus/
│   ├── grafana/
│   └── docs/
│       └── README.md
│
├── docs/
│   ├── executive-summary.md
│   ├── stage1.md
│   ├── stage2.md
│   ├── stage3.md
│   └── interview-notes.md
```

## 6. Infrastructure layer responsability
| Layer                                 | Purpose                                                              | Owner            |
| ------------------------------------- | -------------------------------------------------------------------- | ---------------- |
| `infrastructure/terraform-backend`    | Creates the shared Azure Storage backend for Terraform state         | Platform team    |
| `infrastructure/azure`                | Creates Azure resources such as the resource group and AKS cluster   | Platform team    |
| `infrastructure/kubernetes-resources` | Creates namespace, service account, RBAC, and baseline config in AKS | Platform team    |
| `application/`                        | Builds and deploys the Spring Boot service                           | Application team |



## 7. FAILURE SCENARIOS

Scenario 1 - Bad readiness probe
- application is healthy
- readiness probe path/port is wrong
- pod stays unready
- rollout affected
- diagnosed via events, describe, health endpoint

Scenario 2 - Bad app config
- PROCESSING_MODE missing or invalid
- app fails startup or becomes unhealthy
- diagnosed via logs, config inspection, pod status


## 8. OWNERSHIP MODEL

Infrastructure team owns:
- Terraform
- namespace
- service account
- role / rolebinding
- baseline ConfigMap convention
- environment standards

Application team owns:
- Spring Boot code
- Dockerfile
- Helm chart
- Deployment / Service
- app ConfigMap values
- app Secret usage pattern
- application rollout
- app-level runbook notes
