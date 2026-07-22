# Lab 2 — Inspecting Certificates

## View expiration

```
kubeadm certs check-expiration
```

Example

```
CERTIFICATE                EXPIRES
admin.conf                 364d
apiserver                  364d
controller-manager.conf    364d
scheduler.conf             364d
```

---

## Renew all certificates

```
sudo kubeadm certs renew all
```

For a scripted workflow, use `./scripts/renew-certificates.sh` to renew kubeadm-managed certs and restart kubelet.

```bash
/k8s-lab/scripts/lab/renew-certificates.sh
```

---

## Restart control plane components

Static Pods automatically restart after manifest changes.

Restart kubelet if required:

```
sudo systemctl restart kubelet
```

---

## Verify

```
kubeadm certs check-expiration
```

---

## Questions

1. Why doesn't kubeadm renew the CA?
2. Why is renewing the CA much more complicated?

## Answers

- kubeadm does not renew the CA because the CA is the root trust anchor; replacing it would invalidate all existing certificates.
- Renewing the CA is much more complicated because it requires reissuing the entire certificate chain and updating every component that trusts the old CA.