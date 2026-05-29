# Week 1 - Kubernetes Foundations

## What is Kubernetes?

Kubernetes is a "container orchestration platform" that "manages workloads" using "desired state".

## Core Architecture

Control Plane:
    - API Server
    - Scheduler
    - Controller Manager
    - etcd

Worker Node:
    - kubelet
    - kube-proxy
    - container runtime

## Core Objects

### Pod

Smallest deployable unit.

### Deployment

Manages replica pods.

### Service

Stable network access to pods.

===

## W1D1: 
(May 23, 2026)

### Commands:

```bash
kind create cluster --name week1
kind get clusters
kubectl cluster-info
kubectl get nodes
kubectl get pods -A

kubectl describe pod -n kube-system coredns-xxxxx
    See: Image, Status, Events, IP, Node placement, *Container name
kubectl get pod -n kube-system coredns-xxxxx -oyaml

kubectl get namespaces

kubectl config get-contexts
kubectl config use-context kind-week1

kubectl config get-clusters
kubectl config current-context
kind delete cluster --name week1
```

Note: kind creates cluster and kubectl talks to cluster via Kubernetes API Server

- Cluster lifecycle = kind (or EKS/AKS/GKE/kubeadm/Terraform/Cluster API)
- Workload lifecycle = kubectl

### Questions:

1. What is a cluster?

   - AJ: equivalent to the whole AWS VPC. (not quite correct)
   - A Kubernetes cluster is the entire Kubernetes platform made up of the control plane + worker nodes, which manages and runs applications.

2. What is a node?

   - AJ: Is equivalent to a VM/EC2 for compute, providing shared CPU/Mem/storage and run pods
   - In cloud: - often EC2
   - in Kind → Docker container pretending to be a node

3. What is a pod?

   - AJ: Is a container that will host the application service inside a node. (newbie mistake)
   - A pod is the "smallest deployable unit in Kubernetes", which usually contains one or more containers.
   - Pod ≠ Container

    Containers inside same pod share:

     - IP address
     - localhost networking
     - volumes
     - lifecycle

    That’s why a pod is more than “just a wrapper”.

4. Why are there pods before I deploy anything?

   - AJ: pods provision cpu and memory. (❌ Not correct.)

   - Kubernetes uses Kubernetes to run Kubernetes.
   - Because Kubernetes uses system services (kube-system), run as pods to make the cluster work.
   - Kubernetes itself needs system services to function, and those services run as pods.

    Examples:
    - CoreDNS → internal DNS
    - kube-proxy → networking
    - etcd → cluster database
    - API server components

5. What does kubectl get pods -A show me? 

   - It shows all pods across all namespaces.

6. What is the control plane?

   - The control plane is the management layer of Kubernetes that makes decisions about the cluster, 
      - maintains desired state
      - schedules workloads, 
      - and exposes the API used to control Kubernetes.

   - better say, its the brain and/or management layer

7. Bonus: What lives in the control plane?

    When you created your Kind cluster, these components were there:
    - kube-apiserver     → front door of Kubernetes (everything talks here)
    - etcd               → cluster database (stores desired/current state)
    - kube-scheduler     → decides which node gets a pod
    - controller-manager → keeps actual state matching desired state

===

## W1D2:

### Commands:

```bash
kubectl run nginx --image=nginx
kubectl get pods -w                 → watch
kubectl get pods -o wide            → wide
kubectl logs nginx
kubectl exec -it nginx -- sh
kubectl describe pod nginx
kubectl get pod nginx -o yaml       → live pod
kubectl delete pod nginx
```

### Exercise:

1. Create nginx
   kubectl run nginx --image=nginx

2. Watch pod state live

   kubectl get pods -w

   Watch transitions
       ContainerCreating
       Running

   Question:
       Why does a pod not go straight to Running?

       Answer to think about: image pull, container startup, networking setup, kubelet checks.    

3. Wide outputs (see node + IP)

   kubectl get pods -o wide
    
   Look for:
       Pod IP
       Node
       Age
       Status 

   Question:
       Why does a Pod get its own IP?

