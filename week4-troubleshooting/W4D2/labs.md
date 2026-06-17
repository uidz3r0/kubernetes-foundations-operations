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

---

## Lab Lessons

### NodeSelector

Two valid fixes:

| Root cause | Correct fix |
| --- | --- |
| Pod nodeSelector has a typo / wrong key | Fix the pod YAML (`env: prod` ~ `environment: production`) |
| Node is missing the expected label | Label the node |

One thing to be aware of in production:

Node labels are usually managed by IaC or something -- not applied manually. A manually applied label disappears if the node is replaced or recycled. In a real environment you'd set that label in your node group config or via a tool like Cluster API.

For the CKA exam, the right fix is either:

1. Label the correct node with environment=production
2. Fix a typo in the selector key/value if that's what was broken.

Read what the question is actually asking.

`k label node week4-worker environment=production`
`k get nodes -L environment`
`k describe nodes | grep -A5 "Conditions"`
`k label node week4-worker

Best practice:

- Use nodeSelector carefully - Ensure labels exist before deploying
- Implement node affinity (more flexible than nodeSelector)
- Use multiple node selectors as fallback
- Monitor with kubectl get pods -o wide to see node assignments
- Consider using node pools with consistent labeling in cloud environments

### Broken Node Affinity

Fix it:

```yaml
# Another noob fix by AJ
# FROM
required (hard constraint):
requiredDuringSchedulingIgnoredDuringExecution:
  nodeSelectorTerms:
  - matchExpressions:
    - key: workload
      operator: In
      values:
      - database

# TO - take note the absence of "-" in matchExpressions:
preferred (soft constraint):
preferredDuringSchedulingIgnoredDuringExecution:
- weight: 1
  preference:
    matchExpressions:
    - key: workload
      operator: In
      values:
      - database
```

The right way is:

`kubectl label node <node-name> workload=database`

Changing to preferred is not a fix â it's changing the requirement. With preferred, the pod schedules on any node regardless of the label. You didn't fix the affinity rule, you just made Kubernetes ignore it when it can't be met.

| Fix | What it means | 
| --- | --- |
| Change to `preferred` | "I give up on the constraint" | 
| Keep `required` + label a node | "I satisfy the constraint properly" |

For a lab about troubleshooting scheduling failures, the point is to understand why the pod is Pending and satisfy the constraint -- not remove it.

The one case where changing `preferred` -> `required` (or vice versa) is the right fix is if the original intent was wrong -- e.g., the YAML had required but the app doesn't actually need a specific node, it just prefers one. Then changing the type is a legitimate fix.

### Missing Toleration

```yaml
# FROM
  containers:
  - name: nginx
    image: nginx
    
# TO 
  containers:
  - name: nginx
    image: nginx
  tolerations:
  - key: "workload"
    operator: "Exists"
    effect: "NoSchedule"
```

Remove taint:
`kubectl taint nodes <node> workload=restricted:NoSchedule-`

### Resource Exhaustion

```yaml
resources:
  requests:
    cpu: "8"
```

Students learn:

`kubectl describe pod`

and see:

```bash
0/1 nodes available:
Insufficient cpu
```

### Taints and Tolerations

Node:

`kubectl taint nodes worker1 dedicated=db:NoSchedule`

Pod:

```yaml
spec:
  containers:
  - image: nginx
```

Event:

```bash
node(s) had taint {dedicated: db}
```

Fix by adding:

```yaml
tolerations:
- key: dedicated
  operator: Equal
  value: db
  effect: NoSchedule
```

### Wrong Label

Node labels:

`kubectl get nodes --show-labels`

Pod:

```yaml
nodeSelector:
  env: prod
```

But node has:

`environment=prod`

Students must compare labels.
This teaches observation rather than memorization.

