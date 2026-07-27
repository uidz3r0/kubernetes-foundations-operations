# Week 0 Day 1

## Production Kubernetes Lab Preparation

Today is about preparing Linux servers before Kubernetes installation.

## Nodes

| Hostname | IP | Role | OS |
|----------|-------------|-----------------|------------|
| luke | 10.1.1.10 | Control Plane | Rocky Linux |
| han | 10.1.1.11 | Control Plane | Ubuntu |
| leia | 10.1.1.12 | Worker | Ubuntu |

Future

| Hostname | Role |
|----------|------|
| padme | Control Plane #3 |

---

## Base

* Rocky Linux (`luke`) as __Control Plane #1__
* Ubuntu (`han`) ready to join as __Control Plane #2__
* Ubuntu (`leia`) joined as the Worker
* `padme` reserved for Control Plane #3 later
* `containerd` configured with `SystemdCgroup`
* Kubernetes installed with `kubeadm`
* Calico CNI installed
* MetalLB configured for `LoadBalancer` services on your LAN
* Ingress NGINX installed
* Metrics Server installed
* A reusable set of scripts and documentation to support all of __Week 7 (Cluster Operations)__ and future HA expansion without rebuilding the cluster.

---

## Objectives

Prepare every server for Kubernetes.

Learn:

- Hostnames
- Set timezone (Australia/Brisbane)
- Static IP verification
- DNS
- SSH
- Time synchronization
- Kernel modules
- sysctl
- Swap (check /etc/fstab)
- Firewall
- SELinux/AppArmor
- Package updates

Nothing Kubernetes-specific is installed today.

---

Files

```
scripts/common.sh
scripts/rocky.sh
scripts/ubuntu.sh
```
---

## IP Address Range

### In Router:

```text
10.1.1.1       Gateway/Router/DNS
10.1.1.2-99    Static Infrastructure (Home Lab)
10.1.1.100-199 DHCP Clients
10.1.1.200-254 Temporary Devices
```

### IP Range Allocations:

```text
10.1.1.10-19   Kubernetes Nodes
10.1.1.20-29   Infrastructure Services
10.1.1.30-39   MetalLB LoadBalancer IPs
10.1.1.40-49   Storage Services
10.1.1.50-59   Virtual Machines
10.1.1.60-69   Networking Appliances
10.1.1.70-79   Future Expansion
10.1.1.80-99   Spare Static Addresses
```

---

Your W0D1 should be very task-oriented:

1. Verify hostnames
2. Verify static IPs
3. Update OS
4. Configure /etc/hosts
5. Disable swap
6. Load overlay and br_netfilter
7. Apply sysctl
8. Configure time synchronization
9. Verify SSH
10. Verify firewall/SELinux
11. Reboot
12. Verify everything

That's it.

The goal is simply:

"Prepare three Linux servers for Kubernetes installation using kubeadm."

---

```bash
# han: (sda3) / partiton is currently just 100G, just use all
# 1- Resize the Partition: Use parted to ensure partition sda3 occupies the entire disk
sudo parted /dev/sda resizepart 3 100%

# 2- Resize the Physical Volume: Inform LVM that the physical partition has grown
sudo pvresize /dev/sda3

# 3- Extend the Logical Volume: Allocate all free space in the Volume Group to your root logical volume
sudo lvextend -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv   

# 4- Resize the Filesystem: Expand the ext4 filesystem to fill the new logical volume size.
sudo resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv   

# Verify: Run df -h to confirm / now shows ~1.8TB. 
df -kh
mkdir /opt/data
```

---

A possible evolution of this home lab is to build a simulated Internal Developer Platform (IDP):

### Core Concepts

`Golden Path` (or Paved Road) A recommended, opinionated, and supported workflow for common development tasks (e.g., creating a microservice, deploying to production).  It codifies best practices for security, compliance, and observability but remains optional—developers can go "off-road" if needed, though they forfeit platform support.  Popularized by Spotify.

`Self-Service` The ability for developers to provision resources, deploy applications, and access tools without manual intervention from operations teams.  This is a primary goal of IDPs, reducing ticket queues and wait times from days to minutes. 

`Cognitive Load Reduction` A key metric for IDP success. Refers to minimizing the mental effort developers spend on infrastructure, tooling, and processes so they can focus on writing business logic. 

`Platform Orchestrator` The backend engine that receives developer intent (e.g., "deploy this service") and translates it into automated workflows across infrastructure, CI/CD, and security systems.


