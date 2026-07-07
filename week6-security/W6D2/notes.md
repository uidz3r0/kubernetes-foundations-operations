# W6D2 — Secrets Management

---

# Objectives

Today you will learn:

- Why Kubernetes Secrets exist
- Different Secret types
- Creating Secrets
- Consuming Secrets
- Secrets as environment variables
- Secrets as mounted volumes
- Docker Registry Secrets
- Immutable Secrets
- Secret security considerations

---

# Why Secrets?

Never place passwords directly into Pod YAML.

Bad:

```yaml
env:
- name: DB_PASSWORD
  value: supersecret
```

Instead:

```yaml
Secret
        ↓
Pod reads Secret
```

This separates configuration from sensitive data.

---

# Secret Types

Most common:

```yaml
Opaque
```

General purpose.

Examples:

- passwords
- API keys
- tokens

---

Other types:

```yaml
kubernetes.io/dockerconfigjson
```

Used for pulling private images.

```yaml
kubernetes.io/tls
```

TLS certificates.

```yaml
bootstrap.kubernetes.io/token
```

Cluster bootstrap.

---

# Secret Data

Secrets are stored as:

```yaml
Base64 encoded
```

NOT encrypted.

Example:

```yaml
password: cGFzc3dvcmQ=
```

Decode:

```yaml
echo cGFzc3dvcmQ= | base64 -d
```

Result:

```yaml
password
```

Encoding ≠ Encryption.

---

# Creating Secrets

Literal:

```bash
kubectl create secret generic db-secret \
  --from-literal=username=admin \
  --from-literal=password=secret
```

View:

```bash
kubectl get secret
```

Describe:

```bash
kubectl describe secret db-secret
```

View YAML:

```bash
kubectl get secret db-secret -o yaml
```

---

# Creating From Files

```bash
echo "mypassword" > password.txt

kubectl create secret generic file-secret \
  --from-file=password.txt
```

---

# Using Secrets as Environment Variables

```yaml
env:
- name: PASSWORD
  valueFrom:
    secretKeyRef:
      name: db-secret
      key: password
```

Inside container:

```bash
echo $PASSWORD
```

---

# Using Secrets as Volumes

```yaml
volumes:
- name: secret-volume
  secret:
    secretName: db-secret
```

Mounted:

```yaml
/etc/secret/password
```

---

# Secret Updates

Mounted Secrets update automatically.

Environment variables do NOT.

Pod restart required.

---

# Immutable Secrets

```yaml
immutable: true
```

Benefits:

- performance
- accidental modification prevention

Cannot edit afterward.

---

# Docker Registry Secret

For private images:

```bash
kubectl create secret docker-registry regcred \
  --docker-server=<registry> \
  --docker-username=<user> \
  --docker-password=<password>
```

Pod:

```yaml
imagePullSecrets:
- name: regcred
```

---

# Service Accounts

Pods automatically receive a ServiceAccount token unless disabled.

```yaml
automountServiceAccountToken: false
```

Good security practice if unnecessary.

---

# Security Best Practices

Never commit Secrets to Git.

Use:

- External Secrets Operator
- HashiCorp Vault
- AWS Secrets Manager
- Azure Key Vault

Instead of storing production secrets in Kubernetes.

---

# Encryption At Rest

By default:

```yaml
etcd

↓

Base64 encoded
```

Production clusters should enable:

EncryptionConfiguration

API Server

↓

Encrypted etcd

---

# Useful Commands

Create Secret

```bash
kubectl create secret generic db-secret \
--from-literal=password=test
```

Decode

```bash
kubectl get secret db-secret -o jsonpath='{.data.password}' | base64 -d
```

Describe

```bash
kubectl describe secret db-secret
```

Delete

```bash
kubectl delete secret db-secret
```

---

# Interview Questions

1. Why are Secrets Base64 encoded?

   - (Base64 is transport encoding, not encryption.)

2. Difference between ConfigMap and Secret?

   - (ConfigMaps store non-sensitive configuration.)

3. How are Secrets mounted?

   - (Environment variables or Volumes.)

4. Can Pods automatically receive updated Secrets?

   - Mounted volumes yes.
   - Environment variables no.

5. How do production clusters store secrets?

   - Usually External Secrets + cloud secret manager.

---

## Learning outcomes

By the end of W6D2, you should be able to:

- Create Secrets using literals, files, and YAML manifests.
- Explain why Base64 encoding is not encryption.
- Consume Secrets as both environment variables and mounted volumes.
- Understand the behavior of Secret updates in Pods.
- Use immutable Secrets and understand their benefits.
- Configure imagePullSecrets for private container registries.
- Disable automatic ServiceAccount token mounting when it is not needed.
- Describe production-grade secret management approaches such as External Secrets Operator and cloud secret managers.