#!/bin/bash

set -e

if [[ "$1" == "reset" ]]; then
  echo "🧹 Resetting SPIRE deployment..."

  # Delete everything in the spire namespace, if it exists
  if kubectl get ns spire &> /dev/null; then
    kubectl delete ns spire --wait
    echo "✅ Namespace 'spire' and its resources deleted."
  else
    echo "ℹ️ Namespace 'spire' does not exist. Nothing to delete."
  fi
fi

echo "📄 Applying Kubernetes manifests..."

# Create the SPIRE server namespace
kubectl apply -f spire-namespace.yaml

# Apply the SPIRE server manifests
kubectl apply \
  -f server-account.yaml \
  -f spire-bundle-configmap.yaml \
  -f server-cluster-role.yaml

kubectl apply \
  -f server-configmap.yaml \
  -f server-statefulset.yaml \
  -f server-service.yaml

# Apply the SPIRE agent manifests
kubectl apply \
  -f agent-account.yaml \
  -f agent-cluster-role.yaml

kubectl apply \
  -f agent-configmap.yaml \
  -f agent-daemonset.yaml

echo "✅ Kubernetes manifests applied successfully."

echo "⏳ Waiting for SPIRE server pod to become ready..."
kubectl wait --for=condition=ready pod -l app=spire-server -n spire --timeout=60s

echo "🚀 Creating registration entry for the SPIRE agent..."
kubectl exec -n spire spire-server-0 -- /opt/spire/bin/spire-server entry create \
  -node -spiffeID spiffe://neutrino.org/ns/spire/sa/spire-agent \
  -selector k8s_psat:cluster:demo-cluster \
  -selector k8s_psat:agent_ns:spire \
  -selector k8s_psat:agent_sa:spire-agent

# echo "🔎 Checking created agent entry..."
# AGENT_SPIFFE_ID=$(kubectl exec -n spire spire-server-0 -- /opt/spire/bin/spire-server agent list | grep 'spiffe://neutrino.org/spire/agent/k8s_psat' | awk '{print $4}')

# if [ -z "$AGENT_SPIFFE_ID" ]; then
#   echo "❌ Failed to retrieve SPIFFE ID of the agent. Exiting."
#   exit 1
# fi

# echo "✅ Agent SPIFFE ID found: $AGENT_SPIFFE_ID"
echo "✅ Deployment completed successfully."

echo "📋 To verify the deployment, you can check the logs of the agent and server using:"
echo "kubectl logs -f <pod-name> -n spire"
