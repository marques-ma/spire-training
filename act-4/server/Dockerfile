FROM golang:1.21 AS builder
WORKDIR /app

# Copia apenas os arquivos de dependência para aproveitar cache do Docker
COPY go.mod ./
RUN go mod download

# Copia os arquivos fonte do server
COPY *.go ./

# Desabilita CGO e força link estático
ENV CGO_ENABLED=0 GOOS=linux GOARCH=amd64

# Compila o binário do servidor
RUN go build -a -installsuffix cgo -o server-app .

FROM debian:bullseye-slim
COPY --from=builder /app/server-app /usr/local/bin/server-app
ENTRYPOINT ["server-app"]
