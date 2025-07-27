package main

import (
    "fmt"
    "log"
    "net/http"
)

func main() {
    http.HandleFunc("/hello", func(w http.ResponseWriter, r *http.Request) {
        log.Printf("Received request from %s", r.RemoteAddr)
        fmt.Fprintln(w, "Hello from payment system!")
    })
    addr := "127.0.0.1:9090"
    log.Printf("Legacy payment server listening on %s", addr)
    log.Fatal(http.ListenAndServe(addr, nil))
}