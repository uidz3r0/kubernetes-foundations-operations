# W4D4 Storage Troubleshooting Labs

## Lab 1 - Missing PVC

Apply:

kubectl apply -f yaml/missing-pvc-pod.yaml

Questions:

1. Why is the pod Pending?
2. Which PVC is missing?
3. Fix the issue.

---

## Lab 2 - Unbound PVC

Apply:

kubectl apply -f yaml/unbound-pvc.yaml

Questions:

1. Why is the PVC Pending?
2. Is a PV available?
3. Fix the issue.

---

## Lab 3 - Wrong StorageClass

Apply:

kubectl apply -f yaml/wrong-storageclass-pvc.yaml

Questions:

1. Which StorageClass is requested?
2. Does it exist?
3. Fix the issue.

---

## Lab 4 - Read Only Volume

Apply:

kubectl apply -f yaml/readonly-volume-pod.yaml

Questions:

1. Why is the pod crashing?
2. What do logs show?
3. Fix the issue.

---

## Lab 5 - Mount Investigation

Apply:

kubectl apply -f yaml/broken-mountpath-pod.yaml

Questions:

1. Where is the volume mounted?
2. How can you verify mounts inside the container?
3. Correct the configuration.

---

## Challenge Lab

Create:

- PV (1Gi)
- PVC (1Gi)
- Pod using the PVC

Then intentionally break:

- PVC name
- StorageClass
- Access mode

Troubleshoot and repair each issue.