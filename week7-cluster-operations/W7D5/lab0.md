# Install kube-vip 

## Objective

Deploy kube-vip as a static Pod before running `kubeadm init`.

The kubelet automatically starts static Pods located in:

```
/etc/kubernetes/manifests
```

This allows the Virtual IP to become available before the Kubernetes control plane is fully initialized.

---

## Step 1

Export the network interface.

Determine the interface used for your LAN.

Example:

```
ip addr
```

Typical interface (using wireless here):

```
wlp2s0
```

Export it.

```bash
export INTERFACE=wlp2s0

ip addr show wlp2s0
```

---

## Step 2

Choose the Virtual IP.

```bash
export VIP=10.1.1.15
```

---

## Step 3

Pull the kube-vip image.

```bash
# Identify latest stable version
curl -sL https://api.github.com/repos/kube-vip/kube-vip/releases | jq -r ".[0].name"
    v1.2.1

sudo ctr image pull ghcr.io/kube-vip/kube-vip:v1.2.1
```

(Replace the version with the latest stable release.)

---

## Step 4

Generate the static Pod manifest.

For `luke`


```bash
export INTERFACE=wlp2s0
export VIP=10.1.1.15
VERSION=v1.2.1

sudo ctr run --rm --net-host \
  ghcr.io/kube-vip/kube-vip:${VERSION} \
  vip \
  /kube-vip manifest pod \
    --interface ${INTERFACE} \
    --address ${VIP} \
    --controlplane \
    --services \
    --arp \
    --leaderElection \
  | sudo tee /etc/kubernetes/manifests/kube-vip.yaml
```

For `han`


```bash
export INTERFACE=wlp5s0
export VIP=10.1.1.15
VERSION=v1.2.1

sudo ctr run --rm --net-host \
  ghcr.io/kube-vip/kube-vip:${VERSION} \
  vip \
  /kube-vip manifest pod \
    --interface ${INTERFACE} \
    --address ${VIP} \
    --controlplane \
    --services \
    --arp \
    --leaderElection \
  | sudo tee /etc/kubernetes/manifests/kube-vip.yaml
```


---

## Step 5

Verify the manifest.

```bash
ls /etc/kubernetes/manifests
```

Expected:

```
etcd.yaml
kube-apiserver.yaml
kube-controller-manager.yaml
kube-scheduler.yaml
kube-vip.yaml
```

Before kubeadm init, only `kube-vip.yaml` will exist.

After kubeadm init, kubeadm creates the remaining static Pod manifests.

---

## Step 6

Verify the VIP.

```bash
ip addr
```

Expected:

```
10.1.1.15
```

Verify:

```bash
ping k8s-api.lab
```

The VIP should now respond.