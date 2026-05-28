# Commands

## Create deployment

```bash
kubectl create deployment web --image=nginx
```

## Scale deployment

```bash
kubectl scale deployment web --replicas=3
```

## Watch pods

```bash
kubectl get pods -w
```
