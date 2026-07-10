# Kubernetes Learning Journey

## Purpose

Build practical Kubernetes, Platform Engineering, and Cluster Operations capability through structured hands-on learning.

This repository focuses on:

* Real operational understanding
* Incremental hands-on practice
* Troubleshooting and debugging
* Platform engineering concepts
* Architecture awareness
* Long-term Kubernetes and CKA readiness

---

# Learning Phases

## Phase 1 — Kubernetes Foundations & Operations

Duration: ~8 weeks

Focus:

* Kubernetes fundamentals
* Networking and storage
* Troubleshooting
* Platform engineering
* Security basics
* Cluster operations
* Architecture awareness or Design & Review

Goal:

Become comfortable operating and reasoning about Kubernetes workloads and clusters in real-world scenarios.

This phase is NOT intended to be a pure CKA cram course.

Instead, it builds the operational foundation that makes future CKA preparation significantly easier.

---

# Progress Legend

* `[ ]` not started
* `[⏳]` in progress / partial understanding
* `[x]` completed confidently

A topic is considered complete when it can be:

* explained clearly
* demonstrated without heavy guidance
* troubleshooted at a basic level

---

# Week 0 — Home Lab Preparation (1 Day)

## Objectives

Prepare Linux virtual machines for a kubeadm-based Kubernetes cluster.

## Topics

### Hardware

* Plan cluster topology
* Control Plane vs Worker roles
* CPU/RAM sizing
* Static IP planning

### Operating System

* Install Rocky Linux / Ubuntu
* Configure hostname
* Configure /etc/hosts
* Configure static networking
* SSH access

### Linux Preparation

* Disable swap
* Configure kernel modules
* Configure sysctl
* Install containerd
* Configure systemd cgroups

### Kubernetes Packages

* Install kubeadm
* Install kubelet
* Install kubectl

### Validation

* Verify networking
* Verify time synchronization
* Verify containerd
* Verify kubelet service

Goal

Prepare all nodes for Kubernetes installation using kubeadm.

Notes

Cluster initialization is intentionally deferred until Week 7.

---

# Week 1 — Foundations

## Core Objects

* [x] Setup kind
* [x] kubectl basics
* [x] Pods
* [x] Deployments
* [x] ReplicaSets
* [x] Namespaces
* [x] Labels / Selectors
* [x] Services
* [x] ConfigMaps
* [x] Secrets
* [x] Foundation Lab

## Goal

Understand Kubernetes core objects and the desired-state model.

### Topics

1. Workloads

   * Pods
   * ReplicaSets
   * Deployments

2. Grouping and Control

   * Labels
   * Selectors
   * Namespaces

3. Networking

   * Services
   * Service discovery basics

4. Configuration

   * ConfigMaps
   * Secrets

## Suggested Week Structure

### Day 1 — Cluster Foundations

* kind cluster setup
* kubectl context and cluster inspection
* nodes, namespaces, and control plane basics

### Day 2 — Standalone Pods

* imperative Pod creation
* create, delete, describe, logs, and exec
* Pod lifecycle and behavior

### Day 3 — Deployments and ReplicaSets

* desired state
* self-healing
* scaling
* rollout and rollback

### Day 4 — Labels, Selectors, and Namespaces

* grouping and filtering
* logical isolation
* controller ownership and selector matching

### Day 5 — Services and Cluster Networking

* Pod IP problem
* ClusterIP
* selectors in Services
* service discovery
* DNS basics

### Day 6 — ConfigMaps and Secrets

* app configuration
* environment variables
* mounted files
* secret injection

### Day 7 — Foundation Lab / Integration Day

* build a mini application stack
* combine Deployment, Service, ConfigMap, and Secret
* troubleshoot broken selectors and configuration
* tie Week 1 concepts together

---

# Week 2 — Networking & Storage

## Networking

### Services

* [x] ClusterIP
* [x] NodePort
* [x] LoadBalancer (Concepts)
* [x] Ingress (Concepts)

### Service Discovery

