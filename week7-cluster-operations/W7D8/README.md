# W7D8 — Kubernetes Upgrades, Certificates & Troubleshooting

## Overview

Production Kubernetes clusters require regular maintenance.

This lab covers:

- Kubernetes PKI
- kubeadm certificate management
- Version compatibility
- Cluster upgrades
- HA upgrade procedures
- Worker upgrades
- Verification
- Troubleshooting

---

## Learning Objectives

By the end of today you will understand:

- Kubernetes PKI architecture
- API Server certificates
- kubelet certificates
- CA hierarchy
- kubeadm certs commands
- Certificate renewal
- Upgrade planning
- Version skew policy
- HA upgrades
- Worker upgrades
- Upgrade validation
- Recovery techniques

---

## Labs

1. PKI & Kubernetes Certificates
2. Inspecting & Renewing Certificates
3. Version Skew Policy
4. Planning a Cluster Upgrade
5. Upgrading an HA Control Plane
6. Upgrading Worker Nodes
7. Post-Upgrade Verification
8. Troubleshooting & Rollback

---

## Lab Environment

Cluster:

- `luke` — Control Plane
- `han` — Control Plane
- `leia` — Worker

This lab assumes a kubeadm-managed HA cluster with kube-vip and Calico. Use the helper scripts in `./scripts/` to reduce manual command errors and keep the upgrade workflow consistent.

## Recommended Workflow

1. Inspect certificates and expiration with `./scripts/check-certificates.sh`
2. Renew kubeadm-managed certs when needed using `./scripts/renew-certificates.sh`
3. Verify version compatibility with `./scripts/check-version-skew.sh`
4. Run pre-upgrade checks using `./scripts/pre-upgrade-check.sh`
5. Upgrade control plane nodes one at a time
6. Upgrade worker nodes after control plane success
7. Validate the cluster post-upgrade with `./scripts/verify-upgrade.sh`
8. Capture before/after health state using `./scripts/cluster-health-report.sh`

---

## Suggested Utility Scripts

To match the rest of your Week 7 labs, I'd recommend implementing these helper scripts:

- `check-certificates.sh` — wraps `kubeadm certs check-expiration` with formatted output.
- `renew-certificates.sh` — renews certificates (optionally `all` or a specific cert) and restarts `kubelet` when appropriate.
- `check-version-skew.sh` — reports versions of `kubectl`, `kubeadm`, `kubelet`, and the cluster, highlighting unsupported version combinations.
- `pre-upgrade-check.sh` — validates node readiness, control plane health, running Pods, available disk space, and reminds you to back up etcd before running `kubeadm upgrade plan`.
- `verify-upgrade.sh` — confirms node versions, Ready status, control plane Pods, CoreDNS, kube-vip, and performs a simple workload test.
- `cluster-health-report.sh` — generates a consolidated health report (nodes, Pods, component status, certificate expiration, versions) suitable for recording before and after an upgrade.

This README and the `./scripts/` helpers provide a strong capstone for Week 7 and closely reflect real production maintenance workflows used with kubeadm-managed HA clusters.


---

Estimated time:

4–6 hours

Difficulty:

Intermediate → Advanced

---

Checks I'd include

1. Node health

    `kubectl get nodes`

    Ensure all nodes are Ready.

2. System Pods

    `kubectl get pods -n kube-system`

    Fail if anything is in:

    ```text
    CrashLoopBackOff
    Error
    Pending
    ImagePullBackOff
    ```

3. CNI

    For your lab:

    `kubectl get pods -n calico-system`

4. kube-vip

    `kubectl get pods -n kube-system | grep vip`

    Since you're running an HA control plane with kube-vip, this is important.

5. DNS

    ```bash
    kubectl run dns-test \
    --rm -it \
    --restart=Never \
    --image=busybox \
    -- nslookup kubernetes.default
    ```

    This validates CoreDNS functionality.

6. Scheduling

    ```bash
    kubectl run nginx-test \
    --image=nginx \
    --restart=Never
    ```

    Wait until it's Ready, then delete it.

7. Certificates

    `kubeadm certs check-expiration`

    Ensure renewals were successful if they were part of the maintenance.

8. Version consistency

    `kubectl get nodes -o wide`

    Confirm the expected kubelet versions across the cluster.

9. Cluster information

    `kubectl cluster-info`

    Quickly verifies the control plane and key services are reachable.

10. Optional: Recent warnings

    ```bash
    kubectl get events -A \
    --sort-by=.metadata.creationTimestamp | tail -30
    ```

    Useful for spotting issues that appeared immediately after the upgrade.

---

## Rollback scripts (quick reference)

The `./scripts/` folder includes helpers for recovering from problematic upgrades:

- `scripts/restore-etcd.sh /path/to/snapshot.db` — restores an etcd snapshot interactively. Ensure you run it as root and that `etcdctl` is installed. Example:

```bash
sudo ./scripts/restore-etcd.sh /tmp/etcd-snap.db
```

- `scripts/revert-packages.sh [--dry-run] <kubeadm-version> <kubelet-version> <kubectl-version>` — reinstalls specified package versions. Use `--dry-run` to preview commands before executing. Example:

```bash
sudo ./scripts/revert-packages.sh --dry-run 1.25.7-00 1.25.7-00 1.25.7-00
sudo ./scripts/revert-packages.sh 1.25.7-00 1.25.7-00 1.25.7-00
```

Notes:

- Always keep etcd snapshots off-node and test restore procedures in a disposable environment before relying on them in production.
- The `revert-packages.sh` script supports Debian/Ubuntu (`apt`) and RHEL-family (`dnf`/`yum`) package managers but relies on requested package versions being available in your configured repositories.