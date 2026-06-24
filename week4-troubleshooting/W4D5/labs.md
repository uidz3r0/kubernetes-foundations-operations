# Week 4 Day 5

## Lab 1 — Investigate Cluster Health

```bash
kubectl cluster-info
kubectl get nodes
kubectl get pods -A
kubectl get componentstatuses
```

### Questions

1. Which components run in kube-system?

   - All control-plane related resources are in kube-system namespace. 

2. Which pods belong to CoreDNS?

   - CoreDNS belongs to the two pods coredns-<hash> in `kube-system`

3. Is every node Ready?

   - Control-plane and worker nodes are all ready.

---

## Lab 2 — Event Troubleshooting

### Deploy

```bash
kubectl apply -f yaml/unhealthy-pod.yaml
```

### Tasks

1. Check pod status.

    - The `unhealthy-pod` pod Status = `Running`

2. View events.

    ```bash
    $ k events | tail -n 1
    103s (x21 over 3m18s)   Warning   Unhealthy   Pod/unhealthy-pod   Readiness probe failed: HTTP probe failed with statuscode: 404
    ```

3. Identify probe failure.

    ```bash
    $ k logs unhealthy-pod | tail -n 3
    10.244.1.1 - - [22/Jun/2026:04:42:28 +0000] "GET /badpath HTTP/1.1" 404 153 "-" "kube-probe/1.31" "-"
    2026/06/22 04:42:31 [error] 38#38: *64 open() "/usr/share/nginx/html/badpath" failed (2: No such file or directory), client: 10.244.1.1, server: localhost, request: "GET /badpath HTTP/1.1", host: "10.244.1.8:80"
    10.244.1.1 - - [22/Jun/2026:04:42:31 +0000] "GET /badpath HTTP/1.1" 404 153 "-" "kube-probe/1.31" "-"
    ```

4. Fix the readiness probe.

    ```bash
    k edit pod unhealthy-pod

    # then replace
            path: /badpath
    # with
            path: /

    k replace --force -f /tmp/kubectl-edit-1817720824.yaml
    k get pods | grep unhealthy
    unhealthy-pod   1/1     Running   0          14s
    ```

### Commands

```bash
kubectl describe pod unhealthy-pod
kubectl get events
kubectl logs unhealthy-pod
```

---

## Lab 3 — Cordoned Node

```bash
kubectl cordon worker2
kubectl apply -f yaml/cordoned-node-pod.yaml
```

### Tasks

1. Why is the pod Pending?

   - The pod is scheduled to a node that is marked as cordon, marked node is unschedulable.

2. Which node is unavailable?

   - worker2

   ```bash
   $ k get nodes
    NAME                 STATUS                     ROLES           AGE   VERSION
    w4d5-control-plane   Ready                      control-plane   98m   v1.31.0
    w4d5-worker          Ready                      <none>          98m   v1.31.0
    w4d5-worker2         Ready,SchedulingDisabled   <none>          98m   v1.31.0
   ```  

3. Restore scheduling.

   - `$ kubectl uncordon w4d5-worker2`

    ```bash
    $ k get pods | grep cordon
    cordoned-demo   1/1     Running   0          5m49s
    ```

---

## Lab 4 — CoreDNS Failure

Scale CoreDNS to zero.

    ```bash
    $ k get deployments coredns -n kube-system
    NAME      READY   UP-TO-DATE   AVAILABLE   AGE
    coredns   2/2     2            2           106m

    $ k scale --replicas=0 deployments/coredns -n kube-system
    deployment.apps/coredns scaled
    ```

### Tasks

1. Investigate DNS failure.

```bash
$ kubectl run dns-test --image=busybox --restart=Never -- nslookup kubernetes
pod/dns-test created

$ kubectl logs dns-test
nslookup: write to '10.96.0.10': Connection refused
;; connection timed out; no servers could be reached
```

2. Determine which system pods are unhealthy.

```bash
$ kubectl get pods
NAME            READY   STATUS    RESTARTS   AGE
cordoned-demo   1/1     Running   0          15h
dns-test        0/1     Error     0          2m19s
unhealthy-pod   0/1     Running   0          12m
```

3. Restore DNS.

    ```bash
    $ k scale --replicas=2 deployments/coredns -n kube-system
    $ k run dns-test2 --image=busybox --restart=Never -- nslookup kubernetes 

    $ k get pods
    NAME            READY   STATUS    RESTARTS   AGE
    cordoned-demo   1/1     Running   0          15h
    dns-test        0/1     Error     0          4m18s
    dns-test2       0/1     Error     0          7s
    unhealthy-pod   0/1     Running   0          14m

    $ k logs dns-test2
    Server:		10.96.0.10
    Address:	10.96.0.10:53

    Name:	kubernetes.default.svc.cluster.local
    Address: 10.96.0.1

    ** server can't find kubernetes.svc.cluster.local: NXDOMAIN
    ** server can't find kubernetes.svc.cluster.local: NXDOMAIN
    ** server can't find kubernetes.cluster.local: NXDOMAIN
    ** server can't find kubernetes.cluster.local: NXDOMAIN
    ** server can't find kubernetes.lan: NXDOMAIN
    ** server can't find kubernetes.lan: NXDOMAIN
    ```

    - created a new test pod `dns-test2`, even if `STATUS= Error` it actually managed to get a DNS reply from `Server:	10.96.0.10`

---

## Lab 5 — Static Pod Investigation

Create the static pod.

### Tasks

