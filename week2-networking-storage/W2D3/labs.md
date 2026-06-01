# W2D3 - StatefulSets Lab

## Task 1 - Create Headless Service

- [x] Create yaml/headless-service.yaml
- [x] Apply the manifest
- [x] Verify Service exists

Commands:

kubectl apply -f yaml/headless-service.yaml

kubectl get svc

---

## Task 2 - Create StatefulSet

- [x] Create yaml/nginx-statefulset.yaml
- [x] Deploy StatefulSet
- [x] Verify Pods created sequentially

Commands:

kubectl apply -f yaml/nginx-statefulset.yaml

kubectl get statefulsets

kubectl get pods

Expected:

nginx-0
nginx-1
nginx-2

---

## Task 3 - Verify Stable Hostnames

- [x] Enter nginx-0
- [x] Check hostname

Commands:

kubectl exec -it nginx-0 -- hostname

Expected:

nginx-0

Repeat for nginx-1 and nginx-2.

---

## Task 4 - Verify DNS Resolution

- [x] Check Pod DNS names

Commands:

kubectl exec -it nginx-0 -- nslookup nginx-1.nginx

kubectl exec -it nginx-0 -- nslookup nginx-2.nginx

Observe:

Pods resolve individually.

---

## Task 5 - Scale StatefulSet

- [x] Scale from 3 to 5 replicas
- [x] Verify naming sequence

Commands:

kubectl scale statefulset nginx --replicas=5

kubectl get pods

Expected:

nginx-0
nginx-1
nginx-2
nginx-3
nginx-4

---

## Task 6 - Observe Ordered Deletion

- [x] Scale down to 2 replicas
- [x] Observe deletion order

Commands:

kubectl scale statefulset nginx --replicas=2

kubectl get pods -w

Expected:

nginx-4 deleted first
nginx-3 deleted second

Remaining:

nginx-0
nginx-1

---

## Task 7 - Cleanup

- [x] Delete StatefulSet
- [x] Delete Service

Commands:

kubectl delete statefulset nginx

kubectl delete service nginx

kubectl get all