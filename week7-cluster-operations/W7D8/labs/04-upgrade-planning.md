# Lab 4 — Planning an Upgrade

## Objective

Perform pre-upgrade checks.

---

Cluster health

```
kubectl get nodes

kubectl get pods -A
```

---

Check etcd

```
kubectl get componentstatuses
```

(or use your health scripts)

---

Backup etcd

```
/k8s-lab/scripts/backup/verify-backup.sh
/k8s-lab/scripts/backup/etcd-backup.sh
```

---

Plan upgrade

```
sudo kubeadm upgrade plan
```

Example

```
Components that must be upgraded

kubeadm

kubelet

kubectl

control plane
```

---

Questions

1. Why should etcd always be backed up before upgrading?
2. Why should only one minor version be upgraded?

## Answers

- etcd should be backed up because it stores the cluster state and is the only reliable restore source if the upgrade fails.
- Only one minor version should be upgraded to stay within supported version skew and reduce the risk of compatibility problems.