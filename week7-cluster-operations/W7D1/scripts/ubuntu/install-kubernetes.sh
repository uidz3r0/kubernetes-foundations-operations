#!/bin/bash

set -e

if [ ! -f /etc/apt/sources.list.d/kubernetes.list ]; then
    echo "Kubernetes repository not configured."
    echo "Please complete Step 5 in the README."
    exit 1
fi

echo "Installing kubelet, kubeadm and kubectl..."

sudo apt install -y \
kubelet \
kubeadm \
kubectl

echo "Holding package versions..."

sudo apt-mark hold \
containerd \
kubelet \
kubeadm \
kubectl

sudo systemctl enable kubelet

echo "Done."