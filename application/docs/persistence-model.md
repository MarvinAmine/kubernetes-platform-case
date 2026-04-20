# Persistence Model

This document defines the **light persistence model** for the Stage 1 **Payment Exception Review Service**.

The purpose is to make PostgreSQL part of the design in a controlled way without turning Stage 1 into a full database architecture exercise.

## Scope

This persistence model is intentionally limited to what Stage 1 needs:

- one main persisted business table
- one clear mapping between API-facing concepts and stored review data
- support for realistic internal-service credibility

This document does **not** yet attempt to define:

- a full enterprise data platform
- event sourcing
- audit-history tables
- data retention policies
- reporting schemas
- cross-service database ownership

## Persistence strategy

Stage 1 uses **PostgreSQL** as the system of record for payment exception review data.

The application reads persisted review data and exposes it through the internal REST API.

Runtime configuration such as validation mode or environment metadata remains configuration-driven rather than being stored in the business table.

## Main table

### `payment_exception_reviews`

This is the core Stage 1 table.

It stores one row per payment exception review tracked by the service.

### Proposed columns

| Column | Type | Required | Description |
| --- | --- | --- | --- |
| `id` | `uuid` | Yes | Primary key used internally |
| `review_id` | `varchar(64)` | Yes | External business identifier returned by the API |
| `payment_reference` | `varchar(128)` | Yes | Payment reference associated with the exception |
| `status` | `varchar(32)` | Yes | Current review lifecycle status |
| `reason_code` | `varchar(64)` | Yes | Main reason the payment entered the exception path |
| `validation_state` | `varchar(32)` | Yes | Validation outcome summary |
| `priority` | `varchar(16)` | No | Priority indicator for manual handling |
| `region` | `varchar(32)` | Yes | Regional routing or business context |
| `source_system` | `varchar(64)` | No | Internal source system that emitted the exception |
| `assigned_queue` | `varchar(64)` | No | Manual or operational queue currently responsible |
| `requires_manual_review` | `boolean` | Yes | Whether the exception requires manual review |
| `created_at` | `timestamp with time zone` | Yes | Creation timestamp |
| `updated_at` | `timestamp with time zone` | Yes | Last update timestamp |

## Primary key and uniqueness

### Primary key

- `id`

### Business uniqueness

- `review_id` should be unique

This keeps the internal database key separate from the externally visible business identifier.

## Suggested constraints

- `review_id` is `NOT NULL`
- `review_id` is unique
- `payment_reference` is `NOT NULL`
- `status` is `NOT NULL`
- `reason_code` is `NOT NULL`
- `validation_state` is `NOT NULL`
- `region` is `NOT NULL`
- `requires_manual_review` is `NOT NULL`
- `created_at` is `NOT NULL`
- `updated_at` is `NOT NULL`

## Suggested indexes

For Stage 1, keep indexing minimal and practical:

- unique index on `review_id`
- index on `status`
- index on `payment_reference`

That is enough for:

- primary status lookup by review id
- operational filtering or debugging by status
- searching by payment reference if needed later

## Enumerated business values

The following values are currently good candidates for controlled enum-style storage in PostgreSQL using `varchar` plus application validation.

### `status`

- `RECEIVED`
- `VALIDATING`
- `PENDING_REVIEW`
- `APPROVED`
- `REJECTED`
- `ESCALATED`
- `CLOSED`

### `validation_state`

- `VALID`
- `INVALID`
- `INCOMPLETE`
- `REQUIRES_MANUAL_REVIEW`

### `reason_code`

- `AMOUNT_THRESHOLD_EXCEEDED`
- `MISSING_REFERENCE`
- `DUPLICATE_SUSPECTED`
- `DESTINATION_BLOCKED`
- `COMPLIANCE_REVIEW_REQUIRED`
- `INVALID_METADATA`

## Mapping to the Stage 1 API

### `GET /api/payment-exceptions/{id}/status`

Main mapping:

- `review_id` -> `reviewId`
- `status` -> `status`
- `region` -> `region`

The following fields remain configuration-derived rather than row-derived:

- `validationMode`
- `escalationEnabled`

### `GET /api/payment-exceptions/service-status`

This endpoint is mostly configuration- and runtime-derived, not database-derived.

### `GET /api/payment-exceptions/config-check`

This endpoint is configuration-derived, not database-derived.

## Relationship to the domain model

The persistence model supports the main business concept:

```text
PaymentExceptionReview
  ├── persisted in payment_exception_reviews
  ├── identified externally by review_id
  ├── has one lifecycle status
  ├── has one reason code
  └── carries one regional/business context
```

## Why this is enough for Stage 1

This persistence model is intentionally small because Stage 1 is still about:

- delivery credibility
- stateful service realism
- runtime behavior
- observability
- supportable troubleshooting

It is not yet about:

- full enterprise data modeling
- deep relational design
- long-lived workflow history
- reporting and analytics architecture

## Deferred design topics

The following can wait for later stages:

- audit history table
- status transition history
- optimistic locking strategy
- retention and archival policy
- queue assignment normalization
- cross-service integration tables
