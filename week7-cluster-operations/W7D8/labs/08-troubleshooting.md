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

## Stale etcd Member

If you performed `kubeadm reset` on leia but did not remove it from the etcd cluster, it will remain as a stale member that can cause issues.

Remove the stale member:

```bash
# Member list
sudo etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/peer.crt \
  --key=/etc/kubernetes/pki/etcd/peer.key \
  member list


    # Here shows luke is still a member    
    Output:

    28d11f179153848, started, han, https://10.1.1.11:2380, https://10.1.1.11:2379, false
    7776008a92ec9519, started, padme, https://10.1.1.14:2380, https://10.1.1.14:2379, false
    a6a292fe93a0085d, started, luke, https://10.1.1.10:2380, https://10.1.1.10:2379, false


# Remove the stale member (luke):
sudo etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/peer.crt \
  --key=/etc/kubernetes/pki/etcd/peer.key \
  member remove a6a292fe93a0085d


# Cluster health check
sudo etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/peer.crt \
  --key=/etc/kubernetes/pki/etcd/peer.key \
  endpoint health --cluster

  Output:

     {"level":"warn","ts":"2026-07-26T19:08:04.528474+1000","logger":"client","caller":"v3@v3.6.5/retry_interceptor.go:65","msg":"retrying of unary invoker failed","target":"etcd-endpoints://0xc0002f85a0/10.1.1.14:2379","method":"/etcdserverpb.KV/Range","attempt":0,"error":"rpc error: code = DeadlineExceeded desc = latest balancer error: connection error: desc = \"transport: Error while dialing: dial tcp 10.1.1.14:2379: connect: connection refused\""}
     https://10.1.1.11:2379 is healthy: successfully committed proposal: took = 14.347273ms
     https://10.1.1.10:2379 is healthy: successfully committed proposal: took = 56.905557ms
     https://10.1.1.14:2379 is unhealthy: failed to commit proposal: context deadline exceeded
     Error: unhealthy cluster
```

---

Discussion

1. Why doesn't Kubernetes support a simple downgrade?
2. What should every production upgrade include before starting?

## Answers

- Kubernetes does not support a simple downgrade because cluster state and schema changes are often irreversible and downgrades can break compatibility.
- Every production upgrade should include health checks, an etcd backup, and a tested rollback procedure.

---

What do senior platform engineers use?

If I walked into a production incident where a control-plane join failed, my workflow would typically be:

```text
kubectl get nodes
        ↓
kubectl get pods -n kube-system
        ↓
kubectl logs etcd-*
kubectl logs -f pod/kube-apiserver-luke -n kube-system
        ↓
etcdctl endpoint health --cluster
        ↓
etcdctl member list
        ↓
etcdctl endpoint status --cluster -w table
``` 

- `etcdctl` is still the definitive diagnostic tool because it's talking directly to the distributed database.