#!/usr/bin/env bash

# revert-packages.sh
# Reinstall specific kubeadm/kubelet/kubectl versions to roll back an upgrade.
# Usage: sudo ./revert-packages.sh <kubeadm-version> <kubelet-version> <kubectl-version>

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root (or via sudo)."
  exit 1
fi

DRY_RUN=0
if [[ ${1:-} == "--dry-run" ]]; then
  DRY_RUN=1
  shift
fi

if [[ $# -ne 3 ]]; then
  cat <<EOF
Usage: $0 <kubeadm-version> <kubelet-version> <kubectl-version>
Example: $0 1.25.7-00 1.25.7-00 1.25.7-00

The exact package version strings depend on your distro packaging (apt/dnf). For Debian/Ubuntu, include the -00 suffix when required by the repo.
EOF
  exit 1
fi

KUBEADM_VER="$1"
KUBELET_VER="$2"
KUBECTL_VER="$3"

# Detect package manager
if command -v apt-get >/dev/null 2>&1; then
  PKG_MGR="apt"
elif command -v dnf >/dev/null 2>&1; then
  PKG_MGR="dnf"
elif command -v yum >/dev/null 2>&1; then
  PKG_MGR="yum"
else
  echo "Unsupported package manager. Please run package installs manually."
  exit 1
fi

echo "Package manager detected: $PKG_MGR"
if [[ $DRY_RUN -eq 1 ]]; then
  echo "DRY RUN: showing package manager commands that would be executed"
  if [[ "$PKG_MGR" == "apt" ]]; then
    echo "apt-get update"
    echo "DEBIAN_FRONTEND=noninteractive apt-get install -y --allow-downgrades kubeadm=${KUBEADM_VER} kubelet=${KUBELET_VER} kubectl=${KUBECTL_VER}"
    echo "(simulation) apt-get -s install --allow-downgrades kubeadm=${KUBEADM_VER} kubelet=${KUBELET_VER} kubectl=${KUBECTL_VER}"
  else
    echo "$PKG_MGR install --assumeno kubeadm-${KUBEADM_VER} kubelet-${KUBELET_VER} kubectl-${KUBECTL_VER}"
  fi
  echo "Dry-run complete. No changes made."
  exit 0
fi

read -rp "Proceed to reinstall packages (this will restart kubelet)? (y/N): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "Aborted by user."
  exit 0
fi

if [[ "$PKG_MGR" == "apt" ]]; then
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y --allow-downgrades \
    kubeadm=${KUBEADM_VER} kubelet=${KUBELET_VER} kubectl=${KUBECTL_VER}
  systemctl daemon-reload
  systemctl restart kubelet
elif [[ "$PKG_MGR" == "dnf" || "$PKG_MGR" == "yum" ]]; then
  # For RHEL-based systems, package naming/versioning may differ; adjust as needed
  $PKG_MGR install -y kubeadm-${KUBEADM_VER} kubelet-${KUBELET_VER} kubectl-${KUBECTL_VER} || {
    echo "Package install failed. Check available package versions with your package manager."
    exit 1
  }
  systemctl daemon-reload
  systemctl restart kubelet
fi

echo "Reinstall complete. Verify node status with 'kubectl get nodes' and check control plane logs if needed."