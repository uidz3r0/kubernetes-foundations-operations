# W6D4 Labs

---

# Lab 1 — Observe an Insecure Pod

Apply the insecure Pod manifest:

```bash
kubectl apply -f yaml/insecure-pod.yaml
```

Inspect the Pod:

```bash
kubectl describe pod insecure
```

Notice:

- The container runs as the root user.
- Privilege escalation is allowed.
- The root filesystem is writable.

Delete the Pod afterwards:

```bash
kubectl delete pod insecure
```

---

# Lab 2 — Run as Non-root

Apply the non-root Pod manifest:

```bash
kubectl apply -f yaml/nonroot-pod.yaml
```

Verify the user inside the container:

```bash
kubectl exec nonroot -- id
```

Expected:

```text
uid=1000
```

---

# Lab 3 — Secure Pod

Apply the secure Pod manifest:

```bash
kubectl apply -f yaml/secure-pod.yaml
```

Check the Pod status:

```bash
kubectl get pod secure
```

Review the full Pod configuration:

```bash
kubectl describe pod secure
```

Observe:

- The container runs as a non-root user.
- Seccomp is enabled.
- Linux capabilities are dropped.
- The root filesystem is read-only.

---

# Lab 4 — Read-only Filesystem

Apply the read-only root filesystem manifest:

```bash
kubectl apply -f yaml/readonly-rootfs.yaml
```

Attempt to write to the filesystem:

```bash
kubectl exec readonly -- touch /tmp/test
```

Observe whether writes succeed.

Discuss using `emptyDir` for writable paths.

---

# Lab 5 — Linux Capabilities

Apply the capabilities manifest:

```bash
kubectl apply -f yaml/capabilities-drop.yaml
```

Inspect the Pod:

```bash
kubectl describe pod capabilities
```

Observe:

```yaml
drop:
- ALL
```

---

# Lab 6 — Pod Security Admission

Create namespace:

```bash
kubectl apply -f yaml/namespace-restricted.yaml
```

Deploy the secure Pod into the restricted namespace:

```bash
kubectl apply -n secure-workloads -f yaml/secure-pod.yaml
```

Should succeed.

Now deploy the insecure Pod into the restricted namespace:

```bash
kubectl apply -n secure-workloads -f yaml/insecure-pod.yaml
```

Expected:

```text
Rejected by Pod Security Admission.
```

---

# Challenge

Create a deployment that satisfies Restricted PSA while still serving HTTP.

Requirements:

- Run as a non-root user.
- Use the `RuntimeDefault` seccomp profile.
- Drop Linux capabilities.
- Use a read-only root filesystem.
- Disable privilege escalation.
