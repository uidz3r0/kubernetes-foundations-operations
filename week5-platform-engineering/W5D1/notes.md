# W5D1 — Helm Fundamentals

## What is Helm?

Helm is the package manager for Kubernetes.

Similar to:

- apt for Ubuntu
- yum/dnf for RHEL
- pip for Python

Helm packages Kubernetes applications into Charts.

---

## Benefits

- Reusable deployments
- Parameterized values
- Environment-specific configuration
- Easier upgrades
- Easier rollbacks

---

## Helm Components

Chart
- The application package.

values.yaml
- Configuration values.

Templates
- Kubernetes YAML with variables.

Release
- An installed instance of a chart.

Repository
- Collection of charts.

---

## Common Commands

Install Helm:

`curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash`

Verify:

`helm version`

Create chart:

`helm create simplechart`

Install:

```bash
$ helm install demo ./simplechart

NAME: demo
LAST DEPLOYED: Thu Jun 25 16:39:59 2026
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
1. Get the application URL by running these commands:

export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=simplechart,app.kubernetes.io/instance=demo" -o jsonpath="{.items[0].metadata.name}")
export CONTAINER_PORT=$(kubectl get pod --namespace default $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
echo "Visit http://127.0.0.1:8080 to use your application"
kubectl --namespace default port-forward $POD_NAME 8080:$CONTAINER_PORT
```

List releases:

`helm list`

Upgrade:

`helm upgrade demo ./simplechart`

Uninstall:

`helm uninstall demo`

---

## Values

Default:

values.yaml

Override:

```bash
helm install demo ./simplechart \
  -f yaml/values-dev.yaml
```

---

## Template Rendering

Render without deploying:

`helm template demo ./simplechart`

Useful for troubleshooting.

---

## Dry Run

```bash
helm install demo ./simplechart \
  --dry-run
```  

`helm template` and `--dry-run` serve different purposes:

- `helm template` -- renders locally, never contacts the cluster
- `helm install --dry-run` -- contacts the cluster (validates against the API server) but doesn't apply

For CKA prep, helm template is the one you'll reach for most often when debugging chart rendering issues.

---

## Best Practices

- Keep values separate per environment.
- Avoid hardcoding.
- Use templates.
- Test with helm template.
- Use meaningful release names.

---

## Learning Objectives

By the end of W5D1 you should be able to:

- Explain what Helm is.
- Create a chart.
- Install a release.
- Upgrade a release.
- Uninstall a release.
- Use values files.
- Render templates.
- Understand how Platform Engineers package applications.

This is one of the highest ROI topics in modern Kubernetes. Almost every production cluster today deploys applications through Helm, including Prometheus, Grafana, ingress-nginx, cert-manager, Argo CD, and many platform components you'll see later in Phase 2.

---

### Understanding the extra files

`_helpers.tpl` - Reusable template functions.

Example:

```yaml
{{ include "simplechart.fullname" . }}
```

- Very common in production charts.

`serviceaccount.yaml` - Creates a ServiceAccount.

`ingress.yaml` - Ingress resource template.

`hpa.yaml` - Horizontal Pod Autoscaler.

`httproute.yaml` - This is for the Gateway API.

`tests/` - Helm test pods.
