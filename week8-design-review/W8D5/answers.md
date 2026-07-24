# Answers

## Step 1 - Namespace

```bash
kubectl create namespace demo
k get ns

kubectl config set-context --current --namespace=demo
kubectl config view --minify | grep namespace

kubectl config set-context --current --namespace=default
```

---

## Step 2 - Secrets

```bash
kubectl create secret generic postgres-secret \
--from-literal=username=postgres \
--from-literal=password=password \
-n demo
```

```bash
k get secrets -n demo
```

--- 

## Step 3 - Storage

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner # indicates that this StorageClass does not support automatic provisioning
volumeBindingMode: WaitForFirstConsumer
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: demo-pv
spec:
  capacity:
    storage: 10Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  local:
    path: /opt/data
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - leia    # the storage path exist only in leia
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: demo-pvc
  namespace: demo  
spec:
  storageClassName: "local-storage" # Empty string must be explicitly set otherwise default StorageClass will be set
  volumeName: demo-pv
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi  
```

```bash
kubectl apply -f /k8s-lab/manifests/w8d5/storage.yaml
```

---

## Step 4 - Deploy Database

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
  namespace: demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
        - name: postgres
          image: postgres:15-alpine
          ports:
            - containerPort: 5432
          env:
            - name: POSTGRES_USER
              valueFrom:
                secretKeyRef:
                  name: postgres-secret
                  key: username
            - name: POSTGRES_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: postgres-secret
                  key: password
            - name: PGDATA
              value: /var/lib/postgresql/data/pgdata
          resources:
            requests:
              cpu: 100m
              memory: 256Mi
            limits:
              cpu: 500m
              memory: 512Mi
          volumeMounts:
            - name: postgres-storage
              mountPath: /var/lib/postgresql/data
          readinessProbe:
            exec:
              command:
                - pg_isready
                - -U
                - postgres
            initialDelaySeconds: 5
            periodSeconds: 10
          livenessProbe:
            exec:
              command:
                - pg_isready
                - -U
                - postgres
            initialDelaySeconds: 15
            periodSeconds: 20
      volumes:
        - name: postgres-storage
          persistentVolumeClaim:
            claimName: demo-pvc
```

```bash
kubectl apply -f /k8s-lab/manifests/w8d5/postgres-deployment.yaml
kubectl get pods -n demo
kubectl describe pod -l app=postgres -n demo
```

### 🔍 Key Features & Verification

1. PVC Mounting: Mounts demo-pvc (from Step 3) to /var/lib/postgresql/data.
2. Secrets: Injects credentials from postgres-secret (from Step 2).
3. Probes: Uses PostgreSQL native health checker pg_isready -U postgres for both readiness and liveness.
4. Resource Constraints: Sets basic requests (100m CPU / 256Mi RAM) and limits (500m CPU / 512Mi RAM).

---

## Step 5 - Deploy Backend

Here is the complete manifest for **Step 5 — Deploy Backend**, which includes the `ConfigMap`, `Deployment` (with RollingUpdate strategy & resource limits), and `ClusterIP Service`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: backend-config
  namespace: demo
data:
  DB_HOST: postgres
  DB_PORT: "5432"
  DB_NAME: demodb
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: demo
spec:
  replicas: 2
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
        - name: backend
          image: nginx:alpine
          ports:
            - containerPort: 80
          envFrom:
            - configMapRef:
                name: backend-config
          env:
            - name: DB_USER
              valueFrom:
                secretKeyRef:
                  name: postgres-secret
                  key: username
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: postgres-secret
                  key: password
          resources:
            requests:
              cpu: 50m
              memory: 128Mi
            limits:
              cpu: 250m
              memory: 256Mi
          readinessProbe:
            tcpSocket:
              port: 80
            initialDelaySeconds: 5
            periodSeconds: 5
          livenessProbe:
            tcpSocket:
              port: 80
            initialDelaySeconds: 10
            periodSeconds: 10
---
apiVersion: v1
kind: Service
metadata:
  name: backend
  namespace: demo
spec:
  type: ClusterIP
  selector:
    app: backend
  ports:
    - port: 80
      targetPort: 80
```

### 🔍 Verification & Key Features

- `ConfigMap Integration`: envFrom loads non-sensitive configuration (DB_HOST, DB_PORT, DB_NAME).
- `Secret Integration`: env injects DB_USER and DB_PASSWORD securely from postgres-secret.
- `Zero-Downtime Rolling Update Strategy`: Configured with maxSurge: 1 and maxUnavailable: 0 to ensure no active pods are terminated before new ones pass readiness probes.
- `Internal Service Discovery`: Exposes the backend via a ClusterIP Service named backend on port 80.

```bash
kubectl apply -f backend.yaml
kubectl rollout status deployment/backend -n demo
kubectl get pods,svc -n demo -l app=backend
```

```bash
# Inspect the ConfigMap
kubectl get configmap backend-config -n demo -o yaml

# Inspect the Deployment
kubectl get deployment backend -n demo -o yaml

# Inspect the Service
kubectl get service backend -n demo -o yaml 

# Check DNS resolution from another pod in the same namespace:
kubectl exec -it -n demo deploy/backend -- nslookup backend

