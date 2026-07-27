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
    storage: 5Gi
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
          - padme    # the storage path exist only in padme
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

k events --for Pod/postgres-fb9646cdc-z259v
k describe pod postgres-fb9646cdc-z259v -n demo
k logs postgres-fb9646cdc-z259v -c postgres -n demo
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
kubectl rollout history deployment/backend -n demo
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

- It creates an Ingress in the demo namespace.
- It routes traffic for host app.lab.local to the frontend Service.
- It uses the nginx ingress class, so the cluster needs an ingress-nginx controller running.

### Verification & Testing Commands

```bash
# Apply the Ingress resource
kubectl apply -f ingress.yaml

# Make sure the ingress controller is installed and ready
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx

# Make sure the Ingress exists and has an address
kubectl get ingress -n demo
kubectl describe ingress app-ingress -n demo

# Make sure frontend is still available
kubectl get svc -n demo frontend

# Test it with a host header if DNS is not set
curl -H "Host: app.lab.local" http://<INGRESS_IP>

# Test HTTP access using curl with Host header (if DNS /etc/hosts is not set yet)
kubectl get svc -n ingress-nginx   # Check the NodePort PORTS to use here
curl -H "Host: app.lab.local" http://<NODE_OR_INGRESS_IP>
curl -H "Host: app.lab.local" http://10.1.1.14:30430
curl -H "Host: app.lab.local" https://10.1.1.14:30703

# Test HTTP access directly (assuming app.lab.local is in /etc/hosts)
curl http://app.lab.local:30430
curl https://app.lab.local:30703

If you still want a simpler access path, the next option is to use kubectl port-forward or change the Service to LoadBalancer, but for this lab the NodePort approach is fine.
```

### We need to install the Ingress controller

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.2/deploy/static/provider/baremetal/deploy.yaml

# then Verify
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
kubectl get ingress app-ingress -n demo
```

### Key Points to Explain

1. **Layer 7 HTTP Routing:** Ingress acts as a smart reverse proxy (typically NGINX or Traefik), routing external traffic to internal `ClusterIP` services based on hostnames (`app.lab.local`) and paths (`/`).
2. **Single Entry Point:** Avoids exposing multiple `NodePort` or `LoadBalancer` services, consolidating external traffic through a single entry point.
3. **Decoupled Architecture:** Workloads remain isolated inside the cluster using `ClusterIP` services; only the Ingress controller exposes desired services externally.
4. **TLS/SSL Termination:** Ingress controllers can handle TLS certificates (e.g., via cert-manager), offloading encryption overhead from container applications.

---

## Step 9 — Scheduling

### Updated Cluster Topology (Change of Plans)

| Node  | Role             | Purpose Label         | Storage                          |
|-------|------------------|-----------------------|----------------------------------|
| luke  | Control Plane #1 | control-plane         | 230GB OS                         |
| han   | Control Plane #2 | control-plane+Storage | 2TB — NFS server (`/mnt/k8s-nfs`)|
| leia  | Control Plane #3 | control-plane         | 1TB OS                           |
| padme | **Worker**       | application           | 500GB — local `/opt/data`        |

### Node Label Strategy

```bash
kubectl label node han   purpose=control-plane
kubectl label node leia  purpose=control-plane
kubectl label node luke  purpose=control-plane
kubectl label node padme purpose=application

# Verify labels
kubectl get nodes -L purpose
```

### Taints and Tolerations

```bash
# The NoSchedule prevents pods from landing there without a toleration 
kubectl describe node luke han leia padme| grep Taint
  Taints:             node-role.kubernetes.io/control-plane:NoSchedule
  Taints:             node-role.kubernetes.io/control-plane:NoSchedule
  Taints:             node-role.kubernetes.io/control-plane:NoSchedule
  Taints:             <none>
```

---

### Storage in This Lab: Two Patterns

#### Pattern A — Local PV (W8D5 demo)

The `demo-pvc` uses a local volume on `padme:/opt/data` (the worker node).
This is already correctly configured in [storage.yaml](file:///home/allan/k8s-lab/manifests/w8d5/storage.yaml):

```yaml
nodeAffinity:
  required:
    nodeSelectorTerms:
      - matchExpressions:
          - key: kubernetes.io/hostname
            operator: In
            values:
              - padme    # Worker node — local storage at /opt/data
