# W5D3 — Observability

Observability answers three questions:

1. What happened?
2. Why did it happen?
3. Is it happening again?

Kubernetes observability consists primarily of:

- Logs
- Metrics
- Events

---

# Logs

Logs show application output.

Example:

`kubectl logs podname`

Follow logs:

`kubectl logs -f podname`

Container selection:

`kubectl logs podname -c container`

Previous crashed container:

`kubectl logs podname --previous`

---

# Events

Events explain Kubernetes decisions.

View namespace events:

`kubectl get events`

Sort by newest:

`kubectl get events --sort-by=.metadata.creationTimestamp`

Watch events:

`kubectl get events -w`

Common events:

- Scheduled
- Pulling
- Started
- Killing
- BackOff
- FailedScheduling

---

# Metrics

Metrics answer:

- CPU usage
- Memory usage
- Resource consumption

Requires Metrics Server.

View nodes:

`kubectl top nodes`

View pods:

`kubectl top pods`

Example:

NAME          CPU   MEMORY
frontend      5m    30Mi

---

# kubectl top

CPU:
- m = millicores

1000m = 1 CPU

Memory:
- Mi = mebibytes

Examples:

250m CPU
128Mi memory

---

# Observability Layers

Application
↓
Pod
↓
Node
↓
Cluster

Observability should exist at every layer.

---

# Prometheus Concepts

Prometheus is a pull-based metrics system.

Components:

- Prometheus server
- Exporters
- Alertmanager
- Targets

Prometheus scrapes:

http://application:metrics

The real format is `http://<target>:<port>/metrics` - `/metrics` is the HTTP path (an endpoint), not a port. Minor, but worth getting right since it's a common interview question.

Metrics examples:

http_requests_total
cpu_usage_seconds_total

Prometheus stores time-series data.

Example:

cpu_usage 5 minutes ago
cpu_usage now

---

# Prometheus Terminology

Metric:
    cpu_usage

Label:
    pod="frontend"

Time series:
    cpu_usage{pod="frontend"}

Query language:
    PromQL

Example:

rate(http_requests_total[5m])

---

# Grafana Concepts

Grafana visualizes metrics.

Typical dashboards:

- Node CPU
- Node Memory
- Pod CPU
- Pod Memory
- Request Rate
- Error Rate

Grafana itself does not collect metrics.

It reads from:

- Prometheus
- Loki
- Elasticsearch

---

# Golden Signals

Google SRE defines:

1. Latency
2. Traffic
3. Errors
4. Saturation

These four metrics reveal application health.

---

# Troubleshooting Workflow

1. kubectl get pods
2. kubectl describe pod
3. kubectl logs
4. kubectl get events
5. kubectl top pod
6. investigate application

---

# CKA Notes

Know:

```bash
- kubectl logs
- kubectl logs -f
- kubectl logs --previous
- kubectl top nodes
- kubectl top pods
- kubectl get events
- kubectl describe
```

Logs, Metrics, Events map cleanly to the industry "three pillars of observability" (Logs, Metrics, Traces). Kubernetes core gives you the first two strongly and events as a bonus; tracing (Jaeger/Tempo) is the third pillar you'll meet in Phase 2. Might be worth a one-liner so the mental model is complete.


Prometheus and Grafana are conceptual only for CKA.