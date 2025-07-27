#!/bin/bash
set -e
echo "🧹 Removing old images..."
docker image rm -f client-app:latest || true
docker image rm -f server-app:latest || true
echo "Building Docker images..."
docker build -t server-app:latest -f docker/server.Dockerfile .
docker build -t client-app:latest -f docker/client.Dockerfile .
echo "Loading images into kind..."
kind load docker-image server-app:latest
kind load docker-image client-app:latest
echo "Applying SPIRE manifests..."
kubectl apply -f spire/
echo "Applying Envoy ConfigMaps..."
kubectl apply -f envoy/
echo "Applying application manifests..."
kubectl apply -f k8s/
echo "Creating SPIRE entries..."
bash spire/registration-entries.sh
echo "All done."
