# W3D4 Notes

## Resource Limits

Requests:

- Used during scheduling
- Guarantees resources

Limits:

- Runtime maximum

Example:

- Request CPU = 100m

  Scheduler reserves:

  - 0.1 CPU

- Limit CPU = 500m

  Container may burst up to:

  - 0.5 CPU

---

## CPU Limit

CPU over limit:

Result:

- CPU throttling

- Container keeps running.

---

## Memory Limit

Memory over limit:

Result:

- OOMKill

- Container terminated.

---

## Health Probes

Kubernetes needs to answer:

- "Is the application healthy?"

- Three probe types exist.

---

## Liveness Probe

Question:

- "Should this container be restarted?"

Failure:

- Container restarted.

Use for:

- Deadlocks
- Hung processes
- Unresponsive applications

---

## Readiness Probe

Question:

- "Can this pod receive traffic?"

Failure:

- Pod removed from Service endpoints.

- Container NOT restarted.

Use for:

- Startup initialization
- Database connectivity checks
- Temporary outages

---

## Startup Probe

Question:

- "Has the application finished starting?"

Used for:

- Slow Java applications
- Large Spring Boot apps
- Legacy applications

Benefit:

- Prevents premature liveness failures.

---

## Probe Flow

Startup Probe
      ↓
Readiness Probe
      ↓
Liveness Probe

Typical lifecycle:

1. Container starts
2. Startup succeeds
3. Pod becomes Ready
4. Traffic begins
5. Liveness continues monitoring

---

## Production Guidance

Liveness:

- Use sparingly
- Restart only when necessary

Readiness:

- Use almost everywhere

Startup:

- Use for slow applications

---

## Exam Tip

Liveness:

- Restart pod

Readiness:

- Stop traffic

Startup:

- Delay health checks

Remember:

- Liveness = Alive?

- Readiness = Ready?

- Startup = Finished booting?

---

## End-of-Day Outcome

After W3D4 you should be able to answer:

> "Why is my Pod Running but not receiving traffic?"

Answer:

> Readiness probe is failing, so Kubernetes removes the Pod from Service endpoints even though the container is still running.

And:

> "Why is Kubernetes constantly restarting my Pod?"

Answer:

> A liveness probe is failing, causing kubelet to restart the container.

That distinction shows up frequently in real-world troubleshooting and Kubernetes certification exams. W3D4 is one of the most practical days in Week 3.