# W4D8 – Advanced Debugging & Resource Pressure

## Objectives

- Understand CPU resource exhaustion
- Understand memory exhaustion and OOMKilled containers
- Use kubectl debug
- Use ephemeral debug containers
- Troubleshoot running containers

---

# Resource Exhaustion

Common symptoms:

- Pending pods
- OOMKilled
- CrashLoopBackOff
- Slow applications
- High node utilization

Check:

```bash
kubectl top nodes
kubectl top pods
```

Describe:

```bash
kubectl describe pod POD
```

Events:

```bash
kubectl get events --sort-by=.lastTimestamp
```

---

# Suggested Execution Order

```bash
kubectl apply -f yaml/cpu-pressure.yaml
kubectl top pods

kubectl apply -f yaml/memory-pressure.yaml
kubectl describe pod memory-pressure

kubectl apply -f yaml/debug-target.yaml

kubectl debug debug-target -it --image=busybox

kubectl get events --sort-by=.lastTimestamp
```

---

# CPU Pressure

Symptoms:

- High CPU usage
- Slow responses
- Throttling

Look for:

Limits:
  cpu: "100m"

Requests:
  cpu: "50m"

---

# Memory Pressure

Symptoms:

- OOMKilled
- Restarting containers

Check:

kubectl describe pod

Example:

Last State:
  Terminated
  Reason: OOMKilled

---

# kubectl debug

Create a temporary debug container:

kubectl debug POD -it --image=busybox

Example:

kubectl debug debug-target -it --image=busybox

---

# Ephemeral Containers

Useful when:

- Application image has no shell
- Distroless containers
- Minimal images

Inspect:

kubectl describe pod POD

Look for:

Ephemeral Containers:

---

# Debug Commands

Inside debug container:

ps
top
netstat
nslookup
wget
ping

---

# Important Commands

kubectl top nodes
kubectl top pods
kubectl describe pod POD
kubectl logs POD
kubectl debug POD -it --image=busybox
kubectl get events