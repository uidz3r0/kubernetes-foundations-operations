# Failure Scenarios

## One Control Plane Lost

3 members

```
CP1

CP2

CP3
```

↓

Lose CP2

Remaining:

```
CP1

CP3
```

Quorum maintained.

Cluster continues operating.

---

## Two Control Planes Lost

```
CP1

CP2

CP3
```

↓

Lose CP2 and CP3

Only one remains.

No quorum.

Cluster unavailable.

---

## Worker Failure

Workers can fail without affecting etcd quorum.

Pods can be rescheduled.