* [x] DNS-based Service Discovery
* [x] Service Names
* [x] Service Selectors

### DNS

* [x] CoreDNS
* [x] DNS Search Paths
* [x] Service Resolution

### Modern Kubernetes Networking

* [x] Gateway API (Introduction)

---

## Storage

### Basic Volumes

* [x] Volumes
* [x] volumeMounts
* [x] emptyDir
* [x] hostPath

### Persistent Storage

* [x] Persistent Volumes (PV)
* [x] Persistent Volume Claims (PVC)

### Stateful Workloads

* [x] StatefulSets Basics
* [x] Headless Services
* [x] volumeClaimTemplates

### Advanced Storage

* [x] Dynamic Provisioning
* [x] StorageClasses

---

## Week 2 Daily Breakdown

**W2D1** — Services + Basic Storage

**W2D2** — Persistent Volumes & Claims

**W2D3** — StatefulSets & Headless Services

**W2D4** — Volumes (emptyDir, hostPath)

**W2D5** — StatefulSet Storage (volumeClaimTemplates)

**W2D6** — StorageClasses & Dynamic Provisioning

**W2D7** — Ingress, CoreDNS & Service Discovery

---

### W2D1 — Services + Basic Storage

* ClusterIP
* NodePort
* Service selectors
* PV
* PVC
* Pod storage mounting

#### Files

* `service-clusterip.yaml`
* `service-nodeport.yaml`
* `pv.yaml`
* `pvc.yaml`
* `pod-storage.yaml`

**Status:** ✅ Complete

---

### W2D2 — Persistent Volumes & Claims

#### Topics

* Storage persistence
* Data verification
* PV lifecycle
* PVC lifecycle

#### Files

* `pv.yaml`
* `pvc.yaml`
* `pod.yaml`

**Status:** ✅ Complete

---

### W2D3 — StatefulSets Basics

#### Topics

* StatefulSets
* Stable Pod identity
* Ordered deployment
* Headless Services

#### Files

* `nginx-statefulset.yaml`
* `headless-service.yaml`

**Status:** ✅ Complete

---

### W2D4 — Kubernetes Volumes

#### Topics

* Volumes
* volumeMounts
* emptyDir
* hostPath

#### Files

* `emptydir-pod.yaml`
* `hostpath-pod.yaml`

**Status:** ✅ Complete

---

### W2D5 — StatefulSet Storage

#### Topics

* volumeClaimTemplates
* Per-Pod storage
* Stateful workload persistence

#### Files

* `statefulset-pvc.yaml`

**Status:** ✅ Complete

---

### W2D6 — StorageClasses & Dynamic Provisioning

#### Topics

* StorageClasses
* Dynamic provisioning
* Automatic PVC fulfillment

#### Files

* `storageclass.yaml`
* `pvc-dynamic.yaml`

**Status:** ✅ Complete

---

### W2D7 — Ingress, CoreDNS & Service Discovery

#### Topics

* Ingress resources
* Service Discovery
* CoreDNS
* DNS search domains
* Service resolution
* Gateway API awareness

#### Files

* `nginx-deployment.yaml`
* `nginx-service.yaml`
* `ingress.yaml`

**Status:** ✅ Complete

---

## Goal

### Understand

* How Pods communicate inside a cluster
* How Kubernetes Services expose applications
* How DNS resolution works
* How Service Discovery functions
* How storage persists beyond Pod lifecycles
* How Stateful applications manage data
* How Kubernetes dynamically provisions storage

### By the End of Week 2 You Should Be Able To

* Expose applications using Services
* Troubleshoot Service networking
* Resolve Services using DNS
* Understand CoreDNS behavior
* Mount temporary and persistent storage
* Create and use PVs and PVCs
* Deploy StatefulSets
* Configure StorageClasses
* Understand dynamic provisioning
* Understand the purpose of Ingress
* Understand the direction toward Gateway API

---

## Week 2 Completion

You have now completed the foundational Kubernetes networking and storage topics required before moving into scheduling, workload placement, and operational troubleshooting.

