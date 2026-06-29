# W5D4 — CI/CD into Kubernetes

---

# Objectives

By the end of today you should understand:

- CI vs CD
- Typical Kubernetes deployment pipeline
- Image building
- Container registry
- Updating Deployments
- Rolling Updates
- Rollbacks
- kubectl image
- Basic pipeline YAML

This is platform engineering knowledge—not GitHub Actions mastery.

---

# Typical Flow

Developer

↓

Git Push

↓

CI Pipeline

- Run tests
- Build image
- Tag image
- Push image

↓

Container Registry

↓

CD

`kubectl apply`

or

`helm upgrade`

↓

Kubernetes

↓

Rolling Update

---

# CI

Continuous Integration

Goal:

Every code change is automatically validated.

Usually includes:

- lint
- unit tests
- security scan
- docker build

Example

Developer pushes code

↓

Pipeline

↓

`docker build`

↓

`docker push`

---

# CD

Continuous Delivery / Deployment

Pipeline deploys application.

Typical commands

`kubectl apply -f deployment.yaml`

or

`helm upgrade --install`

---

# Docker Build

Example

`docker build -t demo:v1 .`

Push

```bash
docker tag demo:v1 registry/demo:v1
docker push registry/demo:v1
```

---

# Updating Kubernetes

Initial deployment

image:

nginx:1.25

Upgrade

`kubectl set image deployment/demo-app app=nginx:1.27`

Syntax is `<container-name>=<image>`. Here the container is named `app`
(matches app-deployment.yaml).

Check rollout

`kubectl rollout status deployment/demo`

---

# Rollbacks

History

`kubectl rollout history deployment/demo`

Rollback

`kubectl rollout undo deployment/demo`

---

# Image Tags

Bad

latest

Good

1.0.3

Good

git-sha

Good

20260626-1430

Always use immutable tags.

---

# Registries

Examples

- Docker Hub
- GHCR
- Amazon ECR
- Google Artifact Registry
- Azure ACR
- Harbor

---

# Secrets

Never hardcode

PASSWORD=password

Instead

Secret

↓

Deployment

↓

Environment Variable

---

# Pipeline Stages

Typical

Checkout

↓

Build

↓

Test

↓

Security Scan

↓

Push Image

↓

Deploy

↓

Verify

---

# Example Deployment Flow

`git push`

↓

CI

↓

`docker build`

↓

`docker push`

↓

`kubectl apply`

↓

Deployment updated

↓

Pods replaced

---

# Kubernetes Rollout

Deployment

↓

ReplicaSet

↓

New Pods created

↓

Old Pods terminated

Zero downtime if readiness probes succeed.

## Rolling Update Knobs

Two fields under `spec.strategy.rollingUpdate` control the pace:

- `maxSurge` - how many extra Pods can be created above desired count
  during the update (e.g. 25% or an absolute number).
- `maxUnavailable` - how many Pods can be unavailable at once during
  the update.

Defaults are 25% each. These are the mechanism behind zero-downtime:
new Pods come up (surge) and only then are old Pods removed.

---

# Common Commands

```bash
kubectl rollout status deployment/app

kubectl rollout history deployment/app

kubectl rollout undo deployment/app

kubectl set image deployment/app app=nginx:1.27

kubectl describe deployment app | grep -i image

kubectl get rs

kubectl get pods -w

# AJ notes
kubectl rollout undo deployment.apps/demo-app
kubectl describe deployment.apps/demo-app | grep -i image
    Image:         nginx:1.27

kubectl rollout undo deployment.apps/demo-app
kubectl describe deployment.apps/demo-app | grep -i image
    Image:         nginx:1.25

kubectl rollout history deployment.apps/demo-app
    deployment.apps/demo-app 
    REVISION  CHANGE-CAUSE
    3        <none>
    4        <none>

kubectl rollout history deployment.apps/demo-app --revision=3 | grep -i image
    Image:      nginx:1.27

kubectl rollout history deployment.apps/demo-app --revision=4 | grep -i image
    Image:      nginx:1.25
```

---

# Interview Questions

1. Explain CI vs CD.

   - CI (Continuous Integration)
     - Every time code is updated, it's auto-validated 
     - ex: lint, test, security scan, build artifacts like Docker images
  
   - CD (Continuous Delivery/Deployment)
     - The pipeline automatically deploys the application 
     - `kubectl apply` or `helm upgrade`

2. Why avoid latest image tag?

   - its always better to use explicit, immutable tags

3. What is a rolling update?

   - rolling update is updating in batches to gradually replace old versions for zero downtime

4. How do you rollback?

   - note previous version via `kubectl history` and then `rollout undo`
   - rollback is easy if we use immutable, explicit image tags

5. How does Kubernetes achieve zero downtime?

   - by updating using `rolling update`

6. What happens after docker push?

   - docker uploads the image layers + image manifest to a container registry like Docker Hub, ECR, ACR, GCR. A separate CD step then updates the Kubernetes manifest to reference the new tag.

---

# Today's Takeaways

A Platform Engineer should understand:

✓ CI builds images

✓ Registry stores images

✓ CD deploys manifests

✓ Kubernetes performs rolling updates

✓ Rollbacks are easy

✓ Immutable tags improve reliability

---

### Why this day fits your roadmap

This covers the Kubernetes platform concepts you need before GitOps:

- ✅ CI vs CD fundamentals
- ✅ Docker image lifecycle
- ✅ Container registries
- ✅ Rolling updates and rollbacks
- ✅ kubectl rollout and kubectl set image
- ✅ Reading a simple CI pipeline
- ✅ Understanding how deployments reach a Kubernetes cluster

It intentionally avoids deep dives into GitHub Actions, Jenkins, GitLab CI, or Argo CD, which are implementation-specific and better covered after you've learned GitOps concepts in the next stage.