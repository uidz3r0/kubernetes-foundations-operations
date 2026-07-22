Lab 3 — Ingress Review

This lab focuses on how external traffic enters the cluster in a controlled and maintainable way.

When reviewing the manifest, think about routing, TLS, and access boundaries.

Review

```yaml
rules:
```

Why?

- Host-based routing

Review

```yaml
tls:
```

Why?

- HTTPS
- Encryption
- Certificate management

Review

```yaml
pathType: Prefix
```

Why?

- Matches subpaths efficiently.