**Week 1 →** Kubernetes Fundamentals

**Week 2 →** Networking & Storage

**Week 3 →** Scheduling & Workloads


---

# Week 3 — Scheduling & Workloads

## Week 3 Progression

**W3D1 →** Scheduling Workloads

**W3D2 →** DaemonSets

**W3D3 →** Pod Affinity / Anti-Affinity + Resource Requests

**W3D4 →** Limits + Probes

**W3D5 →** Jobs

**W3D6 →** CronJobs + HPA basics

**W3D7 →** Troubleshooting Review

## Scheduling

* [x] Node scheduling basics
* [x] Taints and tolerations
* [x] Node affinity
* [x] Pod affinity / anti-affinity

## Workloads

* [x] DaemonSets
* [x] Resource requests and limits
* [x] Jobs
* [x] CronJobs
* [x] Horizontal Pod Autoscaler basics

## Goal

Understand how workloads are placed, controlled, and scaled.

---

## Week 3 Completion

You have now completed the scheduling and workload management topics required before moving into operational troubleshooting.

**Week 1 →** Kubernetes Fundamentals

**Week 2 →** Networking & Storage

**Week 3 →** Scheduling & Workloads

**Week 4 →** Troubleshooting

---

# Week 4 — Troubleshooting

## Real Operations

* W4D1 Pod Troubleshooting
* W4D2 Scheduling Troubleshooting
* W4D3 Networking Troubleshooting
* W4D4 Storage Troubleshooting
* W4D5 Cluster Component Troubleshooting
* W4D6 Mock CKA Scenarios
* W4D7 Week Review
* W4D8 Advanced Debugging

* [x] Logs
* [x] Describe
* [x] Events
* [x] CrashLoopBackOff
* [x] ImagePullBackOff
* [x] Pending Pods
* [x] Resource exhaustion
* [x] Debugging techniques 
* [x] kubectl debug
* [x] Ephemeral debug containers

### Storage Troubleshooting (W4D4)

* [x] PVC not found
* [x] PVC Pending / Unbound
* [x] PV/PVC binding failures
* [x] StorageClass mismatch
* [x] FailedMount events
* [x] Read-only volume issues
* [x] Wrong mountPath (silent failure)
* [x] PVC finalizer hang (delete pod before PVC/PV)
* [x] hostPath vs dynamic provisioning awareness

## Goal

Build a break/fix operational mindset.

---

# Milestone 1

By the end of Week 4 I should be able to:

* Deploy applications
* Expose applications with Services
* Troubleshoot Pods
* Troubleshoot networking
* Use storage effectively
* Understand scheduling decisions
* Diagnose common failures

---

# Week 5 — Platform Engineering

## Week Structure

| Day | Topic |
| --- | --- |
| W5D1 | Helm Fundamentals |
| W5D2 | RBAC & Service Accounts |
| W5D3 | Observability (Prometheus/Grafana concepts) |
| W5D4 | CI/CD into Kubernetes |
| W5D5 | GitOps Concepts |
| W5D6 | Gateway API |
| W5D7 | Integration Lab |

Week 5 begins the transition from Kubernetes user/operator to Platform Engineer thinking.

## Platform Layer

* [x] Helm
* [x] RBAC
* [x] Service Accounts
* [x] Gateway API (Platform Engineering Usage)
* [x] GitOps concepts
* [x] CI/CD into Kubernetes
* [x] Observability
  * [x] Logs
  * [x] Metrics
  * [x] Events
  * [x] kubectl top
* [x] Prometheus / Grafana basics

## Goal

Begin thinking like a platform engineer rather than only a workload operator.

---

# Week 6 — Security

## Security Foundations

* [x] RBAC deep dive
* [x] Secrets handling
* [x] Network Policies
* [x] Pod Security
* [x] Security Contexts
* [x] Admission Controllers (high level)
* [x] Image security concepts
* [x] External Secrets Operator (awareness)
* [x] Security Integration Lab

## Goal

