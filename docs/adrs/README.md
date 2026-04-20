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

## Related ADRs

Application-specific ADRs remain under:

- [application/payment-exception-review-service/docs/adrs/README.md](/home/marvin/Documents/dev/kubernetes/application/payment-exception-review-service/docs/adrs/README.md)
