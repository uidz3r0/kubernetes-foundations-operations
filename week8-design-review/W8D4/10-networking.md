# Networking Failures

## Symptoms

Cannot reach Pod

Cannot reach Service

Ingress unavailable

DNS timeout

---

## Verify

```
kubectl get pods -o wide

kubectl get svc

kubectl get endpoints
```

---

## Test Connectivity

```
kubectl exec -it test -- curl http://service

kubectl exec -it test -- ping pod-ip
```

---

## Verify CNI

```
kubectl get pods -n kube-system
```

Check:

- Calico
- Cilium
- Flannel

---

## Common Problems

NetworkPolicy

CNI failure

Firewall

Service selector

Pod not Ready