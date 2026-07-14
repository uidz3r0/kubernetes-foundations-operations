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

## Steps Detailed:

Step 1.  Archive and Copy to luke 

```bash
cd week7-cluster-operations/W7D2/
tar -cvf w7d2.tar manifests scripts
scp w7d2.tar luke:/tmp/x/
```

Step 2. Login to luke and expand the tar file

```bash
ssh luke

cd /root/w7d2/
tar -xvf /tmp/x/w7d2.tar
```

Step 3. Run verify-install.sh

```bash
sh /root/w7d1/scripts/common/verify-install.sh
```

Step 4. Run init-control-plane.sh / kubeadm init

```bash
sh scripts/rocky/init-control-plane.sh
```

Step 5. Run kubeconfig.sh

```bash
sh scripts/common/kubeconfig.sh
```

Step 6. Run Validation

```bash
sh scripts/common/check-cluster.sh

===== Nodes =====
NAME   STATUS     ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                      KERNEL-VERSION                 CONTAINER-RUNTIME
luke   NotReady   control-plane   36m   v1.34.9   10.1.1.10     <none>        Rocky Linux 9.8 (Blue Onyx)   5.14.0-687.17.1.el9_8.x86_64   containerd://2.2.5

===== System Pods =====
NAMESPACE     NAME                           READY   STATUS    RESTARTS   AGE
kube-system   coredns-66bc5c9577-7rtq9       0/1     Pending   0          35m
kube-system   coredns-66bc5c9577-gg2v5       0/1     Pending   0          35m
kube-system   etcd-luke                      1/1     Running   0          35m
kube-system   kube-apiserver-luke            1/1     Running   0          35m
kube-system   kube-controller-manager-luke   1/1     Running   0          35m
kube-system   kube-proxy-9m9qf               1/1     Running   0          35m
kube-system   kube-scheduler-luke            1/1     Running   0          35m

===== Cluster Info =====
Kubernetes control plane is running at https://10.1.1.10:6443
CoreDNS is running at https://10.1.1.10:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
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

---

## Troubleshooting

- We needed to go back to W7D1 and install `crictl` for troubleshooting and `runc` wasn't also installed for containerd
- We reset the cluster since there is no node yet anyway, below set of commands removes the manifest files:

```bash
sudo kubeadm reset -f
sudo rm -rf /etc/cni/net.d
sudo rm -rf ~/.kube
sudo systemctl restart containerd
sudo systemctl restart kubelet
```

- then re-run: `sh scripts/rocky/init-control-plane.sh`

---

## In Production

```bash
sudo kubeadm reset -f              # Resets kubeadm state, removes control plane files
sudo rm -rf ~/.kube                # Removes kubectl config (local admin credentials)
sudo rm -rf /etc/cni/net.d         # Removes CNI plugin configurations
sudo systemctl restart containerd  # Cleans container runtime state
sudo systemctl restart kubelet     # Restarts kubelet to start fresh
```

### Before Resetting - Important Considerations

⚠️ Only reset if:

- You have backed up critical data (etcd snapshots, persistent volumes, configmaps with important data)
- This is not a production cluster with live workloads, OR you have a disaster recovery plan
- You've exhausted troubleshooting options

For production clusters, prefer:

- Adding/removing nodes individually: kubectl drain → kubectl delete node
- Fixing specific components rather than full reset
- Using kubeadm reset only on nodes being decommissioned, not the entire cluster at once

### Proper Reset Procedure for Multi-Node Clusters

If you must reset all nodes:

1. Worker nodes first (from any worker):

```bash
sudo kubeadm reset -f
```

2. Control plane node last (after workers are reset):

```bash
sudo kubeadm reset -f
sudo rm -rf ~/.kube
```

Then re-initialize with `sudo kubeadm init` and rejoin workers with `kubeadm join`

***Remember***: Reset is destructive—it removes all cluster state. Only do it when you're certain a rebuild is the right choice.

