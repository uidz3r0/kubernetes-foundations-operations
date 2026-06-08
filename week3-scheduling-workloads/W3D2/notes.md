# W3D2 – DaemonSets

---

## Learning Objectives

By the end of this lesson you will understand:

- What a DaemonSet is
- When to use a DaemonSet
- How Kubernetes schedules DaemonSet Pods
- DaemonSets with nodeSelectors
- DaemonSets with taints and tolerations
- Real-world DaemonSet examples

---

## What is a DaemonSet?

A DaemonSet ensures a Pod runs on every matching node.

Deployment:

1 Pod → many replicas

DaemonSet:

1 Pod → every node

Example:

Node1 -> Pod
Node2 -> Pod
Node3 -> Pod

If a new node joins:

Node4 -> Pod automatically created

---

## Why DaemonSets Exist

Some workloads must run on every node.

Examples:

- Log collection
- Monitoring agents
- Security scanners
- Network plugins

Without a DaemonSet you would need to manually create Pods.

---

## DaemonSet Architecture

Example cluster:

Control Plane
Worker1
Worker2

DaemonSet:

fluent-bit

Result:

Control Plane -> fluent-bit
Worker1 -> fluent-bit
Worker2 -> fluent-bit

One Pod per node.

---

## DaemonSet vs Deployment

Deployment:

Replicas: 3

Scheduler decides placement.

Possible:

Worker1 -> 2 Pods
Worker2 -> 1 Pod

DaemonSet:

Exactly one Pod per matching node.

Worker1 -> 1 Pod
Worker2 -> 1 Pod

---

## Creating a DaemonSet

Basic structure:

apiVersion: apps/v1
kind: DaemonSet

spec:
  selector:
  template:

Very similar to a Deployment.

---

## Viewing DaemonSets

List DaemonSets:

kubectl get ds

Detailed information:

kubectl describe ds demo

Pods:

kubectl get pods -o wide

---

## DaemonSets and New Nodes

When a new node joins:

DaemonSet controller automatically creates a Pod.

No manual scaling required.

---

## DaemonSets with Node Selectors

You may only want specific nodes.

Example label:

storage=true

DaemonSet only runs there.

spec:
  template:
    spec:
      nodeSelector:
        storage: "true"

---

## DaemonSets with Tolerations

If a node is tainted:

dedicated=logging:NoSchedule

DaemonSet Pods need a matching toleration.

Otherwise they cannot run there.

---

## Real Production Examples

Fluent Bit:

Collect logs from every node.

Prometheus Node Exporter:

Collect node metrics.

Calico:

Provides cluster networking.

Longhorn:

Storage services on each node.

Most clusters run several DaemonSets.

---

## Key Commands

View DaemonSets:

kubectl get ds

Describe:

kubectl describe ds ds-demo

Delete:

kubectl delete ds ds-demo

Watch Pods:

kubectl get pods -o wide -w

---

## Exam Notes

Know:

- One Pod per node
- DaemonSet controller behavior
- Difference between Deployment and DaemonSet
- nodeSelector usage
- toleration usage
- common production examples

Before moving on th W3D3 say this out loud:

```
“DaemonSets run one Pod per eligible node. Node selectors reduce which nodes are eligible. Taints block Pods unless the Pod has a matching toleration.”
```

Need N replicas?
→ Deployment

Need stable identity + storage?
→ StatefulSet

Need one Pod on every node?
→ DaemonSet
