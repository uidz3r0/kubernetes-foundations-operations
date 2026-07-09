# W6D5 — Admission Controllers & Image Security

---

## Goal

Understand how Kubernetes enforces security before workloads are created.

---

## Admission Flow

kubectl apply

↓

Authentication

↓

Authorization (RBAC)

↓

Admission Controllers

  (may mutate)

  (may reject)

↓

Object stored in etcd

↓

Scheduler

↓

Kubelet

↓

Container Runtime
Pod starts

---

Admission Controllers are the final gatekeeper.

---

## Two Types

### Mutating Admission Controller

Changes the object.

Examples:

- Add default values
- Inject sidecars
- Add labels

---

### Validating Admission Controller

Accepts or rejects the object.

Examples:

- Block privileged containers
- Require labels
- Require non-root user
- Require signed images

---

## Built-in Admission Controllers

Examples:

- NamespaceLifecycle
- LimitRanger
- ResourceQuota
- ServiceAccount
- DefaultStorageClass
- PodSecurity

---

## Pod Security Admission

You already used:

restricted

baseline

privileged

This is itself an Admission Controller.

---

## Image Security

Containers should be:

- From trusted registries
- Version pinned
- Scanned
- Signed

Avoid:

nginx:latest

Prefer:

nginx:1.27.5

Stronger:

```text
nginx@sha256:<digest>
```

Pinned tags are better than `latest`, but digest pinning is the most reproducible option.

---

## Non-root and Read-only Images

Security settings must match how the image actually works.

Example:

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 101
  readOnlyRootFilesystem: true
```

This is strong from a security perspective, but it only works if the image can run as that user and has writable paths for runtime files.

For nginx, common writable paths include:

- `/var/cache/nginx`
- `/var/run`
- `/tmp`

Use `emptyDir` volumes for those writable paths:

```yaml
volumeMounts:
- name: cache
  mountPath: /var/cache/nginx
- name: run
  mountPath: /var/run
- name: tmp
  mountPath: /tmp
```

The `runAsUser: 101` value is image-specific. The official nginx image commonly has an `nginx` user at UID `101`, but that is still an image implementation detail. Always verify the image user before relying on it.

If nginx listens on port `80`, a non-root process may also need the narrow `NET_BIND_SERVICE` capability:

```yaml
capabilities:
  drop:
  - ALL
  add:
  - NET_BIND_SERVICE
```

An even cleaner pattern is to use an image or config designed to run as non-root on an unprivileged port such as `8080`.

---

## Why not latest?

latest changes over time.

Today's deployment may not match tomorrow's.

Pinned versions are reproducible.

---

## Image Scanning

Common tools:

- Trivy
- Clair
- Grype

They detect:

- CVEs
- Vulnerable packages
- Secrets
- Misconfigurations

---

## Image Signing

Purpose:

Verify that the image actually came from your organization.

Popular tool:

Cosign

Workflow:

Developer

↓

Build Image

↓

Scan

↓

Sign

↓

Push Registry

↓

Admission Controller verifies signature

↓

Deploy

---

## Supply Chain Security

Modern production pipeline:

Developer

↓

Git

↓

CI

↓

Unit Tests

↓

Trivy

↓

Build

↓

Cosign Sign

↓

Registry

↓

Admission Controller

↓

Cluster

---

## Policy Engines

Popular options:

Kyverno

- Kubernetes-native
- YAML policies
- Easy to learn

OPA Gatekeeper

- Uses Rego
- More powerful
- Steeper learning curve

In a pipeline

```text
Developer
    │
    ▼
Write code
    │
    ├── Semgrep
    │
    ▼
Terraform / Kubernetes YAML
    │
    ├── Checkov
    │
    ▼
Build Image
    │
    ├── Trivy
    │
    ▼
Sign Image
    │
    ├── Cosign
    │
    ▼
Deploy to Kubernetes
    │
    ├── Kyverno / OPA Gatekeeper
    │
    ▼
Application Running
    │
    ├── OWASP ZAP
    │
    ▼
Users
```

---

## For your learning path

Given your goal of becoming a strong Kubernetes Platform/DevOps engineer, I'd prioritize them like this:

1. Trivy – Image and manifest security (you already use it).
2. Checkov – Infrastructure as Code security.
3. OWASP ZAP – Dynamic Application Security Testing (DAST) for web applications.
4. Kyverno – Kubernetes policy enforcement using YAML.
5. OPA Gatekeeper – Enterprise policy enforcement with Rego.

This combination covers the major security layers you'll encounter in modern CI/CD pipelines:

- SAST → Semgrep
- IaC scanning → Checkov
- Container scanning → Trivy
- Policy enforcement → Kyverno or OPA Gatekeeper
- DAST → OWASP ZAP

Together, these tools provide complementary coverage rather than overlapping functionality.

---

## CKA

Know:

- Admission Controller purpose
- Pod Security Admission
- ImagePullPolicy
- Security Context

---

## CKS

Expect questions on:

- Image scanning
- Image signing
- Supply chain
- Admission policies
- Kyverno
- OPA Gatekeeper
- Cosign

---

## Production Best Practices

✔ Pin image versions

✔ Scan every image

✔ Sign production images

✔ Block privileged containers

✔ Require non-root

✔ Read-only filesystem

✔ Trusted registries only

✔ Least privilege
