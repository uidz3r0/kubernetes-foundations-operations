# W5D7 — Platform Engineering Integration Lab

Today combines every topic from Week 5 into one realistic deployment workflow.

Topics covered:

- Helm concepts
- RBAC
- Service Accounts
- Observability
- CI/CD concepts
- GitOps concepts
- Gateway API

Instead of learning something new, the objective is to deploy an application exactly as a platform team would.

Deployment flow:

Developer
    ↓
Git Repository
    ↓
CI Pipeline
    ↓
Container Image
    ↓
GitOps Repository Update
    ↓
Cluster Sync
    ↓
Helm Release
    ↓
Deployment
    ↓
Service
    ↓
Gateway API
    ↓
Users

Security

Developer
↓

ServiceAccount

↓

Role

↓

RoleBinding

↓

Application

Networking

Gateway

↓

HTTPRoute

↓

Service

↓

Pods

Observability

kubectl logs

kubectl describe

kubectl top

Events

GitOps

Git Repository contains desired state.

Cluster always reconciles to Git.

No manual kubectl apply in production.

This concludes Phase 1 Platform Engineering fundamentals.

---

## Week 5 Final Architecture

```bash
                  +-----------------------+
                  |      Developer        |
                  +-----------+-----------+
                              |
                              v
                     Git Repository
                              |
                              v
                       CI/CD Pipeline
                              |
                              v
                     Container Registry
                              |
                              v
                    GitOps Repository
                              |
                              v
                     GitOps Controller
                   (e.g., Argo CD/Flux)
                              |
                              v
                      Helm Release/Chart
                              |
                              v
+--------------------------------------------------------------+
|                     Kubernetes Cluster                       |
|                                                              |
|  ServiceAccount --> Role --> RoleBinding                     |
|             |                                                |
|             v                                                |
|        Deployment --> ReplicaSet --> Pods                    |
|             |                                                |
|             v                                                |
|          Service --> HTTPRoute --> Gateway --> Client        |
|                                                              |
|  Logs • Events • Metrics • kubectl top • describe            |
+--------------------------------------------------------------+
```