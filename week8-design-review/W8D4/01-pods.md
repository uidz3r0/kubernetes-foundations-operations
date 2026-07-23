# Pods

## Symptoms

- Pod not running
- Pod restarting
- Pod stuck
- Pod missing

---

## Checklist

```
kubectl get pods

kubectl describe pod <pod>

kubectl logs <pod>

kubectl logs -p <pod>

kubectl exec -it <pod> -- sh
```

---

## Common Causes

- bad image
- application crash
- probe failures
- missing ConfigMap
- missing Secret
- resource limits
- node failure

---

## Questions

- Is the Pod Scheduled?
- Is the container Running?
- Is the application healthy?
- Are probes failing?