#!/bin/bash

set -e

echo "🧹 Removing old Docker images (if any)..."

docker image rm -f client-app:latest || true
docker image rm -f server-app:latest || true

echo "📦 Building Docker images..."

# Build client
docker build -t client-app:latest -f client/Dockerfile ./client

# Build server
docker build -t server-app:latest -f server/Dockerfile ./server

echo "📤 Loading images into the Kind cluster..."

kind load docker-image client-app:latest
kind load docker-image server-app:latest

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
  -spiffeID spiffe://neutrino.org/ns/default/sa/server-mtls \
  -selector k8s:pod-label:app:server-app   \
  -selector k8s:ns:spire

kubectl exec -n spire spire-server-0 -- /opt/spire/bin/spire-server entry create \
  -parentID "$AGENT_SPIFFE_ID" \
  -spiffeID spiffe://neutrino.org/ns/default/sa/client-mtls \
  -selector k8s:pod-label:app:client-app   \
  -selector k8s:ns:spire

echo "✅ Registration entries created successfully."

echo "📄 Applying Kubernetes manifests..."
kubectl apply -f k8s/server-deployment.yaml
kubectl apply -f k8s/client-job.yaml

echo "✅ Deployment completed successfully."

echo "To verify the deployment, you can check the logs of the client and server pods using:"
echo "kubectl logs -f <pod-name> -n default"
