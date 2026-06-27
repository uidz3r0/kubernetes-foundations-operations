# W5D3 Labs — Observability

---

## Lab 1 — Application Logs

Deploy:

`kubectl apply -f yaml/logging-pod.yaml`

View logs:

`kubectl logs logging-pod`

Follow logs:

`kubectl logs -f logging-pod`

Questions:

- How often are logs generated? = every 5secs
- How do you stop log following? = Ctrl+c

---

## Lab 2 — Crashed Container Logs

Deploy:

`kubectl apply -f yaml/failing-app.yaml`

Observe:

`kubectl get pods`

Describe:

`kubectl describe pod failing-app`

View previous logs:

`kubectl logs failing-app --previous`

- why you need `--previous`: once a container restarts, `kubectl logs failing-app` shows the logs of the **current/new** container instance. `--previous` (or `-p`) shows the **crashed** instance. This is the #1 thing people miss when debugging CrashLoopBackOff â they look at current logs and see nothing useful.

Questions:

- Why did the pod restart?

  - its a busybox image with "exit 1" after 10secs so it kills the container aftewards

- What was the last message?

  - last message was "Application starting..."

---

## Lab 3 — Events

View events:

`kubectl get events`

Sort events:

`kubectl get events --sort-by=.metadata.creationTimestamp`

Watch events:

`kubectl get events -w`

Delete and recreate a pod.

Observe:

- Scheduled
- Pulled
- Started

---

## Lab 4 — Resource Metrics

Deploy:

`kubectl apply -f yaml/metrics-pod.yaml`

View metrics:

`kubectl top pod`

View node metrics:

`kubectl top nodes`

Questions:

- Which pod consumes CPU?

  - `metrics-pod` is hitting the limit resource 100%
  - `metrics-pod` runs `dd if=/dev/zero of=/dev/null` (a CPU spinner) capped at 500m limit

- How much CPU is used?

  - its going between 500m - 501m CPU
  - the `requests` vs `limits` distinction in `top`

`kubectl top pod` shows **actual usage**, not requests/limits. The pod requests `100m` but the limit is `500m` - and it's pinned at ~500m because the spinner wants infinite CPU and gets throttled at the limit. That throttling connection ties back nicely to W4D8 Lab 1 (CPU Pressure).

---

## Lab 5 — Observe Multiple Sources

Open multiple terminals.

Terminal 1:

`kubectl get pods -w`

Terminal 2:

`kubectl logs -f logging-pod`

Terminal 3:

`kubectl top pods`

Terminal 4:

`kubectl get events -w`

Observe how all views provide different information.

---

## Lab 6 — Troubleshooting Exercise

Deploy:

`kubectl apply -f yaml/failing-app.yaml`

Answer:

1. What is the pod state?

   - CrashLoopBackOff

2. What do events show?

   - its updating the Pod events showing creating the pod, starting, and crashing over and over again

3. What do logs show?

   - The realted log just showing "Application starting" 

4. Did the container restart?

   - yes

5. What command failed?

   - the failing-app is set to "exit 1" after sleeping 10 secs

---

# Bonus

If Metrics Server is unavailable:

`kubectl top pods`

Error:

Metrics API not available

This is expected on some Kind clusters.

Observability concepts remain the same.