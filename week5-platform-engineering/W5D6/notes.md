# W5D6 — Gateway API Fundamentals

---

# Objectives

Understand:

- Why Gateway API exists
- GatewayClass
- Gateway
- HTTPRoute
- ParentRefs
- BackendRefs
- Route delegation
- Traffic splitting
- Cross Namespace routing

---

# Why not just Ingress?

Ingress became overloaded.

Problems:

- Controller-specific annotations
- Different implementations
- Difficult traffic management
- Poor extensibility

`Gateway API` solves these.

Instead of

`Ingress`

everything is separated into resources.

#### Platform Team owns:

- GatewayClass
- Gateway

#### Application Team owns:

- HTTPRoute

This separation is a major design improvement.

---

# Gateway API Architecture

                GatewayClass
                      │
                      ▼
                  Gateway
                      │
             +--------+---------+
             |                  |
        HTTPRoute          HTTPRoute
             |                  |
      backend service    backend service

---

# GatewayClass

Represents

"Which implementation?"

Examples

- Istio
- Contour
- Traefik
- NGINX Gateway
- Cilium

Example

apiVersion: gateway.networking.k8s.io/v1

kind: GatewayClass

---

# Gateway

Equivalent to a Load Balancer.

Defines

- listeners
- hostname
- protocol
- ports

Example

listener

- HTTP
- HTTPS
- TLS

---

# HTTPRoute

Defines routing rules.

Examples

- /
- /api
- /admin
- /images

Header matching

Method matching

Hostname matching

Traffic weighting

---

Example

```
example.com
      │
      ▼
 Gateway
      │
      ▼
 HTTPRoute
      │
 ┌────┴────┐
 │         │
api      frontend
```

---

# ParentRefs

HTTPRoute connects to Gateway using

parentRefs

Example

```
parentRefs:
- name: platform-gateway
```

---

# BackendRefs

Destination service.

Example

```
backendRefs:
- name: web-service
  port: 80
```

---

# Route Matching

Gateway API supports

Exact

```
/login
```

Prefix

```
/api
```

Regular expressions
(controller dependent)

---

# Traffic Splitting

Example

```
90%
Backend V1

10%
Backend V2
```

Very useful for

- Canary
- Blue Green

Progressive delivery

without using service mesh.

---

# Cross Namespace Routing

Gateway

- platform namespace

HTTPRoute

- application namespace

Controlled by permissions.

Very common in Platform Engineering.

---

# Ingress vs Gateway API

|Ingress|Gateway API|
|--------|-----------|
|Simple|Modular|
|Annotations|Structured|
|Limited|Extensible|
|Basic routing|Advanced routing|
|One resource|Multiple resources|
|Weak ownership|Platform/App separation|

---

# Typical Ownership

Platform Team

- GatewayClass
- Gateway
- TLS
- Load Balancer
- Security

Application Team

- HTTPRoute
- Routing
- Backends

---

# Production Flow

Internet

↓

Cloud Load Balancer

↓

Gateway

↓

HTTPRoute

↓

Service

↓

Pods

---

# Common Interview Questions

Why Gateway API?

- next-generation Kubernetes networking API. Its modular with advance routing and overcome Ingress limitations.

What is GatewayClass?

- a cluster-scope gateway resource similar to IngressClass of Ingress and StorageClass of PersistentVolumes.

Difference between Gateway and HTTPRoute?

- `Gateway` defines the entry point to the cluster (the infrastructure), like a load balancer, including listeners for ports and protocols. While `HTTPRoute` defines the application-specific routing rules (e.g., path-based, header matching) that attach to a Gateway.

How does traffic splitting work?

- Via a weighted round-robin mechanism (90% to v1, 10% to v2). This enables `canary deployments` and `blue-green rollouts` by adjusting weights over time.

Can multiple teams share one Gateway?

- Yes, a single Gateway can be shared across multiple namespaces. The Gateway API supports a multi-tenant design where cluster operators manage the Gateway, and application teams from different namespaces can attach their own HTTPRoute resources to it, allowing secure delegation and isolation.

How is this different from Ingress?

- Gateway API is a more powerful and flexible successor to Ingress. Key differences include support for multiple protocols (L4/L7, not just HTTP/HTTPS), a role-based resource model (GatewayClass/Gateway/Route vs. monolithic Ingress), native advanced routing (like traffic splitting), and role-oriented design (clear separation for infrastructure and app teams), avoiding vendor-specific annotations

- The Ingress API itself is not obsolete and won't be removed from Kubernetes. However, the most popular implementation—the Ingress NGINX Controller—is being retired, and the Ingress API has been frozen in favor of the Gateway API

In practice:

```bash
# Ingress way (single resource)
apiVersion: networking.k8s.io/v1
kind: Ingress
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /api
        backend:
          service:
            name: api-service
            port: 80

# while Gateway API way (two resources)
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: shared-gateway
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    protocol: HTTP
    port: 80
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: api-route
spec:
  parentRefs:
  - name: shared-gateway
  rules:
  - matches:
    - path:
        value: /api
    backendRefs:
    - name: api-service
      port: 80
```

---

### What You'll Learn by the End of W5D6

After completing this lesson, you should be able to:

- Explain why the Gateway API was introduced and how it improves upon Ingress.
- Describe the roles of `GatewayClass`, `Gateway`, and `HTTPRoute`.
- Understand the separation of responsibilities between platform engineers and application developers.
- Read and interpret Gateway API manifests.
- Explain path-based routing, traffic splitting (canary deployments), and cross-namespace routing.
- Recognize where the Gateway API fits into modern Kubernetes platform engineering and how it relates to GitOps, CI/CD, and future topics such as service meshes and advanced ingress controllers.

This provides a solid conceptual foundation without requiring a specific Gateway controller implementation, keeping the focus on Kubernetes platform architecture rather than vendor-specific tooling.