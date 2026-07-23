# Pending Pods

Pending means the scheduler cannot place the Pod.

---

## Verify

```
kubectl describe pod
```

Read Events carefully.

---

## Common Causes

No nodes

Insufficient CPU

Insufficient Memory

Taints

Affinity

PVC Pending

---

## Commands

```
kubectl get nodes

kubectl describe node
```