# Inspect pod events
kubectl describe pod -l app=backend -n demo
```

---

## Step 6 - Deploy Frontend

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
        - name: frontend
          image: nginx:alpine
          ports:
            - containerPort: 80
          env:
            - name: BACKEND_URL
              value: "http://backend.demo.svc.cluster.local:80"
          resources:
            requests:
              cpu: 50m
              memory: 64Mi
            limits:
              cpu: 250m
              memory: 128Mi
          readinessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 3
            periodSeconds: 5
          livenessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 10
            periodSeconds: 10
---
apiVersion: v1
kind: Service
metadata:
  name: frontend
  namespace: demo
spec:
  type: ClusterIP
  selector:
    app: frontend
  ports:
    - port: 80
      targetPort: 80
```

```bash
kubectl apply -f frontend.yaml
kubectl rollout status deployment/frontend -n demo
kubectl get pods,svc -n demo -l app=frontend
```

```bash
# Get the ClusterIP of the frontend service
kubectl get svc -n demo -l app=frontend -o jsonpath='{.items[0].spec.clusterIP}'

# Get the pod IP of a backend pod
kubectl get pods -n demo -l app=backend -o jsonpath='{.items[0].status.podIP}'

# Use the cluster service IP to access the backend (from another pod if needed)
kubectl exec -it -n demo deploy/frontend -- curl http://[IP_ADDRESS]

# Inspect the frontend deployment
kubectl get deployment frontend -n demo -o yaml

# Inspect the frontend pod events
kubectl describe pod -l app=frontend -n demo
``` 

### 🔍 Verification & Key Features

- **Internal DNS Resolution**: The frontend uses the ClusterIP DNS name `http://backend.demo.svc.cluster.local:80` to communicate with the backend. Kubernetes automatically resolves this to the correct backend pod IP via CoreDNS.
- **Resource Constraints**: The frontend has defined CPU and memory requests and limits to ensure stable resource allocation.
- **Health Checks**: Both readiness (initialDelaySeconds: 3, periodSeconds: 5) and liveness (initialDelaySeconds: 10, periodSeconds: 10) probes are configured to ensure only healthy pods receive traffic and unhealthy ones are restarted.
- **Service Exposure**: Exposes the frontend via a ClusterIP Service named frontend on port 80 for internal access.

---

## Step 7 — Networking

### CoreDNS DNS Resolution Verification

```bash
# Verify DNS resolution from the frontend pod to the backend service:
kubectl exec -it -n demo deploy/frontend -- nslookup backend

# Expected output will show the ClusterIP of the backend service:
# Server:    [IP_ADDRESS]
# Address 1: [IP_ADDRESS] backend.demo.svc.cluster.local
# Name:      backend
# Address 1: [IP_ADDRESS]
```

### Application Connectivity Verification

```bash
# Test backend connectivity from frontend pod using the ClusterIP
kubectl exec -it -n demo deploy/frontend -- curl http://[IP_ADDRESS]

# Verify frontend can resolve and access backend service using the DNS name
kubectl exec -it -n demo deploy/frontend -- curl http://backend.demo.svc.cluster.local:80

# Test backend connectivity using the DNS name directly
kubectl exec -it -n demo deploy/backend -- curl http://backend

# Expected output from backend curl commands:
# <!DOCTYPE html>
# <html>
# <head>
# <title>Welcome to nginx!</title>
# ...
```

```bash
# Inspect the backend service ClusterIP
kubectl get svc backend -n demo -o jsonpath='{.spec.clusterIP}'

# Inspect the frontend service ClusterIP
kubectl get svc frontend -n demo -o jsonpath='{.spec.clusterIP}'

# Verify CoreDNS configuration in kube-system namespace
kubectl get svc -n kube-system kube-dns

# Check CoreDNS pod logs if needed
kubectl logs -n kube-system -l k8s-app=kube-dns
```

### Key Points to Explain

1. **ClusterIP Services**: Provide stable internal IP addresses for services, independent of pod IPs.
2. **DNS Resolution**: CoreDNS automatically creates DNS records for services in the format `<service-name>.<namespace>.svc.cluster.local`.
3. **Stable Backend Access**: Frontend uses `backend.demo.svc.cluster.local` to communicate with the backend, ensuring connectivity even if pod IPs change.
4. **Internal Service Communication**: All service-to-service communication happens within the cluster using ClusterIPs and DNS names.
5. **Calico Routing**: Calico handles the routing between pods on different nodes using BGP and overlay networks.

---

## Step 8 — Ingress

### Manifest: `ingress.yaml`

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  namespace: demo
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
    - host: app.lab.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: frontend
                port:
                  number: 80
```

### Verification & Testing Commands

```bash
# Apply the Ingress resource
kubectl apply -f ingress.yaml

# Verify Ingress resource and inspect assigned IP / Address
kubectl get ingress app-ingress -n demo

# Detailed view of the Ingress rules and backends
kubectl describe ingress app-ingress -n demo

# Test HTTP access using curl with Host header (if DNS /etc/hosts is not set yet)
curl -H "Host: app.lab.local" http://<NODE_OR_INGRESS_IP>

# Test HTTP access directly (assuming app.lab.local is in /etc/hosts)
curl http://app.lab.local
```

### Key Points to Explain

1. **Layer 7 HTTP Routing:** Ingress acts as a smart reverse proxy (typically NGINX or Traefik), routing external traffic to internal `ClusterIP` services based on hostnames (`app.lab.local`) and paths (`/`).
2. **Single Entry Point:** Avoids exposing multiple `NodePort` or `LoadBalancer` services, consolidating external traffic through a single entry point.
3. **Decoupled Architecture:** Workloads remain isolated inside the cluster using `ClusterIP` services; only the Ingress controller exposes desired services externally.
4. **TLS/SSL Termination:** Ingress controllers can handle TLS certificates (e.g., via cert-manager), offloading encryption overhead from container applications.