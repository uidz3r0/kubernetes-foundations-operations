# W3D3 Notes

## Pod Affinity

Schedule Pods together.

Example:

frontend + backend

Benefits:

- lower latency
- same node communication
- cache locality

---

## Pod Anti-Affinity

Schedule Pods apart.

Benefits:

- high availability
- fault tolerance
- workload spreading

Example:

3 replicas

Node1 -> Pod1

Node2 -> Pod2

Node3 -> Pod3

---

## Required vs Preferred

Required

- hard rule
- pod remains Pending if impossible

Preferred

- soft rule
- scheduler tries best effort

---

## Resource Requests

Requests tell scheduler:

"I need at least this much."

Example:

cpu: 250m
memory: 128Mi

Scheduler uses requests when deciding placement.

---

## Resource Limits

Limits tell kubelet:

"Do not exceed this amount."

Example:

cpu: 500m
memory: 256Mi

---

## CPU Units

1000m = 1 CPU

Examples:

100m = 0.1 CPU

500m = 0.5 CPU

1000m = 1 CPU

---

## Memory Units

Mi = Mebibyte

Examples:

128Mi
256Mi
512Mi
1Gi

---

## Production Guidance

Always set:

requests:
  cpu:
  memory:

limits:
  cpu:
  memory:

Without requests:

- scheduler guesses badly
- noisy neighbour issues
- resource starvation

Requests are used for scheduling.

Limits are used for enforcement.

---

End of Week 3 Progress

After W3D3 you will have covered:

✅ Node Selectors
✅ Node Affinity
✅ Taints & Tolerations
✅ DaemonSets
✅ Pod Affinity
✅ Pod Anti-Affinity
✅ Resource Requests
✅ Resource Limits

W3D4 next: Horizontal Pod Autoscaler (HPA) + Metrics Server

This is where Kubernetes starts making scaling decisions automatically based on CPU usage.