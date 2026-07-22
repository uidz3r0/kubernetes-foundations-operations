# W7D8 — Kubernetes Upgrades, Certificates & Troubleshooting

## Objective

Learn how production Kubernetes clusters are maintained over time.

Topics covered:

- Kubernetes PKI
- kubeadm certificate management
- Certificate expiration
- Certificate renewal
- kubeadm upgrade workflow
- Control Plane upgrades
- Worker upgrades
- kubelet upgrades
- kubectl upgrades
- Version Skew Policy
- Upgrade verification
- Rollback considerations
- Post-upgrade health checks

---

# Lab Environment

Cluster:

| Node | Role |
|------|------|
| luke | Control Plane |
| han | Control Plane |
| leia | Worker |

Current Version:

```

kubectl get nodes

```

---

# Part 1 — Understand Kubernetes Certificates

## Why certificates exist

Every Kubernetes component communicates securely using TLS.

Examples:

- kubectl → API Server
- kubelet → API Server
- API Server → etcd
- Controller Manager → API Server
- Scheduler → API Server

These identities are verified using certificates.

---

## Main certificate locations

```

/etc/kubernetes/pki

```

View certificates

```

ls -lh /etc/kubernetes/pki

```

Example

```

ca.crt
ca.key
apiserver.crt
apiserver.key
front-proxy-ca.crt
etcd/

```

---

## Explore certificates

Example

```

openssl x509 \
-in /etc/kubernetes/pki/apiserver.crt \
-noout \
-text

```

Useful fields

- Subject
- Issuer
- SAN
- Valid From
- Valid Until

---

# Part 2 — Check Certificate Expiration

kubeadm provides a built-in checker.

```

sudo kubeadm certs check-expiration

```

Example output

```

CERTIFICATE                EXPIRES
admin.conf                 364d
apiserver                  364d
controller-manager.conf    364d
scheduler.conf             364d
etcd-server                364d

```

Questions

- Which certificates expire first?
- Which certificates are externally managed?
- How long is the default lifetime?

---

# Part 3 — Renew Certificates

Renew all certificates

```

sudo kubeadm certs renew all

```

Or renew individually

```

sudo kubeadm certs renew apiserver

```

Verify

```

sudo kubeadm certs check-expiration

```

---

## Restart Static Pods

Certificates are renewed on disk.

Static Pods must reload them.

Restart kubelet

```

sudo systemctl restart kubelet

```

Watch

```

kubectl get pods -n kube-system

```

---

# Part 4 — kubeadm Upgrade Workflow

Upgrades always follow this order

```

Backup
↓

Upgrade kubeadm

↓

Plan upgrade

↓

Upgrade Control Plane

↓

Upgrade kubelet

↓

Upgrade kubectl

↓

Upgrade Workers

```

Never skip this sequence.

---

# Part 5 — Check Available Upgrades

```

sudo kubeadm upgrade plan

```

Example

```

Components that must be upgraded manually:

kubeadm

Components that will be upgraded:

kube-apiserver
controller-manager
scheduler
CoreDNS
kube-proxy

```

Review:

- current version
- target version
- supported versions

---

# Part 6 — Version Skew Policy

Understand supported version differences.

Control Plane components

- Same version

Workers

- Up to one minor version older

kubectl

- ±1 minor version from API Server

Examples

Good

```

API Server 1.34
kubectl   1.35

```

Good

```

API Server 1.34
Worker     1.33

```

Bad

```

API Server 1.34
Worker     1.31

```

---

# Part 7 — Upgrade Control Plane

## Step 1

Upgrade kubeadm package.

Rocky

```

sudo dnf upgrade kubeadm

```

Ubuntu

```

sudo apt update
sudo apt install kubeadm

```

Verify

```

kubeadm version

```

---

## Step 2

Apply upgrade

```

sudo kubeadm upgrade apply

```

Confirm

```

yes

```

Observe

- API Server
- Controller Manager
- Scheduler
- CoreDNS
- kube-proxy

