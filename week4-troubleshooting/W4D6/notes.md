# W4D6 Notes

## Typical troubleshooting order:

1. kubectl get all
2. kubectl describe
3. kubectl logs
4. kubectl get events --sort-by=.metadata.creationTimestamp
5. kubectl exec
6. kubectl edit
7. kubectl apply

## Useful commands:

kubectl get pods -A
kubectl describe pod PODNAME
kubectl logs PODNAME
kubectl get events -A
kubectl get svc
kubectl get endpoints
kubectl get pvc,pv
kubectl top pod
kubectl top node

## Remember:

Pending:  

- nodeSelector
- taints
- resources
- PVC

CrashLoopBackOff:  

- logs
- command
- image

Service problems:  

- labels
- selectors
- ports

Storage:

- PVC
- mountPath
- StorageClass

Networking:

- Service
- Endpoints
- DNS

CKA:

Observe first.
Edit second.
Delete last.

---

## Optional Final Exam (Highly Recommended)

After finishing all six:

```bash
kubectl apply -f yaml/
date
```

Start a timer for **30 minutes**.

Your objective:

- All pods Running.
- All services have endpoints.
- No Pending pods.
- No CrashLoopBackOff.
- No ImagePullBackOff.

---

This W4D6 should feel much closer to an actual CKA troubleshooting section than the earlier isolated exercises because several scenarios require the exact sequence:

```bash
k get
k describe
k logs
k get events
k edit
k replace
```

which is exactly the troubleshooting muscle memory you want before Week 5 and eventually the mock exams.