4. Inspect logs
   kubectl logs nginx

   Question:
       Why can logs work even though nginx is running inside a container?

       Think: kubectl → API server → kubelet → container runtime
       
5. Exec into container
   kubectl exec -it nginx -- sh

   Inside:
       hostname
       ps
       ls /
       cat /etc/nginx/nginx.conf
       exit

6. Describe deeper
   kubectl describe pod nginx

   Containers
       Image
       Ports
       State

   Conditions
       Initialized
       Ready
       ContainersReady
       PodScheduled

   Events
       Pulled
       Created
       Started

7. Simulate app crash
   kubectl exec -it nginx -- sh

   Inside:
       kill 1

   Now check:
       kubectl get pods
       kubectl describe pod nginx

   Question:
       Why did the Pod stay but container restarted?

       This is a huge concept:
       - Pod = wrapper / Kubernetes object
       - Container = process inside it

       Kubernetes tries to restart failed containers inside the Pod depending on restart policy.
  
           kubectl get pod nginx -o yaml | grep restartPolicy
             restartPolicy: Always


8. Delete Pod 
   kubectl delete pod nginx
   kubectl get pods   

   Why no recreation?
       - Kubernetes does not recreate it because `kubectl run nginx --image=nginx` creates a standalone Pod. No controller, such as a Deployment or ReplicaSet, is maintaining a desired replica count for it.

    End-of-day questions (answer in your own words)
        Pod vs Container?
        Why does a Pod have its own IP?
        Why does killing container process not always delete the Pod?
        Why does deleting the Pod remove it permanently?
        What do Pod Events tell you?

### Questions 

1. Why does a pod not go straight to Running?
  - The Pod goes through startup steps first: scheduler places it on a node, kubelet pulls the image, networking is configured, volumes are mounted, and the container process starts before the Pod becomes Running.

2. Why does a Pod get its own IP?
  - The kubelet is on the node, not inside the Pod.
  - The API server talks to node kubelet, not pod IP.
  - A Pod gets its own IP so it can communicate directly with other Pods inside the cluster. Kubernetes networking expects every Pod to be addressable without manually mapping container ports.

3. Why can logs work even though nginx is running inside a container?
  - "kubectl logs" asks the API server, which talks to the kubelet on the node, and kubelet retrieves the container stdout/stderr logs from the container runtime.
  - the API server fetches the logs from that file on the host server/pod, not from inside the running container.

4. Pod vs Container?
  - A Pod is the smallest deployable Kubernetes object that contains one or more containers sharing network, storage, and lifecycle.
  - Container = process; Pod = Kubernetes wrapper around one or more containers

5. Why does a Pod have its own IP?
  - the IP is used for communication internally.

6. Why does killing container process not always delete the Pod?
  - Kubernetes notices the failed container and may restart it inside the same Pod based on restart policy.

7. Why does deleting the Pod remove it permanently?
  - Because the Pod was standalone and no controller (Deployment/ReplicaSet) was maintaining desired state, Kubernetes does not recreate it after deletion.

8. What do Pod Events tell you?
  - Pod Events tell you what happened to the Pod during its lifecycle — scheduling, image pull, container creation, startup, failures, restarts, etc.

===

## W1D3

### Commands

```bash
kubectl create deployment nginx-deploy --image=nginx
kubectl get deployments
kubectl get rs
kubectl get pods

kubectl describe deployment nginx-deploy
kubectl describe rs
kubectl get pods -o wide 

kubectl get pods
kubectl delete pod <pod-name>

kubectl scale deployment nginx-deploy --replicas=3
kubectl get deployments
kubectl get rs
kubectl get pods

kubectl set image deployment/nginx-deploy nginx=nginx:1.25

kubectl rollout history deployment/nginx-deploy
kubectl rollout status deployment/nginx-deploy

# exec it
kubectl exec -it nginx-deploy-5fd7574f9f-b542m -- nginx -v
```

### Questions

