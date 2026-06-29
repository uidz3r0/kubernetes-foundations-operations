# W5D5 Lab — GitOps Concepts

## Objective

Understand how GitOps works and how Kubernetes continuously reconciles the cluster with the desired state stored in Git.

---

# Part 1 — Deploy an application

```bash
kubectl apply -f yaml/app-deployment.yaml
kubectl apply -f yaml/app-service.yaml
```

Verify.

```bash
kubectl get pods
kubectl get deployment
```

---

# Part 2 — Observe current state

Check replicas.

```bash
kubectl get deploy gitops-demo
```

Expected

```
2 replicas
```

---

# Part 3 — Simulate a Git commit

Pretend someone committed this change.

```
updated-deployment.yaml
```

Instead of editing the cluster directly, apply the updated manifest.

```bash
kubectl apply -f yaml/updated-deployment.yaml
```

Observe rollout.

```bash
kubectl rollout status deployment/gitops-demo
```

Verify.

```bash
kubectl get deploy
```

Expected

```
Replicas: 4
Image: nginx:1.28
```

---

# Part 4 — Drift example

Scale manually.

```bash
kubectl scale deployment gitops-demo --replicas=1
```

Verify.

```bash
kubectl get deploy
```

Current state

```
1 replica
```

Desired state (Git)

```
4 replicas
```

GitOps tools detect this drift.

Since we're not using Argo CD yet, manually reconcile.

```bash
kubectl apply -f yaml/updated-deployment.yaml
```

Verify replicas return to 4.

---

# Part 5 — Simulating GitOps reconciliation

Traditional workflow

```
Developer
      │
      ▼
CI Pipeline
      │
      ▼
kubectl apply
      │
      ▼
Cluster
```

GitOps workflow

```
Developer
      │
      ▼
Git Repository
      │
      ▼
GitOps Controller
      │
      ▼
Cluster
```

---

# Challenge

Without editing the live cluster directly,

Change

- replicas = 5
- nginx image = latest stable version

Apply only through YAML.

Observe rollout.

---

# Cleanup

```bash
kubectl delete deployment gitops-demo
kubectl delete service gitops-demo
```
