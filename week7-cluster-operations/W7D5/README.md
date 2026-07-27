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

- Add entry to /etc/hosts
- Install `kube-vip` Static Pod -- this adds IP addr to system network interface

---

## Lab 2

Reinitialize kubeadm using:

```
--control-plane-endpoint
--upload-certs
```

- verify : kubectl get nodes

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

- `kubectl get pods -n kube-system | grep etcd`

---

## Lab 5

Understand etcd quorum.

---

## Lab 6

Simulate control plane failures.

- systemctl stop kubelet

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

---

## Kubeconfig details

```bash
export KUBECONFIG=/path/to/my/secure/config.yaml
kubectl get pods
unset KUBECONFIG

# Managing KUBECONFIG
kubectl config view
kubectl config get-contexts
kubectl config current-context
kubectl config use-context <context-name>
kubectl config use-context arn:aws:eks:ap-southeast-2:393809387946:cluster/platform-tools-eks
```

```bash
# See the server
cat /etc/kubernetes/admin.conf

kubectl config get-contexts

cp luke:/etc/kubernetes/admin.conf laptop:~/.kube/luke-ha.conf
cp han:/etc/kubernetes/admin.conf laptop:~/.kube/han-ha.conf

# Merge
KUBECONFIG=$HOME/.kube/config:$HOME/.kube/luke-ha.conf \
kubectl config view --flatten > /tmp/config

mv /tmp/config ~/.kube/config

# Show
kubectl config get-contexts 
   CURRENT   NAME                          CLUSTER      AUTHINFO           NAMESPACE
   *         kind-w6d7                     kind-w6d7    kind-w6d7          
             kubernetes-admin@kubernetes   kubernetes   kubernetes-admin   

# Rename
kubectl config rename-context \
  kubernetes-admin@kubernetes \
  kubeadm-ha

$ kubectl config get-contexts
   CURRENT   NAME         CLUSTER      AUTHINFO           NAMESPACE
   *         kind-w6d7    kind-w6d7    kind-w6d7          
             kubeadm-ha   kubernetes   kubernetes-admin   

kubectl config rename-context kubeadm-ha homelab-ha
kubectl config rename-cluster kubernetes homelab

kubectl config view --minify
kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}'

systemctl is-active containerd
systemctl is-active kubelet     (watches /etc/kubernetes/manifest; crictl ps)
```

---

## 🔄 The Standard Maintenance Steps

```text
    Applications Running
            │
            ▼
     1. kubectl cordon <node>           (Stop new Pods from being scheduled)
            │
            ▼
     2. kubectl drain <node>            (Evict existing Pods gracefully)
            │
            ▼
     3. Perform OS / Package Updates    (Apply patches, CRI/Kubelet upgrades, reboot)
            │
            ▼
     4. Verify Node & Service Health    (Ensure kubelet/containerd are Ready)
            │
            ▼
     5. kubectl uncordon <node>         (Allow Scheduler to place Pods again)
```

### ❌ 1. Cordon (The Pause Button)

```bash
sudo kubectl cordon <node-name>
kubectl cordon leia
```

- Effect: Sets the node status to `Ready,SchedulingDisabled`. New Pods will not be scheduled here.


### 📦 2. Drain (The Evacuator)

```bash
sudo kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data --force

# remove taint from han to be schedulable for leia
kubectl taint nodes han node-role.kubernetes.io/control-plane-

# put it back
kubectl taint nodes han node-role.kubernetes.io/control-plane:NoSchedule

# Drain leia
kubectl drain leia --ignore-daemonsets --delete-emptydir-data --force
```

- Effect: **Evicts existing pods** from the node to other nodes in the cluster.
  - It respects `PodDisruptionBudgets (PDBs)` to prevent taking down too much at once.

- Key Flags:
  - `--ignore-daemonsets`: DaemonSet pods run on all nodes, so you must include this flag to evict them (they will be recreated on other nodes after the upgrade).
  - `--delete-emptydir-data`: WARNING: This allows evicting pods that use `emptyDir` volumes. This data is lost when the pod is evicted.
  - `--force`: Use with caution. This allows evicting pods that are not managed by a controller (e.g., manually created pods) or pods that have `PodDisruptionBudgets` that would block the eviction.

