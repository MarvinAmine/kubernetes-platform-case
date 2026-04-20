# Use Cases

This document captures the Stage 1 use cases for the **Payment Exception Review Service**.

The service remains intentionally small. Its role is to justify a credible internal delivery path on AKS with clear operational behavior, not to model a full payment platform.

## Business use cases

### UC1 - Consult payment exception status

**Goal**  
Retrieve the current lifecycle status of a payment exception review.

**Primary actors**  
- Internal support agent
- Payment operations analyst
- Downstream internal system

**Preconditions**  
- The service is deployed and reachable.
- A payment exception review identifier is available.

**Trigger**  
An actor needs to know the current review state for a payment exception.

**Main success scenario**  
1. The actor sends a request to `GET /api/payment-exceptions/{id}/status`.
2. The service validates the request.
3. The service resolves the current review lifecycle state.
4. The service returns the review identifier and its status.

**Expected statuses**  
- `RECEIVED`
- `VALIDATING`
- `PENDING_REVIEW`
- `APPROVED`
- `REJECTED`
- `ESCALATED`

**Conditions of success**  
- The API returns `200 OK`.
- The response contains the requested review identifier.
- The response contains a valid lifecycle status.
- The request is visible through logs or metrics.

**Alternative flows**  
1. If the identifier is invalid, the service returns a client error.
2. If the service is unhealthy, the request fails and must be investigated through logs and health endpoints.

**Postconditions**  
- The actor knows the current review state.
- The request is observable through logs and metrics.

### UC2 - Check service operational status

**Goal**  
Confirm that the service is running and exposing the expected operational metadata.

**Primary actors**  
- Application developer
- Support engineer
- Platform engineer
- Internal monitoring consumer

**Preconditions**  
- The service is deployed.
- The endpoint is reachable.

**Trigger**  
A deployment validation or operational verification is required.

**Main success scenario**  
1. The actor sends a request to `GET /api/payment-exceptions/service-status`.
2. The service returns operational metadata.
3. The actor verifies service identity and key runtime values.

**Conditions of success**  
- The API returns `200 OK`.
- The response contains the service identity.
- The response exposes the expected runtime metadata.
- The returned values match the deployed configuration.

**Alternative flows**  
1. If the service is unavailable, the actor checks rollout status, pod events, and logs.

**Postconditions**  
- The actor confirms whether the service is up.
- The actor confirms whether runtime metadata matches expectations.

### UC3 - Verify active business configuration

**Goal**  
Check that the service is running with valid business configuration.

**Primary actors**  
- Application developer
- Support engineer
- SRE or platform engineer

**Preconditions**  
- The service is deployed.
- Configuration has been loaded by the application.

**Trigger**  
A deployment, startup validation, or troubleshooting session requires configuration verification.

**Main success scenario**  
1. The actor sends a request to `GET /api/payment-exceptions/config-check`.
2. The service evaluates the currently loaded business configuration.
3. The service returns the validation result and effective configuration values.

**Conditions of success**  
- The API returns `200 OK`.
- The response clearly indicates whether the configuration is valid.
- The effective business configuration values are visible.
- Invalid startup configuration prevents the service from reaching a normal ready state.

**Alternative flows**  
1. If the configuration is invalid at startup, the application fails fast and the endpoint is unavailable.
2. The issue is diagnosed through pod state, logs, and rollout events.

**Postconditions**  
- The actor knows whether the active configuration is valid.
- The actor can compare runtime values with expected deployment settings.

## Operational use cases

### UC4 - Kubernetes readiness verification

**Goal**  
Allow Kubernetes to determine whether the pod is ready to receive traffic.

**Primary actors**  
- Kubernetes

**Preconditions**  
- The pod has started.
- The readiness probe is configured.

**Trigger**  
Kubernetes executes the readiness probe during startup or rollout.

**Main success scenario**  
1. Kubernetes calls the readiness endpoint.
2. The application responds successfully only when startup is complete and the service is ready.
3. Kubernetes marks the pod as ready.
4. Traffic can be routed to the pod.

**Conditions of success**  
- The readiness endpoint responds successfully only when the service is actually ready.
- The pod transitions to `Ready`.
- The rollout can continue normally.
- Traffic is not sent to unready pods.

**Alternative flows**  
1. If the readiness path is wrong, the pod stays unready even when the container is running.
2. If startup validation fails, the pod never becomes ready.

**Postconditions**  
- Only ready pods receive traffic.
- Rollout safety is preserved.

### UC5 - Kubernetes liveness verification

**Goal**  
Allow Kubernetes to detect when the running application instance is no longer healthy.

**Primary actors**  
- Kubernetes

**Preconditions**  
- The pod is running.
- The liveness probe is configured.

**Trigger**  
Kubernetes executes the liveness probe periodically.

**Main success scenario**  
1. Kubernetes calls the liveness endpoint.
2. The application responds successfully while it remains healthy.
3. Kubernetes keeps the pod running.

**Conditions of success**  
- The liveness endpoint responds successfully during normal runtime.
- The pod is kept running while healthy.
- Repeated liveness failures trigger automatic restart behavior.

**Alternative flows**  
1. If the liveness probe fails repeatedly, Kubernetes restarts the container.

**Postconditions**  
- Unhealthy pods are recycled automatically.
- Runtime resilience is improved.

### UC6 - Metrics collection for observability

**Goal**  
Expose application metrics for monitoring and troubleshooting.

**Primary actors**  
- Prometheus
- Application team
- Platform team

**Preconditions**  
- The application is running.
- Prometheus can reach the metrics endpoint.

**Trigger**  
Prometheus scrapes `/actuator/prometheus`.

**Main success scenario**  
1. Prometheus requests the metrics endpoint.
2. The application exposes JVM, HTTP, health, and service metrics.
3. Metrics are collected for dashboards and troubleshooting.

**Conditions of success**  
- The metrics endpoint is reachable.
- Prometheus-formatted metrics are exposed successfully.
- Core runtime and service metrics are present.
- Metrics can be used for dashboards and incident diagnosis.

**Alternative flows**  
1. If the metrics endpoint is not reachable, observability is reduced and diagnosis becomes slower.

**Postconditions**  
- Application metrics are available.
- Engineers can use them to understand health, traffic, and runtime behavior.

## Scope note

These use cases intentionally stay narrow.

They support the Stage 1 objective:

- controlled delivery
- Kubernetes runtime credibility
- configuration discipline
- observability support
- realistic troubleshooting

They intentionally do not yet cover:

- customer-facing workflows
- authentication and authorization flows
- persistence workflows
- service-to-service orchestration