1. What got created?
    See:
        Deployment
        ReplicaSet
        Pod

    - Deployment manages ReplicaSet
    - ReplicaSet manages Pods

    - A Deployment is a higher-level controller that manages ReplicaSets and provides scaling, updates, and rollbacks.
    - A ReplicaSet ensures a specific number of identical Pods are running. If a pod dies, ReplicaSet creates a replacement

2. Inspect Deeper
    kubectl describe deployment nginx-deploy
    kubectl describe rs
    kubectl get pods -o wide 

    Look for:
        Desired replicas
        Current replicas
        Available replicas
        Pod template
        Events

    Why didn’t the Deployment create the Pod directly?
    Think in layers.

3. Delete a Pod (self-healing test).
    kubectl get pods
    kubectl delete pod <pod-name>

    Why did this Pod come back, but W1D2 pod did not?

4. Scale manually
    kubectl scale deployment nginx-deploy --replicas=3
    kubectl get deployments
    kubectl get rs
    kubectl get pods
    kubectl scale deployment nginx-deploy --replicas=1

    What is Kubernetes trying to maintain here?

5. Rolling Update
    kubectl set image deployment/nginx-deploy nginx=nginx:1.25

    kubectl get pods -w
    kubectl get rs

    Observe:

    New ReplicaSet created
    Old Pod terminated gradually
    New Pod becomes Ready

    Why create a new ReplicaSet instead of editing the existing Pod?

6. Rollout history
    kubectl rollout history deployment/nginx-deploy
    kubectl rollout status deployment/nginx-deploy

    Undo:
        kubectl rollout undo deployment/nginx-deploy

    kubectl get pods -w
    kubectl logs nginx-deploy-5fd7574f9f-tnsbs

### Questions:

1. What got created?
    - Creating a Deployment caused Kubernetes to create a Deployment object, which created a ReplicaSet, which then created Pods.
2. Why didn’t the Deployment create the Pod directly?
    - Deployment is a higher-level controller. It delegates Pod management to ReplicaSets.
3. Why did this Pod come back, but W1D2 pod did not?
    - In W1D3, the Pod came back because the ReplicaSet created a replacement to maintain desired state. In W1D2, there was no controller managing that Pod.
    Remember:
      - restartPolicy → restarts container inside same Pod
      - ReplicaSet → creates new Pod if Pod disappears
4. What is Kubernetes trying to maintain here?
    - Using scale, Kubernetes maintain the number of Pod replicas to scale out and in
5. Why create a new ReplicaSet instead of editing the existing Pod?
    - Kubernetes creates a new ReplicaSet because Pods are treated as immutable templates.Instead of changing existing Pods in place, Kubernetes creates new Pods from a new ReplicaSet and gradually replaces old ones.

6. What is the difference between Deployment and ReplicaSet?
    - Deployment manages ReplicaSets and adds rollout, rollback, and update logic. ReplicaSet’s job is simply to maintain the correct number of Pods
7. Why did deleting a Pod recreate it?
    - ReplicaSet detected that actual state was below desired state and created a replacement Pod.
8. Why does scaling change Pod count automatically?
    - Changing replicas updates desired state, and ReplicaSet creates or deletes Pods to match it.
9. Why create a new ReplicaSet during image update?
    - Deployment creates a new ReplicaSet because the Pod template changed (image version changed), and Kubernetes uses a new ReplicaSet to safely roll from old Pods to new Pods. 
    - Replicaset have Pod templates.
10. What does desired state mean?
    - Desired state is the configuration you declare (for example, “run 3 nginx Pods”), and Kubernetes continuously works to make actual state match that declaration.
11. Why are Deployments preferred over standalone Pods?
    - Deployments provide self-healing, scaling, rolling updates, and rollbacks, which standalone Pods do not.

### Summary:

- Deployment creates/manages ReplicaSets.
- ReplicaSet maintains Pod count.
- Deleting a Deployment-managed Pod causes replacement.
- Deleting a standalone Day 2 Pod does not.
- Scaling changes desired replica count.
- Rolling updates create a new ReplicaSet.
- Deployments are preferred over standalone Pods because they provide self-healing, scaling, rollout, and rollback.

