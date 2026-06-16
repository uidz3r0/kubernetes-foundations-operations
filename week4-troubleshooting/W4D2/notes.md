# W4D2 - Scheduling Troubleshooting

## Objectives
- Understand how the Kubernetes scheduler places Pods.
- Diagnose Pods stuck in Pending.
- Troubleshoot nodeSelector, node affinity, taints, tolerations, and resource requests.
- Use kubectl describe and events to identify scheduling failures.

## Key Commands

```bash
kubectl get pods
kubectl get pods -A
kubectl describe pod <pod-name>
kubectl get events --sort-by=.lastTimestamp
kubectl get nodes --show-labels
kubectl describe node <node-name>
```

## Common Scheduling Failures

### 1. Missing nodeSelector label
A Pod requests a node label that does not exist.

### 2. Affinity mismatch
Required node affinity cannot be satisfied.

### 3. Taints without tolerations
Node is tainted and Pod does not tolerate it.

### 4. Insufficient resources
Requested CPU or memory exceeds available capacity.

### 5. Unschedulable nodes
Node is cordoned or otherwise unavailable.

## Troubleshooting Workflow

1. Check Pod status.
2. Describe the Pod.
3. Read scheduling events.
4. Inspect node labels and taints.
5. Compare resource requests with node capacity.
6. Apply a fix and verify scheduling.
