# Week 7 — Cluster Operations

This week transitions from running Kubernetes in kind to building and operating a real kubeadm cluster on your home lab.

By the end of this week you will be able to:

- Install Kubernetes components on Linux nodes
- Bootstrap a Kubernetes cluster with kubeadm
- Join worker and additional control plane nodes
- Perform node maintenance safely
- Upgrade a Kubernetes cluster
- Backup and restore etcd
- Understand certificate management
- Troubleshoot common cluster issues

---

## W7D1 — Install Kubernetes Components

Learn:

- containerd
- kubelet
- kubeadm
- kubectl
- Kubernetes package repositories
- SystemdCgroup configuration
- Version pinning
- Verifying installation

---

## W7D2 — Bootstrap the First Control Plane

Learn:

- kubeadm init
- Configure kubectl
- Verify static pods
- Verify control plane

---

## W7D3 — Install the CNI Plugin

Learn:

- Install Calico
- Understand what a CNI does
- Node becomes Ready
- CoreDNS becomes Running
- Verify cluster networking

---

## W7D4 — Join Worker Nodes

Learn:

- kubeadm join
- Bootstrap tokens
- Discovery token CA hash
- Node registration
- Workload scheduling
- Remove/rejoin worker nodes

---

## W7D5 — High Availability Control Plane - old

## W7D5 — High Availability Control Plane - Recreate

Learn:

- Multi-control-plane architecture
- kube-vip
- Virtual IP (VIP)
- Control Plane Endpoint
- Certificate key
- Joining additional control plane nodes
- etcd topology
- Quorum
- Failure scenarios

---

## W7D6 — Backup and Recovery

Learn:

- etcd snapshots
- Restoring etcd
- Static Pod manifests
- Disaster recovery workflow
- Backup best practices
- Cluster recovery verification

---

## W7D7 — Operations & Maintenance

Learn:

- HA verification 
- kube-vip failover verification
- cordon
- drain
- uncordon
- Rolling node maintenance
- Control plane maintenance
- Worker maintenance
- Cluster health verification

---

## W7D8 — Upgrades, Certificates & Troubleshooting

Learn:

- Kubernetes certificates
- kubeadm certs
- Certificate expiration
- Certificate renewal
- kubeadm upgrade plan
- kubeadm upgrade apply
- Control plane upgrades
- Worker node upgrades
- kubelet upgrades
- kubectl upgrades
- Version skew policy
- Cluster version verification
- Upgrade verification
- Rollback considerations
- Post-upgrade health checks

---

## Story

```text
Install
    ↓
Bootstrap
    ↓
Join Nodes
    ↓
Scale Control Plane
    ↓
Maintain
    ↓
Upgrade
    ↓
Backup
    ↓
Recover
    ↓
Troubleshoot
```

---

Overall Progression

```text
W7D1  Install Kubernetes
          │
          ▼
W7D2  Bootstrap Control Plane
          │
          ▼
W7D3  Install CNI
          │
          ▼
W7D4  Join Worker Nodes
          │
          ▼
W7D5  High Availability
          │
          ▼
W7D6  Backup & Recovery
          │
          ▼
W7D7  Operations & Maintenance
          │
          ▼
W7D8  Upgrades, Certificates & Troubleshooting
```

---

I would not add these to Phase 1 Week 7:

```text
Helm
Rancher
ArgoCD
GitOps
MetalLB
Longhorn
cert-manager
ExternalDNS
```

Those belong to Phase 2 (Platform Engineering). Keeping Week 7 focused on core cluster administration with kubeadm preserves a clean separation between becoming a Kubernetes administrator (Phase 1) and building a production platform (Phase 2).

---

## Visual Comparison

- The API server isn't started by `systemd`; it's started by the `kubelet`.

```text
                 Control Plane
               ------------------

systemd
--------
containerd
kubelet

kubelet watches
---------------
/etc/kubernetes/manifests

Static Pods
-----------
kube-apiserver
kube-controller-manager
kube-scheduler
etcd
kube-vip

DaemonSets
----------
kube-proxy
calico-node
```

```text
                    Worker
               ------------------

systemd
--------
containerd
kubelet

Static Pods
-----------
(none)

DaemonSets
----------
kube-proxy
calico-node

Workloads
---------
Deployments
StatefulSets
DaemonSets
Jobs
CronJobs
```