#!/bin/bash

set -e

echo "Updating packages..."

sudo apt update

if ! command -v containerd >/dev/null 2>&1; then
    echo "Installing containerd..."
    # install package; runc is a dependency of containerd and will be installed automatically
    sudo apt install -y containerd 
else
    echo "containerd already installed."
fi

echo "Generating default configuration..."

sudo mkdir -p /etc/containerd

containerd config default | sudo tee /etc/containerd/config.toml >/dev/null

echo "Enabling SystemdCgroup..."

sudo sed -i \
's/SystemdCgroup = false/SystemdCgroup = true/' \
/etc/containerd/config.toml

echo "Starting containerd..."

sudo systemctl enable containerd

sudo systemctl restart containerd

echo "Done."