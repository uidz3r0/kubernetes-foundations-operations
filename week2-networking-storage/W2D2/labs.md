
---

# `labs.md`

```markdown
# W2D2 - Kubernetes Persistent Storage Lab

## Namespace

- [ ] Create `storage-lab` namespace
- [ ] Set namespace as default context
- [ ] Verify namespace configuration

---

## PersistentVolume

- [ ] Create `pv.yaml`
- [ ] Define `demo-pv`
- [ ] Configure storage size
- [ ] Configure access mode
- [ ] Configure reclaim policy
- [ ] Apply PV manifest
- [ ] Verify PV creation
- [ ] Describe PV

---

## PersistentVolumeClaim

- [ ] Create `pvc.yaml`
- [ ] Define `demo-pvc`
- [ ] Request storage
- [ ] Apply PVC manifest
- [ ] Verify PVC creation
- [ ] Verify PVC successfully bound to PV

---

## Pod Using PVC

- [ ] Create `pod.yaml`
- [ ] Mount PVC into Pod
- [ ] Apply Pod manifest
- [ ] Verify Pod is running

---

## Persistence Testing

- [ ] Enter Pod shell
- [ ] Create test file in mounted storage
- [ ] Verify file contents
- [ ] Delete Pod
- [ ] Recreate Pod
- [ ] Verify file still exists after Pod recreation

---

## Kubernetes Object Inspection

- [ ] View all resources
- [ ] Inspect PV
- [ ] Inspect PVC
- [ ] Describe PVC

---

## Cleanup

- [ ] Delete Pod
- [ ] Delete PVC
- [ ] Delete PV
- [ ] Delete namespace

---

# Completion Goals

By the end of this lab you should understand:

- [ ] Difference between PV and PVC
- [ ] How Pods use persistent storage
- [ ] Difference between ephemeral and persistent data
- [ ] Storage persistence across Pod recreation
- [ ] Kubernetes storage lifecycle
- [ ] Basic storage concepts used in real Kubernetes environments

