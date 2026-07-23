# Scheduling

## Symptoms

Pod remains Pending.

---

## Verify

```
kubectl describe pod
```

Look for:

```
Events:
```

---

## Common Causes

Insufficient CPU

Insufficient Memory

NodeSelector mismatch

Affinity mismatch

Taints

No available nodes

---

## Commands

```
kubectl get nodes

kubectl describe node

kubectl top nodes
```