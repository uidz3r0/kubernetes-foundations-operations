# W2D6 — StorageClasses

## Notes for KIND

Because you're using KIND, there is no cloud storage provisioner like AWS EBS CSI, so dynamic provisioning cannot fully happen.

That is actually a useful lesson:

- PVC requests storage
- StorageClass defines how storage should be created
- Provisioner performs the creation
- Without a provisioner, PVC remains Pending

This prepares you for later when you build clusters in AWS and install the Amazon EBS CSI Driver, where dynamic provisioning becomes fully functional. From a Kubernetes Foundations perspective, W2D6 is mainly about understanding the workflow rather than successfully provisioning cloud storage.

## Objective

Learn:

- What a StorageClass is
- Why StorageClasses exist
- Dynamic volume provisioning
- Default StorageClasses
- Relationship between:
  - StorageClass
  - PersistentVolume
  - PersistentVolumeClaim

---

## Why StorageClasses?

So far we manually created:

PV → PVC → Pod

This is called:

Static Provisioning

Example:

User creates a PV first.

Then a PVC consumes it.

This works but becomes difficult at scale.

---

## Dynamic Provisioning

Instead of creating PVs manually:

PVC -> StorageClass -> PV created automatically

Kubernetes asks the storage provider to create storage when needed.

Example providers:

- AWS EBS
- Azure Disk
- GCP Persistent Disk
- NFS Provisioners
- Ceph

---

## View StorageClasses

Show available StorageClasses:

```bash
kubectl get storageclass
```

or

```bash
kubectl get sc
```

Example output:

```
NAME                 PROVISIONER
standard (default)   ebs.csi.aws.com
```

(default) means PVCs use it automatically.

---

## Inspect a StorageClass

```bash
kubectl describe storageclass standard
```

Observe:

- Provisioner
- Reclaim policy
- Volume binding mode

---

## Create a StorageClass

Apply:

```bash
kubectl apply -f yaml/storageclass.yaml
```

Verify:

```bash
kubectl get storageclass
```

---

## Dynamic PVC

Apply:

```bash
kubectl apply -f yaml/pvc-dynamic.yaml
```

Check:

```bash
kubectl get pvc
```

Observe:

```bash
STATUS = Pending
```

Why?

Because KIND has no real cloud storage provisioner.

This is expected.

---

## StorageClass Flow

Traditional:

PV --> PVC --> Pod

Dynamic:

PVC --> StorageClass --> PV --> Pod

The PV is created automatically.

---

## Important Exam / Interview Concepts

### Reclaim Policy

Delete

- Remove storage when PVC is deleted

Retain

- Keep storage after PVC deletion

---

### VolumeBindingMode

Immediate

- Create storage immediately

WaitForFirstConsumer

- Wait until a Pod uses the PVC

---

## Useful Commands

List storage classes:

```bash
kubectl get sc
```

Describe storage class:

```bash
kubectl describe sc
```

List PVCs:

```bash
kubectl get pvc
```

Delete PVC:

```bash
kubectl delete pvc pvc-dynamic
```

Delete StorageClass:

```bash
kubectl delete sc demo-storageclass
```

---

## Questions

1. What problem does a StorageClass solve?
   - a StorageClass dynamically create PV on demand.
   - it eliminates the need for an administrator to manually pre-create every single PersistentVolume.

2. What is the difference between static and dynamic provisioning?
   - Static Provisioning: An administrator manually goes into AWS, creates a 10GB EBS disk, writes a pv.yaml file, and applies it to the cluster. Only then can a developer request it via a PVC. (This is what you did with your local-pv hostPath example).
   - Dynamic Provisioning: The administrator creates a StorageClass once. When a developer applies a PVC, the cluster instantly talks to the cloud provider (like AWS), spins up the disk automatically, and creates the PV on the fly.
   - Static provisioning requires an administrator to manually create the underlying storage and the PV object before a user can claim it. Dynamic provisioning automatically creates the underlying storage and the PV on-the-fly as soon as a PVC requests it, using a StorageClass template.

3. Why does the PVC remain Pending in KIND?
   - If a PVC is stuck in Pending in KIND, it's usually because the PVC is looking for a specific cloud storage class that doesn't exist, or the local path provisioner is waiting for a Pod to be scheduled first (volumeBindingMode: WaitForFirstConsumer).
   - Because KIND lacks a cloud provider's infrastructure (like AWS EBS). While KIND has a built-in local path storage provisioner, a PVC will remain Pending if it explicitly requests a non-existent cloud StorageClass, or if the storage class is waiting for a Pod to be scheduled to a node first before creating the volume.

4. What is a provisioner?
   - The infrastructure (like AWS) is the physical destination, but the provisioner is the literal software plugin or driver (the CSI driver) inside Kubernetes that knows how to translate a Kubernetes YAML file into an API call that commands AWS to create a disk.
   - A provisioner is the software plugin or volume driver (such as kubernetes.io/aws-ebs or a CSI driver) that executes the actual API calls to an underlying storage infrastructure to create or delete physical volumes.

5. What is the purpose of a reclaim policy?
   - Reconnecting to storage is handled automatically by the PVC binding. The Reclaim Policy only answers one single question: "What should Kubernetes do with the physical storage disk and the PV after a developer deletes their PVC?
     - Does it wipe the disk and delete it from AWS (Delete)?
     - Does it leave the disk completely alone so a human can inspect the data (Retain)?

   - The reclaim policy dictates what happens to the underlying PersistentVolume and its actual physical storage after its associated PersistentVolumeClaim (PVC) is deleted. The options are either to keep the asset for manual cleanup (Retain) or automatically wipe and destroy it (Delete).