# W7D4 — Join Worker Nodes

## Objectives

Learn:

- kubeadm join
- Bootstrap tokens
- Discovery token CA hash
- Node registration
- Workload scheduling
- Remove and rejoin worker nodes

---

# Lab Environment

| Host | Role | 
|------|------|
| luke | Control Plane |
| leia | Worker |
| han | not included |



---

# Expected Learning Outcomes

By the end of this lab you should be able to:

- Explain how worker nodes join a cluster
- Generate new bootstrap tokens
- Understand the discovery token CA hash
- Join worker nodes
- Verify node registration
- Deploy workloads to worker nodes
- Remove a node safely
- Rejoin a node

## Steps Summary

Step 2 — Generate Worker Join Command.
Step 3 — Join `leia`.
Step 4 — Verify `luke` + `leia`
Step 5 — Deploy workloads
Step 6 — Drain/Uncordon `leia`
Step 7 — Remove/Rejoin `leia`

> **Note**
>
> Unless otherwise stated, all commands are executed on the control-plane (`luke`).
>
> The following commands are executed on the worker node (`leia`):
>
> - `kubeadm join`
> - `kubeadm reset` (during the remove/rejoin exercise)

### A worker only has:

- kubelet
- kube-proxy
- CNI
- Container runtime

### It does not have:

- kube-apiserver
- kube-controller-manager
- kube-scheduler
- local etcd (in a stacked etcd topology)
- control plane certificates

So it's just a worker.

---

# Step 1 — Verify the Control Plane

On **luke**

```bash
kubectl get nodes
kubectl get pods -A
```

---

# Step 2 — Generate a Join Command (for leia)

Run in luke

```bash
sh scripts/common/generate-join-command.sh
```

Example output

```text
kubeadm join 192.168.1.20:6443 \
--token abcdef.1234567890abcdef \
--discovery-token-ca-cert-hash sha256:xxxxxxxx
```

---

# Step 3 — Join Worker Node

Copy the command.

Run it on **leia**.

<s>Then repeat on **han**</s>.

Or use

Rocky

```bash
sudo sh scripts/rocky/join-worker.sh
```

Ubuntu

```bash
sudo sh scripts/ubuntu/join-worker.sh
```

---

# Step 4 — Verify Registration

Back on the control plane

```bash
kubectl get nodes
```

Expected

```text
NAME    STATUS   ROLES           AGE
luke    Ready    control-plane
leia    Ready    <none>
han     Ready    <none>
```

---

# Step 5 — Verify Cluster

```bash
sh scripts/common/verify-workers.sh
```

---

# Step 6 — Deploy a Test Application

```bash
kubectl apply -f manifests/nginx-deployment.yaml
```

Watch scheduling

```bash
kubectl get pods -o wide
```

Notice the worker node chosen.

---

# Step 7 — Drain a Worker

Example

```bash
kubectl drain leia \
--ignore-daemonsets \
--delete-emptydir-data
```

Observe pods move.

---

# Step 8 — Uncordon

```bash
kubectl uncordon leia
```

---

# Step 9 — Remove a Worker

```bash
kubectl delete node leia
```

On the worker

```bash
sudo sh scripts/common/reset-worker.sh
```

---

# Step 10 — Rejoin

Generate a new join command

```bash
sh scripts/common/generate-join-command.sh
```

Run it again on the worker.

---

# Verify

```bash
kubectl get nodes
kubectl get pods -o wide
```

All nodes should be Ready.

---

## Lab Notes

This lab intentionally uses the real `kubeadm join` workflow rather than hiding it behind automation. By copying and executing the generated join command, you'll see the key components involved:

- **Bootstrap token** – a short-lived token that authenticates the joining node to the control plane.
- **Discovery token CA hash** – the SHA-256 hash of the cluster's CA public key, allowing the worker to verify it is connecting to the correct control plane and preventing man-in-the-middle attacks.
- **Node registration** – after successful TLS bootstrapping, the kubelet registers the node with the API server, and it appears in `kubectl get nodes`.
- **Workload scheduling** – once the node reaches the `Ready` state, the Kubernetes scheduler can place Pods on it.
- **Remove and rejoin** – `kubectl drain`, `kubectl delete node`, `kubeadm reset`, and a new `kubeadm join` allow you to safely recycle or rebuild worker nodes, mirroring common production maintenance workflows.

