# W2D5 — StatefulSet Storage

## Goal

Learn how StatefulSets create persistent storage for each Pod using:

- volumeClaimTemplates
- PersistentVolumeClaims
- Stable storage per Pod

---

### Prep

`kubectl delete namespace week2`
`kubectl create namespace week2`

Set default namespace:

`kubectl config set-context --current --namespace=week2`
`kubectl config view --minify | grep namespace:`

## Why StatefulSets Need Storage

Deployments create identical Pods.

StatefulSets create Pods with unique identities:

```text
nginx-0
nginx-1
nginx-2
```

Each Pod may require its own storage.

Examples:

- Databases
- Message queues
- Search engines

---

## volumeClaimTemplates

A StatefulSet can automatically create a PVC for every Pod.

Example:

```yaml
volumeClaimTemplates:
- metadata:
    name: data
  spec:
    accessModes:
      - ReadWriteOnce
    resources:
      requests:
        storage: 1Gi
```

Kubernetes automatically creates:

```text
data-nginx-0
data-nginx-1
```

Each Pod receives its own storage.

---

## Apply the StatefulSet

Create the StatefulSet:

```bash
kubectl apply -f yaml/statefulset-pvc.yaml
```

---

## Verify StatefulSet

```bash
kubectl get statefulset
```

Expected:

```text
NAME    READY
nginx   2/2
```

---

## Verify Pods

```bash
kubectl get pods
```

Expected:

```text
nginx-0
nginx-1
```

---

## Verify PVCs

```bash
kubectl get pvc
```

Expected:

```text
data-nginx-0
data-nginx-1
```

Notice:

- One PVC per Pod
- PVC names contain Pod names

---

## Describe a PVC

```bash
kubectl describe pvc data-nginx-0
```

Observe:

- Requested storage
- Access mode
- Bound volume

---

## Scale the StatefulSet

Increase replicas:

```bash
kubectl scale statefulset nginx --replicas=3
```

Check:

```bash
kubectl get pods
kubectl get pvc
```

Observe:

```text
nginx-2
data-nginx-2
```

A new Pod receives a new PVC automatically.

---

## Scale Down

```bash
kubectl scale statefulset nginx --replicas=1
```

Check:

```bash
kubectl get pvc
```

Observe:

PVCs remain.

Storage is preserved even when Pods are removed.

---

## Cleanup

```bash
kubectl delete -f yaml/statefulset-pvc.yaml
```

Check:

```bash
kubectl get pvc
```

Depending on the storage backend, PVCs may still remain.

---

## Questions

1. Why does each StatefulSet Pod require its own storage?
   - because StatefulSet have this feature called the Volume Claim Template, which requires a dedicated persistent volume for each Pod.
   - If they shared a single volume, database engines would overwrite each other's transaction logs and cause immediate data corruption.

2. What does volumeClaimTemplates create?
   - it creates a dedicated Volume storage for each StatefulSet created, and re-assigned the same storage volume to a StatefulSet Pod.
   - It acts like a factory. Instead of you manually writing 5 different PVC YAML files for 5 database pods, the template automatically stamps out a unique PVC every time the controller scales up.

3. What PVC name is generated for nginx-0?
   - data-nginx-0 its a combination of [volume-mount-name]-[StatefulSet-pod-name]
   - That explicit syntax (<volumeClaimTemplate-name>-<pod-name>) is exactly how Kubernetes guarantees deterministic mapping.

4. What happens when the StatefulSet scales to three replicas?
   - If StatefulSet scales up, it checks if a number in Volume is already exist, if not it creates a new one for the equivalent StatefulSet Pod.
   - When scaling to 3 replicas (pods 0, 1, and 2), it boots nginx-2. It checks for data-nginx-2. If it doesn’t exist, it talks to the StorageClass to dynamically provision the underlying cloud block storage or network share on the fly.

5. Why are PVCs usually preserved when Pods are removed?
   - PVC's are preserved in case a new StatefulSet Pod will bind it.
   - This is a safety feature built into Kubernetes to prevent data loss. Scaling down a database shouldn't mean deleting the data. If you accidentally scale down from 3 to 2, and then scale back up to 3, nginx-2 will attach right back to its old preserved volume with zero data loss.