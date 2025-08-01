#!/bin/bash

set -e

echo "🧹 Removing old Docker images (if any)..."

docker image rm -f client-app:latest || true
docker image rm -f server-app:latest || true

echo "📦 Building Docker images..."

# Build client
docker build --no-cache -t client-app:latest -f client/Dockerfile ./client

# Build server
docker build --no-cache -t server-app:latest -f server/Dockerfile ./server

echo "📤 Loading images into the Kind cluster..."

kind load docker-image client-app:latest
kind load docker-image server-app:latest

echo "📄 Applying Kubernetes manifests..."

# Apply shared Envoy config (ConfigMap with both client and server configs)
kubectl apply -f configmaps/configmaps.yaml

# Apply server components
kubectl apply -f services/server-serviceaccount.yaml
kubectl apply -f deployments/server.yaml
kubectl apply -f services/server.yaml

# Apply client components
kubectl apply -f services/client-serviceaccount.yaml
kubectl apply -f jobs/client-job.yaml

echo "🔎 Fetching SPIFFE ID of the SPIRE agent for registration entries..."

AGENT_SPIFFE_ID=$(kubectl exec -n spire spire-server-0 -- /opt/spire/bin/spire-server agent list | grep 'spiffe://neutrino.org/spire/agent/k8s_psat' | awk '{print $4}')

if [ -z "$AGENT_SPIFFE_ID" ]; then
  echo "❌ Failed to retrieve SPIFFE ID of the agent. Exiting."
  exit 1
fi

echo "✅ Agent SPIFFE ID found: $AGENT_SPIFFE_ID"

echo "📝 Creating registration entries..."

kubectl exec -n spire spire-server-0 -- /opt/spire/bin/spire-server entry create \
  -parentID "$AGENT_SPIFFE_ID" \
  -spiffeID spiffe://neutrino.org/ns/default/sa/server-envoy \
  -selector k8s:ns:default \
  -selector k8s:sa:server-envoy || true

kubectl exec -n spire spire-server-0 -- /opt/spire/bin/spire-server entry create \
  -parentID "$AGENT_SPIFFE_ID" \
  -spiffeID spiffe://neutrino.org/ns/default/sa/client-envoy \
  -selector k8s:ns:default \
  -selector k8s:sa:client-envoy || true

echo "✅ Registration entries created successfully."

echo "✅ Deployment completed successfully."
