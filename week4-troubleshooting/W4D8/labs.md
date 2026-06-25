# W4D8 Labs

---

## Lab 1 – CPU Pressure

Apply:

`kubectl apply -f yaml/cpu-pressure.yaml`

Observe:

`kubectl top pod`

Describe:

`kubectl describe pod cpu-pressure`

Questions:

1. What CPU request is configured?

    - set to `100m` but `top pod` says `200m` 
 
2. What CPU limit is configured?

    - set to `200m`. container cannot go over this 200 milliCPU.

3. Is the container throttled?

    - The container's CPU use is being <u>**throttled**</u>, because the container is attempting to use more CPU resources than its limit.

---

## Lab 2 – Memory Pressure

Apply:

`kubectl apply -f yaml/memory-pressure.yaml`

Watch:

`kubectl get pod -w`

Describe:

`kubectl describe pod memory-pressure`

Questions:

1. What happened?

    - the container run into `CrashLoopBackOff`

2. Was the container OOMKilled?

    - the container keep on `Restarting` after it OOMKilled hitting memory limit

3. What memory limit caused it?

    - the container is set to use `512M` memory while limit is set to `128Mi`

---

## Lab 3 – kubectl debug

Deploy:

`kubectl apply -f yaml/debug-target.yaml`

Open shell:

`kubectl debug debug-target -it --image=busybox`

Inside:

```bash
ps
nslookup kubernetes.default
wget -qO- http://localhost
```

Exit.

---

## Lab 4 – Ephemeral Containers

Check:

`kubectl describe pod debug-target`

Questions:

1. What image was used?

    - it used `busybox`

2. What command was executed?

    - The default entrypoint for `busybox` was used (sh). Inside, I ran `ps`, `nslookup kubernetes.default`, and `wget -qO- http://localhost`.

3. Why are ephemeral containers useful?

    - They let you attach a debugging toolset to a <u>running pod without restarting it</u>. This is critical when the app container has no shell or debug tools (e.g., a distroless or scratch-based image like nginx). You inject `busybox/curl/etc`. temporarily, debug the live process/network, then it's gone. The key distinction from `kubectl exec` is that ephemeral containers can be added even when the main container is crashing.

    - After we ran `kubectl debug debug-target -it --image=busybox`. That command <u>injected an ephemeral container</u> into the running `debug-target` pod.

    - After exiting, `kubectl describe pod debug-target` will show an Ephemeral Containers section that wasn't there when the pod was first created.

---

## Lab 5 – Events Investigation

Generate failures:

`kubectl apply -f yaml/memory-pressure.yaml`

Observe:

`kubectl get events --sort-by=.lastTimestamp`

Questions:

1. What warning events appeared?

    - `OOMKilling` - the kernel killed the container for exceeding its memory limit
    - `BackOff` - Kubernetes backing off restarting the container (CrashLoopBackOff)

2. What caused the failure?

    - The `stress` process inside the container tried to allocate 512M but the pod's memory limit is 128Mi. The kernel OOM-killed the process.

3. Which object generated the event?

    - The `Pod/memory-pressure` object. In the events output, the `OBJECT` column will show `pod/memory-pressure`.

---

Key takeaway connecting Labs 3-5: 

These three labs together show you a progression of debugging tools - `kubectl debug` (Lab 3) attaches ephemeral containers (Lab 4) to live pods, while `kubectl get events` (Lab 5) gives you the cluster-wide audit trail of what went wrong and when.

---
Target Completion Time:
30–45 minutes.