# W4D7 Notes

---

# Troubleshooting Order

1. kubectl get
2. kubectl describe
3. kubectl get events
4. kubectl logs
5. kubectl exec

---

# Pod States

Pending
Running
Succeeded
Failed
CrashLoopBackOff
ImagePullBackOff

---

# Scheduling Problems

- nodeSelector
- taints
- affinity
- insufficient resources
- cordoned node

---

# Networking Problems

- wrong labels
- wrong selector
- wrong ports
- DNS failures
- NetworkPolicy

---

# Storage Problems

- missing PVC
- unbound PVC
- wrong StorageClass
- wrong mountPath
- readOnly volume

---

# Cluster Problems

- CoreDNS
- unhealthy node
- static pod
- cordoned node

---

# Essential Commands

```bash
kubectl get all
kubectl get events --sort-by=.metadata.creationTimestamp

kubectl describe pod POD
kubectl logs POD

kubectl exec -it POD -- sh

kubectl get endpoints

kubectl get pvc
kubectl get pv

kubectl top pod
kubectl top node
```

---

# CKA Mindset

Observe first.
Do not edit immediately.

Describe tells you:
- why scheduling failed
- why mounts failed
- why images failed

Events tell you:
- what happened
- when it happened

Logs tell you:
- what the container says

---

For each problem:

1. kubectl get
2. kubectl describe
3. kubectl get events
4. kubectl logs

Goal:

- Single issue: under 2 minutes.
- Mixed issue: under 5 minutes.

---

# Week 4 Complete

✓ Pod Troubleshooting
✓ Scheduling Troubleshooting
✓ Networking Troubleshooting
✓ Storage Troubleshooting
✓ Cluster Troubleshooting
✓ Mock Scenarios
✓ Review

Ready for Week 5.