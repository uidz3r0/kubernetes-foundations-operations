# Notes

## Why disable swap?

Kubernetes requires swap disabled because memory scheduling assumes RAM usage only.

---

## Why overlay?

Allows container image layers.

---

## Why br_netfilter?

Allows iptables to inspect bridged traffic.

Without this, Services and Network Policies fail.

---

## Why ip_forward?

Allows pods on different nodes to communicate.

---

## Why verify time?

Certificates depend on synchronized clocks.

Time drift can break:

- kubeadm
- TLS
- etcd

---

## Why hosts file?

Provides reliable hostname resolution even before internal DNS exists.

---

Today was purely Linux preparation.

No Kubernetes software has been installed.