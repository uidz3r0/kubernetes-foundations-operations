# W8D5 — Capstone Review

## Objective

Bring together everything learned throughout the Kubernetes Foundations course by deploying and reviewing a complete application platform.

The goal is to explain **how** and **why** the platform was designed, not just demonstrate that it works.

---

# Scenario

You have been asked to build a small production-style Kubernetes platform.

Your platform should demonstrate:

- Application deployment
- Service networking
- Ingress routing
- Persistent storage
- Secrets
- Scheduling
- Health checks
- Resource management
- Security
- Observability readiness

Assume this is being presented during a technical interview.

---

# Architecture

```

                    Internet
                        │
                 DNS (lab.local)
                        │
                 Ingress Controller
                        │
          ┌─────────────┴─────────────┐
          │                           │
      frontend                   backend API
          │                           │
          └─────────────┬─────────────┘
                        │
                     PostgreSQL
                        │
             Persistent Volume Claim
                        │
                  Persistent Volume


```

---

# Step 1 — Namespace

Create a dedicated namespace.

```
kubectl create namespace demo
```

Verify

```
kubectl get ns
```

---

# Step 2 — Secrets

Create database credentials.

Example

```
kubectl create secret generic postgres-secret \
--from-literal=username=postgres \
--from-literal=password=password \
-n demo
```

Verify

```
kubectl get secrets -n demo
```

Explain

Secrets keep sensitive data outside container images and manifests.

---

# Step 3 — Storage

Create

- StorageClass
- PVC
- PV (if required)

Verify

```
kubectl get pvc,pv
```

Explain

Applications should never rely on container filesystem for persistent data.

Persistent Volumes survive Pod recreation.

---

# Step 4 — Deploy Database

Deploy PostgreSQL.

Requirements

- PVC mounted
- Secret used
- Resource requests
- Liveness probe
- Readiness probe

Verify

```
kubectl get pods
kubectl describe pod postgres
```

Explain

Readiness ensures traffic is only sent after the database is accepting connections.

Liveness restarts unhealthy containers.

---

# Step 5 — Deploy Backend

Deploy an API.

Requirements

- Deployment
- Service
- ConfigMap
- Secret
- Resource limits
- Rolling updates

Verify

```
kubectl rollout status deployment/backend
```

Explain

Deployment manages ReplicaSets and enables zero-downtime updates.

---

# Step 6 — Deploy Frontend

Deploy a web frontend.

Requirements

- Deployment
- Service
- Environment variables
- Resource requests

Verify

```
kubectl get deploy
kubectl get svc
```

---

# Step 7 — Networking

Create Services.

```
Frontend

ClusterIP

↓

Backend

ClusterIP

↓

Database

ClusterIP
```

Verify DNS

```
kubectl exec frontend-pod -- nslookup backend

kubectl exec frontend-pod -- curl backend
```

Explain

Applications communicate through Services rather than Pod IPs because Pods are ephemeral.

---

# Step 8 — Ingress

Expose the frontend.

Verify

```
kubectl get ingress
```

Test

```
curl http://app.lab.local
```

Explain

Ingress provides Layer 7 routing and centralises external access.

---

# Step 9 — Scheduling

Demonstrate scheduling concepts.

Show

```
nodeSelector

Affinity

Anti-affinity

Taints

Tolerations
```

Verify

```
kubectl describe pod
```

Explain

Scheduling controls workload placement for availability and performance.

---

# Step 10 — Security

Review

- ServiceAccount
- RBAC
- Security Context
- Non-root containers
- Read-only filesystem
- Capabilities dropped

Verify

```
kubectl describe pod
```

Explain

Containers should run with least privilege.

---

# Step 11 — Resource Management

Review

```
requests

limits
```

Explain

Requests determine scheduling.

Limits prevent resource starvation.

Verify

```
kubectl describe pod
```

---

# Step 12 — Health Checks

Demonstrate

```
Readiness Probe

Liveness Probe

Startup Probe
```

Explain differences.

| Probe | Purpose |
|----------|-------------|
| Startup | Initial startup |
| Readiness | Accept traffic |
| Liveness | Restart unhealthy container |

---

# Step 13 — Scaling

Scale the backend.

```
kubectl scale deployment backend --replicas=4
```

Verify

```
kubectl get pods
```

