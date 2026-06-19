# W4D3 - Networking Troubleshooting

---

## Lab 1 - Service Selector Mismatch

Create:

```bash
kubectl apply -f yaml/app-pod.yaml
kubectl apply -f yaml/broken-selector-service.yaml
```

Investigate:

```bash
kubectl get svc
kubectl get endpoints
kubectl describe svc web-svc
```

Question:

Why does the Service have no endpoints?

- The service have no endpoints because the selector is `app: frontend` when it is suppossssed to be `app: web`

Fix:

Update selector to:

```yaml
app: web
```

---

## Lab 2 - Wrong targetPort

Create:

```bash
kubectl delete svc web-svc
kubectl apply -f yaml/broken-targetport-service.yaml
```

Test:

```bash
kubectl get endpoints

#kubectl port-forward svc/web-svc 8080:80
kubectl run test --image=busybox:1.36 -it --rm -- sh

# Then:
wget -qO- http://web-svc

# or
wget -S -O- http://web-svc
```


Question:

Why does traffic fail?

- traffic fail because the targetport is `8080` when its supposed to be `80`

Fix:

```yaml
targetPort: 80
```

---

## Lab 3 - DNS Troubleshooting

Create:

```bash
kubectl apply -f yaml/dns-test-pod.yaml
```

Enter pod:

```bash
kubectl exec -it dns-test -- sh
```

Test:

```bash
nslookup kubernetes.default
```

Check:

```bash
kubectl get pods -n kube-system
```

Questions:

Which component provides DNS?

- ```bash
  $ kubectl get pods -n kube-system | grep dns
  coredns-6f6b679f8f-ktg6j                     1/1     Running   0          19h
  coredns-6f6b679f8f-mfhnl                     1/1     Running   0          19h
  ```

How would DNS failures appear?

- Below shows it only resolves for `kubernetes.default.svc.cluster.local`

```bash
# nslookup kubernetes
Server:		10.96.0.10
Address:	10.96.0.10:53

Name:	kubernetes.default.svc.cluster.local
Address: 10.96.0.1

** server can't find kubernetes.svc.cluster.local: NXDOMAIN

** server can't find kubernetes.cluster.local: NXDOMAIN
** server can't find kubernetes.cluster.local: NXDOMAIN
** server can't find kubernetes.svc.cluster.local: NXDOMAIN
** server can't find kubernetes.lan: NXDOMAIN
** server can't find kubernetes.lan: NXDOMAIN

/ # cat /etc/resolv.conf 
search default.svc.cluster.local svc.cluster.local cluster.local lan
nameserver 10.96.0.10
options ndots:5
```

---

## Lab 4 - NetworkPolicy Blocking Traffic

Create:

```bash
kubectl apply -f yaml/networkpolicy-deny.yaml
```

Test connectivity.

Investigate:

```bash
kubectl get networkpolicy
kubectl describe networkpolicy deny-web
```

Question:

Why is traffic blocked?

- The NetworkPolicy selects pods labeled `app: web` and declares an `Ingress` policyType with no allowed rules, which blocks all incoming traffic to those pods.

- Deleting the policy is a valid lab fix. In production you'd add a specific ingress rule to allow only the traffic you want.

Fix:

Delete policy.

```bash
kubectl delete networkpolicy deny-web
```

---

## Lab 5 - Wrong Application Port

Create pod and service.

```bash
kubectl apply -f yaml/wrong-port-pod.yaml
kubectl apply -f yaml/wrong-port-service.yaml
```

Investigate:

```bash
kubectl get svc
kubectl get endpoints
kubectl describe svc
```

Question:

Why is traffic failing despite endpoints existing?

- The pod runs nginx on port 80, but the Service has `targetPort: 8080`. Endpoints exist (selector matches), but traffic hits port 8080 on the container and nothing is listening there. Fix is `targetPort: 80`.

Fix:

Match Service targetPort to container port.

---

## Challenge

Create a Service.

Break it intentionally:

1. Wrong selector
2. Wrong targetPort

Troubleshoot using only:

```bash
kubectl get
kubectl describe
kubectl get endpoints
kubectl exec
```

--- 

### The key lesson for W4D3 is:

```
Pod healthy
↓
Service exists
↓
Endpoints populated
↓
Port mapping correct
↓
DNS resolves
↓
NetworkPolicy allows traffic
```

If you can troubleshoot that chain quickly, you'll be well prepared for W4D6 Mock CKA scenarios where multiple networking problems are combined.