# Notes

Today is intentionally production awareness, not "install ESO from Helm". The goal is to understand how Kubernetes should consume secrets without storing plaintext credentials inside Git.

In production, you'll commonly see:

- AWS Secrets Manager + External Secrets Operator
- HashiCorp Vault + ESO
- Azure Key Vault + ESO
- Google Secret Manager + ESO

In production, developers usually commit `ExternalSecret` manifests. ESO creates the Kubernetes Secrets.

## Kubernetes Secret

Stores base64 encoded values.

Not encrypted by default.

```bash
echo password | base64
```

Base64 is NOT encryption.

---

## External Secrets Operator

Synchronizes secrets from:

- AWS Secrets Manager
- HashiCorp Vault
- Azure Key Vault
- Google Secret Manager

into Kubernetes.

---

## SecretStore

Defines:

- provider
- authentication
- region
- backend

---

## ExternalSecret

Maps an external secret into a Kubernetes Secret.

```text
External provider secret
  -> ExternalSecret
  -> Kubernetes Secret
```

Automatically refreshed.

---

## Advantages

No plaintext credentials in Git.

Secret rotation becomes automatic.

Pods continue using normal Kubernetes Secrets.

Developers don't know actual passwords.

---

## Production Flow

```text
Developer
  -> Git
  -> Argo CD / Flux
  -> ExternalSecret
  -> ESO
  -> AWS Secrets Manager / Vault / Azure Key Vault
  -> Kubernetes Secret
  -> Pod
```

---

## Secret Rotation

```text
Password changed in external provider
  -> ESO syncs
  -> Kubernetes Secret updated
  -> Application must reload the value
```

Important details:

- Secret volumes can update in running Pods.
- Secret values consumed as environment variables do not update until the Pod restarts.
- Some applications need restart or reload automation to use the rotated value.

---

## ClusterSecretStore

Shared across namespaces.

Used in most production clusters.

---

## SecretStore

Namespace scoped.

Usually used for smaller environments.

---

## Important

ESO does NOT replace Kubernetes Secrets.

It automates creation of them.
