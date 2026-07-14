# W7D3 — Install the CNI Plugin

## Objective

Install the Kubernetes networking plugin (Container Network Interface).

Without a CNI plugin:

- Nodes remain NotReady
- Pods cannot communicate
- DNS does not work
- Services do not work

In production there are many CNI implementations:

- Calico
- Cilium
- Flannel
- Weave
- Canal

For this course we'll use **Calico** because:

- Production ready
- kubeadm compatible
- NetworkPolicy support
- Widely used

---

## Verify current state

```bash
kubectl get nodes
```

Expected:

```
NAME    STATUS
luke    NotReady
```

This is normal.

---

## Install Calico

```bash
sh scripts/install-calico.sh
```

---

## Wait

```bash
kubectl get pods -w
```

Wait until every pod becomes Running.

---

## Verify

```bash
sh scripts/check-calico.sh
```

Expected:

```
Node Ready

CoreDNS Running

Calico Running
```

---

## Expected cluster

```
kubectl get nodes

NAME
luke    Ready
```

The cluster is now functional.

---

At this point we have:

```text
                kube-apiserver
                       │
               kube-controller-manager
                       │
                 kube-scheduler
                       │
                    etcd
                       │
                    kubelet
                       │
                 containerd
                       │
          ┌────────────────────────┐
          │       Calico CNI       │
          └────────────────────────┘
                       │
              Pod Networking Ready
                       │
                 CoreDNS Running
                       │
                  Node = Ready
```