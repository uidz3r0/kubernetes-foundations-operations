#!/bin/bash

echo "===== containerd ====="
containerd --version
systemctl is-active containerd

echo
echo "===== kubelet ====="
kubelet --version
systemctl is-enabled kubelet

echo
echo "===== CRI ====="
crictl info >/dev/null && echo "CRI OK" || echo "crictl not installed"

echo
echo "===== cgroup ====="
grep SystemdCgroup /etc/containerd/config.toml

echo
echo "===== swap ====="
swapon --show

echo
echo "===== kernel modules ====="
lsmod | grep overlay
lsmod | grep br_netfilter

echo
echo "===== sysctl ====="
sysctl net.bridge.bridge-nf-call-iptables
sysctl net.ipv4.ip_forward

echo
echo "===== Versions ====="
kubeadm version
kubectl version --client