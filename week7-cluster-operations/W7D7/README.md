# Week 7 Day 7 – Cluster Maintenance

## Objectives

Learn how to safely maintain a production Kubernetes cluster.

Topics:

- Verify HA cluster health
- Verify kube-vip failover
- Cordon nodes
- Drain nodes
- Uncordon nodes
- Worker maintenance
- Control Plane maintenance
- Rolling maintenance
- Cluster health verification

---

## Lab Topology

| Host | Role |
|------|------|
| luke | Control Plane |
| han | Control Plane |
| leia | Worker |

VIP

```
10.1.1.15
```

---

# Step 1

Verify cluster

```bash
./scripts/maintenance/cluster-health.sh
```

---

# Step 2

Verify kube-vip

```bash
./scripts/maintenance/verify-kubevip.sh
```

Shutdown the active kube-vip node in `luke`.

Verify that the VIP moves automatically.

Needed to run below in han (since we forgot to add it to han):

```bash
mkdir -p ~/.kube
sudo cp /etc/kubernetes/admin.conf ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
```

Why kube-vip in `han` doesn't take over after `luke` power was off?

```text
# sequence:

luke dies
    ↓
kube-apiserver on han crashes
    ↓
API unavailable
    ↓
Leader election cannot continue
    ↓
VIP never moves
```

With only two members, if one node disappears, you have:

```text
Remaining members = 1
Required quorum   = 2
```

**No quorum**.

When etcd loses quorum:

- API server cannot read/write Kubernetes state.
- API server starts returning HTTP 500s.
- The kube-apiserver liveness probe fails.
- kubelet restarts the API server.
- kube-vip cannot acquire or renew the Lease because the API is unavailable.

A 2-control-plane stacked-etcd cluster is not highly available from an etcd consensus perspective.

It provides `redundancy`, but not `fault tolerance` for the loss of a control-plane node.

To tolerate one control-plane failure with stacked etcd, you need `3 control-plane` nodes:

```text
luke
han
padme
```

With three etcd members:

- Total members = 3
- Quorum = 2
- Lose one node → 2 remain → quorum maintained → API stays up → kube-vip can fail over.

Everything cascades from the loss of etcd quorum.

With stacked etcd

| Control planes / etcd members | Quorum | Can lose one node? |
| ----------------------------: | -----: | :----------------: |
|                             1 |      1 |        ❌ No       |
|                             2 |      2 |        ❌ No       |
|                             3 |      2 |        ✅ Yes      |
|                             5 |      3 |        ✅ Yes      |

> Lab Observation: In a two-control-plane cluster using stacked etcd, powering off one control-plane node causes etcd to lose quorum (`etcdserver: no leader`). As a result, the API server becomes unavailable and kube-vip cannot complete failover. This demonstrates why production HA clusters typically use three control-plane nodes with stacked etcd (or an external etcd cluster).

## Once padme is added

When you add your planned third control plane:

```text
luke
han
padme
```

you'll have:

```text
3 etcd members
Quorum = 2
```

Now if luke is powered off:

```text
han
padme
```

still form a quorum, so:

```bash
✅ etcd elects a new leader.
✅ kube-apiserver stays healthy.
✅ kube-vip can acquire the Lease and move the VIP.
✅ `kubectl` continues working through `https://k8s-api.lab:6443`.
```

---

# Step 3

Deploy workload

```bash
kubectl apply -f manifests/apps/nginx-demo.yaml
```

Verify

```bash
kubectl get pods -o wide
```

---

# Step 4

Worker Maintenance

```bash
./scripts/maintenance/worker-maintenance.sh leia
```

Observe:

- node cordoned
- pods evicted
- pods recreated
- node returned

---

# Step 5

Control Plane Maintenance

```bash
./scripts/maintenance/control-plane-maintenance.sh han
```

Observe

- API still reachable
- etcd quorum maintained
- workloads continue running

### Output:

```bash
$ kubectl events -w    
    0s     Normal    NodeNotSchedulable        Node/han     Node han status is now: NodeNotSchedulable
    0s     Normal    NodeSchedulable           Node/han     Node han status is now: NodeSchedulable


$ kubectl get nodes 
    NAME   STATUS                     ROLES           AGE   VERSION
    han    Ready,SchedulingDisabled   control-plane   27h   v1.34.9
    leia   Ready                      <none>          27h   v1.34.9
    luke   Ready                      control-plane   27h   v1.34.9

$ kubectl uncordon han    
    node/han uncordoned
```

---

# Step 6

Rolling Maintenance

```bash
./scripts/rolling-maintenance.sh
```

This performs maintenance one node at a time.

Never remove more than one control plane simultaneously.

---

# Expected Outcome

You should understand how production maintenance is performed without downtime.

---

# Worker Node Maintenance

Worker node maintenance happens regularly, often without any application downtime if workloads are designed correctly.

| Reason                         | Example                                                               |
| ------------------------------ | --------------------------------------------------------------------- |
| **Operating System updates**   | Applying Rocky Linux or Ubuntu security patches.                      |
| **Kernel updates**             | Installing a new kernel that requires a reboot.                       |
| **Hardware maintenance**       | Replacing RAM, disks, NICs, or power supplies.                        |
| **Firmware/BIOS upgrades**     | Updating server firmware or BIOS.                                     |
| **Container runtime upgrades** | Upgrading `containerd` or another CRI.                                |
| **Kubelet upgrades**           | Updating the kubelet version.                                         |
| **Storage maintenance**        | Replacing or expanding local disks.                                   |
| **Network maintenance**        | Replacing switches, moving cables, changing VLANs, NIC configuration. |
| **Node troubleshooting**       | High CPU, memory leaks, disk corruption, filesystem checks.           |
| **Node replacement**           | Draining an old node before permanently removing it.                  |
| **Cloud provider maintenance** | Planned maintenance or retirement of cloud instances.                 |


Typical maintenance workflow

The standard process is:

```
Applications Running
        │
        ▼
