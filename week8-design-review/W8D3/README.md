# W8D3 — Platform Review

## Objective

Review the Kubernetes platform as a whole and evaluate whether it follows production best practices.

The review covers:

- Nodes
- Namespaces
- Workloads
- Networking
- Storage
- RBAC
- Secrets
- ConfigMaps
- Monitoring readiness

---

## Deliverables

- Platform review checklist
- Findings
- Recommended improvements

---

## Commands Used

### Cluster

```bash
kubectl get nodes -o wide
kubectl top nodes
kubectl describe node <node>
```

### Namespaces

```bash
kubectl get ns
kubectl get all -A
```

### Workloads

```bash
kubectl get deploy,statefulset,daemonset -A
kubectl get pods -A
```

### Networking

```bash
kubectl get svc -A
kubectl get ingress -A
kubectl get networkpolicy -A
```

### Storage

```bash
kubectl get pv
kubectl get pvc -A
kubectl get storageclass
```

### RBAC

```bash
kubectl get roles -A
kubectl get rolebindings -A
kubectl get clusterroles
kubectl get clusterrolebindings
```

### Config

```bash
kubectl get secrets -A
kubectl get configmaps -A
```

### Monitoring

```bash
kubectl top pods -A
kubectl get --raw="/metrics"
```

---

## Expected Outcome

Understand the current platform state and identify improvements before production deployment.