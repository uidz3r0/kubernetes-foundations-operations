# W2D2 - Kubernetes Storage, PersistentVolumes (PV) and PersistentVolumeClaims (PVC)

## Objective

Learn how Kubernetes handles persistent storage using:

- PersistentVolumes (PV)
- PersistentVolumeClaims (PVC)
- Pods mounting storage
- Storage lifecycle concepts
- Difference between ephemeral and persistent data

---

# Part 1 - Why Persistent Storage Matters

Containers are ephemeral.

If a Pod is deleted:
- the container filesystem is destroyed
- logs/files inside the container are lost
- application data disappears

Kubernetes solves this using persistent storage.

---

# Part 2 - Storage Concepts

## PersistentVolume (PV)

A PersistentVolume is:
- a storage resource in the cluster
- provisioned manually or dynamically
- backed by:
  - AWS EBS
  - NFS
  - local disk
  - Ceph
  - cloud storage systems

Think of it as: "actual storage"

---

## PersistentVolumeClaim (PVC)

A PVC is:
- a request for storage
- created by users/apps
- attached to Pods

Think of it as: "requesting storage from Kubernetes"

---

## Relationship


Pod -> PVC -> PV -> Actual Storage

# Part 3 - Create a Namespace

```
kubectl create namespace storage-lab
```

Set default namespace:

```
kubectl config set-context --current --namespace=storage-lab
kubectl config view --minify | grep namespace:
```

# Part 4 - Create a PersistentVolume

Create file:

```
vim pv.yaml
```

Paste:

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: demo-pv
spec:
  capacity:
    storage: 1Gi

  accessModes:
    - ReadWriteOnce

  persistentVolumeReclaimPolicy: Retain

  hostPath:
    path: /mnt/data
```

Apply:

```
kubectl apply -f pv.yaml
kubectl get pv
kubectl describe pv demo-pv
```

# Part 5 - Create a PersistentVolumeClaim

Create file:

```
vim pvc.yaml
```

Paste:
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: demo-pvc
spec:
  accessModes:
    - ReadWriteOnce

  resources:
    requests:
      storage: 500Mi
```

Apply:
```
kubectl apply -f pvc.yaml
kubectl get pvc
```

Check binding:

```
kubectl get pv
```

Expected:

PVC status = Bound
PV status = Bound

# Part 6 - Create a Pod Using the PVC

Create file:

```
vim pod.yaml
```

Paste:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: storage-pod
spec:
  containers:
  - name: app
    image: nginx

    volumeMounts:
    - mountPath: /usr/share/nginx/html
      name: web-storage

  volumes:
  - name: web-storage
    persistentVolumeClaim:
      claimName: demo-pvc
```

Apply:

```
kubectl apply -f pod.yaml
kubectl get pods
```

# Part 7 - Write Data to Persistent Storage

Enter Pod:

```
kubectl exec -it storage-pod -- bash
```

Create test file:

```
echo "Persistent Storage Test" > /usr/share/nginx/html/index.html

exit
```

Verify from outside:

```
kubectl exec storage-pod -- cat /usr/share/nginx/html/index.html
```

# Part 8 - Test Persistence

Delete Pod:

```
kubectl delete pod storage-pod
```

Recreate Pod:

```
kubectl apply -f pod.yaml
```

Verify file still exists:
```
kubectl exec storage-pod -- cat /usr/share/nginx/html/index.html
```
Expected:

file should still exist
storage persisted beyond Pod lifecycle

# Part 9 - Observe Kubernetes Objects

View all resources:

```
kubectl get all
```

View PV:
```
kubectl get pv
```

View PVC:
```
kubectl get pvc
```

Describe PVC:
```
kubectl describe pvc demo-pvc
```

# Part 10 - Cleanup

Delete Pod:

```
kubectl delete pod storage-pod
kubectl delete pvc demo-pvc
kubectl delete pv demo-pv
kubectl delete namespace storage-lab
```

# Important Concepts

## Access Modes

ReadWriteOnce (RWO)

- mounted read-write by one node

ReadOnlyMany (ROX)

- mounted read-only by many nodes

ReadWriteMany (RWX)

- mounted read-write by many nodes

## Reclaim Policies

Retain

- keeps storage after PVC deletion

Delete

- removes storage automatically

Recycle (deprecated)

- basic scrub and reuse

## Real-World AWS Examples

AWS EBS

- commonly used for RWO storage
- attached to one EC2 node

AWS EFS
- supports RWX
- multiple Pods/nodes can share storage

## Questions

1. What problem do PersistentVolumes solve?
   - They decouple storage from the Pod lifecycle, ensuring data survives Pod deletions and restarts by mapping container directories to durable external infrastructure.
2. What is the difference between PV and PVC?
   - A PV is the actual, cluster-wide storage resource provisioned by an administrator. A PVC is a namespace-scoped request for storage by a user that binds to a matching PV, allowing a Pod to mount it.
3. What happens to container data when a Pod is deleted without persistent storage?
   - Without persistent storage, any container data will be deleted along with the Pod.
4. What does it mean when a PVC is "Bound"?
   - Bound means the PVC has successfully been matched to a PV and can be used by Pods.
5. What is the relationship between Pod, PVC, and PV?
   - A Pod uses a PVC, and the PVC is bound to a PV. The PVC is the claim that connects the Pod to actual storage.
6. Why did the file remain after deleting the Pod?
   - The the file remained because it was saved on durable persistent storage.
7. What does ReadWriteOnce mean?
   - ReadWriteOnce (RWO) means a volume can be mounted as read-write by a single node at a time, not necessarily just one Pod or one container. Multiple Pods on that node may still access the volume. AWS EBS is a common example of RWO storage.
8. What does the Retain reclaim policy do?
   - Retain means Kubernetes keeps the PV and its data after the PVC is deleted; it does not automatically delete the underlying storage.
9. Why is persistent storage important for databases?
   - persistent storage ensures data durability, meaning data survives in the event of DB crashes and outages. It keeps your actual, permanent data safe.
10. What type of AWS storage commonly backs Kubernetes PersistentVolumes?
    - AWS EBS is commonly used for RWO PVs, and AWS EFS is used for RWX/shared volumes.
11. What is the difference between ephemeral and persistent storage?
    - Ephemeral storage is temporary; persistent storage survives Pod restarts and deletion.
12. Why might EFS be preferred over EBS in some Kubernetes workloads?
    - Because EFS supports ReadWriteMany (RWX), allowing multiple Pods running on completely different worker nodes to simultaneously read and write to the exact same storage volume, whereas EBS is limited to a single node (ReadWriteOnce).
13. Can a Pod directly use a PV without a PVC?
    - Standard practice requires a PVC to act as the broker to bind to a PV. However, a Pod can technically mount raw storage inline (like a local hostPath), but it bypasses the entire PV management framework.
14. What would happen if the PVC requested more storage than the PV provides?
    - The PVC will remain stuck in a Pending state because it cannot find an available PV large enough to satisfy the request. Consequently, the Pod will be stuck in a Pending or ContainerCreating state because its required volume cannot be bound.
15. What Kubernetes object connects a Pod to storage?
    - a PVC, not a PV.
