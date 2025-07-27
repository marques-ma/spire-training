#!/bin/bash

set -e

echo "🧹 Removendo imagens Docker antigas (se existirem)..."

docker image rm -f client-app:latest || true
docker image rm -f server-app:latest || true

echo "📦 Construindo imagens Docker..."

# Build client
docker build -t client-app:latest -f client/Dockerfile ./client

# Build server
docker build -t server-app:latest -f server/Dockerfile ./server

echo "📤 Carregando imagens no cluster Kind..."

kind load docker-image client-app:latest
kind load docker-image server-app:latest

echo "🚀 Aplicando os manifests no Kubernetes..."

kubectl apply -f deployments/server.yaml
kubectl apply -f deployments/client.yaml
kubectl apply -f services/server.yaml

echo "✅ Aplicação implantada com sucesso."
