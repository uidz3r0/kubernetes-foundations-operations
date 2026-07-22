# Lab 3 — Version Skew

## Objective

Understand supported Kubernetes versions.

---

## Check versions

```
kubectl version

kubeadm version

kubelet --version
```

---

## Supported Skew

Control Plane

```
v1.35
```

Worker

```
v1.35
v1.34
```

kubectl

```
v1.34
v1.35
v1.36
```

---

Read

Official Version Skew Policy

---

Questions

1. Can kubelet be newer than kube-apiserver?
2. Can kubectl be one version newer?
3. Why?

## Answers

- kubelet should not be newer than kube-apiserver beyond the supported skew; the control plane must remain compatible with worker versions.
- kubectl can usually be one minor version newer than the API server.
- kubectl is a client tool with broader backward compatibility, while kubelet and control plane components have stricter supported skew rules.

---

## 1. Core Rules (Relative to kube-apiserver)

The API server is the anchor; all other versions are evaluated against it.

- Control Plane Components: The kube-controller-manager, kube-scheduler, and cloud-controller-manager must not be newer than the API server. They can be up to one minor version older. 
- Kubelet: The kubelet must never be newer than the API server.  It can be up to three minor versions older (for Kubernetes 1.25+). 
- Kubectl: The client tool is flexible and can be one minor version older or newer than the API server. 
- HA Clusters: In High Availability setups, all kube-apiserver instances must be within one minor version of each other. 

## 2. Impact on Upgrades

This policy enforces a strict sequential upgrade path:

- One Minor Version at a Time: You cannot skip versions (e.g., jumping from 1.34 to 1.36 is blocked). You must upgrade 1.34 → 1.35 → 1.36. 
- Order of Operations: You must upgrade the control plane first, then the worker nodes.  If workers fall three versions behind, the control plane is blocked from upgrading further until nodes are patched. 
- Certificate Renewal Context: While certificate renewal (kubeadm certs renew) does not change component versions, performing it on a cluster that is already at the limit of its version skew (e.g., API server v1.36, Kubelet v1.33) carries risk. If the renewal requires a restart that temporarily breaks communication, an already fragile version compatibility window offers less margin for error during recovery.

## 3. Kubeadm Specifics

When using kubeadm, the tool itself enforces these checks:

- Kubeadm Version: The kubeadm binary should match the target Kubernetes version or be one version older. 
- Upgrade Validation: Running kubeadm upgrade plan explicitly checks these skew policies. If your nodes are too old relative to the target control plane version, the upgrade command will fail with a NodePoolMcVersionIncompatible error. 