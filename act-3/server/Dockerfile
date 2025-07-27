FROM golang:1.21 AS builder
WORKDIR /app

# Copiar os arquivos de dependência primeiro para aproveitar cache
COPY go.mod go.sum ./
RUN go mod download

# Copiar o código-fonte
COPY *.go ./

# Build estático
ENV CGO_ENABLED=0 GOOS=linux GOARCH=amd64
RUN go build -a -installsuffix cgo -o server-app .

# Imagem final enxuta
FROM debian:bullseye-slim
COPY --from=builder /app/server-app /usr/local/bin/server-app
ENTRYPOINT ["server-app"]
