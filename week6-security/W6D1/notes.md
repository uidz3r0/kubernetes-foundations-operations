# W6D1 — RBAC Deep Dive

## What is RBAC?

RBAC = Role Based Access Control.

It determines:

- Who can perform actions
- On which resources
- In which namespace
- Using which API verbs

Without RBAC, every authenticated user could potentially modify cluster resources.

---

## RBAC Objects

### Role

Namespace scoped permissions.

Example:

- pods
- deployments
- configmaps

inside one namespace.

---

### ClusterRole

Cluster-wide permissions.

Examples:

- nodes
- namespaces
- persistentvolumes

or reusable permissions across namespaces.

---

### RoleBinding

Attaches

- Role -> User

or

- Role -> Group

or

- Role -> ServiceAccount

inside one namespace.

---

### ClusterRoleBinding

Cluster-wide attachment.

Can bind

ClusterRole

to

- User
- Group
- ServiceAccount

across the cluster.

---

## Common Verbs

```
get
list
watch
create
update
patch
delete
```

---

## Common Resources

```
pods
deployments
services
configmaps
secrets
jobs
cronjobs
nodes
persistentvolumes
```

---

## Service Accounts

Pods do NOT run as users.

They run as ServiceAccounts.

Example:

```
default
```

Every namespace automatically has one.

Applications should normally use dedicated ServiceAccounts.

---

## Least Privilege

Always grant the minimum permissions required.

Bad:

```
verbs:
- "*"

resources:
- "*"
```

Good:

```
verbs:
- get
- list

resources:
- pods
```

---

## Inspect RBAC

```
kubectl auth can-i list pods

kubectl auth can-i delete pods

kubectl auth can-i create deployments
```

For another ServiceAccount:

```
kubectl auth can-i get pods \
--as=system:serviceaccount:default:developer-sa
```

---

## View Roles

```
kubectl get roles

kubectl get clusterroles

kubectl get rolebindings

kubectl get clusterrolebindings
```

Describe one:

```
kubectl describe role developer
```

---

## Interview Questions

1. Why use `Role` instead of `ClusterRole`?

- Use `Role` whenever permissions are limited to one namespace.

2. What is least privilege?

- Giving only the permissions required.

3. Difference between `RoleBinding` and `ClusterRoleBinding`?

- `RoleBinding` applies inside one namespace.
- `ClusterRoleBinding` applies across the cluster.

4. Can a Role grant node permissions?

- No.
- `Nodes` are cluster-scoped resources.
- Need `ClusterRole`.

5. Can a `ServiceAccount` have multiple Roles?

- Yes. Multiple RoleBindings are allowed.

---

## RoleBinding vs ClusterRoleBinding Reference

| Binding Type | Subject Kind | roleRef Kind | Resulting Scope |
|---|---|---|---|
| RoleBinding | User / Group / ServiceAccount | Role | Namespace-scoped |
| RoleBinding | User / Group / ServiceAccount | ClusterRole | Namespace-scoped (reusable ClusterRole, limited to this namespace) |
| ClusterRoleBinding | User / Group / ServiceAccount | ClusterRole | Cluster-wide (all namespaces) |
| ClusterRoleBinding | User / Group / ServiceAccount | Role | ❌ Not allowed |

## Key takeaways

- <u>RoleBinding</u> always results in namespace-scoped access, no matter whether it references a Role or a ClusterRole.
- <u>ClusterRoleBinding</u> always results in cluster-wide access, and can only reference a ClusterRole (never a Role).
- The **subject kind** (User, Group, ServiceAccount) does not affect scope at all — it only affects *who* receives the permission, not *where* it applies.
- Resource type is a separate constraint: cluster-scoped resources (nodes, PersistentVolumes, namespaces) require a ClusterRole regardless of binding type, since a Role can't even reference them.

### Real-world payoff: built-in ClusterRoles

Kubernetes ships with `view`, `edit`, and `admin` ClusterRoles out of the box:

```bash
kubectl get clusterrole view edit admin
```

When you grant someone "edit access to the dev namespace," you bind one of
these per-namespace with a RoleBinding (row 2 above):

```bash
kubectl create rolebinding dev-edit \
  --clusterrole=edit \
  --serviceaccount=dev:some-sa \
  -n dev
```

This is the point of row 2: define the permission set once as a ClusterRole,
then reuse it across namespaces with small per-namespace RoleBindings — no
copy-pasting Roles into every namespace.

### Granting to multiple namespaces

One ClusterRole, one RoleBinding per namespace — the SA gets access only
where you explicitly bind it:

```bash
kubectl create rolebinding dev-edit  --clusterrole=edit --serviceaccount=dev:some-sa  -n dev
kubectl create rolebinding qa-edit   --clusterrole=edit --serviceaccount=qa:some-sa   -n qa
kubectl create rolebinding prod-edit --clusterrole=edit --serviceaccount=prod:some-sa -n prod
```

Choose based on how broad the access should be:

| Goal | Approach |
| --- | --- |
| Access in specific namespaces (dev, qa, prod) | ClusterRole + one RoleBinding per namespace |
| Access in every namespace (incl. future ones) | ClusterRole + one ClusterRoleBinding |

The per-namespace RoleBinding approach is more YAML but follows least
privilege — the SA gets access exactly where granted, nowhere else.
A ClusterRoleBinding is convenient but grants cluster-wide (all current
and future namespaces), which is easy to over-grant. Prefer per-namespace
RoleBindings unless the permission genuinely needs to be cluster-wide
(e.g. a monitoring agent reading pods everywhere).

---

## Why start with RBAC?

This is the foundation for everything else in Week 6:

- W6D1 — RBAC (who is allowed to do what)
- W6D2 — Secrets Management (protecting sensitive data)
- W6D3 — Network Policies (controlling pod-to-pod communication)
- W6D4 — Pod Security & Security Contexts (hardening workloads)
- W6D5 — Admission Controllers & Image Security (policy enforcement and supply chain)
- W6D6 — External Secrets Operator (production awareness)
- W6D7 — Security Integration Lab (combine RBAC, NetworkPolicies, Security Contexts, and Secrets in a realistic scenario)

This sequence builds from authorization to workload hardening and aligns well with the types of Kubernetes security questions commonly asked in senior Platform Engineering and DevOps understanding.
