run kind
start spire server and agent in spire namespace
create registration entries 
the id after demo-cluster should vary, check first with:
kubectl exec -n spire spire-server-0 --   /opt/spire/bin/spire-server agent list

then use the SPIFFE-ID of the agent as PARENT-ID

    kubectl exec -n spire spire-server-0 --   /opt/spire/bin/spire-server entry create     -parentID <Agent SPIFFE-ID>     -spiffeID spiffe://neutrino.org/ns/default/sa/server-envoy     -selector k8s:ns:default     -selector k8s:sa:server-envoy

    kubectl exec -n spire spire-server-0 --   /opt/spire/bin/spire-server entry create     -parentID <Agent SPIFFE-ID>     -spiffeID spiffe://neutrino.org/ns/default/sa/client-envoy     -selector k8s:ns:default     -selector k8s:sa:client-envoy

build and load server-app and client-app images to kind
apply server deployment
apply configmaps
apply server-serviceaccount
apply services/server.yaml
apply client-serviceaccount
apply client deployment
