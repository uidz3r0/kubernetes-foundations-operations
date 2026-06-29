# W5D7 Labs

## Lab 1 — Deploy the Application

Apply RBAC, then install the app via Helm.

```bash
kubectl apply -f yaml/rbac/
helm install platform-demo ./yaml/helm
```

Verify

```bash
kubectl get all
kubectl get sa
helm list
```

(The raw manifests in `yaml/app/` show what the chart renders to —
see `helm template platform-demo ./yaml/helm`.)

---

## Lab 2 — Verify RBAC

Can the ServiceAccount read Pods?

```bash
kubectl auth can-i get pods \
--as=system:serviceaccount:default:developer-sa
```

Expected

```
yes
```

---

## Lab 3 — Gateway

Prereq: the Gateway API CRDs are not built into Kubernetes. Install them
first or `kubectl apply` fails with "no matches for kind Gateway".

```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/standard-install.yaml
```

Note: this only registers the resources. They won't route real traffic
without a controller (gatewayClassName: nginx) — conceptual lab only.

Apply

```bash
kubectl apply -f yaml/gateway/
```

Verify

```bash
kubectl get gateway
kubectl get httproute
```

---

## Lab 4 — GitOps Update

Pretend Git changed.

Apply

```bash
kubectl apply -f yaml/gitops/deployment-v2.yaml
```

Watch rollout

```bash
kubectl rollout status deployment/platform-demo
```

Note: Lab 1 installed this deployment via Helm, so applying the manifest
directly with `kubectl apply` changes a Helm-managed resource out-of-band.
Helm's stored release state won't know about it until the next
`helm upgrade platform-demo yaml/helm/`. This is configuration drift (see W5D5) — in real GitOps
the change would go through Git/Helm, not a manual `kubectl apply`.

---

## Lab 5 — Observe

Logs

```bash
kubectl logs deployment/platform-demo
```

Events

```bash
kubectl events
```

Resources

```bash
kubectl top pods
```

---

## Lab 6 — End-to-End Review

Draw the deployment flow.

Developer

↓

Git

↓

Pipeline

↓

Registry

↓

GitOps

↓

Helm

↓

Deployment

↓

Service

↓

Gateway

↓

Users

Explain where each Week 5 technology fits.
