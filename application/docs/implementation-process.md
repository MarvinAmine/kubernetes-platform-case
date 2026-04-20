# Stage 1 Implementation Process

This document captures the end-to-end design and implementation process for the **Payment Exception Review Service**.

The goal is to keep one coherent path from business intent to actual code.

## 11-step process

### 1. Use cases and conditions of success

Define the service behavior from the actor point of view before designing the code.

This step answers:
- who interacts with the service
- why they interact with it
- what success looks like
- what operational behavior must also be supported

The Stage 1 use cases are:

#### UC1 - Consult payment exception status

- Goal: retrieve the current lifecycle status of a payment exception review
- Primary actors:
  - internal support agent
  - payment operations analyst
  - downstream internal system
- Conditions of success:
  - the API returns `200 OK`
  - the response contains the requested review identifier
  - the response contains a valid lifecycle status
  - the request is visible through logs or metrics

#### UC2 - Check service operational status

- Goal: confirm that the service is running and exposing expected operational metadata
- Primary actors:
  - application developer
  - support engineer
  - platform engineer
  - internal monitoring consumer
- Conditions of success:
  - the API returns `200 OK`
  - the response contains the service identity
  - the response exposes the expected runtime metadata
  - the returned values match the deployed configuration

#### UC3 - Verify active business configuration

- Goal: check that the service is running with valid business configuration
- Primary actors:
  - application developer
  - support engineer
  - SRE or platform engineer
- Conditions of success:
  - the API returns `200 OK`
  - the response clearly indicates whether the configuration is valid
  - the effective business configuration values are visible
  - invalid startup configuration prevents the service from reaching a normal ready state

#### UC4 - Kubernetes readiness verification

- Goal: allow Kubernetes to determine whether the pod is ready to receive traffic
- Primary actor:
  - Kubernetes
- Conditions of success:
  - the readiness endpoint responds successfully only when the service is actually ready
  - the pod transitions to `Ready`
  - the rollout can continue normally
  - traffic is not sent to unready pods

#### UC5 - Kubernetes liveness verification

- Goal: allow Kubernetes to detect when the running application instance is no longer healthy
- Primary actor:
  - Kubernetes
- Conditions of success:
  - the liveness endpoint responds successfully during normal runtime
  - the pod is kept running while healthy
  - repeated liveness failures trigger automatic restart behavior

#### UC6 - Metrics collection for observability

- Goal: expose application metrics for monitoring and troubleshooting
- Primary actors:
  - Prometheus
  - application team
  - platform team
- Conditions of success:
  - the metrics endpoint is reachable
  - Prometheus-formatted metrics are exposed successfully
  - core runtime and service metrics are present
  - metrics can be used for dashboards and incident diagnosis

Reference:
- [Use cases](./use-cases.md)

### 2. API contract

Define the API behavior in human-readable form.

This step fixes:
- endpoint purpose
- example requests and responses
- HTTP status expectations
- validation and error behavior

Reference:
- [API contract](./api-contract.md)

### 3. OpenAPI / Swagger

Translate the human-readable contract into a formal machine-readable API specification.

This step gives:
- a precise REST contract
- a schema baseline for implementation
- a reusable reference for future testing and documentation

Reference:
- [OpenAPI contract](./openapi.yaml)

### 4. Light domain model

Define the main business and runtime concepts without overdesigning the system.

This step clarifies:
- payment exception review concepts
- status vocabulary
- validation concepts
- runtime metadata concepts

Reference:
- [Domain model](./domain-model.md)

### 5. Light persistence model

Define the persisted view needed by Stage 1.

This step clarifies:
- what is stored in PostgreSQL
- key fields and identifiers
- what belongs to the database versus runtime config

Reference:
- [Persistence model](./persistence-model.md)

### 6. Architecture Decision Records

Capture the decisions that materially shape the implementation.

This step prevents implicit architecture drift.

It records choices such as:
- single service scope
- Java 21 and Spring Boot 3.x
- PostgreSQL persistence
- Kubernetes-native runtime patterns
- OpenAPI as formal contract

References:
- [Application ADRs](./adrs/README.md)
- [Root platform-case ADRs](/home/marvin/Documents/dev/kubernetes/docs/adrs/README.md)

### 7. Application architecture diagram

Describe how the service fits into the governed platform path.

This step clarifies:
- service boundary
- runtime placement
- delivery path
- observability relationship
- database relationship

Reference:
- [Application architecture](./architecture.md)

### 8. Config ownership table

Define which values belong to Infrastructure, Platform, and Application ownership.

This step reduces ambiguity around:
- `INFRASTRUCTURE_OWNER`
- `PLATFORM_OWNER`
- environment metadata
- business configuration
- secret usage

Reference:
- [Configuration ownership](./config-ownership.md)

### 9. Failure scenarios

Define the realistic failure modes before coding too far.

This step ensures the service is supportable, not only deployable.

Stage 1 focuses on:
- wrong readiness probe
- invalid business configuration

Reference:
- [Failure scenarios](./failure-scenarios.md)

### 10. Implementation skeleton

Define the package structure and code organization before filling in behavior.

This step fixes the code layout for:
- `controller`
- `service`
- `repository`
- `entity`
- `dto`
- `config`
- `exception`

Reference:
- [Implementation skeleton](./implementation-skeleton.md)

### 11. Start coding

After the design baseline is stable, implementation begins.

The current coding order is:
- DTOs and enums
- typed runtime configuration
- entity and repository
- service layer
- controller layer
- exception handling
- tests

Recommended first working slice:
- implement `GET /api/payment-exceptions/service-status`
- populate `ServiceStatusResponse`
- read values from `AppProperties`
- expose both `infrastructureOwner` and `platformOwner`

## Summary

This process is intentionally ordered to keep Stage 1:

- credible
- supportable
- explainable in interviews
- small enough to finish

It prevents jumping directly into code before:
- contract clarity
- ownership clarity
- runtime expectations
- failure behavior
- persistence shape

