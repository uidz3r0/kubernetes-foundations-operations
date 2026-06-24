# W4D4 Storage Troubleshooting Labs

## Lab 1 - Missing PVC

Apply:

kubectl apply -f yaml/missing-pvc-pod.yaml

Questions:

1. Why is the pod Pending?

   - the pod status is `Pending` because the PV and PVC resource is missing

2. Which PVC is missing?

   - `missing-pvc` is not found.

    ```bash
    $ k describe pod missing-pvc-demo | grep -A 3 Events
      Events:
        Type     Reason            Age   From               Message
        ----     ------            ----  ----               -------
        Warning  FailedScheduling  5m6s  default-scheduler  0/3 nodes are available: persistentvolumeclaim "missing-pvc" not found. preemption: 0/3 nodes are available: 3 Preemption is not helpful for scheduling.

    $ k get pv
        No resources found

    $ k get pvc
        No resources found in default namespace.
    ```

3. Fix the issue.

```bash

# see kubernetes docs "Persistent Volume"
$ vi yaml/ajfix-pv.yaml

$ k get pv,pvc,pods

$ k exec -it missing-pvc-demo -- /bin/bash
    ls -l /data/

    apt update
    apt install curl
    curl http://localhost/
```

---

## Lab 2 - Unbound PVC

Apply:

kubectl apply -f yaml/unbound-pvc.yaml

Questions:

1. Why is the PVC Pending?

   - it said no PV is available, thus the status is Pending

2. Is a PV available?

   - a PV is available since we fix the LAb 1 issue, however there is not enough storage resource to accomodate its 5G request and there is a mismatch storageClassName.  

3. Fix the issue.

```yaml
# storageClassName shouldn't be empty and matching to PVC
apiVersion: v1
kind: PersistentVolume
metadata:
  name: unbound-pv
  labels:
    type: local
spec:
  storageClassName: ""
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/tmp/unbound-pv"
```

---

## Lab 3 - Wrong StorageClass

Apply:

kubectl apply -f yaml/wrong-storageclass-pvc.yaml

Questions:

1. Which StorageClass is requested?

   - the new PVC was looking to bind to fast-ssd StorageClass

2. Does it exist?

   - There is no PV with that the same StorageClass name.

3. Fix the issue.


```yaml
$ cat /tmp/x.yaml 
apiVersion: v1
kind: PersistentVolume
metadata:
  name: fastssd-volume
  labels:
    type: local
spec:
  storageClassName: fast-ssd
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/tmp/fastdata"

$ k apply -f /tmp/x.yaml
$ k get pods,pv,pvc
```

---

## Lab 4 - Read Only Volume

Apply:

kubectl apply -f yaml/readonly-volume-pod.yaml
k logs readonly-volume-demo
k logs readonly-volume-demo --previous

Questions:

1. Why is the pod crashing?

   - It is not crashing that much obvious but the logs showed more alarming issues than what Status and Events actually show.

2. What do logs show?

```bash
$ k logs readonly-volume-demo
sh: line 0: can't create /data/file.txt: Read-only file system

```

3. Fix the issue.

```bash
$ k edit pod readonly-volume-demo
# delete line readOnly
    - mountPath: /data
      name: data
      readOnly: true

$ k replace --force -f /tmp/kubectl-edit-1211367373.yaml

$ k logs readonly-volume-demo
$ k exec -it readonly-volume-demo -- cat /data/file.txt
```

---

## Lab 5 - Mount Investigation

Apply:

kubectl apply -f yaml/broken-mountpath-pod.yaml

Questions:

1. Where is the volume mounted?

    - the volume is mounted in `/wrong-path`

2. How can you verify mounts inside the container?

    ```bash
    $ k exec -it broken-mountpath-demo -- /bin/bash
    $ k exec -it broken-mountpath-demo -- mount | grep wrong-path
    /dev/nvme0n1p2 on /wrong-path type ext4 (rw,relatime)
    ```

3. Correct the configuration.

    - change to `mountPath: /usr/share/nginx/html`, then

    ```bash
    $ k replace --force -f yaml/broken-mountpath-pod-ajfix.yaml

    $ $ k exec -it broken-mountpath-demo -- mount | grep share
    /dev/nvme0n1p2 on /usr/share/nginx/html type ext4 (rw,relatime)
    ```

That's the trick the pod runs fine because nginx doesn't care about /wrong-path. The bug is silent: the volume is mounted in the wrong place so it's useless to the app.

The lesson here is that a misconfigured mountPath won't crash the pod â you have to actively investigate to catch it. In production this would mean your app writes/reads from a path that isn't actually backed by the volume, silently using local container storage instead.

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

Troubleshoot and repair each issue. Below are the findings:

1. If no issue: `k get pods,pv,pvc`

   - pod Status = `Running`; describe = normal; logs = normal
   - pv Status = `Bound`; describe = normal
   - pvc Status = `Bound`; describe = normal

    ```bash
    $ k get pods,pv,pvc 
    NAME         READY   STATUS    RESTARTS   AGE
    pod/aj-pod   1/1     Running   0          15s

    NAME                     CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM            STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
    persistentvolume/aj-pv   1Gi        RWO            Retain           Bound    default/aj-pvc   aj             <unset>                          25s

    NAME                           STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
    persistentvolumeclaim/aj-pvc   Bound    aj-pv    1Gi        RWO            aj             <unset>                 25s
    ```

2. wrong `claimName` name in ***pod***

   - pod Status = `Pending`; describe = pvc "wrong-name" not found; logs = empty
   - pv Status = `Bound`; describe = normal
   - pvc Status = `Bound`; describe = normal

3. wrong `storageClassName` name in PVC

   - pod Status = `Pending`; describe = pod has unbound immediate PersistentVolumeClaims; logs = empty
   - pv Status = `Available`; describe = normal
   - pvc Status = `Pending`; describe = "aj-wrong-name" not found

4. mismatched `accessModes` in PV (`ReadWriteOnce`) and PVC (`ReadWriteMany`)

   - pod Status = `Pending`; describe = pod has unbound immediate PersistentVolumeClaims; logs = empty
   - pv Status = `Available`; describe = normal,  `Access Modes: RWO`
   - pvc Status = `Pending`; describe = "aj" not found, `Access Modes: <empty>`

<br>
<u>Note</u>: One thing worth adding, the fix pattern is always the same regardless of which scenario:

1. Delete pod first
2. Fix the offending field (pod yaml, PVC yaml, or PV yaml)
3. Re-apply in order: PV â PVC â Pod