### 🔧 3. OS / Package Updates

```text
Includes kernel patches, CRI updates (containerd), and kubelet upgrades.

leia:
   sudo apt update && sudo apt upgrade -y
han:
   sudo apt update && sudo apt upgrade -y
luke:
   sudo dnf update -y && sudo reboot

# Check Registry for Current Version (current 1.34.9-150500.1.1)
leia: 
   sudo apt-cache policy kubeadm
   sudo apt-cache policy kubelet

han: 
   sudo apt-cache policy kubeadm
   sudo apt-cache policy kubelet

luke: 
   sudo dnf list kubeadm
   sudo dnf list kubelet

```

### ✅ 4. Verify Node & Service Health

```text
Ensure kubelet/containerd are Ready

leia: 
   sudo systemctl status kubelet
   sudo systemctl status containerd

han:
   sudo systemctl status kubelet
   sudo systemctl status containerd
   kubectl get nodes -o wide

luke:
   sudo systemctl status kubelet
   sudo systemctl status containerd
   kubectl get nodes -o wide
```

### 🚀 5. Uncordon

```text
Allow Scheduler to place Pods again

leia:
   sudo kubectl uncordon leia

han:
   sudo kubectl uncordon leia

luke:
   sudo kubectl uncordon leia
```

- Normally we leave the pods where and will move and reschedule the pods to other nodes when the node is being removed (e.g. decomissioning). 

---

## Versions

When the Kubernetes documentation refers to a Version Skew, it is almost always talking about Minor Version Skew.

1.34.9 = Major.Minor.Patch
1.34.9-150500.1.1 = Major.Minor.Patch-Distribution.Minor.Patch

- Supported Minor Skew: Moving from 1.34 to 1.35 is a 1-minor version skew. This is perfectly legal and supported.
- Unsupported Minor Skew: Moving from 1.34 to 1.36 is not supported. This creates 2-minor version gap between control plane nodes. 

```bash
# k get nodes -o wide
NAME    STATUS   ROLES           AGE     VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                      KERNEL-VERSION                 CONTAINER-RUNTIME
han     Ready    control-plane   9d      v1.34.9   10.1.1.11     <none>        Ubuntu 24.04.4 LTS            6.8.0-136-generic              containerd://2.2.1
leia    Ready    <none>          9d      v1.34.9   10.1.1.12     <none>        Ubuntu 24.04.4 LTS            6.17.0-35-generic              containerd://2.2.1
luke    Ready    control-plane   9d      v1.34.9   10.1.1.10     <none>        Rocky Linux 9.8 (Blue Onyx)   5.14.0-687.17.1.el9_8.x86_64   containerd://2.2.5
padme   Ready    control-plane   4d14h   v1.34.9   10.1.1.14     <none>        Ubuntu 24.04.4 LTS            6.8.0-136-generic              containerd://2.2.1
```

Bring all control-plane and worker nodes up to 1.35.9 first before upgrading to 1.36. Otherwise the cluster will lose quorum and control-plane will crash. 

## For Cloud Platforms like AWS EKS, it's much simpler to do this: 

**Option 1 - Let EKS manage it for you (Recommended for non-production or test clusters):**

```bash
# See what versions are available
aws eks list-updates --name my-eks-cluster --region ap-southeast-2

# Upgrade control plane
aws eks update-cluster-version \
    --name my-eks-cluster \
    --kubernetes-version 1.35 \
    --region ap-southeast-2

# Watch the magic happen
kubectl get nodes
```

**Option 2 - eksctl (If you used eksctl to create the cluster):**

```bash
# Upgrade worker nodes
eksctl upgrade nodegroup \
    --cluster my-eks-cluster \
    --name my-nodegroup \
    --kubernetes-version 1.35 \
    --region ap-southeast-2
```

If using terraform, you can upgrade the cluster by updating the kubernetes_version attribute in the aws_eks_cluster resource and running terraform apply.