This sequence closely reflects the tasks expected of Kubernetes administrators and those encountered in the CKA exam, making it a solid foundation before moving on to multi-control-plane clusters and lifecycle operations.

---

## Firewall

If you want to keep the firewall on:

```bash
sudo firewall-cmd --permanent --add-port=6443/tcp
sudo firewall-cmd --permanent --add-port=2379-2380/tcp
sudo firewall-cmd --permanent --add-port=10250/tcp
sudo firewall-cmd --permanent --add-port=10257/tcp
sudo firewall-cmd --permanent --add-port=10259/tcp
sudo firewall-cmd --permanent --add-port=179/tcp
sudo firewall-cmd --reload
```

| Port              | Purpose                               | Needed                     |
| ----------------- | ------------------------------------- | -------------------------- |
| **6443/TCP**      | Kubernetes API Server                 | ✅ Required                 |
| **2379-2380/TCP** | etcd peer/client                      | ✅ For control plane / etcd |
| **10250/TCP**     | kubelet API                           | ✅ Required                 |
| **10257/TCP**     | kube-controller-manager (secure port) | ✅ Modern Kubernetes        |
| **10259/TCP**     | kube-scheduler (secure port)          | ✅ Modern Kubernetes        |
| **179/TCP**       | Calico BGP peering                    | ✅ if using Calico in BGP mode |

- You'll notice its 10257 and 10259 instead of 10251 and 10252. In current Kubernetes releases, the insecure ports 10251 and 10252 are no longer used by default

```bash
# Port 179 was not open in luke before thus the current was only 3
# Check all calico pods desired versus current
$ kubectl get ds calico-node -n kube-system
NAME          DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
calico-node   4         3         4       4            4           kubernetes.io/os=linux   9d

$ $ kg pods -n kube-system | grep calico
calico-kube-controllers-5766bdd7c-5j89k   1/1     Running   181 (6h57m ago)   7d21h
calico-node-7mz56                         1/1     Running   2 (9h ago)        9d
calico-node-cfr99                         1/1     Running   0                 3d18h
calico-node-hk8gk                         1/1     Running   0                 9d
calico-node-wstjx                         0/1     Running   0                 9m3s

$ sudo firewall-cmd --permanent --add-port=179/tcp
$ sudo firewall-cmd --reload

# Whats their names? 
$ kubectl get pods -n kube-system | grep calico 
calico-kube-controllers-5766bdd7c-5j89k   1/1     Running   181 (7h20m ago)   7d21h
calico-node-7mz56                         1/1     Running   2 (9h ago)        9d
calico-node-cfr99                         1/1     Running   0                 3d18h
calico-node-hk8gk                         1/1     Running   0                 9d
calico-node-wstjx                         1/1     Running   0                 32m

# Check the BGP running on that pod
$ kubectl exec -it -n kube-system calico-node-wstjx -- birdcl show protocols
Defaulted container "calico-node" out of: calico-node, upgrade-ipam (init), install-cni (init), ebpf-bootstrap (init)
BIRD v0.3.3+birdv1.6.8 ready.
name     proto    table    state  since       info
static1  Static   master   up     07:37:26    
kernel1  Kernel   master   up     07:37:26    
device1  Device   master   up     07:37:26    
direct1  Direct   master   up     07:37:26    
Mesh_10_1_1_11 BGP      master   up     07:58:43    Established   
Mesh_10_1_1_12 BGP      master   up     08:07:04    Established   
Mesh_10_1_1_14 BGP      master   up     07:58:43    Established   

$ kubectl exec -it -n kube-system calico-node-wstjx -- ls /usr/sbin | grep bird
Defaulted container "calico-node" out of: calico-node, upgrade-ipam (init), install-cni (init), ebpf-bootstrap (init)

$ firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: wlp2s0
  sources: 
  services: cockpit dhcpv6-client ssh
  ports: 6443/tcp 2379-2380/tcp 10250/tcp 10257/tcp 10259/tcp 179/tcp
  protocols: 
  forward: yes
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 

```