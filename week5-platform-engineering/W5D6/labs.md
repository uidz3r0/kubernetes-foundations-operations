# W5D6 Labs — Gateway API

---

# Lab 1

Review Gateway resources

```
kubectl api-resources | grep gateway
```

## Observe

GatewayClass

Gateway

HTTPRoute

---

# Lab 2

Read GatewayClass YAML

```
cat yaml/gatewayclass.yaml
```

Questions

What controller owns it?

- `example.com/gateway-controller` owns the demo-gateway-class GatewayClass 

---

# Lab 3

Read Gateway YAML

```
cat yaml/gateway.yaml
```

Questions

Which port?

- port 80

Which protocol?

- HTTP protocol

How many listeners?

- only one listener

---

# Lab 4

Inspect HTTPRoute

```
cat yaml/httproute.yaml
```

Questions

Which backend service?

- its the `frontend-service:80`

Which path?

- path /

---

# Lab 5

Traffic Splitting

Inspect

```
weighted-route.yaml
```

Questions

Traffic percentages?

- 90% goes to backend-v1 while 10% of traffic goes to backend-v2

Which backend gets more traffic?

- backend-v1 gets more traffic

---

# Lab 6

Multiple Routes

Review

```
multi-route.yaml
```

Questions

Which paths exist?

- two paths exist. For /api and for /web

Which services receive traffic?

- traffic that match /api goes to api-service while what matches /web goes to web-service 

---

# Lab 7

Cross Namespace

Inspect

```
namespace-route.yaml
```

Questions

Which namespace owns Gateway?

- `platform` owns Gateway

Which namespace owns Route?

- `application` owns Route

Why is this useful?

- **Separation of duties**. The Gateway lives in a `platform` namespace owned by the <u>platform/infra team</u>, while the HTTPRoute lives in the `application` namespace owned by the <u>app/dev team</u>.

This means:

- **Platform team** controls the shared entry point (ports, TLS certs, hostnames) - one Gateway serves many teams.
- **App teams** attach their own routes to that Gateway without needing edit access to it.
- **RBAC boundary** - dev teams can't accidentally break the shared Gateway; they only manage their own Routes.

This is the single biggest advantage `Gateway API` has over `Ingress`: Ingress mashes everything into one resource, so route config and infra config can't be split across teams. Gateway API's GatewayClass - Gateway - HTTPRoute split is role-oriented by design..

---

# Challenge

Draw

GatewayClass

↓

Gateway

↓

HTTPRoute

↓

Service

↓

Pods

without looking at notes.