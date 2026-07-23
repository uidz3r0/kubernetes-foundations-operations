# Services

## Symptoms

Application cannot be reached.

---

## Verify

```
kubectl get svc

kubectl describe svc

kubectl get endpoints
```

---

## Check

Does selector match?

```
kubectl get pods --show-labels
```

Does service have endpoints?

```
kubectl get endpoints
```

---

## Common Problems

- wrong selector
- wrong port
- wrong targetPort
- no pods
- pod labels changed