# Week 1 Labs

## Day 1 - Cluster Foundations

### Objective

Create and inspect a local Kubernetes cluster.

### Checklist

- [x] Create kind cluster
- [x] Inspect cluster info
- [x] List nodes
- [x] List namespaces
- [x] List system pods across all namespaces
- [x] Describe a system pod
- [x] Explain why system pods exist before deploying workloads

### Commands Used

```bash
kind create cluster --name week1
kind get clusters
kubectl cluster-info
kubectl get nodes
kubectl get namespaces
kubectl get pods -A
kubectl describe pod -n kube-system <pod-name>
kubectl config current-context
```

### Learning Outcome

Understand the difference between cluster setup, cluster inspection, and Kubernetes system workloads.

---

## Day 2 - First Application Pod

### Objective

Deploy and inspect nginx as a standalone Pod.

### Checklist

- [x] Create pod
- [x] Watch lifecycle
- [x] Inspect logs
- [x] Exec into container
- [x] Kill container process
- [x] Observe restart behavior
- [x] Delete pod

### Steps

```bash
kubectl run nginx --image=nginx
kubectl get pods -w
kubectl describe pod nginx
kubectl logs nginx
kubectl exec -it nginx -- sh
kubectl delete pod nginx
```

### Break/Fix

Delete the pod and observe that Kubernetes does not recreate it because it is a standalone Pod.

### Learning Outcome

Understand basic Pod lifecycle and the difference between a standalone Pod and a controller-managed workload.

---

## Day 3 - Deployments and ReplicaSets

### Objective

Deploy nginx using a Deployment and observe controller behavior.

### Checklist

- [x] Create Deployment
- [x] Inspect Deployment
- [x] Inspect ReplicaSet
- [x] Inspect Pods created by Deployment
- [x] Delete a Pod and observe self-healing
- [x] Scale Deployment up
- [x] Scale Deployment down
- [x] Update image version
- [x] Observe rolling update
- [x] View rollout history

### Learning Outcome

Understand desired state, self-healing, scaling, and rolling updates.

---

## Day 4 - Labels, Selectors, and Namespaces

### Objective

Learn how Kubernetes organizes and identifies resources.

### Checklist

- [x] Create Pods with labels
- [x] View labels
- [x] Filter Pods using selectors
- [x] Modify labels
- [x] Delete resources using selectors
- [x] Create a namespace
- [x] Run Pods inside namespace
- [x] View resources across namespaces

### Learning Outcome

Understand labels, selectors, and namespaces as Kubernetes grouping and isolation mechanisms.

---

## Day 5 - Services

### Objective

Learn how Kubernetes exposes Pods and gives them stable network access.

### Checklist

- [x] Create Pods with labels
- [x] Create a Service
- [x] View Service details
- [x] Test Service DNS
- [x] Understand ClusterIP
- [x] Scale Pods behind a Service
- [x] Observe load balancing
- [x] Delete Service resources

### Learning Outcome

Understand how Services provide stable access to Pods even when Pods change.

---

## Day 6 - ConfigMaps and Secrets

### Objective

Learn how Kubernetes injects configuration and sensitive data into Pods without hardcoding values into container images.

### Checklist

- [x] Create a ConfigMap
- [x] View ConfigMap contents
- [x] Create a Secret
- [x] View Secret metadata
- [x] Inject ConfigMap values as environment variables
- [x] Inject Secret values as environment variables
- [x] Mount ConfigMap as files inside a Pod
- [x] Verify configuration inside running Pods
- [x] Understand ConfigMap vs Secret usage
- [x] Delete Day 6 resources

### Learning Outcome

Understand how Kubernetes separates application configuration from container images using ConfigMaps and Secrets.

---

# W1D7 — Foundation Lab / Integration Day Checklist

## Environment Setup

- [x] Create namespace
- [x] Verify namespace exists

---

## ConfigMap

- [x] Create ConfigMap YAML
- [x] Apply ConfigMap
- [x] Verify ConfigMap
- [x] Inspect ConfigMap contents

---

## Secret

- [x] Generate base64 values
- [x] Create Secret YAML
- [x] Apply Secret
- [x] Verify Secret

---

## Deployment

- [x] Create Deployment YAML
- [x] Configure 2 replicas
- [x] Configure ConfigMap environment variables
- [x] Configure Secret environment variables
- [x] Apply Deployment
- [x] Verify Deployment
- [x] Verify ReplicaSet
- [x] Verify Pods

---

## Environment Variables

- [x] Exec into container
- [x] Verify APP variables
- [x] Verify DB variables

---

## Service

- [x] Create Service YAML
- [x] Apply Service
- [x] Verify Service
- [x] Verify Endpoints

---

## Connectivity Test

- [x] Launch temporary BusyBox pod
- [x] Test Service connectivity
- [x] Confirm nginx response

---

## Troubleshooting Labs

### Lab A — Wrong Selector

- [x] Break Service selector
- [x] Observe failed connectivity
- [x] Inspect Endpoints
- [x] Fix selector

### Lab B — Missing ConfigMap Key

- [x] Rename ConfigMap key
- [x] Restart Deployment
- [x] Observe pod failure
- [x] Inspect pod events
- [x] Fix ConfigMap key

### Lab C — Delete Pod

- [x] Delete one pod
- [x] Observe automatic pod recreation
- [x] Watch replacement pod appear

---

## Cleanup

- [x] Delete namespace
- [x] Confirm cleanup complete

---

## Knowledge Check

- [x] Understand Deployment → ReplicaSet → Pod relationship
- [x] Understand Service selectors
- [x] Understand ConfigMap usage
- [x] Understand Secret usage
- [x] Understand Namespace isolation
- [x] Understand Kubernetes self-healing
