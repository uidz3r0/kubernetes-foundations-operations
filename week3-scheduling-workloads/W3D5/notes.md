# W3D5 Notes

Learning Objectives

By the end of today you should understand:

- What a Job is
- When to use a Job instead of a Deployment
- Job completion and retry behavior
- Parallel Jobs
- Indexed Jobs (awareness only)
- What a CronJob is
- Scheduling recurring workloads
- Cleanup of completed Jobs
- Real-world use cases

## Why Jobs Exist

Most Kubernetes workloads are long-running services.

Examples:

- nginx
- web applications
- APIs
- monitoring systems

Deployments ensure Pods keep running forever.

A Job is different.

A Job runs:

1. Start Pod
2. Complete task
3. Exit successfully
4. Kubernetes marks Job complete

---

## Deployment vs Job

Deployment:

- Runs forever
- Replaces failed Pods
- Used for services

Job:

- Runs once
- Finishes
- Records success/failure

---

## Common Job Use Cases

Database migration

```bash
./migrate-db.sh
```

Data import

```bash
./import-customers.sh
```

Generate reports

```bash
./monthly-report.sh
```

Batch processing

```bash
./process-images.sh
```

Backups

```bash
./backup.sh
```

---

## Job Lifecycle

Create Job

↓

Pod starts

↓

Task executes

↓

Exit Code 0

↓

Job Complete

---

## Viewing Jobs

```bash
kubectl get jobs
```

```bash
kubectl describe job demo-job
```

```bash
kubectl logs job/demo-job
```

---

## Restart Behaviour

Inside a Job:

```yaml
restartPolicy: Never
```

or

```yaml
restartPolicy: OnFailure
```

Allowed values:

- Never
- OnFailure

Not allowed:

```yaml
restartPolicy: Always
```

---

## Backoff Limit

Controls retries.

```yaml
backoffLimit: 4
```

Meaning:

Retry failed Pods up to 4 times.

---

## Parallel Jobs

Run multiple Pods simultaneously.

```yaml
parallelism: 3
completions: 6
```

Meaning:

Need 6 successful completions.

Run 3 Pods at a time.

---

## Indexed Jobs

Useful for distributed processing.

Each Pod receives:

```bash
JOB_COMPLETION_INDEX
```

Example:

Worker 0

Processes:

```text
records 0-999
```

Worker 1

Processes:

```text
records 1000-1999
```

etc.

---

## CronJobs

CronJobs create Jobs automatically.

Think Linux cron.

Example:

```cron
*/5 * * * *
```

Every 5 minutes.

---

## Cron Format

```text
* * * * *
| | | | |
| | | | └── Day of week
| | | └──── Month
| | └────── Day
| └──────── Hour
└────────── Minute
```

Example:

```cron
0 2 * * *
```

Every day at 2 AM.

---

## CronJob Flow

CronJob

↓

Creates Job

↓

Creates Pod

↓

Completes

↓

Waits for next schedule

---

## Useful Commands

View CronJobs:

```bash
kubectl get cronjobs
```

View generated Jobs:

```bash
kubectl get jobs
```

View Pods:

```bash
kubectl get pods
```

Delete CronJob:

```bash
kubectl delete cronjob backup-job
```

---

## Cleanup

Completed Jobs remain visible.

Auto cleanup:

```yaml
ttlSecondsAfterFinished: 60
```

Delete Job objects 60 seconds after completion.

---

## Production Examples

Nightly backups

Database maintenance

Generate invoices

Rotate certificates

Export reports

ETL workloads

Log processing

Security scans

Batch image processing

Data warehouse imports

## Expected Takeaways

By the end of W3D5 you should comfortably answer:

1. When should I use a Job instead of a Deployment?

    - Use a Job for finite, one-time or periodic tasks that complete. Use a Deployment for long-running services that should run forever (like web apps, APIs, monitoring systems)

2. What is backoffLimit?

    - It controls how many times a failed Pod will be retried. Default is 3. Example: `backoffLimit: 3` means the Job will retry up to 3 times before marking it as failed.

3. Difference between parallelism and completions?

    - `parallelism`: How many Pods run simultaneously at once. `completions`: Total number of successful Pods needed. Example: `parallelism: 3`, `completions: 6` means 3 Pods run at a time, and you need 6 successful runs total.

4. What problem do Indexed Jobs solve?

    - Indexed Jobs distribute work across multiple Pods. Each Pod gets a unique `JOB_COMPLETION_INDEX` (0, 1, 2, etc.) so it knows which slice of data to process. This avoids duplicate work and allows horizontal scaling of batch jobs.


5. How does a CronJob relate to a Job?

    - A CronJob is a scheduler that automatically creates Jobs on a schedule (like Linux cron). Each time the schedule triggers, a new Job is created, which creates Pod(s) to run the task.

6. What does ttlSecondsAfterFinished do?

    - It automatically deletes completed Job objects after N seconds. Example: `ttlSecondsAfterFinished: 60` removes the Job 60 seconds after it finishes, keeping the cluster clean and preventing clutter from old completed Jobs.

This is one of the most important workload-management topics in Kubernetes because Jobs and CronJobs are used constantly for:

- Database migrations
- Backups
- Reporting
- ETL pipelines
- Maintenance tasks
- Batch processing

W3D6 will fit nicely as ConfigMaps & Secrets, because Jobs often need configuration and credentials, and it introduces how workloads consume external configuration.
