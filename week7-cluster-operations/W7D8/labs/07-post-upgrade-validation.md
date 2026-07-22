# Lab 7 — Validation

Verify versions

```
kubectl get nodes
```

Verify workloads

```
kubectl get pods -A
```

Verify API

```
kubectl cluster-info
```

Verify CoreDNS

```
kubectl get pods -n kube-system
```

Verify kube-vip

```
kubectl get pods -n kube-system \
| grep vip
```

Run application

```
kubectl run nginx \
--image=nginx
```

Delete afterwards.

---

Questions

1. What are the first indicators of a failed upgrade?

## Answers

- First indicators are NotReady nodes, CrashLoopBackOff or Error pods, control plane pod failures, API failures, or version mismatches.