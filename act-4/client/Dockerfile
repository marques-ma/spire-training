FROM golang:1.21 AS builder
WORKDIR /app
COPY go.mod ./
RUN go mod download

COPY *.go ./
# desabilita CGO e força link estático
ENV CGO_ENABLED=0 GOOS=linux GOARCH=amd64
RUN go build -a -installsuffix cgo -o client-app .

FROM debian:bullseye-slim
COPY --from=builder /app/client-app /usr/local/bin/client-app
ENTRYPOINT ["client-app"]
