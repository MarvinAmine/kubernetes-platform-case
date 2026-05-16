# Release Management

[MAIN DOC: Stage 1 of 3 - Governed AKS delivery foundation for an internal payment review service ->](./README.md)

This repository uses Git tags and GitHub Releases to make each completed stage
easy to find, replay, and review later.

The goal is to keep the staged progression clear:

- `main` keeps evolving toward the next stage
- versioned tags preserve completed stage snapshots
- GitHub Releases provide recruiter-friendly and reviewer-friendly milestone pages
- hosted presentations provide a visual walkthrough of each completed stage

## Stage 1 release

The completed Stage 1 snapshot should be tagged as:

```bash
stage1-v1.0.0
```

Recommended tag command:

```bash
git tag -a stage1-v1.0.0 -m "Stage 1 complete: governed AKS delivery foundation"
git push origin stage1-v1.0.0
```

After pushing the tag, create a GitHub Release from that tag.

Recommended release title:

```text
Stage 1 v1.0.0 - Governed AKS Delivery Foundation
```

## Stage 1 application artifact

The Stage 1 application image is published to GHCR:

```text
https://github.com/MarvinAmine/kubernetes-platform-case/pkgs/container/payment-exception-review-service
```

This package is part of the Stage 1 release evidence because the application
delivery path builds, publishes, and deploys the Spring Boot service through
GitHub Actions, GHCR, Docker, and Helm.

## Stage 1 presentation

The Stage 1 visual walkthrough is published here:

```text
https://marvinmeite.cloud/payment-exception-review-stage-1/
```

This presentation is part of the Stage 1 release evidence. It summarizes:

- the business context
- the infrastructure, platform, and application ownership model
- the controlled delivery path
- the application runtime path
- observability and dashboards as code
- troubleshooting scenarios
- FinOps decisions
- the Stage 1 outcome

## How newcomers can replay a stage

To inspect the exact Stage 1 repository state after the tag exists:

```bash
git fetch --tags
git checkout stage1-v1.0.0
```

To return to the active development branch:

```bash
git checkout main
```

To create a working branch from the Stage 1 snapshot:

```bash
git checkout -b stage1-replay stage1-v1.0.0
```

## Release discipline

Use this rule for future stages:

- bug fixes that improve an already released stage can receive a patch tag
- new stage capabilities should be added after the previous stage tag
- each completed stage should have a versioned tag and a GitHub Release

Example future tags:

```text
stage1-v1.0.1
stage2-v1.0.0
stage3-v1.0.0
```
