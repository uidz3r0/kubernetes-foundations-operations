# Lab 9 — Rollback Considerations

## Purpose

Short, practical checklist and commands for rolling back or recovering a kubeadm-managed cluster after a problematic upgrade.

---

## 1 — Before the upgrade (must do)

- Take an etcd snapshot and copy it off-node.
  - Example:

```bash
sudo ETCDCTL_API=3 etcdctl snapshot save /tmp/etcd-snap.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt \
  --key=/etc/kubernetes/pki/etcd/healthcheck-client.key
```

- Archive critical files and manifests:
  - `/etc/kubernetes/manifests` (static pods)
  - `/etc/kubernetes/pki` (certs)
  - `~/.kube/config` and `admin.conf`
  - `kubectl get all -A -o yaml > pre-upgrade-all.yaml`

- Record package versions:

```bash
kubeadm version && kubelet --version && kubectl version --client
```

- Optional: take VM or disk snapshots for fast full-system rollback.

---

## 2 — Quick assessment when something goes wrong

- Check node and pod status:

```bash
kubectl get nodes
kubectl get pods -A
kubectl get events -A --sort-by=.metadata.creationTimestamp | tail -30
```

- Inspect kubelet and control-plane logs:

```bash
sudo journalctl -u kubelet -n 200 --no-pager
sudo journalctl -u kubelet --since "1 hour ago"
# static pod logs via container runtime (crictl/podman/docker)
```

- Check certificate expiration and rotation state:

```bash
sudo kubeadm certs check-expiration
```

---

## 3 — Typical rollback paths

- Worker node failure:
  - Drain (if reachable), reinstall or downgrade `kubelet`/`kubectl`, restart `kubelet`, uncordon.

- Control plane instability but etcd intact:
  - Roll back package versions on control plane nodes to the recorded pre-upgrade versions.
  - Restart `kubelet` and verify static pods recreate control plane components.

- Control plane corrupted (etcd inconsistent or API unavailable):
  - Stop control plane static pods on all control-plane nodes (remove/rename manifests in `/etc/kubernetes/manifests`).
  - Restore etcd from snapshot (see steps below).
  - Restore manifests and restart `kubelet` so static pods recreate the control plane.

---

## 4 — Restoring etcd (high-level)

1. Stop control plane static pods (move manifests out of `/etc/kubernetes/manifests`).
2. On the node holding the etcd data directory, run `etcdctl snapshot restore` specifying a new data-dir.
3. Update the etcd systemd/static pod manifest to point to the restored data-dir (if needed).
4. Start control plane static pods by restoring the manifest files and wait for the API to come up.
5. Verify cluster objects and node health.

Refer to the `etcdctl` docs and your cluster's etcd topology before restoring.

---

## 5 — Certs and CA problems

- CA rotation is destructive. If CA or certs are broken, prefer to restore `/etc/kubernetes/pki` from backup.
- Replacing the CA requires reissuing and distributing new certs to every component — treat as a full rebuild unless you have automated tooling.

---

## 6 — Practical mitigation and automation

- Keep `scripts/restore-etcd.sh` and `scripts/revert-packages.sh` in the repo for your lab (examples below).
- Use VM snapshots for a quick full-system revert when available.
- Test the restore procedure in a disposable environment (Phase 2 / lab kind cluster) before relying on it in production.

---

## 7 — Example quick helper scripts (sketches)

- `scripts/revert-packages.sh` (example idea): downgrade kubeadm/kubelet/kubectl to recorded versions and restart kubelet.
- `scripts/restore-etcd.sh` (example idea): verify snapshot exists, stop static pods, run `etcdctl snapshot restore`, and restore manifests.

---

## 8 — Cautions

- Downgrades are not guaranteed: schema changes and feature migrations can make downgrades unsafe.
- Restoring from a snapshot rewrites cluster state to the snapshot point — objects created after the snapshot will be lost unless reconciled.
- Always practice and document the full restore path before an upgrade.

---

If you want, I can create `scripts/restore-etcd.sh` and `scripts/revert-packages.sh` with concrete commands tailored to your distro (Debian/Ubuntu or RHEL/CentOS).