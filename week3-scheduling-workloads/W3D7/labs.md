# W3D7 Labs

---

# Lab 1 - Create Cluster

```bash
kind create cluster \
  --name w3d7 \
  --config yaml/kind-config.yaml

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml && \
kubectl patch deployment metrics-server -n kube-system --type='json' -p='[
  {"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"},
  {"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-preferred-address-types=InternalIP"}
]'

kubectl get pods -n kube-system
```

Verify:

```bash
kubectl get nodes
```

---

# Lab 2 - Label Worker Node

View nodes:

```bash
kubectl get nodes
```

Label worker:

```bash
kubectl label node w3d7-worker role=app
```

Verify:

```bash
kubectl get nodes --show-labels
```

---

# Lab 3 - Deploy Application

Apply deployment:

```bash
kubectl apply -f yaml/integration-deployment.yaml
```

Apply service:

```bash
kubectl apply -f yaml/integration-service.yaml
```

Verify:

```bash
kubectl get pods
kubectl get svc
```

---

# Lab 4 - Verify Scheduling

Check pod placement:

```bash
kubectl get pods -o wide
```

Confirm application pod runs only on labeled node.

---

# Lab 5 - Deploy DaemonSet

```bash
kubectl apply -f yaml/integration-daemonset.yaml
```

Verify:

```bash
kubectl get ds
kubectl get pods -o wide
```

You should see one daemonset pod per node.

---

# Lab 6 - Run Backup Job

```bash
kubectl apply -f yaml/integration-job.yaml
```

Verify:

```bash
kubectl get jobs
kubectl get pods
```

View logs:

```bash
kubectl logs job/manual-backup
```

---

# Lab 7 - Create CronJob

```bash
kubectl apply -f yaml/integration-cronjob.yaml
```

Wait a few minutes.

Verify:

```bash
kubectl get cronjobs
kubectl get jobs
```

---

# Lab 8 - Deploy HPA

Enable metrics server if available.

Apply:

```bash
kubectl apply -f yaml/integration-hpa.yaml
```

Verify:

```bash
kubectl get hpa
```

---

# Lab 9 - Review Everything

List all resources:

```bash
kubectl get all
```

Questions:

1. Which workload creates one pod per node?

   - DaemonSets.

2. Which workload runs once?

   - Jobs.

3. Which workload runs repeatedly?

   - CronJobs.

4. Which resource performs autoscaling?

   - HPA or HorizontalPodAutoscaler.

5. Which settings influence scheduling?

   - The settings that influence scheduling are: NodeSelector, Node Affinity, Taints, Tolerations, and Pod Affinity/Anti-affinity. Resource requests and limits don't schedule pods but determine if they can fit on a node.

6. Which settings protect resources?

   - Resource requests and limits protect resources by preventing containers from over-consuming CPU/memory..  

7. What happens if readiness probe fails?

   - If the readiness probe fails, the pod is removed from the Service's endpoints, stopping traffic until it passes..

---

# Cleanup

```bash
kind delete cluster --name w3d7
```