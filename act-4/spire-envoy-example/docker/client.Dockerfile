FROM golang:1.21 as builder
WORKDIR /app
COPY app/client.go .
COPY app/client-go.mod ./go.mod

# Desabilita CGO e força link estático
ENV CGO_ENABLED=0 GOOS=linux GOARCH=amd64

RUN go build -a -installsuffix cgo -o client-app .

FROM debian:bullseye-slim
COPY --from=builder /app/client-app /usr/local/bin/client-app
ENTRYPOINT ["/usr/local/bin/client-app"]
