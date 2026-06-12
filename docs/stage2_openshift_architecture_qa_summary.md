# Stage 2 OpenShift Architecture — Q&A Summary

Condensed working memo from the architecture, tooling, OpenShift, CRC, ARO, and cost discussion

Generated: 2026-05-26

## Executive summary
- Stage 2 should be presented as a governed enterprise OpenShift-oriented platform architecture, not as a generic Kubernetes lab.
- Because managed OpenShift services such as ARO are expensive and slow to bootstrap, the practical strategy is to separate target architecture from affordable validation.
- Target architecture: Enterprise OpenShift Platform, preferably provider-neutral and hybrid-ready, with ARO, IBM Cloud OpenShift, ROSA, or self-managed OpenShift as possible implementation options.
- Affordable validation: Red Hat Developer Sandbox for OpenShift behavior, kind or AKS Free tier for GitOps/security/observability controls, and local tools for security scans and documentation.
- Do not pretend to run a full enterprise platform if you are not running it. Make the cost constraint an ADR and show what is validated, simulated, and deferred.

## Final recommended direction
- Stage 1: keep the local kind-based Kubernetes runtime architecture and document the app, PostgreSQL, Secret, ConfigMap, Prometheus, and Grafana flows clearly.
- Stage 2: use OpenShift-first language, but avoid hardcoding ARO as the only target. Use 'Enterprise OpenShift Platform' as the target runtime.
- OpenShift validation: use Red Hat Developer Sandbox first, because it preserves local disk space and gives real OpenShift Projects, Routes, Services, Pods, ConfigMaps, Secrets, ServiceAccounts, and oc CLI practice.
- Do not install CRC on the shared NTFS partition. If CRC is used later, put it on an ext4 Linux partition or external SSD, not on /dev/sda3.
- Do not use ARO as a daily lab. Treat it as an optional short proof session after all manifests and commands are prepared.

## Q&A summary
### 1. Can you browse my Stage 2 baseline and help create four architectures for local, dev, staging, and prod?
Create four architecture views, not four separate cloud estates. Local is validation, dev and staging share non-prod, prod is isolated. The useful split is local, dev, staging, prod, plus separate platform/runtime, security, observability, and promotion views.

### 2. Which tools produce beautiful diagrams in 2026, and how are dynamic LinkedIn diagrams made?
Use draw.io for technical diagrams, Figma or Canva for polish, and export PDF carousels or MP4 videos for LinkedIn. LinkedIn dynamic diagrams are usually PDF carousels, short MP4 animations, or screen recordings, not interactive HTML embedded in the feed.

### 3. Should I use Figma or draw.io?
Figma is better for polished visuals and LinkedIn; draw.io is better for technical architecture diagrams because it already includes Azure, Kubernetes, database, and network icon libraries. For this project, draw.io is a strong choice.

### 4. For the Local page, should I only include solution-architecture relevant elements?
Yes. A high-level solution architecture should show the user/operator, environment boundary, runtime platform, application, data store, endpoint, and key platform services. Avoid kubelet, scheduler, node internals, and excessive implementation noise unless the diagram is explicitly a runtime view.

### 5. Should I draw the Kubernetes node?
No for a high-level solution architecture. Draw the node only in a lower-level runtime/infrastructure diagram. For compact environment architecture, show the cluster/project/namespace and workloads, not kubelet/control-plane internals.

### 6. For Stage 2, should I mix solution architecture and infrastructure runtime?
Do not fully mix them. Show the solution architecture first, then show infrastructure/runtime as a second view. Senior architecture decomposes by views: solution, runtime, deployment, security, observability, promotion, and ownership.

### 7. Are we really using the Stage 2 tech stack? I mentioned OpenStack/OpenShift.
The Stage 2 direction is OpenShift, not OpenStack. OpenShift is enterprise Kubernetes. OpenStack is private-cloud infrastructure. The Stage 2 architecture should show OpenShift-oriented governance, but only include technologies relevant to the diagram view.

### 8. Should I test OpenShift locally first?
Yes if Stage 2 is meant to prove OpenShift readiness, but do not block the project on local CRC if storage is constrained. OpenShift behavior can be validated with Red Hat Developer Sandbox first.

### 9. Can you reread the docs and align with what Stage 2 is supposed to be?
Stage 2 is a governed shared platform model for regulated environments: OpenShift, ArgoCD, Vault direction, Kyverno, security gates, Prometheus/Grafana, Elasticsearch/Kibana, controlled promotion, and multi-team boundaries.

### 10. Which technologies should be included in the Stage 2 local solution architecture?
Include OpenShift Project/Route/Service, Spring Boot API, PostgreSQL, Secret/ConfigMap, ServiceAccount/RBAC, Helm release, Prometheus/Grafana if locally installed, and policy/secret-contract direction. Do not force every Stage 2 tool into the local diagram.