---

## W1D4 – Labels, Selectors, and Namespaces

This is the next logical step because now you understand objects being created, and Day 4 teaches how Kubernetes groups and finds them.

### Commands
```bash
# Create Pods with labels
kubectl run nginx1 --image=nginx --labels="app=web,env=dev"
kubectl run nginx2 --image=nginx --labels="app=web,env=prod"
kubectl run redis1 --image=redis --labels="app=db,env=dev"

# View labels
kubectl get pods --show-labels

# Filter with selectors
kubectl get pods -l app=web
kubectl get pods -l env=dev
kubectl get pods -l app=web,env=prod

# Describe one pod
kubectl describe pod nginx1

# Add/change labels
kubectl label pod nginx1 version=v1
kubectl label pod nginx1 env=test --overwrite

# Delete using selector
kubectl delete pods -l env=dev

# Namespaces
kubectl get namespaces
kubectl create namespace test

# Run pod inside namespace
kubectl run nginx-ns --image=nginx -n test

# View pods in namespace
kubectl get pods -n test

# View all namespaces
kubectl get pods -A

# Delete namespace pod
kubectl delete pod nginx-ns -n test
```

### Questions to Answer

1. Why use labels?
    - works like sticky notes
    - to identify or group Kubernetes objects based on a key-value pair called metadata tag
  
    Names identify one object
    Labels identify groups of objects

2. What does a selector do?
    Observe:
    kubectl get pods -l app=web

    The selector works like a "search-query" that filters Kubernetes objects with the same "label metadata"

    How did Kubernetes know which Pods matched?
        Kubernetes scans metadata and returns all Pods where "app == web"

3. Why can a Pod have many labels?
    Example:
    app=web
    env=prod
    version=v1

    What problem does that solve?
    - AJ: A single Pod can belong to multiple logical groups at the same time.
    - A Pod can have multiple labels so Kubernetes can group and filter resources in more flexible ways across different dimensions (application, environment, version, team, etc.)
    - With multiple labels, grouping becomes easier.

4. What happened when you used:
    kubectl delete pods -l env=dev

    - Deletes all pods that matched the Selector against the tagged label.
    - this works with Services and Deployments too

5. What is a Namespace?
    Logical grouping of Kubernetes objects for isolation.

    After:
    kubectl get pods -A

    Why can different namespaces have their own resources?
    To isolate resources based on their purpose, like staging versus production.

6. Why do Deployments need selectors?

    Hint:

    Deployment must know:
    - “Which Pods belong to me?”

    - A Deployment uses selectors to identify which Pods belong to its ReplicaSet, so it knows what to manage, scale, replace, or update.

    Expected Learning
      - Labels = metadata tags
      - Selectors = query/filter mechanism
      - Namespaces = local logical isolation
      - Controllers use selectors to manage Pods
      - Services later use selectors to route traffic

---

## W1D5 – Services

Pods are temporary. Their IP addresses can change when they die and get recreated.

A Service provides a stable network endpoint in front of Pods.

Instead of talking directly to Pods:

    Client → Service → Pods

    The Service finds Pods using labels/selectors.

### Commands

```bash
# Create Deployment
kubectl create deployment web --image=nginx --replicas=3

# View pods
kubectl get pods --show-labels

# Expose Deployment as Service
kubectl expose deployment web --port=80 --target-port=80

# View services
kubectl get svc

# Describe service
kubectl describe svc web

# Test service inside cluster
kubectl run testbox --image=busybox --restart=Never -it -- sh
# Inside testbox
wget -qO- http://web

# or
kubectl run curl --image=curlimages/curl --restart=Never -it -- sh
curl http://web

# Exit testbox
exit

# Scale deployment
kubectl scale deployment web --replicas=5

# View endpoints
kubectl get endpoints

# Delete test pod
kubectl delete pod testbox
```

## Questions to Answer

1. Why not connect directly to Pods?

   - Pod IPs are temporary.
   - Pods can die and be recreated.
   - Service provides a stable endpoint.

