# W6D4 — Pod Security & Security Contexts

## Objectives

Today you will learn:

- Pod Security Admission (PSA)
- Security Contexts
- Running as non-root
- Linux capabilities
- Read-only root filesystem
- Seccomp
- Principle of Least Privilege

---

# Why workload hardening?

Even with:

- RBAC
- Secrets
- Network Policies

a compromised container may still:

- run as root
- modify the filesystem
- gain Linux capabilities
- escape into the node (rare but possible)

Kubernetes provides workload-level security controls.

---

# Pod Security Admission (PSA)

`PodSecurityPolicy` (PSP) has been removed.

Modern Kubernetes uses `Pod Security Admission`.

Three enforcement levels:

- `Privileged`: no restrictions.
- `Baseline`: blocks obviously dangerous settings.
- `Restricted`: strong security defaults.

Namespace labels enable PSA.

Example:

```yaml
metadata:
  labels:
    pod-security.kubernetes.io/enforce: restricted
```

---

# Security Context

SecurityContext controls:

- UID
- GID
- privilege escalation
- capabilities
- seccomp
- filesystem permissions

Security contexts can exist at either level:

- Pod level: `spec.securityContext`
- Container level: `containers[].securityContext`

Container-level settings override Pod-level settings when both define the same field.

---

# Run as Non-root

- Bad: run as root (`UID 0`)
- Good: configure `runAsNonRoot: true` and `runAsUser: 1000`

Example:

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
```

---

# Read-only Root Filesystem

Most applications never need to modify:

```text
/
```

Enable:

```yaml
readOnlyRootFilesystem: true
```

Temporary files should use:

```yaml
emptyDir: {}
```

---

# Privilege Escalation

Prevent processes from gaining more privileges.

```yaml
allowPrivilegeEscalation: false
```

---

# Linux Capabilities

Linux breaks root into capabilities.

Examples:

- `NET_ADMIN`
- `SYS_ADMIN`
- `SYS_TIME`

Most workloads need none.

Drop everything:

```yaml
capabilities:
  drop:
  - ALL
```

Add only what is required.

---

# Seccomp

Seccomp filters Linux syscalls.

Recommended:

```text
RuntimeDefault
```

Example:

```yaml
securityContext:
  seccompProfile:
    type: RuntimeDefault
```

---

# Privileged Containers

Avoid:

```yaml
privileged: true
```

This effectively gives host-level access.

Only infrastructure components should require it.

---

# Host Namespaces

Avoid:

```yaml
hostNetwork: true
hostPID: true
hostIPC: true
```

These expose host resources.

---

# Best Practice Checklist

- Run as non-root.
- Drop capabilities.
- Disable privilege escalation.
- Use a read-only filesystem.
- Use `RuntimeDefault` seccomp.
- Avoid privileged containers.
- Use PSA `Restricted`.

---

# Production Recommendation

Use `Restricted` PSA by default.

Only exempt infrastructure namespaces when necessary.

---

## Learning Outcomes

By the end of W6D4, students should be able to:

- Explain the purpose of `Pod Security Admission` and the differences between `Privileged`, `Baseline`, and `Restricted` profiles.
- Configure `Security Contexts` at both the Pod and Container levels.
- Run containers as a `non-root user` and understand why this reduces risk.
- Disable `privilege escalation` and drop unnecessary `Linux capabilities`.
- Use a `read-only root filesystem` with `emptyDir` volumes where write access is required.
- Apply the `RuntimeDefault seccomp profile` to reduce the system call attack surface.
- Create workloads that comply with the `Restricted` Pod Security profile and understand why these hardening practices are recommended for production Kubernetes clusters.
