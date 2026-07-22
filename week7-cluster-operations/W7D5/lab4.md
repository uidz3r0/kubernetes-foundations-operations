# Lab 4 — Verify Stacked etcd

Each control plane should run:

```
etcd
```

Verify:

```
kubectl get pods -n kube-system | grep etcd
```

Expected:

```
etcd-luke
etcd-han
```

Inspect membership.

```bash
kubectl exec -n kube-system etcd-luke -- \
etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/peer.crt \
  --key=/etc/kubernetes/pki/etcd/peer.key \
  member list

kubectl exec -n kube-system etcd-luke -- \
etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt \
  --key=/etc/kubernetes/pki/etcd/healthcheck-client.key \
  member list  

ip addr show wlp2s0
ip addr show wlp5s0
```

Observe two members.