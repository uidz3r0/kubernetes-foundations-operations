# Kubernetes Learning Plan Starter Repo

## Folder Structure

```text
kubernetes-learning-plan/
├── README.md
├── week1-foundations/
│   ├── notes.md
│   ├── labs.md
│   ├── commands.md
│   └── yaml/
│
├── week2-networking/
│   ├── notes.md
│   ├── traffic-flow.md
│   ├── labs.md
│   └── yaml/
│
├── week3-troubleshooting/
│   ├── common-errors.md
│   ├── runbooks.md
│   └── scenarios.md
│
├── week4-platform/
│   ├── helm.md
│   ├── rbac.md
│   ├── observability.md
│   └── labs.md
│
├── week5-design/
│   ├── hld.md
│   ├── lld.md
│   └── architecture-diagrams/
│
├── week6-security/
│   ├── security-notes.md
│   ├── interview-questions.md
│
└── cheat-sheets/
    ├── kubectl.md
    ├── troubleshooting.md
    └── yaml-reference.md
```

---

## README.md Template

```markdown
# Kubernetes 6-Week Upgrade Plan

## Goal
Build Kubernetes, Platform Engineering, Design, and Security capability over 6 weeks.

---

## Week 1 – Foundations
- [-] Pods
- [ ] Deployments
- [ ] ReplicaSets
- [ ] Services
- [ ] Namespaces
- [ ] ConfigMaps / Secrets
- [ ] kubectl basics
- [ ] Labs complete

## Week 2 – Networking / Storage
- [ ] ClusterIP
- [ ] NodePort
- [ ] LoadBalancer
- [ ] Ingress
- [ ] DNS
- [ ] PV / PVC
- [ ] Labs complete

## Week 3 – Troubleshooting
- [ ] CrashLoopBackOff
- [ ] Pending pods
- [ ] Logs
- [ ] Events
- [ ] Resource issues
- [ ] Labs complete

## Week 4 – Platform Engineering
- [ ] Helm
- [ ] RBAC
- [ ] Service Accounts
- [ ] Observability
- [ ] CI/CD concepts

## Week 5 – Design
- [ ] HLD
- [ ] LLD
- [ ] Architecture diagrams
- [ ] Traffic flow design

## Week 6 – Security
- [ ] Network Policies
- [ ] Pod Security
- [ ] Secrets handling
- [ ] Interview Q&A

---

## Cheat Sheets
- kubectl
- troubleshooting
- YAML examples
```

---

## Sample Commands Cheat Sheet (`cheat-sheets/kubectl.md`)

```markdown
# kubectl Cheat Sheet

## Pods
kubectl get pods -A
kubectl describe pod <pod>
kubectl delete pod <pod>

## Deployments
kubectl get deploy
kubectl scale deploy <name> --replicas=3
kubectl rollout status deploy <name>

## Logs
kubectl logs <pod>
kubectl logs -f <pod>

## Exec
kubectl exec -it <pod> -- sh

## Events
kubectl get events

## Resources
kubectl top nodes
kubectl top pods
```

---

## Labs Template (`weekX/labs.md`)

```markdown
# Lab

## Objective
What am I learning?

## Steps
1.
2.
3.

## Commands Used
```bash
kubectl ...
```

## What Broke?

## How I Fixed It

## Key Learning
```

---

## Troubleshooting Template (`week3-troubleshooting/runbooks.md`)

```markdown
# Troubleshooting Runbook

## Symptom
Example: Pod CrashLoopBackOff

## Checks
- kubectl describe pod
- kubectl logs
- kubectl get events

## Possible Causes
- bad image
- bad env var
- probe failure

## Resolution

## Prevention
```

