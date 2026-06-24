# W4D7 – Week 4 Review

---

## Lab 1 – Scheduling Review

Apply:

kubectl apply -f yaml/review1.yaml

Tasks:

- Why is the pod Pending?
- Identify the scheduling problem.
- Fix the issue.

  - Fixed it with labeling 1 node with `disk=ssd` 

---

## Lab 2 – Image Problems

Apply:

kubectl apply -f yaml/review2.yaml

Tasks:

- Determine pod state.
- Investigate events.
- Fix the image.

  - Fixed it by editing the running pod to `nginx:latest`

---

## Lab 3 – Networking Review

Apply:

kubectl apply -f yaml/review3.yaml

Tasks:

- Why does the service have no endpoints?
- Fix connectivity.

  - Fixed it by changing service selector to match the pod `app=frontend`

---

## Lab 4 – Storage Review

Apply:

kubectl apply -f yaml/review4.yaml

Tasks:

- Investigate the PVC.
- Determine why the pod remains Pending.
- Repair the storage issue.

  - Fixed it by creating PV with `storageClassName=manual` and updated PVC to have the same.

---

## Lab 5 – Final Challenge

Apply:

kubectl apply -f yaml/final-challenge.yaml

Without looking at the YAML:

- Identify all issues.
- Use only:
    kubectl get
    kubectl describe
    kubectl logs
    kubectl get events

Fix the application until:

- Pod Running.
- Service endpoints exist.
- Application reachable.

---

## Speed Drill

For each problem:

1. kubectl get
2. kubectl describe
3. kubectl get events
4. kubectl logs

Goal:

- Single issue: under 2 minutes.
- Mixed issue: under 5 minutes.

---

## Self Assessment

Rate yourself:

[ ] Logs
[ ] Describe
[ ] Events
[ ] Scheduling
[ ] Networking
[ ] Storage
[ ] Service troubleshooting
[ ] Pod troubleshooting
[ ] Cluster troubleshooting

Weakest topic:

_____________________

Strongest topic:

_____________________