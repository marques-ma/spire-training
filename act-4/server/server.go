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

	addr := "0.0.0.0:8080"
	log.Printf("Legacy payment server listening on %s", addr)
	if err := http.ListenAndServe(addr, nil); err != nil {
		log.Fatalf("Server error: %v", err)
	}
}
