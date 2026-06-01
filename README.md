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
* Architecture awareness

Goal:

Become comfortable operating and reasoning about Kubernetes workloads and clusters in real-world scenarios.

This phase is NOT intended to be a pure CKA cram course.

Instead, it builds the operational foundation that makes future CKA preparation significantly easier.

---

## Phase 2 — Advanced Kubernetes / CKA Preparation

Estimated later duration: ~6–12+ weeks

Future focus areas:

* Timed troubleshooting
* kubeadm administration
* etcd recovery
* Cluster upgrades
* Speed and efficiency
* killer.sh-style scenarios
* Exam strategy and repetition

Goal:

Transition from operational familiarity into exam-level speed and confidence.

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

# Week 1 — Foundations

You are here.

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
* [ ] LoadBalancer
* [ ] Ingress

### DNS

* [ ] CoreDNS

---

## Storage

### Basic Volumes

* [x] Volumes
* [x] Volume types
* [x] emptyDir
* [X] hostPath
* [x] volumeMounts

### Persistent Storage

* [x] Persistent Volumes (PV)
* [x] Persistent Volume Claims (PVC)

### Stateful Workloads

* [x] StatefulSets Basics
* [ ] volumeClaimTemplates (StatefulSet Storage)

### Advanced Storage

* [ ] Dynamic Provisioning
* [ ] StorageClasses

---

## Week 2 Daily Breakdown

```
W2D1 PV / PVC
W2D2 Storage Concepts
W2D3 StatefulSets
W2D4 Volumes
W2D5 StatefulSet Storage
W2D6 StorageClasses
W2D7 Network Exposure + DNS
```

### W2D1 — Persistent Volumes & Persistent Volume Claims

**Topics**

* Persistent Volumes (PV)
* Persistent Volume Claims (PVC)
* Pod storage mounting

**Files**

* `pv.yaml`
* `pvc.yaml`
* `pod-storage.yaml`

**Status:** ✅ Complete

---

### W2D2 — PV/PVC Practice

**Topics**

* Storage persistence
* Data verification
* PV/PVC lifecycle

**Files**

* `pv.yaml`
* `pvc.yaml`
* `pod.yaml`

**Status:** ✅ Complete

---

### W2D3 — StatefulSets Basics

**Topics**

* StatefulSets
* Stable Pod identity
* Headless Services

**Files**

* `nginx-statefulset.yaml`
* `headless-service.yaml`

**Status:** ✅ Complete

---

### W2D4 — Kubernetes Volumes

**Topics**

* Volumes
* volumeMounts
* emptyDir
* hostPath

**Files**

* `emptydir-pod.yaml`
* `hostpath-pod.yaml`

**Status:** ✅ Planned

---

### W2D5 — StatefulSet Storage

**Topics**

* volumeClaimTemplates
* Per-Pod persistent storage
* StatefulSet persistence

**Files**

* `statefulset-pvc.yaml`

**Status:** ⏳ Planned

---

## Goal

### Understand

* How Pods communicate inside a cluster
* How Kubernetes Services expose applications
* How DNS resolution works inside Kubernetes
* How storage persists beyond Pod lifecycles
* How Stateful applications manage persistent data

### By the End of Week 2 You Should Be Able To

* Expose applications using Services
* Troubleshoot Service networking
* Mount temporary and persistent storage
* Create and use PVs and PVCs
* Deploy StatefulSets with persistent storage
* Understand the foundation of StorageClasses and dynamic provisioning

---

# Week 3 — Scheduling & Workloads

## Scheduling

* [ ] Node scheduling basics
* [ ] Taints and tolerations
* [ ] Node affinity
* [ ] Pod affinity / anti-affinity

## Workloads

* [ ] Resource requests and limits
* [ ] Jobs
* [ ] CronJobs
* [ ] Horizontal Pod Autoscaler basics

## Goal

Understand how workloads are placed, controlled, and scaled.

---

# Week 4 — Troubleshooting

## Real Operations

* [ ] Logs
* [ ] Describe
* [ ] Events
* [ ] CrashLoopBackOff
* [ ] ImagePullBackOff
* [ ] Pending Pods
* [ ] Resource exhaustion
* [ ] Debugging techniques

## Goal

Build a break/fix operational mindset.

---

# Week 5 — Platform Engineering

## Platform Layer

* [ ] Helm
* [ ] RBAC
* [ ] Service Accounts
* [ ] GitOps concepts
* [ ] CI/CD into Kubernetes
* [ ] Prometheus / Grafana basics
* [ ] Observability

## Goal

Begin thinking like a platform engineer rather than only a workload operator.

---

# Week 6 — Security

## Security Foundations

* [ ] RBAC deep dive
* [ ] Secrets handling
* [ ] Network Policies
* [ ] Pod Security
* [ ] Security Contexts
* [ ] Admission Controllers (high level)
* [ ] Image security concepts

## Goal

Understand Kubernetes security boundaries and workload hardening basics.

---

# Week 7 — Cluster Operations

## Cluster Administration

* [ ] Node maintenance
* [ ] cordon
* [ ] drain
* [ ] uncordon
* [ ] Static Pods
* [ ] kubeadm concepts
* [ ] etcd concepts
* [ ] Certificate management
* [ ] kubelet behavior

## Goal

Understand cluster internals and administrative operations.

## Note

kind abstracts some cluster bootstrap and administration internals.

Later practice may use:

* kubeadm on VMs
* cloud sandbox environments
* killer.sh-style labs

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