kubectl cordon
        │
        ▼
kubectl drain
        │
        ▼
Perform maintenance
        │
        ▼
Reboot (if required)
        │
        ▼
Verify node health
        │
        ▼
kubectl uncordon
        │
        ▼
Scheduler places new Pods
```

Real-world example

Suppose your worker node leia has a kernel update:

```bash
sudo dnf update kernel
```

The maintenance might look like

```bash
kubectl cordon leia
kubectl drain leia --ignore-daemonsets --delete-emptydir-data

sudo dnf update -y
sudo reboot

# After reboot
kubectl get nodes

kubectl uncordon leia
```

Users should not notice anything if:

- workloads have multiple replicas,
- Pods can be rescheduled elsewhere, and
- there is enough cluster capacity.

## In cloud environments

Cloud-managed Kubernetes services do this frequently. For example:

- AWS EKS – rolling updates of managed node groups.
- Azure AKS – node image upgrades.
- Google GKE – automatic node maintenance windows.

Under the hood, these services also cordon, drain, update, reboot or replace nodes, then uncordon them.

## How often?

Security patches might be **monthly**, emergency security fixes whenever needed, Kubernetes and container runtime upgrades every few months, and hardware maintenance only occasionally. In cloud environments, nodes may also be replaced automatically as part of the provider's lifecycle management.

For your lab, W7D7 is modeling a realistic operational scenario: 

"We need to patch the operating system on leia. Safely evacuate workloads, perform the maintenance, verify the node is healthy, and return it to service."

---

## General best practice

The rule of thumb is:

> Maintain the control plane first, then the workers.

Why?

Because the control plane is the "brain" of the cluster. Once it's healthy and stable, you can safely manage the workers.

A typical sequence is:

1. Verify cluster health
2. Backup etcd (if appropriate)
3. Maintain `control planes` (one at a time)
4. Verify cluster health after each `control plane`
5. Maintain `workers` (one at a time)
6. Final health verification

## Control plane maintenance

Examples include:

- Kubernetes version upgrades (kubeadm, kubelet)
- API server configuration changes
- etcd maintenance
- Certificate renewal
- OS patching and reboot
- Container runtime updates

The key point is:

> Never take down more than one control-plane node at a time (assuming a 3-node HA control plane).

For a 3-node cluster:

```text
cp1   Ready
cp2   Ready
cp3   Ready

Maintenance:

cp1  → drain → maintain → verify → uncordon
cp2  → drain → maintain → verify → uncordon
cp3  → drain → maintain → verify → uncordon
```

## Worker maintenance

Workers are much simpler because they don't host the control plane or etcd.

Typical sequence:

```text
worker1
    ↓
cordon
    ↓
drain
    ↓
patch/reboot
    ↓
Ready?
    ↓
uncordon
    ↓
next worker
```

As long as your workloads have enough replicas and capacity elsewhere, users shouldn't notice.

## If you're upgrading Kubernetes

This has a defined order.

For example, upgrading from `v1.34` to `v1.35`:

1. Backup `etcd`
2. Upgrade `kubeadm` on control plane
3. `kubeadm` upgrade apply
4. Upgrade `kubelet`
5. Restart `kubelet`
6. Repeat for each `control plane`
7. Upgrade `workers`

Notice that workers are upgraded after the control plane.

## If you're only patching the OS

The process is similar, just without the Kubernetes version changes:

```text
Control Plane 1
↓
drain
↓
yum/apt update
↓
reboot
↓
verify

Control Plane 2
↓
repeat

Workers
↓
one at a time
```

## One important difference

Notice that `draining a control-plane node` isn't always about moving workloads. Many production clusters taint control-plane nodes so that normal application Pods don't run there.

Instead, draining a control-plane node is mainly to:

- prevent any new schedulable workloads (if the node is hosting any),
- mark the node unschedulable, and
- make it clear to operators that the node is under maintenance.

The critical part of control-plane maintenance is preserving `API availability and etcd quorum`, not Pod migration.

## Production Maintenance Playbook

```text
Pre-maintenance
---------------
✓ Verify cluster health
✓ Verify etcd health
✓ Verify quorum
✓ Confirm backups

Control Plane Maintenance
-------------------------
CP1 → Verify
CP2 → Verify
CP3 → Verify

Worker Maintenance
------------------
Worker1 → Verify
Worker2 → Verify
Worker3 → Verify

Post-maintenance
----------------
✓ Nodes Ready
✓ System Pods healthy
✓ Applications healthy
✓ Storage healthy
✓ Networking healthy
```