2. What does a Service use to find Pods?

   - Labels + selectors.

   Example:
       app=web

   Service scans for matching Pods and routes traffic to them.

3. What is ClusterIP?

   - Default Service type.
   - Gives an internal virtual IP reachable inside the cluster.
   - Used for Pod-to-Pod communication. (although its Pod-to-Service-then-to-Pod)

4. Why did DNS name "web" work?

   - Kubernetes creates internal DNS records for Services.
   - Pods can talk to Services by name instead of IP.

5. What happened after scaling?

   Before:
       3 Pods

   After:
       5 Pods

   Service automatically included new Pods because they matched the selector.

6. What are Endpoints?

   - Actual Pod IPs behind a Service.
   - Service forwards traffic to these backend Pods.

### Concept (important mental model)

Think of it like this:

    Without Service:
        Client → Pod IP (IP breaks if Pod dies)

    With Service:
        Client → Service (stable network endpoint)
                    ↓
                Pod1
                Pod2
                Pod3

    One correction to watch for

        When you do:
            kubectl expose deployment web --port=80 --target-port=80

        Kubernetes automatically creates the selector for that Deployment.

        You can verify:
            kubectl describe svc web

        Look for:
            Selector: app=web
            Endpoints: 10.x.x.x:80 ...

        That’s the real “aha” moment of Day 5.

### Expected Learning

  - Service = stable network endpoint
  - ClusterIP = internal access
  - Labels/selectors connect Service to Pods
  - DNS works inside cluster
  - Services automatically track Pods
  - Service load balances traffic across matching Pods

  Service model: Service is stable, Pods are replaceable, labels/selectors connect them, DNS gives the Service a name.

---

## W1D6 – ConfigMaps and Secrets

Applications often need configuration such as:

  - Environment mode
  - API endpoints
  - Feature flags
  - Database passwords

Hardcoding these into container images is bad practice.

Kubernetes separates this using:

   - ConfigMap → non-sensitive configuration
   - Secret → sensitive values

### Commands

```bash
# Create ConfigMap
kubectl create configmap app-config \
    --from-literal=APP_MODE=production \
    --from-literal=APP_COLOR=blue

# View ConfigMap
kubectl get configmap
kubectl describe configmap app-config

# Create Secret
kubectl create secret generic app-secret \
    --from-literal=DB_PASSWORD=supersecret

# View Secret
kubectl get secret
kubectl describe secret app-secret
* Kubernetes stores secret base64-encoded, not plain text but not encrypted either
    
kubectl get secret app-secret -oyaml
    echo c3VwZXJzZWNyZXQ= | base64 --decode
```

### Inject as Environment variables


```bash
cat << 'EOF' > config-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: config-demo
spec:
  containers:
  - name: demo
    image: busybox
    command: ["sh", "-c", "sleep 3600"]
    env:
    - name: APP_MODE
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: APP_MODE
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: app-secret
          key: DB_PASSWORD
EOF
```

```bash
# Create Pod using ConfigMap and Secret
kubectl apply -f config-pod.yaml

# View Pod
kubectl get pod
kubectl describe pod config-demo

# Enter Pod
kubectl exec -it config-demo -- sh

# Inside Pod
echo $APP_MODE
echo $DB_PASSWORD

# Exit
exit
```

### Inject as file thru mounted volume

```bash
cat << 'EOF' > config-volume-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: volume-demo
spec:
  containers:
  - name: demo
    image: busybox
    command: ["sh", "-c", "sleep 3600"]
    volumeMounts:
    - name: config-vol
      mountPath: /etc/config
  volumes:
  - name: config-vol
    configMap:
      name: app-config
EOF
```

```bash
# Create Pod with ConfigMap mounted as files
kubectl apply -f config-volume-pod.yaml

# Check mounted files
kubectl exec -it volume-demo -- sh

# Inside Pod
ls /etc/config
cat /etc/config/APP_MODE
cat /etc/config/APP_COLOR

# Exit
exit

# Cleanup
kubectl delete pod config-demo
kubectl delete pod volume-demo
kubectl delete configmap app-config
kubectl delete secret app-secret
```

