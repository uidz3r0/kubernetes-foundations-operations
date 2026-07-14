# Lab 6 — Simulate Control Plane Failure

Stop kubelet on han.

```
sudo systemctl stop kubelet
```

Verify:

```
kubectl get nodes
```

Observe:

```
han   NotReady
```

The cluster should continue operating because luke still hosts the API server.

Restart:

```
sudo systemctl start kubelet
```

Verify recovery.

---

Optional

Repeat by stopping kubelet on luke while accessing the cluster through the controlPlaneEndpoint.

Discuss what happens if the endpoint is backed only by a single host versus a real load balancer or VIP.