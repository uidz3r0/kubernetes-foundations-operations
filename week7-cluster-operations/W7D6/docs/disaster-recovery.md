# Disaster Recovery Workflow

1. Detect failure
2. Stop writes
3. Restore snapshot
4. Update manifest
5. Restart etcd
6. Wait for API Server
7. Validate workloads
8. Resume operations