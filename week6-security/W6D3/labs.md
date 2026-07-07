# W6D3 Labs — Network Policies

Estimated time: 75–100 minutes

> **Important**
>
> Kind's default CNI does **not** enforce NetworkPolicies. These labs are designed to teach the YAML, object behavior, and verification commands. To observe actual traffic being blocked or allowed, you would need a NetworkPolicy-capable CNI such as Calico or Cilium.

---

# Lab 1 — Deploy Test Workloads

Apply the test Pods and Service:

```bash
kubectl apply -f yaml/app-pod.yaml
kubectl apply -f yaml/client-pod.yaml
kubectl apply -f yaml/web-service.yaml
```

Verify:

```bash
kubectl get pods
kubectl get service
```

Expected:

- `web` Pod is running
- `client` Pod is running
- `web` Service exists

---

# Lab 2 — Inspect Labels

Display labels:

```bash
kubectl get pods --show-labels
```

Expected labels:

- `web` has `app=web`
- `client` has `app=client`

Question:

Which Pod should be selected by a policy with this selector?

```yaml
podSelector:
  matchLabels:
    app: web
```

---

# Lab 3 — Test Baseline Connectivity

From the `client` Pod, try to reach the `web` Service:

```bash
kubectl exec client -- wget -qO- web
```

If the request succeeds, you should see the default NGINX page HTML.

Also test DNS:

```bash
kubectl exec client -- nslookup web
```

Question:

Why does `wget web` depend on DNS?

---

# Lab 4 — Create Default Deny Ingress

Apply:

```bash
kubectl apply -f yaml/default-deny.yaml
```

Inspect:

```bash
kubectl get networkpolicy
kubectl describe networkpolicy default-deny

kubectl get netpol
```

Questions:

- Which Pods does `podSelector: {}` select?

  - podSelector is empty, which means it selects __all Pods in the namespace__.
  - so for podSelector if its empty, it means `all pods in the namespace`. If there is a label `app=web`, it means `all pods in the namespace with label app=web`
  - Take note: NetworkPolicies are additive allow lists, not explicit deny rules.

- Which traffic direction does `policyTypes: Ingress` affect?

  - Inbound traffic

- Are there any ingress allow rules?

```bash
# this test from client to web failed (Ingress to web)
k exec -it client -- wget -qO- web

# this test from client to cluster DNS is succesful (Egress to coredns)
k exec -it client -- nslookup web
```

In a policy-capable cluster, this would block inbound traffic to all Pods in the namespace.

In default Kind, the object exists but traffic is not blocked.

---

# Lab 5 — Allow Client to Web

Apply:

```bash
kubectl apply -f yaml/allow-from-client.yaml

kg netpol
  NAME           POD-SELECTOR   AGE
  allow-client   app=web        5s
  default-deny   <none>         8m8s
```

Inspect the policy.

```bash
kubectl describe networkpolicy allow-client

Name:         allow-client
Namespace:    default
Created on:   2026-07-06 18:21:41 +1000 AEST
Labels:       <none>
Annotations:  <none>
Spec:
  PodSelector:     app=web
  Allowing ingress traffic:
    To Port: <any> (traffic allowed to all ports)
    From:
      PodSelector: app=client
  Not affecting egress traffic
  Policy Types: Ingress
```

Questions:

- Which Pods are selected by the top-level `podSelector`?

  - `app=web`

- Which Pods are allowed by the `from` rule?

  - `app=client`
  
- Does this policy apply to the `client` Pod or the `web` Pod?

  - this policy is applied to whats inside PodSelector which is `app=web`

Read the rule as:

```text
Allow traffic into app=web Pods from app=client Pods.
```

Optional check:

```bash
kubectl exec client -- wget -qO- web | grep Welcome
<title>Welcome to nginx!</title>
<h1>Welcome to nginx!</h1>
```

In a policy-capable cluster, this would be allowed because `client` matches the allowed peer selector.

---

# Lab 6 — Deny Egress

Apply:

```bash
kubectl apply -f yaml/deny-egress.yaml
```

Inspect:

```bash
kubectl describe networkpolicy deny-egress

Name:         deny-egress
Namespace:    default
Created on:   2026-07-06 18:27:03 +1000 AEST
Labels:       <none>
Annotations:  <none>
Spec:
  PodSelector:     <none> (Allowing the specific traffic to all pods in this namespace)
  Not affecting ingress traffic
  Allowing egress traffic:
    <none> (Selected pods are isolated for egress connectivity)
  Policy Types: Egress
```

