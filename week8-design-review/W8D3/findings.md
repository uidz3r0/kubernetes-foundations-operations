# Findings

## Strengths

### Cluster Architecture

- Three highly available control plane nodes
- One dedicated worker node
- kube-vip virtual IP for API access
- Stacked etcd quorum
- Calico networking
- Mixed Rocky Linux and Ubuntu nodes demonstrating cross-platform compatibility

### Cluster Operations

- etcd backup process
- Restore procedures documented
- Cluster maintenance scripts available

### Kubernetes Resources

- Deployments functioning correctly
- Services operational
- DNS resolution working

---

## Weaknesses

### Security

- No Network Policies
- Minimal RBAC
- Secrets stored natively
- No Pod Security Standards

---

### Reliability

Current cluster can tolerate:

- Loss of one control plane node without losing quorum.
- Rolling maintenance of control plane nodes.
- Worker node maintenance with minimal disruption (single worker in current lab).

Missing:

- Readiness probes
- Liveness probes
- Startup probes
- Resource requests
- Resource limits

---

### Monitoring

Missing

- Prometheus
- Grafana
- Alertmanager
- Centralized logging

---

### Storage

No production StorageClass configured.

---

### Namespace Design

All workloads currently reside in a limited number of namespaces.

Environment separation should be improved.