## Lab 2 — Service Review

This lab is about choosing the right exposure pattern for an application.

The bigger design question is: how should traffic reach the workload without overexposing it?

Review

```yaml
type: ClusterIP
```

Question:

Why ClusterIP?

Expected answer

- Only `Ingress` should expose the application.
- `Pods` communicate internally through `ClusterIP`.

Security principle:

- Never expose Pods directly.

Review

```yaml
targetPort: 80
```

Question

Why not NodePort?

Expected answer

- `NodePort` exposes every worker node.
- `Ingress` already provides controlled entry.
- `ClusterIP` is safer.
