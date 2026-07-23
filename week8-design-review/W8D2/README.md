# W8D2 – Low Level Design

## Goal

Understand why Kubernetes manifests are written the way they are.

Today's focus is not writing YAML.

Today's focus is defending design decisions.

This day is about building a strong mental model for explaining manifests in interviews, design reviews, and implementation discussions. The goal is not to memorize syntax but to explain why each choice exists and what trade-off it represents.

---

## How to approach this day

For each manifest, ask yourself:

1. What problem is this resource solving?
2. What design goal does it support?
3. What happens if this setting is changed?
4. What trade-off am I making?
5. How would I explain this in an interview?

A good answer should connect the manifest field to one or more of these outcomes:

- availability
- scalability
- security
- maintainability
- operability

---

## Topics

- Deployment strategy
- Requests & Limits
- Probes
- HPA
- Affinity
- Taints & Tolerations
- Network Policies
- Storage Classes
- Security Contexts

---

## Labs

1. Review Deployment
2. Review Service
3. Review Ingress
4. Review Storage
5. Review Security
6. Review Scheduling
7. Complete Design Review

---

## End-of-Day Checklist

You should be comfortable explaining:

- Why `Deployment` is used instead of `Pod`
- Why `RollingUpdate` is the default deployment strategy
- How `requests` and `limits` affect scheduling and runtime
- The differences between `readinessProbe`, `livenessProbe`, and `startupProbe`
- When to use `HorizontalPodAutoscaler` versus increasing replicas manually
- When to use `nodeSelector`, `nodeAffinity`, `podAffinity`, and `podAntiAffinity`
- How taints and tolerations protect dedicated nodes
- Why `NetworkPolicy` implements a zero-trust model
- When to choose different `StorageClass` and access modes
- How `securityContext` enforces least privilege
- How all of these choices contribute to availability, scalability, security, and maintainability

## Review

This is one of the strongest design-focused days in your Phase 1 roadmap. It shifts you from `writing Kubernetes YAML` to `reasoning about production-grade implementation decisions`, which is exactly what senior Platform Engineer, DevOps, and SRE interviews assess. It also complements W8D1 nicely:

- `W8D1 (HLD)`: Why does the platform have these components?
- `W8D2 (LLD)`: Why is each Kubernetes resource configured this way?

By the end of W8D2, you should be able to open almost any Deployment, Service, or Ingress manifest and confidently explain the purpose and trade-offs of every significant field. That level of understanding is far more valuable than memorizing YAML syntax.

## Why these manifests?

```text
manifests/
├── app.yaml              # Production Deployment
├── service.yaml          # ClusterIP Service
├── ingress.yaml          # Ingress with TLS
├── networkpolicy.yaml    # Default deny + allow web traffic
└── pvc.yaml              # PersistentVolumeClaim
```

I intentionally kept them realistic but not overly complex:

- app.yaml demonstrates rolling updates, probes, resource management, and container hardening.
- service.yaml shows the most common internal service pattern (ClusterIP).
- ingress.yaml introduces host-based routing and TLS without controller-specific annotations.
- networkpolicy.yaml implements a basic zero-trust model by allowing traffic only from the ingress controller namespace.
- pvc.yaml demonstrates dynamic provisioning with a StorageClass.

These same manifests can be revisited in later weeks when you study:

- Week 6: Security (expand securityContext and NetworkPolicy)
- Week 7: Operations (rolling updates, maintenance, troubleshooting)
- Phase 2: Helm, GitOps, Kustomize, and policy-as-code

This reuse reinforces why each field exists instead of treating the manifests as one-off examples.