```

Ensure the directory exists on `padme`:
```bash
ssh padme "sudo mkdir -p /opt/data"
```

---

#### Pattern B — NFS PV (han:/mnt/k8s-nfs)

`han` exports `/mnt/k8s-nfs` to the entire `10.1.1.0/24` subnet, verified by:

```bash
showmount -e han
# Export list for han:
# /mnt/k8s-nfs 10.1.1.0/24
```

NFS PVs do **not** need `nodeAffinity` — they are accessible from any node. No local provisioner required:

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-pv
spec:
  capacity:
    storage: 50Gi
  accessModes:
    - ReadWriteMany          # NFS supports multi-node access (unlike local PVs)
  persistentVolumeReclaimPolicy: Retain
  storageClassName: ""       # Static provisioning — no StorageClass
  nfs:
    server: 10.1.1.11        # han's IP
    path: /mnt/k8s-nfs
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfs-pvc
  namespace: demo
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: ""
  volumeName: nfs-pv
  resources:
    requests:
      storage: 10Gi
```

NFS mount verification from any pod:
```bash
# From inside a pod that mounts the NFS PVC:
df -h | grep nfs
mount | grep nfs
```

---

### 9a — Application Pods → `padme` (Worker)

Pin `frontend` and `backend` to `padme` using `nodeSelector`:

```yaml
spec:
  template:
    spec:
      nodeSelector:
        purpose: application
```

```bash
kubectl patch deployment frontend -n demo --type=merge \
  -p '{"spec":{"template":{"spec":{"nodeSelector":{"purpose":"application"}}}}}'

kubectl patch deployment backend -n demo --type=merge \
  -p '{"spec":{"template":{"spec":{"nodeSelector":{"purpose":"application"}}}}}'

# Verify pods land on padme
kubectl get pods -n demo -o wide
```

---

### 9b — Postgres with Local PV on `padme`

`postgres` must land on `padme` because `demo-pv` is a local volume tied to `padme:/opt/data`.
The PVC binding enforces this via `nodeAffinity` in the PV. No toleration needed — `padme` is a plain worker with no `NoSchedule` taint:

```yaml
spec:
  template:
    spec:
      nodeSelector:
        purpose: application    # padme
      volumes:
        - name: postgres-storage
          persistentVolumeClaim:
            claimName: demo-pvc
```

---

### 9c — Pod Anti-Affinity for Backend HA

Spread backend replicas when more workers are added (best-effort in single-worker lab):

```yaml
spec:
  template:
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 100
              podAffinityTerm:
                topologyKey: kubernetes.io/hostname
                labelSelector:
                  matchLabels:
                    app: backend
```

> Use `preferred` (not `required`) — `required` would block scheduling on a single-worker lab.

---

### Verification

```bash
# Confirm pod placement
kubectl get pods -n demo -o wide

# Check node labels
kubectl get nodes -L purpose

# Inspect PV nodeAffinity
kubectl describe pv demo-pv | grep -A10 "Node Affinity"

# Verify NFS export reachable from padme
ssh padme showmount -e han
```

---

### Key Points to Explain

1. **`nodeSelector`:** Hard scheduling constraint using labels — pins workloads to specific node roles.
2. **`padme` as Worker:** Now the only worker node with `purpose=application`. All application pods land here.
3. **`han` as Infrastructure NFS Server:** 2TB storage exported over NFS to the entire lab subnet. NFS PVs use `ReadWriteMany` and have no `nodeAffinity` constraint since they are network-accessible.
4. **Local PV vs NFS PV:** Local PVs are fast but node-bound (`padme`). NFS PVs are shareable across nodes but add network latency. Use local for DB storage, NFS for shared/log storage.
5. **No Toleration Needed for `padme`:** Unlike control-plane nodes, `padme` (worker) has no `NoSchedule` taint — pods schedule there freely.

---

## Step 10 — Security

