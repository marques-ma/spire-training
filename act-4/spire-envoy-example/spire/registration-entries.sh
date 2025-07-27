#!/bin/bash

# Entry for the server
kubectl exec -n spire spire-server-0 -c spire-server --   /opt/spire/bin/spire-server entry create     -spiffeID spiffe://example.org/server     -selector k8s:pod-label:app:server-app     -parentID spiffe://example.org/spire/agent/k8s_psat/cluster/spire/agent   

# Entry for the client
kubectl exec -n spire spire-server-0 -c spire-server --   /opt/spire/bin/spire-server entry create     -spiffeID spiffe://example.org/client     -selector k8s:pod-label:app:client-app     -parentID spiffe://example.org/spire/agent/k8s_psat/cluster/spire/agent   
