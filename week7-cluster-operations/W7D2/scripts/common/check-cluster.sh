#!/bin/bash

echo
echo "===== Nodes ====="

kubectl get nodes -o wide

echo
echo "===== System Pods ====="

kubectl get pods -A

echo
echo "===== Cluster Info ====="

kubectl cluster-info