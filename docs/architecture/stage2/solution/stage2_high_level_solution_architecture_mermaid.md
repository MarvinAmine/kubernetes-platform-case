# Stage 2 High-Level Solution Architecture

This diagram is the human-facing overview of Stage 2.

It shows the major actors, environments, platform boundaries, delivery systems,
runtime targets, compatibility lab, data dependency, and observability surface.
Detailed runtime, admission, promotion, control-plane, secrets, and operations
flows stay in their dedicated diagrams.

```mermaid
flowchart LR
  %% =========================================================
  %% STAGE 2 — HIGH-LEVEL SOLUTION ARCHITECTURE
  %% =========================================================
  %% Scope:
  %% - Human-facing overview.
  %% - Major actors, systems, environments, and ownership boundaries.
  %% - Not a detailed runtime, admission, promotion, or operations flow.
  %% =========================================================

  subgraph ACTORS["Actors and Ownership"]
    direction TB

    INFRA_TEAM["Infrastructure Team"]
    PLATFORM_TEAM["Platform Team"]
    APP_TEAM["Application Team"]
    SRE_TEAM["SRE / Production Engineering"]
    SECURITY_IAM["Security / IAM Direction"]
    QA_PO["QA / Product Owner"]
    INTERNAL_USER["Internal Consumer"]
  end

  subgraph DELIVERY["Delivery and Governance"]
    direction TB

    GITHUB["GitHub Repository<br/>source of change"]
    ACTIONS["GitHub Actions<br/>validation, build, promotion"]
    GHCR["GHCR<br/>immutable image digest"]
    TERRAFORM["Terraform / Terragrunt direction<br/>environment infrastructure"]
    ARGOCD["Argo CD direction<br/>GitOps reconciliation"]
    VAULT["HashiCorp Vault direction<br/>secret governance"]
    KYVERNO["Kyverno direction<br/>policy guardrails"]
    ANSIBLE["Ansible direction<br/>automation helpers"]
  end

  subgraph NONPROD["Azure AKS Non-Prod Estate"]
    direction TB

    NONPROD_VNET["Private VNet + Azure Private DNS<br/>non-prod access boundary"]
    NONPROD_AKS["AKS non-prod cluster<br/>shared dev + staging estate"]
    DEV_NS["Namespace<br/>payment-exception-review-dev"]
    STG_NS["Namespace<br/>payment-exception-review-staging"]
    NONPROD_OBS["Shared observability namespace<br/>Prometheus, Grafana, Alertmanager,<br/>Elasticsearch, Kibana direction"]
    NONPROD_PG["Azure Database for PostgreSQL<br/>non-prod managed dependency"]
  end

  subgraph PROD["Azure AKS Prod Estate"]
    direction TB

    PROD_VNET["Private VNet + Azure Private DNS<br/>prod access boundary"]
    PROD_AKS["AKS prod cluster<br/>isolated production estate"]
    PROD_NS["Namespace<br/>payment-exception-review-prod"]
    PROD_OBS["Production observability namespace<br/>metrics, alerts, logs, dashboards"]
    PROD_PG["Azure Database for PostgreSQL<br/>prod managed dependency"]
  end

  subgraph OPENSHIFT["OpenShift Compatibility Lab"]
    direction TB

    SANDBOX["Red Hat Developer Sandbox<br/>side compatibility proof"]
    PROJECT["OpenShift Project<br/>payment-exception-review-sandbox"]
    ROUTE["OpenShift Route<br/>workload exposure proof"]
  end

  subgraph RELIABILITY["Reliability Evidence"]
    direction TB

    E2E["Postman/Newman<br/>staging E2E evidence"]
    RUNBOOKS["Runbooks<br/>rollback and investigation"]
    SLOS["SLO/SLI assumptions<br/>governance-defined targets"]
    INCIDENTS["Incident / drill evidence<br/>MTTR and postmortem direction"]
  end

  %% =========================================================
  %% Ownership flows
  %% =========================================================

  INFRA_TEAM --> TERRAFORM
  PLATFORM_TEAM --> ARGOCD
  PLATFORM_TEAM --> KYVERNO
  PLATFORM_TEAM --> VAULT
  PLATFORM_TEAM --> ANSIBLE
  APP_TEAM --> GITHUB
  SRE_TEAM --> RELIABILITY
  SECURITY_IAM --> VAULT
  SECURITY_IAM --> KYVERNO
  QA_PO --> E2E

  %% =========================================================
  %% Delivery and platform flows
  %% =========================================================

  GITHUB --> ACTIONS
  ACTIONS --> GHCR
  ACTIONS --> TERRAFORM
  ACTIONS --> E2E
  ACTIONS -->|"promotion gate"| PROD

  TERRAFORM --> NONPROD
  TERRAFORM --> PROD
  ARGOCD --> NONPROD_AKS
  ARGOCD --> PROD_AKS
  VAULT --> DEV_NS
  VAULT --> STG_NS
  VAULT --> PROD_NS
  KYVERNO --> NONPROD_AKS
  KYVERNO --> PROD_AKS

  %% =========================================================
  %% Environment shape
  %% =========================================================

  NONPROD_VNET --> NONPROD_AKS
  NONPROD_AKS --> DEV_NS
  NONPROD_AKS --> STG_NS
  NONPROD_AKS --> NONPROD_OBS
  DEV_NS --> NONPROD_PG
  STG_NS --> NONPROD_PG

  PROD_VNET --> PROD_AKS
  PROD_AKS --> PROD_NS
  PROD_AKS --> PROD_OBS
  PROD_NS --> PROD_PG

  PLATFORM_TEAM --> SANDBOX
  SANDBOX --> PROJECT
  PROJECT --> ROUTE
  PROJECT -.->|"portable workload contract"| GHCR

  %% =========================================================
  %% Consumer and reliability flows
  %% =========================================================

  INTERNAL_USER -->|"private app access"| NONPROD_VNET
  INTERNAL_USER -->|"private app access"| PROD_VNET
  NONPROD_OBS --> SLOS
  PROD_OBS --> SLOS
  E2E --> STG_NS
  RUNBOOKS --> NONPROD_AKS
  RUNBOOKS --> PROD_AKS
  INCIDENTS --> RUNBOOKS

  %% =========================================================
  %% Architecture notes
  %% =========================================================
  %% This overview intentionally avoids low-level arrows such as:
  %% DNS -> LoadBalancer -> Ingress Controller -> Service -> Pod.
  %% Those belong in runtime diagrams.
  %%
  %% It also avoids admission details such as:
  %% Kubernetes API server -> Pod Security Admission -> Kyverno -> ResourceQuota.
  %% Those belong in admission governance diagrams.
  %%
  %% The OpenShift Sandbox is not prod and not a replacement for AKS non-prod.
  %% It is a side compatibility lab used to validate workload portability.

  %% =========================================================
  %% Styles
  %% =========================================================

  classDef actor fill:#111827,stroke:#ffffff,color:#ffffff,stroke-width:2px;
  classDef delivery fill:#eef2ff,stroke:#4f46e5,color:#172033,stroke-width:2px;
  classDef nonprod fill:#e8f3ff,stroke:#0078d4,color:#172033,stroke-width:2px;
  classDef prod fill:#fff7ed,stroke:#ea580c,color:#172033,stroke-width:2px;
  classDef openshift fill:#fee2e2,stroke:#dc2626,color:#172033,stroke-width:2px;
  classDef reliability fill:#f0fdf4,stroke:#16a34a,color:#172033,stroke-width:2px;

  class ACTORS,INFRA_TEAM,PLATFORM_TEAM,APP_TEAM,SRE_TEAM,SECURITY_IAM,QA_PO,INTERNAL_USER actor;
  class DELIVERY,GITHUB,ACTIONS,GHCR,TERRAFORM,ARGOCD,VAULT,KYVERNO,ANSIBLE delivery;
  class NONPROD,NONPROD_VNET,NONPROD_AKS,DEV_NS,STG_NS,NONPROD_OBS,NONPROD_PG nonprod;
  class PROD,PROD_VNET,PROD_AKS,PROD_NS,PROD_OBS,PROD_PG prod;
  class OPENSHIFT,SANDBOX,PROJECT,ROUTE openshift;
  class RELIABILITY,E2E,RUNBOOKS,SLOS,INCIDENTS reliability;
```
