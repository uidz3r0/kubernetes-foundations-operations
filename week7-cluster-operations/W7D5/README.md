# W7D5 — Recreate High Availability Control Plane

## Goal

Convert the existing single-control-plane cluster into a kubeadm High Availability cluster using stacked etcd.

At the end of this lab you will understand:

- controlPlaneEndpoint
- HA kubeadm bootstrap
- Certificate sharing
- Stacked etcd
- Control plane join process
- etcd quorum
- Control plane resiliency

---

# Lab Environment

| Host | Role |
|------|------|
| luke.lab | Control Plane 1 |
| han.lab | Control Plane 2 |
| leia.lab | Worker |

---

## Prerequisites

Before creating a highly available control plane, a stable API endpoint must exist.

In production this endpoint is commonly provided by:

- Cloud Load Balancer
- HAProxy + Keepalived
- kube-vip

For this lab we will use **kube-vip**.

kube-vip provides a Virtual IP (VIP) that automatically moves between control-plane nodes if the active node fails.

Reserved VIP:

```
10.1.1.15
```

Hostname:

```
k8s-api.lab
```

The kubeadm controlPlaneEndpoint will be:

```
k8s-api.lab:6443
```

Clients and worker nodes always connect to this endpoint regardless of which control-plane node currently owns the VIP.

---

# Architecture

```
             +--------------------+
             | controlPlaneEndpoint|
             | 10.1.1.15:6443      |
             +---------+----------+
                       |
        +--------------+--------------+
        |                             |
+---------------+             +---------------+
| luke          |             | han           |
| API Server    |             | API Server    |
| Controller    |             | Controller    |
| Scheduler     |             | Scheduler     |
| etcd          |             | etcd          |
+---------------+             +---------------+

                |
             Worker
              leia
```

### Lab Summary

1. Create a stable `controlPlaneEndpoint` by adding `kube-vip`.
2. Reinitialize kubeadm using: `--control-plane-endpoint`, `--upload-certs`
3. Join `han` as a second control plane.
4. Verify `stacked etcd`.
5. Understand `etcd` quorum.
6. Simulate control plane failures.

### Standard Flow

```
reset-control-plane.sh
        ↓
install-kube-vip.sh
        ↓
init-ha-control-plane.sh
        ↓
kubeconfig.sh
        ↓
join-control-plane.sh
        ↓
join-worker.sh
```

---

# Labs

## Lab 0

```bash
/k8s-lab/scripts/cluster/reset-control-plane.sh

# Verify, should show empty
sudo crictl ps 

# Then see lab0.md to install `kube-vip`.
sudo ctr run...


```bash
# For control-plan init, install CNI, clear kubeconfig, join control-plane  
/k8s-lab/scripts/cluster/init-ha-control-plane.sh
/k8s-lab/scripts/networking/install-calico.sh
/k8s-lab/scripts/cluster/kubeconfig.sh (for control-plane)

# For 
```

---

## Lab 1

Create a stable controlPlaneEndpoint.

---

## Lab 2

Reinitialize kubeadm using:

```
--control-plane-endpoint
--upload-certs
```

---

## Lab 3

Join han as a second control plane.

```bash
/k8s-lab/scripts/cluster/reset-control-plane.sh

sudo kubeadm join k8s-api.lab:6443 --token nk6llp.f5vcln35obdcyjrs \
	--discovery-token-ca-cert-hash sha256:7951cb8946dbacfccb2659c7ad5662d567d2be84c3aeee8c8fc276399869768c \
	--control-plane --certificate-key ee57f9e6a8e17dd877b1f51967d82a0db2080b0f368c39018be01a8d96c4d9ad

```

---

## Lab 4

Verify stacked etcd.

---

## Lab 5

Understand etcd quorum.

---

## Lab 6

Simulate control plane failures.

---

## Notes for your home lab

One important point about your environment: using `/etc/hosts` to create `k8s-api.lab` is useful for learning the `controlPlaneEndpoint` concept, but it **does not provide true high availability** because the hostname still resolves to a single node (`luke`). If `luke` goes down, the endpoint becomes unreachable even though `han` is still healthy.

For a later lab (perhaps W7D7 or W8), it would be valuable to replace this with a real virtual IP using Keepalived (and optionally HAProxy) so the endpoint automatically moves between control-plane nodes. That demonstrates how production kubeadm HA clusters are typically built.

## Dynamic Duo: HAProxy and Keepalived 

This is for Internal traffic, this is what your worker nodes and `kubectl` use to interact with the cluster. Provides a highly available, load-balanced endpoint for the `Kubernetes API server` (control plane access).

- **HAProxy** - Traffic Distribution (Load Balancing)
  - distributes incoming API server requests across all healthy control plane nodes
  - Acts as a TCP load balancer in front of your multiple API servers. It receives traffic on a single port (e.g., `6443`) and uses an algorithm (like `roundrobin`) to forward each request to one of the backend `kube-apiserver` instances running on your control plane nodes. It also performs health checks to stop sending traffic to a failed node.

- **Keepalived** - High Availability & Failover
  - prevents the load balancer itself (HAProxy) from becoming a single point of failure.
  - Manages a `Virtual IP` (VIP) address that floats between the nodes running HAProxy. This VIP is what clients and worker nodes connect to. Using the VRRP protocol, Keepalived ensures that if the node hosting the VIP and HAProxy fails, the VIP automatically moves to a healthy backup node within a few seconds, keeping the API endpoint accessible.
  - Uses VRRP protocol via Keepalived 
  - see Keepalived vs Corosync/Pacemaker
    - Corosync - heartbeat to servers, check server "keepalive"
    - Pacemaker - VIP address, the "Brain"

### 🤔 A Quick Note on Alternatives

While `HAProxy+Keepalived` is the most common and battle-tested approach for self-managed clusters, there are other options. The official kubeadm documentation also references tools like `kube-vip`, which implements both VIP management and load balancing in a single service, often run as a static pod on the control plane nodes.

Think of it this way: `HAProxy+Keepalived` is the classic, battle-tested "two-piece" solution. `kube-vip` is the sleek, integrated "one-piece" solution built for the Kubernetes-native world. It's just that `kube-vip` doesn't perfectly replicate every capability of the two-tool combination.

In summary, for a resilient HA `kubeadm` cluster, you will be deploying both HAProxy and Keepalived together. `Keepalived` gives you the reliable, always-available IP address, and `HAProxy` gives you the smart, load-balancing traffic cop.

## For External Traffic

This is what external users use to access your applications.

`MetalLB` is a load-balancer implementation for bare-metal Kubernetes clusters that aren't running on a supported cloud provider like AWS, GCP, or Azure . In a cloud environment, creating a `LoadBalancer` type service automatically provisions an external IP through the cloud provider's API. On bare metal or on-premises clusters, those services would stay in a "pending" state forever because Kubernetes doesn't have a built-in way to assign external IPs.

---

### Order of labs:

- Reset existing nodes
- Install kube-vip (static Pod)
- Initialize the first HA control plane
- Configure kubectl
- Install the CNI
- Join the second control plane
- Join worker nodes
- Verify stacked etcd
- Explain quorum
- Simulate control-plane failure