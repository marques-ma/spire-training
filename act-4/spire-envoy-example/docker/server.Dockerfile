FROM golang:1.21 as builder
WORKDIR /app
COPY app/server.go .
COPY app/server-go.mod ./go.mod

# Desabilita CGO e força link estático
ENV CGO_ENABLED=0 GOOS=linux GOARCH=amd64

RUN go build -a -installsuffix cgo -o server-app .

FROM debian:bullseye-slim
COPY --from=builder /app/server-app /usr/local/bin/server-app
ENTRYPOINT ["/usr/local/bin/server-app"]