Questions:

- Which Pods are selected?

  - no `PodSelector` defined, so it selects __all Pods in the namespace__
  - NetworkPolicies are additive allow lists, not explicit deny rules.

- Which traffic direction is isolated?

  - `Egress`

- Are there any egress allow rules?

  - No more pods traffic can go out now even for DNS

In a policy-capable cluster, selected Pods would no longer be able to make outbound connections unless another policy allowed them.

---

# Lab 7 — Allow DNS Egress

Apply:

```bash
kubectl apply -f yaml/allow-dns-egress.yaml
```

Inspect:

```bash
kubectl describe networkpolicy allow-dns
```

Questions:

- Why do Pods need DNS when connecting to a Service by name?

  - Pods can communicate by IP, but when you use a Service name like `web`, DNS resolves that name to the Service IP.

- Which protocol and port does this policy allow?

  - It allows outgoing 53/UDP traffic

- Why is this policy additive with `deny-egress`?

  - `deny-egress` isolates all Pods for egress; and then `allow-dns` adds UDP/53 as allowed egress.

Test DNS:

```bash
kubectl exec client -- nslookup web
```

In a policy-capable cluster, DNS would be allowed because this policy permits UDP port 53.

---

# Lab 8 — Allow HTTP Egress

Apply:

```bash
kubectl apply -f yaml/allow-egress-http.yaml
```

Inspect:

```bash
kubectl describe networkpolicy allow-http

Name:         allow-http
Namespace:    default
Created on:   2026-07-06 18:38:38 +1000 AEST
Labels:       <none>
Annotations:  <none>
Spec:
  PodSelector:     <none> (Allowing the specific traffic to all pods in this namespace)
  Not affecting ingress traffic
  Allowing egress traffic:
    To Port: 80/TCP
    To: <any> (traffic not restricted by destination)
  Policy Types: Egress
```

Questions:

- Which Pods does this policy select?

  - this policy is for all pods in the namespace

- Which port does it allow?

  - it allows egress traffic `80/TCP`

- Does it allow HTTPS?

  - HTTPS is `443/TCP`, so its not included

- Does it allow DNS?

  - DNS is already allowed previously but not included in this manifest file

In a policy-capable cluster, selected Pods would now have both DNS egress and TCP port 80 egress because policies are additive.

---

# Lab 9 — Read Policy YAML

Open each policy file:

```bash
cat yaml/default-deny.yaml
cat yaml/allow-from-client.yaml
cat yaml/deny-egress.yaml
cat yaml/allow-dns-egress.yaml
cat yaml/allow-egress-http.yaml
```

For each file, answer:

- Which Pods are selected?

```bash
$ kg netpol 
NAME           POD-SELECTOR   AGE
allow-client   app=web        24m
allow-dns      <none>         12m
allow-http     <none>         7m25s
default-deny   <none>         32m
deny-egress    <none>         19m
```

- Is the policy for ingress, egress, or both?

  - Correct breakdown:
    `default-deny: Ingress`
    `allow-client: Ingress`
    `deny-egress: Egress`
    `allow-dns: Egress`
    `allow-http: Egress`

- What traffic is allowed?

  - DNS and HTTP for `egress`. Ingress-wise, `app=web` allows ingress from `app=client`; other ingress remains blocked by default-deny.

- What traffic would remain blocked in a policy-capable cluster?

  - everything except DNS and HTTP

---

# Cleanup

```bash
kubectl delete -f yaml/allow-egress-http.yaml
kubectl delete -f yaml/allow-dns-egress.yaml
kubectl delete -f yaml/deny-egress.yaml
kubectl delete -f yaml/allow-from-client.yaml
kubectl delete -f yaml/default-deny.yaml

kubectl delete -f yaml/web-service.yaml
kubectl delete -f yaml/client-pod.yaml
kubectl delete -f yaml/app-pod.yaml
```

---

# Challenge

Create a NetworkPolicy that:

- applies only to Pods labeled `app=web`
- allows ingress **only** from Pods labeled `app=client`
- allows egress **only** for DNS (UDP 53)

Do not look at previous examples.

Check your answer by explaining:

- why the top-level selector is `app=web`
- why `policyTypes` needs both `Ingress` and `Egress`
- why DNS is an egress rule
- why there is no deny rule
