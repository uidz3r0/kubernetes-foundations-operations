## Lab 7 — Complete Design Review

This is the interview exercise.

Take one Deployment and explain it as if you were answering a design question in an interview.

A strong answer should connect each field to a requirement such as availability, scalability, security, or maintainability.

Take one Deployment.

Explain everything.

Example

- Why RollingUpdate?
  - Zero downtime deployment.

- Why replicas=3?
  - Survive one node failure.

- Why requests?
  - Guarantee scheduling.

- Why limits?
  - Prevent noisy neighbors.

- Why readinessProbe?
  - Avoid sending traffic to Pods still starting.

- Why anti-affinity?
  - Spread replicas across nodes.

- Why ClusterIP?
  - Ingress is the only public entry point.

- Why NetworkPolicy?
  - Zero-trust networking.

- Why SecurityContext?
  - Container hardening.