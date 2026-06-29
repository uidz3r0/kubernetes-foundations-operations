# W5D2 – RBAC & Service Accounts

## Objectives

- Understand ServiceAccounts
- Learn RBAC concepts
- Create Roles
- Create RoleBindings
- Verify permissions
- Troubleshoot authorization issues

---

## Lab 1 – Create a Service Account

Apply:

```bash
kubectl apply -f yaml/serviceaccount.yaml

kubectl get sa
```

Inspect:

```bash
kubectl describe sa app-sa
```

---

## Lab 2 – Create a Role

Apply:

```bash
kubectl apply -f yaml/role.yaml
```

View:

```bash
kubectl describe role pod-reader
```

Observe:

- get
- list
- watch

---

## Lab 3 – Bind the Role

Apply:

```bash
kubectl apply -f yaml/rolebinding.yaml
```

Verify:

```bash
kubectl describe rolebinding pod-reader-binding
```

---

## Lab 4 – Check Permissions

```bash
kubectl auth can-i list pods --as=system:serviceaccount:default:app-sa

kubectl auth can-i delete pods --as=system:serviceaccount:default:app-sa
```

Observe:

- list = yes
- delete = no

---

## Lab 5 – Run a Pod with ServiceAccount

Apply:

```bash
kubectl apply -f yaml/pod-sa.yaml
```

Verify:

```bash
kubectl describe pod sa-demo
```

Look for:

```text
Service Account: app-sa
```

---

## Lab 6 – Forbidden Operations

Attempt:

```bash
kubectl auth can-i delete deployments --as=system:serviceaccount:default:app-sa
```

Expected:

```text
no
```

---

## Lab 7 – Forbidden from Inside a Pod

Apply:

```bash
kubectl apply -f yaml/forbidden-pod.yaml
```

Exec in:

```bash
kubectl exec -it forbidden-demo -- sh
```

Inside the pod, call the API using the mounted token:

```bash
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

# This should succeed (app-sa has get/list pods)
curl -s --cacert $CACERT -H "Authorization: Bearer $TOKEN" \
  https://kubernetes.default.svc/api/v1/namespaces/default/pods | head -5

# This should return 403 Forbidden
curl -s --cacert $CACERT -H "Authorization: Bearer $TOKEN" -X DELETE \
  https://kubernetes.default.svc/api/v1/namespaces/default/pods/forbidden-demo
```

Expected on the DELETE:

```text
{
  "kind": "Status",
  "status": "Failure",
  "message": "pods \"forbidden-demo\" is forbidden: ...",
  "reason": "Forbidden",
  "code": 403
}
```

- The key distinction from Lab 6: kubectl auth can-i is a convenience check you run as an admin.

- This shows what actually happens at runtime when an app's SA token hits an endpoint it's not allowed to call - you get a real `403 Forbidden` JSON response from the API server. That's what your application code would see in production.

---

## Challenge

Create a Role that allows:

- get pods
- list pods
- get services

Bind it to app-sa.

Verify using:

```bash
cp yaml/role.yaml yaml/role-aj.yaml
cp yaml/rolebinding.yaml yaml/rolebinding-aj.yaml

# edit role-aj.yaml and rolebinding-aj.yaml
k apply -f yaml/role-aj.yaml
k apply -f yaml/rolebinding-aj.yaml

k describe role service-reader
k describe rolebinding service-reader-binding

# Check if Role and RoleBinding exists
k get role service-reader -n default -o yaml
k get rolebinding service-reader-binding -n default -o yaml

# Test permissions for app-sa
k auth can-i get pods --as=system:serviceaccount:default:app-sa -n default
k auth can-i list pods --as=system:serviceaccount:default:app-sa -n default

k auth can-i get services --as=system:serviceaccount:default:app-sa

k auth can-i -h
k auth can-i --list --as=system:serviceaccount:default:app-sa | grep -E "pods|services"
   pods                                            []                                     []               [get list watch]
   services                                        []                                     []               [get]
```

---

## W5D2 Review

Labs 1-3 -- The progression is correct: ServiceAccount > Role > RoleBinding. The binding is the glue that connects the identity (SA) to the permissions (Role). Nothing missing here.

Lab 4 -- The `--as=system:serviceaccount:default:app-sa` flag is the exact syntax used in CKA exams too, worth memorizing that format (`system:serviceaccount:<namespace>:<sa-name>`).

Lab 5 -- One thing to also look for when you `describe pod sa-sa`: Kubernetes automatically mounts the ServiceAccount token as a volume at `/var/run/secrets/kubernetes.io/serviceaccount/`. That's how in-cluster apps authenticate to the API server. You can `kubectl exec` into the pod and see it.

Lab 6 -- Clean.

Challenge -- Solution looks correct

The final `--list` command is the most powerful verification:

`kubectl auth can-i --list --as=system:serviceaccount:default:app-sa | grep -E "pods|services"`

That dumps every permission the SA has - much faster than checking one verb at a time. Keep that pattern in mind for troubleshooting.

One small thing: the output you captured shows `[get list watch]` for pods but your Role only grants `get list`. The `watch` is likely coming from the original `pod-reader` Role binding still being active at the same time. When multiple RoleBindings exist for the same SA, permissions are **additive** - all bindings union together.

---

RBAC is actually one of the more approachable security topics once the three-piece pattern clicks: SA > RoleBinding > Role. The complexity people feel comes from the number of moving parts, not from any single piece being hard.

For CKA, you need exactly what W5D2 covers - create Roles, bind them, verify with `auth can-i`. That's the full scope.

CKS (which comes after CKA) goes significantly deeper on RBAC:

- `ClusterRole vs Role` - ClusterRoles span all namespaces, used for node/PV access
- `Overly permissive detection` - audit logs + spotting dangerous verbs like `*` wildcards or `escalate/bind/impersonate`
- `Projected ServiceAccount tokens` - time-limited tokens instead of long-lived ones
- `RBAC for system components` - understanding what system: prefixed roles do
- `Audit policy` - configuring the API server to log auth decisions

But CKS also layers on top of that: Network Policies, Pod Security Admission, Falco for runtime security, Trivy for image scanning, Secrets encryption at rest. RBAC is probably 15-20% of CKS.

The good news: CKA solidifies the foundation. By the time you get to CKS the RBAC mechanics will be muscle memory and you just extend them.

---

## Quick Test 

```bash
# Create the ServiceAccount if needed
kubectl create serviceaccount app-sa --dry-run=client -o yaml | kubectl apply -f -

# Apply the Role and RoleBinding
kubectl apply -f role-and-binding.yaml

# Test with a simple pod that uses app-sa
kubectl run test-pod --image=nginx --restart=Never --dry-run=client -o yaml | \
  kubectl apply -f -

# Get token for app-sa (if needed for external access)
kubectl create token app-sa -n default
```