Understand Kubernetes security boundaries and workload hardening basics by applying defense-in-depth using RBAC, Security Contexts, Network Policies, Secrets, and admission controls.

---

## Cluster Administration

* [ ] Install Kubernetes components (containerd, kubelet, kubeadm, kubectl)
* [ ] Bootstrap a control plane with kubeadm
* [ ] Join worker nodes
* [ ] Expand to a highly available control plane
* [ ] Node maintenance
* [ ] cordon
* [ ] drain
* [ ] uncordon
* [ ] Cluster upgrades
* [ ] Static Pods
* [ ] kubelet behavior
* [ ] Control Plane Components
* [ ] etcd concepts
* [ ] etcd backup and restore
* [ ] Certificate management
* [ ] Cluster troubleshooting

## Goal

Understand how to build, operate, maintain, and troubleshoot a Kubernetes cluster using kubeadm.

## Note

Unlike earlier weeks that use kind, this week focuses on real cluster administration using a kubeadm-based home lab.

Topics include:

* Installing Kubernetes components
* Bootstrapping a control plane
* Joining worker nodes
* Expanding to multiple control planes
* Node maintenance and upgrades
* etcd backup and restore
* Certificate renewal
* Troubleshooting cluster failures
* CKA-style administration scenarios

---

# Week 8 — Design & Review

## Architecture and Review

### HLD

* [ ] Components
* [ ] Traffic flow
* [ ] High availability
* [ ] Failure domains
* [ ] Security boundaries

### LLD

* [ ] YAML resource decisions
* [ ] Probes
* [ ] Autoscaling
* [ ] Affinity
* [ ] Network policies
* [ ] Implementation specifics

### Final Review

* [ ] YAML writing
* [ ] Troubleshooting review
* [ ] Workload debugging
* [ ] Networking review
* [ ] Storage review

## Goal

Consolidate operational understanding and improve architecture confidence.

---

# Milestone 2

By the end of Phase 1 I should be able to:

* Operate Kubernetes workloads confidently
* Understand platform engineering concepts
* Understand cluster operations concepts
* Discuss Kubernetes architecture at interview level
* Be ready to begin Advanced Kubernetes / CKA preparation

---

# Learning Arc

AWS / Infrastructure Engineer
→ Kubernetes User
→ Kubernetes Operator
→ Platform Engineer
→ Architecture-Aware Engineer
→ Future CKA Candidate

---

# Repo Structure

```text
weekX/
├── setup.md
├── notes.md
├── labs.md
├── commands.md
└── yaml/
```

---

# Cheat Sheets

* kubectl
* troubleshooting
* YAML examples
* networking flow
* debugging commands

---

## Next Phase

### Phase 2 – Advanced Kubernetes & CKA Preparation (6-10 weeks)

#### Platform Engineering

- Helm
- Argo CD
- GitOps
- cert-manager
- External Secrets Operator
- Prometheus & Grafana

  - Prometheus Operator
  - kube-prometheus-stack
  - ServiceMonitor
  - Alertmanager
  - Grafana dashboards
  - Loki
  - PromQL
  - Recording rules
  - Alert rules

#### Infrastructure Integration

- Terraform + Kubernetes
- EKS (optional)
- CI/CD into Kubernetes

#### Operations

- kubeadm administration
- etcd recovery
- cluster upgrades

Goal:

Operate and build Kubernetes platforms.

### Phase 3 — CKA Preparation (3-5 weeks)

#### Topics:

- timed labs
- speed drills
- imperative commands
- killer.sh
- mock exams
- exam strategy

Goal:

Pass the exam.

## Roadmap

Phase 1
Kubernetes Foundations & Operations
(8 weeks)
Weeks 1-6 = use kind
Week 7 = use kubeadm on separate machine, while ubuntu becomes worker
Week 8 = Use both kind and kubeadm

↓

Phase 2
Advanced Kubernetes & Platform Engineering
(3–6 months)

↓

TA-004 Terraform Associate
(optional around here)

↓

Phase 3
CKA Preparation
(6–12 weeks)

↓

CKA Exam

