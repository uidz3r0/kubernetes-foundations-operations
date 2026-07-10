# W7D1/notes.md

# Notes

## containerd

The container runtime used by Kubernetes.

Responsibilities:

- Pull images
- Start containers
- Stop containers
- Manage container lifecycle

---

## kubelet

Runs on every Kubernetes node.

Responsibilities:

- Watches the API Server
- Starts Pods
- Reports node status
- Performs health checks

---

## kubeadm

Bootstraps Kubernetes clusters.

Used to:

- initialize a cluster
- join worker nodes
- join additional control planes
- upgrade clusters

---

## kubectl

The Kubernetes command-line client.

Used for:

- Deployments
- Services
- Pods
- Troubleshooting
- Administration

---

## Why SystemdCgroup?

Kubernetes expects both kubelet and containerd to use the same cgroup driver.

Using systemd improves stability and avoids startup issues.

---

## Why kubelet reports errors

The kubelet starts automatically after installation.

Since no cluster has been initialized yet, it continuously waits for configuration from kubeadm.

This is normal.

---

## Why lock containerd?

The Kubernetes project defines supported container runtime versions for each Kubernetes release.

Locking `containerd` keeps the runtime consistent while learning and prevents unexpected changes caused by routine operating system updates.

In production, containerd should be upgraded intentionally as part of a planned Kubernetes upgrade after verifying compatibility with the target Kubernetes version.