Architected and implemented a production-oriented Kubernetes delivery foundation on Azure for a regulated internal payment review service. This project demonstrates a complete governed platform lifecycle:

- Infrastructure: Provisioned Azure foundation with Terraform, including remote state, AKS, networking, and managed Azure Database for PostgreSQL.
- Platform Engineering: Built a governed Kubernetes bootstrap layer with namespaces, RBAC, service accounts, runtime secret injection, and shared observability with Prometheus, Grafana, and Alertmanager.
- Application Delivery: Deployed a stateful Java / Spring Boot microservice with GitHub Actions, Docker, Helm, and PostgreSQL-backed persistence.
- Operations: Strengthened production readiness with health probes, metrics, rollout verification, and troubleshooting scenarios covering startup, configuration, observability, and connectivity failures.

Tech Stack: Azure (AKS, VNet, PostgreSQL), Kubernetes, Terraform, GitHub Actions, Docker, Helm, Java, Spring Boot, Prometheus, Grafana, Alertmanager, Azure OIDC.
