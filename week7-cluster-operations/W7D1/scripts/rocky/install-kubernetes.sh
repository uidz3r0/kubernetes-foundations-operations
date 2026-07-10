#!/bin/bash

set -e

if [ ! -f /etc/yum.repos.d/kubernetes.repo ]; then
    echo "Kubernetes repository not configured."
    echo "Please complete Step 5 in the README."
    exit 1
fi

echo "Installing Kubernetes packages..."

sudo dnf install -y \
kubelet \
kubeadm \
kubectl

echo "Installing versionlock plugin..."

sudo dnf install -y 'dnf-command(versionlock)'

echo "Locking Kubernetes package versions..."

sudo dnf versionlock add \
containerd \
kubelet \
kubeadm \
kubectl

sudo systemctl enable kubelet

echo "Done."