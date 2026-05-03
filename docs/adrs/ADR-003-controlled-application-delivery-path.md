# ADR-003 - Use GitHub Actions, Docker, and Helm for Controlled Application Delivery

## Status

Accepted

## Context

Stage 1 needs to prove more than the ability to deploy a container. It needs to show:

- a repeatable CI/CD path
- clear ownership by the application team
- Kubernetes deployment discipline
- a delivery flow that can support runtime validation and troubleshooting

The project also needs to stay finishable and interview-friendly.

## Decision

The application delivery path uses:

- **GitHub Actions** for CI/CD workflow orchestration
- **GitHub Container Registry (`ghcr.io`)** as the initial application image registry
- **Docker** for packaging the Spring Boot service into an immutable image
- **Helm** for deploying the service into the governed Kubernetes boundary

This path is application-team-owned and runs on top of the infrastructure and platform layers prepared earlier.

## Consequences

### Positive

- the delivery path is modern, recognizable, and easy to explain
- the image registry stays in the same control plane as the source repository and CI workflows
- Docker and Helm keep runtime packaging and deployment concerns explicit
- GitHub Actions provides a concrete CI/CD workflow for checks, build, packaging, and deployment
- the case stays realistic without introducing GitOps too early

### Negative

- the repo must still explain why later stages evolve toward stronger governance patterns such as ArgoCD
- CI/CD logic and deployment logic are split across multiple artifacts
- `ghcr.io` is a GitHub-centric choice rather than an Azure-native runtime registry

## Alternatives considered

### Direct kubectl-based deployment

Rejected because it weakens the packaging and standardization story.

### Do not use Azure DevOps for application image build and publishing

Rejected because the repository is already centered on:

- GitHub for source control
- GitHub Actions for CI/CD
- GitHub OIDC-based Azure authentication

Adding Azure DevOps at this stage would split the delivery story across two platforms and would increase onboarding, authentication, and operational complexity without materially improving the Stage 1 case.

### Use Azure Container Registry as the first image registry

Deferred rather than rejected.

Azure Container Registry is a valid later-stage option, especially for tighter Azure-native runtime integration, but `ghcr.io` is the simpler first-stage choice because it keeps:

- source
- CI/CD workflow automation
- container image publishing

inside the same GitHub-centered operating model.

### Introduce ArgoCD in Stage 1

Rejected because it adds maturity-stage complexity too early and weakens the focus on the basic controlled-delivery path.
