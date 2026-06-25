# W5D2 Notes – RBAC & Service Accounts

## Authentication vs Authorization

Authentication:

Who are you?

Authorization:

What are you allowed to do?

---

## Service Accounts

Pods authenticate to the API using ServiceAccounts.

Default:

```text
default
```

Custom:

```yaml
serviceAccountName: app-sa
```

---

## RBAC Objects

| Object | Purpose |
|-------|---------|
| Role | Defines permissions |
| ClusterRole | Cluster-wide permissions |
| RoleBinding | Assigns a Role |
| ClusterRoleBinding | Assigns a ClusterRole |

---

## Example Rule

```yaml
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs:
  - get
  - list
  - watch
```

---

## Verbs

Common verbs:

- get
- list
- watch
- create
- update
- patch
- delete

---

## Least Privilege

Grant only what the application needs.

Avoid:

```yaml
verbs:
- "*"
```

Avoid:

```yaml
resources:
- "*"
```

---

## Useful Commands

```bash
kubectl get sa

kubectl get role

kubectl get rolebinding

kubectl describe role

kubectl auth can-i list pods

kubectl auth can-i delete pods \
  --as=system:serviceaccount:default:app-sa
```

---

## Real Examples

Applications commonly need:

- External Secrets Operator
- ArgoCD
- Prometheus
- Ingress controllers

These typically run with dedicated ServiceAccounts and RBAC rules.

---

## CKA Relevance

You may need to:

- inspect RBAC
- troubleshoot permissions
- identify forbidden errors
- verify ServiceAccounts