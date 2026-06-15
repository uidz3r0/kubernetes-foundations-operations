# W3D7 - Scheduling & Workloads Integration Lab

Instead of introducing new concepts, the goal is to combine:

- Scheduling (nodeSelector, taints/tolerations, affinity)
- Workloads (Deployments, Jobs, CronJobs, DaemonSets)
- Resources (requests/limits)
- Probes (liveness/readiness)
- HPA basics

This mirrors real CKA-style scenarios where multiple Kubernetes features interact.

## Objective

Combine scheduling, workload controllers, probes, resources,
and autoscaling into a realistic Kubernetes deployment.

This day acts as a review of everything learned in Week 3.

---

## Scenario

You operate a small web application platform.

Requirements:

- Web application runs only on worker nodes
- Logging agent runs on every node
- Backup job runs on demand
- Scheduled cleanup runs every few minutes
- Application has:
  - resource requests
  - resource limits
  - readiness probe
  - liveness probe
- Application can autoscale

---

## Components

### Deployment

Provides application pods.

Includes:

- requests
- limits
- readiness probe
- liveness probe

---

### Service

Exposes deployment internally.

---

### HPA

Scales deployment based on CPU.

---

### DaemonSet

Runs one pod per node.

Represents logging agents.

---

### Job

Runs backup task once.

---

### CronJob

Runs cleanup task repeatedly.

---

## Architecture

Node
 ├─ DaemonSet Pod
 ├─ App Pod
 └─ HPA monitors deployment

CronJob -> periodic cleanup

Job -> manual backup

---

## Review Commands

View scheduling:

kubectl get pods -o wide

View node labels:

kubectl get nodes --show-labels

View daemonsets:

kubectl get ds

View jobs:

kubectl get jobs

View cronjobs:

kubectl get cronjobs

View HPA:

kubectl get hpa

Describe workload:

kubectl describe deployment webapp

---

## Key Exam Reminder

The CKA rarely tests features individually.

More commonly:

- Deployment + resources
- Deployment + probes
- Deployment + scheduling
- Job + CronJob
- HPA + Deployment

Understand how these work together.

## This serves as a Week 3 capstone:

| Feature             | Week      |
| ------------------- | --------- |
| NodeSelector        | W3D1      |
| Scheduling concepts | W3D1-W3D3 |
| DaemonSets          | W3D2      |
| Resources           | W3D3      |
| Probes              | W3D4      |
| Jobs                | W3D5      |
| CronJobs            | W3D5-W3D6 |
| HPA                 | W3D6      |
