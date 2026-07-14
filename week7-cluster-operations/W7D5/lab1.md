# Stable Endpoint

## Lab 1 — Create controlPlaneEndpoint

### Objective

A control plane endpoint gives every Kubernetes component a stable address.

Without it:

```
kubectl
workers
future control planes
```

would all depend on a single node IP.

---

For this lab we'll use:

```
10.1.1.15
```

mapped locally to:

```
luke.lab
```

Edit:

```
/etc/hosts
```

Example:

```
10.1.1.15   k8s-api.lab
```

Verify:

```
ping k8s-api.lab
```

Expected:

```
PING k8s-api.lab
```