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
kubectl exec -n kube-system etcd-luke -- etcdctl member list

ip addr show wlp2s0
ip addr show wlp5s0
```

Observe two members.