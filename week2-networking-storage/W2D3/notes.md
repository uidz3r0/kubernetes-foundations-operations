# W2D3 - StatefulSets

## Objective

Learn how StatefulSets provide:

- Stable Pod names
- Stable network identities
- Persistent storage per Pod
- Ordered deployment and termination

Unlike Deployments, StatefulSets are designed for stateful applications such as:

- Databases
- Message queues
- Distributed storage systems

Examples:

- PostgreSQL
- MySQL
- MongoDB
- Kafka
- Elasticsearch

---

## Why Deployments Are Not Enough

A Deployment creates interchangeable Pods.

Example:

```bash
app-abc123
app-def456
app-ghi789
```

If a Pod is recreated:

```
app-def456 -> app-xyz999
```

Identity changes.

For databases this is a problem because:

- Nodes need predictable names
- Data must remain attached to the correct node

---

## StatefulSet Characteristics

### Stable Pod Names

Pods receive predictable names:

```bash
web-0
web-1
web-2
```

These names remain consistent after restarts.

---

### Ordered Startup

Pods are created sequentially:

```bash
web-0
web-1
web-2
```

Kubernetes waits for one Pod to become Ready before creating the next.

---

### Ordered Shutdown

Pods terminate in reverse order:

```bash
web-2
web-1
web-0
```

---

### Stable Storage

Each Pod gets its own PersistentVolumeClaim.

Example:

```bash
web-0 -> pvc-data-web-0
web-1 -> pvc-data-web-1
web-2 -> pvc-data-web-2
```

Storage remains attached even if Pods restart.

---

## Headless Services

StatefulSets typically require a Headless Service.

Normal Service:

myapp.default.svc.cluster.local

Headless Service allows DNS entries for each Pod:

```bash
web-0.nginx.default.svc.cluster.local
web-1.nginx.default.svc.cluster.local
web-2.nginx.default.svc.cluster.local
```

This allows applications to locate specific nodes.

---

## Key Commands

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx
spec:
  clusterIP: None
  selector:
    app: nginx
  ports:
    - port: 80
      targetPort: 80
```

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: nginx
spec:
  serviceName: nginx
  replicas: 3

  selector:
    matchLabels:
      app: nginx

  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest

        ports:
        - containerPort: 80
          name: http
```

Create resources

```bash
vim yaml/headless-service.yaml
vim yaml/nginx-statefulset.yam

kubectl apply -f yaml/headless-service.yaml
kubectl apply -f yaml/nginx-statefulset.yaml
```

View StatefulSets

```bash
kubectl get statefulsets
```

View Pods

```
kubectl get pods -o wide
```

Scale StatefulSet

```
kubectl scale statefulset nginx --replicas=5
```

Check PVCs

```
kubectl get pvc
```

Delete StatefulSet

```
kubectl delete statefulset nginx
```

Delete Service

```
kubectl delete service nginx
```

---

## Questions

1. What problem does a StatefulSet solve that a Deployment does not?
    - Statefulset allows predictable names unlike Deployment. 
    - Beyond just names, it gives Pods sticky identities (e.g., db-0, db-1) and maps them 1:1 to dedicated persistent volumes. Deployments treat Pods as completely interchangeable and anonymous.

2. Why are stable Pod names important?
    - The predictable names are for clustering/peering. In databases like PostgreSQL, MySQL, or RabbitMQ, the nodes need to talk to each other to replicate data. If db-1 restarts, it needs to boot back up with the exact same name so db-0 still recognizes it as a trusted cluster member.

3. What is the purpose of a Headless Service?
    - Instead of load-balancing traffic randomly, a Headless Service allows you to target a specific pod directly via DNS (e.g., db-0.my-service.svc.cluster.local).

4. What happens to storage when a StatefulSet Pod restarts?
    - The storage will be re-mounted when the StatefulSet Pod comes back.
    - Because of the Volume Claim Template, db-0 will always reconnect to the exact same Persistent Volume (pvc-db-0), ensuring no data loss or data swapping between nodes.

5. In what order are StatefulSet Pods created?
    - The Pod names are created sequentially from 0 to N-1 (e.g., db-0 must be fully running and healthy before db-1 even begins initializing).

6. In what order are StatefulSet Pods terminated?
    - The Pods are terminated in reverse order.
    - They terminate from N-1 down to 0 (e.g., db-1 is completely shut down before db-0 is touched).

7. Why are StatefulSets commonly used for databases?
    - StatefulSets is used because database clusters require strict data determinism. If you have a primary/replica database setup, the system must know exactly which pod is the writer (db-0) and which are the readers (db-1, db-2) so data doesn't get corrupted or split-brained.

8. What would happen if a database node received a new random name after every restart?
    - If a database node received a new random name, the database cluster would break entirely. If db-xyz crashes and comes back as db-abc, the other database nodes will treat it as a brand-new stranger. It won't be allowed to sync data, and your cluster will lose quorum.