# Notes

## kubeadm init

Creates:

- certificates
- kubeconfigs
- static pod manifests
- etcd
- API Server
- Scheduler
- Controller Manager

Location:

```
/etc/kubernetes/
```

Static Pods:

```
/etc/kubernetes/manifests
```

---

## kubelet

kubelet watches

```
/etc/kubernetes/manifests
```

and automatically launches the control plane containers.

---

## etcd

Runs as a Static Pod.

No systemd service exists.

---

## kubeconfig

Admin configuration:

```
/etc/kubernetes/admin.conf
```

Copy to

```
~/.kube/config
```

---

## Cluster Status

Without a CNI plugin

Node Status:

```
NotReady
```

is expected.
