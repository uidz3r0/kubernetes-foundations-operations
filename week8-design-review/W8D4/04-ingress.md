# Ingress

## Symptoms

404

503

Cannot connect

---

## Verify

```
kubectl get ingress

kubectl describe ingress
```

---

## Check

Ingress Controller running?

```
kubectl get pods -n ingress-nginx
```

Backend Service exists?

```
kubectl get svc
```

Service has endpoints?

```
kubectl get endpoints
```

---

## Common Problems

- wrong host
- wrong path
- backend service missing
- ingress class mismatch