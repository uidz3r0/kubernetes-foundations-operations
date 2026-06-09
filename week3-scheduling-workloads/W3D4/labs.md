# W3D4 Labs

---

## Lab 1 – Build Cluster

```bash
kind create cluster \
  --name w3d4 \
  --config yaml/kind-config.yaml
```

Verify:

```bash
kubectl get nodes
```

---

## Lab 2 – Review Requests vs Limits

Apply:

```bash
kubectl apply -f yaml/limits-demo.yaml
```

Inspect:

```bash
kubectl describe pod limits-demo
```

Questions:

1. What is the CPU request?

   - 100m

2. What is the CPU limit?

   - 500m

3. What is the memory request?

   - 128Mi

4. What is the memory limit?

   - 256Mi

---

## Lab 3 – Liveness Probe

Deploy:

```bash
kubectl apply -f yaml/liveness-probe.yaml
```

Watch:

```bash
kubectl describe pod liveness-demo
```

Locate:

```text
Liveness:
```

Questions:

1. What path is checked?

   - the root path / is checked

2. How often is it checked?

   - run the probe every 10 seconds (period=10s)

3. What happens if it repeatedly fails?

   - The default `failureThreshold` is 3, so after 3 consecutive failures the container restarts.

---

## Lab 4 – Readiness Probe

Deploy:

```bash
kubectl apply -f yaml/readiness-probe.yaml
```

Inspect:

```bash
kubectl describe pod readiness-demo
```

Questions:

1. Does readiness restart the container?

   - No, readiness does not restart the container. It only removes the Pod from Service endpoints.


2. What happens when readiness fails?
   - Readiness removes the pod from Service endpoint if it fails.

### Liveness vs Readiness:

| Probe	| Failure Action | Purpose | 
| --- | --- | --- |
| Liveness | Restarts container | "Is my app dead?" | 
| Readiness | Removes from Service | "Is my app ready to receive traffic?" |

### Common pattern:

```yaml
Liveness:   failureThreshold=3  # Restart if dead 30+ seconds
Readiness:  failureThreshold=1  # Remove traffic IMMEDIATELY on any failure
```

### Real-world scenario:

```yaml
# Container starts (t=0)
# delay=5s, period=10s, failure=3

t=5s   Ready ✅ (added to Service)
t=15s  Ready ✅ (receiving traffic)
t=25s  Ready ❌ (failure #1) - REMOVED from Service immediately? NO! After #3
t=35s  Ready ❌ (failure #2) - Still removed? NO, after threshold
t=45s  Ready ❌ (failure #3) - NOW removed from Service
t=55s  Ready ✅ (success #1) - BACK in Service
```

---

## Lab 5 – Startup Probe

Deploy:

```bash
kubectl apply -f yaml/startup-probe.yaml
```

Inspect:

```bash
kubectl describe pod startup-demo
```

Questions:

1. Why use startup probes?

   - Startup probes prevent slow-starting applications from entering a boot loop. Without them, liveness probe would kill the container before it finishes initializing.

2. What problem do they solve?

   - The startup probe will protect the slow starter up from boot loop death.

### The problem without startupProbe:

```yaml
# Your example
Liveness: failureThreshold=3  # Will restart after 3 failures (30 seconds)
Startup:  failureThreshold=30 # Allows 300 seconds (5 minutes) for startup
```

### Why both are needed:

| Probe	| Protects against | Problem it solves |
| --- | --- | --- |
| Liveness | Runtime crashes | Restarts deadlocks quickly (30 sec) |
| Startup | Slow startup | Prevents liveness from killing slow starters |


### Real scenario:

#### Without startupProbe (bad):

```yaml
Container starting (takes 2 minutes to load large model/cache)
├─ t=10s  Liveness fails (#1)
├─ t=20s  Liveness fails (#2)  
├─ t=30s  Liveness fails (#3) → 🔄 CONTAINER RESTARTED
├─ (Repeat - never actually starts!)

Result: Boot loop death
```

#### With startupProbe (good):

```yaml
Container starting (takes 2 minutes)
├─ Startup probe runs every 10s, failureThreshold=30
├─ t=0-120s  Startup fails but allowed (up to 300s)
├─ t=120s    Startup finally succeeds ✅
├─ t=130s    Liveness takes over (only now active!)
└─ Container keeps running normally

Result: Successful startup!
```

### How they work together:

```yaml
Startup:  failureThreshold=30  # Disables liveness during startup
Liveness: failureThreshold=3   # Takes over AFTER startup succeeds
```

Key rule: `livenessProbe` is disabled until `startupProbe` succeeds. Only then does liveness start running.

---

## Lab 6 – Compare All Three

Deploy:

```bash
kubectl apply -f yaml/probe-comparison.yaml
```

Inspect:

```bash
kubectl describe pod probe-comparison
kubectl describe pod probe-comparison | grep -E "Liveness|Readiness|Startup"
```

Identify:

- Startup probe
- Liveness probe
- Readiness probe

Explain each purpose in one sentence.

- Startup: temporarily disable liveness checks during startup so the container doesnt get killed before its fully running.
- Liveness: restarts the container when its dead or stuck.
- Readiness: stops sending traffic to the container when its not ready to handle requests.
 
### The perfect trio:

```yaml
startupProbe:   # "Give me time to start"
livenessProbe:  # "Kill me if I die at runtime"
readinessProbe: # "Remove traffic if I'm busy"
```

---

## Cleanup

```bash
kind delete cluster --name w3d4
```