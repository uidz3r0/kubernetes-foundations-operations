# W2D1 - Networking / Storage Lab Checklist

## Environment Setup

* [ ] Create folder structure
* [ ] Create `yaml/` directory
* [ ] Create namespace `w2d1`

---

# Networking

## Pod Networking

* [ ] Create nginx Pod
* [ ] Verify Pod is running
* [ ] Enter Pod using `kubectl exec`
* [ ] Test localhost connectivity

---

## ClusterIP Service

* [ ] Create ClusterIP Service
* [ ] Verify Service exists
* [ ] Create temporary busybox client Pod
* [ ] Test connectivity to Service
* [ ] Verify Service resolves internally

---

## NodePort Service

* [ ] Create NodePort Service
* [ ] Verify NodePort assigned
* [ ] Get node IP
* [ ] Access application using browser or curl
* [ ] Verify external access works

---

# Storage

## PersistentVolume

* [ ] Create PersistentVolume
* [ ] Verify PV status

---

## PersistentVolumeClaim

* [ ] Create PVC
* [ ] Verify PVC is Bound

---

## Pod with Storage

* [ ] Create Pod using PVC
* [ ] Verify Pod is running
* [ ] Write file into mounted storage
* [ ] Delete Pod
* [ ] Recreate Pod
* [ ] Verify file still exists

---

# Cleanup

* [ ] Delete namespace
* [ ] Delete PV

---

# Completion Notes

Date Completed:

Notes:

Issues Encountered:

Key Learnings:
