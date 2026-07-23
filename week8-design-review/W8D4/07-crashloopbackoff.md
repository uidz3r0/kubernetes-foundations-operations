# CrashLoopBackOff

Meaning:

Container starts

↓

Container crashes

↓

Restart

↓

Repeat

---

## Commands

```
kubectl describe pod

kubectl logs

kubectl logs -p
```

---

## Common Causes

Application exception

Database unavailable

Bad configuration

Probe failures

Missing environment variables

OOMKilled

---

## Remember

Logs are your friend.