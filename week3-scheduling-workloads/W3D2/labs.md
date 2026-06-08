# W3D2 Labs – DaemonSets

---

## Lab 1 – Basic DaemonSet

Create:

kubectl apply -f yaml/daemonset-basic.yaml

Verify:

kubectl get ds

Check Pods:

kubectl get pods -o wide

Questions:

1. How many nodes exist?
   - 2 worker nodes

2. How many Pods were created?
   - 2 Pods total, one Pod on each of the 2 worker nodes. This is because a DaemonSet creates one Pod per node, not multiple Pods per node.

3. Why?
   - DaemonSet ensures all nodes have pods running.

Delete:

kubectl delete -f yaml/daemonset-basic.yaml

---

## Lab 2 – Add Another Worker

Create cluster:

kind get clusters

kind delete cluster

kind create cluster --config yaml/kind-config.yaml

Verify:

kubectl get nodes

Deploy:

kubectl apply -f yaml/daemonset-basic.yaml

Check:

kubectl get pods -o wide

Questions:

1. How many nodes?
   - 2 worker nodes

2. How many Pods?
   - two pods.

3. What happened automatically?
   - The DaemonSet automatically created a Pod on each node. It’s the DaemonSet controller that responds to the new node and schedules the Pod automatically.

---

## Lab 3 – DaemonSet with Node Selector

View labels:

kubectl get nodes --show-labels

Label worker:

kubectl label node kind-worker storage=true

Apply:

kubectl apply -f yaml/daemonset-node-selector.yaml

Verify:

kubectl get pods -o wide

Questions:

1. Which node received the Pod?
   - The node with NodeSelector received the Pod

2. Why didn't other nodes receive one?
   - The NodeSelector ensures it only schedules to nodes with matching label.

Delete:

kubectl delete -f yaml/daemonset-node-selector.yaml

---

## Lab 4 – DaemonSet and Tolerations

Taint a node:

kubectl taint node worker2 dedicated=logging:NoSchedule

Apply:

kubectl apply -f yaml/daemonset-toleration.yaml

Verify:

kubectl get pods -o wide

Questions:

1. Which node received the Pod?
   - Both worker nodes received Pods because the DaemonSet Pod has a toleration for the tainted node. The Pod is allowed on the tainted node because of the -> toleration.

2. Why was the tainted node included?
   - The toleration is immune to the node's taint, so it can create pod on the node.
   - Better: The DaemonSet created Pods on both worker nodes because the Pod template included a toleration for dedicated=logging:NoSchedule.

3. What would happen without the toleration?
   - Without the toleration, then the pod cannot schedule on that node.

---

## Lab 5 – Observe DaemonSet Behaviour

Create:

kubectl apply -f yaml/daemonset-basic.yaml

Watch:

kubectl get pods -o wide -w

Delete one Pod:

kubectl delete pod <pod-name>


Observe:

1. What recreated the Pod?
   - The DaemonSet Controller recreated the deleted pod except for the tainted node.

2. Was a new node added?
   - No new node added. What made you think so?

3. How does this differ from a Deployment?
   - A Deployment maintains a desired number of replicas, and those replicas can land on any eligible node. A DaemonSet maintains one Pod per eligible node, so its desired count changes when matching nodes are added or removed.
   - A DaemonSet keeps one Pod running on every matching/eligible node, and if the Pod is deleted, the DaemonSet controller recreates it.

A few fixes:

- DaemonSet means every eligible node, not always every node
- In your lab, you correctly saw 2 Pods because your kind cluster has 2 workers. The control-plane node usually has a taint, so a normal DaemonSet won’t run there unless it has a matching toleration.

---

## Challenge

Create a DaemonSet that:

- Uses nginx
- Runs only on nodes labeled monitoring=true
- Includes a custom label app=monitor-agent

Verify:

kubectl get ds
kubectl get pods --show-labels