## Lab 5 — Security Review

This lab focuses on how the workload is hardened and how the manifest supports a least-privilege model.

When reviewing the manifest, think about defense in depth and how the container is restricted by default.

Review

`securityContext`

Explain

```yaml
runAsNonRoot
readOnlyRootFilesystem
allowPrivilegeEscalation: false

capabilities:
  drop:
  - ALL
```

Question

Why?

Expected answer

- Least privilege
- Container hardening
- Defense in depth