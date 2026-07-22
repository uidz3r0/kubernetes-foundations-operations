## Lab 6 — Scheduling Review

This lab focuses on how workload placement is controlled to meet availability, performance, and isolation goals.

When reviewing the manifest, think about whether the workload belongs on a certain node class or whether it should be spread out for resilience.

Review

`nodeSelector`

Question

Why?

- Run workloads only on SSD nodes.

Review

`nodeAffinity`

Question

Why?

- More flexible scheduling than nodeSelector.

Review

`podAntiAffinity`

Question

Why?

- Don't place replicas on the same node.
- Increase availability.

Review

`tolerations`

- Allow Pods onto tainted nodes.

Example:

- Dedicated GPU
- Control Plane
- Database nodes