# Minimal SPIRE mTLS Client/Server

This repo contains a **minimal** client/server setup that uses SPIRE-issued SVIDs for mTLS.

> Assumes a working SPIRE infrastructure in the `spire` namespace of a Kind cluster.

## Structure

- `client/` – Go code for the mTLS client.
- `server/` – Go code for the mTLS server.
- `k8s/` – Only the manifests needed to run the client and server.

## Instructions

1. Build and push your images:

```bash
cd client && docker build -t client-app:latest .
cd ../server && docker build -t server-app:latest .
```

2. Load the images to Kind:

```bash
kind load docker-image server-app:latest
kind load docker-image client-app:latest
```

3. Create the registration entries  

PS: Fetch the ParentID from your spire-server entry show
```bash
kubectl exec -n spire spire-server-0 -- /opt/spire/bin/spire-server entry create   -spiffeID spiffe://neutrino.org/server   -parentID spiffe://neutrino.org/spire/agent/k8s_psat/demo-cluster/899c8ca3-78f0-4825-8a3e-279ce0f21f79   -selector k8s:pod-label:app:server-app   -selector k8s:ns:spire
```

```bash
kubectl exec -n spire spire-server-0 -- /opt/spire/bin/spire-server entry create   -spiffeID spiffe://neutrino.org/client   -parentID spiffe://neutrino.org/spire/agent/k8s_psat/demo-cluster/899c8ca3-78f0-4825-8a3e-279ce0f21f79   -selector k8s:pod-label:app:client-app   -selector k8s:ns:spire
```

4. Deploy:

```bash
kubectl apply -f k8s/server-deployment.yaml
kubectl apply -f k8s/client-job.yaml
```

5. Check the client's output:

```bash
kubectl logs job/client-app -n spire
```
