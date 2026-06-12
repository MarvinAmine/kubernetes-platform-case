# Stage 2 Architecture Documents

This folder is split by architecture purpose so runtime diagrams, admission
controls, and promotion flows do not get mixed together.

Architecture diagram process:

- [Architecture deliverables guide](../architecture-deliverables-guide.md)

## Solution

Solution diagrams show the human-facing overview: major actors, systems,
environments, ownership boundaries, delivery systems, runtime targets,
compatibility labs, and reliability evidence.

- [Stage 2 high-level solution architecture](./solution/stage2_high_level_solution_architecture_mermaid.md)
- [Stage 2 presentation diagrams](../../../presentation/stage2/stage2_presentation_mermaid.md)

## Runtime

Runtime diagrams show component interactions after the workload is already
running.

- [Local high-level runtime](./runtime/stage2_local_high_level_runtime_mermaid.md)
- [AKS non-prod high-level runtime](./runtime/stage2_aks_nonprod_highlevel_runtime_mermaid.md)
- [AKS prod high-level runtime](./runtime/stage2_aks_prod_highlevel_runtime_mermaid.md)
- [OpenShift Sandbox compatibility runtime](./runtime/stage2_openshift_sandbox_compatibility_runtime_mermaid.md)

## Admission

Admission diagrams show what happens before Kubernetes accepts a workload.

- [Local admission governance flow](./admission/stage2_local_admission_governance_flow_mermaid.md)
- [AKS non-prod admission governance flow](./admission/stage2_aks_nonprod_admission_governance_flow_mermaid.md)
- [AKS prod admission governance flow](./admission/stage2_aks_prod_admission_governance_flow_mermaid.md)

## Promotion

Promotion diagrams show delivery governance, PR flow, environment promotion,
image promotion, approval gates, and rollback.

- [Promotion governance flow](./promotion/stage2_promotion_governance_flow_mermaid.md)
- [Git branch promotion graph](./promotion/stage2_git_branch_promotion_flow_mermaid.md)
- [Git PR and image promotion flow](./promotion/stage2_git_pr_promotion_flow_mermaid.md)
- [DevOps good practices reference](./promotion/dev_ops_good_practices.html)

## Control Plane

Control-plane diagrams show which tools manage desired state, infrastructure,
secrets, policies, reconciliation, and operational automation. They are kept
separate from runtime diagrams because these tools do not normally sit in the
HTTP request path.

- [Stage 2 platform control-plane architecture](./control-plane/stage2_platform_control_plane_mermaid.md)
- [Stage 2 secrets governance flow](./control-plane/stage2_secrets_governance_flow_mermaid.md)

## Operations

Operational diagrams show how the platform is observed, investigated,
recovered, and improved through SLO/SLI direction, alerting, logs, runbooks,
rollback, MTTR measurement, and postmortem evidence.

- [Stage 2 operational architecture](./operations/stage2_operational_architecture_mermaid.md)

## HTML Drafts

HTML files are visual drafts or saved architecture prototypes.

- [Stage 2 architecture HTML](./html/architecture.html)
- [Stage 2 architecture saved HTML](./html/stage2_architecture_save.html)

## Notes

- [Stage 2 architecture follow-up notes](./notes/stage2-architecture-follow-up-notes.md)
