# W3D1 — Scheduling Workloads

This is where Kubernetes stops being "Pods and Deployments" and starts becoming a scheduler-driven platform.

## Topics

- Node Scheduling Basics
- nodeSelector
- Labels on Nodes
- Affinity
  - Node Affinity
  - Preferred vs Required
- Anti-Affinity
- Taints
- Tolerations

## Why Scheduling Matters

When a Pod is created, Kubernetes must decide:

- Which node should run it?
- Which node has resources available?
- Which node satisfies placement rules?

This is the job of the Kubernetes Scheduler.

---

## Prep

```bash
kind create cluster --name week3 --config yaml/kind-config.yaml
kubectl config get-contexts
kubectl get nodes

kubectl create namespace week3
kubectl config set-context --current --namespace=week3
kubectl config view --minify | grep namespace
```

# 1. Create Cluster

```bash
kind create cluster --name week3 --config yaml/kind-config.yaml
```

Verify:

```bash
kubectl get nodes
kubectl get nodes --show-labels
```

Observe:

- control-plane node
- worker node labelled workload=web
- worker node labelled workload=database

---

---

# 2. Node Selector

Apply:

```bash
kubectl apply -f yaml/node-selector-pod.yaml
```

Check placement:

```bash
kubectl get pod nginx-selector -o wide
```

Questions:

1. Which node was selected?
   - week3-worker node was selected.

2. Why did Kubernetes choose that node?
   - The Scheduler first FILTER OUT all the nodes that does not meet the criteria and the remaining FEASIBLE Node was only one. And so that node was selected because its the the pod's selector matched the node's label (workload: web).

3. What would happen if no node had workload=web?
   - The pod status will be "Pending" indefinitely.

Delete:

```bash
kubectl delete -f yaml/node-selector-pod.yaml
```

---

# 3. Required Node Affinity

Apply:

```bash
kubectl apply -f yaml/affinity-required.yaml
```

Check:

```bash
kubectl get pod -o wide
```

Inspect:

```bash
kubectl describe pod nginx-affinity-required
```

Questions:

1. Which node received the Pod?
   - week3-worker2

2. How is this similar to nodeSelector?
   - It uses the pod's selector to match a node's label and so the pod was scheduled on that node by the default-scheduler.

3. Why is affinity more flexible?
   - affinity is more flexible compared the Node Selector because it can schedule pods if there is at least one matching or select either hard required or prefered

Delete:

```bash
kubectl delete -f yaml/affinity-required.yaml
```

---

# 4. Preferred Node Affinity

Apply:

```bash
kubectl apply -f yaml/affinity-preferred.yaml
```

Check placement:

```bash
kubectl get pod -o wide
```

Questions:

1. Is placement guaranteed?
   - No. Preferred node affinity is not guaranteed. Preferred affinity is a soft preference. Kubernetes will try to place the Pod on a matching node, but if that is not possible, it can still schedule the Pod somewhere else.

2. What does weight=100 mean?
   - weight is 1-100 and works like priority where higher number is higher priority

3. Why might preferred affinity be safer than required affinity?
   - preferred is less stricter than required.

Delete:

```bash
kubectl delete -f yaml/affinity-preferred.yaml
```

---

# 5. Taints

View nodes:

```bash
kubectl get nodes
```

Select database worker:

```bash
kubectl label nodes <database-node> dedicated=special
kubectl label nodes week3-worker2 dedicated=special
```

Add taint:

```bash
kubectl taint nodes <database-node> dedicated=special:NoSchedule
kubectl taint nodes week3-worker2 dedicated=special:NoSchedule
```

Verify:

```bash
kubectl describe node <database-node>
kubectl describe node week3-worker2
```

Observe:

- Taints section
  - 

---

# 6. Pod Without Toleration

Apply:

```bash
kubectl apply -f yaml/taint-demo-pod.yaml
```

Check:

```bash
kubectl get pod
kubectl describe pod taint-demo
```

Questions:

1. Did Kubernetes avoid the tainted node?
   - there was no event to show that node week3-worlker2 was filtered out

2. What event message was generated?
   - The event log showed that the pod was succesfully assigned to node week3-worker

Delete:

```bash
kubectl delete -f yaml/taint-demo-pod.yaml
```

---

# 7. Pod With Toleration

Apply:

```bash
kubectl apply -f yaml/toleration-demo-pod.yaml
```

Check:

```bash
kubectl get pod -o wide
kubectl describe pod toleration-demo
```

Questions:

1. Why can this Pod run on the tainted node?
   - Taints repel; tolerations allow.
   - Taints are placed on nodes to repel Pods. Tolerations are placed on Pods to say “this Pod is allowed to tolerate that taint.”

2. Does toleration force placement?
   - Tolerations do not force placement. A toleration only allows a Pod to be scheduled onto a tainted node. It does not make Kubernetes choose that node.
   - To force or strongly guide placement, combine toleration with nodeSelector or node affinity.

3. What is the difference between affinity and toleration?
   - affinity is matching selectors to label with more more rules or conditions
   - while toleration works with taints, to allow the pod with toleration being immune to the taint. The toleration repels the taint thus can can allow the pod to get schdeuled on the node.

Delete:

```bash
kubectl delete -f yaml/toleration-demo-pod.yaml
```

---

# Cleanup

Remove taint:

```bash
kubectl taint nodes <database-node> dedicated=special:NoSchedule-
kubectl taint nodes week3-worker2 dedicated=special:NoSchedule-
```

Remove label:

```bash
kubectl label nodes <database-node> dedicated-
kubectl label nodes week3-worker2 dedicated-
```

After W3D1, the next progression I'd recommend is:

- W3D2 – DaemonSets
- W3D3 – Resource Requests & Limits
- W3D4 – Liveness, Readiness & Startup Probes
- W3D5 – Jobs
- W3D6 – CronJobs
- W3D7 – Week 3 Review + Troubleshooting Lab

That sequence follows how Kubernetes actually operates in production and builds naturally on scheduling concepts learned in W3D1.