### Example hardening for the demo workloads

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: demo-sa
  namespace: demo
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: demo
spec:
  template:
    spec:
      serviceAccountName: demo-sa
      securityContext:
        runAsNonRoot: true
        runAsUser: 101
        runAsGroup: 101
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: frontend
          image: nginxinc/nginx-unprivileged:alpine
          ports:
            - containerPort: 8080
          readinessProbe:
            tcpSocket:
              port: 8080  
          livenessProbe:
            tcpSocket:
              port: 8080    
          securityContext:
            allowPrivilegeEscalation: false
            capabilities:
              drop:
                - ALL
            # readOnlyRootFilesystem: true  # not going to work on this image
---
apiVersion: v1
kind: Service
spec:
  ports:
    - port: 80
      targetPort: 8080
```

```bash
kubectl apply -f step10-serviceaccount.yaml
# kubectl rollout restart step10-frontend -n demo
# kubectl rollout restart step10-backend -n demo
kubectl apply -f step10-frontend.yaml
kubectl apply -f step10-backend.yaml

kubectl describe pod -n demo -l app=frontend
```

### USeful checks

```bash
kubectl rollout status deployment/backend -n demo
kubectl rollout status deployment/frontend -n demo
kubectl describe pod -n demo -l app=frontend
kubectl describe pod -n demo -l app=backend

kubectl get sa -n demo
kubectl get deploy frontend -n demo -o yaml

k events --for pod/backend-799977ff89-gcdbg
k logs -f pod/backend-799977ff89-gcdbg -c backend
```

### The main takeaway is:

- the security settings that matter most for the lab are working
- `readOnlyRootFilesystem: true` was the one that was causing trouble for this image
- leaving it commented out is a sensible choice for this demo
- `runAsNonRoot: true` + `nginx:alpine` + `port 80` is a bad combination

### What to verify

- Pods run with a dedicated ServiceAccount
- Pods are not running as root
- Privilege escalation is disabled
- Linux capabilities are dropped
- The container filesystem is read-only where the image supports it

### Why this matters

- Reduces the attack surface
- Follows least-privilege principles
- Improves the container security posture

---

## Step 11 — Resource Management

### Review the concepts

Resource requests and limits help Kubernetes decide where pods fit and how much CPU/memory they can consume.

- `requests` influence scheduling and placement.
- `limits` prevent a pod from consuming too much shared cluster capacity.

### Example from the lab

```yaml
resources:
  requests:
    cpu: 100m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 512Mi
```

### Useful verification commands

```bash
kubectl describe pod -n demo -l app=postgres
kubectl describe pod -n demo -l app=backend
kubectl describe pod -n demo -l app=frontend

kubectl top pods -n demo
kubectl top nodes
```

### What to explain

- Requests help the scheduler place pods on nodes with enough available CPU and memory.
- Limits protect the node from a noisy neighbor and help avoid resource starvation.
- In a small lab, you can see the effect clearly by comparing requests and limits for database, backend, and frontend workloads.

### Why this matters

- Improves predictability and workload placement
- Helps avoid node saturation
- Makes the platform more stable under load

---

## Step 12 - Health Checks

### What's already in place

Readiness and liveness probes were added back in Steps 4, 5, 6 and hardened again in Step 10:

- `postgres` — `exec: pg_isready -U postgres` for both readiness and liveness.
- `backend` / `frontend` — `tcpSocket`/`httpGet` on port 8080 (post Step 10 hardening).

The one probe type missing from the lab so far is `startupProbe`.

### Adding a startupProbe to postgres

`postgres` is the only workload where first boot (`initdb` running on an empty PVC) can legitimately take longer than a normal restart. A `startupProbe` protects that slow first boot without having to loosen the steady-state `livenessProbe`:

```yaml
# postgres-deployment.yaml — startupProbe added alongside the existing probes
startupProbe:
  exec:
    command:
      - pg_isready
      - -U
      - postgres
  failureThreshold: 30
  periodSeconds: 2
