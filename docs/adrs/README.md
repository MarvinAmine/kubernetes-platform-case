# Architecture Decision Records

This directory contains the Architecture Decision Records for the **root platform case**, not only the Spring Boot application.

These ADRs capture the structural decisions behind Stage 1 of the repository:

- how responsibilities are split between teams
- how the infrastructure and platform layers are separated
- how application delivery is controlled
- how observability and troubleshooting are treated as first-class concerns
- how the stage progression is intentionally scoped

## ADR Index

- [ADR-001 - Use a three-team Stage 1 operating model](./ADR-001-three-team-stage1-operating-model.md)
- [ADR-002 - Separate infrastructure and platform Terraform responsibilities](./ADR-002-separate-infrastructure-and-platform-terraform-responsibilities.md)
- [ADR-003 - Use GitHub Actions, Docker, and Helm for controlled application delivery](./ADR-003-controlled-application-delivery-path.md)
- [ADR-004 - Treat observability and failure scenarios as part of the platform case](./ADR-004-observability-and-failure-scenarios-as-core-scope.md)
- [ADR-005 - Keep the overall case staged and maturity-driven](./ADR-005-staged-maturity-evolution.md)
- [ADR-006 - Do not create a standard GitHub Actions workflow for the remote Terraform backend](./ADR-006-do-not-create-a-github-actions-workflow-for-the-remote-terraform-backend.md)
- [ADR-007 - Use the main infrastructure workflow for managed Azure PostgreSQL](./ADR-007-use-the-main-infrastructure-workflow-for-managed-azure-postgresql.md)
- [ADR-008 - Create a GitHub Actions workflow for the Azure foundation](./ADR-008-create-a-github-actions-workflow-for-the-azure-foundation.md)
- [ADR-009 - Default to Standard_D2als_v6 while documenting Standard_B2als_v2 as the lower-cost fallback](./ADR-009-default-to-standard-d2als-v6-while-documenting-standard-b2als-v2-as-the-lower-cost-fallback.md)
- [ADR-010 - Use local PostgreSQL for local development and managed Azure PostgreSQL for cloud](./ADR-010-use-local-postgresql-for-local-development-and-managed-azure-postgresql-for-cloud.md)
- [ADR-011 - Prefer private networking for Azure PostgreSQL in the governed cloud environment](./ADR-011-prefer-private-networking-for-azure-postgresql-in-the-governed-cloud-environment.md)
- [ADR-012 - Defer advanced PostgreSQL capabilities to later stages](./ADR-012-defer-advanced-postgresql-capabilities-to-later-stages.md)
- [ADR-013 - Use the repository-root `.env` file as the single local configuration source](./ADR-013-use-the-repository-root-env-file-as-the-single-local-configuration-source.md)
- [ADR-014 - Separate application CI, deploy, and destroy workflows](./ADR-014-separate-application-ci-deploy-and-destroy-workflows.md)
- [ADR-015 - Use Kustomize for Grafana dashboard ConfigMap generation](./ADR-015-use-kustomize-for-grafana-dashboard-configmap-generation.md)

## Related ADRs

Application-specific ADRs remain under:

- [application/docs/adrs/README.md](../../application/docs/adrs/README.md)
