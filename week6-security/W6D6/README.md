# W6D6 — External Secrets Operator (Production Awareness)

## Objectives

Learn:

- Why Kubernetes Secrets alone are insufficient
- External Secrets Operator architecture
- SecretStore vs ClusterSecretStore
- ExternalSecret resources
- Secret refresh lifecycle
- Production secret management

This lab demonstrates the YAML resources used in production.

No cloud account is required.

---

## Expected Learning Outcomes

By the end of W6D6, you should be able to:

1. Explain why base64-encoded Kubernetes Secrets are not secure by themselves.
2. Describe how `External Secrets Operator (ESO)` integrates with external secret managers such as AWS Secrets Manager or HashiCorp Vault.
3. Differentiate between a `SecretStore` (namespace-scoped) and a `ClusterSecretStore` (cluster-scoped).
4. Explain the roles of `SecretStore`, `ExternalSecret`, Kubernetes `Secret`, and application `Deployment` in the secret lifecycle.
5. Understand that applications continue to consume standard Kubernetes Secrets, while ESO automates their creation and refresh.
6. Recognize why `ExternalSecret manifests belong in Git`, whereas plaintext Kubernetes Secret manifests containing credentials should not.
7. Understand how automatic secret rotation works when the source secret changes in the external provider.

## Simple Mental Map Answers

1. Base64 is encoding, not encryption. Anyone who can read the Secret can decode it. 
   - Kubernetes Secrets can be encrypted at rest using the Kubernetes EncryptionConfiguration feature, but by default they are only base64-encoded before being stored in etcd.
   - This prevents the common misconception that Kubernetes Secrets are always insecure. The real issue is that many clusters never enable encryption at rest.
2. ESO runs in the cluster, connects to an external provider, reads secret values, and creates or updates Kubernetes Secrets.
3. `SecretStore` is namespace-scoped. `ClusterSecretStore` is cluster-scoped and reusable across namespaces.
4. `SecretStore` says where and how to connect. `ExternalSecret` says what to fetch. Kubernetes `Secret` stores the synced value. `Deployment` consumes the Secret.
5. Applications still use normal Kubernetes Secrets through `secretKeyRef` or mounted Secret volumes. ESO manages creating and refreshing those Secrets.
6. `ExternalSecret` manifests contain references to secrets, not the real secret values. Plain Kubernetes Secret manifests can contain real credentials and should not be committed to Git.
7. When the provider secret changes, ESO refreshes the Kubernetes Secret. Pods may need a reload or restart, especially when secrets are consumed as environment variables.
   - Pods consuming Secrets as environment variables will not automatically see updated values and typically require a restart. Pods consuming Secrets as mounted volumes usually see updated files automatically, although the application itself may still need to reload the configuration.

Core flow:

```text
Git
  ↓
ExternalSecret
  ↓
External Secrets Operator
  ↓
AWS Secrets Manager / Vault / Azure Key Vault
  ↓
Kubernetes Secret
  ↓
Deployment
  ↓
Pod
```

---

## Real-world note

This lesson is very closely aligned with production Platform Engineering practices. In many organizations, developers commit only `ExternalSecret` resources to Git, while platform teams manage the integration between ESO and the external secret provider (for example, AWS Secrets Manager, Vault, or Azure Key Vault). This pattern fits naturally into GitOps workflows with tools such as Argo CD or Flux and is commonly expected knowledge for Kubernetes Platform Engineer, DevOps Engineer, and CKS-level roles.

---

## Interview Question

Q: If applications still use Kubernetes Secrets, why use External Secrets Operator?

A:
External Secrets Operator separates secret management from application deployment. Secret values remain in a centralized secret manager, can be rotated automatically, and are never committed to Git. Applications continue using standard Kubernetes Secrets without modification.

---

## Production vs Lab

This lab focuses on understanding the resources and workflow.

A production deployment would additionally include:

- External Secrets Operator installed via Helm
- IAM Roles for Service Accounts (IRSA) or Workload Identity
- AWS Secrets Manager, HashiCorp Vault, or another external provider
- Secret rotation policies
- GitOps deployment using Argo CD or Flux
