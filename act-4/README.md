# SPIRE Demo Setup on Kind with Envoy and SPIFFE-SVID

This guide walks you through setting up a SPIRE demo environment on `kind`, with a SPIFFE-authenticated communication between a client and a server using Envoy.

---

## Prerequisites

- `kind` installed and a cluster running
- Docker installed
- `kubectl` configured for the kind cluster
- SPIRE already running (Follow activity 2)
- `server-app` and `client-app` source code
- SPIRE server and agent manifests

---

## Step-by-step Instructions

### 1. Start the Kind cluster

```bash
kind create cluster
```

---

### 2. Deploy SPIRE server and agent

Deploy SPIRE components in the `spire` namespace, as detailed in Activity 2.


---

### 3. Identify SPIRE Agent SPIFFE ID

List registered agents to find the SPIFFE ID you'll use as `parentID`:

```bash
kubectl exec -n spire spire-server-0 -- /opt/spire/bin/spire-server agent list
```

Look for the SPIFFE ID under the `SPIFFE ID` field (e.g., `spiffe://neutrino.org/spire/agent/...`).

---

### 4. Create Workload Registration Entries

Use the agent’s SPIFFE ID from the previous step in place of `<Agent SPIFFE-ID>`.

```bash
kubectl exec -n spire spire-server-0 -- /opt/spire/bin/spire-server entry create \
    -parentID <Agent SPIFFE-ID> \
    -spiffeID spiffe://neutrino.org/ns/default/sa/server-envoy \
    -selector k8s:ns:default \
    -selector k8s:sa:server-envoy

kubectl exec -n spire spire-server-0 -- /opt/spire/bin/spire-server entry create \
    -parentID <Agent SPIFFE-ID> \
    -spiffeID spiffe://neutrino.org/ns/default/sa/client-envoy \
    -selector k8s:ns:default \
    -selector k8s:sa:client-envoy
```

---

### 5. Build and Load Images into Kind

```bash
docker build -t server-app:latest server/
docker build -t client-app:latest client/

kind load docker-image server-app:latest
kind load docker-image client-app:latest
```

---

### 6. Deploy the Server

Apply the following manifests in order:

```bash
kubectl apply -f server/server-serviceaccount.yaml
kubectl apply -f server/server-configmap.yaml
kubectl apply -f server/server-deployment.yaml
kubectl apply -f server/server-service.yaml
```

---

### 7. Deploy the Client Job

```bash
kubectl apply -f client/client-serviceaccount.yaml
kubectl apply -f client/client-configmap.yaml
kubectl apply -f client/client-job.yaml
```

---

### 8. Check the Logs

Monitor the logs of the client job to ensure the connection was successful:

```bash
kubectl logs -l job-name=client-app
```

Or for an interactive shell:

```bash
kubectl exec -it $(kubectl get pod -l job-name=client-app -o jsonpath='{.items[0].metadata.name}') -- /bin/sh
```

---

## Notes

- `Deployment` for the client is no longer needed when using a `Job`.
- Both client and server use `envoy` sidecars and `spire-agent` socket mount.
- Envoy is configured via ConfigMaps in both pods.
- The communication between client and server is authenticated using SPIFFE IDs and validated using mTLS through Envoy.

---