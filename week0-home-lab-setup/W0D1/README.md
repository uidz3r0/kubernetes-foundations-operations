# Week 0 Day 1
# Production Kubernetes Lab Preparation

Today is about preparing Linux servers before Kubernetes installation.

Nodes

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

## Objectives

Prepare every server for Kubernetes.

Learn:

- Hostnames
- Static IP verification
- DNS
- SSH
- Time synchronization
- Kernel modules
- sysctl
- Swap
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
