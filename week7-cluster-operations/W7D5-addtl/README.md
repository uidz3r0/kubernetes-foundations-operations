# W7D5 — High Availability Control Plane

## Objective

Convert the single kubeadm control plane into a highly available control plane.

By the end of this lab you will understand:

- Multi-control-plane architecture
- Control Plane Endpoint
- Uploading certificates
- Certificate Key
- Joining additional control plane nodes
- Stacked etcd topology
- Quorum
- Failure scenarios

### Summary Workflow

```bash
# On luke
sudo upload-certs.sh
    - a1340295cb359c56aeec0c08f7e4b724c75a23063140e53c0e231a42ac6e4413 

sudo generate-control-plane-join.sh
    - kubeadm join 10.1.1.10:6443 --token 3u8son.w6zuz5ykqju0i5yo --discovery-token-ca-cert-hash sha256:0adc5762cfe972b8caafd7ac67a031770c47b8de9bb747840e6dfb96485b9639 --control-plane --certificate-key c81686f0320a4c9f910724e238f1e8e29c6ca687037b94b9db35b9ff5289f369

# Copy the generated command

# On han
sudo kubeadm join ... --control-plane ...
```

---

# Step 1

Verify current cluster.

```
sh scripts/common/check-control-planes.sh
```

---

# Step 2 (on luke)

Upload cluster certificates.

```
sudo sh scripts/common/upload-certs.sh
```

---

# Step 3

Generate the control plane join command.

```
sudo sh scripts/common/generate-control-plane-join.sh
```

Save the generated command.

---

# Step 4

Copy the command to han.

Run it as root.

---

# Step 5

Wait several minutes.

Verify.

```
kubectl get nodes
```

---

# Step 6

Inspect etcd members.

```
sh scripts/common/check-etcd.sh
```

---

# Step 7

Check quorum.

```
sh scripts/common/check-quorum.sh
```

---

# Step 8

Review the architecture documents.

```
docs/
```

---

# Expected Result

```
NAME    STATUS   ROLES

luke    Ready    control-plane
han     Ready    control-plane
leia    Ready    worker
```

---

### Stacked-etcd cluster:

```bash
luke   -> Control Plane + etcd
han    -> Control Plane + etcd
padme  -> Control Plane + etcd
leia   -> Worker
```