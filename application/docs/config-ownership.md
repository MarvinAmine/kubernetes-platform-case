# Configuration Ownership

This document defines which configuration values belong to the infrastructure team, platform team, and application team.

The goal is to reduce delivery ambiguity and keep the Stage 1 operating model realistic.

## Infrastructure-owned configuration

These values identify the foundational estate supporting the service.

| Variable | Example | Purpose |
| --- | --- | --- |
| `INFRASTRUCTURE_OWNER` | `infrastructure-team` | Ownership metadata for the foundational Azure, AKS, backend, and managed database estate |

## Platform-owned configuration

These values are injected by the governed environment and should not be freely redefined by the application team.

| Variable | Example | Purpose |
| --- | --- | --- |
| `ENV_NAME` | `stage1` | Environment identifier exposed by the platform baseline |
| `PLATFORM_OWNER` | `platform-team` | Ownership metadata from the platform boundary |
| `LOG_LEVEL` | `INFO` | Baseline logging convention provided by the platform |

## Application-owned configuration

These values shape business behavior inside the service and are owned by the application team.

| Variable | Example | Purpose |
| --- | --- | --- |
| `VALIDATION_MODE` | `STANDARD` | Business validation strictness |
| `ESCALATION_ENABLED` | `true` | Enables or disables escalation behavior |
| `RISK_AMOUNT_THRESHOLD` | `10000` | Threshold used by review logic |
| `REGION` | `CA-QC` | Regional business context |

## Secret placeholder pattern

Stage 1 should still demonstrate a secret usage pattern, even if the service remains simple.

| Secret | Example | Purpose |
| --- | --- | --- |
| `PAYMENT_REVIEW_DB_PASSWORD` | `<from Kubernetes Secret>` | PostgreSQL password used by the application |

## Ownership principle

The platform team owns the paved road.

The application team owns the business behavior delivered through that paved road.