---

## Step 3

Upgrade kubelet

Rocky

```

sudo dnf upgrade kubelet

```

Ubuntu

```

sudo apt install kubelet

```

Restart

```

sudo systemctl daemon-reload
sudo systemctl restart kubelet

```

---

## Step 4

Upgrade kubectl

Rocky

```

sudo dnf upgrade kubectl

```

Ubuntu

```

sudo apt install kubectl

```

Verify

```

kubectl version

```

---

# Part 8 — Upgrade Additional Control Plane

Repeat for each additional control plane.

Drain

```

kubectl drain han \
--ignore-daemonsets

```

Upgrade

```

kubeadm upgrade node

```

Upgrade kubelet

Restart kubelet

Uncordon

```

kubectl uncordon han

```

Repeat for every control plane node.

---

# Part 9 — Upgrade Worker Nodes

Drain worker

```

kubectl drain leia \
--ignore-daemonsets

```

Upgrade kubeadm

```

sudo apt install kubeadm

```

Upgrade node

```

sudo kubeadm upgrade node

```

Upgrade kubelet

```

sudo apt install kubelet

```

Restart

```

sudo systemctl restart kubelet

```

Uncordon

```

kubectl uncordon leia

```

---

# Part 10 — Verify Cluster Version

```

kubectl get nodes

```

```

kubectl version

```

```

kubectl get componentstatuses

```

(Optional on older clusters)

```

kubectl get pods -A

```

```

kubectl get nodes -o wide

```

---

# Part 11 — Upgrade Verification

Confirm

- Nodes Ready
- Pods Running
- CoreDNS Healthy
- kube-proxy Healthy
- API Server Healthy
- etcd Healthy

Useful commands

```

kubectl get events -A

```

```

kubectl get pods -A

```

```

kubectl top nodes

```

```

kubectl cluster-info

```

---

# Part 12 — Post-upgrade Health Checks

Check API

```

kubectl cluster-info

```

Check Nodes

```

kubectl get nodes

```

Check workloads

```

kubectl get pods -A

```

Check DNS

```

kubectl run dns-test \
--image=busybox \
-it --rm -- nslookup kubernetes.default

```

Check etcd health

```

ETCDCTL_API=3 etcdctl endpoint health

```

---

# Part 13 — Rollback Considerations

Unlike many applications, Kubernetes upgrades are **not designed to be rolled back in-place**.

Best practice:

- Take an etcd snapshot before upgrading.
- Backup `/etc/kubernetes/`.
- Upgrade one node at a time.
- Validate workloads after each step.

If a serious issue occurs:

1. Stop the upgrade.
2. Restore etcd from snapshot if required.
3. Restore the control plane configuration.
4. Rejoin or rebuild affected nodes if necessary.

---

# Part 14 — Troubleshooting

## Certificates

```

sudo kubeadm certs check-expiration

```

---

## kubelet

```

sudo systemctl status kubelet

```

```

journalctl -u kubelet -f

```

---

## Static Pods

```

ls /etc/kubernetes/manifests

```

---

## API Server

```

kubectl cluster-info

```

---

## Node Health

```

kubectl get nodes

```

---

## Events

```

kubectl get events -A

```

---

## Pods

```

kubectl get pods -A

```

---

# Summary

Today you learned:

- Kubernetes PKI
- Certificate expiration
- Certificate renewal
- kubeadm upgrade workflow
- Version skew policy
- Control Plane upgrades
- Worker upgrades
- kubelet upgrades
- kubectl upgrades
- Cluster verification
- Health checks
- Rollback planning
- Production troubleshooting

Congratulations!

You have now completed **Week 7 – Kubernetes Cluster Operations**.

Next Week:

**Week 8 – Kubernetes Design, Troubleshooting & CKA Preparation**

- Scheduling scenarios
- Storage scenarios
- Networking scenarios
- Security scenarios
- Real-world troubleshooting
- Timed CKA exercises
- Mock exams

