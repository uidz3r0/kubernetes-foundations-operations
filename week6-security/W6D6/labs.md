# W6D6 Labs

## Lab 1

Inspect the `SecretStore` manifest:

```bash
cat yaml/secretstore.yaml
```

Observe:

- The provider is AWS Secrets Manager.
- The region is `ap-southeast-2`.
- Production use also needs authentication, such as IAM roles, IRSA, access keys, or Vault tokens depending on the provider.

Note: `SecretStore` is an ESO custom resource. `kubectl apply --dry-run=client` requires ESO CRDs to be installed in the cluster.

---

## Lab 2

Inspect the `ExternalSecret` manifest:

```bash
cat yaml/externalsecret.yaml
```

Notice:

- `remoteRef`: the external provider secret to read.
- `secretKey`: the key to create inside the Kubernetes Secret.
- `target.name`: the Kubernetes Secret that ESO creates.

---

## Lab 3

Inspect the application `Deployment`:

```bash
cat yaml/app-deployment.yaml
```

Notice:

```yaml
env:
  valueFrom:
    secretKeyRef
```

The application still consumes a normal Kubernetes Secret.

The difference:

- The developer does not commit the real secret value.
- ESO creates or updates the Kubernetes Secret automatically.

---

## Lab 4

Compare the unsafe Secret manifest with the Git-safe ExternalSecret manifest.

Open:

```bash
cat yaml/fake-k8s-secret.yaml
```

Then open:

```bash
cat yaml/externalsecret.yaml
```

Ask:

Which one belongs in Git?

Answer:

`externalsecret.yaml` belongs in Git because it references the external secret.

`fake-k8s-secret.yaml` contains plaintext credentials and must not be committed as a real production Secret.

---

## Lab 5

Trace the lifecycle

Imagine AWS Secrets Manager contains

```text
db-password
```

ESO flow

```text
AWS Secrets Manager
        │
        ▼
SecretStore
        │
        ▼
ExternalSecret
        │
        ▼
Kubernetes Secret
        │
        ▼
Application Pod
```

This is the production pattern.

Applications still read from the Kubernetes Secret, not directly from AWS Secrets Manager.

---

## Lab 6

Reason about secret rotation.

Imagine the password changes in AWS Secrets Manager.

```text
AWS Secrets Manager password changes
        │
        ▼
ESO refreshes database-secret
        │
        ▼
Application must reload the value
```

If the application reads the secret as an environment variable, the Pod usually needs to restart before it sees the new value.

If the application reads the secret from a mounted Secret volume, Kubernetes can update the file in the running Pod, but the application must still reread or reload the file.
