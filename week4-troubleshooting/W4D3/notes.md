# W4D3 Notes

## Objectives

Learn how to troubleshoot:

- Service selector mismatches
- Wrong targetPort values
- DNS resolution failures
- NetworkPolicy blocking traffic
- Application listening on wrong port

Tools to master:

```bash 
kubectl get
kubectl describe
kubectl logs
kubectl exec
kubectl get endpoints
kubectl get svc
kubectl get networkpolicy
```

---

## Networking Troubleshooting Flow

Application unreachable:

1. Pod running?

```bash
kubectl get pods
```

2. Service exists?

```bash
kubectl get svc
```

3. Endpoints populated?

```bash
kubectl get endpoints
```

If:

```text
ENDPOINTS <none>
```

Check selectors.

4. Service ports correct?

```bash
kubectl describe svc
```

Check:

- port
- targetPort

5. DNS working?

```bash
kubectl exec -it POD -- nslookup kubernetes.default
```

6. NetworkPolicy blocking?

```bash
kubectl get networkpolicy
```

---

## Common Commands

### Service

```bash
kubectl get svc
kubectl describe svc NAME
```

### Endpoints

```bash
kubectl get endpoints
```

### DNS

```bash
kubectl exec -it POD -- nslookup kubernetes.default
```

### Network Policies

```bash
kubectl get networkpolicy
kubectl describe networkpolicy
```

---

## CKA Pattern

Service not working:

```text
Pod
 ↓
Service
 ↓
Endpoints
 ↓
DNS
 ↓
NetworkPolicy
```

Always check:

1. Labels
2. Selectors
3. Endpoints
4. Ports
5. DNS
6. Policies

---

W4D3 Outcome

By the end of today you should be comfortable diagnosing:

- Service has no endpoints
- Service points to wrong port
- DNS failures
- NetworkPolicy blocks
- App listening on unexpected port
