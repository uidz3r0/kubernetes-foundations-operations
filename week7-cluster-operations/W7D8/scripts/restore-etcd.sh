#!/usr/bin/env bash

# restore-etcd.sh
# Restores an etcd snapshot for a kubeadm-managed cluster.
# Usage: sudo ./restore-etcd.sh /path/to/snapshot.db

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root (or via sudo)."
  exit 1
fi

if [[ $# -ne 1 ]]; then
  cat <<EOF
Usage: $0 /path/to/snapshot.db

Notes:
- This script is an opinionated helper for lab use. Review and test it before using in production.
- If etcd in your cluster is configured with mTLS, set ETCDCTL_API=3 and ensure the variables
  ETCD_ENDPOINTS, ETCD_CACERT, ETCD_CERT, ETCD_KEY are exported in the environment.
EOF
  exit 1
fi

SNAPSHOT_PATH="$1"
if [[ ! -f "$SNAPSHOT_PATH" ]]; then
  echo "Snapshot file not found: $SNAPSHOT_PATH"
  exit 1
fi

ETCDCTL_BIN="${ETCDCTL_BIN:-etcdctl}"
if ! command -v "$ETCDCTL_BIN" >/dev/null 2>&1; then
  echo "$ETCDCTL_BIN not found in PATH. Install etcdctl or set ETCDCTL_BIN to the correct path."
  exit 1
fi

export ETCDCTL_API=3

# Build optional flags from env
ETCD_FLAGS=()
if [[ -n "${ETCD_ENDPOINTS:-}" ]]; then
  ETCD_FLAGS+=(--endpoints="$ETCD_ENDPOINTS")
fi
if [[ -n "${ETCD_CACERT:-}" ]]; then
  ETCD_FLAGS+=(--cacert="$ETCD_CACERT")
fi
if [[ -n "${ETCD_CERT:-}" ]]; then
  ETCD_FLAGS+=(--cert="$ETCD_CERT")
fi
if [[ -n "${ETCD_KEY:-}" ]]; then
  ETCD_FLAGS+=(--key="$ETCD_KEY")
fi

read -rp "This will stop control plane static pods and restore etcd from $SNAPSHOT_PATH. Continue? (y/N): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "Aborted by user."
  exit 0
fi

TS=$(date +%Y%m%d-%H%M%S)
ETCD_DATA_DIR="/var/lib/etcd"
BACKUP_ETCD_DIR="${ETCD_DATA_DIR}.backup.${TS}"
MANIFEST_DIR="/etc/kubernetes/manifests"
MANIFEST_BACKUP_DIR="${MANIFEST_DIR}.backup.${TS}"

echo "Backing up existing etcd data directory (if present) to $BACKUP_ETCD_DIR"
if [[ -d "$ETCD_DATA_DIR" ]]; then
  mv "$ETCD_DATA_DIR" "$BACKUP_ETCD_DIR"
fi

echo "Backing up control plane static manifests to $MANIFEST_BACKUP_DIR"
mkdir -p "$MANIFEST_BACKUP_DIR"
if compgen -G "$MANIFEST_DIR/*" >/dev/null; then
  mv $MANIFEST_DIR/* "$MANIFEST_BACKUP_DIR" || true
fi

echo "Restoring snapshot to $ETCD_DATA_DIR"
# Join flags into a string for execution
ETCDCTL_FLAGS="${ETCD_FLAGS[*]}"

# Note: etcdctl snapshot restore will create the specified data-dir
$ETCDCTL_BIN snapshot restore "$SNAPSHOT_PATH" --data-dir "$ETCD_DATA_DIR" $ETCDCTL_FLAGS

# Fix permissions (run as root, ensure ownership matches etcd user if present)
chown -R root:root "$ETCD_DATA_DIR" || true
# If an 'etcd' user exists, prefer that ownership
if id -u etcd >/dev/null 2>&1; then
  chown -R etcd:etcd "$ETCD_DATA_DIR" || true
fi

# Restore static manifests so kubelet recreates the control plane
if compgen -G "$MANIFEST_BACKUP_DIR/*" >/dev/null; then
  echo "Restoring static manifests"
  mv $MANIFEST_BACKUP_DIR/* $MANIFEST_DIR/ || true
fi

echo "Waiting for control plane to come up. Check logs if API does not become available."
sleep 5

# Attempt a basic health check (if kubectl available and kubeconfig present)
if command -v kubectl >/dev/null 2>&1; then
  echo "Waiting up to 120s for kube-apiserver to respond to 'kubectl get nodes'"
  for i in {1..24}; do
    if kubectl get nodes >/dev/null 2>&1; then
      echo "API is responding."
      kubectl get nodes
      exit 0
    fi
    sleep 5
  done
  echo "Timed out waiting for API. Inspect kubelet and static pod logs."
else
  echo "kubectl not found; inspect control plane logs manually."
fi

echo "Restore script finished. If API did not come up, check kubelet and static pod logs and verify etcd data directory."