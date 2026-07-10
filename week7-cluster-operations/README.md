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
- kubeconfig
- Admin credentials
- Static Pods
- Installing a CNI plugin
- Verifying cluster health
- kubectl cluster-info

---

## W7D3 — Join Worker Nodes

Learn:

- kubeadm join
- Bootstrap tokens
- Certificate discovery
- Node registration
- Node Ready status
- Scheduling workloads
- Removing and rejoining nodes

---

## W7D4 — High Availability Control Plane

Learn:

- Multi-control-plane architecture
- Control Plane Endpoint
- Certificate key
- Joining additional control plane nodes
- etcd topology
- Quorum
- Failure scenarios

---

## W7D5 — Cluster Maintenance

Learn:

- kubectl cordon
- kubectl drain
- kubectl uncordon
- Rolling node maintenance
- Node upgrades
- Package upgrades
- Cluster version verification

---

## W7D6 — Backup and Recovery

Learn:

- etcd snapshots
- Restoring etcd
- Cluster recovery concepts
- Static Pod manifests
- Disaster recovery workflow
- Backup best practices

---

## W7D7 — Certificates and Troubleshooting

Learn:

- Kubernetes certificates
- kubeadm certs
- Certificate expiration
- Certificate renewal
- Control plane troubleshooting
- Worker troubleshooting
- Common kubeadm issues

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