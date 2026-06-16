# W4D1 - Pod Troubleshooting

## Objective

Learn how to troubleshoot common pod failures.

The CKA exam often gives a broken workload and asks you
to restore functionality.

---

# Troubleshooting Workflow

Always follow the same process.

## 1. Create the cluster.

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
kubectl get nodes  
```  

---

## 2. Check Pod Status

```bash
kubectl get pods
```

Identify:

- Pending
- CrashLoopBackOff
- ImagePullBackOff
- Error
- Completed

Example:

```text
NAME        READY   STATUS
web-app     0/1     CrashLoopBackOff
```

---

## 2. Watch Events

```bash
kubectl events -w
```

or

```bash
kubectl get events --sort-by=.metadata.creationTimestamp
```

Events frequently reveal the problem immediately:

- FailedScheduling
- FailedMount
- FailedCreate
- BackOff
- ErrImagePull
- Unhealthy

---

## 4. Describe the Pod

```bash
kubectl describe pod web-app
```

Focus on:

- Conditions
- Container State
- Recent Events

Look for:

- Events
- Scheduling failures
- Image pull errors
- Resource issues

---

## 5. Check Logs

```bash
kubectl logs web-app
```

If restarting:

```bash
kubectl logs web-app --previous
```

---

## 6. Inspect YAML

```bash
kubectl get pod web-app -o yaml
```

Useful for:

- environment variables
- image names
- mounts
- probes

---

## 7. Exec Into Running Containers

```bash
kubectl exec -it pod-name -- sh
```

or

```bash
kubectl exec -it pod-name -- bash
```

Use when the container is running but behaving incorrectly.

Useful for:

- checking files
- testing connectivity
- viewing configuration

---

# Common Pod Problems

## CrashLoopBackOff

Container starts then crashes repeatedly.

Check:

```bash
kubectl logs pod-name
```

Common causes:

- bad command
- missing file
- application crash

---

## ImagePullBackOff

Container image cannot be downloaded.

Check:

```bash
kubectl describe pod pod-name
```

Common causes:

- typo in image name
- missing image tag
- registry authentication

---

## Pending

Pod cannot schedule.

Check:

```bash
kubectl describe pod pod-name
```

Common causes:

- insufficient CPU
- insufficient memory
- node selector mismatch
- taints

---

## CreateContainerConfigError

Container configuration invalid.

Common causes:

- missing ConfigMap
- missing Secret
- invalid environment variables

---

# Useful Commands

View all pods:

```bash
kubectl get pods -A
```

Describe:

```bash
kubectl describe pod POD
```

Logs:

```bash
kubectl logs POD
```

Previous logs:

```bash
kubectl logs POD --previous
```

Exec:

```bash
kubectl exec -it POD -- sh
```

View events:

```bash
kubectl get events --sort-by=.metadata.creationTimestamp
```

Watch pods:

```bash
kubectl get pods -w
```

---

# Exam Tip

Always use:

1. get
2. describe
3. logs
4. exec

in that order.

Most troubleshooting questions are solved with those four commands.

But in real-world troubleshooting—and even on the CKA if available—I'd mentally insert:

1. get
2. events
3. describe
4. logs
5. exec

---

## End of W4D1

By the end of today you should be comfortable identifying:

- `CrashLoopBackOff`
- `ImagePullBackOff`
- `Pending`
- Container startup failures
- Reading `describe` output
- Reading container logs

This is one of the highest-value CKA troubleshooting days because nearly every troubleshooting question starts with these exact techniques. Tomorrow (W4D2) can move into Deployment, ReplicaSet and Service Troubleshooting, where you'll trace failures beyond a single pod.

