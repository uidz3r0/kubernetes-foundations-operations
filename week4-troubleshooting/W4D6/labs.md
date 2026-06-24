# W4D6 – Mock CKA Scenarios

Rules:

- Do not open YAML files immediately.
- Use kubectl commands first.
- Solve using the least disruptive method.
- Record your investigation steps.
- Time yourself.

```bash
# Helpful check to AJ
k get all
k get pods,svc,endpoints
k get pods,pv,pvc,svc,endpoints
```

---

## Scenario 1

Fix app1.

### Root cause

ConfigMap defines key `APP_MODE` but the pod references `APPMODE` (missing underscore). Pod fails with `InvalidEnvironmentVariableNames` — the key doesn't exist in the ConfigMap.

### Fix

```yaml
# scenario1.yaml — pod env section
valueFrom:
  configMapKeyRef:
    name: app-config
    key: APP_MODE   # was: APPMODE
```

```bash
kubectl describe pod app1         # shows CreateContainerConfigError
kubectl get configmap app-config -o yaml   # confirms key is APP_MODE
kubectl edit pod app1             # fix key name
```

---

## Scenario 2

Users cannot reach web-service.

### Root cause

Service selector has a typo: `app: frontent` — doesn't match the pod label `app: frontend`. The service has no endpoints.

### Fix

```bash
kubectl get endpoints web-service   # shows <none>
kubectl describe svc web-service    # reveals selector mismatch
kubectl edit svc web-service        # fix: frontent → frontend
```

---

## Scenario 3

scheduler-problem remains Pending.

### Root cause

Pod has `nodeSelector: disk: ssd` but no node in the cluster has that label. Scheduler can't place it anywhere.

### Fix

```bash
kubectl describe pod scheduler-problem   # shows 0/N nodes match nodeSelector
kubectl get nodes --show-labels          # confirms no node has disk=ssd

# Option A — label a node
kubectl label node <node-name> disk=ssd

# Option B — remove the nodeSelector from the pod manifest
kubectl edit pod scheduler-problem
```

---

## Scenario 4

storage-app cannot start.

### Root cause

Pod references `claimName: missing-pvc` but the PVC deployed is named `data-pvc`. Pod stays Pending because the referenced PVC doesn't exist.

### Fix

```bash
kubectl describe pod storage-app   # shows Unable to attach/mount volumes: PVC missing-pvc not found
kubectl get pvc                    # shows data-pvc exists, missing-pvc does not
kubectl edit pod storage-app       # fix claimName: missing-pvc → data-pvc
```

---

## Scenario 5

broken-app continually restarts.

### Root cause

Container command is `exit 1` — it exits immediately with a failure code every time. Kubelet keeps restarting it → CrashLoopBackOff.

### Fix

```bash
kubectl logs broken-app            # empty — exits instantly
kubectl describe pod broken-app    # shows Exit Code 1, BackOff restarting

kubectl edit pod broken-app
# change command to something that stays alive:
# - sleep 3600
```

---

## Scenario 6

The application stack is unavailable. Restore functionality.

### Root cause — three bugs

1. **nodeSelector** `environment: prod` — no node has this label, pod stays Pending.
2. **Image** `nginx:99` — tag doesn't exist, causes `ImagePullBackOff`.
3. **Service selector** `app: wrong` — doesn't match pod label `app: demo`, service has no endpoints.

### Fix

```bash
kubectl describe pod full-trouble    # reveals Pending + ImagePullBackOff
kubectl get nodes --show-labels      # confirms no node has environment=prod
kubectl get endpoints full-service   # shows <none>
kubectl describe svc full-service    # reveals selector mismatch

kubectl edit pod full-trouble
# 1. remove nodeSelector block
# 2. fix image: nginx:99 → nginx

kubectl edit svc full-service
# 3. fix selector: app: wrong → app: demo
```

---

## Summary

| Scenario | Category | Bug |
|---|---|---|
| 1 | ConfigMap | Key name typo (`APPMODE` vs `APP_MODE`) |
| 2 | Service | Selector typo (`frontent` vs `frontend`) |
| 3 | Scheduling | nodeSelector label doesn't exist on any node |
| 4 | Storage | PVC name mismatch (`missing-pvc` vs `data-pvc`) |
| 5 | CrashLoop | Command always exits with code 1 |
| 6 | Multi-issue | nodeSelector + bad image tag + service selector wrong |