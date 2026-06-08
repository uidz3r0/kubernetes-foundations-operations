# W3D3 Labs

---

## Lab 1 - Build Cluster

```bash
kind create cluster \
--name w3d3 \
--config yaml/kind-config.yaml

docker info
docker stats
docker ps -a
docker logs learn-worker3
```

Verify:

```bash
kubectl get nodes --show-labels
```

---

## Lab 2 - Pod Affinity Required

Deploy:

```bash
kubectl apply -f yaml/pod-affinity-required.yaml
```

Observe:

```bash
kubectl get pods -o wide
```

Question:

Which node did frontend and backend land on?

- Both frontend and backend landed on the same node w3d3-worker.

---

## Lab 3 - Pod Affinity Preferred

Deploy:

```bash
kubectl apply -f yaml/pod-affinity-preferred.yaml
```

Observe:

```bash
kubectl get pods -o wide
```

Question:

Did api schedule with cache?
  
- Yes. api and cache are both on the same node w3d3-worker2.

---

## Lab 4 - Pod Anti-Affinity Required

Deploy:

```bash
kubectl apply -f yaml/pod-antiaffinity-required.yaml
```

Observe:

```bash
kubectl get pods -o wide
```

Question:

Did replicas spread across nodes?

- the podAntiAffinity caused the replicas to spread across nodes as much as possible, but one pod stayed "Pending" because the required anti-affinity rule could not be satisfied on any available node with an existing "frontend" pod.

- Key point: requiredDuringSchedulingIgnoredDuringExecution is a hard rule. If it cannot be satisfied, the pod stays Pending.

---

## Lab 5 - Pod Anti-Affinity Preferred

Deploy:

```bash
kubectl apply -f yaml/pod-antiaffinity-preferred.yaml
```

Observe:

```bash
kubectl get pods -o wide
```

Question:

Were Pods distributed evenly?

- Pods were distributed evenly where possible, but because there were more replicas than nodes, some pods still shared nodes.

- Key point: preferred is soft and best-effort, not a guarantee.

---

## Lab 6 - Resource Requests

Deploy:

```bash
kubectl apply -f yaml/resource-requests.yaml
```

Inspect:

```bash
kubectl describe pod requests-demo
```

Find:

Resources -> Requests

---

## Lab 7 - Resource Limits

Deploy:

```bash
kubectl apply -f yaml/resource-limits.yaml
```

Inspect:

```bash
kubectl describe pod limits-demo
```

Find:

Resources -> Limits

---

## Lab 8 - Deployment Resources

Deploy:

```bash
kubectl apply -f yaml/resource-demo-deployment.yaml
```

Inspect:

```bash
kubectl describe deployment web-resources
```

Questions:

- What requests are configured?

  - Requests: cpu: 100m, memory: 128Mi

- What limits are configured?

  - Limits: cpu: 500m, memory: 256Mi

---

## Lab 9 - Scheduler Investigation

View node allocation:

```bash
kubectl describe node
```

Look for:

Allocated resources

Questions:

- How does Kubernetes know where to place Pods?
  - The scheduler uses `requests` to decide placement.

- Does it use requests or limits?
  - It uses requests, not limits
  - `limits` are not used for scheduling in the normal case; they are a runtime cap enforced by the kubelet/container runtime.

Answer:

Requests.

---

## Cleanup

```bash
kind delete cluster --name w3d3
```

---

### Simple missing understanding: 

- `required` affinity/anti-affinity = hard constraint, pod may stay `Pending` if impossible  
- `preferred` affinity/anti-affinity = soft hint, scheduler tries but can still place pods elsewhere  
- `requests` = scheduling reservation -- only used during scheduling. Requests must be <= limits for the same resource.  
- `limits` = runtime enforcement cap. If a container exceeds CPU `limits` it is throttled; if it exceeds memory `limits` it can be OOM-killed.


### Concepts:

- Required vs Preferred:

  - `requiredDuringSchedulingIgnoredDuringExecution`: hard constraint — scheduler will not place the Pod if the rule can't be satisfied (Pod stays Pending).

  - `preferredDuringSchedulingIgnoredDuringExecution`: soft hint — scheduler tries to satisfy it but will place the Pod elsewhere if needed.

- Behavior examples:

  - `podAffinity` + required = pods will be colocated (or Pending if impossible).

  - `podAffinity` + preferred = scheduler tries to colocate but may not.
  
  - `podAntiAffinity` + preferred = scheduler spreads pods where possible; if replicas > nodes, some pods will share nodes.
  
  - `podAntiAffinity` + required = scheduler will refuse to schedule pods that would violate the rule (Pending) if there aren’t enough distinct topology domains.

- Topology scope: The `topologyKey` (e.g., `kubernetes.io/hostname`, zone labels) controls “together/apart” scope. Choose it to target node-level or zone-level behavior.

- Other constraints matter: Node selectors, node affinity, taints/tolerations, resource `requests`, and node capacity all influence final placement — affinity is one factor of many.

- Scheduler resource note: The scheduler uses `requests` when deciding placement; `limits` do not affect scheduling.

| Resource Setting | Used By | When | Purpose |
| --- | --- | --- | --- |
| Requests | Scheduler | Before Pod starts | Decide where Pod can be placed |
| Limits | Kubelet / Linux cgroups | While Pod is running | Prevent Pod from consuming too much |