### 11. On local, will I use OpenShift and Kibana?
Use OpenShift behavior locally or in the Developer Sandbox. Do not put Kibana in the main local solution architecture unless you actually run it locally. For local, Prometheus/Grafana are enough. Kibana belongs in a separate observability lab or dev/prod platform view.

### 12. How can I test Elasticsearch and Kibana?
Test them separately from the local solution architecture. Fastest path: Docker/local Elastic or OpenSearch lab. More OpenShift-aligned path: ECK/OpenShift observability lab, but this is heavier and should not be your first local target on limited hardware.

### 13. Can you give the entire Stage 2 solution architecture without oversimplifying?
The complete Stage 2 architecture should have zones: governance/control plane, source of truth, PR/SSDLC gates, CI/artifact production, infrastructure foundation, non-prod platform estate, prod platform estate, reliability/promotion/operations, observability/logging, and GitOps/platform runtime.

### 14. For the Stage 1 local diagram, where should arrows go?
Use arrows for important flows only: Developer to service, service to pod, app to PostgreSQL service, PostgreSQL service to pod, pod to Secret/ConfigMap as dependency or Secret/ConfigMap to pod as injection, Prometheus to app service, Grafana to Prometheus, dashboard ConfigMap to Grafana.

### 15. When an element is used, where should the arrow point?
For runtime calls: caller -> target. For dependency view: component -> object used. For config injection view: config source -> consumer. Do not mix conventions without labels.

### 16. Are you sure about arrow direction?
The strict dependency convention is pod -> Secret/ConfigMap because the pod uses them. The injection convention is Secret/ConfigMap -> pod. Both are valid if labelled. For senior diagrams, choose one convention and add a legend.

### 17. Should PostgreSQL Pod connect to the Secret if scripts use .env to create the DB?
Yes if the script creates a Kubernetes Secret and the PostgreSQL container receives POSTGRES_PASSWORD through secretKeyRef. The accurate setup flow is .env -> script -> Kubernetes Secret -> PostgreSQL Pod.

### 18. What changes when creating the Stage 2 local diagram?
Stage 2 local should add platform governance around the same workload: OpenShift project/route direction, ServiceAccount/RBAC, Vault-ready Secret contract, environment-aware ConfigMap, Kyverno policy direction, ServiceMonitor, platform labels, and GitOps-ready manifests.

### 19. Can we use OpenShift locally?
Yes. The official local option is Red Hat OpenShift Local / CRC, a single-node local OpenShift cluster for development/testing. But it is heavier than kind and needs meaningful CPU, RAM, and disk.

### 20. I have 20 GB RAM. Is OpenShift Local free?
OpenShift Local can be used for free for development/testing, but it requires a Red Hat account and pull secret. With 20 GB RAM, it is possible, but do not overload it with Elasticsearch/Kibana immediately.

### 21. Is a Red Hat account free? Is there a minimal OpenShift locally? Are Elasticsearch and Kibana free/open source?
A Red Hat developer account is free. The minimal official local OpenShift is OpenShift Local/CRC. MicroShift exists but is more edge-focused. Elasticsearch/Kibana can be used free for lab use, but licensing is nuanced; OpenSearch/OpenSearch Dashboards are the cleaner Apache 2.0 open-source alternative.

### 22. Can I create CRC on /dev/sda3?
Not directly. CRC should not use a raw block device. It needs a filesystem path. More importantly, your /dev/sda3 is NTFS/shared with Windows, so it is not recommended for CRC VM/storage files.

### 23. My /dev/sda3 is shared between Windows and Ubuntu. What should I do?
Do not put CRC on the NTFS shared partition. Use the Ubuntu ext4 partition for Linux VM/container workloads, or use an external SSD/ext4 partition if you need more space.

### 24. 35 GB for CRC is too much. How can I keep Ubuntu storage?
Then do not install CRC on the Ubuntu partition right now. Use Red Hat Developer Sandbox for OpenShift validation and keep local storage for code, diagrams, tools, and Stage 1 kind work.

### 25. Is Red Hat Developer Sandbox in the browser?
Yes. It is a hosted OpenShift environment accessible through the web console. You can also connect from your Ubuntu terminal using oc CLI.

### 26. What are the tradeoffs of Sandbox vs CRC vs kind?
Sandbox saves disk and gives real OpenShift behavior, but has limits around cluster-admin and operators. CRC gives more local control but consumes disk/RAM. kind is fast and cheap but is not OpenShift.

### 27. What is the price of OpenShift Sandbox after 30 days? Can I use a VM in Azure/AWS? Can I install OpenShift on AKS?
The sandbox is a temporary free trial-style environment, not a normal paid long-lived cluster. CRC inside a cloud VM is not a good path because of nested virtualization. OpenShift is not installed on AKS; use ARO for Azure managed OpenShift.

### 28. If I deploy OpenShift on Azure, will it be expensive?
Yes. ARO is expensive for an individual because it requires multiple nodes and worker OpenShift licensing. Treat it as a target enterprise platform or optional short proof session, not a daily lab.