## Questions to Answer

1. Why use ConfigMaps?

    - Store application configuration outside the container image.
    - Allows configuration changes without rebuilding the app image.

2. Why not store passwords in ConfigMaps?

    - ConfigMaps are for non-sensitive data.
    - Secrets are designed for sensitive values.

3. How can Pods consume ConfigMaps?

    - Environment variables
    - Mounted files (volumes)

4. How can Pods consume Secrets?

    - Environment variables
    - Mounted files (volumes)

5. Is a Secret encrypted by default?

    - Secret data is Base64 encoded by default.
    - Base64 is NOT encryption.
    - Real encryption depends on cluster configuration.

## Concept (important mental model)

Think of it like this:

    Without Kubernetes config:
        Container image contains:
            APP_MODE
            DB_HOST
            PASSWORD   (bad)

    With Kubernetes:
        Container image stays generic

        Kubernetes injects:
            ConfigMap → configuration
            Secret → sensitive values

Two common ways Pods receive data

    As environment variables:
        APP_MODE=production

    As mounted files:
        /etc/config/APP_MODE
        /etc/config/APP_COLOR

### Expected Learning

- ConfigMap stores non-sensitive configuration
- Secret stores sensitive values
- Pods can consume config as env vars
- Pods can consume config as mounted files
- Container images should stay generic
- Configuration should be externalized

### Mental model:

- Deployment runs app
- Service exposes app
- ConfigMap configures app
- Secret provides sensitive data

---

## W1D7 — Foundation Lab / Integration Day

Today is the integration day for Week 1.

You will combine:

- Pods
- Deployments
- ReplicaSets
- Services
- Namespaces
- ConfigMaps
- Secrets

You will also intentionally break things and troubleshoot them.

---

## Goal

Build a small application stack:

Management/Control flow:
   Deployment → ReplicaSet → Pod

