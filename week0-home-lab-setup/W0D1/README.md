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