Worker nodes use an automated strategy called:

```text
Rolling Update Strategy
   1. Identify a node to upgrade.
   2. Drain the node (cordon + evict).
   3. Upgrade the kubelet/OS.
   4. Uncordon the node.
   5. Move to the next node.
```

**Option 3 - EKS Self-Managed Nodes:**

If you are using EC2 instances directly (not managed node groups), you must perform the rolling update manually.

## For Rancher

If you used the Cluster API (CAPI) to create the cluster, you can upgrade the cluster by updating the kubernetes_version attribute in the Cluster object and running a terraform apply.

```yaml
# In Cluster.yaml
apiVersion: cluster.x-k8s.io/v1beta1
spec:
  kubernetesVersion: v1.35.9
```

## For kubeadm

From: 1.34.9 To: 1.35.7    ✅ Done Jul 24, 2026
From: 1.35.7 To: 1.36.3 

### Upgrade Sequence & Rules
1. **Control Planes First:** Upgrade control plane nodes one by one (`han` $\rightarrow$ `padme` $\rightarrow$ `luke`).
2. **Workers Last:** Upgrade worker nodes only after all control planes are upgraded (`leia`).
3. **`kubeadm upgrade apply` vs `node`:**
   * Run `sudo kubeadm upgrade apply v1.35.9` **ONLY** on the **first** control plane (`han`).
   * Run `sudo kubeadm upgrade node` on all **subsequent** control planes (`padme`, `luke`) and workers (`leia`).
4. **Package Unholding & Repos (`pkgs.k8s.io`):**
   * Debian/Ubuntu package versions on `pkgs.k8s.io` use the **`-1.1`** suffix (e.g., `1.35.9-1.1`), NOT the old `-00` suffix.
   * Run `apt-cache policy kubeadm` to check exact available version strings in your repo.
   * **Ubuntu/Debian (`han`, `padme`, `leia`):** Use `sudo apt-mark unhold` before installing and `sudo apt-mark hold` after.
   * **Rocky Linux (`luke`):** Use `sudo dnf install --disableexcludes=kubernetes`.

---

### STEP 1: Upgrade First Control Plane (`han` — Ubuntu)
```bash
kubectl cordon han
kubectl drain han --ignore-daemonsets --delete-emptydir-data --force

# Update APT repo to v1.35 in /etc/apt/sources.list.d/kubernetes.list:
# deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /

cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /
EOF

kubeadm upgrade plan

sudo apt-mark unhold kubeadm
sudo apt-get update
# Check exact package version string: apt-cache policy kubeadm
sudo apt-get install -y kubeadm=1.35.7-1.1
sudo apt-mark hold kubeadm 

# FIRST CONTROL PLANE ONLY:
sudo kubeadm upgrade apply v1.35.7 -y

sudo apt-mark unhold kubelet kubectl
sudo apt-get install -y kubelet=1.35.7-1.1 kubectl=1.35.7-1.1
sudo apt-mark hold kubelet kubectl

sudo systemctl daemon-reload && sudo systemctl restart kubelet
kubectl uncordon han
```

### STEP 2: Upgrade Secondary Control Plane (`padme` — Ubuntu)
```bash
kubectl cordon padme
kubectl drain padme --ignore-daemonsets --delete-emptydir-data --force

# Update APT repo to v1.35 in /etc/apt/sources.list.d/kubernetes.list
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /
EOF

sudo apt-mark unhold kubeadm
sudo apt-get update
sudo apt-get install -y kubeadm=1.35.7-1.1
sudo apt-mark hold kubeadm

# SECONDARY CONTROL PLANE: kubeadm upgrade node (NOT apply!)
sudo kubeadm upgrade node

sudo apt-mark unhold kubelet kubectl
sudo apt-get install -y kubelet=1.35.7-1.1 kubectl=1.35.7-1.1
sudo apt-mark hold kubelet kubectl

sudo systemctl daemon-reload && sudo systemctl restart kubelet
kubectl uncordon padme
```

