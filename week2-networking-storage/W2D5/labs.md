# W2D5 Lab Checklist

## StatefulSet Storage

- [ ] Apply statefulset-pvc.yaml
- [ ] Verify StatefulSet is running
- [ ] Verify Pods are created
- [ ] Verify PVCs are automatically created
- [ ] Describe one PVC
- [ ] Identify the PVC attached to nginx-0

---

## Scaling

- [ ] Scale StatefulSet to 3 replicas
- [ ] Verify nginx-2 is created
- [ ] Verify a new PVC is created for nginx-2

---

## Persistence

- [ ] Scale StatefulSet down to 1 replica
- [ ] Verify PVCs still exist
- [ ] Explain why StatefulSets preserve storage

---

## Knowledge Check

- [ ] Explain volumeClaimTemplates
- [ ] Explain per-Pod storage
- [ ] Explain why databases commonly use StatefulSets