Data traffic flow:
   Client → Service → Pod (Deployment isn't shown here since this is related to traffic flow)

The Pod will:

- use environment variables from ConfigMap
- use credentials from Secret
- expose traffic through a Service

Then you will troubleshoot:

- broken selectors
- missing environment variables
- incorrect Service mappings

---

## Step 1 — Create Namespace

```
kubectl create namespace integration-lab
kubectl get ns
```

## Step 2 — Create ConfigMap

Create configmap.yaml

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: integration-lab

data:
  APP_COLOR: blue
  APP_MODE: production
```

```
kubectl apply -f configmap.yaml

kubectl get configmap -n integration-lab
kubectl describe configmap app-config -n integration-lab
```

## Step 3 — Create Secret

Generate base64 values:
```
echo -n "admin" | base64
echo -n "supersecret" | base64
```

Create secret.yaml
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
  namespace: integration-lab

type: Opaque

data:
  username: YWRtaW4=
  password: c3VwZXJzZWNyZXQ=
```

```
kubectl apply -f secret.yaml

kubectl get secrets -n integration-lab
kubectl describe secret app-secret -n integration-lab
```

## Step 4 — Create Deployment

Create deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment

metadata:
  name: demo-app
  namespace: integration-lab

spec:
  replicas: 2

  selector:
    matchLabels:
      app: demo

  template:
    metadata:
      labels:
        app: demo

    spec:
      containers:
      - name: web
        image: nginx

        env:
        - name: APP_COLOR
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: APP_COLOR

        - name: APP_MODE
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: APP_MODE

        - name: DB_USER
          valueFrom:
            secretKeyRef:
              name: app-secret
              key: username

        - name: DB_PASS
          valueFrom:
            secretKeyRef:
              name: app-secret
              key: password
```
```
kubectl apply -f deployment.yaml

kubectl get deploy -n integration-lab
kubectl get rs -n integration-lab
kubectl get pods -n integration-lab
```

## Step 5 — Inspect Environment Variables

Get pod name:
```
kubectl get pods -n integration-lab
```
Exec into one pod:
```
kubectl exec -it <pod-name> -n integration-lab -- /bin/bash
```
Inside container:
```
env | grep APP
env | grep DB
```
Exit:
```
exit
```

## Step 6 — Create Service

Create service.yaml
```yaml
apiVersion: v1
kind: Service

metadata:
  name: demo-service
  namespace: integration-lab

spec:
  selector:
    app: demo

  ports:
  - protocol: TCP
    port: 80
    targetPort: 80

  type: ClusterIP
```

```
kubectl apply -f service.yaml

kubectl get svc -n integration-lab
kubectl describe svc demo-service -n integration-lab
```

## Step 7 — Test Connectivity

Run temporary pod:
```
kubectl run tester \
  --image=busybox \
  -it \
  --rm \
  -n integration-lab \
  -- sh
```
Inside pod:
```
wget -qO- demo-service
```
Exit:
```
exit
```

# TROUBLESHOOTING LABS

Now intentionally break things.

## Lab A — Wrong Service Selector

Edit Service:
```
kubectl edit svc demo-service -n integration-lab
```

Change:
```yaml
selector:
  app: demo
```

to:
```yaml
selector:
  app: wrong
```

Now test again.

Observe:

- Service exists
- Pods exist
- Traffic fails

Check endpoints:
```
kubectl get endpoints -n integration-lab
```

Fix the selector.

## Lab B — Missing ConfigMap Key

Edit ConfigMap:

```
kubectl edit configmap app-config -n integration-lab
```

Rename:

```yaml
APP_COLOR
```

to:
```yaml
APP_COLOUR
```

Restart pods:
```
kubectl rollout restart deployment demo-app -n integration-lab
```

Observe pod status:

```
kubectl get pods -n integration-lab
kubectl describe pod <pod-name> -n integration-lab
```

Fix the key.

## Lab C — Delete a Pod

Delete one pod:
```
kubectl delete pod <pod-name> -n integration-lab
```

Observe:

- ReplicaSet notices the missing Pod and creates a replacement
- Deployment manages the ReplicaSet.

Verify:
```
kubectl get pods -n integration-lab -w
```
Stop watch mode:

CTRL+C

## Cleanup

```
kubectl delete namespace integration-lab
```

## Questions for the Week

1. What Kubernetes objects were created during this lab?
    - AJ: Namespace, ConfigMap, Secret, Service, Deployment, ReplicaSet, Pods.
2. Which object was responsible for maintaining pod count?
    - AJ:  ReplicaSet
3. Why did the Service stop working when selectors changed?
    - Because the Service Selector metadata cant find a matching Label metadata on the Pod.
    - Because the Service selector could no longer find matching Pod labels, the Service had no Endpoints to route traffic to.
4. What are Endpoints in Kubernetes?
    - Endpoints are the dynamic list of internal IP:port of the Pods. Traffic goes to the Service's stable IP first, which uses that list to reliably reach any healthy member Pod.
5. Why did the pod fail when the ConfigMap key was missing?
    - The Pod failed because the container referenced a ConfigMap key that did not exist. Kubernetes could not inject the environment variable, so container startup failed.
    Important distinction:
      - Pod object may still be created
      - Container startup fails (CreateContainerConfigError commonly)
6. Why are Secrets stored differently from ConfigMaps?
    - Secrets are used for storing sensitive data and are base64-encoded, not encrypted by default.
      - Base64 is encoding, not security
      - etcd encryption-at-rest should be enabled in production clusters (random info)
7. What happens when a pod managed by a Deployment is deleted?
    - ReplicaSet will create a new replacement.
8. What is the relationship between:
   - Deployment - higher-level controller that manages ReplicaSet
   - ReplicaSet - controller that ensures desired state count is maintained.
   - Pod - smallest deployable unit and contains one or more containers.
9. Why is a Namespace useful in Kubernetes?
    - Namespace allows a logical isolation of Kubernetes resources, allowing multiple environments or teams to share the same cluster safely.
10. Which Week 1 concept feels strongest now?
    - Deployment, ReplicaSet, Pods, Selector/Labels
11. Which concept still feels confusing?
