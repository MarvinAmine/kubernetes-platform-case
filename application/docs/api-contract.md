# API Contract

This document defines the Stage 1 API contract for the **Payment Exception Review Service**.

The objective is to keep the contract small, explicit, and implementation-ready before writing the Spring Boot controllers.

## Scope

This Stage 1 contract includes:

- one business status lookup endpoint
- one operational service-status endpoint
- one configuration-check endpoint
- Spring Boot Actuator operational endpoints

This Stage 1 contract does **not** include:

- authentication and authorization behavior
- persistence-specific behavior
- pagination
- filtering
- write operations
- asynchronous workflows

## Base assumptions

- Base path: `/api/payment-exceptions`
- Content type: `application/json`
- The service is internal-only for Stage 1
- Responses are intentionally simple and deterministic

## 1. Get payment exception status

### Endpoint

`GET /api/payment-exceptions/{id}/status`

### Purpose

Return the current lifecycle state for a payment exception review.

### Path parameters

| Name | Type | Required | Rules |
| --- | --- | --- | --- |
| `id` | `string` | Yes | Must be non-empty and URL-safe |

### Success response

**Status code**

`200 OK`

**Example body**

```json
{
  "reviewId": "payexc-100045",
  "status": "PENDING_REVIEW",
  "validationMode": "STANDARD",
  "escalationEnabled": true,
  "region": "CA-QC"
}
```

### Response fields

| Field | Type | Description |
| --- | --- | --- |
| `reviewId` | `string` | Review identifier received in the request |
| `status` | `string` | Current review lifecycle status |
| `validationMode` | `string` | Active validation mode used by the service |
| `escalationEnabled` | `boolean` | Indicates whether escalation is enabled |
| `region` | `string` | Active regional configuration |

### Allowed status values

- `RECEIVED`
- `VALIDATING`
- `PENDING_REVIEW`
- `APPROVED`
- `REJECTED`
- `ESCALATED`

### Validation rules

- `id` must not be blank
- `id` must be present in the path

### Error responses

**`400 Bad Request`**

Used when the path parameter is invalid.

**Example**

```json
{
  "error": "INVALID_REQUEST",
  "message": "Payment exception review id must not be blank."
}
```

**`500 Internal Server Error`**

Used when the application is unhealthy or cannot resolve the status.

## 2. Get service operational status

### Endpoint

`GET /api/payment-exceptions/service-status`

### Purpose

Return a compact operational view of the running service and its main runtime settings.

### Success response

**Status code**

`200 OK`

**Example body**

```json
{
  "service": "payment-exception-review-service",
  "version": "0.0.1-SNAPSHOT",
  "environmentName": "stage1",
  "infrastructureOwner": "infrastructure-team",
  "platformOwner": "platform-team",
  "validationMode": "STANDARD",
  "escalationEnabled": true,
  "riskAmountThreshold": 10000,
  "region": "CA-QC",
  "logLevel": "INFO"
}
```

### Response fields

| Field | Type | Description |
| --- | --- | --- |
| `service` | `string` | Logical service name |
| `version` | `string` | Current application version |
| `environmentName` | `string` | Platform environment name |
| `infrastructureOwner` | `string` | Infrastructure ownership metadata |
| `platformOwner` | `string` | Platform ownership metadata |
| `validationMode` | `string` | Current business validation mode |
| `escalationEnabled` | `boolean` | Indicates whether escalation is enabled |
| `riskAmountThreshold` | `number` | Active risk threshold configuration |
| `region` | `string` | Active regional configuration |
| `logLevel` | `string` | Effective log-level convention value |

### Error responses

**`500 Internal Server Error`**

Used when runtime metadata cannot be resolved.

## 3. Check active business configuration

### Endpoint

`GET /api/payment-exceptions/config-check`

### Purpose

Return whether the current application configuration is valid and visible at runtime.

### Success response

**Status code**

`200 OK`

**Example body**

```json
{
  "status": "VALID",
  "validationMode": "STANDARD",
  "escalationEnabled": true,
  "riskAmountThreshold": 10000,
  "region": "CA-QC",
  "environmentName": "stage1"
}
```

### Response fields

| Field | Type | Description |
| --- | --- | --- |
| `status` | `string` | Configuration validation result |
| `validationMode` | `string` | Current validation mode |
| `escalationEnabled` | `boolean` | Current escalation setting |
| `riskAmountThreshold` | `number` | Current risk threshold |
| `region` | `string` | Current regional configuration |
| `environmentName` | `string` | Current environment value |

### Allowed validation result values

- `VALID`

### Startup validation rules

The service should fail fast at startup if:

- `VALIDATION_MODE` is not one of `STRICT` or `STANDARD`
- `RISK_AMOUNT_THRESHOLD` is not a positive number

### Error behavior

If startup validation fails, the application should not reach normal ready state.

That means this endpoint may become unavailable rather than returning a normal runtime payload.

## 4. Actuator endpoints

These endpoints are part of the Stage 1 contract because they support probes and observability.

### Health

`GET /actuator/health`

Purpose:
- overall health visibility

Expected success code:
- `200 OK`

### Info

`GET /actuator/info`

Purpose:
- expose basic runtime/service metadata

Expected success code:
- `200 OK`

### Prometheus

`GET /actuator/prometheus`

Purpose:
- expose metrics for Prometheus scraping

Expected success code:
- `200 OK`

## 5. Configuration values expected by the service

### Infrastructure-owned values

| Variable | Example |
| --- | --- |
| `INFRASTRUCTURE_OWNER` | `infrastructure-team` |

### Platform-owned values

| Variable | Example |
| --- | --- |
| `ENV_NAME` | `stage1` |
| `PLATFORM_OWNER` | `platform-team` |
| `LOG_LEVEL` | `INFO` |

### Application-owned values

| Variable | Example | Rules |
| --- | --- | --- |
| `VALIDATION_MODE` | `STANDARD` | Allowed: `STRICT`, `STANDARD` |
| `ESCALATION_ENABLED` | `true` | Boolean |
| `RISK_AMOUNT_THRESHOLD` | `10000` | Positive integer |
| `REGION` | `CA-QC` | Non-empty string |

## 6. Initial implementation notes

For Stage 1, the contract can be implemented without a database.

A good first implementation is:

- deterministic in-memory status resolution based on the review id
- startup validation of configuration values
- Actuator endpoints exposed for runtime checks

This keeps the focus on delivery, runtime behavior, probes, and observability rather than persistence design.
