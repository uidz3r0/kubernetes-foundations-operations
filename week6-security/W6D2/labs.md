# W6D2 Labs — Secrets Management

Estimated time: 90–120 minutes

---

# Lab 1 — Create a Secret

Create:

```bash
kubectl create secret generic db-secret \
  --from-literal=username=admin \
  --from-literal=password=password123
```

Verify:

```bash
kubectl get secret
kubectl describe secret db-secret
```

Questions

- Can you see the password?
- How many keys exist?

---

# Lab 2 — Decode Secret

Display YAML.

```bash
kubectl get secret db-secret -o yaml
```

Decode password.

```bash
kubectl get secret db-secret \
-o jsonpath='{.data.password}' | base64 -d
```

Question

Why is Base64 not encryption?

---

# Lab 3 — Create Secret from YAML

Apply:

```bash
kubectl apply -f yaml/secret-literal.yaml
```

Verify.

---

# Lab 4 — Secret From File

Create:

```bash
echo "supersecret" > password.txt
```

Run:

```bash
kubectl create secret generic file-secret \
--from-file=password.txt
```

Verify.

---

# Lab 5 — Environment Variable

Deploy:

```bash
kubectl apply -f yaml/env-secret-pod.yaml
```

Exec:

```bash
kubectl exec env-secret-demo -- env
```

Question

Can you see `PASSWORD`?

---

# Lab 6 — Secret Volume

Deploy:

```bash
kubectl apply -f yaml/volume-secret-pod.yaml
```

Exec:

```bash
kubectl exec volume-secret-demo -- ls /etc/secret
```

Display:

```bash
kubectl exec volume-secret-demo -- cat /etc/secret/password
```

---

# Lab 7 — Update Secret

Ensure both `env-secret-demo` and `volume-secret-demo` are still running before continuing.

Edit:

```bash
kubectl edit secret db-secret
```

Note: values in the `data:` field must be base64-encoded. To encode a new value:

```bash
echo -n "newpassword" | base64
```

Paste the output into the edit buffer. Alternatively, switch the field from `data:` to `stringData:` and type plaintext — Kubernetes will encode it automatically.

Observe:

Mounted file changes.

Environment variable does not.

Restart Pod.

---

# Lab 8 — Immutable Secret

Apply:

```bash
kubectl apply -f yaml/immutable-secret.yaml
```

Try editing.

Expected:

```
field is immutable
```

---

# Lab 9 — Service Account Token

Deploy:

```bash
kubectl apply -f yaml/serviceaccount-secret-pod.yaml
```

Verify:

```bash
kubectl exec no-token-pod -- ls /var/run/secrets
```

Expected: the command fails with `No such file or directory`.

Question

Why does the directory not exist at all?

---

# Lab 10 — Registry Secret

Review:

```bash
cat yaml/registry-secret-example.yaml
```

Discuss how `imagePullSecrets` works.

---

# Cleanup

```bash
kubectl delete pod env-secret-demo
kubectl delete pod volume-secret-demo
kubectl delete pod no-token-pod

kubectl delete secret db-secret
kubectl delete secret file-secret
kubectl delete secret immutable-secret

rm -f password.txt
```

---

# Challenge

Create one Secret containing:

- `username`
- `password`
- `api-key`

Create a Pod that consumes:

- `username` as env variable
- `password` as mounted file
- `api-key` as mounted file

Verify all three.