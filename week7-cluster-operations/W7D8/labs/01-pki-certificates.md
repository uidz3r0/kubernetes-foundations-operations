# Lab 1 — Kubernetes PKI

## Objective

Understand Kubernetes certificates, how Kubernetes uses them to authenticate components, and which certificates are kubeadm-managed versus auto-rotated.

---

## Why this matters

Kubernetes components rely on TLS identities. If a certificate expires or is not renewed correctly, API communication and control plane access can fail.

## Explore

```
ls /etc/kubernetes/pki
```

Expected

```
ca.crt
ca.key
apiserver.crt
apiserver.key
front-proxy-ca.crt
etcd/
sa.key
```

---

## Examine API Server certificate

```
openssl x509 \
-in /etc/kubernetes/pki/apiserver.crt \
-text \
-noout
```

Look for

- Subject
- Issuer
- SANs (Subject Alternative Name)
- Expiration

---

## Examine CA

```
openssl x509 \
-in /etc/kubernetes/pki/ca.crt \
-noout \
-text
```

Notice

- Self-signed
- Long expiration

---

## kubelet certificates

```
ls /var/lib/kubelet/pki
```

Inspect

```
openssl x509 \
-in /var/lib/kubelet/pki/kubelet-client-current.pem \
-text \
-noout
```

---

## Questions

1. Which certificates are signed by the cluster CA?
2. Which certificates rotate automatically?
3. Which certificates require kubeadm renewal?

## Answers

- Most kubeadm-managed cluster certificates are signed by the cluster CA, including `apiserver`, `controller-manager`, `scheduler`, kubelet client certs, and etcd certs.
- Kubelet client certificates are the primary certificates that rotate automatically.
- kubeadm-managed certificates such as `apiserver`, `controller-manager`, `scheduler`, `admin.conf`, and etcd certificates require `kubeadm certs renew`.
