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

### The Binding Phase - Chain of Custody

$$\text{Pod} \longrightarrow \text{PVC} \longrightarrow \text{PV} \longrightarrow \text{Physical Storage (/tmp/k8s-data)}$$

Here is how those specific YAML files shake hands behind the scenes:

1. The Pod looks at the PVC

  Inside "pod-storage.yaml", your Pod says: "I want a volume named storage-volume, and I want to back it with a claim named local-pvc." * The Link: claimName: local-pvc matches the metadata.name: local-pvc inside your pvc.yaml.

2. The PVC looks for a matching PV (The Magic Step)

  When you run kubectl apply -f pvc.yaml, the Kubernetes control plane looks at the requirements inside your claim:

    - It needs ReadWriteOnce access.
    - It needs at least 500Mi of space.

  Kubernetes then scans the cluster's available PersistentVolumes to find a match. It looks at your pv.yaml and says: "Aha! local-pv has ReadWriteOnce and offers 1Gi (which is plenty for a 500Mi request). I will Bind them together."

  Once bound, that PV belongs exclusively to that PVC. No other claim can steal it.

3. The PV points to the Real World
 
  Your pv.yaml has a property called hostPath.path: /tmp/k8s-data. This is the literal directory on your worker node's physical hard drive.

  How to see this relationship in the terminal

  If you want to prove to yourself that they are connected, run these two diagnostic commands:

   1. Check the PVC Status
   
```bash
kubectl get pvc local-pvc -n w2d1
```

  What to look for: Under the VOLUME column, you will see it explicitly print local-pv. Under STATUS, it will say Bound.

   2. Check the PV Status
```bash
kubectl get pv local-pv
```

  What to look for: Under the CLAIM column, you will see it explicitly print w2d1/local-pvc, proving that the cluster-level volume has successfully locked eyes with your namespace-scoped claim.

  The node running the cluster will have this physical file /tmp/k8s-data/test.txt

---

# Cleanup

```bash
kubectl delete namespace w2d1
kubectl delete pv local-pv
```

---

# Questions W2D1

1. What is the difference between a Pod and a Service?
    - A Pod is the smallest deployable unit running your container application, while a Service provides a stable network endpoint to load balance traffic across a group of matching Pods.

2. Why is a Service needed if Pods already have IP addresses?
    - Because Pods are ephemeral and their IP addresses change whenever they are recreated. A Service provides a permanent, stable IP address that abstracts those shifting Pod IPs so other applications don't lose connection.

3. What does ClusterIP expose?
    - ClusterIP exposes the Service on an internal cluster IP, allowing access to the selected Pods from "inside" the cluster only.

4. What does NodePort expose?
    - NodePort exposes the Service on a port on every node, so traffic from outside the cluster can reach the Pods via nodeIP:nodePort.

5. What is a selector in a Service?
    - A selector in a Service matches the labels of Pods. It allows the Service to automatically discover and route traffic to Pods with matching metadata labels.

6. What happens if labels do not match selectors?
    - The Service will still exist, but its Endpoints list will be empty. As a result, any traffic hitting the Service will have nowhere to go and will drop or timeout because no Pods match the criteria.
  
7. What is a PersistentVolume (PV)?
    - A PersistentVolume (PV) is cluster-level storage resource provided by the Kubernetes cluster. It exists independently of Pods and can persist data beyond the lifecycle of a Pod.
    - A PV can be implemented using local disks, EBS, NFS, EFS or other storage systems.

8. What is a PersistentVolumeClaim (PVC)?
    - A PVC is a namespace-scoped request for storage that binds to a PV; Pods use the PVC to mount storage.

9.  What happens to data after a Pod is deleted without persistent storage?
    - Without persistent storage, Pod data is ephemeral and is lost when the Pod is deleted. The data lasts only for the Pod’s lifecycle.

10. Why did the file still exist after recreating the Pod?
    - The file still exists because it was saved to a durable PersistentVolume (PV). When the new Pod was recreated, it claimed the same PersistentVolumeClaim (PVC), reconnecting it to that persistent storage. The Pod mounts the PVC, which is bound to the PV.