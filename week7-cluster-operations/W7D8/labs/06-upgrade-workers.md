# Lab 6 — Worker Upgrade

Drain

```
kubectl drain leia \
--ignore-daemonsets
```

Upgrade packages

Restart kubelet

```
sudo systemctl restart kubelet
```

Uncordon

```
kubectl uncordon leia
```

---

Verify

```
kubectl get nodes
```

Questions

1. Why upgrade workers after the control plane?

## Answers

- Workers are upgraded after the control plane because the control plane must be on a supported version first and able to manage the upgraded workers.