### 29. How can I continue the project if ARO is too expensive?
Continue with a target architecture + cost-controlled validation model: target enterprise OpenShift architecture, Red Hat Developer Sandbox for OpenShift behavior, kind/AKS Free tier for platform controls, and strong documentation/evidence.

### 30. Can Azure provide a non-VM instance to make OpenShift cheaper if I install it myself?
No practical cheap magic option. Azure Dedicated Host still hosts Azure VMs and is usually more expensive. Self-installing OpenShift on Azure VMs avoids some managed-service packaging but still requires multiple nodes and operational burden.

### 31. Who owns Red Hat?
IBM owns Red Hat. IBM acquired Red Hat in 2019. Red Hat remains the enterprise open-source brand behind OpenShift, RHEL, Ansible, Quay, and related products.

### 32. Does IBM offer a less expensive cloud for OpenShift?
IBM offers Red Hat OpenShift on IBM Cloud, but it is still an enterprise managed OpenShift service. It may be attractive for regulated industries or companies with entitlements/credits, but it is not automatically cheap for an individual.

### 33. Which cloud provider do big regulated corporations in Montréal/Québec use for OpenShift? Are they using ARO?
There is no reliable public proof that Montréal regulated companies mainly use ARO. ARO was too opinionated as a universal answer. A provider-neutral, hybrid-ready Enterprise OpenShift Platform is safer: self-managed OpenShift/private cloud, ARO, IBM Cloud OpenShift, or ROSA depending on organization standard.

### 34. What if I use only 30 minutes of ARO?
The running cost for 30 minutes may be small, but ARO is not a 30-minute casual lab. Creation, validation, screenshots, and deletion can take hours, and the risk is forgetting it running.

### 35. How long does ARO take to bootstrap?
Plan roughly 45-75 minutes for cluster creation and 2-3 hours for a controlled proof session including setup, validation, screenshots, and cleanup. It is heavier than AKS.

### 36. My Stage 1 AKS already takes 20 minutes to bootstrap. What does that imply?
ARO will feel heavier. Use ARO only as optional evidence capture, not as a normal development loop.

### 37. Why do companies use ARO if it is so long to bootstrap?
Companies do not recreate clusters daily. They provision once, harden, connect IAM/networking/secrets/monitoring, onboard many teams, and keep the platform for months or years. Daily app deployment is fast once the platform exists.

### 38. Are you sure Montréal regulated companies are using ARO?
No. The safer answer is that regulated companies are likely to use enterprise OpenShift in hybrid/provider-specific forms. For your diagrams, use 'Enterprise OpenShift Platform' and list ARO/ROSA/IBM/self-managed as deployment options, not assumptions.

## ADR-style decision
**ADR-Style Decision:** Use a cost-controlled validation strategy for Stage 2 instead of continuously running ARO.

**Context:** Stage 2 targets highly regulated organizations, but managed OpenShift estates are too expensive and slow for daily individual portfolio work.

**Decision:** Represent the target as a provider-neutral Enterprise OpenShift Platform. Validate OpenShift-specific behavior in Red Hat Developer Sandbox. Validate GitOps, policy, security, and observability controls in kind/AKS Free tier/local labs. Use ARO only as an optional short proof session if credits/budget are available.

**Consequences:** The project remains credible if the documentation clearly separates target architecture, validated implementation, simulated controls, and deferred enterprise deployment.

## Validation matrix
- **OpenShift Projects, Routes, Services, Pods:** Target: Enterprise OpenShift. Affordable validation: Red Hat Developer Sandbox.
- **ServiceAccount and RBAC basics:** Target: Enterprise OpenShift. Affordable validation: Sandbox + kind/AKS.
- **ArgoCD GitOps:** Target: Enterprise OpenShift. Affordable validation: kind or AKS Free tier.
- **Vault secret contract:** Target: Enterprise OpenShift + Vault. Affordable validation: local Vault/dev contract + documented injection pattern.
- **Kyverno policies:** Target: Enterprise OpenShift admission controls. Affordable validation: kind or AKS Free tier.
- **Prometheus/Grafana:** Target: platform observability. Affordable validation: kind/AKS/local stack.
- **Elasticsearch/Kibana or OpenSearch:** Target: platform log investigation. Affordable validation: separate Docker/local lab or deferred dev platform test.
- **Security gates:** Target: enterprise SSDLC. Affordable validation: GitHub Actions with Checkmarx/Snyk/Trivy/Checkov/secret scanning/ZAP where available.
- **Production approval and rollback:** Target: enterprise release governance. Affordable validation: GitHub Environments, Helm rollback, runbooks, release evidence.

## Bottom line
Continue the Stage 2 project without paying for a permanent ARO cluster. Make the enterprise OpenShift architecture provider-neutral, validate OpenShift-specific behavior with the Red Hat Developer Sandbox, validate platform controls in cheap labs, and document the tradeoffs honestly.