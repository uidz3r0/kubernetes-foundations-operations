# Stacked etcd

kubeadm uses stacked etcd by default.

Each control plane runs:

- kube-apiserver
- kube-controller-manager
- kube-scheduler
- local etcd

The etcd members replicate between themselves.

Pros

- Simple
- Default kubeadm deployment

Cons

- Control plane and etcd share the same node
