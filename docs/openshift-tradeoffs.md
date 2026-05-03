# OpenShift Tradeoffs

This document clarifies why Stage 2 uses OpenShift-oriented platform features
without making multi-cloud the primary reason for that choice.

## Current Stage 2 choice

Stage 2 uses OpenShift as the reference platform for stronger enterprise
Kubernetes operating features such as:

- project and namespace governance patterns
- stronger admission and security defaults
- route and ingress management patterns
- stricter service account and RBAC operating conventions
- platform guardrails around multi-team tenancy
- more enterprise-oriented operational tooling and supportability patterns
- GitOps-friendly shared-platform operating behavior

The point of the choice is not "multi-cloud for its own sake".

The point is to model the kind of Kubernetes operating experience commonly
found in highly regulated enterprises where governance, supportability,
platform controls, and operational consistency matter more than using raw
upstream Kubernetes everywhere.

## Why OpenShift in Stage 2

OpenShift is useful in this repository because it represents:

- stronger enterprise Kubernetes conventions
- better alignment with governed shared-platform operations
- a more realistic platform-team operating model
- features and defaults that push the design toward production discipline

That makes it a stronger Stage 2 fit than staying only at the level of a basic
managed Kubernetes cluster with lighter governance assumptions.

## What belongs to Stage 2

Stage 2 is where the repository focuses on enterprise Kubernetes operating
features, for example:

- stronger dev / prod separation
- multi-team isolation and governed tenancy
- GitOps-style reconciliation and controlled promotion
- centralized secrets handling
- shared observability services
- platform defaults and policy-aware operations
- OpenShift-style operational guardrails and supportability patterns

These are platform-governance and enterprise-Kubernetes concerns.

## What is deferred to Stage 3

The following concerns are intentionally treated as later-stage architecture
features rather than the main purpose of Stage 2:

- hybrid Azure and AWS platform design
- on-prem platform compatibility direction
- multi-cluster operating patterns across different hosting models
- stronger portability design across providers
- broader enterprise identity integration across environments
- enterprise-wide observability federation and long-term cross-environment view

These are multi-cloud and broader enterprise-architecture concerns.

## Why not position OpenShift primarily as a multi-cloud choice?

OpenShift can support multi-environment and hybrid strategies, but that is not
the main reason for using it in Stage 2.

If multi-cloud were made the main reason too early, the repository would blur
two different maturity signals:

- Stage 2: governed shared-platform operations
- Stage 3: broader hybrid-cloud and enterprise architecture credibility

The better progression is:

- Stage 2: use OpenShift for enterprise Kubernetes features and stronger
  platform governance
- Stage 3: extend the platform story into wider hybrid and multi-environment
  architecture concerns

## Practical tradeoff

### Option A - Use OpenShift for Stage 2 enterprise platform features

Pros:

- stronger enterprise Kubernetes credibility
- better platform-governance signal
- clearer shared-platform operating model
- closer fit for regulated organizations with stronger operational standards

Cons:

- adds platform complexity compared with a lighter Kubernetes baseline
- can be overkill if the goal is only to prove simple deployment capability
- introduces vendor-flavored platform thinking earlier

### Option B - Stay only with a lighter upstream or managed Kubernetes baseline

Pros:

- simpler
- easier to explain initially
- fewer platform-specific concepts

Cons:

- weaker enterprise shared-platform signal
- weaker governance story
- less realistic for organizations that expect stronger platform controls

## Decision

The repository uses this progression:

- Stage 1: governed AKS delivery foundation
- Stage 2: OpenShift-oriented enterprise Kubernetes features for shared-platform
  governance
- Stage 3: broader hybrid-cloud and enterprise architecture direction

So the rule is:

- OpenShift in Stage 2 is mainly about enterprise Kubernetes operating
  features
- multi-cloud is a later architecture concern, not the primary justification

