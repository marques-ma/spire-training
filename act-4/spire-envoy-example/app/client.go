package main

import (
    "io/ioutil"
    "log"
    "net/http"
    "os"
    "time"
)

func main() {
    url := "http://server-app:8080/hello"
    if u := os.Getenv("SERVER_URL"); u != "" {
        url = u
    }

    client := &http.Client{Timeout: 5 * time.Second}
    log.Printf("Client sending request to %s", url)
    resp, err := client.Get(url)
    if err != nil {
        log.Fatalf("Request failed: %v", err)
    }
    defer resp.Body.Close()

    body, _ := ioutil.ReadAll(resp.Body)
    log.Printf("Server responded: %s", string(body))
}