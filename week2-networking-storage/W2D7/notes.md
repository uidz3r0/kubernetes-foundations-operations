# Week 2 Day 7 — Ingress, CoreDNS & Service Discovery

NOTE:

Ingress resources require an Ingress Controller.

For Kind, creating an Ingress resource alone does not expose traffic.

This lesson focuses on understanding the Ingress object and how it routes traffic.

Installing an Ingress Controller (such as NGINX Ingress Controller) will be covered later in the course.

## Objectives

Learn:

- What Ingress is
- How Ingress differs from Services
- Basic Ingress resources
- Kubernetes DNS
- CoreDNS
- Service discovery between Pods

---

# 1. Create Namespace

```bash
kubectl create namespace week2
```

---

# 2. Deploy Application

```bash
kubectl apply -f yaml/nginx-deployment.yaml -n week2
kubectl apply -f yaml/nginx-service.yaml -n week2
```

Verify:

```bash
kubectl get pods -n week2
kubectl get svc -n week2
```

---

# 3. Test Service Discovery

Create a temporary pod:

```bash
kubectl run testpod \
--image=busybox \
-it \
--rm \
--restart=Never \
-n week2 -- sh
```

Inside the pod:

```bash
nslookup nginx-service
```

Expected:

```text
Name: nginx-service
Address: <ClusterIP>
```

Exit:

```bash
exit
```

---

# 4. View CoreDNS

```bash
kubectl get pods -n kube-system
```

Find CoreDNS:

```bash
kubectl get pods -n kube-system -l k8s-app=kube-dns
```

View logs:

```bash
kubectl logs -n kube-system <coredns-pod>
```

---

# 5. Create Ingress

Apply:

```bash
kubectl apply -f yaml/ingress.yaml -n week2
```

Verify:

```bash
kubectl get ingress -n week2
```

Describe:

```bash
kubectl describe ingress web-ingress -n week2
```

---

# Questions

1. What problem does Ingress solve?
   - Ingress solves the cost and management overhead of creating multiple external cloud load balancers. It acts as a single entry point that provides advanced Layer 7 (HTTP/HTTPS) routing, directing external traffic to different internal Services based on hostnames (e.g., api.com) or paths (e.g., /images).

2. What is the difference between NodePort and Ingress?
   - NodePort is a low-level configuration that opens a specific port (30000-32767) on every single cluster node to expose a Service directly. Ingress is an intelligent Layer 7 proxy controller that manages external HTTP/HTTPS traffic entering the cluster, using standard ports (80/443) to route requests based on host or path rules.

3. What component provides DNS inside Kubernetes?
   - the local coredns in the control plane kube-system namespace provides the local name services.

4. What service name was resolved by nslookup?
   - nslookup nginx-service.week2.svc.cluster.local
        Server:		10.96.0.10
        Address:	10.96.0.10:53

        Name:	nginx-service.week2.svc.cluster.local
        Address: 10.96.62.197
   - the Fully Qualified Domain Name (FQDN) for the nginx-service running inside the week2 namespace, and it cleanly pointed to its stable ClusterIP (10.96.62.197).

5. Why do Pods use Service names instead of Pod IPs?
   - Pods use Service names because Pod IP addresses are volatile and change constantly as Pods are destroyed and recreated. Service names resolve to a permanent, stable ClusterIP via CoreDNS, allowing applications to reliably find each other without worrying about shifting container IPs underneath.

---

# Key Concepts

Ingress
→ HTTP/HTTPS routing layer

Service
→ Network endpoint for Pods

CoreDNS
→ Cluster DNS server

Service Discovery
→ Pods finding Services using DNS names

# Gateway API (Awareness Only)

Ingress is the traditional Kubernetes north-south routing API.

Gateway API is the newer Kubernetes networking model that introduces:

- GatewayClass
- Gateway
- HTTPRoute

Many organizations are adopting Gateway API as a successor to Ingress.