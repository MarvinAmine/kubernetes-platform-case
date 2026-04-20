# ADR-009 - Default to Standard_D2als_v6 While Documenting Standard_B2als_v2 as the Lower-Cost Fallback

## Status

Accepted

## Context

Stage 1 needs an AKS node size that is:

- affordable enough for personal Azure subscriptions
- credible for a production-oriented platform case
- likely to work across different subscriptions, regions, and quota situations

Two relevant Azure VM sizes for this project are:

- `Standard_B2als_v2`
- `Standard_D2als_v6`

Both provide:

- 2 vCPUs
- 4 GiB RAM

However, they represent different trade-offs.

Microsoft documents the `Basv2` family as a **low cost CPU burstable** series and a **cost effective** option for general purpose workloads.  
Source: https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/general-purpose/basv2-series

Microsoft documents the `Dalsv6` family as a stronger general-purpose series for broader workloads.  
Source: https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/general-purpose/dalsv6-series

Azure also enforces quotas at both:

- the total regional vCPU level
- the VM family level

This means practical usability depends on subscription, region, and quota availability.  
Source: https://learn.microsoft.com/en-us/azure/virtual-machines/quotas

## Decision

The repository keeps:

- `Standard_D2als_v6` as the default VM size

and documents:

- `Standard_B2als_v2` as the lower-cost fallback when it is available in the target subscription and region

The project also documents that users may need to request quota increases if the preferred or fallback size is not currently available to them.

## Consequences

### Positive

- the default remains a stronger and safer general-purpose baseline for Stage 1
- the project stays accessible to users who need a cheaper fallback
- cost-awareness and Azure quota-awareness are made explicit
- the repo balances credibility with practical usability

### Negative

- different users may run Stage 1 on different VM families
- runtime behavior and performance can vary slightly depending on the chosen size
- documentation must explain why the cheaper size is not the default

## Alternatives considered

### Use Standard_B2als_v2 as the default

Rejected because although it is the cheaper option, the project benefits from a more stable general-purpose default for the intended Stage 1 platform case.

### Use only Standard_D2als_v6 with no cheaper fallback guidance

Rejected because it makes the project less accessible for users with tighter subscription budgets.

### Support many equal-priority VM size defaults

Rejected because it adds unnecessary choice and weakens the clarity of the documented baseline.