1. Locate the manifest.

- A static pod is NOT created with `kubectl apply`. It's created by placing a manifest file directly into `/etc/kubernetes/manifests/` on a node. The kubelet on that node watches that directory and starts the pod automatically â no scheduler involved.

```bash
$ k get nodes
NAME                 STATUS   ROLES           AGE   VERSION
w4d5-control-plane   Ready    control-plane   18h   v1.31.0
w4d5-worker          Ready    <none>          18h   v1.31.0
w4d5-worker2         Ready    <none>          18h   v1.31.0

$ docker exec -it w4d5-control-plane ls -l /etc/kubernetes/manifests/
-rw------- 1 root root 2547 Jun 21 12:12 etcd.yaml
-rw------- 1 root root 3896 Jun 21 12:12 kube-apiserver.yaml
-rw------- 1 root root 3428 Jun 21 12:12 kube-controller-manager.yaml
-rw------- 1 root root 1463 Jun 21 12:12 kube-scheduler.yaml

$ docker cp yaml/static-nginx.yaml w4d5-control-plane:/etc/kubernetes/manifests/static-nginx.yaml 
Successfully copied 137B (transferred 2.05kB) to w4d5-control-plane:/etc/kubernetes/manifests/static-nginx.yaml

$ docker exec -it w4d5-control-plane ls -l /etc/kubernetes/manifests/
-rw------- 1 root root 2547 Jun 21 12:12 etcd.yaml
-rw------- 1 root root 3896 Jun 21 12:12 kube-apiserver.yaml
-rw------- 1 root root 3428 Jun 21 12:12 kube-controller-manager.yaml
-rw------- 1 root root 1463 Jun 21 12:12 kube-scheduler.yaml
-rw-rw-r-- 1 1001 1001  137 Jun 21 10:59 static-nginx.yaml

# Pod appears automatically - notice the node name suffix
$ k get pods | grep static
static-nginx-w4d5-control-plane   1/1     Running   0          47s
```

2. Determine why the pod exists.

- The pod exist because kubelet found the manifest in `/etc/kubernetes/manifests/`. It's NOT scheduled - it runs on exactly the node where the file lives.  

3. Remove the pod.

```bash
# Delete the FILE, not the pod, otherwise kubelet just recreates it immediately
$ docker exec w4d5-control-plane rm /etc/kubernetes/manifests/static-nginx.yaml

$ docker exec -it w4d5-control-plane ls -l /etc/kubernetes/manifests/
total 16
-rw------- 1 root root 2547 Jun 21 12:12 etcd.yaml
-rw------- 1 root root 3896 Jun 21 12:12 kube-apiserver.yaml
-rw------- 1 root root 3428 Jun 21 12:12 kube-controller-manager.yaml
-rw------- 1 root root 1463 Jun 21 12:12 kube-scheduler.yaml
```

- That's why control plane components (etcd, kube-apiserver, etc.) are static pods - they need to exist even before the API server is running.

---

## Lab 6 — Control Plane Inspection

Run:

```bash
docker ps
docker exec -it w4d5-control-plane bash

crictl ps
crictl logs <container-id>

# Check what kubelet sees
journalctl -u kubelet -n 50 --no-pager
```

### Questions:

1. Where does the API server run?
 
   - As a static pod on the control-plane node, managed directly by kubelet.
   - Pod name: `kube-apiserver-w4d5-control-plane` in `kube-system`

    ```bash
    $ docker exec -it w4d5-control-plane bash
    # crictl ps | grep -E "NAME|api"
    CONTAINER           IMAGE               CREATED             STATE               NAME                      ATTEMPT             POD ID              POD
    32083abad3d7b       4f8c99889f8e4       2 hours ago         Running             kube-apiserver            0                   c2b1208a8612b       kube-apiserver-w4d5-control-plane

    # hostname
        w4d5-control-plane
    ```

2. Which container runs etcd?

   - Also a static pod on the control-plane node.
   - Pod name: `etcd-w4d5-control-plane` in `kube-system`

    ```bash
    $ k get pod -A
    $ k get pod etcd-w4d5-control-plane -n kube-system
    NAME                      READY   STATUS    RESTARTS   AGE
    etcd-w4d5-control-plane   1/1     Running   0          149m

    $ k describe pod etcd-w4d5-control-plane -n kube-system
    ```

3. Which manifests create control-plane components?

    ```bash
    $ docker exec -it w4d5-control-plane bash
    root@w4d5-control-plane:/# ls -l /etc/kubernetes/manifests/
    total 16
    -rw------- 1 root root 2547 Jun 21 12:12 etcd.yaml
    -rw------- 1 root root 3896 Jun 21 12:12 kube-apiserver.yaml
    -rw------- 1 root root 3428 Jun 21 12:12 kube-controller-manager.yaml
    -rw------- 1 root root 1463 Jun 21 12:12 kube-scheduler.yaml
    ```

   - Located at `/etc/kubernetes/manifests/` on the control-plane node:
      - `etcd.yaml`
      - `kube-apiserver.yaml`
      - `kube-controller-manager.yaml`
      - `kube-scheduler.yaml`
   - Kubelet watches this directory and keeps these pods running automatically.
   - This is why control-plane components survive even if the API server crashes - they don't depend on the API server to exist.

The key insight to reinforce: all four control-plane components are static pods. That's not a coincidence - it's by design so that the cluster can bootstrap itself even when the API server isn't yet running. Worth keeping that note as it directly explains the "why" behind static pods.