# Notes Week 4 Day 5

```bash
kubectl cluster-info

kubectl get componentstatuses

kubectl get pods -n kube-system

kubectl describe node

kubectl get events --sort-by=.lastTimestamp

kubectl cordon NODE

kubectl uncordon NODE

kubectl drain NODE --ignore-daemonsets

kubectl top nodes

kubectl top pods

docker ps

docker exec -it w4d5-control-plane bash

crictl ps

ls /etc/kubernetes/manifests
```

---

## Additional W4D5 Topics

These are worth covering because they appear in CKA:

- `kubectl get events -A`
- `kubectl describe node`
- `kubectl top nodes`
- `kubectl top pods`
- `kubectl cordon`
- `kubectl drain`
- `kubectl uncordon`
- static pods
- CoreDNS troubleshooting
- kube-system investigation
- control plane containers

At the end of W4D5 you should comfortably answer:

- Why is the cluster unhealthy?
- Which component is failing?
- Is the problem the node, scheduler, DNS, kubelet, or workload?
- Which commands reveal the answer fastest?

That sets you up very well for W4D6 Mock CKA Scenarios, where several of these failures can be combined into timed troubleshooting exercises.