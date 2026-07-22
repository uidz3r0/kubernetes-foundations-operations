# Lab 8 — Troubleshooting & Rollback

## Common Issues

### kubelet won't start

```
systemctl status kubelet
journalctl -u kubelet
```

---

### API unavailable

Check

```
crictl ps

kubectl get pods -A
```

---

### Certificate expired

```
kubeadm certs check-expiration
```

Renew

```
kubeadm certs renew all
```

---

### Upgrade interrupted

Check

```
kubeadm upgrade plan
```

Resume

```
kubeadm upgrade apply
```

---

### Node NotReady

Inspect

```
kubectl describe node
```

---

### Recovery

Restore etcd snapshot from your backup.

Restart kubelet.

Verify static pods in `/etc/kubernetes/manifests` are present and valid.

If the API server does not come back, inspect the kubelet logs and the static pod manifest files for syntax or path issues.

---

Discussion

1. Why doesn't Kubernetes support a simple downgrade?
2. What should every production upgrade include before starting?

## Answers

- Kubernetes does not support a simple downgrade because cluster state and schema changes are often irreversible and downgrades can break compatibility.
- Every production upgrade should include health checks, an etcd backup, and a tested rollback procedure.
