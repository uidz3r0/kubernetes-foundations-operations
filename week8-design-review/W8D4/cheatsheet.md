# Troubleshooting Cheatsheet

## Pod

```
kubectl describe pod
kubectl logs
kubectl logs -p
kubectl exec
```

---

## Service

```
kubectl get svc
kubectl describe svc
kubectl get endpoints
```

---

## DNS

```
nslookup
dig
```

---

## Ingress

```
kubectl get ingress
kubectl describe ingress
```

---

## Storage

```
kubectl get pvc
kubectl get pv
kubectl describe pvc
```

---

## Scheduling

```
kubectl describe pod
kubectl describe node
kubectl top nodes
```

---

## Networking

```
kubectl get pods -o wide
kubectl exec
kubectl get endpoints
```

---

## Golden Rule

Always follow the request path.

```
Ingress
 ↓
Service
 ↓
Endpoints
 ↓
Pod
 ↓
Container
 ↓
Logs
```

Never jump directly to application debugging.

Verify one layer at a time.