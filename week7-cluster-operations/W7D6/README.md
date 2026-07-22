# W7D6 — Backup & Recovery

## Goal

Learn how to protect a Kubernetes control plane by creating and restoring etcd snapshots.

This lab covers:

- Understanding etcd
- Creating snapshots
- Verifying backups
- Restoring snapshots
- Updating kubeadm static manifests
- Validating cluster recovery

---

## Prerequisites

Complete:

- W7D1
- W7D2
- W7D3
- W7D4
- W7D5

A healthy multi-control-plane cluster is running.

---

## What You'll Learn

- Why etcd backups are important
- kubeadm static pod architecture
- etcdctl
- Snapshot creation
- Snapshot verification
- Snapshot restoration
- Disaster recovery workflow

---

## Step 1

Verify cluster health.

```

scripts/common/cluster-health.sh

```

---

## Step 2

Create an etcd snapshot.

```

scripts/backup/etcd-backup.sh

```

---

## Step 3

Verify the snapshot.

```

scripts/backup/verify-backup.sh

```

---

## Step 4

List available backups.

```

scripts/backup/list-snapshots.sh

```

---

## Step 5

Simulate a disaster.

Delete a namespace or deployment.

Do **NOT** delete the etcd database.

---

## Step 6

Restore the snapshot.

```

scripts/restore/etcd-restore.sh /k8s-lab/backups/etcd-YYYY-MM-DD-HHMM.db

```

---

## Step 7

Update the kubeadm static manifest.

```

scripts/restore/update-etcd-manifest.sh

```

---

## Step 8

Verify the cluster.

```

scripts/restore/verify-restore.sh

```

---

## Expected Outcome

- etcd snapshot created
- Snapshot verified
- Cluster restored
- API Server healthy
- Workloads recovered

---

Why this structure?

I recommend not automating the modification of `/etc/kubernetes/manifests/etcd.yaml`. In production, editing the static pod manifest is a deliberate, high-impact action that should be performed and reviewed manually. This aligns with your earlier preference to avoid destructive or opaque automation (such as automatically deleting `/etc/kubernetes` or `/var/lib/etcd`). The scripts automate snapshot creation and restoration, while the manifest update remains an explicit manual step so you can clearly see and understand the changes.

---

## Install etcdctl


```bash
which etcdctl
command -v etcdctl

# Check the server version:
kubectl -n kube-system describe pod etcd-$(hostname) | grep Image:
    Image:         registry.k8s.io/etcd:3.6.5-0
```

### Then download that version (run on all `control-plane`):

```bash
ETCD_VERSION=v3.6.5

wget https://github.com/etcd-io/etcd/releases/download/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz

tar xzf etcd-${ETCD_VERSION}-linux-amd64.tar.gz

sudo cp etcd-${ETCD_VERSION}-linux-amd64/etcdctl /usr/bin/
sudo cp etcd-${ETCD_VERSION}-linux-amd64/etcdutl /usr/bin/

etcdctl version
```

---

> You do NOT run `update-etcd-manifest.sh` when creating a backup.
> You only perform that step when you're doing a real restore of the cluster.

## Why?

When you run:

`etcdutl snapshot restore snapshot.db --data-dir=/var/lib/etcd-restored`

It simply creates a new etcd data directory: `/var/lib/etcd-restored`

Your running `etcd` is still using: `/var/lib/etcd`

You can confirm this by looking at the static pod manifest: `/etc/kubernetes/manifests/etcd.yaml`

## When do you update the manifest?

Only after you've decided:

> "I want this restored snapshot to become the live etcd database."

## Why does this work?

Remember from W7D2:

kubeadm runs the control plane as static pods.

The kubelet continuously watches:

`/etc/kubernetes/manifests/`

Whenever you save a change to `etcd.yaml`, the kubelet notices it automatically.

The sequence is:

1. kubelet sees etcd.yaml changed.
2. kubelet stops the current etcd container.
3. kubelet starts a new etcd container using the updated manifest.
4. The new etcd starts with /var/lib/etcd-restored.

No `kubectl` command is involved—the kubelet manages static pods directly.


## Production example

Imagine someone accidentally deletes all namespaces or corrupts the etcd database.

You would:

1. Stop the API server (or accept it will become unavailable).
2. Restore yesterday's snapshot:

   ```bash
   etcdutl snapshot restore backup.db \
       --data-dir=/var/lib/etcd-restored
   ```

3. Update etcd.yaml to use the restored directory.
4. kubelet restarts etcd.
5. The API server reconnects to the restored etcd.
6. The cluster state returns to what it was when the snapshot was taken.

---

## Why I suggested splitting W7D6

After today's HA troubleshooting, I think there's a clearer separation:

### W7D6 — Backup

- Verify cluster health
- Create snapshot
- Verify snapshot
- Restore snapshot to a `temporary directory`
- Inspect the restored files
- `Do not modify the running cluster`

### W7D7 (or W7D8) — Disaster Recovery

- Simulate an etcd failure
- Restore the snapshot
- Update `etcd.yaml`
- Let kubelet recreate the static pod
- Wait for the API server to recover
- Validate that the cluster has been restored

That mirrors how production teams operate: backups are routine and non-disruptive, while changing `etcd.yaml` is a deliberate recovery action performed only when you intend to replace the live cluster state.