# up to 30 * 2s = 60s to come up before liveness/readiness are even evaluated
```

`nginx:alpine` / `nginx-unprivileged` start in well under a second, so adding a startupProbe to `backend`/`frontend` would be decorative — it's included here to explain the concept, not because those containers need it.

```bash
kubectl apply -f /k8s-lab/manifests/w8d5/step12-postgres-deployment.yaml
kubectl rollout status deployment/postgres -n demo
```

### Verification

```bash
kubectl describe pod -n demo -l app=postgres
# Look for "Startup: pg_isready ..." alongside Readiness/Liveness in the probe list,
# and confirm Ready/Liveness checks don't start firing until Startup succeeds.

kubectl get events -n demo --field-selector involvedObject.kind=Pod | grep -i postgres
```

To actually see a startupProbe do its job, temporarily set `failureThreshold` too low (e.g. `3`) and watch the pod get killed and restarted before Postgres finishes initializing — then revert to the real value. Confirms the failure mode a startupProbe is meant to prevent, rather than just trusting the YAML.

### Differences

| Probe | Purpose | Used on | Effect on failure |
| --- | --- | --- | --- |
| Startup | Gives slow-starting containers time to initialize | `postgres` (first `initdb`) | Readiness/liveness are suppressed until it succeeds once; if it never succeeds, the container is killed and restarted per `restartPolicy` |
| Readiness | Controls whether the pod receives traffic | `postgres`, `backend`, `frontend` | Pod is pulled from the Service `Endpoints`, but not restarted |
| Liveness | Detects a stuck/deadlocked container | `postgres`, `backend`, `frontend` | Container is killed and restarted |

### Key Points to Explain

- A `startupProbe` and a `livenessProbe` can point at the exact same check (`pg_isready`) — what differs is *when* the kubelet evaluates it and what it does on failure.
- While a `startupProbe` is defined and hasn't yet succeeded, the kubelet disables readiness and liveness checks entirely — this is what stops a slow-booting Postgres from being killed by a liveness probe tuned for steady state.
- Readiness failures are a traffic-management concern (Service endpoints); liveness failures are a container-health concern (restart). Startup failures are a one-time gate between the two.

### Why this matters

- Lets liveness probes stay tight/aggressive for steady-state failure detection without also having to tolerate slow first-boot behavior.
- Avoids the common anti-pattern of padding `initialDelaySeconds` on the liveness probe to cover worst-case startup time, which just makes steady-state failure detection slower for everyone.

---

## Step 13 - Scaling

```bash
kubectl scale deployment backend --replicas=4 -n demo
kubectl get pods -n demo -l app=backend -o wide
```

`padme` is still the only worker in this lab, so all 4 replicas land there — the Step 9 `podAntiAffinity` is `preferred`, not `required`, so it doesn't block scheduling on a single node. On a multi-worker cluster it would spread them.

---

## Step 14 - Rolling Update

### Trigger a real rollout

Re-applying the same `:alpine` tag wouldn't trigger a new rollout (same image digest), so bump to a pinned version tag:

```bash
kubectl set image deployment/backend backend=nginxinc/nginx-unprivileged:1.27-alpine -n demo
```

### Watch it roll out

```bash
kubectl rollout status deployment/backend -n demo
kubectl get rs -n demo -l app=backend
kubectl get pods -n demo -l app=backend -o wide
```

### History and rollback

```bash
kubectl rollout history deployment/backend -n demo
kubectl rollout undo deployment/backend -n demo
kubectl rollout status deployment/backend -n demo
```

### Key Points to Explain

- Step 5's `maxSurge: 1, maxUnavailable: 0` strategy — still in effect via `step10-backend.yaml` — means capacity never drops during the rollout: a new pod comes up and passes its `readinessProbe` before an old one is terminated.
- `kubectl set image` only patches the container image in the pod template; the Deployment's rollout strategy and probes from Steps 5/10/12 keep governing how the rollout actually happens.
- Each pod-template change creates a new ReplicaSet; the previous one is scaled to 0 (not deleted), which is what `kubectl rollout undo` scales back up.

### Why this matters

- Zero-downtime deploys come from readiness probes + rollout strategy working together — not from the image change itself.
- Rollback is fast because the previous ReplicaSet's pod spec already exists; nothing needs to be rebuilt.