### STEP 3: Upgrade Secondary Control Plane (`luke` — Rocky Linux)
```bash
kubectl cordon luke
kubectl drain luke --ignore-daemonsets --delete-emptydir-data --force

# update the Repositories
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.35/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.35/rpm/repodata/repomd.xml.key
EOF

sudo dnf makecache

# Unlock versionlock if locked
sudo dnf versionlock delete kubeadm kubelet kubectl 2>/dev/null || true

# Upgrade kubeadm (check available version: sudo dnf list --showduplicates kubeadm)
sudo dnf install -y kubeadm-1.35.7-150500.1.1 --disableexcludes=kubernetes

# SECONDARY CONTROL PLANE: kubeadm upgrade node
sudo kubeadm upgrade node

# Upgrade kubelet and kubectl
sudo dnf install -y kubelet-1.35.7-150500.1.1 kubectl-1.35.7-150500.1.1 --disableexcludes=kubernetes

sudo systemctl daemon-reload && sudo systemctl restart kubelet
kubectl uncordon luke
```

### STEP 4: Upgrade Worker Node (`leia` — Ubuntu)
```bash
kubectl cordon leia
kubectl drain leia --ignore-daemonsets --delete-emptydir-data --force

# Update APT repo to v1.35 in /etc/apt/sources.list.d/kubernetes.list
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /
EOF

sudo apt-mark unhold kubeadm kubelet kubectl
sudo apt-get update
sudo apt-get install -y kubeadm=1.35.7-1.1 kubelet=1.35.7-1.1 kubectl=1.35.7-1.1
sudo apt-mark hold kubeadm kubelet kubectl

# WORKER NODE: kubeadm upgrade node
sudo kubeadm upgrade node

sudo systemctl daemon-reload && sudo systemctl restart kubelet
kubectl uncordon leia

# Verify the cluster is healthy
kg componentstatuses

k cluster-info
k get --raw='/readyz?verbose'

# Quick smoke test
k create deployment nginx --image=nginx
k expose deployment nginx --port=80
k get pods
k get svc
k delete deployment nginx
k delete svc nginx   
```

etcd backup
```text
etcdctl snapshot save /k8s-lab/backups/etcd-$(date +%F-%H-%M).db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

# Copy to a safe location (your laptop, etc)
scp padme:~/backup-*.db .
```

# What Happens During Upgrade
1. **Cordon** - Node is marked unschedulable.
2. **Evict** - Running pods are gracefully terminated and rescheduled to healthy nodes.
3. **Upgrade Kubelet** - The node agent is upgraded.
4. **Uncordon** - Node is marked schedulable again.

---

## Change of Plans 

(see W0D1 on implementation)

### From 

| Node | Role | OS | Hardware | CPU | Memory | Disk | 
|------|------|-----|----------|-----|--------|------|
| **luke.lab** | Control Plane #1 | Rocky Linux 9.8 | Intel NUC, i5 2.7GHz | 4 | 16 GB | 230 GB |
| **han.lab** | Control Plane #2 | Ubuntu 24.04 | Old Tower, AMD 3.7GHz | 4 | 8 GB | 2 TB | 
| **padme.lab** | Control Plane #3 | Ubuntu 24.04 | Intel NUC, i5 2.4GHz | 8 | 16 GB | 500 GB |
| **leia.lab** | Worker | Ubuntu 24.04 | Old Laptop, i5-4200U 1.60GHz | 4 | 4 GB | 1 TB |

### To

| Node | Role | OS | Hardware | CPU | Memory | Disk | 
|------|------|-----|----------|-----|--------|------|
| **leia.lab** | Control Plane #3 | Ubuntu 24.04 | Old Laptop, i5-4200U 1.60GHz | 4 | 4 GB | 1 TB |
| **padme.lab** | Worker | Ubuntu 24.04 | Intel NUC, i5 2.4GHz | 8 | 16 GB | 500 GB |

Note: 

- `kubeadm reset` cleans up the local node but does not reconfigure the existing etcd cluster for you. You may need to check and remove any stale membership. 