```text
Developers
     │
     ▼
GitHub / GitLab
     │
     ▼
CI/CD (GitHub Actions or Jenkins)
     │
     ▼
Argo CD (GitOps)
     │
     ▼
Kubernetes Platform
├── Ingress / Gateway API
├── cert-manager
├── External Secrets
├── Monitoring
│   ├── Prometheus
│   ├── Grafana
│   └── Alertmanager
├── Logging
│   ├── Loki
│   └── Fluent Bit
├── Tracing
│   └── Tempo
├── VictoriaMetrics (optional)
├── Kyverno
├── ExternalDNS (if applicable)
└── Storage
```

Another high-level architecture could look like this:

```text
                    Developers
                         │
                         │
                GitHub / GitLab
                         │
                  Pull Request
                         │
                 CI Pipeline (Jenkins)
                         │
          ┌──────── Build & Scan ────────┐
          │                              │
      Trivy        Checkov       Semgrep
          │                              │
          └────────────┬─────────────────┘
                       │
                  Container Image
                       │
                Local Container Registry
                       │
                  ArgoCD / GitOps
                       │
                 Kubernetes Cluster
                       │
        ┌──────────────┼──────────────┐
        │              │              │
    Gateway API    cert-manager   External Secrets
        │              │              │
        └──────────────┼──────────────┘
                       │
              Application Namespace
                       │
         Prometheus • Grafana • Loki
                       │
                VictoriaMetrics
```

Then add the platform layer:

```text
Developer
    │
    ▼
Request New Project
    │
    ▼
Template Repository
    │
    ▼
Creates

• Git repository
• Namespace
• RBAC
• ResourceQuota
• LimitRange
• NetworkPolicy
• Pipeline
• Helm values
• GitOps application
• Monitoring
• Dashboard
```

From the developer's perspective:

1. Create a new project.
2. Push code.
3. Pipeline builds the image.
4. Image is scanned.
5. Image is published.
6. ArgoCD deploys automatically.
7. HTTPS is available.
8. Logs and metrics appear automatically.
9. Secrets are managed.
10. Alerts and dashboards are ready.

The developer primarily focuses on the application code.

---

Where your current curriculum fits

You've already covered or planned most of the building blocks:

```text
✅ Kubernetes fundamentals
✅ Helm
✅ RBAC
✅ Network Policies
✅ Security Contexts
✅ Admission Controllers
✅ External Secrets
✅ Prometheus/Grafana
✅ GitOps concepts
✅ Cluster Operations
✅ etcd
✅ Certificates
```

The remaining pieces are mostly platform automation rather than Kubernetes concepts.

---

A possible Phase 2

After Week 7, you could introduce a Platform Engineering phase:

* Platform repository structure
* Jenkins shared pipelines
* Local container registry
* ArgoCD bootstrap
* cert-manager
* External Secrets
* Gateway API / Ingress
* Monitoring stack
* Logging (Loki)
* VictoriaMetrics
* Developer templates
* Namespace provisioning
* Self-service deployment
* Policy enforcement (Kyverno)
* Multi-tenancy
* Backup & disaster recovery

---

The "Landing Zone"

In the cloud, a landing zone typically provisions accounts, networking, IAM, and guardrails.

In Kubernetes, the equivalent is a developer landing zone, where a new application receives everything it needs automatically:

```text
Namespace
RBAC
Resource quotas
Network policies
Secrets integration
CI/CD pipeline
GitOps application
TLS
Monitoring
Logging
Alerts
Dashboards
```

It won't match the scale of products like `Backstage` or commercial platforms, but it will demonstrate the same core Platform Engineering principles that many organizations use in production.

---

## Architectural Terms

`Software Catalog` A centralized inventory of all software entities (microservices, libraries, APIs, pipelines) with metadata like ownership, lifecycle status, and dependencies.  In Backstage, this is defined via `catalog-info.yaml` files.

`Scaffolding` (or Templates) Automated project generation tools that create new services with pre-configured structures, CI/CD pipelines, and governance policies.  This is how golden paths are technically implemented.

`Guardrails` Enforced policies and constraints that prevent unsafe or non-compliant actions (e.g., blocking deployments without security scans).  Unlike golden paths, guardrails are mandatory.

`Resource Plane` vs. `Control Plane`

- `Control Plane`: The interface where developers express intent (e.g., via a portal or API). 
- `Resource Plane`: The underlying infrastructure (Kubernetes, cloud services) where applications actually run. 

## Related Buzzwords

`DevEx` (Developer Experience) The overall quality of a developer's interaction with tools, processes, and platforms. IDPs aim to maximize DevEx by reducing friction.

