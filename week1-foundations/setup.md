# Week 1 - Environment Setup (Pre-Day 1)

## Objective

Prepare a local Kubernetes learning environment on Ubuntu using:

- Docker Engine
- kubectl
- kind
- Multi-node local Kubernetes cluster

---

# 1. Install Docker Engine

## Install from Docker official repository

```bash
sudo apt update
sudo apt install ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" \
| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

---

## Add user to Docker group

```bash
sudo usermod -aG docker allan
newgrp docker
```

### Reason

Reload current shell with updated Docker group membership without logging out.

---

## Verify Docker socket permissions

```bash
ls -l /var/run/docker.sock
```

Expected:

```text
srw-rw---- root docker ...
```

---

## Verify Docker installation

```bash
docker --version
systemctl status docker
systemctl is-active docker
docker run hello-world
```

Expected:

- Docker version displays
- Docker service = active
- hello-world container runs successfully

---

# 2. Install kubectl

## Install latest stable binary

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

---

## Verify kubectl

```bash
kubectl version --client
```

Expected:

```text
Client Version: ...
```

---

# 3. Install kind

## Install kind binary

```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-amd64

chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

---

## Verify kind

```bash
kind version
```

Expected:

```text
kind v...
```

---

# 4. Create Local Kubernetes Cluster

## Create cluster config file

Create:

`kind-config.yaml`

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4

nodes:
- role: control-plane
- role: worker
- role: worker
```

---

## Create cluster

```bash
kind create cluster --name learning --config kind-config.yaml
```

---

## Verify cluster

```bash
kubectl get nodes
kubectl cluster-info
kubectl cluster-info --context kind-learning
```

Expected:

```text
learning-control-plane   Ready
learning-worker          Ready
learning-worker2         Ready
```

---

# 5. Kubernetes Context Checks

```bash
kubectl config get-contexts
kubectl config current-context
```

Expected:

```text
kind-learning
```

---

# 6. Enable kubectl Bash Completion

```bash
sudo apt install bash-completion -y

echo 'source <(kubectl completion bash)' >> ~/.bashrc
source ~/.bashrc
```

---

## Test autocomplete

Try:

```bash
kubectl get po<TAB>
```

Expected:

Autocomplete suggestions appear.

---

# 7. Cluster Cleanup

Delete cluster if needed:

```bash
kind delete cluster --name learning
```

Useful Docker checks:

```bash
docker ps
docker images
```

---

# Notes

## Why kind?

- Lightweight local Kubernetes
- Uses Docker containers as nodes
- Fast to rebuild
- Good for labs and troubleshooting practice

## Cluster Topology

Ubuntu Laptop
→ Docker
→ kind cluster

- 1 control-plane
- 2 worker nodes

This allows:

- scheduling practice
- node troubleshooting
- drain/cordon labs
- more realistic Kubernetes behavior