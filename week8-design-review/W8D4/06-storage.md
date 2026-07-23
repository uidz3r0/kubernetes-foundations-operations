# Storage

## Symptoms

PVC Pending

Volume Mount Failed

Read-only filesystem

---

## Verify

```
kubectl get pvc

kubectl get pv

kubectl describe pvc
```

---

## Check

StorageClass

Capacity

AccessMode

Binding

---

## Common Problems

- StorageClass missing
- no provisioner
- capacity mismatch
- access mode mismatch