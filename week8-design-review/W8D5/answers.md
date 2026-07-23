
1. 
kubectl create namespace demo
k get ns

2.
kubectl create secret generic postgres-secret \
--from-literal=username=postgres \
--from-literal=password=password \
-n demo

k get secrets -n demo

3. 

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner # indicates that this StorageClass does not support automatic provisioning
volumeBindingMode: WaitForFirstConsumer
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: demo-pv
spec:
  capacity:
    storage: 10Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  local:
    path: /opt/data
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - leia    # the storage path exist only in leia
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: demo-pvc
  namespace: demo  
spec:
  storageClassName: "local-storage" # Empty string must be explicitly set otherwise default StorageClass will be set
  volumeName: demo-pv
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi  
```