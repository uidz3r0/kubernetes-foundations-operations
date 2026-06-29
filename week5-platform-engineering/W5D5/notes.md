# W5D5 Notes — GitOps Concepts

## What is GitOps?

GitOps is an operational model where Git becomes the single source of truth for Kubernetes.

Instead of administrators running

```
kubectl apply
```

a GitOps controller continuously synchronizes the cluster with what exists in Git.

---

# Desired State vs Actual State

Desired State

```
Git Repository
replicas = 4
image = nginx:1.28
```

Actual State

```
Cluster
replicas = 2
image = nginx:1.27
```

The GitOps controller detects differences and reconciles them.

---

# Reconciliation Loop

```
Git

↓

Compare

↓

Detect Drift

↓

Apply Changes

↓

Cluster matches Git
```

This repeats continuously.

---

# Traditional CI/CD

```
Developer

↓

Git

↓

CI

↓

kubectl apply

↓

Cluster
```

Pipeline pushes changes into Kubernetes.

---

# GitOps

```
Developer

↓

Git

↓

GitOps Controller

↓

Cluster
```

The cluster pulls changes from Git.

---

# Why GitOps?

Benefits

- Declarative infrastructure
- Version controlled
- Easy rollback
- Full audit history
- Self-healing
- Less manual access to production clusters

---

# Drift

Configuration drift occurs when the live cluster differs from Git.

Example

Git

```
replicas: 4
```

Cluster

```
replicas: 1
```

GitOps detects this difference and restores the desired state.

---

# Rollback

Instead of

```
kubectl rollout undo
```

GitOps rollback is simply

```
git revert
git push
```

The controller reconciles automatically.

---

# Common GitOps Tools

- Argo CD
- Flux CD

Both continuously compare Git with the Kubernetes cluster.

---

# Repository Structure

Typical GitOps repository

```
apps/

environments/

clusters/

manifests/
```

Separate repositories may also be used for

- application code
- infrastructure
- Kubernetes manifests

---

# GitOps Workflow

```
Developer

↓

Commit

↓

Git Repository

↓

GitOps Controller

↓

Cluster Updated
```

---

# Best Practices

✔ Never edit production resources manually.

✔ Git is the source of truth.

✔ Everything is declarative.

✔ Pull-based deployment.

✔ Automatic reconciliation.

✔ Version control every Kubernetes manifest.

---

# Interview Questions

## What problem does GitOps solve?

It ensures Kubernetes clusters always match the desired configuration stored in Git while providing version control, auditing, rollback, and automated reconciliation.

---

## What is configuration drift?

Configuration drift occurs when the running cluster no longer matches the desired state defined in Git. Manually running `kubectl scale` to 1 while Git declares 4 is the textbook definition of configuration drift.

---

## What is reconciliation?

The continuous process of comparing the desired state with the current state and applying changes until they match.

---

## Why is GitOps considered more secure?

Clusters no longer require external CI systems to have direct administrative access. Instead, in-cluster controllers pull approved changes from Git. Ans also, because every change goes through a Git PR, you get review/approval gates and a complete audit trail of who changed what and when â security via process, not just access control.

---

## Traditional CI/CD vs GitOps

| Traditional CI/CD | GitOps |
|-------------------|---------|
| Push model | Pull model |
| Pipeline deploys | Controller deploys |
| kubectl in pipeline | Git is source of truth |
| Manual rollback | Git revert |
| Easier drift | Automatic reconciliation |

---

### Two flavors of reconciliation:

- Self-heal / drift detection â controller reverts manual cluster changes (what your Part 4 simulates)
- Auto-sync on Git change â controller applies new commits automatically

Argo CD lets you toggle these independently.