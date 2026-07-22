# Lab 5 — HA Control Plane Upgrade

## Upgrade first control plane

Drain

```
kubectl drain luke \
--ignore-daemonsets
```

Upgrade kubeadm

```
sudo dnf upgrade kubeadm
```

Apply

```
sudo kubeadm upgrade apply
```

Upgrade kubelet

Restart

```
sudo systemctl restart kubelet
```

Uncordon

```
kubectl uncordon luke
```

Repeat for

- han
- padme

---

Verify

```
kubectl get nodes
```

Questions

1. Why are HA control planes upgraded one at a time?
2. Why shouldn't all control planes be offline simultaneously?

## Answers

- HA control planes are upgraded one at a time to preserve quorum and keep the API available.
- If all control planes are offline simultaneously, the cluster becomes unavailable and may lose quorum.