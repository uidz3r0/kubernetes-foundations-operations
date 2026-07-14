# Lab 2 — Reinitialize Cluster

Reset the existing cluster.

```
sudo kubeadm reset -f
```

Run:

```
sudo kubeadm init \
--control-plane-endpoint=k8s-api.lab:6443 \
--upload-certs
```

Gives:

```bash
# You can now join any number of control-plane nodes running the following command on each as root:

  kubeadm join k8s-api.lab:6443 --token nk6llp.f5vcln35obdcyjrs \
	--discovery-token-ca-cert-hash sha256:7951cb8946dbacfccb2659c7ad5662d567d2be84c3aeee8c8fc276399869768c \
	--control-plane --certificate-key ee57f9e6a8e17dd877b1f51967d82a0db2080b0f368c39018be01a8d96c4d9ad

# Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
# As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use
"kubeadm init phase upload-certs --upload-certs" to reload certs afterward.

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join k8s-api.lab:6443 --token nk6llp.f5vcln35obdcyjrs \
	--discovery-token-ca-cert-hash sha256:7951cb8946dbacfccb2659c7ad5662d567d2be84c3aeee8c8fc276399869768c 
```

Observe:

- certificate key
- join command
- discovery token

Save all output.

Why?

Additional control planes need certificates that normally never leave the first node.

The upload-certs option temporarily encrypts those certificates inside the cluster.