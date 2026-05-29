# W2D1 - Networking / Storage Lab Checklist

## Environment Setup

* [x] Create folder structure
* [x] Create `yaml/` directory
* [x] Create namespace `w2d1`

---

# Networking

## Pod Networking

* [x] Create nginx Pod
* [x] Verify Pod is running
* [x] Enter Pod using `kubectl exec`
* [x] Test localhost connectivity

---

## ClusterIP Service

* [x] Create ClusterIP Service
* [x] Verify Service exists
* [x] Create temporary busybox client Pod
* [x] Test connectivity to Service
* [x] Verify Service resolves internally

---

## NodePort Service

* [x] Create NodePort Service
* [x] Verify NodePort assigned
* [x] Get node IP
* [x] Access application using browser or curl
* [x] Verify external access works

---

# Storage

## PersistentVolume

* [x] Create PersistentVolume
* [x] Verify PV status

---

## PersistentVolumeClaim

* [x] Create PVC
* [x] Verify PVC is Bound

---

## Pod with Storage

* [x] Create Pod using PVC
* [x] Verify Pod is running
* [x] Write file into mounted storage
* [x] Delete Pod
* [x] Recreate Pod
* [x] Verify file still exists

---

# Cleanup

* [x] Delete namespace
* [x] Delete PV

---

# Completion Notes

Date Completed:

Notes:

Issues Encountered:

Key Learnings:
