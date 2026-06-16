# W4D2 Labs - Scheduling Troubleshooting

## Lab 1 - Broken nodeSelector

1. Apply:
   ```bash
   kubectl apply -f yaml/broken-nodeselector-pod.yaml
   ```
2. Observe the Pod is Pending.
3. Use:
   ```bash
   kubectl describe pod broken-nodeselector
   ```
4. Identify the scheduling error.
5. Fix the nodeSelector and redeploy.

---

## Lab 2 - Broken Node Affinity

1. Apply:
   ```bash
   kubectl apply -f yaml/broken-affinity-pod.yaml
   ```
2. Describe the Pod.
3. Determine why affinity rules cannot be met.
4. Modify the affinity rule so the Pod schedules.

---

## Lab 3 - Missing Toleration

1. Taint a node:
   ```bash
   kubectl taint nodes <node> workload=restricted:NoSchedule
   ```
2. Apply:
   ```bash
   kubectl apply -f yaml/missing-toleration-pod.yaml
   ```
3. Investigate why scheduling fails.
4. Add the correct toleration.

---

## Lab 4 - Excessive Resource Requests

1. Apply:
   ```bash
   kubectl apply -f yaml/resource-pressure-pod.yaml
   ```
2. Inspect scheduling events.
3. Reduce requests until the Pod schedules.

---

## Challenge Lab

Create a Pod that combines:
- nodeSelector
- node affinity
- resource requests

Intentionally break one setting and diagnose it using only:
```bash
kubectl describe
kubectl get events
```
