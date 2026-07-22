## Lab 4 — Storage Review

This lab is about selecting storage that supports the workload's access pattern and recovery needs.

When reviewing the manifest, think about portability, provisioning, and performance trade-offs.

Review

```yaml
storageClassName
```

Question

Why not hard-code a volume?

Expected answer

- StorageClass abstracts the storage backend.
- Allows migration.
- Supports dynamic provisioning.

Review

`ReadWriteOnce`

Why?

- Single writer.
- Suitable for databases.

Discuss

- `ReadWriteMany`
- `ReadOnlyMany`

Use cases.