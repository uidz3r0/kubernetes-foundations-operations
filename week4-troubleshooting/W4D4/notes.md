# W4D4 Notes

### W4D4 Learning Objectives

By the end of W4D4 you should be comfortable with:

- PVC not found
- PVC Pending
- PV/PVC binding failures
- StorageClass problems
- FailedMount events
- Read-only volume issues
- Volume mount troubleshooting
- `kubectl describe`
- `kubectl get pvc`
- `kubectl get pv`
- `kubectl get storageclass`
- `kubectl get events`

This aligns very closely with the storage troubleshooting tasks that appear in the CKA exam and the troubleshooting workflow you'll use in W4D6 Mock Scenarios.

## Storage Troubleshooting Workflow

### 1. Check Pod Status

`kubectl get pods`

Common symptoms:

- Pending
- ContainerCreating
- CrashLoopBackOff

### 2. Describe Pod

`kubectl describe pod <pod>`

Look for:

- PVC not found
- FailedMount
- FailedAttachVolume

### 3. Check PVC

`kubectl get pvc`

`kubectl describe pvc <pvc>`

Look for:

- Pending
- StorageClass issues
- No matching PV

### 4. Check PV

`kubectl get pv`

`kubectl describe pv <pv>`

Verify:

- Capacity
- AccessModes
- Claim binding

### 5. Check StorageClasses

`kubectl get storageclass`

Verify:

- Default class
- Provisioner

### 6. Check Events

`kubectl get events --sort-by=.metadata.creationTimestamp`

### 7. Inspect Mounts

`kubectl exec -it <pod> -- sh`

mount
df -h

---

## Storage Check Flow

Pod > PVC > PV > StorageClass > Provisioner > Mount

|Stage|What you're checking|Command|
|---|---|---|
|Pod|Pending / ContainerCreating|kubectl describe pod > look for FailedMount, FailedAttachVolume|
|PVC | Is it Bound or Pending? | kubectl describe pvc|
|PV | Capacity + AccessModes match the claim? | kubectl describe pv|
|StorageClass | Default set? Correct provisioner? | kubectl get sc|
|Provisioner | Is the CSI driver / provisioner pod running?| kubectl get pods -n kube-system|
|Mount|Actually mounted inside container? RW vs RO?|kubectl exec -- mount / df -h|

### How it parallels your network flow

The logic is identical -- follow the binding chain from the consumer (Pod) down to the backing resource:

- Network: the Pod consumes a Service, which resolves to Endpoints, etc.
- Storage: the Pod consumes a PVC, which binds to a PV, which is provisioned by a StorageClass.

The single most important concept (and the #1 CKA storage gotcha) is the PVC <--> PV binding match. A PVC stays Pending if any of these don't match the PV:

- Capacity -- PVC requests more than PV offers
- AccessModes -- PVC wants `RWX` but PV only offers `RWO`
- StorageClassName -- must match exactly (including the empty-string `""` case for static provisioning)
- Selector/labels -- if the PVC uses a selector

