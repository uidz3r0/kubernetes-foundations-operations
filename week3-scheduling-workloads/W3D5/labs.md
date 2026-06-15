# W3D5 Labs

---

# Lab 1 - Basic Job

Apply:

```bash
kubectl apply -f yaml/job-basic.yaml
```

Observe:

```bash
kubectl get jobs
```

```bash
kubectl get pods
```

View logs:

```bash
kubectl logs job/basic-job
```

Inspect:

```bash
kubectl describe job basic-job
```

Questions:

- Did the Pod restart?

  - The pod did not restart after it was completed.

- What marked the Job complete?

  - ```bash
    $ kubectl describe job basic-job | grep Status
      Pods Statuses:    0 Active (0 Ready) / 1 Succeeded / 0 Failed
    ```

---

# Lab 2 - Failed Job

Apply:

```bash
kubectl apply -f yaml/job-failure.yaml
```

Watch:

```bash
kubectl get pods -w
```

Inspect:

```bash
kubectl describe job failed-job
```

Questions:

- How many retries occurred?

  - 4 total attempts (1 initial + 3 retries with backoffLimit=3)

- Which setting controlled retries?

  - the BackoffLimit controlled the number of retries

```bash
$ kubectl describe job/failed-job | grep -B 2 Status 
Backoff Limit:    3
Start Time:       Wed, 10 Jun 2026 14:37:14 +1000
Pods Statuses:    0 Active (0 Ready) / 0 Succeeded / 4 Failed
```

---

# Lab 3 - Parallel Job

Apply:

```bash
kubectl apply -f yaml/job-parallel.yaml
```

Observe:

```bash
kubectl get jobs
```

```bash
kubectl get pods
```

Questions:

- How many Pods ran simultaneously?

  - There were 3 pods running in parallel; 6 required completions
  
- How many successful completions were required?

  - There were 6 required completions

```bash
$ kubectl get job/parallel-job
NAME           STATUS     COMPLETIONS   DURATION   AGE
parallel-job   Complete   6/6           41s        4m54s
```

---

# Lab 4 - Indexed Job

Apply:

```bash
kubectl apply -f yaml/indexed-job.yaml
```

View logs:

```bash
kubectl logs -l app=indexed-job
```

Questions:

- What completion index was assigned?

  - Each Pod was assigned a unique index (0, 1, 2). This is accessible via the `JOB_COMPLETION_INDEX` environment variable, which the container uses to know its position in the job.

- Why is indexing useful?

  - Indexing allows distributed workload processing. Each Pod knows its index and can process a different slice of the work. For example: Pod 0 processes records 0-999, Pod 1 processes 1000-1999, Pod 2 processes 2000-2999. Without indexing, each Pod wouldn't know which part to handle.

---

# Lab 5 - CronJob

Apply:

```bash
kubectl apply -f yaml/cronjob-backup.yaml
```

Watch:

```bash
kubectl get cronjobs
```

```bash
kubectl get jobs
```

```bash
kubectl get pods
```

Wait a few minutes.

Observe:

New Jobs appear automatically.

Questions:

- Did the CronJob create Jobs?

  - CronJob created Jobs on schedule

    ```yaml
    $ kubectl get cronjobs
    NAME         SCHEDULE      TIMEZONE   SUSPEND   ACTIVE   LAST SCHEDULE   AGE
    backup-job   */2 * * * *   <none>     False     1        4s              2m2s
    ```


- Did each Job create a Pod?

  - each Job created a Pod.

    ```yaml
    $ kubectl get pods | grep backup-job
      backup-job-29686082-77dnl   0/1     Completed   0          77s
      backup-job-29686084-7bttc   0/1     Completed   0          2m24s
      backup-job-29686086-fmwnd   0/1     Completed   0          24s

    $ kubectl describe cronjobs backup-job | grep "Job History"
      Successful Job History Limit:  3
      Failed Job History Limit:      1
    ```  

---

# Lab 6 - CronJob Cleanup

Apply:

```bash
kubectl apply -f yaml/cronjob-cleanup.yaml
```

Observe:

```bash
kubectl get jobs
```

Wait for completion.

Observe cleanup.

Questions:

- What removed the Job?

  - The `ttlSecondsAfterFinished: 60` setting in the CronJob spec automatically deletes completed Jobs after 60 seconds.
  - `ttlSecondsAfterFinished: 60` — this is the TTL (time-to-live) controller at work.

- Why is cleanup useful?

  - Without cleanup, completed Jobs and their Pods accumulate in the cluster, consuming resources and making logs cluttered. The TTL setting automatically removes old Jobs, keeping the cluster tidy and manageable.

    ```yaml
    $ kubectl get cronjobs 
      NAME          SCHEDULE      TIMEZONE   SUSPEND   ACTIVE   LAST SCHEDULE   AGE
      backup-job    */2 * * * *   <none>     False     0        24s             18m
      cleanup-job   */2 * * * *   <none>     False     0        24s             2m47s

    $ kubectl get pods | grep -E "backup|cleanup"
      backup-job-29686098-hl5rx    0/1     Completed   0          4m18s
      backup-job-29686100-kcl46    0/1     Completed   0          2m18s
      backup-job-29686102-c68kp    0/1     Completed   0          18s
      cleanup-job-29686098-xswfh   0/1     Completed   0          42s

    $ kubectl get pods | grep -E "backup|cleanup"
      backup-job-29686098-hl5rx    0/1     Completed   0          4m18s
      backup-job-29686100-kcl46    0/1     Completed   0          2m18s
      backup-job-29686102-c68kp    0/1     Completed   0          18s
      cleanup-job-29686102-rl9ln   0/1     Completed   0          18s
    ```

---

# Cleanup

```bash
kubectl delete -f yaml/
```

## Key insight to retain


| Feature | Purpose |
| --- | --- |
| `completionMode: Indexed` | Each Pod knows its position; useful for parallel batch processing |
| `ttlSecondsAfterFinished` | Auto-delete finished Jobs after N seconds; prevents cluster clutter |