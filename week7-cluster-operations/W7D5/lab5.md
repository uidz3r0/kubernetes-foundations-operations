# Lab 5 — Understanding Quorum

Quorum means:

```
Majority of members must agree.
```

Examples

| Control Planes | Majority |
|---------------|----------|
|1|1|
|2|2|
|3|2|
|5|3|

This explains why production clusters typically use an odd number of control planes.

With two members:

Lose one node:

❌ No quorum

Cluster becomes read-only.

With three members:

Lose one node:

✅ Quorum maintained.