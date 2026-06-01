# W2D4 — Kubernetes Volumes

## Objective

Learn the difference between:

- emptyDir
- hostPath
- Persistent Volumes

and understand when each should be used.

---

## emptyDir

An emptyDir volume is created when a Pod starts.

Characteristics:

- Exists only while Pod exists
- Shared between containers in the same Pod
- Deleted when Pod is removed

Use cases:

- Temporary cache
- Scratch space
- Shared files between containers

---

### Prep

`kubectl delete namespace week2`
`kubectl create namespace week2`

Set default namespace:

`kubectl config set-context --current --namespace=week2`
`kubectl config view --minify | grep namespace:`


### Deploy emptyDir Pod

```bash
kubectl apply -f yaml/emptydir-pod.yaml
kubectl get pods
```

Open a shell:

```bash
kubectl exec -it emptydir-demo -- sh
```

Create a file:

```bash
echo "hello" > /data/test.txt
cat /data/test.txt
```

Exit shell.

Delete Pod:

```bash
kubectl delete pod emptydir-demo
kubectl apply -f yaml/emptydir-pod.yaml
```

Check file again:

```bash
kubectl exec -it emptydir-demo -- cat /data/test.txt
```

Observe that the file is gone.

---

## hostPath

hostPath mounts a directory from the Kubernetes node.

Characteristics:

- Data survives Pod restart
- Tied to one node
- Common in labs and testing
- Not recommended for production workloads

Deploy:

```bash
kubectl apply -f yaml/hostpath-pod.yaml
```

Create file:

```bash
kubectl exec -it hostpath-demo -- sh
```

```bash
echo "persistent" > /data/test.txt
exit
```

Delete Pod:

```bash
kubectl delete pod hostpath-demo
kubectl apply -f yaml/hostpath-pod.yaml
```

Verify:

```bash
kubectl exec -it hostpath-demo -- cat /data/test.txt
```

Observe that the file still exists.

---

## Comparing Storage Types

| Type | Survives Pod Delete | Shared Across Nodes |
|--------|--------|--------|
| emptyDir | No | No |
| hostPath | Yes | No |
| PV/PVC | Yes | Yes (depends on backend) |

---

## Questions

1. What happens to emptyDir data after Pod deletion?
    - the data is gone since its temporal 

2. Why is hostPath not ideal for production?
    - Multiple Pods on the same node can share a "hostPath" because it mounts a directory directly from the underlying worker node's OS. The real reason it's not production-ready is Node Dependency / Portability. If Kubernetes reschedules your Pod onto a different node in the cluster, that new node won't have the files from the first node.

3. What problem do PVs solve that hostPath cannot?
    - PV's files survives if the Node dies
    - By backing them with network storage (like AWS EFS, EBS, or Ceph), the data is safe even if the entire physical worker node catches fire and crashes.

4. Which volume type would be suitable for temporary cache data?
    - temporary cache data is good for emptyDir
    - emptyDir is the textbook choice for scratch space, transient local caches, or high-speed data manipulation where persistence isn't required.