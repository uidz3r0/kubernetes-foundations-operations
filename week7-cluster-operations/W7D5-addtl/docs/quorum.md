# Quorum

Quorum = majority of etcd members.

Examples

1 member

Need:

```
1
```

3 members

Need:

```
2
```

5 members

Need:

```
3
```

Without quorum:

- API unavailable
- Writes stop
- Cluster becomes read-only/unavailable

---

**Fault tolerance** in quorum-based systems is determined by the cluster size, where the `quorum size` is typically a majority ($n/2 + 1$) of the nodes.  A system can tolerate **f failures** if the cluster size is `2f + 1`, meaning the fault tolerance is the cluster size minus the quorum size. 

For example, in a 3-node cluster, the quorum is 2, allowing 1 failure.  In a 5-node cluster, the quorum is 3, allowing 2 failures.  The following table illustrates this relationship for common deployment sizes:

| Servers | Quorum Size | Fault Tolerance |
| --- | --- | --- |
| 1	| 1 | 0 |
| 3	| 2	| 1 |
| 5	| 3	| 2 |
| 7	| 4	| 3 |