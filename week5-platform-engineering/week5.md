# Week 5 Structure

## W5D1 — Helm Fundamentals ✅

- helm install
- helm upgrade
- helm rollback
- values files
- helm template
- use existing charts

## W5D2 — RBAC & Service Accounts

Files:

```bash
W5D2/
├── labs.md
├── notes.md
└── yaml
    ├── serviceaccount.yaml
    ├── role.yaml
    ├── rolebinding.yaml
    ├── pod-sa.yaml
    └── forbidden-pod.yaml
```

Topics:

- ServiceAccounts
- Roles
- RoleBindings
- kubectl auth can-i
- least privilege

## W5D3 — Observability

Files:

```bash
W5D3/
├── labs.md
├── notes.md
└── yaml
    ├── metrics-pod.yaml
    ├── logging-pod.yaml
    └── failing-app.yaml
```

Topics:

- logs
- metrics
- events
- kubectl top
- Prometheus concepts
- Grafana concepts

## W5D4 — CI/CD into Kubernetes

Topics:

- image build
- push image
- update deployment
- rollout
- rollback

Example pipeline:

```bash
Git Push
    ↓
Build Image
    ↓
Push Registry
    ↓
kubectl apply
```

You don't need Jenkins or GitHub Actions yet.

## W5D5 — GitOps Concepts

Topics:

- desired state
- drift
- pull vs push
- ArgoCD overview

Maybe even:

```bash
kubectl apply -f app.yaml
git commit
```

and explain why GitOps exists.

## W5D6 — Gateway API

This is becoming more relevant than Ingress.

Topics:

- GatewayClass
- Gateway
- HTTPRoute

Only concepts and perhaps one demo.

## W5D7 — Platform Engineering Integration Lab

Scenario:

- Application deployed with Helm.
- Uses ServiceAccount.
- Restricted with RBAC.
- Observable via metrics.
- Delivered via a Git workflow.
- Exposed through Gateway.