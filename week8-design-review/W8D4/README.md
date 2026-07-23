# W8D4 — Troubleshooting Review

## Goal

Develop a systematic troubleshooting process for Kubernetes.

By the end of this lab you should be comfortable identifying failures without relying on documentation.

---

## Topics

- Pods
- Services
- DNS
- Ingress
- Scheduling
- Storage
- CrashLoopBackOff
- ImagePullBackOff
- Pending Pods
- Networking

---

## General Troubleshooting Workflow

Never guess.

> Always start from the outside and work inward.

```
User
 ↓
Ingress
 ↓
Service
 ↓
Endpoints
 ↓
Pods
 ↓
Containers
 ↓
Application
```

> For cluster problems:

```
Node
 ↓
Kubelet
 ↓
Container Runtime
 ↓
CNI
 ↓
Storage
 ↓
Control Plane
```

---

## Commands You Should Know

```
kubectl get
kubectl describe
kubectl logs
kubectl exec
kubectl top
kubectl events
kubectl get endpoints
kubectl get endpointslices
kubectl get ingress
kubectl get pvc
kubectl get pv
kubectl get nodes
kubectl rollout status
kubectl rollout undo
```

---

## Deliverable

Work through every troubleshooting scenario without looking at previous notes.

---

## End-of-day self-check

Before moving to W8D5, you should be able to troubleshoot these scenarios from memory within a few minutes each:

- ✅ Pod stuck in CrashLoopBackOff
- ✅ Pod stuck in ImagePullBackOff
- ✅ Pod remains Pending
- ✅ Service has no endpoints
- ✅ DNS lookup fails between Pods
- ✅ Ingress returns 404 or 503
- ✅ PVC remains Pending
- ✅ Pod cannot communicate with another Pod or Service
- ✅ Pod scheduled to the wrong node due to affinity, taints, or selectors
- ✅ CNI or networking issues preventing cluster communication

This aligns well with CKA troubleshooting tasks while also reflecting common production incidents you'll encounter as a Platform Engineer.