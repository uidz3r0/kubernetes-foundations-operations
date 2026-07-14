# Lab 3 — Join Second Control Plane

On han.lab execute the control-plane join command.

Example:

```bash
/k8s-lab/scripts/cluster/reset-control-plane.sh

sudo kubeadm join k8s-api.lab:6443 \
--token <token> \
--discovery-token-ca-cert-hash sha256:<hash> \
--control-plane \
--certificate-key <key>
```

Verify:

```
kubectl get nodes
```

Expected:

```
NAME
luke
han
leia
```

Verify control plane pods:

```
kubectl get pods -n kube-system -o wide
```

Observe that:

- kube-apiserver
- kube-controller-manager
- kube-scheduler
- etcd

exist on both control-plane nodes.