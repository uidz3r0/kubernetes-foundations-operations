# W2D1 - Networking / Storage

## Objectives

Today you will learn:

* Kubernetes networking basics
* Pod-to-Pod communication
* Services

  * ClusterIP
  * NodePort
* Basic storage concepts

  * PersistentVolume (PV)
  * PersistentVolumeClaim (PVC)
* Mounting persistent storage into Pods

---

# Part 1 - Kubernetes Networking

## Step 1 - Create Namespace

```bash
kubectl create namespace w2d1
```

Verify:

```bash
kubectl get ns
```

---

## Step 2 - Create a Web Pod

Create file:

```bash
vim yaml/pod-web.yaml
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-pod
  namespace: w2d1
  labels:
    app: web
spec:
  containers:
  - name: nginx
    image: nginx:latest
    ports:
    - containerPort: 80
```

Apply:

```bash
kubectl apply -f yaml/pod-web.yaml
```

Verify:

```bash
kubectl get pods -n w2d1 -o wide
```

---

## Step 3 - Test Pod Connectivity

Enter the Pod:

```bash
kubectl exec -it -n w2d1 web-pod -- bash
```

Inside the container:

```bash
apt update
apt install -y curl
curl localhost
```

Exit:

```bash
exit
```

---

# Part 2 - ClusterIP Service

## Step 4 - Create ClusterIP Service

Create file:

```bash
vim yaml/service-clusterip.yaml
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service
  namespace: w2d1
spec:
  type: ClusterIP
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 80
```

Apply:

```bash
kubectl apply -f yaml/service-clusterip.yaml
```

Verify:

```bash
kubectl get svc -n w2d1
```

---

## Step 5 - Test Service Connectivity

Run temporary Pod:

```bash
kubectl run test-client \
--image=busybox \
--restart=Never \
-it \
-n w2d1 -- sh
```

Inside the Pod:

```bash
wget -qO- web-service
```

Exit:

```bash
exit
```

---

# Part 3 - NodePort Service

## Step 6 - Create NodePort Service

Create file:

```bash
vim yaml/service-nodeport.yaml
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-nodeport
  namespace: w2d1
spec:
  type: NodePort
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
```

Apply:

```bash
kubectl apply -f yaml/service-nodeport.yaml
```

Verify:

```bash
kubectl get svc -n w2d1
```

---

## Step 7 - Access NodePort

Get node IP:

```bash
kubectl get nodes -o wide
```

Access from browser or curl:

```bash
curl http://NODE-IP:30080
```

---

# Part 4 - Kubernetes Storage

## Step 8 - Create PersistentVolume

Create file:

```bash
vim yaml/pv.yaml
```

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /tmp/k8s-data
```

Apply:

```bash
kubectl apply -f yaml/pv.yaml
```

Verify:

```bash
kubectl get pv
```

---

## Step 9 - Create PersistentVolumeClaim

Create file:

```bash
vim yaml/pvc.yaml
```

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: local-pvc
  namespace: w2d1
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
```

Apply:

```bash
kubectl apply -f yaml/pvc.yaml
```

Verify:

```bash
kubectl get pvc -n w2d1
```

---

## Step 10 - Create Pod Using PVC

Create file:

```bash
vim yaml/pod-storage.yaml
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: storage-pod
  namespace: w2d1
spec:
  containers:
  - name: busybox
    image: busybox
    command: ["sleep", "3600"]
    volumeMounts:
    - mountPath: "/data"
      name: storage-volume

  volumes:
  - name: storage-volume
    persistentVolumeClaim:
      claimName: local-pvc
```

Apply:

```bash
kubectl apply -f yaml/pod-storage.yaml
```

Verify:

```bash
kubectl get pods -n w2d1
```

---

## Step 11 - Test Persistent Storage

Enter Pod:

```bash
kubectl exec -it -n w2d1 storage-pod -- sh
```

Inside container:

```bash
echo "hello persistent storage" > /data/test.txt
cat /data/test.txt
```

Exit:

```bash
exit
```

Delete Pod:

```bash
kubectl delete pod storage-pod -n w2d1
```

Recreate:

```bash
kubectl apply -f yaml/pod-storage.yaml
```

Verify file still exists:

```bash
kubectl exec -it -n w2d1 storage-pod -- sh
cat /data/test.txt
```

---

# Cleanup

```bash
kubectl delete namespace w2d1
kubectl delete pv local-pv
```

---

# Questions

1. What is the difference between a Pod and a Service?
2. Why is a Service needed if Pods already have IP addresses?
3. What does ClusterIP expose?
4. What does NodePort expose?
5. What is a selector in a Service?
6. What happens if labels do not match selectors?
7. What is a PersistentVolume (PV)?
8. What is a PersistentVolumeClaim (PVC)?
9. What happens to data after a Pod is deleted without persistent storage?
10. Why did the file still exist after recreating the Pod?
