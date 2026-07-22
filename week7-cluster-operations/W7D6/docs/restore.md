# Restoring etcd

Restoring creates a new etcd data directory from a snapshot.

The kubeadm static pod manifest must then point to the restored data directory.

After kubelet reloads the manifest, etcd starts with the restored data.