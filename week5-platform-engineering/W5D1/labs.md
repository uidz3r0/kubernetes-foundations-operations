# W5D1 Labs — Helm Fundamentals

## Lab 1 — Install Helm

Verify:

```bash
helm version
```

---

## Lab 2 — Create Chart

```bash
helm create simplechart
```

Inspect:

```bash
tree simplechart
```

Questions:

- What is Chart.yaml?

  - The Helm package. It's actually the metadata file (name, version, appVersion, description) for the application.

- What is values.yaml?

  - This is the default settings. For configuration variables.

- What is templates/?

  - the template or blueprint folder. This will actually render into actual manifest files using the values in `values.yaml`
  - The flow would be `values.yaml` + `templates/` → Helm → Final Kubernetes YAML.

---

## Lab 3 — Install Chart

```bash
helm install demo ./simplechart
```

Verify:

```bash
kubectl get all

# This shows the release after the `helm upgrade ..`
helm list
```

---

## Lab 4 — Modify Replica Count

Edit:

values.yaml

Change:

```yaml
replicaCount: 3
```

Upgrade:

```bash
helm upgrade demo ./simplechart
```

Verify:

```bash
kubectl get deploy
```

---

## Lab 5 — Environment Values

Deploy:

```bash
helm upgrade demo ./simplechart \
  -f yaml/values-dev.yaml
```

Check:

```bash
kubectl get deploy
```

`values-dev.yaml` only contains the keys it overrides. Helm deep-merges it on top of the default `values.yaml`. Keys not mentioned in `values-dev.yaml` keep their default values.

---

## Lab 6 — Render Templates

```bash
helm template demo ./simplechart
```

Observe generated YAML.

---

## Lab 7 — Cleanup

```bash
helm uninstall demo
helm uninstall dev
helm uninstall prod
```

Verify:

```bash
helm list
kubectl get all
```

`helm template` is a dry-run that renders YAML locally without touching the cluster. Very useful for debugging â you can pipe it to `kubectl diff` or just eyeball what Helm would actually apply.

---

# Challenge

Deploy:

- dev release
- prod release

At the same time:

```bash
helm install dev ./simplechart \
  -f yaml/values-dev.yaml

helm install prod ./simplechart \
  -f yaml/values-prod.yaml

# One chart, with multiple isolated releases
kubectl get deploy  
```

Compare the deployments.