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

## Related ADRs

Application-specific ADRs remain under:

- [application/payment-exception-review-service/docs/adrs/README.md](/home/marvin/Documents/dev/kubernetes/application/payment-exception-review-service/docs/adrs/README.md)
