```mermaid
flowchart LR
  %% =========================================================
  %% STAGE 2 — AKS NON-PROD HIGH-LEVEL RUNTIME ARCHITECTURE
  %% =========================================================
  %% Scope:
  %% - Runtime interactions only.
  %% - Shows dev and staging inside the AKS non-prod estate.
  %% - Shows Azure PostgreSQL as the managed non-prod database dependency.
  %% - Shows Azure resource group and private virtual network boundaries.
  %% - Excludes CI/CD promotion and admission governance flows.
  %% =========================================================

  CONSUMER["Internal Consumer<br/>or QA Tester"]

  subgraph AZURE["Azure Non-Prod Estate"]
    direction LR

    subgraph RG_AKS["Resource Group: rg-stage2-nonprod-aks"]
      direction TB

      DNS_ZONE["Azure Private DNS Zone<br/>non-prod private hostnames"]

      subgraph VNET["Private Virtual Network: vnet-stage2-nonprod"]
        direction LR

        subgraph AKS_SUBNET["Subnet: snet-stage2-nonprod-aks"]
          direction TB

          subgraph AKS["AKS Non-Prod Cluster"]
            direction TB

            subgraph INGRESS_NS["Namespace: ingress-system"]
              direction LR

              INGRESS_LB_SVC["Service<br/>internal ingress controller<br/>type: LoadBalancer<br/>private IP only"]
              INGRESS_CTRL_POD["Pod<br/>Ingress Controller<br/>NGINX / AGIC direction"]
              DEV_INGRESS["Ingress Resource<br/>dev private hostname<br/>routes to dev service"]
              STG_INGRESS["Ingress Resource<br/>staging private hostname<br/>routes to staging service"]
              GRAFANA_INGRESS["Ingress Resource<br/>Grafana private hostname<br/>routes to Grafana service"]
              KIBANA_INGRESS["Ingress Resource<br/>Kibana private hostname<br/>routes to Kibana service"]
            end

            subgraph DEV_NS["Namespace: payment-exception-review-dev"]
              direction LR

              DEV_APP_SVC["Service<br/>Spring Boot backend<br/>payment-exception-review-service<br/>80 → 8080"]
              DEV_APP_POD["Pod<br/>Payment Exception Review API<br/>dev runtime"]
              DEV_SECRET["Secret<br/>payment-review-db-dev<br/>DB credentials"]
              DEV_CM["ConfigMap<br/>dev runtime variables<br/>values-dev.yaml"]
            end

            subgraph STAGING_NS["Namespace: payment-exception-review-staging"]
              direction LR

              STG_APP_SVC["Service<br/>Spring Boot backend<br/>payment-exception-review-service<br/>80 → 8080"]
              STG_APP_POD["Pod<br/>Payment Exception Review API<br/>staging runtime"]
              STG_SECRET["Secret<br/>payment-review-db-staging<br/>DB credentials"]
              STG_CM["ConfigMap<br/>staging runtime variables<br/>values-staging.yaml"]
            end

            subgraph MON_NS["Namespace: monitoring"]
              direction LR

              PROM_SVC["Service<br/>Prometheus<br/>kube-prometheus-stack-prometheus:9090"]
              GRAFANA_SVC["Service<br/>Grafana<br/>kube-prometheus-stack-grafana:80"]
              PROM_POD["Pod<br/>Prometheus"]
              GRAFANA_POD["Pod<br/>Grafana"]
              DASH_CM["ConfigMap<br/>Shared Grafana dashboards<br/>env-filtered dashboards as code"]
              ALERT_SVC["Service<br/>Alertmanager<br/>kube-prometheus-stack-alertmanager:9093"]
              ALERT_POD["Pod<br/>Alertmanager"]
              LOG_AGENT["DaemonSet<br/>Log collector<br/>cluster log shipping"]
              ELASTIC_SVC["Service<br/>Elasticsearch<br/>log storage"]
              ELASTIC_POD["Pod / Stateful workload<br/>Elasticsearch"]
              KIBANA_SVC["Service<br/>Kibana<br/>log investigation UI"]
              KIBANA_POD["Pod<br/>Kibana"]
            end
          end
        end

        subgraph PG_SUBNET["Delegated Subnet: snet-stage2-nonprod-postgres"]
          direction TB

          subgraph DATA["Azure Managed Data Layer"]
            direction TB

            AZ_PG["Azure Database for PostgreSQL<br/>non-prod managed service"]
            DEV_DB["Database / schema<br/>payment_exception_review_dev"]
            STG_DB["Database / schema<br/>payment_exception_review_staging"]
          end
        end
      end
    end
  end

  %% =========================================================
  %% Runtime request flows
  %% =========================================================

  CONSUMER -->|"resolves private hostname"| DNS_ZONE
  DNS_ZONE -->|"returns private ingress IP"| INGRESS_LB_SVC
  INGRESS_LB_SVC -->|"routes private HTTP(S) traffic"| INGRESS_CTRL_POD

  INGRESS_CTRL_POD -.->|"watches routing rules"| DEV_INGRESS
  INGRESS_CTRL_POD -.->|"watches routing rules"| STG_INGRESS
  INGRESS_CTRL_POD -.->|"watches routing rules"| GRAFANA_INGRESS
  INGRESS_CTRL_POD -.->|"watches routing rules"| KIBANA_INGRESS

  INGRESS_CTRL_POD -->|"HTTP request<br/>dev endpoint"| DEV_APP_SVC
  INGRESS_CTRL_POD -->|"HTTP request<br/>staging endpoint"| STG_APP_SVC
  INGRESS_CTRL_POD -->|"dashboard access<br/>private Grafana hostname"| GRAFANA_SVC
  INGRESS_CTRL_POD -->|"log investigation UI<br/>private Kibana hostname"| KIBANA_SVC

  CONSUMER -.->|"debug fallback<br/>kubectl port-forward"| GRAFANA_SVC
  CONSUMER -.->|"debug fallback<br/>kubectl port-forward"| KIBANA_SVC
  CONSUMER -.->|"optional direct API access<br/>debug/admin only"| ELASTIC_SVC
  CONSUMER -.->|"optional alert UI access<br/>platform/SRE only"| ALERT_SVC

  DEV_APP_SVC -->|"routes traffic<br/>TCP 8080"| DEV_APP_POD
  STG_APP_SVC -->|"routes traffic<br/>TCP 8080"| STG_APP_POD

  DEV_APP_POD -->|"JDBC<br/>TCP 5432"| AZ_PG
  STG_APP_POD -->|"JDBC<br/>TCP 5432"| AZ_PG

  AZ_PG --> DEV_DB
  AZ_PG --> STG_DB

  %% =========================================================
  %% Configuration / secret dependencies
  %% Dashed lines = non-network dependency
  %% =========================================================

  DEV_APP_POD -.->|"uses DB credentials"| DEV_SECRET
  DEV_APP_POD -.->|"uses runtime config"| DEV_CM

  STG_APP_POD -.->|"uses DB credentials"| STG_SECRET
  STG_APP_POD -.->|"uses runtime config"| STG_CM

  GRAFANA_POD -.->|"loads shared dashboard definitions<br/>filtered by environment labels"| DASH_CM

  %% =========================================================
  %% Observability flows
  %% =========================================================

  GRAFANA_SVC -->|"routes dashboard traffic"| GRAFANA_POD
  GRAFANA_POD -->|"queries metrics<br/>PromQL"| PROM_SVC
  PROM_SVC -->|"routes traffic"| PROM_POD

  PROM_POD -->|"scrapes<br/>/actuator/prometheus"| DEV_APP_SVC
  PROM_POD -->|"scrapes<br/>/actuator/prometheus"| STG_APP_SVC
  PROM_POD -->|"sends firing alerts"| ALERT_SVC
  ALERT_SVC -->|"routes alert traffic"| ALERT_POD
  ALERT_POD -->|"routes notifications<br/>channel decided later"| CONSUMER

  DEV_APP_POD -->|"stdout / application logs"| LOG_AGENT
  STG_APP_POD -->|"stdout / application logs"| LOG_AGENT
  LOG_AGENT -->|"ships logs"| ELASTIC_SVC
  ELASTIC_SVC -->|"routes log writes / queries"| ELASTIC_POD
  KIBANA_SVC -->|"routes UI traffic"| KIBANA_POD
  KIBANA_POD -->|"queries logs"| ELASTIC_SVC

  %% =========================================================
  %% Architecture notes
  %% =========================================================
  %% AKS non-prod uses Azure PostgreSQL to stay close to the production
  %% dependency model.
  %%
  %% Grafana dashboards should usually stay shared in the monitoring namespace.
  %% Do not duplicate Grafana per environment by default. Split dashboards only
  %% when dev and staging need different ownership, retention, access control,
  %% or alerting behavior. Stage 2 should prefer shared dashboards with
  %% environment labels and variables.
  %%
  %% Grafana permissions protect UI actions, but they are not represented as a
  %% runtime Kubernetes component. Kubernetes RBAC and GitOps protect the source
  %% of truth: monitoring namespace resources, dashboard ConfigMaps,
  %% Prometheus rules, and reconciled desired state.
  %%
  %% Alertmanager is shown as the Stage 2 alert routing direction. The final
  %% notification channel can be decided later.
  %%
  %% Elasticsearch / Kibana are shown as the Stage 2 log investigation direction.
  %% The exact log collector implementation can be decided later, but the runtime
  %% interaction is: workload logs -> collector -> Elasticsearch -> Kibana.
  %%
  %% Stage 2 should move away from port-forward as the main evidence path.
  %% The target non-prod runtime access path is:
  %% Internal user -> Azure Private DNS Zone -> internal LoadBalancer Service
  %% -> Ingress Controller Pod -> Kubernetes Ingress rules -> application or
  %% observability Service.
  %%
  %% Stage 2 owns the platform-side private access resources: Azure Private DNS
  %% direction, internal ingress controller exposure, Kubernetes Ingress
  %% resources, and private AKS service exposure. Enterprise ZTNA/SASE/VPN
  %% products such as Palo Alto Prisma Access or GlobalProtect are Stage 3
  %% enterprise access architecture concerns.
  %%
  %% Port-forward remains acceptable only as an admin/debug fallback.
  %%
  %% OpenShift Sandbox compatibility is intentionally not shown here.
  %% It has a separate architecture because it proves workload portability,
  %% not Azure infrastructure parity.
  %%
  %% Promotion, GitHub Actions, GHCR, Azure OIDC, Kyverno, PSS, ResourceQuota,
  %% and LimitRange are important Stage 2 controls, but they are not runtime
  %% HTTP/JDBC/observability interactions. They belong in separate delivery,
  %% admission, and promotion diagrams.

  %% =========================================================
  %% Styles
  %% =========================================================

  classDef actor fill:#111827,stroke:#ffffff,color:#ffffff,stroke-width:2px;
  classDef access fill:#eaf6ed,stroke:#2e7d32,color:#172033,stroke-width:2px;
  classDef azure fill:#e8f3ff,stroke:#0078d4,color:#172033,stroke-width:2px;
  classDef rg fill:#ffffff,stroke:#0078d4,color:#172033,stroke-width:2px,stroke-dasharray: 8 4;
  classDef vnet fill:#f7faff,stroke:#172033,color:#172033,stroke-width:2px;
  classDef subnet fill:#ffffff,stroke:#64748b,color:#172033,stroke-width:1.5px,stroke-dasharray: 4 4;
  classDef cluster fill:#eef4ff,stroke:#326ce5,color:#172033,stroke-width:2px;
  classDef namespace fill:#ffffff,stroke:#326ce5,color:#172033,stroke-width:2px,stroke-dasharray: 6 4;
  classDef service fill:#dbeafe,stroke:#2563eb,color:#172033,stroke-width:2px;
  classDef pod fill:#dcfce7,stroke:#16a34a,color:#172033,stroke-width:2px;
  classDef data fill:#fff7ed,stroke:#ea580c,color:#172033,stroke-width:2px;
  classDef config fill:#ede9fe,stroke:#7c3aed,color:#172033,stroke-width:2px;
  classDef secret fill:#fee2e2,stroke:#dc2626,color:#172033,stroke-width:2px;
  classDef observability fill:#ffedd5,stroke:#f97316,color:#172033,stroke-width:2px;

  class CONSUMER actor;
  class DNS_ZONE,INGRESS_LB_SVC,INGRESS_CTRL_POD,DEV_INGRESS,STG_INGRESS,GRAFANA_INGRESS,KIBANA_INGRESS access;
  class AZURE azure;
  class RG_AKS rg;
  class VNET vnet;
  class AKS_SUBNET,PG_SUBNET subnet;
  class AKS cluster;
  class INGRESS_NS,DEV_NS,STAGING_NS,MON_NS namespace;
  class DEV_APP_SVC,STG_APP_SVC,PROM_SVC,GRAFANA_SVC,ALERT_SVC service;
  class DEV_APP_POD,STG_APP_POD pod;
  class AZ_PG,DEV_DB,STG_DB data;
  class DEV_CM,STG_CM,DASH_CM config;
  class DEV_SECRET,STG_SECRET secret;
  class PROM_POD,GRAFANA_POD,ALERT_POD,LOG_AGENT,ELASTIC_SVC,ELASTIC_POD,KIBANA_SVC,KIBANA_POD observability;
```
