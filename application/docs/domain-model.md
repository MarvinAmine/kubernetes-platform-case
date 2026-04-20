# Domain Model

This document defines the light domain model for the Stage 1 **Payment Exception Review Service**.

The model is intentionally small. Its purpose is to support a credible internal service design without introducing unnecessary persistence or enterprise-modeling overhead.

## Modeling scope

This Stage 1 domain model supports:

- one internal payment exception review concept
- one lifecycle status model
- one business validation mode model
- one runtime configuration view

This Stage 1 domain model does **not** yet include:

- a full enterprise database design
- audit-history tables
- audit tables
- user identity model
- workflow orchestration
- external partner integrations

## Core domain concepts

### 1. PaymentExceptionReview

Represents an internal payment operation that has left the normal automated path and requires review or validation.

#### Purpose

This is the main business concept exposed by the Stage 1 API.

#### Key attributes

| Attribute | Type | Description |
| --- | --- | --- |
| `reviewId` | `string` | Unique identifier of the payment exception review |
| `status` | `PaymentReviewStatus` | Current lifecycle state |
| `region` | `string` | Regional routing or processing context |
| `validationMode` | `ValidationMode` | Active business validation mode |
| `escalationEnabled` | `boolean` | Whether escalation behavior is enabled |

#### Notes

For Stage 1, this concept is backed by PostgreSQL, but the model remains intentionally lightweight.

### 2. PaymentReviewStatus

Represents the lifecycle state of a payment exception review.

#### Allowed values

| Value | Meaning |
| --- | --- |
| `RECEIVED` | The exception has been received by the service |
| `VALIDATING` | Validation is in progress |
| `PENDING_REVIEW` | The exception is waiting for manual or controlled review |
| `APPROVED` | The exception has been approved |
| `REJECTED` | The exception has been rejected |
| `ESCALATED` | The exception has been escalated for deeper handling |

#### Stage 1 usage

This enum is central to:

- `GET /api/payment-exceptions/{id}/status`
- use-case documentation
- troubleshooting examples

### 3. ValidationMode

Represents the business validation policy used by the service.

#### Allowed values

| Value | Meaning |
| --- | --- |
| `STRICT` | Stronger validation behavior |
| `STANDARD` | Default validation behavior |

#### Validation rule

The application must fail fast if any value outside this set is configured.

This is directly tied to the Stage 1 invalid-configuration failure scenario.

### 4. ServiceRuntimeConfiguration

Represents the effective configuration view exposed by the service at runtime.

#### Purpose

This concept helps operators and developers understand how the service is currently configured.

#### Key attributes

| Attribute | Type | Description |
| --- | --- | --- |
| `environmentName` | `string` | Platform environment identifier |
| `infrastructureOwner` | `string` | Infrastructure ownership metadata |
| `platformOwner` | `string` | Platform ownership metadata |
| `logLevel` | `string` | Effective logging convention |
| `validationMode` | `ValidationMode` | Active validation mode |
| `escalationEnabled` | `boolean` | Current escalation setting |
| `riskAmountThreshold` | `integer` | Active risk threshold |
| `region` | `string` | Active regional setting |

## Concept relationships

The relationships between the main concepts are intentionally simple:

```text
PaymentExceptionReview
  ├── has one reviewId
  ├── has one PaymentReviewStatus
  ├── uses one ValidationMode
  └── is evaluated under one ServiceRuntimeConfiguration

ServiceRuntimeConfiguration
  ├── contains one ValidationMode
  ├── contains one region
  ├── contains one riskAmountThreshold
  └── contains environment, infrastructure, and platform metadata
```

## Proposed implementation mapping

This light domain model can map cleanly to Java classes such as:

- `PaymentExceptionReview`
- `PaymentReviewStatus`
- `ValidationMode`
- `ServiceRuntimeConfiguration`
- `ServiceStatusResponse`
- `ConfigCheckResponse`

For Stage 1, the domain model can stay separate from transport DTOs if useful, but it is also acceptable to keep the design lightweight and close to the API response model.

## Configuration ownership alignment

### Infrastructure-owned values

| Variable | Domain usage |
| --- | --- |
| `INFRASTRUCTURE_OWNER` | populates `infrastructureOwner` |

### Platform-owned values

| Variable | Domain usage |
| --- | --- |
| `ENV_NAME` | populates `environmentName` |
| `PLATFORM_OWNER` | populates `platformOwner` |
| `LOG_LEVEL` | populates `logLevel` |

### Application-owned values

| Variable | Domain usage |
| --- | --- |
| `VALIDATION_MODE` | populates `validationMode` |
| `ESCALATION_ENABLED` | populates `escalationEnabled` |
| `RISK_AMOUNT_THRESHOLD` | populates `riskAmountThreshold` |
| `REGION` | populates `region` |

## Why this model is enough for Stage 1

This model is deliberately small because the main goal of Stage 1 is to prove:

- controlled delivery
- runtime health behavior
- configuration discipline
- observability
- troubleshooting support

The goal is not yet to prove:

- complex business orchestration
- rich persistence modeling
- multi-service domain decomposition

If persistence evolves further, this document can evolve into:

- a richer domain model
- a database model
- a retention and audit model
