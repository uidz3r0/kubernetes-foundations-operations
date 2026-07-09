# W6D7 — Security Integration Lab

## Objective

Deploy a small application using several Kubernetes security mechanisms together.

## Technologies Used

- Namespace isolation
- ConfigMaps
- Secrets
- ServiceAccounts
- RBAC
- Security Contexts
- Network Policies

---

## Deploy

```bash
kubectl apply -f namespace.yaml

kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml

kubectl apply -f serviceaccount.yaml
kubectl apply -f role.yaml
kubectl apply -f rolebinding.yaml

kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

kubectl apply -f networkpolicy.yaml
kubectl apply -f test-client.yaml

kubectl get all,ep,cm,secret,sa,role,rolebinding,netpol -n secure-app
```

---

## Verify

Pods

```bash
kubectl get pods -n secure-app
```

Service

```bash
kubectl get svc -n secure-app
```

Describe Security Context

```bash
kubectl describe pod -n secure-app
```

View ServiceAccount

```bash
kubectl get sa -n secure-app
```

View Role

```bash
kubectl describe role config-reader -n secure-app
```

View Secret

```bash
kubectl get secret app-secret -n secure-app
```

---

## Test Connectivity

```bash
kubectl exec -n secure-app test-client -- \
curl http://secure-nginx
```

Should succeed.

Launch another pod without the required label:

```bash
kubectl run bad-client \
--image=curlimages/curl \
-n secure-app \
-- sleep 3600
```

Test access:

```bash
kubectl exec -n secure-app bad-client -- \
curl http://secure-nginx
```

The request should fail because the NetworkPolicy only allows ingress from pods labeled `access=allowed`.


To reinforce defense in depth, have students verify each security layer.

```bash
# RBAC
kubectl auth can-i get configmaps \
  --as=system:serviceaccount:secure-app:app-sa \
  -n secure-app

kubectl auth can-i get secrets \
  --as=system:serviceaccount:secure-app:app-sa \
  -n secure-app
```

Expected

```bash
yes
no
```

Check the Security Context:

```bash
kubectl exec -n secure-app deploy/secure-nginx -- id
```

Expected:

`uid=101 gid=101`

Verify the root filesystem is read-only:

```bash
kubectl exec -n secure-app deploy/secure-nginx -- \
touch /etc/test
```

Expected:

`Read-only file system`

Verify the injected environment variables:

```bash
kubectl exec -n secure-app deploy/secure-nginx -- \
printenv | grep APP_MODE

kubectl exec -n secure-app deploy/secure-nginx -- \
printenv | grep USERNAME
```

Then verify the NetworkPolicy:

```bash
kubectl exec -n secure-app test-client -- \
curl http://secure-nginx

kubectl exec -n secure-app bad-client -- \
curl --connect-timeout 5 http://secure-nginx
```

That sequence nicely demonstrates:

1. RBAC (API permissions)
2. Security Contexts (container hardening)
3. Secrets & ConfigMaps (configuration management)
4. NetworkPolicy (network isolation)

It's a solid capstone because you're validating each layer rather than just applying manifests.

---

## Learning Outcomes

By completing this lab, you should be able to:

- Apply RBAC using `Roles` and `RoleBindings`.
- Restrict network traffic with `NetworkPolicies`.
- Run containers with hardened `Security Contexts`.
- Inject configuration through `ConfigMaps` and `Secrets`.
- Combine multiple security controls into a realistic deployment.

That sequence nicely demonstrates:

- RBAC (API permissions)
- Security Contexts (container hardening)
- Secrets & ConfigMaps (configuration management)
- NetworkPolicy (network isolation)