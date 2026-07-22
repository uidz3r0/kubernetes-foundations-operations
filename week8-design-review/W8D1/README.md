# Week 8 Day 1 - High Level Design (HLD)

## Objective

Design a production-ready Kubernetes platform from a high-level architectural perspective.

This is not a command-based exercise. The goal is to build a mental model of a production Kubernetes platform and be able to explain it clearly in interviews, design reviews, and architectural discussions.

This lab focuses on understanding how the major platform components fit together, why they are included, and what trade-offs they represent.

---

## How to approach this design

Think about the platform in this order:

1. Start with the requirement
2. Identify the platform concerns
3. Map the core components
4. Explain the traffic flow
5. Discuss resilience and recovery

A useful mindset is:

- What problem are we solving?
- What must stay available?
- Where could the platform fail?
- How would we recover?

---

## Design prompts

Use these prompts while building or reviewing your design:

- What is the entry point for client traffic?
- How does traffic reach the application?
- Where does TLS terminate?
- How are services discovered inside the cluster?
- What keeps the platform available if a node or zone fails?
- How is persistent data protected?
- How would you recover the platform after a major outage?

---

## Learning Objectives

- Kubernetes cluster architecture
- Control Plane components
- Worker Nodes
- Networking
- Storage
- DNS
- Ingress
- Load Balancing
- External services
- High Availability
- Failure Domains
- Disaster Recovery concepts

---

## Deliverables

- Production Kubernetes Architecture Diagram
- High-Level Design document
- Component descriptions
- Traffic flow explanation
- High Availability discussion
- Disaster Recovery overview

---

## Files

| File | Purpose |
|------|---------|
| architecture.md | High Level Design document |
| production-architecture.drawio | Editable architecture diagram |
| production-architecture.png | Exported architecture |

---

## Success Criteria

- Understand every major Kubernetes component
- Explain traffic flow end-to-end
- Identify failure domains
- Explain HA strategy
- Explain disaster recovery at a high level

---

For Kubernetes platforms, I recommend using these design principles.

| Principle             | Goal                                   | Design Decisions                                                                                |
| --------------------- | -------------------------------------- | ----------------------------------------------------------------------------------------------- |
| **Reliability**       | Keep applications running              | Multiple replicas, health probes, self-healing, rolling updates                                 |
| **High Availability** | Eliminate single points of failure     | 3 control planes, replicated etcd, multiple workers, redundant ingress/load balancers           |
| **Scalability**       | Handle growth                          | Horizontal Pod Autoscaler, Cluster Autoscaler (cloud), stateless applications, scalable storage |
| **Performance**       | Low latency and efficient resource use | Resource requests/limits, scheduling, node sizing, load balancing                               |
| **Security**          | Protect workloads and data             | RBAC, NetworkPolicies, Secrets, TLS, Pod Security, image scanning                               |
| **Resilience**        | Recover from failures                  | Self-healing, anti-affinity, PodDisruptionBudgets, automatic rescheduling                       |
| **Maintainability**   | Easy to operate                        | Infrastructure as Code, GitOps, standardized manifests, observability                           |
| **Observability**     | Understand system health               | Metrics, logs, traces, dashboards, alerts                                                       |
| **Disaster Recovery** | Recover from catastrophic events       | etcd backups, persistent volume backups, documented recovery procedures                         |
| **Portability**       | Avoid vendor lock-in                   | Kubernetes-native APIs, CSI, CNI, OCI images, cloud-agnostic design                             |
| **Cost Efficiency**   | Balance performance and cost           | Right-sized nodes, autoscaling, efficient resource requests, shared platform services           |

## The architecture is essentially built from these requirements

Instead of starting with "We need three control planes," start with the requirement.

```text
Requirement
      │
      ▼
Need high availability
      │
      ▼
Three control planes
      │
      ▼
Replicated etcd
      │
      ▼
Control plane survives a node failure
```

Another example:

```text
Requirement
      │
      ▼
Need scalability
      │
      ▼
Multiple worker nodes
      │
      ▼
Deployments with replicas
      │
      ▼
Horizontal Pod Autoscaler
```

Or

```text
Requirement
      │
      ▼
Need security
      │
      ▼
RBAC
Network Policies
Secrets
TLS
Admission Policies
```