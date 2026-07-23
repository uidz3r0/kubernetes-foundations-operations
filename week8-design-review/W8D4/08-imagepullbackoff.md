# ImagePullBackOff

Meaning

Node cannot download image.

---

## Verify

```
kubectl describe pod
```

Look at Events.

---

## Common Causes

Wrong image name

Wrong tag

Private registry

Registry unavailable

ImagePullSecret missing

---

## Verify Secret

```
kubectl get secrets
```