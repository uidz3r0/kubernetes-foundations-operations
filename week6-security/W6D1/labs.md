# W6D1 Labs

## Lab 1

Create a namespace.

```
kubectl create ns development
```

Verify.

- `kubectl get namespaces`

---

## Lab 2

Create a ServiceAccount.

```
kubectl apply -f yaml/serviceaccount.yaml
```

Verify.

`k get sa -n development`

---

## Lab 3

Create a Role.

```
kubectl apply -f yaml/developer-role.yaml
```

Verify permissions.

```bash
k get role -A

k describe role developer -n development | grep pod
  pods       []                 []              [get list watch]
```

---

## Lab 4

Bind the Role.

```
kubectl apply -f yaml/developer-rolebinding.yaml
```

Verify.

```bash
k get rolebinding -n development
    NAME                ROLE             AGE
    developer-binding   Role/developer   27s

k describe rolebinding -n development
    Name:         developer-binding
    Labels:       <none>
    Annotations:  <none>
    Role:
      Kind:  Role
      Name:  developer
    Subjects:
      Kind            Name          Namespace
      ----            ----          ---------
      ServiceAccount  developer-sa  development
```

---

## Lab 5

Can the ServiceAccount list pods?

```
kubectl auth can-i list pods \
--as=system:serviceaccount:development:developer-sa \
-n development
```

Expected:

```
yes
```

---

## Lab 6

Can it delete deployments?

```
kubectl auth can-i delete deployments \
--as=system:serviceaccount:development:developer-sa \
-n development
```

Expected:

```
no
```

---

## Lab 7

Create ClusterRole.

```
kubectl apply -f yaml/pod-reader-clusterrole.yaml
```

Bind it.

```
kubectl apply -f yaml/pod-reader-clusterrolebinding.yaml
```

Verify.

```bash
k get clusterrole | grep pod-reader
    pod-reader                                                             2026-06-29T11:21:54Z
k get clusterrolebinding | grep pod-reader
    pod-reader-binding                          
```

---

## Lab 8

Can it list pods in kube-system?

```
kubectl auth can-i list pods \
--as=system:serviceaccount:development:developer-sa \
-n kube-system
```

Expected:

```
yes
```

---

## Lab 9

Attempt forbidden operation.

```
kubectl auth can-i create namespaces \
--as=system:serviceaccount:development:developer-sa
```

Expected:

```
no
```

---

## Lab 10

Test RBAC from inside a running Pod.

The previous labs used `--as=` to simulate the ServiceAccount. This lab
shows real enforcement: a Pod running as `developer-sa` calling the API.

```bash
kubectl apply -f yaml/rbac-test-pod.yaml
```

Allowed (Role grants get/list/watch pods):

```bash
kubectl exec -it rbac-test -n development -- kubectl get pods -n development

    NAME        READY   STATUS    RESTARTS   AGE
    rbac-test   1/1     Running   0          70s
```

Forbidden (Role has no delete):

```bash
kubectl exec -it rbac-test -n development -- kubectl delete pod rbac-test -n development

    Error from server (Forbidden): pods "rbac-test" is forbidden: User "system:serviceaccount:development:developer-sa" cannot delete resource "pods" in API group "" in the namespace "development"

    command terminated with exit code 1
```

Expected:

```text
Error from server (Forbidden): pods "rbac-test" is forbidden
```

This is the live counterpart to Labs 5/6 — what the application
actually sees at runtime, not a simulation.

---

## Lab 11

Bind to a non-existent Role.

```bash
kubectl apply -f yaml/forbidden-rolebinding.yaml
```

Notice the apply succeeds — Kubernetes does NOT validate that the
referenced Role exists.

Check what it actually grants:

```bash
kubectl auth can-i get secrets \
--as=system:serviceaccount:development:developer-sa -n development

    no - RBAC: role.rbac.authorization.k8s.io "does-not-exist" not found
```

Expected:

```text
no
```

Lesson: a successful `kubectl apply` of a RoleBinding does not mean
permissions were granted. A dangling `roleRef` silently grants nothing.

---

## Challenge

Create a Role allowing:

- ConfigMaps
- Secrets
- Services

with only

```text
get
list
watch
```

Bind it to the ServiceAccount.

Verify permissions.