`TicketOps` A derogatory term for traditional operations models where developers must file tickets and wait for manual provisioning—what IDPs seek to replace.

`Railroads` Rigid, mandated workflows with no flexibility.  Unlike golden paths, railroads force compliance and are generally discouraged as they reduce innovation.

`Scorecards` Benchmarking tools that measure software quality, security posture, or compliance against organizational standards, often integrated into the software catalog.

`TechDocs` Documentation-as-code systems where docs are versioned with source code and rendered automatically in the developer portal. 

---

## Setup in padme 

```bash
git clone https://github.com/uidz3r0/k8s-lab.git /k8s-lab
/k8s-lab/scripts/setup/install-crictl.sh

# ~/k8s/week0-home-lab-setup/W0D1/scripts/common.sh
/k8s-lab/scripts/setup/common.sh 

# run as regular-user
/k8s-lab/scripts/setup/01-node-setup.sh
    sudo ufw allow 6443/tcp
    sudo ufw allow 2379:2380/tcp
    sudo ufw allow 10250/tcp
    sudo ufw allow 10257/tcp
    sudo ufw allow 10259/tcp


# In luke,
/k8s-lab/scripts/cluster/generate-control-plane-join.sh

# In padme
/k8s-lab/scripts/cluster/reset-control-plane.sh

kubeadm join k8s-api.lab:6443 --token ejsw3y.8j4789r75cw0p7e8 --discovery-token-ca-cert-hash sha256:990784e53aaff966b2fa6a0a2c1d1ca1b44af3b15bb5118e841df6f651fd5c53 --control-plane --certificate-key 1a17c24d6d5793271ce3ef7df45363d06b6930e73551005bacf78a365f8e41d0

# kube-vip setup found W7D5/lab0.md

# Identify latest stable version
curl -sL https://api.github.com/repos/kube-vip/kube-vip/releases | jq -r ".[0].name"
    v1.2.1

     sudo ctr image pull ghcr.io/kube-vip/kube-vip:v1.2.1

     ping k8s-api.lab
     ip addr show wlp2s0 | grep 10.1.1.15

     kubectl get pods -n kube-system | grep vip

# generate the static pods
ip addr show

export INTERFACE=wlo1
export VIP=10.1.1.15
VERSION=v1.2.1

sudo ctr run --rm --net-host \
  ghcr.io/kube-vip/kube-vip:${VERSION} \
  vip \
  /kube-vip manifest pod \
    --interface ${INTERFACE} \
    --address ${VIP} \
    --controlplane \
    --services \
    --arp \
    --leaderElection \
  | sudo tee /etc/kubernetes/manifests/kube-vip.yaml      

kubectl get pods -n kube-system | grep vip  
```

---

## Change of Plans

- see W7D5 for Version updates

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

---

## For PADME, convert from control-plane to worker (see W7D4)

