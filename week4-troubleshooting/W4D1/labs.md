# W4D1 Labs

---

# Lab 0 - Create Cluster

```bash
kind create cluster \
  --name w4d1 \
  --config yaml/kind-config.yaml

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml && \
kubectl patch deployment metrics-server -n kube-system --type='json' -p='[
  {"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"},
  {"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-preferred-address-types=InternalIP"}
]'

kubectl get pods -n kube-system
```

# Lab 1 - CrashLoopBackOff

Create:

```bash
kubectl apply -f yaml/crashloop-pod.yaml
```

Observe:

```bash
kubectl get pods
```

Question:

1. What status appears?

   - The status is `CrashLoopBackOff`. 

Investigate:

```bash
kubectl describe pod crashloop-demo
```

Check logs:

```bash
kubectl logs crashloop-demo
```

Fix the YAML and redeploy.

- `exit 1` terminates the container right away and restarts in loop. You can fix it with replacing it with `"echo 'Hello AJ' ; sleep 3600` just to keep the container running for 60mins and allows you to see the status into `Running` within that time frame.

Expected Result:

```bash
Running
```

---

# Lab 2 - ImagePullBackOff

Create:

```bash
kubectl apply -f yaml/imagepull-pod.yaml
```

Check:

```bash
kubectl get pods
```

Investigate:

```bash
kubectl describe pod imagepull-demo
```

Questions:

1. What image is Kubernetes trying to pull?

   - Kubernetes is trying to pull `nginxxxx:latest` which does not exist this getting status `ErrImagePull` then eventually `ImagePullBackOff`

2. Why is it failing?

   - It is failing because the image name is wrong and so the image does not exist in the repo. You can fix the issue by replacing `nginxxxx` to `nginx`.

Fix the image name.

Expected Result:

```bash
Running
```

---

# Lab 3 - Pending Pod

Create:

```bash
kubectl apply -f yaml/pending-pod.yaml
```

Observe:

```bash
kubectl get pods
```

Investigate:

```bash
kubectl describe pod pending-demo
```

Questions:

1. Why is the pod Pending?

    - The pod remains Pending since the NodeSelector `disktype=ssd` cannot find a matching label on any worker node. 

2. What scheduler event explains the failure?

    - `default-scheduler` is the one reporting the failure of the pod. 

3. Which nodeSelector is preventing scheduling?

    - the nodeSelector `disktype=ssd` is preventing scheduling.

4. What message appears in the Events section?

    ```bash
    $ k events | grep "Pod/pending-demo"
    2m19s (x4 over 17m)   Warning   FailedScheduling   Pod/pending-demo     0/3 nodes are available: 1 node(s) had untolerated taint {node-role.kubernetes.io/control-plane: }, 2 node(s) didn't match Pod's node affinity/selector. preemption: 0/3 nodes are available: 3 Preemption is not helpful for scheduling.
    ```

    Try this instead:
      `k events --for pod/pending-demo`

5. What change is required to schedule the pod successfully?

Fix the problem.

Clue: `kubectl get pod pending-demo -o yaml`

AJ Fix:

- ```bash
  $ kubectl label nodes w4d1-worker2 disktype=ssd

  $ kubectl get pods -o wide | grep pending
  pending-demo     1/1     Running            0               27m   10.244.2.3   w4d1-worker2   <none>           <none>

  # Remove label
  $ k label nodes w4d1-worker2 disktype-
  ```

Find:

```yaml
   nodeSelector:
     disktype: ssd
```

Expected Result:

```bash
Running
```

---

# Lab 4 - Broken Environment Variable

Create:

```bash
kubectl apply -f yaml/broken-env-pod.yaml
```

Observe:

```bash
kubectl get pods
```

Investigate:

```bash
kubectl logs broken-env-demo
```

Questions:

1. Which variable is missing?

   - REQUIRED_VAR does not have value

2. Why does the container exit?

   - `-z` is a test operator that returns True if the variable is not defined or `empty`

Fix the issue.

- change `-z` to `! -z` (this is noob answer AJ)
- should be

    ```yaml
    value: "something"
    ```

   or in practice, the value would come from a ConfigMap or Secret:

    ```yaml
    env:
    - name: REQUIRED_VAR
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: required-var
    ```


Expected Result:

```bash
Running
```

---

# Lab 5 - Fast Troubleshooting Drill

Without looking at notes:

Investigate each pod using only:

```bash
kubectl get pods
kubectl describe pod <pod>
kubectl logs <pod>
kubectl logs <pod> --previous
kubectl exec <pod>
```

For each pod identify:

- Problem
- Root cause
- Fix

Only then:

```bash
k edit pod <pod>
```

or 

```bash
k delete pod ...
k apply -f ...
```

Goal:

Resolve all failures within 15 minutes.

For troubleshooting, I think of it like this:

| Situation	| Preferred Fix | 
| --- | --- | 
| Pod created directly from a YAML file	| Edit file → apply | 
| Pod created manually (`kubectl run`) | Edit/replace or recreate | 
| Deployment-managed pod | Fix Deployment, not Pod | 
| StatefulSet-managed pod | Fix StatefulSet, not Pod |
| DaemonSet-managed pod	| Fix DaemonSet, not Pod |
| Exam/lab environment | Whatever is fastest and safe |

### Classic `/tmp file` + replace workflow

```bash
kubectl get pod crashloop-demo -o yaml > /tmp/pod.yaml
vi /tmp/pod.yaml

kubectl replace -f /tmp/pod.yaml
kubectl replace --force -f /tmp/pod.yaml
```

### What I would do in the W4D1 labs

For a Pod created from a file:

Fix:

```yaml
command:
- sh
- -c
- sleep 3600
```

Then:

```bash
kubectl apply -f yaml/crashloop-pod.yaml
```

If Kubernetes rejects it:

```bash
kubectl delete pod crashloop-demo
kubectl apply -f yaml/crashloop-pod.yaml
```

### Production mindset

In production, I'd almost never think:

```bash
kubectl edit pod
```

I'd think:

Who owns this pod?

Check:

```bash
kubectl get pod POD -o jsonpath='{.metadata.ownerReferences[*].kind}'
```

You might get:

```
ReplicaSet
```

Then:

```
ReplicaSet
  ↳ Deployment
```

Fix the Deployment:

```bash
kubectl edit deployment web
```

or

```bash
kubectl set image deployment/web app=nginx:latest
```

and let Kubernetes recreate the Pods.

## Interesting failures that require tracing beyond a single pod:

- Deployment exists but pod won't start
- ReplicaSet not creating desired replicas
- Service selector mismatch
- Service points to wrong targetPort
- Service has no endpoints
- Deployment image typo
- Deployment stuck during rollout

### A small challenge

Without looking at your notes, explain the difference between:

- `ErrImagePull` - typo or Image does not exist issue; first failed pull attempt
- `ImagePullBackOff` - typo or Image does not exist issue
- `CrashLoopBackOff` - container starts but crashes immediately or shortly after, and Kubernetes keeps restarting it with increasing delay
- `CreateContainerConfigError` - Configuration error, ConfigMap or Secret issue
- `Pending` - No eligible nodes to schedule, Selector/label mismatch

in one sentence each.