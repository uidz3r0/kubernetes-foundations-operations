# DNS

## Symptoms

Pod cannot resolve another Service.

---

## Verify DNS

```
kubectl exec -it dns-test -- nslookup my-service

kubectl exec -it dns-test -- dig my-service
```

---

## Verify CoreDNS

```
kubectl get pods -n kube-system

kubectl logs -n kube-system deployment/coredns
```

---

## Common Problems

- CoreDNS not running
- wrong namespace
- typo
- NetworkPolicy blocking DNS