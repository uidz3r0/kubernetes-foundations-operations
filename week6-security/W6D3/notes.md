# W6D3 — Network Policies

---

# Objectives

Today you will learn:

- Why NetworkPolicies exist
- The difference between default allow and default deny
- How `podSelector` chooses the Pods a policy protects
- How ingress rules allow traffic into selected Pods
- How egress rules allow traffic out of selected Pods
- Why NetworkPolicies are additive
- Why a supported CNI plugin is required for enforcement
- How to inspect and reason about NetworkPolicy YAML

---

# Why Network Policies?

By default, Kubernetes networking is open.

If there are no `NetworkPolicies` selecting a Pod:

```text
Ingress allowed
Egress allowed
```

That means any Pod can usually talk to any other Pod, and Pods can usually make outbound connections.

NetworkPolicies let you describe which traffic should be allowed.

They do not create explicit deny rules. Instead, they create isolation. Once a Pod is selected by a policy for `Ingress`, only allowed ingress traffic is permitted. Once a Pod is selected by a policy for `Egress`, only allowed egress traffic is permitted.

---

# CNI Requirement

NetworkPolicies only work if the CNI plugin supports them.

Examples:

- Calico
- Cilium
- Antrea
- Weave Net

Kind's default networking does **not** enforce NetworkPolicies.

In a default Kind cluster, you can still create, inspect, and reason about NetworkPolicy objects, but traffic will not actually be blocked.

This lesson focuses on understanding the YAML and the policy model. In a production cluster, or a Kind cluster with a policy-capable CNI installed, the same policies would be enforced.

---

# Main Components

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: example
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress: []
  egress: []
```

Important fields:

- `podSelector`: which Pods this policy applies to
- `policyTypes`: whether the policy affects ingress, egress, or both
- `ingress`: allowed inbound traffic
- `egress`: allowed outbound traffic

---

# The Most Important Question

When reading any NetworkPolicy, ask:

```text
Which Pods are selected by spec.podSelector?
```

Those are the Pods being protected by the policy.

Example:

```yaml
podSelector:
  matchLabels:
    app: web
```

This policy applies to Pods with:

```yaml
app: web
```

It does not apply to Pods with:

```yaml
app: client
```

---

# Empty podSelector

This selector:

```yaml
podSelector: {}
```

means:

```text
All Pods in this namespace
```

It is commonly used for namespace-wide default deny policies.

---

# Default Deny Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
spec:
  podSelector: {}
  policyTypes:
  - Ingress
```

This selects all Pods in the namespace and isolates them for ingress.

Because there are no `ingress` allow rules, no inbound traffic is allowed to those Pods.

---

# Default Deny Egress

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-egress
spec:
  podSelector: {}
  policyTypes:
  - Egress
```

This selects all Pods in the namespace and isolates them for egress.

Because there are no `egress` allow rules, no outbound traffic is allowed from those Pods.

---

# Allow Client to Web

This policy applies to the `web` Pod:

```yaml
podSelector:
  matchLabels:
    app: web
```

It allows ingress from Pods labelled `app=client`:

```yaml
ingress:
- from:
  - podSelector:
      matchLabels:
        app: client
```

Read it as:

```text
Allow traffic into app=web Pods from app=client Pods.
```

It does not mean:

```text
Apply this policy to app=client Pods.
```

The top-level `podSelector` always tells you which Pods the policy protects.

---

# Egress DNS

Pods often need DNS before they can reach Services by name.

For example:

```bash
wget web
```

usually requires a DNS lookup for the Service named `web`.

If egress is restricted and DNS is not allowed, name resolution can fail even if HTTP traffic is allowed.

A simple DNS egress allow rule looks like:

```yaml
egress:
- to:
  - namespaceSelector: {}
  ports:
  - protocol: UDP
    port: 53
```

This allows UDP port 53 to any namespace.

Real clusters often use a more specific selector for the `kube-system` namespace and CoreDNS Pods.

---

# Additive Policies

NetworkPolicies are additive.

If multiple policies select the same Pod, the allowed traffic is combined.

Example:

- Policy A allows DNS egress
- Policy B allows HTTP egress

Together, selected Pods may use DNS and HTTP.

There is no explicit deny rule in NetworkPolicy.

Traffic is either:

- allowed by at least one matching policy
- not allowed because no matching policy allows it

---

# Common Exam Facts

- NetworkPolicies are namespaced.
- A policy only affects Pods selected by `spec.podSelector`.
- `podSelector: {}` selects all Pods in the namespace.
- NetworkPolicies are allow lists.
- NetworkPolicies do not have deny rules.
- Multiple matching policies are additive.
- `Ingress` controls traffic entering selected Pods.
- `Egress` controls traffic leaving selected Pods.
- Enforcement requires a CNI plugin that supports NetworkPolicy.

---

# Useful Commands

```bash
kubectl get networkpolicy
kubectl get netpol
kubectl describe networkpolicy
kubectl apply -f policy.yaml
kubectl delete networkpolicy NAME
kubectl get pods --show-labels
kubectl get pod web -o wide
kubectl exec -it client -- wget -qO- web
kubectl exec -it client -- nslookup kubernetes.default
```
