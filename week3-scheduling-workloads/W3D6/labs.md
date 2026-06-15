# W3D6 Labs – CronJobs and HPA Basics

---

## Lab 1 – Create Cluster

```bash
kind create cluster \
  --name w3d6 \
  --config yaml/kind-config.yaml
```

Verify:

```bash
kubectl get nodes
```

---

## Lab 2 – Suspended CronJob

Create:

```bash
kubectl apply -f yaml/cronjob-suspend.yaml
```

Verify:

```bash
kubectl get cronjobs
```

Observe:

```bash
kubectl describe cronjob suspended-cronjob
```

Question:

Why are no jobs being created?

- No cronjobs created because `Suspend` is set to True.

  ```yaml
  $ kubectl get cronjobs
  NAME                SCHEDULE      TIMEZONE   SUSPEND   ACTIVE   LAST SCHEDULE   AGE
  suspended-cronjob   */1 * * * *   <none>     True      0        <none>          2m53s
  ```

---

## Lab 3 – CronJob History Retention

Deploy:

```bash
kubectl apply -f yaml/cronjob-history.yaml
```

Watch:

```bash
watch kubectl get jobs
```

After several minutes:

```bash
kubectl get jobs
```

Question:

How many successful jobs are retained?

- 2 jobs are retained. The third oldest job is deleted.

  ```yaml
  $ kubectl get jobs
  NAME                    STATUS     COMPLETIONS   DURATION   AGE
  history-demo-29687312   Complete   1/1           5s         119s
  history-demo-29687313   Complete   1/1           4s         59s
  ```

---

## Lab 4 – CronJob Concurrency Policy

Deploy:

```bash
kubectl apply -f yaml/cronjob-concurrency.yaml
```

Observe:

```bash
kubectl get jobs
```

Describe:

```bash
kubectl describe cronjob concurrency-demo
```

Question:

Why are some scheduled runs skipped?

- Im not sure here

  ```yaml
  $ kubectl get jobs
  NAME                        STATUS     COMPLETIONS   DURATION   AGE
  concurrency-demo-29687321   Complete   1/1           94s        4m53s
  concurrency-demo-29687322   Complete   1/1           94s        3m19s
  concurrency-demo-29687324   Complete   1/1           94s        105s
  concurrency-demo-29687325   Running    0/1           11s        11s
  history-demo-29687324       Complete   1/1           4s         113s
  history-demo-29687325       Complete   1/1           4s         53s
  ```

---

## Lab 5 – Deploy HPA Target

Create deployment:

```bash
kubectl apply -f yaml/hpa-demo-deployment.yaml
```

Create service:

```bash
kubectl apply -f yaml/hpa-demo-service.yaml
```

Verify:

```bash
kubectl get deploy
kubectl get pods
```

---

## Lab 6 – Create HPA

Apply:

```bash
kubectl apply -f yaml/hpa.yaml
```

Check:

```bash
kubectl get hpa
```

Expected:

```text
TARGETS
<unknown>
```

Question:

Why is CPU usage unknown?

- Its unknown because the metrics-server that monitors the CPU/MEM is not installed in kind. 

```yaml
$ kubectl get pods | grep hpa
hpa-demo-7fc5d95985-kdrwq         1/1     Running     0          3m34s

$ kubectl get deploy | grep hpa
hpa-demo   1/1     1            1           3m41s

$ kubectl get hpa
NAME       REFERENCE             TARGETS              MINPODS   MAXPODS   REPLICAS   AGE
hpa-demo   Deployment/hpa-demo   cpu: <unknown>/50%   1         5         1          98s
```

---

## Lab 7 – Install Metrics Server

Kind does not install Metrics Server by default.

Install:

```bash
kubectl apply -f \
https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

Need to patch apparently:

```bash
kubectl patch deployment metrics-server -n kube-system --type='json' -p='[
  {"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"},
  {"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-preferred-address-types=InternalIP"}
]'
```

Verify:

```bash
kubectl get pods -n kube-system

$ kubectl get pods -n kube-system | grep metrics
metrics-server-66458f576f-jfhpd              1/1     Running   0          6m43s
```

Wait until running.

Check:

```bash
$ kubectl top nodes
NAME                 CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)   
w3d6-control-plane   128m         1%       642Mi           2%          
w3d6-worker          22m          0%       161Mi           0%          
w3d6-worker2         25m          0%       214Mi           0%  
```

Check:

```bash
$ kubectl top pods
NAME                              CPU(cores)   MEMORY(bytes)   
concurrency-demo-29687523-bzbnd   0m           0Mi             
hpa-demo-7fc5d95985-kdrwq         0m           7Mi 
```

---

## Lab 8 – Observe HPA Metrics

Check:

```bash
$ kubectl get hpa
NAME       REFERENCE             TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
hpa-demo   Deployment/hpa-demo   cpu: 0%/50%   1         5         1          18m
```

Observe:

```bash
kubectl describe hpa hpa-demo

$ kubectl describe hpa hpa-demo | grep -C 3 Min
Reference:                                             Deployment/hpa-demo
Metrics:                                               ( current / target )
  resource cpu on pods  (as a percentage of request):  0% (0) / 50%
Min replicas:                                          1
Max replicas:                                          5
Deployment pods:                                       1 current / 1 desired

```

Question:

Can HPA now see CPU utilization?

- Yes, after installing Metrics Server. 

---

## Lab 9 – Generate Load

Open a shell:

```bash
kubectl run load-generator \
--rm -it \
--image=busybox \
-- /bin/sh
```

Inside:

```bash
while true
do
  wget -q -O- http://hpa-demo
done
```

In another terminal:

```bash
kubectl get hpa -w

$ kubectl get hpa -w
NAME       REFERENCE             TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
hpa-demo   Deployment/hpa-demo   cpu: 0%/50%   1         5         1          25m
hpa-demo   Deployment/hpa-demo   cpu: 28%/50%   1         5         1          26m
hpa-demo   Deployment/hpa-demo   cpu: 108%/50%   1         5         1          26m
hpa-demo   Deployment/hpa-demo   cpu: 91%/50%    1         5         3          26m
hpa-demo   Deployment/hpa-demo   cpu: 35%/50%    1         5         3          27m
hpa-demo   Deployment/hpa-demo   cpu: 34%/50%    1         5         3          27m
hpa-demo   Deployment/hpa-demo   cpu: 49%/50%    1         5         3          27m
```

Observe:

```bash
kubectl get deploy
kubectl get pods

$ kubectl get deploy
NAME       READY   UP-TO-DATE   AVAILABLE   AGE
hpa-demo   3/3     3            3           31m

$ kubectl get pods | grep -E "hpa|load"
hpa-demo-7fc5d95985-hgbgv         1/1     Running             0          2m37s
hpa-demo-7fc5d95985-kdrwq         1/1     Running             0          31m
hpa-demo-7fc5d95985-zx68m         1/1     Running             0          2m37s
load-generator                    1/1     Running             0          4m9s
```

Question:

Did replicas increase?

- The replica did increase to 3/3

```bash
$ kubectl get hpa
NAME       REFERENCE             TARGETS        MINPODS   MAXPODS   REPLICAS   AGE
hpa-demo   Deployment/hpa-demo   cpu: 38%/50%   1         5         3          30m
```

---

## Cleanup

```bash
kind delete cluster --name w3d6
```