- cordon/drain = safe maintenance prep
- reset/demote + rejoin = role change (for PADME/LEIA's case)

```bash
# Firewall is inactive for Ubuntu
ufw status

# Execute from luke or han
kubectl cordon padme
kubectl drain padme --ignore-daemonsets --delete-emptydir-data
kubectl delete node padme

# check health on han and luke; expect  "https://127.0.0.1:2379 is healthy"
sudo ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  endpoint health

# on PADME, full reset:
kubeadm reset -f
systemctl stop kubelet
rm -rf /etc/kubernetes/manifests/*
rm -rf /var/lib/etcd
rm -rf /var/lib/kubelet/*
rm -rf /etc/cni/net.d
systemctl start kubelet

# This removes the node’s control-plane components and local kubelet state.
# Then run in luke, worker dont need certificate
kubeadm token create --print-join-command

# Now back to padme, reconfigure as worker, 
kubeadm join <cp-ip>:6443 --token <token> \
  --discovery-token-ca-cert-hash sha256:<hash>

# OPTIONAL: Check
containerd --version
kubelet --version
kubeadm version
kubectl version --client
runc --version 

# use crictl for troubleshooting
crictl --version
kube-vip

sudo rm -rf ~/.kube

# use CNI plugin (like Calico, Cilium, or Flannel). Calico is recommended for "network policy capabilities" 
# Without it, pods cannot communicate, and nodes will remain `NotReady`.
# You apply the Calico `DaemonSet` manifest once to the cluster (usually on the control-plane).
sh scripts/install-calico.sh
```

### Check this kubeadm-scripts

`git clone https://github.com/techiescamp/kubeadm-scripts`

---

## For LEIA, convert from worker to control-plane (see W7D4)

```bash
# Install the CRI troubleshooting tool
/k8s-lab/scripts/setup/install-crictl.sh

# Execute from luke or han
kubectl cordon leia
kubectl drain leia --ignore-daemonsets --delete-emptydir-data
kubectl delete node leia

# full reset
sudo kubeadm reset -f
systemctl stop kubelet
sudo rm -rf /etc/kubernetes /var/lib/etcd /var/lib/kubelet /var/lib/cni /etc/cni/net.d
sudo systemctl restart containerd kubelet


# Then run in luke or han whereever the VIP is, control-plane requires certificate key
kubeadm token create --print-join-command \
  --certificate-key $(kubeadm init phase upload-certs --upload-certs | tail -n 1)

# Now back to leia, reconfigure as control-plane, 
kubeadm join <cp-ip>:6443 --token <token> \
  --discovery-token-ca-cert-hash sha256:<hash> \
  --control-plane \
  --certificate-key <key>


# Check leia can connect
nc -vz 10.1.1.15 6443
nc -vz 10.1.1.10 2379
nc -vz 10.1.1.10 2380
curl -k https://10.1.1.15:6443/readyz

# 
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

```bash
# kube-vip setup found W7D5/lab0.md

# Identify latest stable version
curl -sL https://api.github.com/repos/kube-vip/kube-vip/releases | jq -r ".[0].name"
    v1.2.1

     sudo ctr image pull ghcr.io/kube-vip/kube-vip:v1.2.1

     ping k8s-api.lab
     ip addr show wlp3s0 | grep 10.1.1.15

     kubectl get pods -n kube-system | grep vip

# generate the static pods
ip addr show

export INTERFACE=wlp3s0
export VIP=10.1.1.15
VERSION=v1.2.1

sudo ctr run --rm --net-host \
  ghcr.io/kube-vip/kube-vip:${VERSION} \
  vip \
  /kube-vip manifest pod \
    --interface ${INTERFACE} \
    --address ${VIP} \
    --controlplane \
    --services \
    --arp \
    --leaderElection \
  | sudo tee /etc/kubernetes/manifests/kube-vip.yaml      

kubectl get pods -n kube-system | grep vip  
```

---

## Issues

```bash

# ISSUE: Stale membership, etcd still thinks padme is control-plane
han:~# sudo etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/peer.crt \
  --key=/etc/kubernetes/pki/etcd/peer.key \
  member list

  Output:

     28d11f179153848, started, han, https://10.1.1.11:2380, https://10.1.1.11:2379, false
     7776008a92ec9519, started, padme, https://10.1.1.14:2380, https://10.1.1.14:2379, false
     a6a292fe93a0085d, started, luke, https://10.1.1.10:2380, https://10.1.1.10:2379, false

# So verify, cluster health first
sudo etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/peer.crt \
  --key=/etc/kubernetes/pki/etcd/peer.key \
  endpoint health --cluster

  Output:

     {"level":"warn","ts":"2026-07-26T19:08:04.528474+1000","logger":"client","caller":"v3@v3.6.5/retry_interceptor.go:65","msg":"retrying of unary invoker failed","target":"etcd-endpoints://0xc0002f85a0/10.1.1.14:2379","method":"/etcdserverpb.KV/Range","attempt":0,"error":"rpc error: code = DeadlineExceeded desc = latest balancer error: connection error: desc = \"transport: Error while dialing: dial tcp 10.1.1.14:2379: connect: connection refused\""}
     https://10.1.1.11:2379 is healthy: successfully committed proposal: took = 14.347273ms
     https://10.1.1.10:2379 is healthy: successfully committed proposal: took = 56.905557ms
     https://10.1.1.14:2379 is unhealthy: failed to commit proposal: context deadline exceeded
     Error: unhealthy cluster

## Why this happened
- When you demoted padme from a control plane to a worker, kubeadm reset removed the local etcd instance from padme, but it does not automatically remove the member from the existing etcd cluster.
- You have to remove the old etcd member manually.

# Remove the stale member: 7776008a92ec9519
sudo etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/peer.crt \
  --key=/etc/kubernetes/pki/etcd/peer.key \
  member remove 7776008a92ec9519

# then Verify
sudo etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/peer.crt \
  --key=/etc/kubernetes/pki/etcd/peer.key \
  member list

  Output

  28d11f179153848, started, han, https://10.1.1.11:2380, https://10.1.1.11:2379, false
  a6a292fe93a0085d, started, luke, https://10.1.1.10:2380, https://10.1.1.10:2379, false
  
