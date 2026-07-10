# week7-cluster-operations/W7D1/README.md

# W7D1 — Install Kubernetes Components

## Objectives

Learn how Kubernetes is installed on Linux nodes before a cluster is created.

Install:

- containerd
- kubelet
- kubeadm
- kubectl

Understand:

- Container Runtime Interface (CRI)
- Why containerd is required
- Why kubelet does not start successfully yet
- SystemdCgroup configuration
- Version pinning
- Kubernetes package repositories

---

## Expected Learning Outcomes

By the end of this lab you should be able to:

- Explain the role of containerd
- Explain the role of kubelet
- Explain the purpose of kubeadm
- Explain the purpose of kubectl
- Configure containerd correctly
- Verify Kubernetes components are installed
- Prepare Linux nodes for kubeadm

---

## Home Lab

Perform this lab on every node.

| Host | Role | OS |
|------|------|----|
| luke | Control Plane #1 | Rocky Linux |
| han | Control Plane #2 | Ubuntu |
| leia | Worker | Ubuntu |

*(padme can be added later as Control Plane #3.)*

---

## Steps

1. Update the operating system
2. Install containerd
3. Configure SystemdCgroup
4. Enable containerd
5. Add Kubernetes package repository
6. Install Kubernetes packages
7. Prevent automatic package upgrades
8. Enable kubelet
9. Verify installation

No cluster is created today.

### Execute

> **Note**
>
> This lab assumes you are logged in as **root** on each Kubernetes node.
>
> If using a non-root account, prepend privileged commands with `sudo`.

## Pre-flight Checklist

Ensure the node is clean before installation.

Verify:

- Docker is not installed
- No previous Kubernetes packages are installed
- No previous kubeadm cluster exists
- No existing /etc/kubernetes directory

```bash
which docker
which kubeadm
which kubelet
which kubectl

rpm -qa | grep -E 'docker|containerd|kube'

ls /etc/kubernetes
```

**Step 0**

Tar and copy the files:

```bash
cd /home/allan/k8s/week7-cluster-operations/W7D1/
tar -cvf scripts.tar scripts
scp scripts.tar luke:/tmp/x/
scp scripts.tar han:/tmp/x/
scp scripts.tar leia:/tmp/x/
```

**Steps 1–4**

Run the appropriate script for your operating system:

```bash
mkdir /root/kubeadm-install/ ; cd /root/kubeadm-install/ 
tar -xvf /tmp/x/scripts.tar
```

> **Rocky Linux only**
>
> The `containerd` package is not available in the default BaseOS/AppStream repos.
> Enable EPEL before running `install-containerd.sh`:
>
> ```bash
> sudo dnf install -y epel-release
> ```

```text
sh scripts/rocky/install-containerd.sh
sh scripts/ubuntu/install-containerd.sh
```

**Step 5**

Follow the operating system-specific instructions below to add the official Kubernetes package repository.

**Steps 6–8**

Run the appropriate installation script:

```text
sh scripts/rocky/install-kubernetes.sh
sh scripts/ubuntu/install-kubernetes.sh
```

**Step 9**

Verify the installation:

```text
sh scripts/common/verify-install.sh
```

---

## Step 5 — Configure the Kubernetes Package Repository

Kubernetes packages are distributed from the official Kubernetes package repository rather than the default operating system repositories.

Follow the appropriate instructions for your operating system.

### Ubuntu

```bash
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key \
| sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

cat >/etc/apt/sources.list.d/kubernetes.list <<'EOF'
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /
EOF

sudo apt update
```

---

### Rocky Linux

```bash
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.34/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.34/rpm/repodata/repomd.xml.key
EOF

sudo dnf makecache
```

---

Verify the repository has been added successfully before installing Kubernetes packages.

---

## Verify

```bash
containerd --version

kubelet --version

kubeadm version

kubectl version --client
```

---

## Expected Result

You should have:

- containerd running
- kubelet installed
- kubeadm installed
- kubectl installed

The kubelet service may report errors because no Kubernetes cluster exists yet. This is expected.

---

## Files

```
W7D1
├── notes.md
├── README.md
└── scripts
    ├── common
    │   └── verify-install.sh
    ├── rocky
    │   ├── install-containerd.sh
    │   └── install-kubernetes.sh
    └── ubuntu
        ├── install-containerd.sh
        └── install-kubernetes.sh
```

---

## Lab Validation

This lab has been tested on:

- Rocky Linux 9
- Ubuntu 25.04

The installation process should result in:

- containerd installed and running
- kubelet installed and enabled
- kubeadm installed
- kubectl installed
- Kubernetes packages locked
- Ready for `kubeadm init`