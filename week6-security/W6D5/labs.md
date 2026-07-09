# W6D5 Labs

## Lab 1

Create the cluster.

```bash
kind create cluster --config yaml/kind-config.yaml
```

---

## Lab 2

Deploy secure pod.

```bash
kubectl apply -f yaml/secure-image-pod.yaml

kubectl get pods
```

Observe:

The pod runs normally.

---

## Lab 3

Deploy latest tag example.

```bash
kubectl apply -f yaml/bad-latest-image.yaml
```

Question:

Why is this considered bad practice?

---

## Lab 4

Deploy privileged pod.

```bash
kubectl apply -f yaml/privileged-pod.yaml
```

Observe:

The pod is accepted.

Question:

Why?

Answer:

Because no admission policy is enforcing restrictions.

Now imagine the namespace used Pod Security Admission restricted.

Would it be admitted?

No.

---

## Lab 5

Review security contexts.

```bash
kubectl describe pod secure-image

kubectl describe pod privileged-example
```

Compare:

- Privileged
- Non-root
- Read-only filesystem

---

## Lab 6

Inspect image information.

```bash
kubectl get pod secure-image -o yaml | grep image
```

---

## Lab 7

ImagePullPolicy

```bash
kubectl get pod secure-image -o yaml | grep imagePullPolicy
```

Why is `IfNotPresent` commonly used with pinned image versions?

---

## Lab 8

(Optional)

Install Trivy locally.

Scan a public image.

```bash
trivy image nginx:1.27.5
```

Observe:

- Vulnerabilities
- Severity
- Fixed versions

No Kubernetes cluster required.


---

## Challenge

Imagine you're operating a production Kubernetes cluster.

Write down five admission rules you would enforce.

Example:

- No privileged containers
- No latest tags
- Must run as non-root
- Read-only root filesystem
- Images only from approved registries
