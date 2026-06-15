# W3D6 Notes – CronJobs and HPA Basics

---

## CronJob Controls

Useful settings:

### suspend

Stops future executions.

```yaml
suspend: true
```

---

### successfulJobsHistoryLimit

Controls retained successful jobs.

```yaml
successfulJobsHistoryLimit: 2
```

---

### failedJobsHistoryLimit

Controls retained failed jobs.

```yaml
failedJobsHistoryLimit: 1
```

---

### concurrencyPolicy

Controls overlapping executions.

Allow (default)

```yaml
concurrencyPolicy: Allow
```

Forbid

```yaml
concurrencyPolicy: Forbid
```

Replace

```yaml
concurrencyPolicy: Replace
```

---

## Horizontal Pod Autoscaler (HPA)

Automatically adjusts replica count.

Example:

```yaml
minReplicas: 1
maxReplicas: 5
```

---

## Why HPA Needs Resource Requests

HPA calculates utilization using:

CPU Usage
------------
CPU Request

Example:

Usage = 100m

Request = 200m

Utilization = 50%

Without CPU requests:

```yaml
resources:
  requests:
    cpu: 100m
```

HPA cannot calculate percentages.

---

## Metrics Server

Provides resource metrics.

Commands:

```bash
kubectl top nodes
```

```bash
kubectl top pods
```

Without Metrics Server:

```text
TARGETS
unknown
```

---

## HPA Workflow

1. Metrics Server gathers CPU metrics.

2. HPA checks utilization.

3. Utilization exceeds target.

4. Deployment replicas increase.

5. Utilization falls.

6. Replicas scale down.

---

## Common Commands

View HPA:

```bash
kubectl get hpa
```

Describe HPA:

```bash
kubectl describe hpa
```

View metrics:

```bash
kubectl top pods
```

Watch scaling:

```bash
kubectl get pods -w
```

---

## Exam Tips

Know:

- Job vs CronJob
- suspend
- concurrencyPolicy
- successfulJobsHistoryLimit
- failedJobsHistoryLimit
- Metrics Server
- HPA requires CPU requests
- minReplicas
- maxReplicas
- averageUtilization

Typical interview question:

"What happens if CPU requests are not defined on a Deployment using HPA?"

Answer:

HPA cannot calculate CPU utilization percentages and therefore cannot scale based on CPU metrics.

---

## End of Week 3

At this point you've covered most of the day-to-day workload management concepts:

- Scheduling (selectors, taints, affinity)
- DaemonSets
- Resources
- Limits
- Probes
- Jobs
- CronJobs
- HPA

Week 4 can move into:

- ConfigMaps (advanced)
- Secrets (advanced)
- Volumes
- PersistentVolumes
- PersistentVolumeClaims
- StorageClasses
- StatefulSets

which is where Kubernetes starts feeling like "real production workloads."