# Activity 2: Deploying SPIRE in Kubernetes

This guide describes the automated process for deploying the SPIRE Server and Agent in a local Kubernetes cluster (e.g., using Kind), using the `deploy.sh` script.

## Prerequisites

- A running local Kubernetes cluster (e.g., Kind)
- `kubectl` configured and connected to the cluster
- The following Kubernetes manifest files available in the current directory:
  - `spire-namespace.yaml`
  - `server-account.yaml`
  - `spire-bundle-configmap.yaml`
  - `server-cluster-role.yaml`
  - `server-configmap.yaml`
  - `server-statefulset.yaml`
  - `server-service.yaml`
  - `agent-account.yaml`
  - `agent-cluster-role.yaml`
  - `agent-configmap.yaml`
  - `agent-daemonset.yaml`

## How to Run

To deploy SPIRE, simply run:

```bash
./run.sh
```

To reset the environment and remove a previous deployment:

```bash
./run.sh reset
```

## What the Script Does

### 1. (Optional) Reset Environment

If the script is called with the `reset` argument, it will:
- Check if the `spire` namespace exists.
- If it exists, delete the namespace and wait for all resources to be removed.

### 2. Apply Kubernetes Manifests

- Create the `spire` namespace.
- Apply SPIRE Server resources:
  - Service Account, Bundle ConfigMap, ClusterRole, Configuration ConfigMap, StatefulSet, and Service.
- Apply SPIRE Agent resources:
  - Service Account, ClusterRole, Configuration ConfigMap, and DaemonSet.

### 3. Wait for SPIRE Server Pod

- Waits for the SPIRE Server pod to become `Ready`, with a timeout of 60 seconds.

### 4. Create Agent Registration Entry

- Executes the `spire-server entry create` command inside the `spire-server-0` pod to register the SPIRE Agent with the following selectors:
  - `k8s_psat:cluster:demo-cluster`
  - `k8s_psat:agent_ns:spire`
  - `k8s_psat:agent_sa:spire-agent`

### 5. Final Output

Once complete, you can check the logs:

```bash
kubectl logs -f <pod-name> -n spire
```

## Expected Outcome

- The SPIRE Server is running as a StatefulSet in the `spire` namespace.
- The SPIRE Agent is running as a DaemonSet.
- A valid node registration entry has been created for the Agent in the SPIRE Server.