Explain

Deployments distribute replicas across available nodes where possible.

---

# Step 14 — Rolling Update

Update the image.

```
kubectl set image deployment/backend \
backend=myimage:v2
```

Watch rollout

```
kubectl rollout status deployment/backend
```

Rollback

```
kubectl rollout undo deployment/backend
```

Explain

Rolling updates minimise downtime.

---

# Step 15 — Validation Checklist

Verify everything.

```
kubectl get all -n demo

kubectl get ingress

kubectl get pvc

kubectl get events

kubectl top nodes

kubectl top pods
```

---

# Architecture Review

Walk through the platform.

## Control Plane

Responsible for:

- Scheduling
- API Server
- Controller Manager
- etcd
- Cluster state

High Availability

- kube-vip virtual IP
- Multiple control planes
- Stacked etcd quorum

---

## Worker Nodes

Responsible for:

- Running workloads
- kubelet
- containerd
- kube-proxy

---

## Networking

Calico provides

- Pod networking
- Routing
- Network Policies

Services provide

- Stable virtual IPs

Ingress provides

- HTTP routing

DNS resolves

```
backend.demo.svc.cluster.local
```

---

## Storage

Persistent Volumes

↓

Persistent Volume Claims

↓

Mounted into Pods

Data survives Pod recreation.

---

## Security

Platform includes

- Namespaces
- Secrets
- RBAC
- Service Accounts
- Security Contexts
- Least privilege

---

## Reliability

High Availability

- Multiple control planes
- ReplicaSets
- Deployments
- Rolling Updates
- Self-healing Pods

---

## Scalability

Applications scale horizontally.

```
Deployment

↓

ReplicaSet

↓

Pods
```

---

# Interview Walkthrough

Imagine presenting your platform.

Example

> "This cluster consists of three control plane nodes using kube-vip for a highly available API endpoint and one worker node for application workloads. Calico provides pod networking and network policies, while CoreDNS enables service discovery.

> Applications are deployed using Deployments with ReplicaSets for self-healing and rolling updates. Services provide stable networking between frontend, backend, and PostgreSQL components, while an Ingress controller exposes the application externally.

> Persistent data is stored through Persistent Volumes and Persistent Volume Claims to survive pod recreation. Secrets manage database credentials, and resource requests and limits ensure fair scheduling.

> Health is monitored using startup, readiness, and liveness probes. Security is enforced through RBAC, service accounts, and non-root containers. Overall, the platform is designed to be reliable, scalable, secure, and maintainable."

---

# Common Interview Questions

## Why use Deployments instead of Pods?

Pods are not self-healing.

Deployments provide:

- ReplicaSets
- Rolling updates
- Rollbacks
- Self-healing

---

## Why Services?

Pods change IP addresses.

Services provide stable networking.

---

## Why PVCs?

Containers are ephemeral.

Persistent storage survives Pod recreation.

---

## Why Readiness Probes?

Prevent traffic reaching applications before they are ready.

---

## Why Resource Requests?

Guarantee scheduling.

---

## Why Resource Limits?

Prevent noisy neighbours consuming cluster resources.

---

## Why Ingress?

Provides Layer 7 routing for multiple applications through a single entry point.

---

## Why kube-vip?

Provides a highly available Kubernetes API endpoint by presenting a single virtual IP that automatically fails over between control plane nodes.

---

## Why Calico?

Provides:

- Pod networking
- Network policies
- Efficient routing
- Scalable networking

---

# Self-Evaluation Checklist

- [ ] I can explain every Kubernetes object I created.
- [ ] I can justify every important manifest field.
- [ ] I can explain why Deployments are preferred over Pods.
- [ ] I understand Services, DNS, and Ingress.
- [ ] I understand storage architecture.
- [ ] I understand scheduling decisions.
- [ ] I understand security best practices.
- [ ] I understand rolling updates and rollbacks.
- [ ] I can troubleshoot common failures.
- [ ] I can confidently present my cluster in a technical interview.

---

# Outcome

By completing this capstone review, you should be able to present your Kubernetes platform end-to-end as though explaining a real production environment. You should be comfortable justifying your design decisions around reliability, scalability, security, networking, storage, and operations—demonstrating the practical understanding expected of a Platform Engineer or Kubernetes Administrator.
