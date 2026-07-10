#!/bin/bash

set -e

echo "Updating packages..."

sudo dnf update -y

if ! command -v containerd >/dev/null 2>&1; then
    echo "Installing containerd..."
    # install package
    sudo dnf install -y containerd
else
    echo "containerd already installed."
fi

sudo mkdir -p /etc/containerd

containerd config default | sudo tee /etc/containerd/config.toml >/dev/null

sudo sed -i \
's/SystemdCgroup = false/SystemdCgroup = true/' \
/etc/containerd/config.toml

sudo systemctl enable containerd

sudo systemctl restart containerd

echo "Done."