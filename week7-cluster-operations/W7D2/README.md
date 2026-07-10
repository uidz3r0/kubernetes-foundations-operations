# W7D2 — Bootstrap the First Control Plane

## Objective

Create the first Kubernetes Control Plane using kubeadm.

This lab initializes:

- Kubernetes API Server
- Controller Manager
- Scheduler
- etcd
- kubelet

The node becomes the first Control Plane.

---

## Environment

| Host | Role |
|------|------|
| luke | Control Plane #1 |

OS:

Rocky Linux 9

---

## Steps

1. Verify prerequisites
2. Create kubeadm configuration
3. Initialize the cluster
4. Configure kubectl
5. Verify system Pods

---

## Expected Output

```

kubectl get nodes

NAME STATUS ROLES AGE VERSION

luke NotReady control-plane

```

NotReady is expected because a CNI plugin has not yet been installed.

---

## Files

manifests/kubeadm-init.yaml

contains the kubeadm configuration.

---

## Scripts

init-control-plane.sh

Runs kubeadm init.

---

## Validation

kubectl get nodes

kubectl get pods -A

kubectl cluster-info

---

## Expected Flow

```text
Luke

verify-install.sh
        │
        ▼
init-control-plane.sh
        │
        ▼
kubeadm init
        │
        ▼
kubeconfig.sh
        │
        ▼
kubectl get nodes
        │
        ▼
NotReady
        │
        ▼
SUCCESS
```

---

## Learning Outcomes

By the end of W7D2, you should be able to:

* Explain what kubeadm init creates and configures.
* Describe the role of the Kubernetes control plane components (API Server, Scheduler, Controller Manager, and etcd).
* Understand how the kubelet manages control plane components as Static Pods.
* Locate the key configuration files under /etc/kubernetes/.
* Configure kubectl using the generated admin.conf.
* Verify the cluster with kubectl get nodes, kubectl get pods -A, and kubectl cluster-info.
* Recognize why the control plane reports NotReady before a CNI plugin is installed.

This keeps the scope focused on bootstrapping a single control plane, leaving networking, worker joins, and high availability for later days.