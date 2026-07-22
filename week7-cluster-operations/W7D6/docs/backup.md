# etcd Backups

etcd is the source of truth for Kubernetes.

It stores:

- Pods
- Deployments
- Secrets
- ConfigMaps
- Namespaces
- RBAC
- Services
- Nodes

If etcd is lost, the Kubernetes cluster state is lost.

Snapshots are the recommended backup mechanism.

Backups should be taken regularly and copied off the control plane.