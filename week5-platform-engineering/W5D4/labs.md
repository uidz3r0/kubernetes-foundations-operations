# W5D4 Labs — CI/CD into Kubernetes

---

## Lab 1 — Create Cluster

```
kind create cluster --config yaml/kind-config.yaml
```

Verify

```
kubectl get nodes
```

---

## Lab 2 — Deploy Application

```
kubectl apply -f yaml/app-deployment.yaml
kubectl apply -f yaml/app-service.yaml
```

Verify

```
kubectl get pods
kubectl get deploy
kubectl get svc
```

---

## Lab 3 — Observe Rollout

```
kubectl rollout status deployment/demo-app
```

Describe deployment

```
kubectl describe deployment demo-app
```

---

## Lab 4 — Update Image

Current image

```
kubectl get deploy demo-app -o yaml | grep image
```

Update

```
kubectl set image deployment/demo-app app=nginx:1.27
```

Watch rollout

```
kubectl rollout status deployment/demo-app
```

Watch Pods

```
kubectl get pods -w
```

Observe old Pods terminate while new Pods become Ready.

---

## Lab 5 — Rollback

View history

```
kubectl rollout history deployment/demo-app
```

Undo

```
kubectl rollout undo deployment/demo-app
```

Verify

```
kubectl rollout status deployment/demo-app
```

---

## Lab 6 — Pipeline Walkthrough

Open

```
yaml/pipeline-example.yaml
```

Identify:

- Checkout
- Build
- Push
- Deploy

You are reading the pipeline—not executing it.

---

## Lab 7 — Simulate Deployment

```
kubectl apply -f yaml/app-deployment.yaml
```

Apply again

```
kubectl apply -f yaml/app-deployment.yaml
```

Notice

```
configured
```

No unnecessary Pods recreated.

---

## Challenge

Without notes:

- Deploy application
- Upgrade image
- Watch rollout
- Rollback
- Confirm previous version restored

Target:

< 10 minutes